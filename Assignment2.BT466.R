# Data Cleaning Script for Taxi Zone Lookup

# Install and load necessary packages
if (!requireNamespace("readr", quietly = TRUE)) install.packages("readr")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
if (!requireNamespace("janitor", quietly = TRUE)) install.packages("janitor")

# Load libraries
library(readr)
library(dplyr)
library(janitor)
library(tidyr)

# Read the dataset
file_path <- "raw_data/taxi_zone_lookup.csv"
zone_lookup <- read_csv(file_path)

# 1. Rename Columns
# Clean column names to be more consistent and readable
zone_lookup_cleaned <- zone_lookup %>%
  clean_names()

# 2. Identify Key Columns & Column Selection
zone_lookup_selected <- zone_lookup_cleaned %>%
  select(
    location_id,   # Unique identifier for each zone
    zone,          # Name of the zone
    borough,       # Borough where the zone is located
    service_zone   # Additional classification of the zone
  )

# 3. Create New Columns
zone_lookup_transformed <- zone_lookup_selected %>%
  mutate(
    # Binary indicator for Manhattan
    is_manhattan = tolower(borough) == "manhattan",
    
    # Length of zone name
    zone_name_length = nchar(zone),
    
    # Categorize service zones
    service_zone_category = case_when(
      tolower(service_zone) == "yellow" ~ "Traditional Taxi",
      tolower(service_zone) == "green" ~ "Green Taxi",
      tolower(service_zone) == "hs" ~ "High-Sensitivity",
      TRUE ~ "Other"
    )
  )

# 4. Handle Missing Data
# Check for missing values
missing_summary <- zone_lookup_transformed %>%
  summarise(across(everything(), ~ sum(is.na(.)))) 

# Print missing value summary
cat("Missing Value Summary:\n")
print(missing_summary)

# Remove rows with missing values (if any)
zone_lookup_final <- zone_lookup_transformed %>%
  drop_na()

# 5. Save a Copy
# Ensure the processed_data directory exists
if(!dir.exists("processed_data")) {
  dir.create("processed_data")
}

# Save the processed dataset
write_csv(zone_lookup_final, "processed_data/zone_lookup_cleaned.csv")

# Documentation of Key Decisions
cat("\nData Cleaning Decision Log:\n",
    "1. Cleaned column names using janitor::clean_names()\n",
    "2. Selected key columns: location_id, zone, borough, service_zone\n",
    "3. Created new columns:\n",
    "   - is_manhattan: Binary indicator of Manhattan zones\n",
    "   - zone_name_length: Length of zone names\n",
    "   - service_zone_category: Categorized service zones\n",
    "4. Checked and removed any rows with missing values\n",
    "5. Saved processed data to processed_data/zone_lookup_cleaned.csv\n")

# Optional: Quick overview of final dataset
print(glimpse(zone_lookup_final))

# Clean up environment
rm(list = setdiff(ls(), "zone_lookup_final"))