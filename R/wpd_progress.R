#' wpd_progress
#'
#' @return list of progress indicators
#' @export
#'
wpd_progress <- function(){
  tasks <- wpd_get_query_master("select * from upload_tasks", verbose = FALSE)

  not_done <- sum(tasks$task_status != "done")
  done     <- sum(tasks$task_status == "done")

  # stats
  res <-
    list(
      percentage = round(done / (not_done + done) * 100, 4),
      time_s     = as.integer(difftime(max(tasks$task_status_ts), min(tasks$task_status_ts), units = "secs")),
      time_hms   = as.character(hms::hms(as.integer(difftime(max(tasks$task_status_ts), min(tasks$task_status_ts), units = "secs")))),
      ts_max     = max(tasks$task_status_ts),
      ts_min     = min(tasks$task_status_ts)
    )

  res$eta_s <- res$time_s / (done / (not_done + done))
  res$eta   <- res$eta_s + Sys.time()

  # return
  res
}
