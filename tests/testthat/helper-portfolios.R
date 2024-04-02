# Utility functions
change_colnames <- function(x, colnames) {
  colnames(x) <- colnames
  return(x)
}

# Groups
empty_groups <- data.frame()

simple_groups <- tibble::tribble(
  ~investor_name, ~portfolio_name,
  "Simple Investor", "Simple Portfolio"
)

# Portfolios
simple_portfolio <- tibble::tribble(
  ~isin, ~market_value, ~currency,
  "GB0007980591", 10000L, "USD"
)

simple_portfolio_all_columns <- dplyr::select(
  .data = dplyr::mutate(
    .data = simple_portfolio,
    portfolio_name = "Simple Portfolio",
    investor_name = "Simple Investor"
  ),
  investor_name,
  portfolio_name,
  isin,
  market_value,
  currency
)
