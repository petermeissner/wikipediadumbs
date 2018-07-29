#' wpd_filter_extract
#'
#' @param fname file name to extract data from
#' @param lang language to extract
#'
#' @export
#'
wpd_filter_extract <-
  function(fname, lang){
    fname_out <-
      paste0(
        "pagecounts-",
        stringr::str_extract(fname, "\\d{4}-\\d{2}-\\d{2}"),
        "_", lang
      )

    system_call <-
      sprintf(
        "bzcat %s | grep '^%s.z ' -ia > %s",
        fname,
        lang,
        paste0(dirname(fname), "/", fname_out)
      )

    system(system_call)
  }
