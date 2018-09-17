library(wpd)


# get list of files
page_title_files_bz2 <-
  list.files("/data/wpd/2012", pattern = "\\d{4}-\\d{2}-\\d{2}\\.bz2$", full.names = TRUE)






start_time  <- Sys.time()
sum_counter <- 0


for( i in seq_along(page_title_files_bz2) ){
  # open file connection
  bz_con <-
    bzfile(
        description = page_title_files_bz2[i],
        open        = "rb"
      )

  # set initial loop values
  counter    <- 0
  n_lines    <- 25

  # read first chunk of lines
  data <-
    readLines(con = bz_con, n = n_lines)[-1] %>%
    grep(pattern = "^\\w{2,3}\\.z", value = TRUE, ignore.case = TRUE) %>%
    tolower() %>%
    read.table(
      text = .,
      header = FALSE,
      sep = " ",
      col.names = c("lang", "page_name", "page_view_count", "page_view_count_by_hour"),
      colClasses = c("character", "character", "integer", "character"),
      stringsAsFactors = FALSE,
      encoding = "UTF8",
      fileEncoding = "UTF8"
    )

  # establish database connection
  con     <- wpd_connect()

  while ( length(dict) > 0 ){
    # generate query
    sql  <-
      sqlAppendTable(
        con   = con,
        table = paste0("dict_", page_title_language[i]),
        data.frame(
          page_name = unique(str_to_lower(dict))
        ),
        row.names = FALSE
      )


wpd_upload_pageview_counts(
  page_name = ,
  page_view_count = ,
  page_view_date = ,
  page_language = ,
  conn =
)
