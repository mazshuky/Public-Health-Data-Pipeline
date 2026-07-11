# Retrieves data from WHO Global Health Observatory (GHO) OData API
# Indicator: WHOSIS_000001 (Life expectancy at birth)

library(httr2)
library(jsonlite)
library(readr)
library(here)

# Define source
indicator <- "WHOSIS_000001"

# Fetch
cat("Fetching data from WHO GHO API...\n")
response <- request("https://ghoapi.azureedge.net/api") |>
  req_url_path_append(indicator) |>
  req_url_query(
    `$filter` = "SpatialDimType eq 'COUNTRY'",  # countries only, no regions
    `$top`    = 300
  ) |>
  req_timeout(30) |>
  req_retry(max_tries = 3) |>
  req_perform()

cat("Status:", resp_status(response), "\n")

# Parse 
raw_json <- resp_body_string(response)
parsed   <- fromJSON(raw_json, flatten = TRUE)

data <- parsed$value

cat("Columns available:", paste(names(data), collapse = ", "), "\n")

# Select and rename relevant columns
clean <- data[, c("SpatialDim", "TimeDim", "Dim1", "NumericValue")]
colnames(clean) <- c("country_code", "year", "sex", "value")

# Keep only most recent year per country/sex
clean <- clean[order(clean$country_code, clean$sex, -clean$year), ]
clean <- clean[!duplicated(clean[, c("country_code", "sex")]), ]
clean <- clean[!is.na(clean$value), ]

cat("Records after cleaning:", nrow(clean), "\n")
head(clean)

# Save with dated filename 
output_dir <- here("data", "who_gho", indicator)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

filename    <- paste0(indicator, "_", format(Sys.Date(), "%Y%m%d"), ".csv")
output_path <- file.path(output_dir, filename)

write_csv(clean, output_path)
cat("Saved to:", output_path, "\n")

# Write a source documentation record
doc <- data.frame(
  indicator_code  = indicator,
  indicator_name  = "Life expectancy at birth (WHO GHO)",
  source_url      = "https://ghoapi.azureedge.net/api/",
  access_method   = "OData REST API, no authentication",
  update_frequency = "Annual",
  last_retrieved  = as.character(Sys.Date()),
  known_issues    = "Some countries have missing recent years",
  file_saved      = filename
)

doc_path <- here("data", "who_gho", "source_documentation.csv")

# Append to existing doc sheet, or create new
if (file.exists(doc_path)) {
  existing <- read_csv(doc_path, show_col_types = FALSE)
  existing <- existing[existing$indicator_code != indicator, ]  # remove old entry
  doc <- rbind(existing, doc)
}

write_csv(doc, doc_path)
cat("Documentation updated:", doc_path, "\n")