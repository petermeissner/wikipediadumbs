#' wpd_connect
#'
#' Establish connection to WPD database
#'
#' @return A DBI/RPostgreSQL compliant connection object.
#' @export
#'
wpd_connect <-
  function(node = NULL){

    if(is.null(node)){
      node <- wpd_current_node()
    }

    RPostgreSQL::dbConnect(
      drv      = RPostgreSQL::PostgreSQL(),
      dbname   = "wikipedia",
      host     = wpd_nodes[node],
      port     = 5432,
      user     = Sys.getenv("wpd_user"),
      password = Sys.getenv("wpd_password")
    )
  }
