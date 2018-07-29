#' wpd_batch_execute
#'
#'
#' @param SQL_GEN_FUNCTION a function that will generate a SQL statement for a batch length of each dot parameter and that will be called for each batch to be executed
#' @param BATCH_SIZE a series of batch sizes to go through - errors in the SQL execution will lead to going down the batch size list
#' @param CON an optional connection object - if NULL, wpd_connect will be used to establish a new connection
#' @param ... parameter passed through to sql_gen_function
#'
#' @export
#'
wpd_batch_execute <-
  function(
    SQL_GEN_FUNCTION,
    BATCH_SIZE = c(10000, 1000, 100, 1),
    CON        = NULL,
    ...
  ){

    # preprocess BATCH_SIZE
    if( is.null(BATCH_SIZE) || all(BATCH_SIZE == 1)  || all(BATCH_SIZE == 0) ){
      BATCH_SIZE <- 1
    }

    # determine length of first ... parameter
    par_length <- length(list(...))
    if ( par_length > 0 ){
      par_length <- length(list(...)[[1]])
    }

    # handle connections
    if ( is.null(CON) ){
      CON <- wpd_connect()
      on.exit(DBI::dbDisconnect(CON))
    }

    # results
    res <- list()

    # batch execute function
    batch_sequence <- seq_len( ceiling( par_length / BATCH_SIZE[1] ) )
    for ( batch in  batch_sequence ) {

      # determine which items prepare and execute
      batch_is <-
        seq(
          from = min(((batch - 1) * BATCH_SIZE[1]) + 1, par_length),
          to   = min(((batch)     * BATCH_SIZE[1]),     par_length)
        )

      # prepare query
      sql <- SQL_GEN_FUNCTION(...)


      # execute query
      batch_res       <- wpd_get_query(query = sql, con = CON)
      batch_res$batch <-
        c(
          min(batch_is),
          max(batch_is)
        )

      if ( batch_res$status$errorMsg == "OK" | all(BATCH_SIZE == 1) ) {

        # do nothing and execute next batch
        res[[ length(res) + 1 ]] <- batch_res

      }else{

        # split batch into sub batches
        res[[ length(res) + 1 ]] <-

          do.call(
            what = "wpd_batch_execute",
            args =
              c(
                list(
                  BATCH_SIZE       = BATCH_SIZE[-1],
                  SQL_GEN_FUNCTION = SQL_GEN_FUNCTION,
                  CON              = CON
                ),
                wpd_hlp_subset_dots(
                  ...,
                  i = batch_is
                )
              )
          )
      }
    }

    # return
    invisible(res)
  }



















