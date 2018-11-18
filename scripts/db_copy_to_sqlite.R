library(wpd)
library(DBI)
library(RSQLite)

getwd()


# open up connections
con_from <- wpd_connect_master()
con_to   <- dbConnect(SQLite(), sprintf("/data/wpd/%s.db", lang))


db_copy_table_to_db(
  table_name = sprintf("dict_%s", lang),
  con_from   = con_from,
  con_to     = con_to,
  batch_size = 100000
)

# ensure closing of connections
dbDisconnect(con_from)
dbDisconnect(con_to)



# open up connections
con_from <- wpd_connect_master()
con_to   <- dbConnect(SQLite(), sprintf("/data/wpd/%s.db", lang))


db_copy_table_to_db(
  table_name = sprintf("page_views_daily_%s", lang),
  con_from   = con_from,
  con_to     = con_to,
  batch_size = 100000
)


# ensure closing of connections
dbDisconnect(con_from)
dbDisconnect(con_to)


message("\n[done] ", as.character(Sys.time()))


