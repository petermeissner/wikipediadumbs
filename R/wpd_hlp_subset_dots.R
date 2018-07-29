#' wpd_hlp_subset_dots
#'
#' @param ... parameter to subset
#' @param i index to subset by
#'
#' @return List of its inputs where inputs are each subset according to i
#' @export
#'
wpd_hlp_subset_dots <-
function(..., i=NULL){
  lapply(
    list(...),
    function(x, i){
      # subset
      if(length(x) > 1){
        x <- x[i]
      }
      # return
      x
    },
    i
  )
}
