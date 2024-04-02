# suppress log messages during testing.
old_threshold <- logger::log_threshold()
withr::defer(logger::log_threshold(old_threshold))
logger::log_threshold("FATAL")

# establish testing tempdir
test_dir <- tempdir()
withr::defer(unlink(test_dir))

test_that("re-exporting simple file works.", {
  test_dir <- withr::local_tempdir()
  test_file <- withr::local_tempfile(fileext = ".csv")
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

test_that("re-exporting exported file yields same file.", {
  test_dir <- withr::local_tempdir()
  test_file <- withr::local_tempfile(fileext = ".csv")
  write.csv(
    x = simple_portfolio_all_columns,
    file = test_file,
    row.names = FALSE,
    quote = FALSE
  )
  metadata_input <- reexport_portfolio(
    input_filepath = test_file,
    output_directory = test_dir
  )
  metadata <- reexport_portfolio(
    input_filepath = file.path(
      test_dir,
      metadata_input[["portfolios"]][[1L]][["output_filename"]]
    ),
    output_directory = test_dir
  )
  expect_simple_reexport(
    output_dir = test_dir,
    metadata = metadata,
    groups = empty_groups,
    input_digest = metadata_input[["portfolios"]][[1L]][["output_md5"]],
    input_filename = metadata_input[["portfolios"]][[1L]][["output_filename"]],
    input_entries = 1L
  )
})

test_that("re-exporting simple file with all columns works", {
  test_dir <- withr::local_tempdir()
  test_file <- withr::local_tempfile(fileext = ".csv")
  write.csv(
    x = simple_portfolio_all_columns,
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

test_that("re-exporting empty file fails.", {
  test_dir <- withr::local_tempdir()
  test_file <- withr::local_tempfile(fileext = ".csv")
  file.create(test_file)
  expect_identical(as.integer(file.size(test_file)), 0L)
  filehash <- digest::digest(
    object = test_file,
    file = TRUE,
    algo = "md5"
  )
  expect_multiple_conditions(
    {
      metadata <- reexport_portfolio(
        input_filepath = test_file,
        output_directory = test_dir
      )
    },
    warning = c(
      "No portfolio data detected in file.",
      "Object could not be validated against schema."
    )
  )
  expect_reexport_failure(
    metadata = metadata,
    input_filename = basename(test_file),
    input_digest = filehash
  )
})

test_that("re-exporting multiportfolio file with all columns works", {
  test_dir <- withr::local_tempdir()
  test_file <- withr::local_tempfile(fileext = ".csv")
  groups <- tibble::tribble(
    ~investor_name, ~portfolio_name,
    "Simple Investor", "Portfolio A",
    "Simple Investor", "Portfolio B"
  )
  multi_port <- dplyr::cross_join(groups, simple_portfolio)
  write.csv(
    x = multi_port,
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
    groups = groups,
    input_digest = filehash,
    input_filename = basename(test_file),
    input_entries = 2L
  )
})
