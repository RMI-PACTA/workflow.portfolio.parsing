#' @export
process_directory <- function(
  input_directory = "/mnt/input",
  output_directory = "/mnt/output",
  validate = TRUE,
  schema_file = system.file(
    "extdata", "schema", "metadata.json",
    package = "workflow.portfolio.parsing"
  )
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
    sch <- jsonvalidate::json_schema[["new"]](
      schema = schema_file,
      strict = TRUE,
      engine = "ajv"
    )
    summaries_json <- jsonlite::prettify(
      sch[["serialise"]](all_summaries)
    )
    json_is_valid <- sch[["validate"]](summaries_json, verbose = TRUE)
    if (json_is_valid) {
      logger::log_debug("JSON is valid.")
    } else {
      logger::log_error("JSON is not valid.")
    }
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
