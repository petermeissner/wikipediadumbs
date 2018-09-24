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


# get tasks that are done but status not set for all tasks
tasks_done <-
  tasks %>%
  group_by(task_date) %>%
  summarise(
    sum_done = sum(task_status == 'done')
  ) %>%
  filter(
    sum_done == 1
  ) %>%
  left_join(
    tasks, by="task_date"
  ) %>%
  group_by(task_date) %>%
  summarise(
    sum_progress = sum(task_volume, na.rm = TRUE)/20,
    sum_duration = sum(task_duration, na.rm = TRUE)/20,
    ts_update    = max(task_status_ts)
  ) %>%
  left_join(
    (task %>% select(task_date, task_id)), by = "task_date"
  )



update <-
  wpd_task_update(
    task_id        = tasks_done$task_id,
    task_status    = "done",
    task_duration  = tasks_done$sum_duration,
    task_volume    = tasks_done$sum_progress,
    task_status_ts = tasks_done$ts_update
  )










