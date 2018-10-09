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
  dplyr::group_by(
    job_id, job_run_node
  ) %>%
  dplyr::summarise(
    task_date = min(task_date)
  ) %>%
  arrange(job_run_node)

jobs$y <- scales::rescale(seq_len(nrow(jobs)), from = c(1, nrow(jobs)), to =c(0,20))




# plot progress
plot <-
  tasks %>%
  group_by(task_date) %>%
  summarise(
    task_status   = sum(task_status == "done"),
    hours = mean(task_duration/3600 , na.rm = TRUE)
  ) %>%
  ggplot(aes(x = task_date, y = task_status, color = hours)) +
  geom_col(width=0.005) +
  theme_bw() +
  geom_hline(data = data.frame(y=0), aes(yintercept=y))+
  geom_vline(data = jobs, aes(xintercept = task_date, color = job_run_node))

if(nrow(jobs) > 0 ){
  plot <-
    plot +
    geom_text(data = jobs, aes(x = task_date, y = y, color = job_run_node, label = paste0(job_run_node, "/", task_date)))
}

plot



# print missing dates
missing <- tasks %>% filter(task_status!="done", task_date >= "2012-01-01")
missing$task_date %>% unique() %>% sort() %>% as.character()






