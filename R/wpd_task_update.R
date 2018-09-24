#' wpd_task_update
#'
#' @param task_id the job id to change
#' @param ... a number of key value pairs
#'
#'
#' @export
#'
wpd_task_update <- function(task_id, ...){

  if ( length(task_id) > 1){
    res <-
      mapply(
        FUN     = wpd_task_update,
        task_id = task_id,
        ...
      )
    return(res)
  }

  params <- list(...)

  if( ("task_status_ts" %in% names(params)) == FALSE ){
    params$task_status_ts <- as.character(Sys.time())
  } else {
    params$task_status_ts <- as.character(params$task_status_ts)
  }

  params <- lapply(params, function(x){ dbQuoteLiteral(conn = ANSI(), x) })
  params <- mapply(function(x, y){ paste0(x, "=", y) }, names(params), params)
  params <- paste(params, collapse = ", ")

  sql <-
    SQL("UPDATE upload_tasks SET ") +
    params +
    wpd_sql(" WHERE task_id = %s ", task_id)

  wpd_get_query_master(sql)
}



