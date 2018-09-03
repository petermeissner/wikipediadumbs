#' wpd_size
#'
#' @return list with twot items: machine size of db, human readable size of db
#' @export
#'
wpd_size <-
  function(){
    as.list(wpd_get_query("select * from db_size()")$return)
  }
