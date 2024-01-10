simple_portfolio_hash <- digest::digest(
  object = system.file(
    "extdata", "portfolios", "simple_output.csv",
    package = "workflow.portfolio.parsing"
  ),
  file = TRUE,
  algo = "md5"
)

expect_simple_portfolio_output <- function(
  output_dir,
  metadata,
  investor_name = NULL,
  portfolio_name = NULL
) {
  output_filepath <- file.path(
    output_dir,
    metadata[["output_filename"]]
  )
  # Checking that output file exists.
  testthat::expect_true(file.exists(output_filepath))
  # Checking that output file has correct hash.
  testthat::expect_equal(
    digest::digest(
      object = output_filepath,
      file = TRUE,
      algo = "md5"
    ),
    simple_portfolio_hash
  )
  # Check investor and portfolio names
  # Note that expect_equal() works for comparing NULL
  testthat::expect_equal(metadata[["investor_name"]], investor_name)
  testthat::expect_equal(metadata[["portfolio_name"]], portfolio_name)
  # Checking that output file has correct number of rows.
  testthat::expect_equal(metadata[["output_rows"]], 1L)
  # read file (should be small)
  file_contents <- read.csv(output_filepath)
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
  testthat::expect_equal(
    sapply(file_contents, class),
    c(
      isin = "character",
      market_value = "numeric",
      currency = "character"
    )
  )
  # check that metadata row count is same as actual
  testthat::expect_equal(
    metadata[["output_rows"]],
    nrow(file_contents)
  )
}
