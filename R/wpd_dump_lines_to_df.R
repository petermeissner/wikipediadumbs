#' wpd_dump_lines_to_df_list
#'
#' @param lines character vector of lines from a wikipedia üage views dump file
#'     should be filtered beforehand to exclude
#'
#' @export
#'
wpd_dump_lines_to_df_list <-
  function(lines, filter = TRUE, split = TRUE){

    # filtering for wpd_languages
    if ( filter == TRUE ){
      lines_filtered <-
        grep(
          x           = lines,
          pattern     = paste0("(^", wpd_languages, "\\.z)", collapse = "|"),
          value       = TRUE,
          ignore.case = TRUE
        )
    } else {
      lines_filtered <- lines
    }



    # transform to data.frame
    if( length(lines_filtered) > 0 ){
      lines_df <-
        lines_filtered %>%
        tolower() %>%
        paste(collapse = "\n", "\n" ) %>%
        fread(
          input            = .,
          sep              = " ",
          header           = FALSE,
          stringsAsFactors = FALSE,
          encoding         = "UTF-8",
          select           = 1:3,
          data.table       = TRUE,
          colClasses       = c("character", "character", "integer", "character")
        ) %>%
        setNames(c("lang", "page_name", "page_view_count")) %>%
        mutate(
          lang      = substr(lang, 1, 2),
          page_name = utf8_encode(url_decode(page_name))
        )
    }else{
      lines_df <- data.table::data.table()
    }



    # split
    if (split == TRUE ){
      return(lines_df)
    } else {
      return(split(lines_df, lines_df$lang))
    }
  }
