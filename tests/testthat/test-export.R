# suppress log messages during testing.
old_threshold <- logger::log_threshold()
withr::defer(logger::log_threshold(old_threshold))
logger::log_threshold("FATAL")

# establish testing tempdir
test_dir <- tempdir()
withr::defer(unlink(test_dir))

test_that("exporting a file works, no grouping", {
  simple_portfolio <- tibble::tribble(
    ~isin, ~market_value, ~currency,
    "GB0007980591", 10000, "USD"
  )
  simple_groups <- data.frame()
  metadata <- export_portfolio(
    portfolio_data = simple_portfolio,
    group_data = simple_groups,
    output_directory = test_dir
  )
  expect_simple_portfolio_output(output_dir = test_dir, metadata = metadata)
})

test_that("exporting works, against reordered columns", {
  reordered_portfolio <- tibble::tribble(
    ~isin, ~currency, ~market_value,
    "GB0007980591", "USD", 10000
  )
  simple_groups <- data.frame()
  metadata <- export_portfolio(
    portfolio_data = reordered_portfolio,
    group_data = simple_groups,
    output_directory = test_dir
  )
  expect_simple_portfolio_output(output_dir = test_dir, metadata = metadata)
})

test_that("exporting works, against extra columns", {
  extra_cols_portfolio <- tibble::tribble(
    ~isin, ~currency, ~market_value, ~foo,
    "GB0007980591", "USD", 10000, "foo"
  )
  simple_groups <- data.frame()
  expect_warning(
    metadata <- export_portfolio(
      portfolio_data = extra_cols_portfolio,
      group_data = simple_groups,
      output_directory = test_dir
    ),
    regexp = "^Extra columns detected in portfolio data. Discarding.$"
  )
  expect_simple_portfolio_output(output_dir = test_dir, metadata = metadata)
})

test_that("exporting fails when missing columns", {
  missing_cols_portfolio <- tibble::tribble(
    ~isin, ~currency,
    "GB0007980591", "USD"
  )
  simple_groups <- data.frame()
  expect_error(
    export_portfolio(
      portfolio_data = missing_cols_portfolio,
      group_data = simple_groups,
      output_directory = test_dir
    ),
    regexp = "^Missing columns detected in portfolio data.$"
  )
})
