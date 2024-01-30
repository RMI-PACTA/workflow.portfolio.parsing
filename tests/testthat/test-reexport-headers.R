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
  "simple_all-columns_headers-camelcase.csv",
  "simple_all-columns_headers-demo.csv",
  "simple_all-columns_headers-dot.csv",
  # "simple_all-columns_headers-doublepadded.csv", #TODO: enable this test
  "simple_all-columns_headers-mixed.csv",
  # "simple_all-columns_headers-none.csv",
  "simple_all-columns_headers-nosep-lowercase.csv",
  "simple_all-columns_headers-nosep-uppercase.csv",
  "simple_all-columns_headers-padded.csv",
  "simple_all-columns_headers-quoted.csv",
  "simple_all-columns_headers-space.csv",
  "simple_all-columns_headers-underscore.csv"#,
  # "simple_headers-none.csv"
)

for (filename in files_to_test) {
  test_that(paste("re-exporting robust header formats -", filename), {
    test_file <- testthat::test_path(
      "testdata", "portfolios", "headers", filename
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
