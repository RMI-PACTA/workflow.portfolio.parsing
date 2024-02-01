#' @export
process_directory <- function(
  input_directory = "/mnt/input",
  output_directory = "/mnt/output",
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

  return(all_summaries)
}
