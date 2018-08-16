# script to read in and upload page title files -- dictionaries


#### packages ##################################################################

library(stringr)
library(wpd)
library(DBI)

#### doing-duty-to-do ##########################################################

# get list of gz-files
page_title_files_gz <-
  list.files("/data/wpd/pagetitles/", pattern = "\\gz$", full.names = TRUE) %>%
  gsub("//", "/", x = .)

page_title_language <-
  page_title_files_gz %>%
  basename() %>%
  substring(1,2)

page_title_date <-
  page_title_files_gz %>%
  basename() %>%
  str_extract("\\d{8}") %>%
  as.Date(format = "%Y%m%d") %>%
  as.character()

start_time  <- Sys.time()
sum_counter <- 0


for( i in seq_along(page_title_files_gz) ){
  # open file connection
  gz_con <-
    gzcon(
      file(
        description = page_title_files_gz[i],
        open        = "rb"
        )
      )

  # set initial loop values
  counter    <- 0
  n_lines    <- 250000

  # read first chunk of lines
  dict    <- readLines(con = gz_con, n = n_lines)[-1]

  # establish database connection
  con     <- wpd_connect()

  while ( length(dict) > 0 ){
    # generate query
    sql  <-
      sqlAppendTable(
        con   = con,
        table = paste0("dict_", page_title_language[i]),
        data.frame(
          page_name = dict
        ),
        row.names = FALSE
      )

    sql <-
      SQL(
        paste0(
          "WITH dict_inserts as (\n  ",
          sql,
          "\n ON CONFLICT (page_name) DO UPDATE set page_name = EXCLUDED.page_name RETURNING *",
          "\n)\n",
          "INSERT INTO dict_source_", page_title_language[i],
          "\n  SELECT page_id, '", page_title_date[i],"' as page_name_date FROM dict_inserts",
          "\n  ON CONFLICT DO NOTHING"
        )
      )

    # execute query
    res <- wpd_get_query(query = sql, con = con)

    # report on progress
    cat(
      "\r - ", page_title_language[i], "-",
      {
        counter <- counter + 1;
        sum_counter <- sum_counter + n_lines
        format(counter * n_lines, big.mark = ",", scientific = FALSE)
      },
      "\t ~",
      difftime(res$end, res$end, units = "secs"), "sec",
      "| ", round((difftime(Sys.time(), start_time, units = "secs") / (sum_counter)) * 1000000, 1), "sec/Mio",
      "| \u2211",
      round(difftime(Sys.time(), start_time, units = "mins"), 1), "min                   "
    )

    # read next chunk of lines
    dict <- readLines(gz_con, n_lines)
  }

  # close connections
  close(gz_con)
  dbDisconnect(con)
}



