library(wpd)


wpd_get_query(
"
  CREATE TABLE IF NOT EXISTS dict_en (
    page_id serial,
    page_name text unique,
    page_name_clean text
  )
"
)


