#' re-export a directory of PACTA portfolios in a standard format
#'
#' This function takes a directory containing pacta portfolios as a file, and
#' exports them to a csv file in `output_directory`. optionally (default on),
#' it can validate the metadata that will be attached to this file export.
#'
#' @param input_directory path to directory with input files
#' @param output_directory character with the directory where the file will be
#' @param validate logical, should the output be validated against the schema?
#'
#' @return portfolio metadata (as nested list) for exported files, primarily
#' called for side effect of writing files to disk.
#' @export
process_directory <- function(
  input_directory = "/mnt/input", # nolint: nonportable_path_linter
  output_directory = "/mnt/output", # nolint: nonportable_path_linter
  validate = TRUE
) {
  # Get the list of files in the directory
  files <- list.files(input_directory, full.names = TRUE)
  # Process each file
  all_summaries <- list()
  for (file in files) {
    portfolio_summary <- reexport_portfolio(
      input_filepath = file,
      output_directory = output_directory
    )
    all_summaries <- c(all_summaries, list(portfolio_summary))
  }
  logger::log_info("Done processing directory.")

  logger::log_info("Preparing metadata JSON file.")
  if (validate) {
    logger::log_info("Validating output.")
    summaries_json <- schema_serialize(all_summaries)
  } else {
    logger::log_warn("Skipping JSON validation.")
    summaries_json <- jsonlite::toJSON(
      x = all_summaries,
      pretty = TRUE,
      auto_unbox = TRUE
    )
  }

  metadata_path <- file.path(output_directory, "processed_portfolios.json")
  logger::log_info("Writing metadata JSON to file \"", metadata_path, "\".")
  writeLines(summaries_json, metadata_path)
  logger::log_debug("Metadata JSON file written.")

  return(invisible(all_summaries))
}
