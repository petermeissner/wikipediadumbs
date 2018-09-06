#' wpd_filter_extract_worker
#'
#' @param fname file name to filter extract
#' @param lang language to extract
#'
#'
wpd_filter_extract_worker <-
  function(fname, lang){

    start <- Sys.time()
    cat(as.character(Sys.time()), "-- start -- ", lang, fname)

    fname_out <-
      paste0(
        "pagecounts-",
        stringr::str_extract(fname, "\\d{4}-\\d{2}-\\d{2}"),
        "_", lang, ".bz2"
      )

    system_call <-
      sprintf(
        paste0(
          "bzcat %s ",
          "| grep '^%s.z ' -i --text ",
          "| grep -e ':'  -e '\\.jpg '  -e '\\.png '  -e 'wikimedia'  -e '\\.php ' -vi --text ",
          "| bzip2 -fk > %s"
        ),
        fname,
        lang,
        paste0(dirname(fname), "/", fname_out)
      )

    system(system_call)

    cat(
      as.character(Sys.time()),
      "-- end -- ",
      lang,
      fname,
      "--",
      hms::hms(difftime(Sys.time(), start))
    )
  }
