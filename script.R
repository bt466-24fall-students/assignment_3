#script.R

# install and load necessary packages
if (!requireNamespace("readr", quietly = TRUE)) {
  install.packages("readr")
}

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

renv::snapshot()
