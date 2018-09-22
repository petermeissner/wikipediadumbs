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
          pattern     =
            sprintf(
              "(%s) \\S+ \\S+ \\S+",
              paste0("(^", wpd_languages, "\\.z)", collapse = "|")
            ),
          value       = TRUE
        )
    } else {
      lines_filtered <- lines
    }



    # transform to data.frame
    if( length(lines_filtered) > 0 ){
      lines_df <-
        lines_filtered %>%
        utf8_encode() %>%
        tolower() %>%
        paste0(collapse = "\n") %>%
        paste0("\ncs.z wpd_dump_lines_to_df_test_entry 0 a") %>%
        fread(
          input            = .,
          sep              = " ",
          header           = FALSE,
          stringsAsFactors = FALSE,
          encoding         = "UTF-8",
          select           = 1:3,
          data.table       = TRUE,
          colClasses       = c("character", "character", "integer", "character"),
          fill             = TRUE,
          quote            = ""
        ) %>%
        setNames(c("lang", "page_name", "page_view_count")) %>%
        mutate(
          lang      = substr(lang, 1, 2),
          page_name = url_decode(page_name)
        ) %>%
        filter(
          page_name != "wpd_dump_lines_to_df_test_entry"
        ) %>%
        group_by(
          lang, page_name
        ) %>%
        summarise(
          page_view_count = sum(page_view_count, na.rm = TRUE)
        ) %>%
        data.table()
    }else{
      lines_df <- data.table()
    }



    # split
    if (split == TRUE ){
      return(split(lines_df, lines_df$lang))
    } else {
      return(lines_df)
    }
  }
