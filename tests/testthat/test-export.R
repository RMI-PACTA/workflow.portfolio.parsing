# suppress log messages during testing.
old_threshold <- logger::log_threshold()
withr::defer(logger::log_threshold(old_threshold))
logger::log_threshold("FATAL")

# establish testing tempdir
test_dir <- tempdir()
withr::defer(unlink(test_dir))
empty_groups <- data.frame()
simple_portfolio <- tibble::tribble(
  ~isin, ~market_value, ~currency,
  "GB0007980591", 10000, "USD"
)

test_that("exporting a file works, no grouping", {
  metadata <- export_portfolio(
    portfolio_data = simple_portfolio,
    group_data = empty_groups,
    output_directory = test_dir
  )
  expect_simple_portfolio_output(output_dir = test_dir, metadata = metadata)
})

test_that("exporting works, against reordered columns", {
  reordered_portfolio <- tibble::tribble(
    ~isin, ~currency, ~market_value,
    "GB0007980591", "USD", 10000
  )
  metadata <- export_portfolio(
    portfolio_data = reordered_portfolio,
    group_data = empty_groups,
    output_directory = test_dir
  )
  expect_simple_portfolio_output(output_dir = test_dir, metadata = metadata)
})

test_that("exporting works, against extra columns", {
  extra_cols_portfolio <- tibble::tribble(
    ~isin, ~currency, ~market_value, ~foo,
    "GB0007980591", "USD", 10000, "foo"
  )
  expect_warning(
    metadata <- export_portfolio(
      portfolio_data = extra_cols_portfolio,
      group_data = empty_groups,
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
  expect_error(
    export_portfolio(
      portfolio_data = missing_cols_portfolio,
      group_data = empty_groups,
      output_directory = test_dir
    ),
    regexp = "^Missing columns detected in portfolio data.$"
  )
})

test_that("exporting a file works, simple grouping", {
  simple_groups <- tibble::tribble(
    ~investor_name, ~portfolio_name,
    "Simple Investor", "Simple Portfolio"
  )
  metadata <- export_portfolio(
    portfolio_data = simple_portfolio,
    group_data = simple_groups,
    output_directory = test_dir
  )
  expect_simple_portfolio_output(
    output_dir = test_dir,
    metadata = metadata,
    investor_name = "Simple Investor",
    portfolio_name = "Simple Portfolio"
  )
})

test_that("exporting a file works, port name grouping", {
  simple_groups <- tibble::tribble(
    ~portfolio_name,
    "Simple Portfolio"
  )
  metadata <- export_portfolio(
    portfolio_data = simple_portfolio,
    group_data = simple_groups,
    output_directory = test_dir
  )
  expect_simple_portfolio_output(
    output_dir = test_dir,
    metadata = metadata,
    investor_name = NULL,
    portfolio_name = "Simple Portfolio"
  )
})

test_that("exporting a file works, investor name grouping", {
  simple_groups <- tibble::tribble(
    ~investor_name,
    "Simple Investor"
  )
  metadata <- export_portfolio(
    portfolio_data = simple_portfolio,
    group_data = simple_groups,
    output_directory = test_dir
  )
  expect_simple_portfolio_output(
    output_dir = test_dir,
    metadata = metadata,
    investor_name = "Simple Investor",
    portfolio_name = NULL
  )
})
