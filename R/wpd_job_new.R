
#' wpd_job_new
#'
#' @param lang language covered by job
#' @param date date covered by job
#' @param file input file
#'
#' @export
#'
wpd_job_new <-
  function(
    lang,
    date,
    file,
    job_type
  ) {

    stopifnot(
      !is.null(lang),
      !is.null(date),
      !is.null(file),
      !is.null(job_type),
      file.exists(file) || length(list.files(path = dirname(file), pattern = basename(file))) > 0
    )

    # filter tasks
    sql <-
      paste0(
        "select * from upload_tasks where task_lang in
    ('", paste(lang, collapse = "','"), "') and
    task_date = '", date,"'
    ")

    tasks <- wpd_get_query_master(sql)$return


    # register job
    sql <-
      wpd_sql_insert(
        upload_jobs =
          data.frame(
            job_start_ts     = as.character(Sys.time()),
            job_status       = "start",
            job_progress     = 0,
            job_type         = job_type,
            job_run_node     = wpd_current_node(),
            job_target_node  = wpd_current_node(),
            job_file         = file,
            job_ts_update    = as.character(Sys.time())
          )
      )

    sql <- paste(sql, " returning job_id")

    job_id <- wpd_get_query_master(sql)$return$job_id


    # connect jobs and tasks
    wpd_get_query_master(
      wpd_sql_insert(upload_task_jobs = data.frame(task_id = tasks$task_id, job_id = job_id))
    )

    # return
    list(
      tasks  = tasks,
      job_id = job_id
    )
  }
