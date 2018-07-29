library(data.table)
library(wpd)


de <- fread("/data/wpd/pagecounts-2015-01-01_en", sep = " ")

counter <- 0
nrow_de <- nrow(de)
start   <- Sys.time()

con     <- wpd_connect()
errors  <- list()

while (TRUE) {
  if ( nrow_de <= counter ){
    break()
  }

  c1 <- min(counter + 1, nrow_de)
  c2 <- min(counter + 1000, nrow_de)

  tryCatch(
    wpd_push_item("2015-01-01", "en", page = gsub(pattern = "'", "''", de[c1:c2][[2]]), views = de[c1:c2][[3]]),
    error =
      function(e){
        errors[[length(errors)+1]] <<-
          list(
            c1 = c1,
            c2 = c2,
            error_message = e$message
          )

        for ( ci in seq(c1,c2) ){
          tryCatch(
            expr =
            {
              wpd_push_item(
                "2015-01-01",
                "en",
                page =
                  gsub(pattern = "'", "''", de[ci][[2]]), views = de[ci][[3]])
            },
            error =
              function(e){
                errors[[length(errors)+1]] <<-
                  list(
                    c1 = ci,
                    c2 = ci,
                    error_message = e$message
                  )
              }
          )
        }
      }
  )

  counter <- c2
  if(counter %% 1000 == 0){
    cat("\n", round(difftime(Sys.time(), start,units = "min"),2), "min: \t", c2, "error: \t", length(errors))
  }
}


