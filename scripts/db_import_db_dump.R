library(wpd)
library(fs)

dict             <- dir_ls("/data/wpd/", regexp = "dict_\\w{2}\\_copy.gz$")
dict_source      <- dir_ls("/data/wpd/", regexp = "dict_source_\\w{2}\\_copy.gz$")
page_views_daily <- dir_ls("/data/wpd/", regexp = "page_views_daily.*copy.gz$")
misc             <- dir_ls("/data/wpd/", regexp = "\\.gz$")
misc             <- misc[!(misc %in% dict) & !(misc %in% dict_source) & !(misc %in% page_views_daily) & !(misc %in% "/data/wpd/page_views_traffic_copy.gz")]

table_files <- c(dict, dict_source, page_views_daily, misc)

start <- Sys.time()

for ( i in seq_along(table_files) ) {
  dbt_hlp_progress(i, length(table_files), start = start, m = table_files[i])
  system(
    sprintf(
      'zcat %s |  grep -vw "idle_in_transaction_session_timeout" | psql wikipedia',
      table_files[i]
    )
  )

}
