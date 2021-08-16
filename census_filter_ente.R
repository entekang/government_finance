#### filtering census data against variables we care about ####

# Author: Ente Kang
# Date Last worked on: Jun. 11, 2021

if(!require("tidyverse")) install.packages("tidyverse")
library(tidyverse)

if(!require("readxl")) install.packages("readxl")
library(readxl)

if(!require("data.table")) install.packages("data.table")
library(data.table)

#### BC 2016 census ####

muni_codes <- read_csv("aux_tables/bc/bc_muni_concordance.csv")

vars_want <- read_xlsx("census_codes.xlsx") 

bc_census_2016_final <- fread("cen_2016_bc/2016bc_cens.csv", select = c(1, 2, 4, 11, 13), 
                              col.names = c("year", "uid", "muni_name", "var", "val")) %>% 
  filter((uid %in% muni_codes$uid) & (var %in% vars_want$cen2016)) %>% 
  mutate(var_name = "")

#### BC 2011 census ####
# bc has geo code 59 
bc_census_2011 <- fread('cen2011/cen2011.csv', select = c(1, 2, 6, 7, 9)) %>% 
  filter(Prov_Name == "British Columbia") %>% 
  filter(Characteristics %in% vars_want$cen2011_charac[complete.cases(vars_want$cen2011_charac)])
bc_census_2011_final <- inner_join(bc_census_2011, muni_codes, by = c("Geo_Code" = "uid")) %>% 
  select(c(1,3,4,5,6)) %>% 
  rename(uid = Geo_Code, val = Total) %>% 
  mutate(var_name = "")

#### nhs2011 ####
nhs <- fread('nhs2011_subdiv/BC.csv', select = c(1, 4, 7, 8, 10)) %>% 
  filter(Characteristic %in% vars_want$nhs2011_charac[complete.cases(vars_want$nhs2011_charac)])
nhs_final <- inner_join(nhs, muni_codes, by = c("Geo_Code" = "uid")) %>% 
  select(c(1, 3, 4, 5, 6)) %>% 
  rename(uid = Geo_Code, val = Total) %>% 
  mutate(var_name = "")

#### BC 2006 census ####
bc_census_2006 <- fread('cen2006_subdiv/BC.csv', select = c(1, 4, 6, 7, 9), nrow = 233248) %>%   # change nrow for different files, weird comments at bottom
  rename(uid = V1, Total = Note, Characteristic = Topic, Topic = CSD_Type) %>% 
  filter(Characteristic %in% vars_want$cen2006_charac[complete.cases(vars_want$cen2006_charac)])
bc_census_2006_final <- inner_join(bc_census_2006, muni_codes, by = "uid") %>% 
  select(c(1, 3, 4, 5, 6)) %>% 
  rename(val = Total) %>% 
  mutate(var_name = "")

for (i in 1:nrow(vars_want)){
  bc_census_2006_final$var_name[bc_census_2006_final$Characteristic == vars_want$cen2006_charac[i]] <- vars_want$var_clean[i]
  bc_census_2011_final$var_name[bc_census_2011_final$Characteristics == vars_want$cen2011_charac[i]] <- vars_want$var_clean[i]
  nhs_final$var_name[nhs_final$Characteristic == vars_want$nhs2011_charac[i]] <- vars_want$var_clean[i]
  bc_census_2016_final$var_name[bc_census_2016_final$var == vars_want$cen2016[i]] <- vars_want$var_clean[i]
}


