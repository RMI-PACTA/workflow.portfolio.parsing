# check for multiple conditions in a function's output.
# matches by regexp as documented in expect_warning, etc.
expect_multiple_conditions <- function(
  object,
  error = NULL,
  warning = NULL,
  message = NULL
) {
  if (length(error) > 0L) {
    testthat::expect_error(
      object = {
        expect_multiple_conditions(
          object = object,
          message = message,
          warning = warning,
          error = error[-1L]
        )
      },
      regexp = error[[1L]]
    )
    return(invisible(NULL))
  } else if (length(warning) > 0L) {
    testthat::expect_warning(
      object = {
        out <- expect_multiple_conditions(
          object = object,
          message = message,
          warning = warning[-1L],
          error = error
        )
      },
      regexp = warning[[1L]]
    )
  } else if (length(message) > 0L) {
    testthat::expect_message(
      object = {
        out <- expect_multiple_conditions(
          object = object,
          message = message[-1L],
          warning = warning,
          error = error
        )
      },
      regexp = message[[1L]]
    )
  } else {
    out <- {{ object }}
  }
  return(invisible(out))
}
