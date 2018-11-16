library(wpd)
library(DBI)
library(RSQLite)

getwd()


# open up connections
con_from <- wpd_connect_master()
con_to   <- dbConnect(SQLite(), "wpd.db")


# get list of tables
table_names <-
  grep(
    x       = sort(dbListTables(con_from)),
    pattern = "(^dict_)|(^page_views_daily)|(^upload)",
    value   = TRUE
  )

# ensure closing of connections
dbDisconnect(con_from)
dbDisconnect(con_to)


# loop over list of tables
RES <- list()
for ( i in seq_along(table_names) ){
  # open up connections
  con_from <- wpd_connect_master()
  con_to   <- dbConnect(SQLite(), "wpd.db")

  # copy table
  RES[[ length(RES) + 1 ]] <-
    db_copy_table_to_db(
      table_name = table_names[i],
      con_from   = con_from,
      con_to     = con_to,
      batch_size = 100000
    )

  # ensure closing of connections
  dbDisconnect(con_from)
  dbDisconnect(con_to)
}


