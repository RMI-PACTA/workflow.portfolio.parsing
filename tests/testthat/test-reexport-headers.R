# suppress log messages during testing.
old_threshold <- logger::log_threshold()
withr::defer(logger::log_threshold(old_threshold))
logger::log_threshold("FATAL")

colnames_to_test <- list(
  camelcase = c(
    "investorName", "portfolioName", "isin", "marketValue", "currency"
  ),
  demo = c(
    "Investor.Name", "Portfolio.Name", "ISIN", "MarketValue", "Currency"
  ),
  dot = c(
    "Investor.Name", "Portfolio.Name", "ISIN", "Market.Value", "Currency"
  ),
  doublepadded = c(
    "  Investor.Name  ", "  Portfolio.Name  ", "  ISIN  ",
    "  MarketValue  ", "  Currency  "
  ),
  mixed = c(
    "INVESTOR.NAME", "PortfolioName", "isin", "market_value", " Currency"
  ),
  lowercase_nosep = c(
    "investorname", "portfolioname", "isin", "marketvalue", "currency"
  ),
  uppercase_nosep = c(
    "INVESTORNAME", "PORTFOLIONAME", "ISIN", "MARKETVALUE", "CURRENCY"
  ),
  padded = c(
    " Investor.Name ", " Portfolio.Name ", " ISIN ",
    " MarketValue ", " Currency "
  ),
  quoted = c(
    "\"investor_name\"", "\"portfolio_name\"", "\"isin\"",
    "\"market_value\"", "\"currency\""
  ),
  space = c(
    "Investor Name", "Portfolio Name", "ISIN", "Market Value", "Currency"
  ),
  underscore = c(
    "investor_name", "portfolio_name", "isin", "market_value", "currency"
  )
)

for (x in seq_along(colnames_to_test)) {
  testthat::test_that(
    desc = paste( # nolint: indentation_linter
      "re-exporting robust header formats -",
      names(colnames_to_test)[x]
    ),
    code = {
      test_dir <- withr::local_tempdir()
      test_file <- withr::local_tempfile(fileext = ".csv")
      write.csv(
        x = change_colnames(
          x = simple_portfolio_all_columns,
          colnames = colnames_to_test[[x]]
        ),
        file = test_file,
        row.names = FALSE,
        quote = FALSE
      )
      filehash <- digest::digest(
        object = test_file,
        file = TRUE,
        algo = "md5"
      )
      metadata <- reexport_portfolio(
        input_filepath = test_file,
        output_directory = test_dir
      )
      expect_simple_reexport(
        output_dir = test_dir,
        metadata = metadata,
        groups = simple_groups,
        input_digest = filehash,
        input_filename = basename(test_file),
        input_entries = 1L
      )
    })
}

test_that("re-exporting robust header formats - no headers simple", {
  test_dir <- withr::local_tempdir()
  test_file <- withr::local_tempfile(fileext = ".csv")
  write.table(
    x = simple_portfolio,
    file = test_file,
    row.names = FALSE,
    col.names = FALSE,
    sep = ",",
    quote = FALSE
  )
  filehash <- digest::digest(
    object = test_file,
    file = TRUE,
    algo = "md5"
  )
  metadata <- reexport_portfolio(
    input_filepath = test_file,
    output_directory = test_dir
  )
  expect_simple_reexport(
    output_dir = test_dir,
    metadata = metadata,
    groups = empty_groups,
    input_digest = filehash,
    input_filename = basename(test_file),
    input_entries = 1L
  )
})

test_that("re-exporting robust header formats - no headers all_columns", {
  test_dir <- withr::local_tempdir()
  test_file <- withr::local_tempfile(fileext = ".csv")
  write.table(
    x = simple_portfolio_all_columns,
    file = test_file,
    row.names = FALSE,
    col.names = FALSE,
    sep = ",",
    quote = FALSE
  )
  filehash <- digest::digest(
    object = test_file,
    file = TRUE,
    algo = "md5"
  )
  metadata <- reexport_portfolio(
    input_filepath = test_file,
    output_directory = test_dir
  )
  expect_simple_reexport(
    output_dir = test_dir,
    metadata = metadata,
    groups = simple_groups,
    input_digest = filehash,
    input_filename = basename(test_file),
    input_entries = 1L
  )
})
