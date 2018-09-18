library(wpd)
library(DBI)

sql <-
  SQL(paste0("DELETE FROM page_views_", wpd_languages," a
  WHERE a.ctid <> (
    SELECT min(b.ctid)
    FROM   page_views_",wpd_languages," b
    WHERE  a.page_id = b.page_id and a.page_view_date = b.page_view_date
  );"))


wpd_get_queries(sql)


indices <-
  c("CREATE UNIQUE INDEX if not exists  page_views_cs_page_id_idx ON public.page_views_cs (page_id,page_view_date);",
"CREATE UNIQUE INDEX if not exists  page_views_da_page_id_idx ON public.page_views_da (page_id,page_view_date);",
"CREATE UNIQUE INDEX if not exists  page_views_de_page_id_idx ON public.page_views_de (page_id,page_view_date);",
"CREATE UNIQUE INDEX if not exists  page_views_el_page_id_idx ON public.page_views_el (page_id,page_view_date);",
"CREATE UNIQUE INDEX if not exists  page_views_en_page_id_idx ON public.page_views_en (page_id,page_view_date);",
"CREATE UNIQUE INDEX if not exists  page_views_es_page_id_idx ON public.page_views_es (page_id,page_view_date);",
"CREATE UNIQUE INDEX if not exists  page_views_et_page_id_idx ON public.page_views_et (page_id,page_view_date);",
"CREATE UNIQUE INDEX if not exists  page_views_fi_page_id_idx ON public.page_views_fi (page_id,page_view_date);",
"CREATE UNIQUE INDEX if not exists  page_views_fr_page_id_idx ON public.page_views_fr (page_id,page_view_date);",
"CREATE UNIQUE INDEX if not exists  page_views_hu_page_id_idx ON public.page_views_hu (page_id,page_view_date);",
"CREATE UNIQUE INDEX if not exists  page_views_it_page_id_idx ON public.page_views_it (page_id,page_view_date);",
"CREATE UNIQUE INDEX if not exists  page_views_pt_page_id_idx ON public.page_views_pt (page_id,page_view_date);",
"CREATE UNIQUE INDEX if not exists  page_views_ru_page_id_idx ON public.page_views_ru (page_id,page_view_date);",
"CREATE UNIQUE INDEX if not exists  page_views_sk_page_id_idx ON public.page_views_sk (page_id,page_view_date);",
"CREATE UNIQUE INDEX if not exists  page_views_sl_page_id_idx ON public.page_views_sl (page_id,page_view_date);",
"CREATE UNIQUE INDEX if not exists  page_views_sv_page_id_idx ON public.page_views_sv (page_id,page_view_date);",
"CREATE UNIQUE INDEX if not exists  page_views_tr_page_id_idx ON public.page_views_tr (page_id,page_view_date);",
"CREATE UNIQUE INDEX if not exists  page_views_zh_page_id_idx ON public.page_views_zh (page_id,page_view_date);")

wpd_get_queries(indices)
