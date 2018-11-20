library(RSQLite)
library(wpd)



langs <- wpd_languages
start <- Sys.time()
for(lang in langs){

  dbt_hlp_progress(i = which(langs == lang), ii = length(langs), start = start, m = lang)
  con <- dbConnect(SQLite(), sprintf("f:/wpd/%s.db", lang) )

  dbExecute(
    con,
    sprintf(
      "create index
    if not exists
    idx_page_views_daily_%s_page_id
    on
    page_views_daily_%s (page_id)",
      lang,
      lang
    )
  )

  dbExecute(
    con,
    sprintf(
      "create index
    if not exists
    idx_dict_%s_page_id
    on
    page_views_daily_%s (page_id)
    ",
      lang,
      lang
    )
  )

  dbDisconnect(con)
}

