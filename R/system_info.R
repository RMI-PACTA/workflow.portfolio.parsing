get_system_info <- function() {
  logger::log_trace("Getting system information")
  package <- getPackageName()
  version <- as.character(packageVersion(package))
  logger::log_trace("Package: ", package, " version: ", version)
  deps <- strsplit(
    x = packageDescription(package)[["Imports"]],
    split = ",\n",
    fixed = TRUE
  )[[1L]]
  deps_version <- as.list(
    vapply(
      X = deps,
      FUN = function(x) {
        as.character(packageVersion(x))
      },
      FUN.VALUE = character(1L),
      USE.NAMES = TRUE
    )
  )
  return(
    list(
      timestamp = format(
        Sys.time(),
        format = "%Y-%m-%dT%H:%M:%SZ",
        tz = "UTC"
      ),
      package = package,
      packageVersion = version,
      RVersion = as.character(getRversion()),
      dependencies = deps_version
    )
  )
}
