# script to download all data for 2011
library(wpd)
library(fs)

dir.create("/data/wpd/2007", showWarnings = FALSE)


wpd_get_dumps(ts = "20071215", directory = "/data/wpd/2007")
flist <- dir_ls("/data/wpd/2007")
file_move(flist, "/data/wpd/todo/")

wpd_get_dumps(ts = "20071217", directory = "/data/wpd/2007")
flist <- dir_ls("/data/wpd/2007")
file_move(flist, "/data/wpd/todo/")

wpd_get_dumps(ts = "20071218", directory = "/data/wpd/2007")
flist <- dir_ls("/data/wpd/2007")
file_move(flist, "/data/wpd/todo/")

wpd_get_dumps(ts = "20071227", directory = "/data/wpd/2007")
flist <- dir_ls("/data/wpd/2007")
file_move(flist, "/data/wpd/todo/")



