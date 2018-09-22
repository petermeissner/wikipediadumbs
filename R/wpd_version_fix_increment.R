#' wpd_version_fix
#'
#' @export
#'
wpd_version_fix_increment <- function(){
  usethis::use_version("patch")
}

#' wpd_version_feature
#'
#' @export
#'
wpd_version_feature_increment <- function(){
  usethis::use_version("minor")
}
