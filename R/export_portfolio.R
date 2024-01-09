#' @ export
export_portfolio <- function(
  portfolio_data,
  group_data,
  output_directory
) {

  output_rows <- nrow(portfolio_data)

  output_filename <- paste0(
    uuid::UUIDgenerate(),
    ".csv"
  )

  # Write the portfolio data to a file
  output_filepath <- file.path(
    output_directory,
    output_filename
  )

  logger::log_trace("Writing portfolio data to file: ", output_filepath)
  write.csv(
    x = portfolio_data,
    file = output_filepath,
    row.names = FALSE,
    fileEncoding = "UTF-8"
  )
  logger::log_debug("Portfolio data written to file: ", output_filepath)

  output_digest <- digest::digest(
    object = output_filepath,
    file = TRUE,
    algo = "md5",
    serialize = FALSE
  )
  logger::log_trace("Portfolio data digest: ", output_digest)

  browser()

  portfolio_metadata <- list(
    output_digest = output_digest,
    output_filename = output_filename,
    output_rows = output_rows
  )

  return(portfolio_metadata)
}
