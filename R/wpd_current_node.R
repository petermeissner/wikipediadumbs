#' wpd_current_node
#'
#' @export
#'
wpd_current_node <- function(){
  names(wpd_nodes)[wpd_nodes == system("hostname", intern = TRUE)]
}
