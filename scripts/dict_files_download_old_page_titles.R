# script to download (oldest) page title files available

#### libraries #################################################################
library(wpd)
library(stringr)
library(rvest)



#### doing-duty-to-do ##########################################################

# get list of available dates

links    <-
  paste0(
    "https://dumps.wikimedia.org/other/static_html_dumps/current/",
    wpd_languages,
    "/html.lst"
  )


for ( i in seq_along(links) ){
  tryCatch(
    download.file( url = links[i], destfile = paste0(wpd_languages[i], "_2008_07_01.lst") ),
    error = function(e){cat("\n\t - ", basename(links[i]), "\n")}
  )
}

