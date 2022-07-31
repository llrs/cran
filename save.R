library("tools")
file_name <- function(folder, name, ext = ".RDS") {
    paste0(folder, "/", name, ext)
}
timestamp <- function(){format(Sys.time(), tz = "UTC", "%Y%m%dT%H%M")}
chck_r <- CRAN_check_results()
saveRDS(chck_r, file = file_name("check_results", timestamp()))
chck_d <- CRAN_check_details()
saveRDS(chck_d, file = file_name("check_details", timestamp()))
chck_i <- CRAN_check_issues()
saveRDS(chck_i, file = file_name("check_issues", timestamp()))
current_db <- tools:::CRAN_current_db()
saveRDS(current_db, file = file_name("current_db", timestamp()))
aliases_db <- tools:::CRAN_aliases_db()
saveRDS(aliases_db, file = file_name("aliases_db", timestamp()))
rdxrefs_db <- tools:::CRAN_rdxrefs_db()
saveRDS(rdxrefs_db, file = file_name("rdxrefs_db", timestamp()))
packages_db <- CRAN_package_db()
saveRDS(packages_db, file = file_name("packages_db", timestamp()))
download.file("https://cran.r-project.org/src/contrib/PACKAGES.in",
              destfile = file_name("PACKAGES", timestamp(), ".in"))


proto <- data.frame(r_version = character(),
                    os = character(),
                    architecture = character(),
                    other = character())
flavors <- chck_r$Flavor
flavors_df <- strcapture(
    pattern = "r-([[:alnum:]]+)-([[:alnum:]]+)-([[:alnum:]_\\+]+)-?(.*)",
    x = flavors,
    proto = proto)

# Extract R version used and svn id
h <- "https://www.r-project.org/nosvn/R.check/%s/%s-00check.html"
links <- sprintf(h, chck_r$Flavor, chck_r$Package)
extract_revision <- function(x) {
    r <- readLines(x, 12)[12]
    version <- strcapture(pattern = "([[:digit:]]\\.[[:digit:]]\\.[[:digit:]])",
                          x = r, proto = data.frame(version = character()))
    date <- strcapture(pattern = "([[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2})",  x = r,
                       proto = data.frame(date = character()))
    revision <- strcapture(pattern = "(r[[:digit:]]+)",  x = r,
                           proto = data.frame(revision = character()))
    cbind(version, date, revision)
}
# revision <- data.frame(version = character(),
#                        revision = character())
# library("future")
# library("future.apply")
# plan(multisession) ## Run in parallel on local computer
# er_catch <- function(i){
#     tryCatch(extract_revision(i), error = function(e) {
#         Sys.sleep(0.02)
#         extract_revision(i)
#     })}
# rev <- future_lapply(links, FUN = er_catch)
# revision <- do.call(rbind, rev)
# flavors_df <- cbind(flavors = flavors, flavors_df, revision)
# saveRDS(flavors_df, file = file_name("flavors_db", timestamp()))
