library(wpd)
library(DBI)

sql <-
  SQL(paste0("DELETE FROM page_views_", wpd_languages," a USING (
    SELECT MIN(ctid) as ctid, page_id, page_view_date
    FROM page_views_", wpd_languages,"
    GROUP BY page_id, page_view_date HAVING COUNT(*) > 1
  ) b
  WHERE a.page_id = b.page_id
  AND a.page_view_date = b.page_view_date
  AND a.ctid <> b.ctid;"
))


wpd_get_queries(sql)


indices <-
  SQL(paste0("CREATE UNIQUE INDEX \n  if not exists  page_views_",wpd_languages,"_page_id_idx \n  ON public.page_views_",wpd_languages," (page_id,page_view_date);"))

wpd_get_queries(indices)
