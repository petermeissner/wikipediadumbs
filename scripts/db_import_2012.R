

# packages
library(wpd)
library(dplyr)
library(future)
library(future.apply)


# options
plan("multisession", workers = availableCores())
import_date <- "2012"



# get distribution of jobs
topology <- wpd_db_topology()


# filter
topo <-
  topology %>%
  #as_data_frame() %>%
  filter(
    substring(task_date, 1, 4) == import_date
  ) %>%
  group_by(
    task_date,
    task_lang
  ) %>%
  summarise(
    ok   = sum(job_status == "done", na.rm = TRUE) > 0,
    node = job_run_node[job_status == "done"][1]
  ) %>%
  group_by(
    task_date
  ) %>%
  summarise(
    ok   = sum(ok, na.rm = TRUE) == length(wpd_languages),
    node = paste0(unique(sort(node)), collapse = ", ")
  )





sql <-
  wpd_sql(
    "CREATE TABLE if not exists page_views_%s_%s_import (
    page_id int4 NULL,
    page_view_date date NULL,
    page_view_count int4 NULL
  )
    ;
    ",
    wpd_languages,
    import_date
  )
for(i in seq_along(sql)) wpd_get_query_master(sql[i])


sql_list <- list()
for( i in seq_len(nrow(topo)) ){

  if( wpd_nodes[topo$node[i]] == Sys.info()["nodename"]){
    sql <-
      wpd_sql(
        "insert into page_views_%s_%s_import
          select page_id, page_view_date, sum(page_view_count)
          from page_views_%s where page_view_date = '%s'::date
          group by page_id, page_view_date
        ;
        ",
        wpd_languages,
        import_date,
        wpd_languages,
        topo$task_date[i]
      )
  }else{
    sql <-
      wpd_sql(
        "insert into page_views_%s_%s_import
    select page_id, page_view_date, sum(page_view_count) from
    dblink(
      'dbname=wikipedia port=5432 host=%s user=%s password=%s',
      'select * from page_views_%s where page_view_date = ''%s''::date')
      as dings(page_id int4, page_view_date date, page_view_count int4)
    group by page_id, page_view_date
    ;
    ",
        wpd_languages,
        import_date,
        wpd_nodes[topo$node[i]],
        Sys.getenv("wpd_user"),
        Sys.getenv("wpd_password"),
        wpd_languages,
        topo$task_date[i]
      )
  }

  sql_list[[ length(sql_list) + 1 ]] <-
    data_frame(
      page_view_date = topo$task_date[i],
      page_view_lang = wpd_languages,
      node           = topo$node[i],
      sql            = sql
    )
}


sql_df      <- do.call(rbind, sql_list)
sql_df      <- sample_n(sql_df, nrow(sql_df))
sql_df_list <- split(sql_df, seq_len(nrow(sql_df)))







results <-
  do.call(
    rbind,
    future_lapply(
      X   = sql_df_list,
      FUN =
        function(df){


          jobs <-
            wpd_get_query_master(
              wpd_sql(
                "select * from import_jobs
          where page_view_date ='%s'::date and
          page_view_lang = '%s'
          ",
                df$page_view_date,
                df$page_view_lang
              )
            )$return

          if ( nrow(jobs) == 0 ){
            wpd_get_query_master(
              wpd_sql(
                "insert into import_jobs (page_view_lang, page_view_date)
            values ('%s', '%s')",
                df$page_view_lang,
                df$page_view_date
              )
            )
            jobs <-
              wpd_get_query_master(
                wpd_sql(
                  "select * from import_jobs
          where page_view_date ='%s'::date and
          page_view_lang = '%s'
          ",
                  df$page_view_date,
                  df$page_view_lang
                )
              )$return
          }

          if ( jobs$import_status %in% c("start", "done") ){

            message("done already: ", df$page_view_date, " ", df$page_view_lang)
            df$sql    <- NULL
            df$status <- "done already"
            return(df)

          } else {

            message(
              "started:   ", df$page_view_date, " ", df$page_view_lang,
              " -- ", as.character(Sys.time()), " -- start"
            )

            if ( jobs$import_status %in% "error" ) {
              wpd_get_query_master(
                wpd_sql(
                  "delete from page_views_%s_%s_import where page_view_date = '%s'::date",
                  df$page_view_lang,
                  import_date,
                  df$page_view_date
                )
              )
            }

            wpd_get_query_master(
              wpd_sql(
                "update import_jobs set import_status = 'start'
                where page_view_date = '%s'::date and page_view_lang = '%s'",
                df$page_view_date,
                df$page_view_lang
              )
            )

            res <- wpd_get_query_master(df$sql)
            if ( res$status$errorMsg == "OK" ){
              status <- "done"
            }else{
              status <- "error"
            }


            wpd_get_query_master(
              wpd_sql(
                "update import_jobs set import_status = '%s'
                where page_view_date = '%s'::date and page_view_lang = '%s'",
                status,
                df$page_view_date,
                df$page_view_lang
              )
            )

            message(
              "processed: ", df$page_view_date, " ", df$page_view_lang,
              " -- ", as.character(Sys.time()), " -- ",status
            )
            df$sql    <- NULL
            df$status <- status
            return(df)
          }

        }
    )
  )
results





