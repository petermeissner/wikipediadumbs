#' wpd_check_job_execution_necessary
#'
#' @param date task_date
#' @param lang task_lang
#'
#' @export
#'
#'
#'
wpd_check_job_execution_necessary <-
  function(
    date,
    lang
  ){
    # get task status
    task_status <- wpd_get_tasks(date = date, lang = lang)

    # --- check if execution is necessary --------------------------------------

    if( !any (task_status$task_status %in% c("waiting", "error") ) ) {
      message("none of the tasks is waiting or in error")

      # do not execute any other code
      return(FALSE)
    }

    if( all (task_status$job_status == "done") ) {
      message("all jobs are done already")

      # do not execute any other code
      return(FALSE)
    }

    if( any (task_status$job_status == "start") ) {
      message("at least one job has been started for the task")

      # do not execute any other code
      return(FALSE)
    }


    return(TRUE)

  }
