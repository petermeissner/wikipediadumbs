#
# consistency checks for dictionaries
#
#
#


library(wpd)
library(DBI)
library(data.table)
library(dplyr)


nodes         <- names(wpd_nodes[!names(wpd_nodes)=="master"])
dicts         <- paste0("dict_", wpd_languages)
dict_sourcess <- paste0("dict_source_", wpd_languages)



DF <-
  list(
    data.frame(
      table = character(0),
      node  = character(0),
      count = integer()
    )
  )

for ( node in nodes ){

  for( dict in dicts ){
    res <-
      wpd_get_query(
        query = sprintf("select count(*) from %s", dict),
        con   = wpd_connect(node = node),
        close = TRUE
      )

    DF[[ length(DF) + 1 ]] <-
      data.frame(
        table = dict,
        node  = node,
        count = res$return$count
      )
  }

  for ( dict_source in dict_sourcess ){
    res <-
      wpd_get_query(
        query = sprintf("select count(*) from %s", dict_source),
        con   = wpd_connect(node = node),
        close = TRUE
      )

    DF[[ length(DF) + 1 ]] <-
      data.frame(
        table = dict_source,
        node  = node,
        count = res$return$count
      )
  }
}


tables_data <- do.call(rbind, DF)
tables_data %>% arrange(table, node)





