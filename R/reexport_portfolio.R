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
    dplyr::pick(dplyr::all_of(group_cols))
  )
  subportfolios_count <- nrow(dplyr::group_keys(grouped_portfolios))
    logger::log_warn(subportfolios_count, " portfolios detected in file.")
  if (length(group_cols) > 0) {
    logger::log_trace("Portfolio data grouped by ", length(group_cols), " cols")
    logger::log_trace(paste(group_cols, collapse = ", "))
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
      x[["input_digest"]] <- input_digest
      x[["input_filename"]] <- input_filename
      x[["input_entries"]] <- input_entries
      x[["subportfolios_count"]] <- subportfolios_count
      x[["group_cols"]] <- group_cols
      return(x)
    }
  )

  logger::log_info("Finished processing file: ", input_filepath)
  return(full_portfolio_summary)
}
