# script to download all data for 2011
library(wpd)
library(fs)

dir.create("/data/wpd/failures", showWarnings = FALSE)

failures <-
  c(
    "2009-05-11", "2009-05-12", "2009-09-21", "2009-09-22",
    "2009-09-23", "2009-09-24", "2009-09-25", "2009-09-26", "2009-09-27", "2009-09-28",
    "2009-09-29", "2009-09-30", "2009-10-14", "2009-10-15", "2009-10-16", "2009-11-22",
    "2010-01-23", "2010-01-24", "2010-02-08", "2010-02-26", "2010-07-05", "2010-07-07",
    "2010-07-08", "2010-07-09", "2010-07-10", "2010-11-30", "2011-01-19", "2011-01-21"
  )
failures <- gsub("-", "", failures)


for (  i in  failures ){
  wpd_get_dumps(ts = i, directory = "/data/wpd/failures")
  flist <- dir_ls("/data/wpd/failures")
  system("rsync /data/wpd/failures/* pm6:/data/wpd/todo/ -v --progress --ignore-existing")
  file_move(flist, "/data/wpd/todo/")
}

