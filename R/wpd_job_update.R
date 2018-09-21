
#' wpd_job_update
#'
#' @param job_id the job id to change
#' @param ... a number of key value pairs
#'
#'
#' @export
#'
wpd_job_update <- function(job_id, ...){
  params <- list(...)
  params$job_ts_update <- as.character(Sys.time())
  params <- lapply(params, function(x){ dbQuoteLiteral(conn = ANSI(), x) })
  params <- mapply(function(x, y){ paste0(x, "=", y) }, names(params), params)
  params <- paste(params, collapse = ", ")

  sql <-
    SQL("UPDATE upload_jobs SET ") +
    params +
    wpd_sql(" WHERE job_id = %s ", job_id)

  wpd_get_query_master(sql)
}



