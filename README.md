# workflow.portfolio.parsing
<!-- badges: start -->
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![codecov](https://codecov.io/gh/RMI-PACTA/workflow.portfolio.parsing/graph/badge.svg?token=ewpls5qPVK)](https://codecov.io/gh/RMI-PACTA/workflow.portfolio.parsing)
<!-- badges: end -->

The docker image defined by this repo accepts a directory of portfolios (mounted to `/mnt/input/`, see [Inputs](#inputs)) and exports sanitized versions of those portfolios ready for further processing via PACTA (in `/mnt/output`, see [Outputs](#outputs),)

## Docker Image

The intended method for invoking this workflow is with a Docker container defined by the image in the [Dockerfile](Dockerfile).
GitHub Actions builds the offical image, which is available at: `ghcr.io/rmi-pacta/workflow.portfolio.parsing:main`

Running the workflow from a docker image requires mounting an input and output directory:

```sh

# note that the input mount can have a readonly connection
# You can set logging verbosity via the LOG_LEVEL envvar

docker run --rm \
    --mount type=bind,source="$(pwd)"/input,target=/mnt/input,readonly \
    --mount type=bind,source="$(pwd)"/output,target=/mnt/output \
    --env LOG_LEVEL=TRACE \
    ghcr.io/rmi-pacta/workflow.portfolio.parsing:pr16

```

The container will process any files in the `input` directory, and export any valid portfolios along with a metadata files (see [Outputs](#outputs), below).

## Metadata file (`processed_portfolios.json`)

Along with portfolios (in a standardized `csv` format), the parser exports a metadata file about the parsed inputs, and the exported portfolio files.
The file is in JSON format, and validates against a [JSON Schema in this repository](inst/extdata/schema/parsedPortfolio_0-1-0.json).

The file is array of objects, with the highest level opbects in the array centered around the input files, with the exported files contained in an array with the `portfolio` key  in each input file object.

A simple example of the output file:

```jsonc
[
  {
    "input_filename": "simple.csv",
    "input_md5": "8e84d71c0f3892e34e0d9342cfc91a4d",
    "system_info": {
      "timestamp": "2024-01-31T19:11:56Z",
      "package": "workflow.portfolio.parsing",
      "packageVersion": "0.0.0.9000",
      "RVersion": "4.3.2",
      "dependencies": [
        {
          "package": "digest",
          "version": "0.6.33"
        },
      // ... array elided
      ]
    },
    "input_entries": 1,
    "group_cols": [],
    "subportfolios_count": 1,
    "portfolios": [
      {
        "output_md5": "0f51946d64ef6ee4daca1a6969317cba",
        "output_filename": "be1e7db9-3d7c-4978-9c1c-4eba4ad2cff5.csv",
        "output_rows": 1
      }
    ]
  }
]
```

Note that a input file object may have an `errors` key (exclusive to the `portfolios` key), or `warnings` (not exclusive to `portfolios` or `errors`) which indicates a processing error (or warning).
The `errors` object will be an array with messages which are suitable for presentation to end users.

Here is an example `jq` query to see a simple mapping between input and output files:

```sh

cat output/processed_portfolios.json | jq '
    .[] |
    [{
      input_file: .input_filename,
      output_file: .portfolios[].output_filename
    }]
'

```

## R Package

This repo defines an R Package, `{workflow.portfolio.parsing}`.
The R package structure allows for easy management of dependencies, tests, and access to package files (such as the [JSON Schema](inst/extdata/schema/parsedPortfolio_0-1-0.json)).
Because using the R Package locally not intended as the primary use-case, running locally (beyond development) is technically unsupported, but should not pose any issues.

The package exports functions, but the main entrypoint is `process_directory()`. When called with default arguments, it works as intended for use with the docker image from this repo.

## Inputs

This workflow reads files from a directory (by convention mounted in docker container as `/mnt/input`).
The files must be plain csv files (though they do not need to have a `csv` file extension), parsable by [`pacta.portfolio.import::read_portfolio_csv()`](https://rmi-pacta.github.io/pacta.portfolio.import/reference/read_portfolio_csv.html).
The workflow will attempt to parse other files in that directory, but will throw warnings.
The workflow will not recurse into subdirectories.

## Outputs

This workflow writes files to a directory (by convention mounted in docker container as `/mnt/output`):

- `*.csv`: csv files that contain portfolio data, with columns and column names standardized, 1 portfolio per file.
- `processed_portfolios.json`: A JSON file with metadata about the files, including the input file, as well as file hashes and summary information for both input and output files.
This file validates against the JSON Schema defined in this repository ([found here](inst/extdata/schema/parsedPortfolio_0-1-0.json))
