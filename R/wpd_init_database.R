wpd_init_database <- function(){
  # handle connection to database
  con <- wpd_connect()
  on.exit(DBI::dbDisconnect(con))

  lang  <- c("de", "en")
  years <- 2008:2015

  table_names <-
    unlist(
      lapply(
        X        = as.data.frame(t(expand.grid(lang, years))),
        FUN      = paste0,
        collapse = "_"
      ),
      use.names = FALSE
    )

  sql <-
    paste0(
      "CREATE TABLE IF NOT EXISTS ", table_names, " (",
      "page_name text, ",
      "date date,",
      "views integer, ",
      "PRIMARY KEY(page_name, date)",
      ")"
    )

  # get rid of tables
  # sql <- paste("drop table", table_names)

  for ( i in seq_along(sql) ){
    DBI::dbExecute(con, sql[i])
  }
}
