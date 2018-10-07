#' wpd_sql_glue
#'
#' @param query_string a query string
#' @param ... values to put into string, see \link{glue::glue_sql}
#'
#' @export
#'
wpd_sql_glue <- function(query_string, ..., .con = DBI::ANSI(), .envir = parent.frame(), .na = DBI::SQL("NULL")){
  DBI::SQL(glue::glue_sql(query_string, ...))
}
