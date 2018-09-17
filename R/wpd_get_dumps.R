
#' function that downloads dump files for specific dates
#'
#'
#' @param ts timestamp e.g. "20071201" or shorter that will be used to match dump links
#' @param directory directory to store downloads in
#'
#' @export
#'
#'
wpd_get_dumps <- function(ts, directory = "." ){

  stopifnot(!is.null(directory))

  # decide which links have to be downloaded
  links <-
    readLines(
      gzcon(
        file(
          description = system.file("dumplinks.gz", package = "wpd"),
          open = "rb"
        )
      )
    )
  index <-
    stringr::str_extract(basename(links), "\\d{8}") %>%
    grep(paste0("^", ts), .)

  to_be_downloaded <- links[index]

  # download dumps
  RES <- character(length(to_be_downloaded))
  for( i in seq_along(to_be_downloaded) ){
      destfile <-
        gsub("//", "/", paste0(directory, "/", basename(to_be_downloaded[i])))

      cat("\r", i, " / ", length(to_be_downloaded), " start" )

      if( !file.exists(destfile) ){
        RES[[i]] <-
          {
            Sys.sleep(2)
            tryCatch(
              expr =
              {
                download.file(
                  url      = to_be_downloaded[i],
                  destfile = destfile
                )
                paste0("ok::", destfile)
              },
              error = function(e){
                paste0("error::", e$message)
              },
              warning = function(e){
                paste0("warning::", e$message)
              }
            )
          }
      }else{
        RES[[i]] <- "skip::file exists already"
        cat("file exists already - no download\n")
      }

      cat("\r", i, " / ", length(to_be_downloaded), " end   " )
  }

  return(data.frame(status= unlist(RES), link = to_be_downloaded))
}
