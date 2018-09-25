library(dplyr)
library(ggplot2)
library(wpd)



jobs <- wpd_get_query_master("select * from upload_jobs")$return


ggplot(
  jobs,
  aes(
    x = job_ts_update,
    y = job_pace_sec_per_mio,
    group = job_run_node,
    color = job_run_node
    )
  ) +
  geom_point(size = 0.1)+
  geom_smooth(se = FALSE)+
  theme_bw()+
  ylim(c(0,1000))



