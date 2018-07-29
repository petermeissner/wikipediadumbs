

#' wpd_download_month
#'
#' @param year year for whic hto download data
#' @param month month for which to download data
#'
#' @return nothing, called for side effects
#' @export
#'
wpd_download_month <- function(year, month){
  # pre process month parameter
  month <- stringr::str_pad(string = month, pad= "0", side = "left", width = 2)

  # generate urls
  urls <-
    paste0(
      "https://dumps.wikimedia.org/other/pagecounts-ez/merged/", year,
      "/", year, "-", month,"/pagecounts-", year,"-", month,"-",
      stringr::str_pad(string = seq_len(31), pad= "0", side = "left", width = 2),
      ".bz2"
    )

  # download urls
  start <- as.character(Sys.time())
  cat("START: ", start, "\n")

  for( i in seq_len(length(urls)) ){
    cat("\n", start, " - ", as.character(Sys.time()), basename(urls[i]), "\n")
    try(download.file(urls[i], basename(urls[i])))
  }

  cat("START: ", start, " -- END: ", as.character(Sys.time()))
}







