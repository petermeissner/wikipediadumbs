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


args <- wpd_get_args()
file <- args$file
cat(file)



# error handler
options(
  "error" =
  function(){
    if ( !exists("date") | class(date) == "function" ){
      date <- ""
    }

    if(!exists("lang")){
      lang <- ""
    }


    em <- geterrmessage()
    fname <- paste0("Rscript_", paste(date, paste(lang, collapse = "_"), sep = "_"), ".error")
    sink(file = fname)
    traceback(2)
    sink()

    cat( "\n\n", em, "\n\n")
    cat(readLines(fname), sep = "\n")

    if ( exists("job_id") ){
      wpd_job_update(
        job_id      = job_id,
        job_status  = "error",
        job_comment = readLines(fname)
      )
    }

    wpd_notify(
      date,
      lang,
      readLines(fname)
    )


    if(!interactive()){q(save = "no")}

  }
)




date <- str_extract(file, "\\d{4}-\\d{2}-\\d{2}")

if(!exists("lang")){
  tmp <- str_extract(str_extract(file, "_[a-z]{2}\\."), "[a-z]{2}")
  if ( !is.na(tmp)  ) {
    lang <- tmp
  }else{
    lang <- wpd_languages
  }
}




# check global variables
  stopifnot(
    exists("date"),
    exists("lang"),
    exists("file"),
    class(file) != "function"
  )



# check for job statuses
task_status <-
  wpd_get_query_master(
    wpd_sql(
      "SELECT a.*, c.* FROM upload_tasks as a
      left join upload_task_jobs as b on a.task_id = b.task_id
      left join upload_jobs as c on b.job_id = c.job_id
      where
      a.task_date = '%s' and
      a.task_lang in %s
      ",
      date,
      wpd_sql_values(lang)
    )
  )$return

task_status$job_status[is.na(task_status$job_status)] <- ""



if( any (task_status$task_status != "waiting") ) {
  stop("none of the tasks is waiting")
}

if( all (task_status$job_status == "done") ) {
  stop("all jobs are done already")
}

if( any (task_status$job_status == "start") ) {
  stop("at least on job has been started for the task")
}






# log start time
start_time <- Sys.time()




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




#### END #######################################################################

# update job status - DONE
wpd_job_update(
  job_id     = job_id,
  job_end_ts = as.character(Sys.time()),
  job_status = "done"
)

# update task status - DONE
wpd_task_update(
  task_id        = task_status$task_id,
  task_status    = "done",
  task_duration  = as.integer(difftime(Sys.time(), start_time, units = "secs")),
  task_volume    = progress
)


cat(
  "\n\n--- done after:",
  as.character(hms::hms(round(difftime(Sys.time(), start_time, units = "secs")))),
  "---\n"
)

