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
  test_file <- system.file(
    "extdata", "portfolios", "simple.csv",
    package = "workflow.portfolio.parsing"
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
  test_file <- system.file(
    "extdata", "portfolios", "output_simple.csv",
    package = "workflow.portfolio.parsing"
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

test_that("re-exporting robust against column order.", {
  test_file <- system.file(
    "extdata", "portfolios", "simple_reordered.csv",
    package = "workflow.portfolio.parsing"
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

# TODO: re-enable these tests once we have a way to handle
if (FALSE) {
  test_that("re-exporting simple file with only portfolio name", {
    test_file <- system.file(
      "extdata", "portfolios", "simple_portfolioname.csv",
      package = "workflow.portfolio.parsing"
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
      ~portfolio_name,
      "Simple Portfolio"
    )
    expect_simple_reexport(
      output_dir = test_dir,
      metadata = metadata,
      groups = groups,
      input_digest = filehash,
      input_filename = basename(test_file),
      input_entries = 1
    )
  })

  test_that("re-exporting simple file with only investor name works", {
    test_file <- system.file(
      "extdata", "portfolios", "simple_investorname.csv",
      package = "workflow.portfolio.parsing"
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
      ~investor_name,
      "Simple Investor"
    )
    expect_simple_reexport(
      output_dir = test_dir,
      metadata = metadata,
      groups = groups,
      input_digest = filehash,
      input_filename = basename(test_file),
      input_entries = 1
    )
  })
}

test_that("re-exporting simple file with all columns works", {
  test_file <- system.file(
    "extdata", "portfolios", "simple_all-columns.csv",
    package = "workflow.portfolio.parsing"
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

test_that("re-exporting robust against column order - simple.", {
  test_file <- system.file(
    "extdata", "portfolios", "simple_reordered.csv",
    package = "workflow.portfolio.parsing"
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

test_that("re-exporting robust against column order - all columns.", {
  test_file <- system.file(
    "extdata", "portfolios", "simple_all-columns_reordered.csv",
    package = "workflow.portfolio.parsing"
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
    "Simple Investor", "Simple Portfolio"
  )
  expect_simple_reexport(
    output_dir = test_dir,
    metadata = metadata,
    groups = groups,
    input_digest = filehash,
    input_filename = basename(test_file),
    input_entries = 1
  )
})

test_that("re-exporting empty file fails.", {
  test_file <- system.file(
    "extdata", "portfolios", "simple_all-columns_empty.csv",
    package = "workflow.portfolio.parsing"
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
  test_file <- system.file(
    "extdata", "portfolios", "multi_simple_all-columns_portfolioname.csv",
    package = "workflow.portfolio.parsing"
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
