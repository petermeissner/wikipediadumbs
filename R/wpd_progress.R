#' wpd_progress
#'
#' @return list of proress indicators
#' @export
#'
wpd_progress <- function(){
  dates       <- seq.Date(as.Date("2007-12-01"), as.Date("2015-12-31"), by = "day")
  traffic     <- wpd_get_query("select * from page_views_traffic")$return
  dates_in_db <- unique(traffic$traffic_date)

  # stats
  res <-
    list(
      percentage = round(mean(dates %in% dates_in_db) * 100, 4),
      time_s     = as.integer(difftime(max(traffic$upload_ts), min(traffic$upload_ts), units = "secs")),
      time_hms   = as.character(hms::hms(difftime(max(traffic$upload_ts), min(traffic$upload_ts), units = "secs"))),
      ts_max     = max(traffic$upload_ts),
      ts_min     = min(traffic$upload_ts)
    )

  res$eta_s <- res$time_s / mean(dates %in% dates_in_db)
  res$eta   <- res$eta_s + Sys.time()

  # return
  res
}
