library(wpd)
library(DBI)

conn <- wpd_connect_master()


tables <- dbListTables(conn)
tables <- tables[grep("^tmp", tables, invert = TRUE)]
tables <- sample(tables)



setwd("/data/wpd/")
start = Sys.time()

system("pg_dump --schema-only -d wikipedia > wikipedia_schema.sql")

for(i in seq_along(tables)){
  dbt_hlp_progress(i = i, ii = length(tables), start = start, m = tables[i])
  system(sprintf("pg_dump --data-only -d wikipedia -t %s | gzip > %s_copy.gz", tables[i], tables[i]))
  system(sprintf("pg_dump --data-only --column-inserts -d wikipedia -t %s | gzip > %s_inserts.gz", tables[i], tables[i]))
}


