# script to read in and upload page title files -- dictionaries


#### packages ##################################################################

library(stringr)
library(wpd)
library(DBI)

#### doing-duty-to-do ##########################################################

# get list of gz-files
page_title_files_lst <-
  list.files("/data/wpd/pagetitles/", pattern = "\\.lst$", full.names = TRUE) %>%
  gsub("//", "/", x = .)

page_title_language <-
  page_title_files_lst %>%
  basename() %>%
  gsub(x = ., pattern = "_.*$", "")

page_title_date <-
  page_title_files_lst %>%
  basename() %>%
  str_extract("\\d{4}_\\d{2}_\\d{2}") %>%
  as.Date(format = "%Y_%m_%d") %>%
  as.character()

start_time  <- Sys.time()
sum_counter <- 0


for( i in seq_along(page_title_files_lst) ){
  # open file connection
  file_con <-
      file(
        description = page_title_files_lst[i],
        open        = "rb"
      )

  # set initial loop values
  counter    <- 0
  n_lines    <- 250000

  # read first chunk of lines
  dict    <- readLines(con = file_con, n = n_lines)[-1]



  # clean up dictionary
  dict_clean_1 <-
    dict[!str_detect(dict, "~")] %>%
    str_replace("^.*/", "") %>%
    str_replace("\\.html$", "")

  dict_clean_2 <-
    dict_clean_1 %>%
    str_replace("(^.*)_[abcdef01234567890]{4}$", "\\1")


  # establish database connection
  db_con     <- wpd_connect()

  while ( length(dict) > 0 ){
    # generate query
    sql  <-
      sqlAppendTable(
        con   = db_con,
        table = paste0("dict_", page_title_language[i]),
        data.frame(
          page_name = unique(str_to_lower(c(dict_clean_1, dict_clean_2)))
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
    res <- wpd_get_query(query = sql, con = db_con)

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
    dict <- readLines(file_con, n_lines)
  }

  # close connections
  close(file_con)
  dbDisconnect(db_con)
}



