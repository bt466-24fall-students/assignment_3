
library(readr)

# Define paths for downloading and reading data
raw_data <- "raw_data"
dataset_url <- "https://data.iowa.gov/api/views/qd3t-kfqg/rows.csv?accessType=DOWNLOAD"


# Define file path for dataset
dataset_path <- file.path(raw_data, "Iowa_Economic_Indicators.csv")

# Check if dataset downloaded, if not download
if (!file.exists(dataset_path)) {
  download.file(dataset_url, dataset_path, mode = "wb")
}

# Read the CSV file
Iowa_Economic_Indicators <- read_csv(dataset_path)

# Make sure data is only object in environment
rm(list = setdiff(ls(), "Iowa_Economic_Indicators"))

# Print first 5 rows of dataset to make sure script is working
print(head(Iowa_Economic_Indicators, 5))

