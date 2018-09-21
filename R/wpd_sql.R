#' wpd_sql
#'
#' @param query_string a query string
#' @param ... values to put into string, see \link{sprintf}
#'
#' @export
#'
wpd_sql <- function(query_string, ...){

  # do recursion over parameter or not
  if ( length(query_string) > 1 | any(vapply(list(...), length, integer(1)) > 1) ){
    return(
      DBI::SQL(
        mapply(wpd_sql, query_string, ..., USE.NAMES = FALSE)
        )
    )
  }

  # paste together string, mark as SQL and return
  DBI::SQL(sprintf( query_string, ...))
}
