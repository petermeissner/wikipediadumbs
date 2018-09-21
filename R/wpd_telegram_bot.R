#' @docType data
#' @keywords internal
bot_env <- new.env()
bot_env$bot <- telegram::TGBot$new(token = "647549430:AAGcuHjHAixLYuHAXvglsVM6pvbCWcdfMK0")
bot_env$bot$set_default_chat_id(335002958)


