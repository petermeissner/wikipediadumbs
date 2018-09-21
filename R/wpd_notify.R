#' wpd_notify
#'
#' @param x the message to send
#'
#' @export
#'
wpd_notify <- function(...){
  bot_env$bot$sendMessage(paste(..., collapse = "\n"))
}



