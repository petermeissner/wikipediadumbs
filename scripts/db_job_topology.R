

# packages

library(wpd)
library(dplyr)



# get distribution of jobs

topology <- wpd_db_topology()


# filter
topology %>%
  filter(
    substring(task_date, 1, 4) == "2015"
  )
