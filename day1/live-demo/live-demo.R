# analyze COVID-19 county mortality rates stratified by poverty level

# steps: 
#   - declare dependencies
#   - load the COVID-19 data 
#   - clean the data
#   - fetch the poverty data 
#   - merge data together 
#   - create cutpoints for poverty 
#   - create some visualization(s)
#   - (possibly) create & report on a regression model

# dependencies
library(tidyverse)
library(tidycensus)
library(urbnmapr)
library(here)

# setup 
analysis_dir <- here("day1/live-demo/")


# load covid-19 data  -----------------------------------------------------
covid <- list(
  readr::read_csv(here(analysis_dir, 'data/us-counties-2020.csv')),
  readr::read_csv(here(analysis_dir, 'data/us-counties-2021.csv')),
  readr::read_csv(here(analysis_dir, 'data/us-counties-2022.csv'))
)

# clean the covid-19 data -------------------------------------------------
covid <- bind_rows(covid) # merge into one dataframe

# remove the unnecessary "USA-" prefix in the geoids
covid$geoid <- stringr::str_replace_all(covid$geoid, "USA-", "")

# aggregate monthly 
covid <- covid |> 
  mutate(
    year_month = paste0(lubridate::year(date), "-", lubridate::month(date))
  )

# create a factor level for the year_month
covid$year_month <- factor(covid$year_month, levels=
                             paste0(rep(2020:2022, each=12), "-", rep(c(1:12), 3)))

# aggregate up to monthly observations
covid <- covid |> 
  group_by(year_month, geoid, county, state) |> 
  summarize(
    deaths_avg_per_100k = mean(deaths_avg_per_100k, na.rm=T)
  )

# fetch county covariates data --------------------------------------------

popsize_and_poverty <- tidycensus::get_acs(
  geography = 'county',
  variables = c('popsize' = 'B01001_001',
                'total_for_poverty_table' = 'B05010_001',
                'in_poverty' = 'B05010_002'),
  year = 2020
)

# clean county covariates data
popsize_and_poverty <- popsize_and_poverty |> 
  select(-moe) |> 
  tidyr::pivot_wider(
    id_cols = c(GEOID, NAME),
    values_from = estimate,
    names_from = variable
  )

# calculate proportion in poverty
popsize_and_poverty <- popsize_and_poverty |> 
  mutate(
    proportion_in_poverty = in_poverty / total_for_poverty_table
  )

# drop unnecessary columns
popsize_and_poverty <- popsize_and_poverty |> 
  select(GEOID, popsize, proportion_in_poverty)


# merge data --------------------------------------------------------------

covid <- left_join(covid, popsize_and_poverty,
                   by = c('geoid' = 'GEOID'))


# summarize by poverty levels ---------------------------------------------

covid <- covid |> 
  mutate(
    poverty_cut = cut(proportion_in_poverty, 
                      c(0, 0.05, 0.1, 0.2, 1))
  )

covid_avg_by_poverty_level <- covid |> 
  group_by(poverty_cut, year_month) |> 
  summarize(
    deaths_avg_per_100k = Hmisc::wtd.mean(
      deaths_avg_per_100k, normwt = popsize
    )
  )

# visualize ---------------------------------------------------------------

covid_avg_by_poverty_level |> 
  filter(! is.na(poverty_cut)) |> 
  ggplot(aes(x = year_month, y = deaths_avg_per_100k, color = poverty_cut, group = poverty_cut)) + 
  geom_line() + 
  xlab("Date") + 
  ylab("COVID-19 Mortality per 100k (monthly averages)") +
  ggtitle("Monthly County COVID-19 Mortality Rates by Poverty Level") + 
  scale_color_brewer(palette = "RdBu", direction = -1) + 
  theme(axis.text.x = element_text(angle = 75, hjust = 1)) 

