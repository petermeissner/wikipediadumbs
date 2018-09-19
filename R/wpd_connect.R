#' wpd_connect
#'
#' Establish connection to WPD database
#'
#' @return A DBI/RPostgreSQL compliant connection object.
#' @export
#'
wpd_connect <-
  function(node = 1){
    RPostgreSQL::dbConnect(
      drv      = RPostgreSQL::PostgreSQL(),
      dbname   = "wikipedia",
      host     = c("petermeissner.de", "h2800722.stratoserver.net")[node],
      port     = 5432,
      user     = Sys.getenv("wpd_user"),
      password = Sys.getenv("wpd_password")
    )
  }
