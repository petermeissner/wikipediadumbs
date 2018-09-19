#' wpd_get_args
#'
#' @export
#'
wpd_get_args <- function(){

  # get commandline arguments
  args       <- commandArgs(trailingOnly=TRUE)

  # process
  args_split <- strsplit(args, "=")
  args_list  <- lapply(args_split, `[[`, 2)
  names(args_list) <- unlist(lapply(args_split, `[[`, 1))

  # return
  args_list
}
