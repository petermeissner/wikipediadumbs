
#### packages ##################################################################

suppressPackageStartupMessages({
  library(wpd)
  library(stringr)
  library(dplyr)
  library(urltools)
  library(utf8)
  library(DBI)
  library(RPostgreSQL)
  library(data.table)
})



#### globals ###################################################################

# log start time
start_time <- Sys.time()


# get script arguments
args <- wpd_get_args()
if( class(file) =="function" ){
  file  <- args$file
}
cat("\n\n --", { if( is.null(file) ){"file: NULL"} else {file} }, "-- \n\n ")

date   <- ""
lang   <- ""
job_id <- "unknown"



#### error handler #############################################################
error_function <-
  function(){
    if ( !exists("date") | class(date) == "function" ){
      date <- ""
    }

    if(!exists("lang")){
      lang <- ""
    }

    em    <- geterrmessage()
    fname <- paste0("Rscript_", paste(date, paste(lang, collapse = "_"), sep = "_"), ".error")
    sink(file = fname)
    cat( "\n-----------------\n\n", file, "\n\n----------------\n")
    cat( "\n-----------------\n\n", em, "\n----------------\n")
    traceback(2)
    sink()

    cat( "\n-----------------\n\n", em, "\n----------------\n")
    cat(readLines(fname), sep = "\n")



    if ( exists("job_id") ){

      cat( "\n-----------------\njob_id:", job_id, "\n-----------------\n")

      wpd_job_update(
        job_id      = job_id,
        job_status  = "error",
        job_comment = paste(readLines(fname), collapse = "\n"),
        job_end_ts  = as.character(Sys.time())
      )

      if ( !interactive() ) {
        Sys.sleep(4)
      }

    }else{
      job_id <- "unknown"
      cat( "\n-----------------\njob_id:", job_id, "\n-----------------\n")
    }


    if ( !interactive() ) {

      wpd_notify(
        wpd_current_node(), "[", job_id, "]",
        date, "--",
        file, "--",
        paste(lang, collapse = ", "), "--",
        paste(readLines(fname), collapse = "\n")
      )

      q(save = "no")
    }

  }


options( "error" = error_function )




#### START : DUTY TO DO FUNCTION WITH IMMEDIATE EXECUTION
# it is used to be able to 'break' execution without raising an error
#
#
duty_to_do_function <-
  function()
  {


    # ---- get date and lang ---------------------------------------------------
    date <<-
      as.character(
        as.Date(
          str_extract(file, "\\d{4}\\d{2}\\d{2}"),
          format = "%Y%m%d"
        )
      )

    lang <<- wpd_languages


    # # ---- checks for information completeness ---------------------------------

    # check global variables
    stopifnot(
      exists("date"),
      exists("lang"),
      exists("file"),
      class(file) != "function"
    )


    # ---- register a job ------------------------------------------------------

    (execute <- wpd_check_job_execution_necessary(date = date, lang = lang))

    if( execute == TRUE ){

      # do nothing, carry on

    } else {

      # stop function by returning
      return(NULL)
    }


    new_job_res <-
      wpd_job_new(
        lang     = lang,
        date     = date,
        file     = file,
        job_type =
          paste(
            gsub("^.*\\.","",file),
            "all",
            sep = ", "
          )
      )
    job_id <<- new_job_res$job_id


    # check if all files are available
    files <-
      list.files(path = dirname(file), pattern = basename(file), full.names = TRUE)

    if( length(files) != 24 ){
      stop("Expected number of .gz files for date 24 but found ", length(files), ".")
    }



    # clean up database before putting in data
    wpd_get_query(
      paste0(
        "delete from page_views_traffic",
        " where traffic_date = '", date,"' and page_language in ",
        wpd_sql_values(lang)
      )
    )

    wpd_get_queries(
      queries =
        paste0(
          "delete from page_views_", lang,
          " where page_view_date = '", date, "'"
        )
    )

    table_names <- paste0("tmp_page_views_", lang, "_", gsub("-", "_", date))
    sql         <-
      SQL(
        c(
          wpd_sql("drop table if exists ") + table_names,
          wpd_sql("create table %s (like page_views_%s)", table_names, lang)
        )
      )

    wpd_get_queries(sql)



    # ---- read through file ---------------------------------------------------
    progress <- 0
    n_lines  <- 100000

    for ( i in seq_along(files) ){

      # read in text from file
      f_con <- gzcon(file(files[i], "rb"))
      f     <- readLines(f_con, n = n_lines)


      # read more from file
      while ( length(f) > 0 ) {
        # transform to list of data.tables
        f_df_list <- wpd_dump_lines_hourly_to_df_list(f)

        res <-
          lapply(
            X   = f_df_list,
            FUN =
              function(df){
                wpd_upload_pageview_counts(
                  page_name       = utf8_encode(df$page_name),
                  page_view_count = df$page_view_count,
                  page_view_date  = date,
                  page_language   = df$lang[1],
                  upload_type     = "gz"
                )
              }
          )

        # log progress
        progress <- progress + length(f)

        wpd_job_log(
          date       = date,
          lang       = lang,
          file       = file,
          start_time = start_time,
          progress   = progress,
          job_id     = job_id
        )

        f     <- readLines(f_con, n = n_lines)
      }

      close(f_con)
    }

    #---- aggregate  -----------------------------------------------------------

    sql <-
      wpd_sql(
        "insert into page_views_%s
        (select page_id, page_view_date, sum(page_view_count)
        from tmp_page_views_%s_%s
        group by page_id, page_view_date);",
        lang,
        lang,
        gsub("-", "_", date)
      )
    res <- wpd_get_queries(sql)


    #---- clean up temporary tables --------------------------------------------

    wpd_get_queries(
      wpd_sql("drop table if exists ") + table_names
    )


    #---- end ------------------------------------------------------------------

    # update job progress one last time to get pace right
    wpd_job_log(
      date       = date,
      lang       = lang,
      file       = file,
      start_time = start_time,
      progress   = progress,
      job_id     = job_id
    )

    # update job status - DONE
    wpd_job_update(
      job_id     = job_id,
      job_end_ts = as.character(Sys.time()),
      job_status = "done"
    )

    # update task status - DONE
    wpd_task_update(
      task_id        = wpd_get_tasks(date = date, lang = lang)$task_id,
      task_status    = "done",
      task_duration  = (as.integer(difftime(Sys.time(), start_time, units = "secs")) / length(lang)),
      task_volume    = (progress / length(lang))
    )


  }
#### END : DUTY TO DO FUNCTION
debug(duty_to_do_function)
duty_to_do_function()





#### end #######################################################################
cat(
  "\n\n--- done after:",
  as.character(
    hms::hms(
      round(
        as.numeric(
          difftime(
            Sys.time(),
            start_time,
            units = "secs"
          )
        )
      )
    )
  ),
  "---\n"
)

