# script to download (oldest) page title files available

#### libraries #################################################################
library(wpd)
library(stringr)



#### doing-duty-to-do ##########################################################

# get list of available dates
page_titles_page    <- readLines("https://dumps.wikimedia.org/other/pagetitles/")
earliest_pagetitles <- min(str_extract(page_titles_page, "\\d{8}"), na.rm = TRUE)
latest_pagetitles   <- max(str_extract(page_titles_page, "\\d{8}"), na.rm = TRUE)


links <-
  paste0(
    "https://dumps.wikimedia.org/other/pagetitles/",
    earliest_pagetitles,
    "/",
    wpd_languages,
    "wiki-",
    earliest_pagetitles,
    "-all-titles-in-ns-0.gz"
  )

for ( i in seq_along(links) ){
  tryCatch(
    download.file( url = links[i], destfile = basename(links[i]) ),
    error = function(e){cat("\n\t - ", basename(links[i]), "\n")}
  )
}

