# script to download all data for 2011
library(wpd)


dir.create("/data/wpd/2011", showWarnings = FALSE)

wpd_get_dumps(ts = "20110[1-6]", directory = "/data/wpd/2011")


