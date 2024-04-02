simple_portfolio_hash <- local({
  ff <- withr::local_tempfile(fileext = ".csv")
  write.csv(
    x = simple_portfolio,
    file = ff,
    row.names = FALSE,
    na = "",
    fileEncoding = "UTF-8"
  )
  digest::digest(
    object = ff,
    file = TRUE,
    algo = "md5"
  )
})

expect_simple_portfolio_file <- function(filepath) {
  # Checking that output file exists.
  testthat::expect_true(file.exists(filepath))
  # Checking that output file has correct hash.
  testthat::expect_identical(
    digest::digest(
      object = filepath,
      file = TRUE,
      algo = "md5"
    ),
    simple_portfolio_hash
  )

  file_contents <- read.csv(filepath)
  # Check that output file has correct column names.
  testthat::expect_identical(
    colnames(file_contents),
    c(
      "isin",
      "market_value",
      "currency"
    )
  )
  # Check that output file has correct column types.
  testthat::expect_type(file_contents[["isin"]], "character")
  testthat::expect_in(
    class(file_contents[["market_value"]]),
    c("numeric", "integer")
  )
  testthat::expect_type(file_contents[["currency"]], "character")

  # Check file encoding
  testthat::expect_identical(
    pacta.portfolio.import::guess_file_encoding(filepath),
    "ascii"
  )

  return(nrow(file_contents))
}

expect_simple_export_portfolio <- function(
  output_dir,
  metadata,
  investor_name = NULL,
  portfolio_name = NULL
) {
  output_filepath <- file.path(
    output_dir,
    metadata[["output_filename"]]
  )
  # check metadata field names
  required_fields <- c("output_filename", "output_rows", "output_md5")
  optional_fields <- c("investor_name", "portfolio_name")
  testthat::expect_contains(names(metadata), required_fields)
  testthat::expect_in(
    names(metadata),
    c(required_fields, optional_fields)
  )

  # Check investor and portfolio names
  # Note that expect_identical() works for comparing NULL
  testthat::expect_identical(metadata[["investor_name"]], investor_name)
  testthat::expect_identical(metadata[["portfolio_name"]], portfolio_name)
  # Checking that output file has correct number of rows.
  testthat::expect_identical(metadata[["output_rows"]], 1L)
  # read file (should be small)
  # check that metadata row count is same as actual
  file_content_rows <- expect_simple_portfolio_file(output_filepath)
  testthat::expect_identical(
    metadata[["output_rows"]],
    file_content_rows
  )
}

expect_simple_reexport <- function(
  output_dir,
  metadata,
  groups,
  input_digest,
  input_filename,
  input_entries
) {
  # check length of metadata
  testthat::expect_setequal(
    object = names(metadata),
    expected = c(
      "group_cols",
      "input_md5",
      "input_entries",
      "input_filename",
      "portfolios",
      "subportfolios_count",
      "system_info"
    )
  )

  testthat::expect_null(metadata[["errors"]])
  testthat::expect_setequal(metadata[["group_cols"]], colnames(groups))
  testthat::expect_identical(metadata[["input_md5"]], input_digest)
  testthat::expect_identical(metadata[["input_entries"]], input_entries)
  testthat::expect_identical(metadata[["input_filename"]], input_filename)

  testthat::expect_type(metadata[["portfolios"]], "list")
  testthat::expect_length(
    object = metadata[["portfolios"]],
    n = metadata[["subportfolios_count"]]
  )

  testthat::expect_identical(
    metadata[["subportfolios_count"]], max(nrow(groups), 1L)
  )

  testthat::expect_null(metadata[["warnings"]])
  testthat::expect_null(metadata[["errors"]])

  observed_groups <- groups[0L, ]
  # for each entry in the metadata
  for (x in metadata[["portfolios"]]) {
    # check that the output file exists
    output_filepath <- file.path(
      output_dir,
      x[["output_filename"]]
    )
    file_content_rows <- expect_simple_portfolio_file(output_filepath)
    testthat::expect_identical(
      x[["output_rows"]],
      file_content_rows
    )

    required_fields <- c(
      "output_filename",
      "output_rows",
      "output_md5"
    )
    optional_fields <- c(
      "investor_name",
      "portfolio_name"
    )
    testthat::expect_contains(names(x), required_fields)
    testthat::expect_in(
      names(x),
      c(required_fields, optional_fields)
    )

    # check that the output file has the correct number of rows
    testthat::expect_identical(x[["output_rows"]], 1L)

    # check that the output file has the correct investor and portfolio names
    # look for this cobination in the groups data frame and add to observed
    # groups, for checking completeness later.
    if (
      "investor_name" %in% names(groups) &&
        "portfolio_name" %in% names(groups)
    ) {
      testthat::expect_identical(
        nrow(groups[
          groups[["investor_name"]] == x[["investor_name"]] &
            groups[["portfolio_name"]] == x[["portfolio_name"]],
        ]),
        1L
      )
      this_group <- data.frame(
        investor_name = x[["investor_name"]],
        portfolio_name = x[["portfolio_name"]]
      )
    } else if ("investor_name" %in% names(groups)) {
      testthat::expect_identical(
        nrow(groups[
          groups[["investor_name"]] == x[["investor_name"]],
        ]),
        1L
      )
      testthat::expect_null(x[["portfolio_name"]])
      this_group <- data.frame(
        investor_name = x[["investor_name"]]
      )
    } else if ("portfolio_name" %in% names(groups)) {
      testthat::expect_identical(
        nrow(groups[
          groups[["portfolio_name"]] == x[["portfolio_name"]],
        ]),
        1L
      )
      testthat::expect_null(x[["investor_name"]])
      this_group <- data.frame(
        portfolio_name = x[["portfolio_name"]]
      )
    } else {
      testthat::expect_null(x[["investor_name"]])
      testthat::expect_null(x[["portfolio_name"]])
      this_group <- data.frame()
    }
    observed_groups <- dplyr::bind_rows(observed_groups, this_group)
  }
  # Test that all observed groups are the expected groups
  testthat::expect_identical(
    dplyr::arrange(observed_groups, !!!rlang::syms(colnames(groups))),
    dplyr::arrange(groups, !!!rlang::syms(colnames(groups)))
  )
}

expect_reexport_failure <- function(
  metadata,
  input_filename,
  input_digest
) {
  testthat::expect_setequal(
    object = names(metadata),
    expected = c(
      "errors",
      "input_md5",
      "input_filename",
      "system_info"
    )
  )
  testthat::expect_identical(metadata[["input_md5"]], input_digest)
  testthat::expect_identical(metadata[["input_filename"]], input_filename)
  testthat::expect_type(metadata[["errors"]], "list")
  testthat::expect_identical(
    metadata[["errors"]],
    list(
      "Cannot import portfolio file. Please see documentation."
    )
  )
}
