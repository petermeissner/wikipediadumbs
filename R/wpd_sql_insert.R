#' wpd_sql_insert
#'
#' @param ... table name and value in the form of name = value
#'
#' @export
#'
wpd_sql_insert <- function(...){

  con <- wpd_connect()
  on.exit(DBI::dbDisconnect(con))

  df <- list(...)

  sqlAppendTable(
    con = con,
    table = names(df)[1],
    values = df[[1]],
    row.names = FALSE
  )
}
