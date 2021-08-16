#### Extract sheet names out of all the datasets for Alberta ####

#Author: Ente Kang 
#Last edit: Jun. 15, 2021

library(tidyverse)
library(readxl)
library(data.table)


excel_sheets('data_raw/ab/ab_2009.xlsx')

path_start <- "data_raw/ab/ab_"

sheet_df <- tibble()
for (year in 2009:2020){
  s_path <- paste(path_start, year, ".xlsx", sep = "")
  df <- data.frame(excel_sheets(path = s_path))
  colnames(df) <- year
  sheet_df <- merge(sheet_df, df, by = 0, all = TRUE)[-1]
}

