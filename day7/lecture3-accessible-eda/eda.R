# Exploratory Data Analysis 

# We'll show you some tools you can use to perform exploratory 
# data analyses. 
# 
# Of course, we've already shown you ggplot2 with which you can make all kinds
# of fantastic visualizations to explore your data, but the tools mentioned
# below should help you on your journey of understanding.


# dependencies ------------------------------------------------------------

library(palmerpenguins)
library(tidyverse)
library(skimr)
library(gtsummary)
library(DataExplorer)
library(GGally)
library(vip)
library(randomForest)

# the basics --------------------------------------------------------------

# you should think of View and glimpse as your go-to start places for 
# beginning to understand a dataframe you have on hand
View(penguins)
glimpse(penguins)

# a more sophisticated option is present in the skimr package
skim(penguins)


# gtsummary ---------------------------------------------------------------

# if you want a bit more of a fancy table, or a basic "Table 1" you 
# might use gtsummary

gtsummary::tbl_summary(penguins)

gtsummary::tbl_summary(penguins, by = sex)

penguins %>% 
  mutate(
    sex = forcats::fct_explicit_na(sex)) %>% 
  gtsummary::tbl_summary(by = sex)


# DataExplorer ------------------------------------------------------------

DataExplorer::create_report(penguins)


# GGally ------------------------------------------------------------------

ggpairs(penguins)

ggbivariate(penguins, outcome = "species", explanatory = c("sex"))


# vip ---------------------------------------------------------------------

# the vip package helps you to visualize variable importance
# 
# it works with lm, glm, randomForest, and lots of other types of models

lm_model <- lm(bill_depth_mm ~ bill_length_mm + flipper_length_mm + species + sex,
   data = penguins)

vip(lm_model)

# you don't need to know anything about randomForests, just that they're another
# kind of modeling approach
rf_model <- randomForest( 
  bill_depth_mm ~ bill_length_mm + flipper_length_mm + species + sex,
  data = na.omit(penguins))

vip(rf_model)

# ggdiagnose in GGally ----------------------------------------------------

GGally::ggnostic(lm_model)
# or you could use benjaminleroy/ggDiagnose
