library(wpd)
library(ggplot2)
library(data.table)
library(dplyr)


# get data
tasks <-
  wpd_get_query_master("select * from upload_tasks")$return

jobs <-
  wpd_get_query_master("select * from upload_jobs as a
	left join upload_task_jobs as b on a.job_id = b.job_id
	left join upload_tasks as c on c.task_id = b.task_id
	where job_status = 'start'")$return %>%
  data.frame() %>%
  rbind(data.frame(job_id = integer(), job_run_node = character(), task_date = integer())) %>%
  group_by(
    job_run_node, task_date
  ) %>%
  summarise()

jobs$y <- scales::rescale(seq_len(nrow(jobs)), from = c(1, nrow(jobs)), to =c(0,20))




# plot progress
plot <-
  tasks %>%
  group_by(task_date) %>%
  summarise(
    task_status   = sum(task_status == "done"),
    hours = mean(task_duration/3600 , na.rm = TRUE)
  ) %>%
  ggplot(aes(x = task_date, y = task_status)) +
  geom_col(width = 2) +
  theme_bw() +
  geom_vline(
    data = jobs,
    aes(xintercept = task_date, color = job_run_node)
  )

if(nrow(jobs) > 0 ){
  plot <-
    plot +
    geom_text(data = jobs, aes(x = task_date, y = y, color = job_run_node, label = paste0(job_run_node, "/", task_date)))
}

plot



# print missing dates
missing <- tasks %>% filter(task_status!="done")
missing$task_date %>% unique() %>% sort() %>% as.character()






