library(wpd)

year     <- 2015
month    <- 1
day      <- 2:10
language <- c("en", "de") # wpd_languages


for(lng in language){
  for( yr  in year ){
    for( mth in month ){
      for ( d  in day ){
        wpd_filter_extract(
          fname =
            sprintf(
              "/data/wpd/pagecounts-%s-%s-%s.bz2",
              yr,
              stringr::str_pad(mth, width = 2, side = "left", pad = "0"),
              stringr::str_pad(  d, width = 2, side = "left", pad = "0")
            ),
          lang = lng
        )
      }
    }
  }
}



for(lng in language){
  for( yr  in year ){
    for( mth in month ){
      for ( d  in day ){

        cat(
          "\n",
          as.character(start), " --> ",
          as.character(Sys.time()), "\t",
          "\t", yr, "-",
          stringr::str_pad(mth, width = 2, side = "left", pad = "0"), "-",
          stringr::str_pad(  d, width = 2, side = "left", pad = "0"), "_",
          lng, "\n",
          sep =""
        )

        res     <- list()
        counter <- 0
        fcon    <-
          file(
            sprintf(
              "/data/wpd/pagecounts-%s-%s-%s_%s",
              yr,
              stringr::str_pad(mth, width = 2, side = "left", pad = "0"),
              stringr::str_pad(  d, width = 2, side = "left", pad = "0"),
              lng
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
                lang             = lng
              )
            )
        }

        close(fcon)
      }
    }
  }
}
