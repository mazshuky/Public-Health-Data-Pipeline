# Retrieves life expectancy data from the World Bank Open Data API
# Indicator: SP.DYN.LE00.IN (Life expectancy at birth)

library(httr2)
library(jsonlite)
library(readr)
library(here)

# Define source 
indicator  <- "SP.DYN.LE00.IN"   # life expectancy at birth
base_url   <- paste0(
  "https://api.worldbank.org/v2/country/all/indicator/", indicator,
  "?format=json&per_page=500&mrv=1"  # mrv=1 means most recent value only
)

# Fetch 
cat("Fetching data from World Bank API...\n")

response <- request(base_url) |>
  req_perform()

resp_status(response)

# Parse JSON 
raw_json <- resp_body_string(response)
parsed   <- fromJSON(raw_json, flatten = TRUE)

# World Bank wraps data in a list: [[1]] is metadata, [[2]] is the data
data <- parsed[[2]]

# Clean and select columns
clean <- data[, c("country.value", "countryiso3code", "date", "value")]
colnames(clean) <- c("country", "iso3", "year", "life_expectancy")

# Remove rows with no value
clean <- clean[!is.na(clean$life_expectancy), ]

cat("Records retrieved:", nrow(clean), "\n")
head(clean)

# Save with dated filename
# Create output folder if it doesn't exist
output_dir <- here("data", "worldbank")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

filename <- paste0("life_expectancy_", format(Sys.Date(), "%Y%m%d"), ".csv")
output_path <- file.path(output_dir, filename)

write_csv(clean, output_path)
cat("Saved to:", output_path, "\n")