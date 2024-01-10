
library(tidyverse)
library(scales)


# Simulate data -----------------------------------------------------------
# Make messy data

set.seed(747)

n_obs <- 100


df <- data.frame(id = sample(1:n_obs, n_obs, replace=FALSE),
  race = sample(c("White", "Black", "American Indian or Alaska Native",
                  "Asian", "Native Hawaiian or Pacific Islander", "Two or more races"),
                n_obs, prob=c(0.55, 0.22, 0.05, 0.13, 0.01, 0.04),
                replace=TRUE),
  hispanic = sample(c("Non-Hispanic", "Hispanic"), 
                    n_obs, prob=c(0.70, 0.3),
                    replace=TRUE),
  age = rnorm(n_obs, 36, 17),
  gender = sample(c("cisgender male", "cisgender female", "transgender male", "transgender female", "non-binary or genderqueer"),
                  n_obs, prob=c(0.43,0.45,0.03,0.04,0.05), replace=TRUE),
  education = sample(c("8th Grade", "9-11th Grade", "High School", "Some College", "College Grad"),
                     n_obs,
                     prob = c(0.07, 0.12, 0.21, 0.31, 0.29),
                     replace=TRUE),
  SleepHrsNight = rnorm(n_obs, 6.9, 1.35),
  HHIncome = exp(rnorm(n_obs, 10.7, 0.8))) |>
  mutate(age = ifelse(age < 0, -age, age)) |>
  mutate(age = ifelse(age<21, age + 20, age)) |>
  mutate(age = round(age)) |>
  # make duplicated rows
  rowwise() |>
  mutate(times_to_duplicate = sample(c(1,2,3,4,5), 1, prob=c(0.6,0.2,0.1,0.07,0.03))) |>
  ungroup() |>
  uncount(weight = times_to_duplicate) |>
  group_by(id) |>
  mutate(age = ifelse(row_number()>1, -99, age),
         SleepHrsNight = ifelse(row_number()>1, -77, SleepHrsNight),
         HHIncome = ifelse(row_number()>1, -999, HHIncome),
         across(c(gender, hispanic, education),
         ~ ifelse(row_number()>1, "unknown", .))) |>
  ungroup() |>
  # randomly shuffle
  slice(sample(n())) |>
  rename("ID Number"=id,
         "Race self-identified"=race,
         "Hispanic ethnicity"=hispanic,
         "Age at exam"=age,
         "Self-identified gender"=gender, 
         "Highest education completed"=education,
         "Hours of sleep per night" = SleepHrsNight,
         "Household income before taxes" = HHIncome)

# 
# df <- df |>
#   rename_with(~ str_replace_all(., "_", " ")) |>
#   rename_with(~ str_to_title(.)) 

write_csv(df, "day3/activity-data-cleaning/messy_data.csv")



# Data cleaning activity --------------------------------------------------

messy_data <- read_csv("day3/activity-data-cleaning/messy_data.csv")

head(messy_data)

# We can use the clean_names() function from the janitor package to clean up the column names
df <- messy_data |>
  janitor::clean_names()

# there appear to be some ID numbers that appear multiple times
table(df$id_number)

# We can sort by id_number to see if there is a pattern
df <- df |> arrange(id_number)
View(df)

# There appear to be non-standard missing codes in the dataset that we need to clean up.
# Note that self_identified_gender and highest_education_completed are character variable
# and we need to change unknown to NA_character_
# We also see that the numeric variables age_at_exam, hours_of_sleep_per_night, and
# household_income_before_taxes have -99, -77, and -999 that need to be changed to
# NA_real_
# We will take advantage of the across() function to apply mutate to multiple columns at once

df <- df |>
  mutate(across(c(self_identified_gender, highest_education_completed),
                ~ ifelse(.x == "unknown", NA_character_, .x)),
         across(c(age_at_exam, hours_of_sleep_per_night, household_income_before_taxes),
                ~ ifelse(.x <0, NA_real_, .)))

# Now we can count the number of missing variables in order to identify duplicate records
# that should be discarded
unique_df <- df |>
  # count the number of missing columns
  mutate(missing_count = rowSums(is.na(df), na.rm = FALSE)) |>
  group_by(id_number) |>
  # group each id_number's observations by the number of missing columns
  arrange(missing_count) |>
  # take the first row for each id_number, which is the row with the least missing variables
  slice(1) |>
  # drop the missing_count variable
  select(-missing_count) |>
  ungroup()


# We would like to do some collapsing of these variables:
# 1. Create a combined race/ethnicity variable from race_self_identified and hispanic_ethnicity
# This new variable should combine Asian and Native Hawaiian and Pacific Islander individuals into
# the same category. 
# 2. Create a collapsed gender variable with categories cisgender female, cisgender male, and trans/non-binary.
# 3. Create a collapsed education variable with categories less than high school, high school graduate, and college graduate.

table(unique_df$race_self_identified, unique_df$hispanic_ethnicity, useNA="ifany")


unique_df <- unique_df |>
  mutate(raceth = factor(
    case_when(
      race_self_identified == "White" &
        hispanic_ethnicity == "Non-Hispanic" ~ "Non-Hispanic White",
      race_self_identified == "Black" &
        hispanic_ethnicity == "Non-Hispanic" ~ "Non-Hispanic Black",
      hispanic_ethnicity == "Hispanic" ~ "Hispanic",
      is.na(race_self_identified) |
        is.na(hispanic_ethnicity) ~ NA_character_,
      TRUE ~ "underrepresented racial/ethnic group"
    ),
    levels = c(
      "Non-Hispanic White",
      "Non-Hispanic Black",
      "Hispanic",
      "underrepresented racial/ethnic group"
    )
  ))


unique_df <- unique_df |>
  mutate(
    gender_collapsed = ifelse(
      self_identified_gender %in% c(
        "transgender female",
        "transgender male",
        "non-binary or genderqueer"
      ),
      "trans/non-binary",
      self_identified_gender
    ),
    education_collapsed = case_when(
      highest_education_completed %in% c("8th Grade", "9-11th Grade") ~ "less than hs",
      highest_education_completed %in% c("High School", "Some College") ~ "hs grad",
      highest_education_completed == "College Grad" ~ "college grad"
    )
  )
    
# We would like to create a dichotomous sleep variable where 0 = >=7 hours of sleep per night and 1= <7 hours of sleep per night
# We would also like to create a categorical income variable with categories <$35,000, $35000-$50000, $50000-$100000, and >=$100000
# We would also like to create an income quintile variable


unique_df <- unique_df |>
  mutate(insufficient_sleep = hours_of_sleep_per_night < 7)

table(unique_df$insufficient_sleep)

unique_df <- unique_df |>
  mutate(income_cat = cut(household_income_before_taxes, 
                          breaks = c(0, 25000, 50000, 75000, 100000, 1000000),
                          right = FALSE, include.lowest=TRUE, na.rm=T),
         income_quint = ntile(household_income_before_taxes, 5))


# Let's visualize how income_cat has split up the household_income_before_taxes variable
ggplot(unique_df, aes(x=income_cat, y=household_income_before_taxes)) + 
  geom_boxplot() +
  scale_y_continuous(labels=label_comma())
  
# Let's compare how income_quint has split up the household_income_before_taxes variable
ggplot(unique_df, aes(x=factor(income_quint), y=household_income_before_taxes)) + geom_boxplot()

# to see the minimum and maximum of the quintile categories created by ntile()
# we can use group_by and summarize
unique_df |>
  group_by(income_quint) |>
  summarise(mininc = min(household_income_before_taxes, na.rm=T),
            maxinc = max(household_income_before_taxes, na.rm=T))


# suppose that we want to calculate the proportion of subjects
# with insufficient sleep in each gender and racial/ethnic group

proportions_by_gender_raceth <- unique_df |>
  # group by gender, race/ethnicity, and insufficient sleep category
  group_by(gender_collapsed, raceth, insufficient_sleep) |>
  # count the number of subjects in each category
  # Note the use of .groups='drop' which removes the group_by after summarizing
  summarise(count_insufficient_sleep = n(), .groups='drop') |>
  # Now group by gender and race/ethnicity
  group_by(gender_collapsed, raceth) |>
  # Calculate the proportion
  mutate(proportion_insufficient_sleep = count_insufficient_sleep/sum(count_insufficient_sleep, na.rm=T)) |>
  # Remove the grouping
  ungroup()

head(proportions_by_gender_raceth)
