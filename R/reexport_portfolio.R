#' @export
reexport_portfolio <- function(
  input_filepath,
  output_directory
) {

  if (length(input_filepath) > 1) {
    logger::log_error("Only one filepath can be processed at a time.")
    stop("Only one filepath can be processed at a time.")
  }
  logger::log_info("Processing file: ", input_filepath)

  logger::log_trace("Reading portfolio data.")
  portfolio_data <- pacta.portfolio.import::read_portfolio_csv(
    filepaths = input_filepath,
    combine = FALSE
  )
  logger::log_debug("Portfolio data read.")

  logger::log_trace("Indentifying portfolio metadata.")
  input_digest <- digest::digest(
    object = input_filepath,
    file = TRUE,
    algo = "md5",
    serialize = FALSE
  )
  input_filename <- basename(input_filepath)
  input_entries <- nrow(portfolio_data)

  group_cols_poss <- c("portfolio_name", "investor_name")
  group_cols <- group_cols_poss[group_cols_poss %in% names(portfolio_data)]

  grouped_portfolios <- dplyr::group_by(
    .data = portfolio_data,
    dplyr::pick(group_cols)
  )
  if (identical(group_cols, character(0))) {
  } else {
    logger::log_trace("Portfolio data grouped by: ", length(group_cols))
  }

  logger::log_trace("Exporting portfolio data.")
  portfolio_summary <- dplyr::group_map(
    .data = grouped_portfolios,
    .f = ~ export_portfolio(
      portfolio_data = .x,
      group_data = .y,
      output_directory = output_directory
    )
  )

  logger::log_trace("Adding file information to portfolio metadata.")
  full_portfolio_summary <- purrr::map(
    .x = portfolio_summary,
    .f = function(x) {
      x$input_digest <- input_digest
      x$input_filename <- input_filename
      x$input_filename <- input_filename
      x$input_entries <- input_entries
      x$group_cols <- group_cols
      return(x)
    }
  )

  logger::log_info("Finished with file: ", input_filepath)
  return(full_portfolio_summary)
}
