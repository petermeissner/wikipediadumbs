
tasks <-
  expand.grid(
    task_lang   <- wpd_languages,
    task_date   <- as.character(seq.Date(as.Date("2007-12-01"), as.Date("2015-12-31"), by = "day")),
    task_status <- "waiting"
  )
tasks <- setNames(tasks, c("task_lang", "task_date", "task_status"))

sql <-
  sqlAppendTable(
    con    = wpd_connect_master(),
    table  = "upload_tasks",
    values = tasks,
    row.names = FALSE
  )

wpd_get_query_master(sql)


res <- list()

res[[length(res)+1]]<-
  lapply(
    wpd_get_queries(
      paste0(
        "select distinct '", wpd_languages, "' as page_lang, page_view_date from page_views_",
        wpd_languages
      ),
      flatten = FALSE
    ),
    `[[`,
    "return"
  )

wpd_languages
