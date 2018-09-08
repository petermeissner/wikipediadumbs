# script to download all data for 2011
library(wpd)
library(future.apply)

plan(multicore, workers = 3)

future_lapply(
  X   = 1:12,
  FUN =
    function(x){
      wpd_download_month(year = 2011, month = x)
    }
)




