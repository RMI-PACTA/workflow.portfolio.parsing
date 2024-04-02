# suppress log messages during testing.
old_threshold <- logger::log_threshold()
withr::defer(logger::log_threshold(old_threshold))
logger::log_threshold("FATAL")

json_validator <- jsonvalidate::json_schema[["new"]](
  schema = system.file(
    "extdata", "schema", "parsedPortfolio_0-1-0.json",
    package = "workflow.portfolio.parsing"
  ),
  strict = TRUE,
  engine = "ajv"
)

test_that("Processing a directory with a single file works.", {
  test_dir <- withr::local_tempdir()
  input_dir <- withr::local_tempdir(pattern = "input")
  test_file <- withr::local_tempfile(fileext = ".csv", tmpdir = input_dir)
  write.csv(
    x = simple_portfolio,
    file = test_file,
    row.names = FALSE,
    quote = FALSE
  )
  filehash <- digest::digest(
    object = test_file,
    file = TRUE,
    algo = "md5"
  )

  metadata <- process_directory(
    input_directory = input_dir,
    output_directory = test_dir
  )
  expect_simple_reexport(
    output_dir = test_dir,
    metadata = metadata[[1L]],
    groups = empty_groups,
    input_digest = filehash,
    input_filename = basename(test_file),
    input_entries = 1L
  )
  metadata_file <- file.path(test_dir, "processed_portfolios.json")
  expect_true(file.exists(metadata_file))
  expect_true(json_validator[["validate"]](
    json =  metadata_file,
    verbose = TRUE
  ))
})

test_that("Processing a directory with a multiple files works.", {
  test_dir <- withr::local_tempdir()
  input_dir <- withr::local_tempdir(pattern = "input")
  test_file <- withr::local_tempfile(
    fileext = ".csv",
    tmpdir = input_dir,
    pattern = "portfolio1"
  )
  write.csv(
    x = simple_portfolio,
    file = test_file,
    row.names = FALSE,
    quote = FALSE
  )
  filehash <- digest::digest(
    object = test_file,
    file = TRUE,
    algo = "md5"
  )

  test_file2 <- withr::local_tempfile(
    fileext = ".csv",
    tmpdir = input_dir,
    pattern = "portfolio2"
  )
  write.csv(
    x = simple_portfolio_all_columns,
    file = test_file2,
    row.names = FALSE,
    quote = FALSE
  )
  filehash2 <- digest::digest(
    object = test_file2,
    file = TRUE,
    algo = "md5"
  )

  metadata <- process_directory(
    input_directory = input_dir,
    output_directory = test_dir
  )

  expect_simple_reexport(
    output_dir = test_dir,
    metadata = metadata[[1L]],
    groups = empty_groups,
    input_digest = filehash,
    input_filename = basename(test_file),
    input_entries = 1L
  )
  expect_simple_reexport(
    output_dir = test_dir,
    metadata = metadata[[2L]],
    groups = simple_groups,
    input_digest = filehash2,
    input_filename = basename(test_file2),
    input_entries = 1L
  )
  metadata_file <- file.path(test_dir, "processed_portfolios.json")
  expect_true(file.exists(file.path(test_dir, "processed_portfolios.json")))
  expect_true(json_validator[["validate"]](
    json =  metadata_file,
    verbose = TRUE
  ))
})
