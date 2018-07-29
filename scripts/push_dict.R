library(wpd)


wpd_filter_extract(fname = "/data/wpd/pagecounts-2015-01-03.bz2", lang = "de")

res     <- list()
counter <- 0
fcon    <- file("/data/wpd/pagecounts-2015-01-03_de", "rt")
start   <- Sys.time()

while ( TRUE ) {
  lines = readLines(fcon, n = 100000)
  if ( length(lines) == 0 ) {
    break
  }

  counter <- counter + 1
  cat("\r", as.character(start), "\t", as.character(Sys.time()), "\t", counter , "\t", length(lines))

  res <-
    c(
      res,
      wpd_batch_execute(
        SQL_GEN_FUNCTION = wpd_push_dict_helper_sql_insert,
        pages            = wpd_filter_pages(lines),
        lang             = "de"
      )
    )
}


close(fcon)
