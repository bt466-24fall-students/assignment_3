# Group 3
# Matthew Bodziony, Daniel Choi, Cole Groeneveld

# Load necessary package
library(readr)
library(ggplot2)
library(dplyr)
library(skimr)

if (Sys.info()["sysname"] == "Windows") {
  # For Windows, default Git Bash path (adjust if needed)
  git_bash_path <- "C:/Program Files/Git/git-bash.exe"
  if (!file.exists(git_bash_path)) {
    git_bash_path <- "C:/Program Files (x86)/Git/git-bash.exe"
  }
} else if (Sys.info()["sysname"] == "Darwin") {
  # For macOS, default bash path (Git is usually pre-installed)
  git_bash_path <- "/bin/bash"
} else {
  # For Linux or unknown OS, use default bash
  git_bash_path <- "/bin/bash"
}

# Create raw_data folder
dir.create("./raw_data", recursive = TRUE)

# Write your bash commands and run them  
curl_command <- "curl -L -o ./raw_data/archive.zip https://www.kaggle.com/api/v1/datasets/download/tylermorse/retail-business-sales-20172019"
system(paste(shQuote(git_bash_path), 
             "-c", 
             shQuote(curl_command)), 
       intern = TRUE)

unzip_command <- "unzip -o ./raw_data/archive.zip -d ./raw_data/business_sales"
system(paste(shQuote(git_bash_path), 
             "-c", 
             shQuote(unzip_command)), 
       intern = TRUE)



# Load the dataset
data_frame_name <- read_csv("raw_data/business_sales/business.retailsales.csv")

# Confirm data is loaded
print(head(data_frame_name))


# Initial inspection of the dataset
glimpse(data_frame_name)
head(data_frame_name)
tail(data_frame_name)
skim(data_frame_name)

# Document notable observations
# - The dataset contains 1775 rows and 6 columns
# - The columns contain "Product Type, Net Quantity, Gross Sales, 
# - Discounts, Returns, and Total Net Sales".
# - The Rows contain different product types.
# - There seems to be 8 missing product types which leads to a 99.5% completion rate
# - The missing cases are very unlikely to impact the analysis since 99.5%
# is already completed. In this case we believe removing the missing cases
# would be the best since they are product types instead of numbers so we don't
# know which products are missing.

# Key columns: Product Type and Total Net Sales
selected_data <- data_frame_name %>%
  select(`Product Type`,`Total Net Sales`)

#New column for sales perfomance
data_frame_name <- data_frame_name %>%
  mutate(
    Sales_Performance = case_when(
      `Total Net Sales` > 603 ~ "High",
      `Total Net Sales` > 188 ~ "Medium",
      TRUE ~ "Low"
    )
  )

# Count missing values
missing_counts <- data_frame_name %>%
  summarise(across(everything(), ~sum(is.na(.))))

# Handle missing data by removing rows with missing values)
cleaned_data <- data_frame_name %>%
  filter(complete.cases(.))

# Save the cleaned data
write_csv(cleaned_data, "raw_data/business_sales/cleaned_business_sales.csv")

# Summary statistics
summary_stats <- cleaned_data %>%
  summarise(
    Mean_Sales = mean(`Total Net Sales`, na.rm = TRUE),
    Median_Sales = median(`Total Net Sales`, na.rm = TRUE),
    SD_Sales = sd(`Total Net Sales`, na.rm = TRUE)
  )

# Frequency counts for categorical variables
product_counts <- cleaned_data %>%
  count(`Product Type`)


# Group data by category and summarize sales
product_summary <- cleaned_data %>%
  group_by(`Product Type`) %>%
  summarise(
    Total_Sales = sum(`Total Net Sales`, na.rm = TRUE),
    Average_Sales = mean(`Total Net Sales`, na.rm = TRUE)
  ) %>%
  arrange(desc(Total_Sales))

# observation:
# - "Basket" has the highest frequency count of 551
# - "Easter" and "Gift Basket" has the lowest freuency count of 1
# - "Basket" has the highest Total Sales of 134791.39
# - "Art & Sculpture" has the highest Average Sales of 250.68501


#Density Plot of distribution of Total Net Sales
ggplot(cleaned_data, aes(x = `Total Net Sales`)) +
  geom_density(fill = "blue", alpha = 0.5) +
  labs(title = "Density Plot of Sales", x = "Sales", y = "Density") +
  theme_minimal()

#Bar plot of Product Type
ggplot(cleaned_data, aes(x = `Product Type`)) +
  geom_bar(fill = "darkorange", color = "black") +
  labs(title = "Frequency of Product", x = "Product", y = "Count") +
  theme_minimal()

#Box plot for Prouct type vs Total Net Sales
ggplot(cleaned_data, aes(x = `Product Type`, y = `Total Net Sales`)) +
  geom_boxplot(fill = "purple", color = "black") +
  labs(title = "Sales Distribution by Product", x = "Product", y = "Sales") +
  theme_minimal()




