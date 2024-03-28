# suppress log messages during testing.
old_threshold <- logger::log_threshold()
withr::defer(logger::log_threshold(old_threshold))
logger::log_threshold("FATAL")

test_that("exporting a file works, no grouping", {
  test_dir <- withr::local_tempdir()
  metadata <- export_portfolio(
    portfolio_data = simple_portfolio,
    group_data = empty_groups,
    output_directory = test_dir
  )
  expect_simple_export_portfolio(output_dir = test_dir, metadata = metadata)
})

test_that("exporting works, against reordered columns", {
  test_dir <- withr::local_tempdir()
  reordered_portfolio <- dplyr::select(
    .data = simple_portfolio,
    market_value, isin, currency
  )
  metadata <- export_portfolio(
    portfolio_data = reordered_portfolio,
    group_data = empty_groups,
    output_directory = test_dir
  )
  expect_simple_export_portfolio(output_dir = test_dir, metadata = metadata)
})

test_that("exporting works, against extra columns", {
  test_dir <- withr::local_tempdir()
  extra_cols_portfolio <- dplyr::mutate(
    .data = simple_portfolio,
    foo = "bar"
  )
  expect_warning(
    metadata <- export_portfolio(
      portfolio_data = extra_cols_portfolio,
      group_data = empty_groups,
      output_directory = test_dir
    ),
    regexp = "^Extra columns detected in portfolio data. Discarding.$"
  )
  expect_simple_export_portfolio(output_dir = test_dir, metadata = metadata)
})

test_that("exporting fails when missing columns", {
  test_dir <- withr::local_tempdir()
  missing_cols_portfolio <- dplyr::select(
    .data = simple_portfolio,
    -market_value
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
  test_dir <- withr::local_tempdir()
  metadata <- export_portfolio(
    portfolio_data = simple_portfolio,
    group_data = simple_groups,
    output_directory = test_dir
  )
  expect_simple_export_portfolio(
    output_dir = test_dir,
    metadata = metadata,
    investor_name = "Simple Investor",
    portfolio_name = "Simple Portfolio"
  )
})

test_that("exporting a file works, port name grouping", {
  test_dir <- withr::local_tempdir()
  port_groups <- tibble::tribble(
    ~portfolio_name,
    "Simple Portfolio"
  )
  metadata <- export_portfolio(
    portfolio_data = simple_portfolio,
    group_data = port_groups,
    output_directory = test_dir
  )
  expect_simple_export_portfolio(
    output_dir = test_dir,
    metadata = metadata,
    investor_name = NULL,
    portfolio_name = "Simple Portfolio"
  )
})

test_that("exporting a file works, investor name grouping", {
  test_dir <- withr::local_tempdir()
  investor_group <- tibble::tribble(
    ~investor_name,
    "Simple Investor"
  )
  metadata <- export_portfolio(
    portfolio_data = simple_portfolio,
    group_data = investor_group,
    output_directory = test_dir
  )
  expect_simple_export_portfolio(
    output_dir = test_dir,
    metadata = metadata,
    investor_name = "Simple Investor",
    portfolio_name = NULL
  )
})
