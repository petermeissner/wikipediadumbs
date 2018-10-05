

#' wpd_db_creat_indecies
#'
#' @export
#'
wpd_db_creat_indecies <- function(){

  # modify future plan
  oplan <- future::plan()

  # ensure future plan is reversed at exit of function
  on.exit(future::plan(oplan), add = TRUE)

  # plan future execution
  future::plan(future::multisession, workers = length(wpd_languages))

  # execute
  future.apply::future_lapply(
    X   = names(wpd_nodes),
    FUN =
      function(x){
        sql <-
          wpd_sql(
            "CREATE INDEX IF NOT EXISTS
              page_views_%s_page_view_date_idx
              ON page_views_%s (page_view_date)
            ;",
            wpd_languages,
            wpd_languages
          )
        con <- wpd_connect(x)
        wpd_get_queries(
          queries = sql,
          con     = con,
          flatten = TRUE
        )
      }
  )
}

