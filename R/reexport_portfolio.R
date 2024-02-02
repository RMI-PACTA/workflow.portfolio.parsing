#' @export
reexport_portfolio <- function(
  input_filepath,
  output_directory,
  validate = TRUE
) {

  if (length(input_filepath) > 1L) {
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
  input_md5 <- digest::digest(
    object = input_filepath,
    file = TRUE,
    algo = "md5",
    serialize = FALSE
  )
  input_filename <- basename(input_filepath)
  input_entries <- nrow(portfolio_data) #returns NULL if no data

  file_summary <- list(
    input_filename = input_filename,
    input_md5 = input_md5,
    system_info = get_system_info()
  )

  # read_portfolio_csv retruns NA if it cannot process a portfolio
  if (inherits(portfolio_data, "data.frame")) {
    logger::log_trace("Portfolio data detected in file.")

    file_summary[["input_entries"]] <- input_entries

    group_cols_possible <- c("portfolio_name", "investor_name")
    group_cols <- group_cols_possible[
      group_cols_possible %in% names(portfolio_data)
    ]
    file_summary[["group_cols"]] <- group_cols

    grouped_portfolios <- dplyr::group_by(
      .data = portfolio_data,
      dplyr::pick(dplyr::all_of(group_cols))
    )
    subportfolios_count <- nrow(dplyr::group_keys(grouped_portfolios))
    logger::log_trace(subportfolios_count, " portfolios detected in file.")
    file_summary[["subportfolios_count"]] <- subportfolios_count

    if (length(group_cols) > 0L) {
      logger::log_trace(
        "Portfolio data grouped by ", length(group_cols), " cols"
      )
      logger::log_trace(toString(group_cols))
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
    file_summary[["portfolios"]] <- portfolio_summary

    # No warnings or errors detected
    file_summary[["warnings"]] <- NULL
    file_summary[["errors"]] <- NULL

  } else { # no portfolio data detected

    logger::log_warn("Cannot import file: ", input_filepath)
    warning("No portfolio data detected in file.")
    file_summary[["errors"]] <- list(
      "Cannot import portfolio file. Please see documentation."
    )
    file_summary[["warnings"]] <- NULL
    file_summary[["portfolios"]] <- NULL
  }

  if (validate) {
    logger::log_trace("Validating output.")
    schema_serialize(
      object = file_summary,
      reference = "#/items"
    )
  } else {
    logger::log_trace("Skipping JSON validation.")
  }

  logger::log_info("Finished processing file: ", input_filepath)
  return(file_summary)
}
