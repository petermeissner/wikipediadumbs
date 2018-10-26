library(wpd)

sql <- 
  wpd_sql(
    "
  CREATE INDEX if not exists page_views_%s_page_view_date_idx 
    ON 
    page_views_%s (page_view_date);",
    wpd_languages, wpd_languages
  )

for( i in seq_along(sql)){
  cat(as.character(Sys.time()), " - ", i)
  wpd_get_query(query = sql[i], node = "pm5")
}
