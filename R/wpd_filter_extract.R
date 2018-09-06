#' wpd_filter_extract
#'
#' @param fname file name to extract data from
#' @param lang language to extract
#'
#' @export
#'
wpd_filter_extract <-
  function(file, languages = wpd_languages){
    future.apply::future_lapply(
      X    = languages,
      FUN  =
        function(x, fname){
          wpd_filter_extract_worker(fname = fname, lang = x)
        },
      fname = file
    )
  }

