library(wpd)

year     <- 2015
month    <- 1
day      <- 2:10
language <- c("en", "de") # wpd_languages


for(lang_i in language){
  for( year_i  in year ){
    for( month_i in month ){
      for ( day_i  in day ){
        wpd_filter_extract(
          fname =
            sprintf(
              "/data/wpd/pagecounts-%s-%s-%s.bz2",
              year_i,
              stringr::str_pad(month_i, width = 2, side = "left", pad = "0"),
              stringr::str_pad(  day_i, width = 2, side = "left", pad = "0")
            ),
          lang = lang_i
        )
      }
    }
  }
}



for(lang_i in language){
  for( year_i  in year ){
    for( month_i in month ){
      for ( day_i  in day ){

        cat(
          "\n",
          as.character(start), " --> ",
          as.character(Sys.time()), "\t",
          "\t", year_i, "-",
          stringr::str_pad(month_i, width = 2, side = "left", pad = "0"), "-",
          stringr::str_pad(  day_i, width = 2, side = "left", pad = "0"), "_",
          lang_i, "\n",
          sep =""
        )

        res     <- list()
        counter <- 0
        fcon    <-
          file(
            sprintf(
              "/data/wpd/pagecounts-%s-%s-%s_%s",
              year_i,
              stringr::str_pad(month_i, width = 2, side = "left", pad = "0"),
              stringr::str_pad(  day_i, width = 2, side = "left", pad = "0"),
              lang_i
            ), "rt")
        start   <- Sys.time()

        while ( TRUE ) {
          lines = readLines(fcon, n = 50000)
          if ( length(lines) == 0 ) {
            break
          }

          counter <- counter + 1

          cat(
            "\r",
            as.character(start), "\t",
            as.character(Sys.time()), "\t",
            counter , "\t",
            format( length(lines) * counter, big.mark = ",")
          )

          res <-
            c(
              res,
              wpd_batch_execute(
                SQL_GEN_FUNCTION = wpd_push_dict_helper_sql_insert,
                pages            = wpd_filter_pages(lines),
                lang             = lang_i
              )
            )
        }

        close(fcon)
      }
    }
  }
}
