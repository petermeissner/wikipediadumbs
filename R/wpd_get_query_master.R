#' wpd_get_query_master
#'
#' @inheritParams wpd_get_query
#' @rdname wpd_get_query
#'
#' @export
#'
wpd_get_query_master <-
  function(query, verbose = TRUE, con = NULL, dt = TRUE, close = NULL){
    wpd_get_query(
      query   = query,
      verbose = verbose,
      con     = con,
      node    = wpd_nodes_master,
      dt      = dt,
      close   = NULL
    )
  }
