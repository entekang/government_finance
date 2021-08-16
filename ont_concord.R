#### matching uid's across raw data and statscan #### 

# Author: Ente Kang
# Date Last worked on: Jun. 14, 2021

if(!require("tidyverse")) install.packages("tidyverse")
library(tidyverse)

if(!require("data.table")) install.packages("data.table")
library(data.table)

concord <- read_csv('aux_tables/on/on_csd_index.csv')
ont <- fread('data_raw/on/fir_data_2019.csv', select = c(3,4,7)) %>% 
  rename(muni_name = MUNICIPALITY_DESC) %>% 
  filter(MUNID != 1000) %>% 
  mutate(uid = MUNID + 3500000) %>% 
  select(-c(2)) %>% 
  distinct(.keep_all = T)

ont_final <- inner_join(ont, concord, by = "uid") %>% 
  select(-c(1)) %>% 
  rename(muni_name = name)
