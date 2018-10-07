#' wpd_db_topology
#'
#' @export
#'
wpd_db_topology <-
  function(){
    wpd_get_query_master("select * from upload_status")$return
  }
