# script to download all data for 2011
library(wpd)


dir.create("/data/wpd/2011", showWarnings = FALSE)

wpd_get_dumps(ts = "201107|201108|201109|201110|201111", directory = "/data/wpd/2011")


