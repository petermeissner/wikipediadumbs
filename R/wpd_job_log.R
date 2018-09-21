#' Title
#' @inheritParams wpd_job_new
#' @param start_time start time
#' @param progress some measure of progress
#'
#' @export
#'
wpd_job_log <-
  function(date, lang, file, start_time, progress, job_id){
    pace <-
      round(
        (
          difftime(Sys.time(), start_time, units = "secs") /
            (progress)
        ) * 1000000,
        1
      )
    if( is.infinite(pace) ){
      pace <- "+infinity"
    }

    # report on progress to screen
    cat(
      "\n",
      date, "-", lang, "-", basename(file), "-",
      format(progress, big.mark = ",", scientific = FALSE),
      " ~",
      "| ",
      pace, "sec/Mio",
      "| \u2211",
      round(
        difftime(Sys.time(), start_time, units = "mins"),
        1
      ), "min"
    )


    # report on progress to db
    wpd_job_update(
      job_id               = job_id,
      job_progress         = progress,
      job_pace_sec_per_mio = pace
    )
  }


