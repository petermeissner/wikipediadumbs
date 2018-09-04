with
page_view_data AS
	(
		select
		  tmp_tab.page_name, '", page_language,"' as page_language,
		  page_id,
		  page_view_date,
		  page_view_count
		from
			(select * from
				(
					VALUES  ", sql_values, "
				) as page_names
			) as tmp_tab (page_name, page_view_count, page_view_date)
			left join ", dict_table_name," on tmp_tab.page_name = ", dict_table_name,".page_name
	),
page_view_with_id_insert as
	(
	 	insert into ", page_views_table_name,"
		(
			select page_id, page_view_date::date, page_view_count
			from page_view_data
			where page_id is not null
		)
	)
insert into page_views_traffic
	(page_language, traffic_date, traffic_count, page_views_count)
	(
		select
		  '", page_language,"' as page_language,
		  page_view_date::date as traffic_date,
		  count(page_name) as traffic_count,
		  count(page_id) as page_views_count
		from page_view_data
		group by traffic_date
	)
;

