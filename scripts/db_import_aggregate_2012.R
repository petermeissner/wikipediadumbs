

library(wpd)

sql <-
  wpd_sql(
    "
    insert into imports_%s
      select
        aa.page_id,
        2012,
        string_agg((CASE when bb.page_view_count isnull THEN 0 else bb.page_view_count end)::text, ',')
        from
        (
          select * from (select generate_series('2012-01-01'::date, '2012-12-31'::date, '1 day'::interval)::date as page_view_date) as a
          cross join
          (select page_id from dict_%s) as b
    --      where page_id
        ) as aa
        left join
        (
          select page_id, page_view_date, sum(page_view_count) as page_view_count
          from page_views_%s_2012_import
    --      where page_id
          group by page_id, page_view_date
        ) as bb
        on aa.page_id = bb.page_id and aa.page_view_date = bb.page_view_date
        group by aa.page_id
    ;
    ",
    sort(wpd_languages),
    sort(wpd_languages),
    sort(wpd_languages)
  )


start <- Sys.time()
dbt_hlp_progress(0, length(sql))

for ( i in seq_along(sql) ){
  cat(rev(sql)[i])
  wpd_get_query_master(rev(sql)[i])
  dbt_hlp_progress(i, length(sql), start)
}

