library(dplyr)

logger::log_info("Loading test data.")
simple_portfolio <- read.csv(
  file = system.file(
    "extdata", "portfolios", "output_simple.csv",
    package = "workflow.portfolio.parsing"
  ),
  stringsAsFactors = FALSE
)

logger::log_info("Generating test data.")
simple_portfolio_all_columns <- simple_portfolio %>%
  mutate(
    portfolio_name = "Simple Portfolio",
    investor_name = "Simple Investor"
  ) %>%
  select(
    investor_name,
    portfolio_name,
    isin,
    market_value,
    currency
  )

logger::log_info("Writing simple full test file.")
simple_portfolio_all_columns %>%
  write.csv(
    file = "simple_all-columns.csv",
    row.names = FALSE,
    quote = FALSE
  )

logger::log_info("Writing minimal simple test file.")
simple_portfolio_all_columns %>%
  select(-investor_name, -portfolio_name) %>%
  write.csv(
    file = "simple.csv",
    row.names = FALSE,
    quote = FALSE
  )

change_colnames <- function(x, colnames) {
  colnames(x) <- colnames
  return(x)
}

#### Playing with headers

logger::log_info("Writing test file with underscores in headers.")
simple_portfolio_all_columns %>%
  write.csv(
    file = "simple_all-columns_headers-underscore.csv",
    row.names = FALSE,
    quote = FALSE
  )

logger::log_info("Writing test file with no headers.")
simple_portfolio_all_columns %>%
  write.table(
    file = "simple_all-columns_headers-none.csv",
    row.names = FALSE,
    col.names = FALSE,
    sep = ",",
    quote = FALSE
  )

logger::log_info("Writing test file with no headers.")
simple_portfolio_all_columns %>%
  select(-investor_name, -portfolio_name) %>%
  write.table(
    file = "simple_headers-none.csv",
    row.names = FALSE,
    col.names = FALSE,
    sep = ",",
    quote = FALSE
  )

# Names as in Mock Portfolio on CTM (mixed dots and camelCase)
logger::log_info("Writing test file with headers in demo format.")
simple_portfolio_all_columns %>%
  change_colnames(
    colnames = c(
      "Investor.Name", "Portfolio.Name", "ISIN", "MarketValue", "Currency"
    )
  ) %>%
  write.csv(
    file = "simple_all-columns_headers-demo.csv",
    row.names = FALSE,
    quote = FALSE
  )

# Dot separated
logger::log_info("Writing test file with dots in headers.")
simple_portfolio_all_columns %>%
  change_colnames(
    colnames = c(
      "Investor.Name", "Portfolio.Name", "ISIN", "Market.Value", "Currency"
    )
  ) %>%
  write.csv(
    file = "simple_all-columns_headers-dot.csv",
    row.names = FALSE,
    quote = FALSE
  )

# space separated
logger::log_info("Writing test file with spaces in headers.")
simple_portfolio_all_columns %>%
  change_colnames(
    colnames = c(
      "Investor Name", "Portfolio Name", "ISIN", "Market Value", "Currency"
    )
  ) %>%
  write.csv(
    file = "simple_all-columns_headers-space.csv",
    row.names = FALSE,
    quote = FALSE
  )

# camelcase
logger::log_info("Writing test file with camelCase headers.")
simple_portfolio_all_columns %>%
  change_colnames(
    colnames = c(
      "investorName", "portfolioName", "isin", "marketValue", "currency"
    )
  ) %>%
  write.csv(
    file = "simple_all-columns_headers-camelcase.csv",
    row.names = FALSE,
    quote = FALSE
  )

# lowercase
logger::log_info("Writing test file with lowercase headers.")
simple_portfolio_all_columns %>%
  change_colnames(
    colnames = c(
      "investorname", "portfolioname", "isin", "marketvalue", "currency"
    )
  ) %>%
  write.csv(
    file = "simple_all-columns_headers-nosep-lowercase.csv",
    row.names = FALSE,
    quote = FALSE
  )

# uppercase separated
logger::log_info("Writing test file with uppercase headers.")
simple_portfolio_all_columns %>%
  change_colnames(
    colnames = c(
      "INVESTORNAME", "PORTFOLIONAME", "ISIN", "MARKETVALUE", "CURRENCY"
    )
  ) %>%
  write.csv(
    file = "simple_all-columns_headers-nosep-uppercase.csv",
    row.names = FALSE,
    quote = FALSE
  )

# space padded
logger::log_info("Writing test file with padded headers.")
simple_portfolio_all_columns %>%
  change_colnames(
    colnames = c(
      " Investor.Name ", " Portfolio.Name ", " ISIN ",
      " MarketValue ", " Currency "
    )
  ) %>%
  write.csv(
    file = "simple_all-columns_headers-padded.csv",
    row.names = FALSE,
    quote = FALSE
  )

# double space padded
logger::log_info("Writing test file with double padded headers.")
simple_portfolio_all_columns %>%
  change_colnames(
    colnames = c(
      "  Investor.Name  ", "  Portfolio.Name  ", "  ISIN  ",
      "  MarketValue  ", "  Currency  "
    )
  ) %>%
  write.csv(
    file = "simple_all-columns_headers-doublepadded.csv",
    row.names = FALSE,
    quote = FALSE
  )

# quoted heades
logger::log_info("Writing test file with quoted headers.")
simple_portfolio_all_columns %>%
  change_colnames(
    colnames = c(
      "\"investor_name\"", "\"portfolio_name\"", "\"isin\"",
      "\"market_value\"", "\"currency\""
    )
  ) %>%
  write.csv(
    file = "simple_all-columns_headers-quoted.csv",
    row.names = FALSE,
    quote = FALSE
  )

# Mix of formats
logger::log_info("Writing test file with mixed format headers.")
simple_portfolio_all_columns %>%
  change_colnames(
    colnames = c(
      "INVESTOR.NAME", "PortfolioName", "isin", "market_value", " Currency"
    )
  ) %>%
  write.csv(
    file = "simple_all-columns_headers-mixed.csv",
    row.names = FALSE,
    quote = FALSE
  )


#### Playing with column order
logger::log_info("Writing test file with reordered columns.")
simple_portfolio_all_columns %>%
  select(rev(everything())) %>%
  write.csv(
    file = "simple_all-columns_reordered.csv",
    row.names = FALSE,
    quote = FALSE
  )

logger::log_info("Writing minimal test file with reordered columns.")
simple_portfolio_all_columns %>%
  select(rev(everything())) %>%
  select(-investor_name, -portfolio_name) %>%
  write.csv(
    file = "simple_reordered.csv",
    row.names = FALSE,
    quote = FALSE
  )

#### Playing with extra columns
logger::log_info("Writing test file with extra columns.")
simple_portfolio_all_columns %>%
  mutate(foo = "bar") %>%
  write.csv(
    file = "simple_all-columns_extra_columns.csv",
    row.names = FALSE,
    quote = FALSE
  )

logger::log_info("Writing minimal test file with extra columns.")
simple_portfolio_all_columns %>%
  mutate(foo = "bar") %>%
  select(-investor_name, -portfolio_name) %>%
  write.csv(
    file = "simple_extra_columns.csv",
    row.names = FALSE,
    quote = FALSE
  )

#### Playing with missing columns
logger::log_info("Writing test file with missing column: investor_name.")
simple_portfolio_all_columns %>%
  select(-investor_name) %>%
  write.csv(
    file = "simple_portfolioname.csv",
    row.names = FALSE,
    quote = FALSE
  )

logger::log_info("Writing test file with missing column: portfolio_name.")
simple_portfolio_all_columns %>%
  select(-portfolio_name) %>%
  write.csv(
    file = "simple_investorname.csv",
    row.names = FALSE,
    quote = FALSE
  )

logger::log_info("Writing test file with missing column: currency.")
simple_portfolio_all_columns %>%
  select(-currency) %>%
  write.csv(
    file = "simple_missing-currency.csv",
    row.names = FALSE,
    quote = FALSE
  )

logger::log_info("Writing test file with missing column: market_value.")
simple_portfolio_all_columns %>%
  select(-market_value) %>%
  write.csv(
    file = "simple_missing-marketvalue.csv",
    row.names = FALSE,
    quote = FALSE
  )

logger::log_info("Writing test file with missing column: isin.")
simple_portfolio_all_columns %>%
  select(-isin) %>%
  write.csv(
    file = "simple_missing-isin.csv",
    row.names = FALSE,
    quote = FALSE
  )

#### Playing with missing rows
logger::log_info("Writing test file with no data.")
simple_portfolio_all_columns %>%
  slice(0) %>%
  write.csv(
    file = "simple_all-columns_empty.csv",
    row.names = FALSE,
    quote = FALSE
  )

logger::log_info("Writing minimal test file with no data.")
simple_portfolio_all_columns %>%
  slice(0) %>%
  select(-investor_name, -portfolio_name) %>%
  write.csv(
    file = "simple_all-columns_empty.csv",
    row.names = FALSE,
    quote = FALSE
  )

#### TODO: Playing with encodings

#### TODO: Playing with missing values
#### TODO: Playing with invalid values
#### TODO: Playing with column types
#### TODO: Playing with Excel exports (BOMs)
#### TODO: Playing with EOL markers (\r\n, \r, \n)
#### TODO: Playing with NA strings (NA, N/A, NULL, "", -, /, etc.)
#### TODO: Playing with rownames (export from R write.csv default)


#### TODO: Playing with multiple portfolios in a file

logger::log_info("Done.")
