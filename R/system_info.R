get_system_info <- function() {
  logger::log_trace("Getting system information")
  package <- utils::getPackageName()
  version <- as.character(utils::packageVersion(package))
  logger::log_trace("Package: ", package, " version: ", version)
  raw_deps <- trimws(
    strsplit(
      x = utils::packageDescription(package)[["Imports"]],
      split = ",",
      fixed = TRUE
    )[[1L]]
  )
  deps <- trimws(
    gsub(
      x = raw_deps,
      pattern = "\\s+\\(.*\\)",
      replacement = ""
    )
  )
  deps_version <- as.list(
    lapply(
      X = deps,
      FUN = function(x) {
        list(
          package = x,
          version = as.character(utils::packageVersion(x))
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
