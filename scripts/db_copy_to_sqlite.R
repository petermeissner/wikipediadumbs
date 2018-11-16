library(wpd)
library(DBI)
library(RSQLite)




copy_table <-
  function(table_name){

    # get current time
    start    <- Sys.time()

    # open up connections
    con_from <- wpd_connect_master()
    con_to   <- dbConnect(SQLite(), "f:/test.db")

    # ensure closing of connections
    on.exit({
      dbDisconnect(con_from)
      dbDisconnect(con_to)
    })

    # query size of table
    statement_size <-
      dbGetQuery(
        con_from,
        wpd_sql("select count(*) from %s", table_name)
      )$count

    # send query
    statement_exec <-
      dbSendQuery(
        con_from,
        wpd_sql("select * from %s", table_name)
      )


    # fetch first batch of results
    statement_res  <- dbFetch(statement_exec, n = 10000)
    size           <- nrow(statement_res)


    # ensure table exists at to table
    if( dbExistsTable(con_to, table_name) ){
      # do nothing
    } else {
      if ( size > 0 ){
        dbCreateTable(con_to, table_name, statement_res)
      }
    }

    # loop through
    while ( nrow(statement_res) > 0 ){

      # check encoding
      for ( i in seq_len(ncol(statement_res)) ){
        if ( class(statement_res[[i]]) %in% "character" ){
          Encoding(statement_res[[i]]) <- "UTF-8"
        }
      }

      size <- nrow(statement_res) + size
      dbt_hlp_progress(size, statement_size, start = start, m = table_name)
      dbAppendTable(con_to, table_name, value = statement_res)

      statement_res <- dbFetch(statement_exec, n = 10000)
    }

    return(list(start = start, duration = hms::hms(as.integer(Sys.time() - start))))
  }


copy_table("dict_it")


