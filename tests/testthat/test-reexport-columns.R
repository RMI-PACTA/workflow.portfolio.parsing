# suppress log messages during testing.
old_threshold <- logger::log_threshold()
withr::defer(logger::log_threshold(old_threshold))
logger::log_threshold("FATAL")

# files_to_test <- c(
#   # "simple_all-columns_extra_columns.csv", #TODO: enable this test
#   # "simple_all-columns_reordered.csv", #TODO: enable this test
#   "simple_extra_columns.csv" #,
#   # "simple_reordered.csv" #TODO: enable this test
# )

test_that("re-exporting with extra columns works", {
  test_dir <- withr::local_tempdir()
  test_file <- withr::local_tempfile(fileext = ".csv")
  write.csv(
    x = dplyr::mutate(
      .data = simple_portfolio_all_columns,
      foo = "bar"
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
  metadata <- reexport_portfolio( # nolint: implicit_assignment_linter
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

test_that("re-exporting fails with missing columns - investor_name", {
  test_dir <- withr::local_tempdir()
  test_file <- withr::local_tempfile(fileext = ".csv")
  write.csv(
    x = dplyr::select(
      .data = simple_portfolio_all_columns,
      -investor_name
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
  testthat::expect_warning(
    testthat::expect_warning(
      metadata <- reexport_portfolio( # nolint: implicit_assignment_linter
        input_filepath = test_file,
        output_directory = test_dir
      ),
      "^No portfolio data detected in file.$"
    ),
    "^Object could not be validated against schema.$"
  )
  expect_reexport_failure(
    metadata = metadata,
    input_filename = basename(test_file),
    input_digest = filehash
  )
})

test_that("re-exporting fails with missing columns - portfolio_name", {
  test_dir <- withr::local_tempdir()
  test_file <- withr::local_tempfile(fileext = ".csv")
  write.csv(
    x = dplyr::select(
      .data = simple_portfolio_all_columns,
      -portfolio_name
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
  testthat::expect_warning(
    testthat::expect_warning(
      metadata <- reexport_portfolio( # nolint: implicit_assignment_linter
        input_filepath = test_file,
        output_directory = test_dir
      ),
      "^No portfolio data detected in file.$"
    ),
    "^Object could not be validated against schema.$"
  )
  expect_reexport_failure(
    metadata = metadata,
    input_filename = basename(test_file),
    input_digest = filehash
  )
})

test_that("re-exporting fails with missing columns - currency", {
  test_dir <- withr::local_tempdir()
  test_file <- withr::local_tempfile(fileext = ".csv")
  write.csv(
    x = dplyr::select(
      .data = simple_portfolio_all_columns,
      -currency
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
  testthat::expect_warning(
    testthat::expect_warning(
      testthat::expect_warning(
        testthat::expect_warning(
          metadata <- reexport_portfolio( # nolint: implicit_assignment_linter
            input_filepath = test_file,
            output_directory = test_dir
          ),
          regexp = "^No portfolio data detected in file.$"
        ),
        regexp = "^Object could not be validated against schema.$"
      ),
      regexp = "column could not be determined"
    ),
    regexp = "column could not be determined"
  )
  expect_reexport_failure(
    metadata = metadata,
    input_filename = basename(test_file),
    input_digest = filehash
  )
})

test_that("re-exporting fails with missing columns - isin", {
  test_dir <- withr::local_tempdir()
  test_file <- withr::local_tempfile(fileext = ".csv")
  write.csv(
    x = dplyr::select(
      .data= simple_portfolio_all_columns,
      -isin
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
  testthat::expect_warning(
    testthat::expect_warning(
      testthat::expect_warning(
        testthat::expect_warning(
          metadata <- reexport_portfolio( # nolint: implicit_assignment_linter
            input_filepath = test_file,
            output_directory = test_dir
          ),
          regexp = "^No portfolio data detected in file.$"
        ),
        regexp = "^Object could not be validated against schema.$"
      ),
      regexp = "column could not be determined"
    ),
    regexp = "column could not be determined"
  )
  expect_reexport_failure(
    metadata = metadata,
    input_filename = basename(test_file),
    input_digest = filehash
  )
})

test_that("re-exporting fails with missing columns - market_value", {
  test_dir <- withr::local_tempdir()
  test_file <- withr::local_tempfile(fileext = ".csv")
  write.csv(
    x = dplyr::select(
      .data = simple_portfolio_all_columns,
      -market_value
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
  testthat::expect_warning(
    testthat::expect_warning(
      testthat::expect_warning(
        testthat::expect_warning(
          metadata <- reexport_portfolio( # nolint: implicit_assignment_linter
            input_filepath = test_file,
            output_directory = test_dir
          ),
          regexp = "^No portfolio data detected in file.$"
        ),
        regexp = "^Object could not be validated against schema.$"
      ),
      regexp = "column could not be determined"
    ),
    regexp = "column could not be determined"
  )
  expect_reexport_failure(
    metadata = metadata,
    input_filename = basename(test_file),
    input_digest = filehash
  )
})
