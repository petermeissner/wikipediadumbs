library(wpd)
library(dplyr)
library(urltools)
library(utf8)
library(DBI)
library(RPostgreSQL)
library(data.table)


# get list of files
page_title_files_bz2 <-
  c(
    list.files(
      path    = "/data/wpd/2015/",
      pattern = "\\d{4}-\\d{2}-\\d{2}\\.bz2$",
      full.names = TRUE
    ) %>%
      grep("2015-0[789]", ., value = TRUE),
    list.files(
      path    = "/data/wpd/2015/",
      pattern = "\\d{4}-\\d{2}-\\d{2}\\.bz2$",
      full.names = TRUE
    ) %>%
      grep("2015-1[012]", ., value = TRUE)
  )


dates <-
  gsub(
    x           = page_title_files_bz2,
    pattern     = "(^.*?-)(\\d{4}-\\d{2}-\\d{2})(.bz2)",
    replacement = "\\2"
  )

data_done <-
  wpd_get_query("select date from data_upload where status = 'done'")$return %>%
  unlist()



data_tried <-
  wpd_get_query("select date from data_upload where status = 'started'")$return %>%
  unlist()


iffer_not_done  <- !(dates %in% data_done)
iffer_not_tried <- !(dates %in% data_tried)

if ( all(iffer_not_tried == FALSE) ){
  iffer <- iffer_not_done
} else {
  iffer <- iffer_not_tried
}


page_title_files_bz2 <- page_title_files_bz2[iffer]




# preparing loop stats
start_time_global  <- Sys.time()
sum_counter <- 0


# report time script started
cat("--- START --- ", as.character(start_time_global), " --- \n")

for( i in seq_along(page_title_files_bz2) ){

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


  # log the start of the script
  wpd_get_query(
    paste0(
      "insert into data_upload (date, status) values ('", date, "', 'started')"
    )
  )

  # read first chunk of lines
  while ( length(lines) > 0 ){
    counter      <- counter + 1
    lines        <- readLines(con = bz_con, n = n_lines)

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
      {
        sum_counter <- counter * n_lines
        format(sum_counter, big.mark = ",", scientific = FALSE)
      },
      " ~",
      "| ", round((difftime(Sys.time(), start_time, units = "secs") / (sum_counter)) * 1000000, 1), "sec/Mio",
      "| \u2211",
      round(difftime(Sys.time(), start_time, units = "mins"), 1), "min                   "
    )
  }

  wpd_get_query(
    paste0(
      "insert into data_upload (date, status) values ('", date, "', 'done')"
    )
  )

  close(bz_con)
}




### end
cat(
  "--- END --- ", as.character(Sys.time()),
  " - ",
  round(difftime(Sys.time(), start_time_global, units = "hours"), 1), "h  ", "--- \n"
)

