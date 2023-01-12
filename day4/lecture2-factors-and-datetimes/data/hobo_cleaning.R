### Author: AHz
### Date: 01/08/2023
### Written in: R version 4.2.1
### Purpose: Load and clean CO2/temp data

# set working directory to file location

library(pacman)
p_load(here)
p_load(tidyverse)
p_load(janitor)
p_load(lubridate)


###############################################################################
# 1. FUNCTIONS TO CLEAN RAW DATA #########################################
###############################################################################

#clean HOBO data (without CO2 logger)
clean_hobo_dat <- function(dat){
  dat %>% 
    clean_names() %>% 
    rename_all(~str_remove_all(., "_lgr.*")) %>% 
    rename_with(~"date_time", contains("date_time")) %>% 
    select(date_time:rh_percent) %>%
    mutate(date_time = mdy_hms(date_time)) %>% 
    pivot_longer(names_to = "metric", values_to = "result", temp_f:rh_percent) 
}

#clean HOBO CO2 logger data
clean_hobo_co2 <- function(dat){
  dat %>% 
    clean_names() %>% 
    rename_all(~str_remove_all(., "_lgr.*")) %>% 
    rename_with(~"date_time", contains("date_time")) %>% 
    select(date_time:co2_ppm) %>% 
    mutate(date_time = mdy_hms(date_time)) %>% 
    pivot_longer(names_to = "metric", values_to = "result", temp_f:co2_ppm) %>%
    filter(metric == "co2_ppm") 
}


###############################################################################
# 2. LOAD AND CLEAN DATA   #########################################
###############################################################################

hobo <- read_csv(here("day4/factor_datetime_code/data/hobo_g2_2023-01-09.csv"), skip = 1) %>% 
  clean_hobo_dat() %>% 
  filter(date_time %within% interval(start = ymd_hms("2023-01-09 13:15:00"), 
                                     end = ymd_hms("2023-01-09 18:00:00")))
  
hobo_co2 <- read_csv(here("day4/factor_datetime_code/data/hobo_co2_g2_2023-01-09.csv"), skip = 1) %>% 
  clean_hobo_co2() %>% 
  filter(date_time %within% interval(start = ymd_hms("2023-01-09 13:15:00"), 
                                     end = ymd_hms("2023-01-09 18:00:00")))


hobo_g2 <- bind_rows(hobo, hobo_co2)


write_csv(hobo_g2, here("day4/factor_datetime_code/data/hobo_g2.csv"))
