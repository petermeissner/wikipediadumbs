# script to download all data for 2011
library(wpd)
dir.create("/data/wpd/2009", showWarnings = FALSE)
wpd_get_dumps(ts = "2009", directory = "/data/wpd/2009")


