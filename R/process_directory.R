#' @export
process_directory <- function(
  input_directory = "/mnt/input",
  output_directory = "/mnt/output"
) {
  # Get the list of files in the directory
  files <- list.files(input_directory, full.names = TRUE)
  # Process each file
  for (file in files) {
    reexport_portfolio(
      input_filepath = file,
      output_directory = output_directory
    )
  }
  logger::log_info("Done processing directory.")
}
