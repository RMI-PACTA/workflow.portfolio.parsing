#' @export
process_directory <- function(
  directory = "/mnt/input"
) {
  # Get the list of files in the directory
  files <- list.files(directory, full.names = TRUE)
  # Process each file
  for (file in files) {
    logger::log_info("Processing file: ", file)
  }
  logger::log_info("Done processing directory.")
}
