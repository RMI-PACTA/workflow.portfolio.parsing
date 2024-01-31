schema_serialize <- function(
  object,
  schema_file = system.file(
    "extdata", "schema", "metadata.json",
    package = "workflow.portfolio.parsing"
  ),
  reference = NULL
) {
  sch <- jsonvalidate::json_schema[["new"]](
    schema = readLines(schema_file),
    strict = TRUE,
    engine = "ajv",
    reference = reference
  )
  json <- sch[["serialise"]](object)
  json_is_valid <- sch[["validate"]](json, verbose = TRUE)
  if (json_is_valid) {
    logger::log_trace("JSON is valid.")
  } else {
    json_errors <- attributes(json_is_valid)[["errors"]]
    logger::log_warn(
      "object could not be validated against ",
      "JSON schema: \"", schema_file, "\",",
      " reference: \"", reference, "\"."
    )
    logger::log_trace(
      logger::skip_formatter(paste("JSON string: ", json))
    )
    logger::log_trace("Validation errors:")
    for (i in seq(from = 1L, to = nrow(json_errors), by = 1L)) {
      logger::log_trace(
        "instancePath: ", json_errors[i, "instancePath"],
        " message: ", json_errors[i, "message"]
      )
    }
    warning("Object could not be validated against schema.")
  }
  return(json)
}
