#Loads the readr library tibble dplyr
library(readr)
library(tibble)
library(dplyr)
library(ggplot2)
library(e1071)
library(skimr)

# setting download path as the raw data folder
download_path <- "group_01/raw_data/sales_data.csv"

# storing dataset url in variable
dataset_link <- "https://docs.google.com/spreadsheets/d/e/2PACX-1vRgpIxJreICLSslDONRupncn6mgOC7EoQXprYjsD1Pk5-lE4t7xNFQG2Y14o5iaaWiF1WlrSmVRmaTV/pub?output=csv"




# Download the dataset
download.file(dataset_link, download_path, mode = "wb")



# Read the dataset into a data frame with a clear, concise name
Sales_data <- readr::read_csv(download_path)



#Make sure Sales_data is only object in global environment
rm(download_path, dataset_link)


#Make sure Sales data exists
#if (exists("Sales_data")) {
#  print("Data is loaded.")
#  print(head(Sales_data))  
#} else {
#  stop("sales_data not found")
#}


# Glimpse to view the structure
#glimpse(Sales_data)

#view the first few rows of the dataset
#head(Sales_data)

#view last few rows
#tail(Sales_data)

#Check for missingness
#skim_output <- skimr::skim(Sales_data)
#print(skim_output)

# 2,823 rows and 25 columns, double and character data types 
# 16 character variables and 9 double variables
# Missing data in few columns


# most relevant columns selected
Sales_data_cleaned <- Sales_data %>% 
  select(ORDERDATE, SALES, QUANTITYORDERED, COUNTRY, PRODUCTLINE,
         PRICEEACH, ADDRESSLINE1, CITY, STATE, CUSTOMERNAME, POSTALCODE, PHONE)




#Create new column Total_Revenue that is qordered * priceeach
Sales_data_cleaned <- Sales_data_cleaned %>%
  mutate(TOTAL_REVENUE = QUANTITYORDERED * PRICEEACH)


# Count the total number of blank or missing entries across the entire dataset
total_blank_count <- Sales_data_cleaned %>%
  summarise(across(everything(), ~sum(is.na(.) | . == ""))) %>%
  summarise(total_blanks = sum(.))

# Print the result with the message
cat("Total no. of N/A entries before removing is:", total_blank_count$total_blanks, "\n")

# Remove rows that contain any blank or NA entries
Sales_data_cleaned <- Sales_data_cleaned %>%
  filter_all(all_vars(. != "" & !is.na(.)))




#We've selected only ORDERDATE, SALES, QUANTITYORDERED, COUNTRY, PRODUCTLINE,
#PRICEEACH, ADDRESSLINE1, CITY, STATE, CUSTOMERNAME, POSTALCODE. All other variables were either
#redundant such as address2 or weren't necessary such as Month and year id.
#We then counted no. of blank entries using dplyr functions, then printed it 
#and then removed rows with blank entries


# Summary statistics for numeric columns
numeric_summary <- Sales_data_cleaned %>%
  summarise(
    mean_sales = mean(SALES, na.rm = TRUE),
    median_sales = median(SALES, na.rm = TRUE),
    sd_sales = sd(SALES, na.rm = TRUE),
    mean_quantity = mean(QUANTITYORDERED, na.rm = TRUE),
    median_quantity = median(QUANTITYORDERED, na.rm = TRUE),
    sd_quantity = sd(QUANTITYORDERED, na.rm = TRUE)
  )

# Print the summary statistics
print(numeric_summary)



# Frequency count for categorical variables (e.g., COUNTRY, PRODUCTLINE)
categorical_summary <- Sales_data_cleaned %>%
  group_by(COUNTRY) %>%
  summarise(country_count = n())

# Print frequency counts
print(categorical_summary)


#Detect and print skewness (detect outliars)
sales_skewness <- skewness(Sales_data_cleaned$SALES, na.rm = TRUE)
quantity_skewness <- skewness(Sales_data_cleaned$QUANTITYORDERED, na.rm = TRUE)

cat("Skewness for SALES:", sales_skewness, "\n")
cat("Skewness for QUANTITYORDERED:", quantity_skewness, "\n")


# Visualizations using ggplot2


# Faceted Histogram for Sales by Product Line
print(ggplot(Sales_data_cleaned, aes(x = SALES)) +
        geom_histogram(binwidth = 1000, fill = "blue", color = "black", alpha = 0.7) +
        facet_wrap(~ PRODUCTLINE, scales = "free_y") +
        labs(title = "Distribution of Sales by Product Line", x = "Sales", y = "Frequency"))

# Faceted Density Plot for Quantity Ordered by Product Line
print(ggplot(Sales_data_cleaned, aes(x = QUANTITYORDERED)) +
        geom_density(fill = "green", alpha = 0.5) +
        facet_wrap(~ PRODUCTLINE, scales = "free_y") +
        labs(title = "Density Plot of Quantity Ordered by Product Line", x = "Quantity Ordered", y = "Density"))

# Faceted Bar Plot for Product Line by Country
print(ggplot(Sales_data_cleaned, aes(x = PRODUCTLINE)) +
        geom_bar(fill = "red", color = "black", alpha = 0.7) +
        facet_wrap(~ COUNTRY, scales = "free_y") +
        labs(title = "Frequency of Product Line by Country", x = "Product Line", y = "Count"))

# Faceted Bar Plot for Country by Product Line
print(ggplot(Sales_data_cleaned, aes(x = COUNTRY)) +
        geom_bar(fill = "purple", color = "black", alpha = 0.7) +
        facet_wrap(~ PRODUCTLINE, scales = "free_y") +
        labs(title = "Frequency of Countries by Product Line", x = "Country", y = "Count"))

# Faceted Scatter Plot for Sales vs Quantity Ordered by Country
print(ggplot(Sales_data_cleaned, aes(x = QUANTITYORDERED, y = SALES)) +
        geom_point(alpha = 0.5, color = "darkblue") +
        facet_wrap(~ COUNTRY, scales = "free") +
        labs(title = "Sales vs Quantity Ordered by Country", x = "Quantity Ordered", y = "Sales"))

# Faceted Box Plot for Sales across Different Product Lines and Countries
print(ggplot(Sales_data_cleaned, aes(x = PRODUCTLINE, y = SALES)) +
        geom_boxplot(fill = "yellow", color = "black", alpha = 0.7) +
        facet_wrap(~ COUNTRY, scales = "free_y") +
        labs(title = "Sales Distribution by Product Line and Country", x = "Product Line", y = "Sales"))

# Faceted Histogram for Price Each by Product Line
print(ggplot(Sales_data_cleaned, aes(x = PRICEEACH)) +
        geom_histogram(binwidth = 50, fill = "orange", color = "black", alpha = 0.7) +
        facet_wrap(~ PRODUCTLINE, scales = "free_y") +
        labs(title = "Distribution of Price Each by Product Line", x = "Price Each", y = "Frequency"))

# Faceted Box Plot for Quantity Ordered across Different Product Lines and Countries
print(ggplot(Sales_data_cleaned, aes(x = PRODUCTLINE, y = QUANTITYORDERED)) +
        geom_boxplot(fill = "lightblue", color = "black", alpha = 0.7) +
        facet_wrap(~ COUNTRY, scales = "free_y") +
        labs(title = "Quantity Ordered Distribution by Product Line and Country", x = "Product Line", y = "Quantity Ordered"))




#Advanced data wrangling with dplyr, insights from grouped data
# Total Revenue by Country
revenue_by_country <- Sales_data_cleaned %>%
  group_by(COUNTRY) %>%
  summarise(total_revenue = sum(TOTAL_REVENUE, na.rm = TRUE)) %>%
  arrange(desc(total_revenue))

print(revenue_by_country)


# Total Revenue by Product Line
revenue_by_productline <- Sales_data_cleaned %>%
  group_by(PRODUCTLINE) %>%
  summarise(total_revenue = sum(TOTAL_REVENUE, na.rm = TRUE)) %>%
  arrange(desc(total_revenue))

print(revenue_by_productline)



