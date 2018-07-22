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
      dbname   = "wikipediatrend",
      host     = "wikipediatrend.cxlf5dhif8nw.eu-central-1.rds.amazonaws.com",
      port     = 5432,
      user     = Sys.getenv("wpd_user"),
      password = Sys.getenv("wpd_password")
    )
  }
