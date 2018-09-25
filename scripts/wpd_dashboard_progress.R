library(wpd)
library(ggplot2)
library(data.table)
library(dplyr)


# get data
tasks <-
  wpd_get_query_master("select * from upload_tasks")$return


# plot progress
tasks %>%
  group_by(task_date) %>%
  summarise(
    task_status = sum(task_status == "done")
  ) %>%
  ggplot(aes(x = task_date, y = task_status)) +
  geom_col() +
  theme_bw() +
  geom_hline(data = data.frame(y=0), aes(yintercept=y))










