#script.R

# install and load necessary packages
if (!requireNamespace("readr", quietly = TRUE)) {
  install.packages("readr")
}
#install dplyr

install.packages("dplyr")
library(dplyr)

#install ggplot2

install.packages("ggplot2")
library(ggplot2)


#load necessary library
library (readr)
  
#define URL for data set 
url<-"https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv"

if(!dir.exists("raw_data")) {
  dir.create("raw_data")
}

#define the local path for downloaded data 
file_path<-"raw_data/taxi_zone_lookup.csv"

#download dataset if not already downloaded 
if (!file.exists(file_path)) {
  download.file(url, destfile = file_path, mode = "wb")
}

#read the CSV file into a data frame 
zone_lookup<-read_csv(file_path)

#remove all other objects except the data frame 
#rm(list = setdiff(ls(), "zone_lookup"))

str(zone_lookup)

compute_frequency <- function(data, Address) {
  # Group by the specified column and compute frequency
  frequency_analysis <- data %>%
    group_by(across(all_of(Address))) %>%  # Group by the specified column
    summarize(Frequency = n(), .groups = "drop") %>%  # Count occurrences
    arrange(desc(Frequency))  # Arrange by descending frequency
  
  return(frequency_analysis)
}


data <- read.csv("raw_data/taxi_zone_lookup.csv")

write.csv(mutate(data, Address = paste(Borough, Zone, sep = " ,")), "taxi_updated.csv", row.names = FALSE)

data <- read.csv("taxi_updated.csv", stringsAsFactors = FALSE)

frequency_result <- compute_frequency(data, "Borough")

# View the result
print(frequency_result)
view(frequency_result)

data <- read.csv(file_path)

ggplot(data, aes(x = Borough)) +
  geom_density() +
  labs(title = "Density Plot of Boroughs", x = "Borough", y = "Density")
renv::snapshot()

