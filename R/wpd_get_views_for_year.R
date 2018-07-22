#' wpd_get_views_for_year
#'
#' @export
#'
wpd_get_views_for_year <- function(){

  # handle connection
  con <- wpd_connect()
  on.exit(DBI::dbDisconnect(con))

  dbReadTable(con, "de_2015")
}
