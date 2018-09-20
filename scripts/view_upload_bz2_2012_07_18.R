library(wpd)
library(dplyr)
library(urltools)
library(utf8)
library(DBI)
library(RPostgreSQL)
library(data.table)

page_title_files_bz2 <- "/data/wpd/2012//pagecounts-2012-07-18.bz2"


# preparing loop stats
start_time_global  <- Sys.time()
sum_counter <- 0


# report time script started
cat("--- START --- ", as.character(start_time_global), " --- \n")




i <- 1

  start_time <- Sys.time()

  # date
  date <-
    gsub(
      x           = page_title_files_bz2[i],
      pattern     = "(^.*?-)(\\d{4}-\\d{2}-\\d{2})(.bz2)",
      replacement = "\\2"
    )

  # clean up database before putting in data
  wpd_get_query(
    paste0(
      "delete from page_views_traffic",
      " where traffic_date = '", date,"'"
    )
  )

  wpd_get_queries(
    queries =
      paste0(
        "delete from page_views_", wpd_languages,
        " where page_view_date = '", date, "'"
      )
  )



  # open file connection
  bz_con <-
    bzfile(
      description = page_title_files_bz2[i],
      open        = "rb"
    )


  # set initial loop values
  counter    <- 0
  n_lines    <- 100000
  lines      <- ""
  lines_filter <- data.frame()


  # read first chunk of lines
  while ( length(lines) > 0 ){

    counter      <- counter + 1
    lines        <- readLines(con = bz_con, n = n_lines)
    sum_counter  <- counter * n_lines

    if( sum_counter < 58800000 ){
      next
    }


    lines_list <- wpd_dump_lines_to_df_list(lines)

    res <-
      lapply(
        X   = lines_list,
        FUN =
          function(df){
            wpd_upload_pageview_counts(
              page_name       = utf8_encode(df$page_name),
              page_view_count = df$page_view_count,
              page_view_date  = date,
              page_language   = df$lang[1]
            )
          }
      )



    # report on progress
    cat(
      "\n - ", page_title_files_bz2[i], "-",
        format(sum_counter, big.mark = ",", scientific = FALSE),
      " ~",
      "| ",
      round(
        (
          difftime(Sys.time(), start_time, units = "secs") /
            (sum_counter)) * 1000000, 1
        ), "sec/Mio",
      "| \u2211",
      round(
        difftime(Sys.time(), start_time, units = "mins"),
        1
      ), "min"
    )
  }

