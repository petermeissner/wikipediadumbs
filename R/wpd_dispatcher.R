
#' wpd_dispatcher
#'
#' function that can be called by cron job via Rscript -e "wpd::wpd_dispatcher()"
#' to dispatch scripts
#'
#' @export
#'
wpd_dispatcher <- function(file = NULL, retry = FALSE, n_jobs = 2){

  # todos
  if( is.null(file) ){
    todos <-
      list.files("/data/wpd/todo", full.names = TRUE, recursive = TRUE)
  } else {
    todos <- file
  }

  # jobs run already
  jobs_run <- basename(wpd_get_query_master("select * from upload_jobs")$return$job_file)

  # jobs_open
  if ( retry == FALSE ){
    jobs_open <- todos[!(basename(todos) %in% jobs_run)]
  } else {
    jobs_open <- todos
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

    cat("Nothing dispatched, no jobs to be done")

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
        cat("Dispatched: ", jobs_open[1])
        jobs_open <- jobs_open[-1]
      }
    }else{
      cat("Nothing dispatched, no spots open")
    }
  }
}



















