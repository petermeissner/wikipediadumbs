#' wpd_db_topology
#'
#' @export
#'
wpd_db_topology <-
  function(){

    # modify future plan
    oplan <- future::plan()

    # ensure future plan is reversed at exit of function
    on.exit(future::plan(oplan), add = TRUE)

    # plan future execution
    future::plan(future::multisession, workers = length(wpd_languages))

    # worker function
    worker <-
      function(node){
        con <- wpd_connect(node = node)

        res <-
          wpd_get_queries(
            queries = wpd_sql("select distinct page_view_date from page_views_%s", wpd_languages),
            flatten = FALSE,
            con     = con
          )

        res_df_list <-
          lapply(
            res,
            function(l){
              df      <- l$return
              df$node <- l$node
              df
            }
          )
        for(i in seq_along(wpd_languages)){
          res_df_list[[i]]$lang <- wpd_languages[i]
        }

        data.frame(data.table::rbindlist(res_df_list))
      }

    topology <-
      data.frame(
        data.table::rbindlist(
          future.apply::future_lapply(
            names(wpd_nodes),
            worker
          ),
          use.names = TRUE,
          fill      = TRUE
        )
      )

    write.csv(topology, "topology.csv")
    topology
  }
