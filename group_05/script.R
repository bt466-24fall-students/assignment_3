#Assignment 1
# Path to Git Bash on your computer
#!!Use git_bash_path <- "C:/Program Files/Git/git-bash.exe" instead if you're on Windows!!
git_bash_path <- "/bin/bash"
# Define the Kaggle dataset URL and file paths
kaggle_url <- "https://www.kaggle.com/api/v1/datasets/download/taseermehboob9/salary-dataset-of-business-levels"
output_dir <- "./raw_data"
zip_file <- file.path(output_dir, "archive.zip")

#Create folder "raw_data" if not exists
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# CURL command for downloading the dataset
curl_command <- sprintf("curl -L -o %s %s", shQuote(zip_file), shQuote(kaggle_url))

# Run the CURL command
system(paste(shQuote(git_bash_path), "-c", shQuote(curl_command)), intern = TRUE)

# Unzip command
unzip_command <- sprintf("unzip -o %s -d %s", shQuote(zip_file), shQuote(output_dir))

# Run the Unzip command
system(paste(shQuote(git_bash_path), "-c", shQuote(unzip_command)), intern = TRUE)

# Load the dataset
# Install required library
library(readr)

# Define a path to the csv file
salary_csv <- file.path(output_dir, "salary.csv")

# Reads the data from the salary_csv file into the R environment as a data frame
salary_df <- read_csv(salary_csv)

# Display first few rows of the dataframe
print(head(salary_df))


#Assignment 2

#LOAD & INPSECT
# Load necessary libraries
library(dplyr)  # For data manipulation
library(skimr)  # For detailed summary

# Glimpse the dataset to see structure and data types
glimpse(salary_df)

# View the first few rows of the dataset
head(salary_df)

# View the last few rows of the dataset
tail(salary_df)

# Use skimr to provide a detailed overview of the dataset
skim(salary_df)

#Comments on the dataset
print("Observations:
The dataset has 10 rows and 3 columns: Position (characters), Level (numeric) and Salary (numeric). 
Some examples of the Positions, as revealed by head() and tail(), are Business Analyst, Junior Consultant, Manager, etc. The rows are organized in the order of increasing position level, with the lowest level is Business Analyst and highest level position is CEO.
There are no missing values detected.
")

#CLEANING
# Step 1: Rename Columns
# Standardize column names: make them lowercase, replace spaces with underscores, and remove special characters
salary_df <- salary_df %>% 
  rename_all(~ gsub("[[:space:]]+", "_", .) %>% 
               gsub("[^[:alnum:]_]", "", .) %>% 
               tolower())

# Step 3: Create New Columns
# Add a column for the percentage increase in salary from one level below
salary_df <- salary_df %>% 
  arrange(level) %>% 
  mutate(salary_increase_percent = case_when(
    !is.na(lag(level)) & level != lag(level) ~ (salary - lag(salary)) / lag(salary) * 100, .default = 0
  ))

# Step 4: Handle Missing Data
# Check for missing values
missing_counts <- salary_df %>% 
  summarise_all(~ sum(is.na(.)))
print(missing_counts)

#To-do: Add a function to remove any row with NaN values


#Step 6: Save df as a new copy
write.csv(salary_df, "./raw_data/salary_cleaned.csv")

#Key Decisions: 
#We did not remove any columns since they are all important
#Renamed the columns into standardized names
#Created a column of % increase of salary from the level below to see how salaries change when moving up the level scale.
#Included functions to identify and remove rows with NaN values, however, this df did not have any NaN values.

#Summarize mean, median, and standard deviation for numeric columns
numeric_summary <- salary_df %>%
  summarize(
    mean_salary = mean(salary, na.rm = TRUE),
    median_salary = median(salary, na.rm = TRUE),
    sd_salary = sd(salary, na.rm = TRUE),
    mean_level = mean(level, na.rm = TRUE),
    median_level = median(level, na.rm = TRUE),
    sd_level = sd(level, na.rm = TRUE)
  )
print("Numeric Summary:")
print(numeric_summary)

# Compute frequency counts for categorical variables by position
categorical_summary <- salary_df %>%
  group_by(position) %>%
  summarize(count = n(), .groups = "drop")

print("Categorical Summary:")
print(categorical_summary)

# Data summarization identify trends
print("The trend between level/position and salary is positive.
      The increase in salary is fairly linear, but there is an extreme outlier for a CEO's salary.")

#Plots
#Number 1:Univariate - Bar plot
#Creates line breaks for positions with two words
salary_df$position <- gsub(" ", "\n", salary_df$position)

barplot(salary_df$salary,
     names.arg = salary_df$position,
     main = "Salary by Position",
     xlab = "Position",
     ylab = "Salary",
     col = "lightblue",
     border = "black",
     las = 1,            # Keeps y numbers horizontal
     cex.names = 0.55,   # Adjust text size for x-axis labels
     cex.axis = 0.6,     # Adjust axis number text size
     space = 1
     )
#Prevent scientific notation for y-axis (Salary)
options(scipen = 999)

#Number 2: Bivariate - Scatter plot
plot(salary_df$level, salary_df$salary,
     main = "Salary vs Level",
     xlab = "Level",
     ylab = "Salary",
     pch = 19,
     col = "pink",
     las = 1,
     cex = 1.5,     
     cex.axis = 0.75,     
     cex.lab = 1.2,
        )

#Advanced Data Wrangling:
#Use dplyr functions to derive insights from grouped or filtered subsets of data.

# Create Salary Groups with Ordered Levels
salary_df <- salary_df %>%
  mutate(
    salary_group = case_when(
      salary < 50000 ~ "Low",
      salary >= 50000 & salary < 100000 ~ "Medium",
      salary >= 100000 ~ "High"
    ),
    salary_group = factor(salary_group, levels = c("High", "Medium", "Low"))
  )

# Group by Salary Group and Derive Insights
grouped_summary <- salary_df %>%
  group_by(salary_group) %>%
  summarize(
    avg_salary = mean(salary, na.rm = TRUE),
    min_salary = min(salary, na.rm = TRUE),
    max_salary = max(salary, na.rm = TRUE),
    avg_level = mean(level, na.rm = TRUE),
    count = n(),
    .groups = "drop"
  ) %>%
  arrange(salary_group)  # Ensure the rows are ordered as per salary_group levels

print("Grouped Summary by Salary Group:")
print(grouped_summary)

# Additional Insights: Salary Increase Percentage by Group
salary_increase_summary <- salary_df %>%
  group_by(salary_group) %>%
  summarize(
    avg_salary_increase = mean(salary_increase_percent, na.rm = TRUE),
    max_salary_increase = max(salary_increase_percent, na.rm = TRUE),
    min_salary_increase = min(salary_increase_percent, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(salary_group)  # Ensure the rows are ordered as per salary_group levels

print("Salary Increase Insights by Salary Group:")
print(salary_increase_summary)

# Optional: Bar Plot for Average Salary by Group
library(ggplot2)

ggplot(grouped_summary, aes(x = salary_group, y = avg_salary, fill = salary_group)) +
  geom_bar(stat = "identity", color = "black") +
  labs(
    title = "Average Salary by Salary Group",
    x = "Salary Group",
    y = "Average Salary"
  ) +
  theme_minimal() +
  scale_fill_manual(values = c("High" = "darkblue", "Medium" = "blue", "Low" = "lightblue"))

#Assignment 3



