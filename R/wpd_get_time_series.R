#' wpd_get_time_series
#'
#' @param page article name
#' @param lang article language
#'
#' @export
#'
wpd_get_time_series <- function(page = NULL, lang = NULL){

  # generate query
  sql <-
    wpd_sql(
      "
      select
        a.page_name,
        a.page_id,
        sum(b.page_view_count),
        b.page_view_date
      from dict_%s as a
      left join
	      page_views_%s as b
        on a.page_id=b.page_id
	    where page_name = '%s'
	    group by (a.page_name, a.page_id, b.page_view_date)
	    order by a.page_name, page_view_date
    ;
    ",
      lang,
      lang,
      page
    )

  # execute query
  res <- list()

  for( node in names(wpd_nodes) ){
    cat(".")
    con <- wpd_connect(node = node)
    res <-
      c(
        res,
        wpd_get_queries(
          sql,
          con     = con,
          flatten = FALSE,
          verbose = FALSE
        )
      )
    DBI::dbDisconnect(conn = con)
  }
  cat("\n")


  # rbind and return
  res_flat <- data.table::rbindlist(res, fill = TRUE)
  res_flat[!is.na(res_flat$page_view_date),]
}















