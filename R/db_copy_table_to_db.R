
#' db_copy_table_to_db
#'
#' @param table_name name of table
#' @param con_from connection to copy table from
#' @param con_to connection to copy table to
#' @param batch_size how many lines should be copied at once
#'
#' @export
#'
db_copy_table_to_db <-
  function(table_name, con_from, con_to, batch_size = 10000){

    # get current time
    start    <- Sys.time()

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
    statement_res  <- dbFetch(statement_exec, n = batch_size)
    size           <- nrow(statement_res)


    # ensure table exists at to table
    if( dbExistsTable(con_to, table_name) ){
      stop(sprintf("table '%s' exists already", table_name))
    } else {
      if ( size > 0 ){
        dbCreateTable(con_to, table_name, statement_res)
      }
    }

    # loop through
    while ( nrow(statement_res) > 0 ){

      # check encoding
      for ( i in seq_len(ncol(statement_res)) ){
        if ( "character" %in% class(statement_res[[i]])  ){
          Encoding(statement_res[[i]]) <- "UTF-8"
        }
      }

      dbt_hlp_progress(size, statement_size, start = start, m = table_name)
      dbAppendTable(con_to, table_name, value = statement_res)

      size          <- nrow(statement_res) + size
      statement_res <- dbFetch(statement_exec, n = batch_size)
      gc()
    }

    cat("\n")
    return(
      list(
        start    = start,
        end      = Sys.time(),
        duration =
          as.character(
            hms::hms(
              as.integer(
                difftime(
                  Sys.time(),
                  start,
                  units = "secs"
                )
              )
            )
          )
      )
    )
  }
