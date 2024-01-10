test_that("exporting a file works, no grouping", {
  test_dir <- tempdir()
  simple_portfolio <- tibble::tribble(
    ~isin, ~market_value, ~currency,
    "GB0007980591", 10000, "USD"
  )
  simple_groups <- data.frame()
  metadata <- export_portfolio(
    portfolio_data = simple_portfolio,
    group_data = simple_groups,
    output_directory = test_dir
  )
  expect_simple_portfolio_output(output_dir = test_dir, metadata = metadata) 
})

# test_that("exporting works, against reordered columns", {
#   test_dir <- tempdir()
#   simple_portfolio <- tibble::tribble(
#     ~isin, ~currency, ~market_value,
#     "GB0007980591", "USD", 10000
#   )
#   simple_groups <- data.frame()
#   metadata <- export_portfolio(
#     portfolio_data = simple_portfolio,
#     group_data = simple_groups,
#     output_directory = test_dir
#   )
#   expect_simple_portfolio_output(output_dir = test_dir, metadata = metadata) 
# })
