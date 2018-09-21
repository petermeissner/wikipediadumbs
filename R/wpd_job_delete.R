
#' wpd_job_delete
#'
#' @export
#'
wpd_job_delete <- function(job_id){
  sql <-
    wpd_sql("DELETE from upload_jobs where job_id = %s", job_id)

  wpd_get_query_master(sql)
}
