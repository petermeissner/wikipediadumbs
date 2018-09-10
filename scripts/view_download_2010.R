# script to download all data for 2011
library(wpd)
dir.create("/data/wpd/2010", showWarnings = FALSE)
wpd_get_dumps(ts = "2010", directory = "/data/wpd/2010")


