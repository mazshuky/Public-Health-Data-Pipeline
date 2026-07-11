# Public Health Data Pipeline

Automated retrieval, structuring, and documentation of public health data from open sources — built to support reproducible public health intelligence workflows.

## Overview

This project provides R scripts that automatically fetch, clean, version, and document public health datasets from open APIs. Each script follows a consistent pattern:

1. Request data from a public API
2. Parse and clean the response
3. Save output with a dated filename to a structured folder
4. Update a source documentation sheet automatically

## Repository Structure

```
public-health-data-pipeline/
├── fetch_worldbank.R          # World Bank Open Data retrieval script
├── fetch_who_gho.R            # WHO Global Health Observatory retrieval script
├── README.md
└── data/
    ├── worldbank/
    │   └── life_expectancy_YYYYMMDD.csv
    └── who_gho/
        ├── source_documentation.csv
        └── WHOSIS_000001/
            └── WHOSIS_000001_YYYYMMDD.csv
```

> \*\*Note:\*\* The `data/` folder is excluded from version control via `.gitignore`. Run the scripts locally to generate outputs.

## Data Sources

|Source|Indicator|API|Auth Required|
|-|-|-|-|
|World Bank Open Data|Life expectancy at birth (`SP.DYN.LE00.IN`)|REST/JSON|None|
|WHO Global Health Observatory|Life expectancy at birth (`WHOSIS_000001`)|OData REST|None|

Source metadata (update frequency, access method, known issues) is automatically logged to `data/who_gho/source_documentation.csv` on each run.

## Getting Started
### Prerequisites

* [R](https://cran.r-project.org/) (≥ 4.0)
* [RStudio](https://posit.co/download/rstudio-desktop/) (recommended)

### Install dependencies

Open RStudio and run in the Console:

```r
install.packages(c("httr2", "jsonlite", "readr", "here"))
```

### Run the scripts

Each script is standalone. Run either from RStudio (`Ctrl+Shift+Enter` to source) or from the terminal:

```bash
Rscript fetch_worldbank.R
Rscript fetch_who_gho.R
```

Expected console output:

```
Fetching data from World Bank API...
Records retrieved: 189
Saved to: /your/path/data/worldbank/life_expectancy_20260711.csv
```

## File Naming Convention

All output files follow this pattern:

```
{indicator_or_source}_{YYYYMMDD}.csv
```

Example: `life_expectancy_20260711.csv`

This ensures:

* **Traceability** — every file is tied to the date it was retrieved
* **Non-destructive updates** — re-running a script never overwrites previous pulls
* **Reproducibility** — analysts can reference which snapshot was used in any given report

## Source Documentation

`fetch_who_gho.R` auto-generates and updates a `source_documentation.csv` with the following fields per indicator:

|Field|Description|
|-|-|
|`indicator_code`|WHO/World Bank indicator ID|
|`indicator_name`|Human-readable indicator name|
|`source_url`|API base URL|
|`access_method`|How data is accessed (e.g. OData REST, no auth)|
|`update_frequency`|How often the source publishes new data|
|`last_retrieved`|Date of last successful retrieval|
|`known_issues`|Any gaps, lags, or inconsistencies observed|
|`file_saved`|Filename of the output saved on this run|

## Dependencies

|Package|Purpose|
|-|-|
|`httr2`|HTTP requests to REST/OData APIs|
|`jsonlite`|JSON parsing and flattening|
|`readr`|Fast, consistent CSV read/write|
|`here`|Reproducible relative file paths across environments|

## Extending the Pipeline

To add a new data source:

1. Copy either script as a template
2. Update the `indicator` and `base_url` variables
3. Adjust column selection to match the new API's response structure
4. The folder creation, file naming, and documentation logging will work automatically

## Relevance to Public Health Intelligence

This pipeline was designed with WHO-style data workflows in mind:

* **Multi-source organisation** — each source has its own subfolder, preventing naming collisions across datasets
* **Automated updates** — scripts can be scheduled (e.g. via `cronR` or Task Scheduler) to run on a defined cadence without manual intervention
* **Documentation-first** — source metadata is machine-generated alongside the data, not maintained separately
* **Reproducibility** — `here` package ensures paths resolve correctly regardless of working directory or operating system

