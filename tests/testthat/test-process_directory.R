# suppress log messages during testing.
old_threshold <- logger::log_threshold()
withr::defer(logger::log_threshold(old_threshold))
logger::log_threshold("FATAL")

empty_groups <- data.frame()
simple_groups <- tibble::tribble(
  ~investor_name, ~portfolio_name,
  "Simple Investor", "Simple Portfolio"
)

test_that("Processing a directory with a single file works.", {
  test_file <- testthat::test_path(
    "testdata", "portfolios", "simple.csv"
  )
  filehash <- digest::digest(
    object = test_file,
    file = TRUE,
    algo = "md5"
  )
  input_dir <- tempfile("input")
  dir.create(input_dir)
  withr::defer(unlink(input_dir))
  output_dir <- tempfile("output")
  dir.create(output_dir)
  withr::defer(unlink(output_dir))
  file.copy(
    from = test_file,
    to = file.path(input_dir, "foo.csv")
  )
  metadata <- process_directory(
    input_directory = input_dir,
    output_directory = output_dir
  )
  expect_simple_reexport(
    output_dir = output_dir,
    metadata = metadata[[1]],
    groups = empty_groups,
    input_digest = filehash,
    input_filename = "foo.csv",
    input_entries = 1L
  )
  expect_true(file.exists(file.path(output_dir, "processed_portfolios.json")))
})

test_that("Processing a directory with a multiple files works.", {
  test_file <- testthat::test_path(
    "testdata", "portfolios", "simple.csv"
  )
  filehash <- digest::digest(
    object = test_file,
    file = TRUE,
    algo = "md5"
  )
  input_dir <- tempfile("input")
  dir.create(input_dir)
  withr::defer(unlink(input_dir))
  output_dir <- tempfile("output")
  dir.create(output_dir)
  withr::defer(unlink(output_dir))
  file.copy(
    from = test_file,
    to = file.path(input_dir, "foo1.csv")
  )
  file.copy(
    from = test_file,
    to = file.path(input_dir, "foo2.csv")
  )
  metadata <- process_directory(
    input_directory = input_dir,
    output_directory = output_dir
  )
  expect_simple_reexport(
    output_dir = output_dir,
    metadata = metadata[[1]],
    groups = empty_groups,
    input_digest = filehash,
    input_filename = "foo1.csv",
    input_entries = 1L
  )
  expect_simple_reexport(
    output_dir = output_dir,
    metadata = metadata[[2]],
    groups = empty_groups,
    input_digest = filehash,
    input_filename = "foo2.csv",
    input_entries = 1L
  )
  expect_true(file.exists(file.path(output_dir, "processed_portfolios.json")))
})
