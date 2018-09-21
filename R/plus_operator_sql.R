
#' +-Operator for SQL
#'
#' @param a first part of SQL statement
#' @param b second part of SQL statement
#'
#' @export
#'
"+.SQL" <- function(a,b) {SQL(paste0(a,b))}
