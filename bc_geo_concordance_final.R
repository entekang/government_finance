# INFO
#====
# Script to compare and construct an concordance between BC municipality
# administrative names and Statistics Canada CSD names / uids.

#====

# SET UP
#----

# Libraries
if(!require("dplyr")) install.packages("dplyr")
library(dplyr)

if(!require("readxl")) install.packages("readxl")
library(readxl)
library(tidyverse)
library(stringr)
library(tidyr)

# Read in BC CSD index
csd_index <- read.csv(
  "aux_tables/bc/bc_stats_can_csd_index.csv",
  header = TRUE
)

# Read in data file manifest
manifest <- read.csv(
  "aux_tables/bc/bc_data_manifest.csv"
)

#----

# GRAB NAMES BY YEAR
#----

start_year <- 2005
end_year <- 2019
years <- start_year:end_year
sched <- "201"

filenames <- vector(mode = "character", length = 0)
for(i in 1:length(years)){
  filenames[i] <- manifest$filename[
    manifest$year == years[i] & manifest$sched_num == sched
  ]
}

munis_union <- c()
munis_intersect <- c()
munis_combined_union <- c()
munis_combined_intersect <- c()

for(f in filenames){
  filename <- paste("data_raw/bc/",f, sep = "")
  tempfile <- read_excel(
    filename,
    sheet = 1,
    skip = 1
  )
  temp_munis <- tempfile %>% pull(var = 1)
  temp_type <- tempfile %>% pull(var = 2)
  temp_rd <- tempfile %>% pull(var = 3)
  temp_munis_combined <- paste(temp_munis, temp_type, sep = ":")
  length(temp_munis)
  if(is.null(munis_union)){
    munis_union <- temp_munis
    munis_intersect <- temp_munis
    munis_combined_union <- temp_munis_combined
    munis_combined_intersect <- temp_munis_combined
  } else {
    munis_union <- union(munis_union, temp_munis)
    munis_intersect <- intersect(munis_intersect, temp_munis)
    munis_combined_union <- union(munis_combined_union, temp_munis_combined)
    munis_combined_intersect <- intersect(munis_combined_intersect, temp_munis_combined)
  }
}

munis_diff <- setdiff(munis_union,munis_intersect)
munis_combined_diff <- setdiff(munis_combined_union, munis_combined_intersect)

munis_df <- data.frame(munis_combined_intersect)
colnames(munis_df) <- c("name")
munis_df <- munis_df %>% separate(name, c("name", "type"), ":")

statscan <- read_csv("aux_tables/bc/bc_stats_can_csd_index.csv")

concord <- inner_join(munis_df, statscan, by = "name", suffix = c("_x", "_y"))

concord_final <- concord[str_detect(concord$type_y, concord$type_x),] %>%
  rename(type_raw = type_x, type_stats_can = type_y) %>% 
  select(name, type_raw, type_stats_can, uid)

# mini concordance table
statscan_cdindex <- read_csv("aux_tables/stats_can_csd_index.csv")



