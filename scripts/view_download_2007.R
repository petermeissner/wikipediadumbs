# script to download all data for 2011
library(wpd)
dir.create("/data/wpd/2007", showWarnings = FALSE)
wpd_get_dumps(ts = "2007", directory = "/data/wpd/2007")


