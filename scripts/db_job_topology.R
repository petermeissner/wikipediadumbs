

# packages

library(wpd)
library(dplyr)



# get distribution of jobs

topology <- wpd_db_topology()


# filter
topology %>%
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


