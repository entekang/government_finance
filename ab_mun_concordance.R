# INFO ====

# Script to start the matching of AB municipalities with Statistics Canada CSDs

# ADDITIONAL EDITS BY ENTE (Jun 16, 2021): further processing, uids, column types, joining.

# SETUP ----

# libraries
if (!require('readxl')) install.packages('readxl'); library(readxl)
if (!require('tidyverse')) install.packages('tidyverse'); library(tidyverse)
if (!require('stringr')) install.packages('stringr'); library(stringr)

# load csd index
csd_index <- read.csv("aux_tables/ab/ab_csd_index.csv",
                      col.names = c("uid", "name", "type")) 
csd_index$name <- str_to_lower(csd_index$name)

# set parameters
start_year <- 2009
end_year <- 2020

# COLLECT NAMES FROM DATA

path_start <- "data_raw/ab/ab_"

# placeholder dataframe
geo_info <- data.frame(type = character(), code = numeric(), name = character())

for(yr in start_year:end_year){# loop over years
  path <- paste(path_start, yr, ".xlsx", sep = "") # construct path
  nsheets <- length(excel_sheets(path = path)) # number of sheets
  for(i in 2:nsheets){ # loop over all but 1st (index) sheet
    temp_df <- read_excel(
      path = path,
      sheet = i,
      skip = 3
    )
    
    # select geographic columns, and rename
    temp_df <- temp_df %>% select(2:4) %>% rename(type = 1, code = 2, name = 3)
    
    # bind to geo info set
    geo_info <- rbind(geo_info, temp_df)
  }
}

# filter for distinct, filter out "____ out of ____" obs, etc.
geo_info_f <- geo_info %>% distinct(.keep_all = TRUE) %>%
  separate(name, c("muni_name", "other"), sep = ",") %>% 
  select(c("type", "muni_name"))
geo_info_f$muni_name <- str_to_lower(geo_info_f$muni_name)

# string operations (eg. probably need to get rid of everything after a comma, could be some other rules)

# JOIN ----

# Join cleaned geo_info data with CSD Index
joined_concordance <- inner_join(geo_info_f, csd_index, by = c("muni_name"="name"), suffix = c("_geo", "_csd"))

# OTHERS ----
# save a file with "others" where joining didn't work
# open that file, create a mapping manually if necessary

# re-load "other" concordance
# associate "others"

# see the BC code file


# SAVE ----
# save concordance

