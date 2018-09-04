with
page_view_data AS
	(
		SELECT
		  tmp_tab.page_name,
		  'cs' AS page_language,
		  page_id,
		  page_view_date,
		  page_view_count
		  FROM
			(SELECT * FROM
				(
					VALUES  ('!',2, '2018-01-01'),  ('!!!',3, '2018-01-01'),  ('!!!_(chk_chk_chk)',4, '2018-01-01') , ('petermeissner', 4, '2018-01-01')
				) AS page_names
			) AS tmp_tab (page_name, page_view_count, page_view_date)
			left join dict_cs on tmp_tab.page_name = dict_cs.page_name
	),
page_view_with_id_insert AS
	(
	 	insert into page_views_cs
		(
			SELECT page_id, page_view_date::date, page_view_count
			FROM page_view_data
			WHERE page_id is NOT NULL
		)
		returning *
	),
page_view_without_id_dump_insert AS
	(
		 insert into page_views_dump
		 	(page_name, page_language, page_view_date, page_view_count)
				(
					SELECT page_name, page_language, page_view_date::date, page_view_count
					FROM page_view_data
					WHERE page_id is null
				)
		returning *
	)
SELECT false AS page_id_valid, count(*) AS count
  FROM page_view_without_id_dump_insert
  UNION
  SELECT true  AS page_id_valid, count(*) AS count
    FROM page_view_with_id_insert
;
