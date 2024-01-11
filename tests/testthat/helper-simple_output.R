simple_portfolio_hash <- digest::digest(
  object = system.file(
    "extdata", "portfolios", "simple_output.csv",
    package = "workflow.portfolio.parsing"
  ),
  file = TRUE,
  algo = "md5"
)

expect_simple_portfolio_file <- function(filepath) {
  # Checking that output file exists.
  testthat::expect_true(file.exists(filepath))
  # Checking that output file has correct hash.
  testthat::expect_equal(
    digest::digest(
      object = filepath,
      file = TRUE,
      algo = "md5"
    ),
    simple_portfolio_hash
  )

  file_contents <- read.csv(filepath)
  # Check that output file has correct column names.
  testthat::expect_equal(
    colnames(file_contents),
    c(
      "isin",
      "market_value",
      "currency"
    )
  )
  # Check that output file has correct column types.
  testthat::expect_equal(class(file_contents[["isin"]]), "character")
  testthat::expect_in(
    class(file_contents[["market_value"]]),
    c("numeric", "integer")
  )
  testthat::expect_equal(class(file_contents[["currency"]]), "character")

  # Check file encoding
  testthat::expect_equal(
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
  required_fields <- c("output_filename", "output_rows", "output_digest")
  optional_fields <- c("investor_name", "portfolio_name")
  testthat::expect_contains(names(metadata), required_fields)
  testthat::expect_in(
    names(metadata),
    c(required_fields, optional_fields)
  )

  # Check investor and portfolio names
  # Note that expect_equal() works for comparing NULL
  testthat::expect_equal(metadata[["investor_name"]], investor_name)
  testthat::expect_equal(metadata[["portfolio_name"]], portfolio_name)
  # Checking that output file has correct number of rows.
  testthat::expect_equal(metadata[["output_rows"]], 1L)
  # read file (should be small)
  # check that metadata row count is same as actual
  file_content_rows <- expect_simple_portfolio_file(output_filepath)
  testthat::expect_equal(
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
  testthat::expect_equal(length(metadata), input_entries)

  observed_groups <- groups[0, ]
  # for each entry in the metadata
  for (x in metadata) {
    # check that the output file exists
    output_filepath <- file.path(
      output_dir,
      x[["output_filename"]]
    )
    file_content_rows <- expect_simple_portfolio_file(output_filepath)
    testthat::expect_equal(
      x[["output_rows"]],
      file_content_rows
    )

    required_fields <- c(
      "output_filename", "output_rows", "output_digest",
      "input_digest", "input_filename", "input_entries",
      "subportfolios_count", "group_cols"
    )
    optional_fields <- c("investor_name", "portfolio_name")
    testthat::expect_contains(names(x), required_fields)
    testthat::expect_in(
      names(x),
      c(required_fields, optional_fields)
    )

    # check that the output file has the correct number of rows
    testthat::expect_equal(x[["output_rows"]], 1L)
    # check that the output file has the correct input digest
    testthat::expect_equal(x[["input_digest"]], input_digest)
    # check that the output file has the correct input filename
    testthat::expect_equal(x[["input_filename"]], input_filename)
    # check that the output file has the correct input entries
    testthat::expect_equal(x[["input_entries"]], input_entries)
    testthat::expect_equal(x[["subportfolios_count"]], max(nrow(groups), 1L))
    testthat::expect_setequal(x[["group_cols"]], colnames(groups))

    # check that the output file has the correct investor and portfolio names
    # look for this cobination in the groups data frame and add to observed
    # groups, for checking completeness later.
    if (
      "investor_name" %in% names(groups) &&
        "portfolio_name" %in% names(groups)
    ) {
      testthat::expect_equal(
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
      testthat::expect_equal(
        nrow(groups[
          groups[["investor_name"]] == x[["investor_name"]],
        ]),
        1L
      )
      testthat::expect_equal(x[["portfolio_name"]], NULL)
      this_group <- data.frame(
        investor_name = x[["investor_name"]]
      )
    } else if ("portfolio_name" %in% names(groups)) {
      testthat::expect_equal(
        nrow(groups[
          groups[["portfolio_name"]] == x[["portfolio_name"]],
        ]),
        1L
      )
      testthat::expect_equal(x[["investor_name"]], NULL)
      this_group <- data.frame(
        portfolio_name = x[["portfolio_name"]]
      )
    } else {
      testthat::expect_equal(x[["investor_name"]], NULL)
      testthat::expect_equal(x[["portfolio_name"]], NULL)
      this_group <- data.frame()
    }
    observed_groups <- dplyr::bind_rows(observed_groups, this_group)
  }
  testthat::expect_equal(
    dplyr::arrange(observed_groups, !!!rlang::syms(colnames(groups))),
    dplyr::arrange(groups, !!!rlang::syms(colnames(groups)))
  )
}
