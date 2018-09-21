#' wpd_sql_values
#'
#' @param values values to be put in sql list
#'
#' @export
#'
wpd_sql_values <- function(values){
  con <- wpd_connect()
  on.exit(DBI::dbDisconnect(con))
  paste0("(",paste0(DBI::dbQuoteLiteral(con, values), collapse = ", "), ")")
}
