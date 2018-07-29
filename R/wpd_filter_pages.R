
#' wpd_filter_pages
#'
#' @param x
#'
#' @export
#'
wpd_filter_pages <- function(x){

  # get second item
  x    <-
    vapply(
      X   = strsplit(x, " ", fixed = TRUE),
      FUN =
        function(x){
          if(length(x)<2){
            x <- NA_character_
          }else{
            x <- x[[2]]
          }
          x
        },
      FUN.VALUE = ""
    )

  # exclude too long titles
  x    <- x[nchar(x) < 300]

  # url decode
  x    <- urltools::url_decode(x)

  # encoding check
  check <- data.table::rbindlist(stringi::stri_enc_detect2(x, NA), idcol = "page_id")
  x[is.na(check$Encoding)] <- NA

  x <- stringr::str_trim(stringi::stri_enc_toutf8(x, validate = NA))

  # get rid of non-pages
  x[grepl("(^[<#\"{`])|(.*\\.jpg$)|(.*\\.php$)|(.*\\.png$)|(\xef\xbf\xbd)|(/wikipedia/)|(http://)|(https://)(</)|(<br)", x)] <- NA


  # return
  x[!is.na(x)]
}
