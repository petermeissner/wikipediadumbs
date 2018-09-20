#' wpd_size
#'
#' @return list with twot items: machine size of db, human readable size of db
#' @export
#'
wpd_size <-
  function(node = wpd_nodes_master){
    tmp      <- wpd_get_query("select * from db_size()", node = node)
    res      <- as.list(tmp$return)
    res$host <- tmp$host
    res$node <- tmp$node

    # return
    res
  }
