# ############################################################################ #
# COURSE :  ID 529: Data Management and Analytic Workflows in R
# ACTIVITY: Working with joins
# DATE:     01/13/2023
# INPUTS:   ID 529 NHANES dataset (ID529data::nhanes_id529) 
# OUTPUTS:  N/A
# AUTHOR:   Dean Marengi
# NOTES:    ID 529 dataset details: https://github.com/ID529/ID529data
# ############################################################################ #

# PACKAGES ---------------------------------------------------------------------
# Uncomment and run lines 15-18  (if you have not already 
# loaded the ID529 NHANES data or installed the tidyverse)

install.packages("tidyverse")
install.packages("devtools")
library(devtools)
devtools::install_github("ID529/ID529data")

# Load relevant package libraries
library(ID529data) # Includes ID 529 NHANES data
library(tidyverse) # Includes dplyr

# Load ID 529 NHANES data 
data(nhanes_id529, package = 'ID529data')

# SPLIT UP THE DATASET ---------------------------------------------------------
# Run set.seed(123) to ensure the random sample we take is the same
set.seed(123)

# Dataset 1: Demographic and clinical parameters
clinical <- nhanes_id529 %>%
  rename(race_eth = race_ethnicity,
         sbp = mean_BP, 
         ht = height,
         wt = weight) %>%
  select(id, age, race_eth, sbp:ht) %>% 
  # Take a random sample of 2300 (out of the total 2339 observations)
  slice_sample(., n = 2300) %>% 
  as_tibble()
  
# Dataset 2: Demographic and clinical parameters (maintain all 2339 observations)
pfas <- nhanes_id529 %>% 
  arrange(id) %>% 
  select(id, matches("pf.*")) %>% 
  as_tibble()

# LOOK AT THE DATA -------------------------------------------------------------
# Print the tibbles to the console
clinical 
pfas

# Alternatively, use glimpse()
glimpse(clinical)
glimpse(pfas)

# PRACTICE ---------------------------------------------------------------------
# 1. Review the code used to create the above datasets and add a comment
# above each line describing what the function is doing


# 2. Left join the clinical data to the pfas data. What happend? 
# How many rows and columns were in the original datasets? 
# How many are in the final, joined dataset? 


# 3. Right join the clinical data to the pfas data. What happend now? 
# Again, how many rows and columns were in the original datasets? 
# And how many are in the final, joined dataset? 

# 4. Explore one other mutating join (e.g, inner_join, full_join). How 
# do these two joins differ from left and right joins? 

# 5. Implement the following ant_join function. What information does this provide? 
# How might this be useful? 
anti_join(pfas, clinical, by = "id")

