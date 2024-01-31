get_system_info <- function() {
  logger::log_trace("Getting system information")
  package <- getPackageName()
  version <- as.character(packageVersion(package))
  logger::log_trace("Package: ", package, " version: ", version)
  deps <- trimws(
    strsplit(
      x = packageDescription(package)[["Imports"]],
      split = ",",
      fixed = TRUE
    )[[1L]]
  )
  deps_version <- as.list(
    lapply(
      X = deps,
      FUN = function(x) {
        list(
          package = x,
          version = as.character(packageVersion(x))
        )
      }
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
