#' wpd_push_item
#'
#' @param date date for which to push
#' @param lang language
#' @param page page names
#' @param views page views
#' @param con connection object
#'
#' @export
#'
wpd_push_item <-
  function(
    date,
    lang,
    page,
    views,
    con = NULL
  ){
    # handle connection
    if ( is.null(con) ) {
      con <- wpd_connect()
      on.exit(DBI::dbDisconnect(con))
    }

    # parse dates
    date_parsed <- as.Date(date)
    year        <- substr(date, 1, 4)
    table_name  <- paste0(lang, "_", year)


    # generate sql statement
    sql <-
      paste0(
        "INSERT INTO ", table_name," (page_name, date, views)
    VALUES ", paste0("(", paste0("'", page, "'", ",","'", date, "',", views, collapse="),\n("), ") \n"),
        "ON CONFLICT (page_name, date) DO UPDATE SET views = EXCLUDED.views;")

    # generate sql statement
    sql <-
      paste0(
        "INSERT INTO ", table_name," (page_name, date, views)
    VALUES ", paste0("(", paste0("'", page, "'", ",","'", date, "',", views, collapse="),\n("), ") \n"),
    "ON CONFLICT (page_name, date) DO UPDATE SET views = EXCLUDED.views;")

    # execute statement
    DBI::dbGetQuery(con, statement = sql)
    DBI::dbGetException(conn = con)
  }
