#' wpd_create_tables
#'
#' @param flatten flatten query results
#' @param verbose be talkative?
#'
#' @export
#'
wpd_create_tables <-
  function(flatten = TRUE, verbose = TRUE){

    # handle connection
    con <- wpd_connect()
    on.exit(DBI::dbDisconnect(con))


    # generate query
    sql <- character(0)

    sql <-
      append(
        sql,
        paste0(
          "CREATE TABLE IF NOT EXISTS dict_", wpd_languages," (
              page_id SERIAL PRIMARY KEY,
              page_name TEXT UNIQUE NOT NULL
            );"
        )
      )

    sql <-
      append(
        sql,
        paste0(
          "CREATE TABLE IF NOT EXISTS dict_source_", wpd_languages," (
                page_id INTEGER REFERENCES dict_", wpd_languages,"(page_id),
                page_name_date DATE,
                PRIMARY KEY(page_id, page_name_date)
              );"
        )
      )

    sql <-
      append(
        sql,
        paste0(
          "CREATE TABLE IF NOT EXISTS page_views_", wpd_languages," (
              page_id INTEGER REFERENCES dict_", wpd_languages,"(page_id),
              page_view_date DATE,
              page_view_count INTEGER
            );"
        )
      )

    sql <-
      append(
        sql,
        "CREATE TABLE IF NOT EXISTS page_views_dump (
          page_name TEXT,
          page_language TEXT,
          page_view_date DATE,
          page_view_count INTEGER
        );"
      )

    # execute query
    sql_res <-
      wpd_get_queries(
        queries = sql,
        con     = con,
        flatten = flatten,
        verbose = verbose
      )

    # return
    sql_res
  }




