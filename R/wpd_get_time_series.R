#' wpd_get_time_series
#'
#' @param page article name
#' @param lang article language
#'
#' @export
#'
wpd_get_time_series <- function(page = NULL, lang = NULL, regex = NULL){

  # check input
  if ( !is.null(regex) & !is.null(page) ){
    stop("You cannot use page name and regex argument at the same time.")
  }

  stopifnot(!is.null(lang))

  # generate query
  if ( !is.null(page) ){
    sql <-
      wpd_sql(
        "select a.page_id, a.page_name, b.year, b.page_views
  from (select * from dict_%s where page_name = '%s') as a
  left join imports_%s as b on a.page_id = b.page_id
  ;
",
        lang,
        page,
        lang
      )

  } else if ( !is.null(regex) ){
    sql <-
      wpd_sql(
        "select a.page_id, a.page_name, b.year, b.page_views
  from (select * from dict_%s where page_name ~* '%s') as a
  left join imports_%s as b on a.page_id = b.page_id
  ;",
        lang,
        regex,
        lang
      )
  } else {
    stop("Either page or regex have to be specified")
  }

  con <- wpd_connect_master()
  on.exit(DBI::dbDisconnect(con))

  res <-
    wpd_get_queries(
      queries = sql,
      con     = con,
      flatten = FALSE
    )

  res_dfs <-
    lapply(res, `[[`, "return")





  # rbind and return
  res_dfs_flat <- data.table::rbindlist(res_dfs, fill = TRUE)
  res_dfs_flat
}















