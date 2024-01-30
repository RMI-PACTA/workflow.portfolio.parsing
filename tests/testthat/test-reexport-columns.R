# suppress log messages during testing.
old_threshold <- logger::log_threshold()
withr::defer(logger::log_threshold(old_threshold))
logger::log_threshold("FATAL")

# establish testing tempdir
test_dir <- tempdir()
withr::defer(unlink(test_dir))

simple_groups <- tibble::tribble(
  ~investor_name, ~portfolio_name,
  "Simple Investor", "Simple Portfolio"
)


files_to_test <- c(
  # "simple_all-columns_extra_columns.csv", #TODO: enable this test
  # "simple_all-columns_reordered.csv", #TODO: enable this test
  "simple_extra_columns.csv" #,
  # "simple_investorname.csv", #TODO: enable this test
  # "simple_missing-currency.csv", #TODO: enable this test
  # "simple_missing-isin.csv", #TODO: enable this test
  # "simple_missing-marketvalue.csv", #TODO: enable this test
  # "simple_portfolioname.csv", #TODO: enable this test
  # "simple_reordered.csv" #TODO: enable this test
)

for (filename in files_to_test) {
  test_that(paste("re-exporting fails with missing columns -", filename), {
skip()
    test_file <- testthat::test_path(
      "testdata", "portfolios", "columns", filename
    )
    filehash <- digest::digest(
      object = test_file,
      file = TRUE,
      algo = "md5"
    )
    testthat::expect_warning(
      metadata <- reexport_portfolio(
        input_filepath = test_file,
        output_directory = test_dir
      ),
      "^No portfolio data detected in file.$"
    )
    expect_reexport_failure(
      metadata = metadata,
      input_filename = basename(test_file),
      input_digest = filehash
    )
  })
}
