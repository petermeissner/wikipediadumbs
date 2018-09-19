#' wpd_get_query
#'
#' Establish a connection, execute SQL statement against database, close connection and return.
#'
#' @param query SQL statement to execute
#' @param verbose return extra information -- timings, potential database errors -- or not
#'
#' @export
#'
#' @examples
#'
#'
wpd_get_query <-
  function(query, verbose = TRUE, con = NULL, node = 1){
    # establish connection
    if( is.null(con) ){
      con <- wpd_connect(node = node)
      on.exit(DBI::dbDisconnect(con))
    } else {
      # do nothing
    }

    # execute query and get potential exception/error
    res        <- list()
    res$start  <- as.character(Sys.time())
    res$return <- suppressWarnings(DBI::dbGetQuery(con, query))
    res$end    <- as.character(Sys.time())
    res$status <- DBI::dbGetException(con)
    res$node   <- DBI::dbGetInfo(con)$host

    # return
    if ( verbose == TRUE ){
      return(res)
    }else{
      return(res$return)
    }
  }
