# suppress log messages during testing.
old_threshold <- logger::log_threshold()
withr::defer(logger::log_threshold(old_threshold))
logger::log_threshold("FATAL")

# establish testing tempdir
test_dir <- tempdir()
withr::defer(unlink(test_dir))

empty_groups <- data.frame()
simple_groups <- tibble::tribble(
  ~investor_name, ~portfolio_name,
  "Simple Investor", "Simple Portfolio"
)

test_that("re-exporting simple file works.", {
  test_file <- testthat::test_path(
    "testdata", "portfolios", "simple.csv"
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
    input_entries = 1
  )
})

test_that("re-exporting simple exported file yields same file.", {
  test_file <- testthat::test_path(
    "testdata", "portfolios", "output_simple.csv"
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
    input_entries = 1
  )
})

test_that("re-exporting simple file with all columns works", {
  test_file <- testthat::test_path(
    "testdata", "portfolios", "simple_all-columns.csv"
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
    input_entries = 1
  )
})

test_that("re-exporting empty file fails.", {
  skip() #TODO: enable this test
  test_file <- testthat::test_path(
    "testdata", "portfolios", "simple_all-columns_empty.csv"
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
  expect_reexport_failure(
    metadata = metadata,
    input_filename = basename(test_file),
    input_digest = filehash
  )
})

test_that("re-exporting multiportfolio file with all columns works", {
  test_file <- testthat::test_path(
    "testdata", "portfolios", "multi_simple_all-columns_portfolioname.csv"
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
  groups <- tibble::tribble(
    ~investor_name, ~portfolio_name,
    "Simple Investor", "Portfolio A",
    "Simple Investor", "Portfolio B"
  )
  expect_simple_reexport(
    output_dir = test_dir,
    metadata = metadata,
    groups = groups,
    input_digest = filehash,
    input_filename = basename(test_file),
    input_entries = 2
  )
})
