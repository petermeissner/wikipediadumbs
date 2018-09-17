library(wpd)
library(dplyr)
library(urltools)
library(utf8)
library(DBI)
library(RPostgreSQL)
library(data.table)


# get list of files
page_title_files_bz2 <-
  list.files(
    path    = "/data/wpd/2012",
    pattern = "\\d{4}-\\d{2}-\\d{2}\\.bz2$",
    full.names = TRUE
  ) %>%
  grep("2012-01-07", ., value = TRUE)




# opening conenction to data base
# establish database connection
con     <- wpd_connect()


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
    ),
    con = con
  )
  wpd_get_queries(
    queries =
      paste0(
        "delete from page_views_", wpd_languages,
        " where page_view_date = '", date, "'"
      ),
    con = con
  )


  # open file connection
  bz_con <-
    bzfile(
      description = page_title_files_bz2[i],
      open        = "rb"
    )


  # set initial loop values
  counter    <- 0
  n_lines    <- 250000
  lines      <- ""
  lines_filter <- data.frame()

  # read first chunk of lines
  while ( length(lines) > 0 ){
    counter      <- counter + 1
    lines        <- readLines(con = bz_con, n = n_lines)

    lines_filtered <-
      grep(
        x           = lines,
        pattern     = paste0("(^", wpd_languages, "\\.z)", collapse = "|"),
        value       = TRUE,
        ignore.case = TRUE
      )

    if( length(lines_filtered) > 0 ){
      lines_df <-
        lines_filtered %>%
        tolower() %>%
        paste(collapse = "\n" ) %>%
        fread(
          input = .,
          sep = " ",
          header = FALSE,
          stringsAsFactors = FALSE,
          encoding = "UTF-8",
          select = 1:3,
          data.table = TRUE,
          colClasses = c("character", "character", "integer", "character")
        ) %>%
        setNames(c("lang", "page_name", "page_view_count")) %>%
        mutate(
          lang      = substr(lang, 1, 2),
          page_name = utf8_encode(url_decode(page_name))
        )
    }else{
      lines_df <- data.frame()
    }


    if ( nrow(lines_df) > 0 ) {
      lines_list <-
        split(lines_df, lines_df$lang)

      res <-
        lapply(
          X   = lines_list,
          FUN =
            function(df){
              wpd_upload_pageview_counts(
                page_name       = df$page_name,
                page_view_count = df$page_view_count,
                page_view_date  = date,
                page_language   = df$lang[1],
                conn            = con
              )
            }
        )
    }

    # report on progress
    cat(
      "\n - ", page_title_files_bz2[i], "-",
      {
        sum_counter <- counter * n_lines
        format(sum_counter, big.mark = ",", scientific = FALSE)
      },
      "\t ~",
      "| ", round((difftime(Sys.time(), start_time, units = "secs") / (sum_counter)) * 1000000, 1), "sec/Mio",
      "| \u2211",
      round(difftime(Sys.time(), start_time, units = "mins"), 1), "min                   "
    )
  }
}




### end
cat(
  "--- START --- ", as.character(Sys.time()),
  " - ",
  round(difftime(Sys.time(), start_time_global, units = "hours"), 1), "h  ", "--- \n"
)
