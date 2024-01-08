reexport_portfolio <- function(
  input_filepath,
  output_directory
) {

  if (length(input_filepath) > 1) {
    logger::log_error("Only one filepath can be processed at a time.")
    stop("Only one filepath can be processed at a time.")
  }

  input_digest <- digest::digest(
    object = input_filepath,
    file = TRUE,
    algo = "md5",
    serialize = FALSE
  )

  logger::log_info("Processing file: ", input_filepath)
  portfolio_data <- pacta.portfolio.import::read_portfolio_csv(
    filepaths = input_filepath,
    combine = FALSE
  )
  logger::log_debug("Portfolio data read.")

  if (!("portfolio_name" %in% names(portfolio_data))) {
    logger::log_trace(
      "Portfolio does not contain a portfolio name.",
      " Using filename as export file name."
    )
    filename <- basename(input_filepath)
  }

  # Write the portfolio data to a file
  output_filepath <- file.path(
    output_directory,
    filename
  )
  logger::log_debug("Writing portfolio data to file: ", output_filepath)
  write.csv(
    x = portfolio_data,
    file = output_filepath,
    row.names = FALSE,
    fileEncoding = "UTF-8"
  )
  output_digest <- digest::digest(
    object = output_filepath,
    file = TRUE,
    algo = "md5",
    serialize = FALSE
  )

  portfolio_metadata <- list(
    input_filepath = input_filepath,
    input_digest = input_digest,
    output_filepath = output_filepath,
    output_digest = output_digest
  )

  return(portfolio_metadata)
}
