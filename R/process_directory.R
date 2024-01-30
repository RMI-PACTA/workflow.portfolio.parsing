#' @export
process_directory <- function(
  input_directory = "/mnt/input",
  output_directory = "/mnt/output"
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
  return(all_summaries)
}
