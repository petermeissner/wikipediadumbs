library(wpd)
library(dplyr)
library(DBI)

tr_pm1 <- wpd_get_query("select * from page_views_traffic", node = "pm")$return
tr_pm1$node = "pm"


tr_pm2 <- wpd_get_query("select * from page_views_traffic", node = "pm2")$return
tr_pm2$node = "pm2"


tr_pm3 <- wpd_get_query("select * from page_views_traffic", node = "pm3")$return
tr_pm3$node = "pm3"


tr_pm4 <- wpd_get_query("select * from page_views_traffic", node = "pm4")$return
tr_pm4$node = "pm4"


tr_pm5 <- wpd_get_query("select * from page_views_traffic", node = "pm5")$return
tr_pm5$node = "pm5"


tr_pm6 <- wpd_get_query("select * from page_views_traffic", node = "pm6")$return
tr_pm6$node = "pm6"


tr_pm7 <- wpd_get_query("select * from page_views_traffic", node = "pm7")$return
tr_pm7$node = "pm7"




traffic <-
  rbind(
    tr_pm1,
    tr_pm2,
    tr_pm3,
    tr_pm4,
    tr_pm5,
    tr_pm6,
    tr_pm7
  ) %>%
  as_tibble()

tmp <-
  traffic %>%
  select(
    page_language,
    traffic_date,
    node
  ) %>%
  group_by(
    page_language,
    traffic_date,
    node
  ) %>%
  distinct()


traffic_duplicates <-
  tmp[
    tmp %>%
    ungroup() %>%
    select(page_language,traffic_date) %>%
    duplicated()
  ,] %>%
    ungroup() %>%
    select(traffic_date, page_language)

traffic_ok <-
  traffic %>%
  anti_join(
    traffic_duplicates,
    by = c("traffic_date", "page_language")
  )



traffic_problems <-
  traffic_duplicates %>%
  left_join(
    traffic,
    by = c("traffic_date", "page_language")
  )


traffic_problems_solved <-
  traffic_problems %>%
  group_by(traffic_date,page_language,node) %>%
  summarise(
    n = n()
  ) %>%
  ungroup() %>%
  arrange(
    traffic_date,
    page_language,
    -n
  ) %>%
  group_by(traffic_date, page_language) %>%
  summarise(node = first(node)) %>%
  left_join(
    traffic,
    by = c("traffic_date", "page_language", "node")
  )




page_views_daily_global <-
  bind_rows(
    traffic_problems_solved,
    traffic_ok
  ) %>%
  select(
    -node, - upload_ts
  ) %>%
  group_by(
    traffic_date,
    page_language
  ) %>%
  summarise(
    page_views      = sum(page_views_count),
    server_requests = sum(traffic_count)
  )

page_views_daily_global$traffic_date <- as.character(page_views_daily_global$traffic_date)
sql <- wpd_sql_insert(page_views_daily_global = page_views_daily_global)

wpd_get_query_master(sql)











