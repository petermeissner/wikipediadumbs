#' wpd_connect
#'
#' Establish connection to WPD database
#'
#' @return A DBI/RPostgreSQL compliant connection object.
#' @export
#'
wpd_connect <-
  function(){
    RPostgreSQL::dbConnect(
      drv      = RPostgreSQL::PostgreSQL(),
      dbname   = "wikipedia",
      host     = "petermeissner.de",
      port     = 5432,
      user     = Sys.getenv("wpd_user"),
      password = Sys.getenv("wpd_password")
    )
  }
