
#' wpd_upload_pageview_counts
#'
#' @param page_language language (length 1)
#' @param page_name character vector of page names
#' @param page_view_count numeric vector of page view counts
#' @param page_view_date date for page view counts (length 1)
#' @param conn either NULL or an connection object
#'
#' @export
#'
wpd_upload_pageview_counts <-
  function(
    page_name,
    page_view_count,
    page_view_date,
    page_language,
    conn = NULL
  ) {

    # check inputs
    stopifnot(length(page_language) == 1, length(page_view_date) == 1)

    # connection to wpd database
    if( is.null(conn) ){
      conn <- wpd_connect()
      on.exit(DBI::dbDisconnect(conn))
    }

    # prepare table names
    dict_table_name       <- paste0("dict_", page_language)
    page_views_table_name <- paste0("page_views_", page_language)

    # prepare sql value list
    sql_values <-
      paste(
        paste0(
          "(",
          DBI::dbQuoteLiteral(conn = conn, x = page_name), ", ",
          DBI::dbQuoteLiteral(conn = conn, x = page_view_count), ", ",
          DBI::dbQuoteLiteral(conn = conn, x = page_view_date),
          ")"
        ), collapse = ",\n"
      )


    sql <-
      SQL(
        paste0(
          "with
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
          -- ON CONFLICT (page_id, page_view_date)
          -- DO UPDATE
          -- SET page_view_count = excluded.page_view_count
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

      "
        )
      )

    wpd_get_query(sql, con = conn)

  }
