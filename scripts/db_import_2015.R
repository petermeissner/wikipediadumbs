

# packages

library(wpd)
library(dplyr)

import_date <- "2015"

# get distribution of jobs

topology <- wpd_db_topology()


# filter
topo <-
  topology %>%
  #as_data_frame() %>%
  filter(
    substring(task_date, 1, 4) == import_date
  ) %>%
  group_by(
    task_date,
    task_lang
  ) %>%
  summarise(
    ok   = sum(job_status == "done", na.rm = TRUE) > 0,
    node = job_run_node[job_status == "done"][1]
  ) %>%
  group_by(
    task_date
  ) %>%
  summarise(
    ok   = sum(ok, na.rm = TRUE) == length(wpd_languages),
    node = paste0(unique(sort(node)), collapse = ", ")
  )





sql <-
  wpd_sql(
    "CREATE TABLE if not exists page_views_%s_%s_import (
    page_id int4 NULL,
    page_view_date date NULL,
    page_view_count int4 NULL
  )
  ;
  ",
    wpd_languages,
    import_date
  )
for(i in seq_along(sql)) wpd_get_query_master(sql[i])



start <- Sys.time()
for( i in seq_len(nrow(topo)) ){
  sql <-
    wpd_sql(
      "insert into page_views_%s_%s_import
    select page_id, page_view_date, sum(page_view_count) from
    dblink(
      'dbname=wikipedia port=5432 host=%s user=%s password=%s',
      'select * from page_views_%s where page_view_date = ''%s''::date')
      as dings(page_id int4, page_view_date date, page_view_count int4)
    group by page_id, page_view_date
    ;
    ",
      wpd_languages,
      import_date,
      wpd_nodes[topo$node[i]],
      Sys.getenv("wpd_user"),
      Sys.getenv("wpd_password"),
      wpd_languages,
      topo$task_date[i]
    )

  cat("\n", topo$node[i], "-", as.character(topo$task_date[i]), ": ")
  for ( k in seq_along(wpd_languages) ) {
    cat(" ", wpd_languages[k], sep="")
    wpd_get_query_master(sql[k])
  }
  cat(
    "\n", i, "/",
    nrow(topo), "in",
    as.character(hms::as.hms(round(difftime(Sys.time(), start, units = "secs"))))
  )

}















