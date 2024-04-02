#' export a PACTA portfolio in a standard format
#'
#' This function takes a pacta portfolio as a data frame, and exports it to a
#' csv file in `output_directory`. optionally (default on), it can validate the
#' metadata that will be attached to this file export.
#'
#' @param portfolio_data data frame with the portfolio data
#' @param group_data list or data frame with the group data
#' @param output_directory character with the directory where the file will be
#' @param validate logical, should the output be validated against the schema?
#'
#' @return portfolio metadata (as nested list) for exported file, pramirly
#' called for side effect of writing file to disk.
#' @export
export_portfolio <- function(
  portfolio_data,
  group_data,
  output_directory,
  validate = TRUE
) {

  logger::log_trace("cleaning and rearranging data prior to export")
  output_cols <- c("isin", "market_value", "currency")
  extra_cols <- setdiff(colnames(portfolio_data), output_cols)
  if (length(extra_cols)) {
    logger::log_warn(
      "Extra columns detected in portfolio data: ",
      extra_cols,
      " Discarding."
    )
    warning("Extra columns detected in portfolio data. Discarding.")
  }
  missing_cols <- setdiff(output_cols, colnames(portfolio_data))
  if (length(missing_cols)) {
    logger::log_warn(
      "Missing columns detected in portfolio data: ",
      missing_cols
    )
    stop("Missing columns detected in portfolio data.")
  }

  portfolio_data <- dplyr::select(
    .data = portfolio_data,
    dplyr::all_of(output_cols)
  )

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
  utils::write.csv(
    x = portfolio_data,
    file = output_filepath,
    row.names = FALSE,
    na = "",
    fileEncoding = "UTF-8"
  )
  logger::log_debug("Portfolio data written to file: ", output_filepath)

  output_md5 <- digest::digest(
    object = output_filepath,
    file = TRUE,
    algo = "md5",
    serialize = FALSE
  )
  logger::log_trace("Portfolio data digest: ", output_md5)

  portfolio_metadata <- c(
    list(
      output_md5 = output_md5,
      output_filename = output_filename,
      output_rows = output_rows
    ),
    as.list(group_data)
  )

  if (validate) {
    logger::log_trace("Validating output.")
    schema_serialize(
      object = list(portfolio_metadata),
      reference = "#/items/properties/portfolios" # nolint: nonportable_path_linter
    )
  } else {
    logger::log_trace("Skipping JSON validation.")
  }

  return(portfolio_metadata)
}
