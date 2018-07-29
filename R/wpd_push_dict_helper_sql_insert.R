#' wpd_push_dict_helper_sql_insert
#'
#' @param page character vector of page names
#'
#' @export
#'
wpd_push_dict_helper_sql_insert <-
  function(pages, lang, con = NULL){

    # handle connection
    if ( is.null(con) ){
      con <- wpd_connect()
      on.exit(DBI::dbDisconnect(con))
    }

    # escape strings for sql-usage
    pages_escaped <- DBI::dbQuoteString(con, pages)

    sql <-
        paste0(
          "INSERT INTO dict_", lang, " (page_name) VALUES \n",
          paste0("(", paste0(pages_escaped, collapse="),("), ") "),
          "\nON CONFLICT DO NOTHING;"
        )

    # return
    sql
  }
