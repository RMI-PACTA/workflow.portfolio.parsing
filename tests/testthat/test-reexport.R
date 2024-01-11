# suppress log messages during testing.
old_threshold <- logger::log_threshold()
withr::defer(logger::log_threshold(old_threshold))
logger::log_threshold("FATAL")

# establish testing tempdir
test_dir <- tempdir()
withr::defer(unlink(test_dir))

empty_groups <- data.frame()

test_that("re-exporting simple exported file yields same file.", {
  test_file <- system.file(
    "extdata", "portfolios", "simple_output.csv",
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
