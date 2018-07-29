#' wpd_unpack
#'
#' @param fname
#'
#' @export
#'
wpd_unpack <-
  function(fname){
    try(system(paste0("unp ", fname)))
  }
