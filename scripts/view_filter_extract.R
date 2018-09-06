library(wpd)
library(future)


# get list of files
page_count_files_bz2 <-
  list.files("/data/wpd", pattern = "\\d{4}-\\d{2}-\\d{2}\\.bz2$", full.names = TRUE)

plan(multiprocess, workers = 2)


for ( i in seq_along(page_count_files_bz2) ){
  wpd_filter_extract(page_count_files_bz2[i])

  fname_stub <- gsub("\\.bz2", "", basename(page_count_files_bz2[i]))
  fnames_lang <- paste0(fname_stub, "_", wpd_languages)

  fnames_lang_found <- list.files("/data/wpd/", pattern = paste0(fnames_lang, collapse = "|"))

  if ( length(fnames_lang_found) == length(wpd_languages) ){
    unlink(page_count_files_bz2[i])
  }
}


