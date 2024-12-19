library(dplyr)
library(readr)
library(skimr)
library(ggplot2)
library(tidyverse)

# Define paths for downloading and reading data
raw_data <- "raw_data"
dataset_url <- "https://data.iowa.gov/api/views/qd3t-kfqg/rows.csv?accessType=DOWNLOAD"


# Define file path for dataset
dataset_path <- file.path(raw_data, "Iowa_Economic_Indicators.csv")

#Create raw_data folder if not already created
if (!dir.exists(raw_data)) {
  dir.create(raw_data)
}

# Check if dataset downloaded, if not download
if (!file.exists(dataset_path)) {
  download.file(dataset_url, dataset_path, mode = "wb")
}

# Read the CSV file
Iowa_Economic_Indicators <- read_csv(dataset_path)

# Make sure data is only object in environment
#309 Rows 17 Columns
rm(list = setdiff(ls(),"Iowa_Economic_Indicators"))

print(head(Iowa_Economic_Indicators,5))

print(tail(Iowa_Economic_Indicators,5))

#Wide array of units, all but date are numeric and most are indexes

glimpse(Iowa_Economic_Indicators)

#NA for diffusion indexes is because they need due to the need of prior data
#Profits doesn't specify unit (billions, millions, etc)

skim(Iowa_Economic_Indicators)

#Diesel Fuel Consumption has a large standard deviation, is only column with 8 digits
#Non-Farm Employment Coincident Index stays similar throughout data set
#Agricultural Futures Profits Index has a negative mean

#Add units to agricultural profits
Iowa_Economic_Indicators <- Iowa_Economic_Indicators %>%
  rename(
    `Corn Profits (cents per bushel)`=`Corn Profits`,
    `Soybean Profits (cents per bushel)`=`Soybean Profits`,
    `Cattle Profits (cents per pound)`=`Cattle Profits`,
    `Hog Profits (cents per pound)`=`Hog Profits`
  )

#Make sure changes went through
skim(Iowa_Economic_Indicators)

#Replace problematic spaces with underscores
names(Iowa_Economic_Indicators) <- gsub(" ", "_", names(Iowa_Economic_Indicators))

#Make sure column names were fixed
print(names(Iowa_Economic_Indicators))

#Select key columns
key_columns<-Iowa_Economic_Indicators %>%
  select(
    Month,
    Iowa_Leading_Indicator_Index,
    Avg_Weekly_Unemployment_Claims,
    Residential_Building_Permits,
    Avg_Weekly_Unemployment_Claims,
    Yield_Spread,
    `Diesel_Fuel_Consumption_(Gallons)`,
    Iowa_Stock_Market_Index,
    Agricultural_Futures_Profits_Index,
    `Corn_Profits_(cents_per_bushel)`,
    `Soybean_Profits_(cents_per_bushel)`,
    `Cattle_Profits_(cents_per_pound)`,
    `Hog_Profits_(cents_per_pound)`
  )

#Ensure columns are selected    
print(key_columns)

#Created a new column, Average_Profits, which is the average of the four profit columns
key_columns<-key_columns %>%
  mutate(
    Average_Profits=rowMeans(select(.,`Corn_Profits_(cents_per_bushel)`, 
                                      `Soybean_Profits_(cents_per_bushel)`, 
                                      `Cattle_Profits_(cents_per_pound)`, 
                                      `Hog_Profits_(cents_per_pound)`), 
    )
  )

#Ensure new row was created
print(key_columns$Average_Profits)

#dplyr::filter for missing data
missing_data<-key_columns %>%
  dplyr::filter(if_any(everything(),is.na))

#Print missing values
print(missing_data)

#Saved copy of key_columns
save<-file.path("raw_data","Revised_Iowa_Economic_Indicators.csv")
write.csv(key_columns,save)
cat("Copy was saved at",save)

#I added units to the agricultural profits so that they could be better understood.
#I selected 12 key columns based on their usefulness, the rest were excluded because they either weren't useful or weren't easily understood.
#I created a new column, Average_Profits, which is the average of the four profit columns. My intent was to create a column which better reflected how industry profits were changing.
#I dplyr::filtered out missing data but no action was needed as there were none.

#Find Mean, Median, and Standard Deviation for each column
summary_stat<-key_columns %>%
  summarize(
    across(
      where(is.numeric), 
      list(
        Mean=~mean(.),
        Median=~median(.),
        SD=~sd(.)
      )
    )
  )

glimpse(summary_stat)

#Corn and Soybean Profits: Large difference between mean and median, suggests significant outliers
#Hog and Cattle profits: Normal means and medians suggesting crops are more volatile than animals
#Residential Building Permits: High standard deviation indicates that this variable is volatile, likely due to the effect economic recessions has on the construction industry
#Avg Weekly Unemployment: Similar to residential building, high SD likely caused by the effect economic recessions has on unemployment claims
#Diesel Consumption: High SD, likely due to two factors: the price of oil, and seasonal driving habits (Americans drive less in the winter)
#Stock Market and Agricultural Futures: High SD, suggests that investors have had varied opinions on the economy of Iowa during the length of the report

#The following sections all create different histograms 
ggplot(key_columns,aes(x=Iowa_Leading_Indicator_Index))+
  geom_histogram(binwidth=1)+
  labs(title="Histogram of Iowa Leading Indicator Index", y="Frequency")

ggplot(key_columns,aes(x=Residential_Building_Permits))+
  geom_histogram(binwidth=50)+
  labs(title="Histogram of Residential Building Permits",y="Frequency")

ggplot(key_columns,aes(x=Iowa_Stock_Market_Index))+
  geom_histogram(binwidth=10)+
  labs(title="Histogram of Iowa Stock Market Index",y="Frequency")

#The following sections all create different scatter plots
ggplot(key_columns,aes(x=Average_Profits,y=Iowa_Leading_Indicator_Index))+
  geom_point()+
  labs(title="Scatter plot of Average Profits vs Iowa Leading Indicator Index")

ggplot(key_columns,aes(x=`Corn_Profits_(cents_per_bushel)`,y=`Soybean_Profits_(cents_per_bushel)`))+
  geom_point()+
  labs(title="Scatter plot of Corn Profits vs Soybean Profits")

ggplot(key_columns,aes(x=Avg_Weekly_Unemployment_Claims,y=Residential_Building_Permits))+
  geom_point()+
  labs(title="Scatter plot of Avg Weekly Unenmployment Claims vs Residential Building Permits")



