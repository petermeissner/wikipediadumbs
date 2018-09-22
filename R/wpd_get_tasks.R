#' wpd_get_tasks
#'
#' @param date task_date
#' @param lang task_lang
#'
#' @export
#'
wpd_get_tasks <-
  function(
    date,
    lang
  ){
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

    # return
    task_status
  }
