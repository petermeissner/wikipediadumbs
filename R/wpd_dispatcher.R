
#' wpd_dispatcher
#'
#' function that can be called by cron job via Rscript -e "wpd::wpd_dispatcher()"
#' to dispatch scripts
#'
#' @export
#'
wpd_dispatcher <- function(file = NULL, retry = FALSE, n_jobs = 2){

  cat_log <- function(...){
    cat(as.character(Sys.time()),"--", ...)
  }

  # todos
  if( class(file) == "function" | is.null(file) ){
    todos <-
      list.files(
        path       = "/data/wpd/todo",
        full.names = TRUE,
        recursive  = TRUE,
        pattern    = "(.+?)((\\.gz)|(.bz2))$"
      )
  } else {
    files <-
      list.files(
        path       = dirname(file),
        pattern    = basename(file),
        full.names = TRUE
      )
    todos <- files
  }


  # processing .gz files
  todos <- unique(gsub("-\\d{6}\\.gz", "-.*.gz", todos))


  # jobs_open
  if ( retry == FALSE ){

    # jobs run already
    jobs_run <- basename(wpd_get_query_master("select * from upload_jobs")$return$job_file)

    # filter todo for jobsrun already
    jobs_open <- todos[!(basename(todos) %in% jobs_run)]

  } else {
    jobs_run <- basename(wpd_get_query_master("select * from upload_jobs")$return$job_file)

    iffer <-
      todos %in%
      wpd_get_query_master(
        "
        SELECT
          c.job_file
          FROM upload_tasks a
          LEFT JOIN upload_task_jobs b ON a.task_id = b.task_id
          LEFT JOIN upload_jobs c ON b.job_id = c.job_id
          where job_status != 'done' and job_status != 'start' and task_status != 'done'
        "
      )$return$job_file |
      !(basename(todos) %in% jobs_run)

    jobs_open <- todos[iffer]
  }


  # dispatch
  if ( length(jobs_open) == 0  ){

    if ( !file.exists("~/no_open_jobs") ) {

      wpd_notify(wpd_current_node(), as.character(Sys.time()), "- no open jobs in todo")
      writeLines(
        c(wpd_current_node(), as.character(Sys.time()), "- no open jobs in todo"),
        "~/no_open_jobs"
      )

    }

    cat_log("Nothing dispatched, no jobs to be done")

  }else{

    ps           <- system("ps aux | grep peter", intern = TRUE)
    ps_rscript_n <- length(grep("/usr/lib/R/bin/exec/R", ps, value = TRUE))

    if ( ps_rscript_n <= n_jobs & length(jobs_open) > 0 ){
      while ( ps_rscript_n <= n_jobs  & length(jobs_open) > 0 ){

        # increment counter by one
        ps_rscript_n <- ps_rscript_n + 1

        # decide on which script to use
        proto_bz2 <- system.file("view_upload_bz2.R", package = "wpd")
        proto_gz  <- system.file("view_upload_gz.R",  package = "wpd")

        if ( grepl("bz2$", jobs_open[1]) ){
          proto <- proto_bz2
        } else if ( grepl("gz$", jobs_open[1]) ){
          proto <- proto_gz
        } else {
          stop( "Do not know how to handle this job type.")
        }

        system_command <-
          sprintf(
            'nohup Rscript %s file=%s > %s 2>&1 &',
            proto,
            jobs_open[1],
            paste0("/home/peter/", basename(jobs_open[1]), ".error")
          )

        system(system_command)
        cat_log("Dispatched: ", jobs_open[1], "\n")
        jobs_open <- jobs_open[-1]
      }
    }else{
      cat_log("Nothing dispatched, no spots open")
    }
  }
}



















