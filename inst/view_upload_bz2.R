
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
cat("\n\n -- ", file, "-- \n\n ")





#### error handler #############################################################
options(
  "error" =
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
      cat( "\n-----------------\n\n", em, "\n----------------\n")
      traceback(2)
      sink()

      cat( "\n-----------------\n\n", em, "\n----------------\n")
      cat(readLines(fname), sep = "\n")



      if ( exists("job_id") ){

        cat( "\n-----------------\n\n", job_id, "\n----------------\n")

        wpd_job_update(
          job_id      = job_id,
          job_status  = "error",
          job_comment = paste(readLines(fname), collapse = "\n"),
          job_end_ts  = as.character(Sys.time())
        )

      }else{
        job_id <- "unknown"
      }

      wpd_notify(
        wpd_current_node(), "[", job_id, "]",
        date, "--",
        paste(lang, collapse = ", "), "--",
        paste(readLines(fname), collapse = "\n")
      )


      if(!interactive()){q(save = "no")}

    }
)





#### START : DUTY TO DO FUNCTION WITH IMMEDIATE EXECUTION
# it is used to be able to 'break' execution without raising an error
#
#
(
  function()
  {


    # ---- get date and lang ---------------------------------------------------
    date <- str_extract(file, "\\d{4}-\\d{2}-\\d{2}")

    if(!exists("lang")){
      tmp <- str_extract(str_extract(file, "_[a-z]{2}\\."), "[a-z]{2}")
      if ( !is.na(tmp)  ) {
        lang <- tmp
      }else{
        lang <- wpd_languages
      }
    }


    # ---- checks for information completeness ---------------------------------

    # check global variables
    stopifnot(
      exists("date"),
      exists("lang"),
      exists("file"),
      class(file) != "function"
    )



    # ---- get info on jobs and task status ------------------------------------

    execute <-
      wpd_check_job_execution_necessary(date = date, lang = lang)

    if( execute == TRUE ){

      # do nothing, carry on

    } else {

      # stop function by returning
      return(NULL)
    }


    # ---- clean upü any old data ----------------------------------------------

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



    # ---- register a job ------------------------------------------------------

    execute <-
      wpd_check_job_execution_necessary(date = date, lang = lang)

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
            if ( all( wpd_languages %in% lang ) ){
              "all"
            } else if ( length(lang) == 1 ){
              "single"
            } else{
              lang
            },
            sep = ", "
          )
      )
    job_id <- new_job_res$job_id


    # open file connection
    bz_con <-
      bzfile(
        description = file,
        open        = "rb"
      )


    # set initial loop values
    counter    <- 0
    n_lines    <- 100000
    lines      <- ""
    progress   <- 0

    # read first chunk of lines
    while ( length(lines) > 0 ){

      counter   <- counter + 1
      lines     <- readLines(con = bz_con, n = n_lines)
      progress  <- counter * n_lines


      lines_list <- wpd_dump_lines_to_df_list(lines)

      res <-
        lapply(
          X   = lines_list,
          FUN =
            function(df){
              wpd_upload_pageview_counts(
                page_name       = utf8_encode(df$page_name),
                page_view_count = df$page_view_count,
                page_view_date  = date,
                page_language   = df$lang[1]
              )
            }
        )

      wpd_job_log(
        date       = date,
        lang       = lang,
        file       = file,
        start_time = start_time,
        progress   = progress,
        job_id     = job_id
      )

    }




    #---- end --------------------------------------------------------------------

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
)()
#### END : DUTY TO DO FUNCTION



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

