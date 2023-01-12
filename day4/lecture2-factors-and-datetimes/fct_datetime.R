### Author: AHz
### Date: 2023-01-12
### Written in: R version 4.2.1
### Purpose: Run code from the factors and date-times (fct_datetime.qmd) lecture


###############################################################################
# 0. SET UP #########################################
###############################################################################

#install.packages("pacman")
library(pacman)
p_load(tidyverse,
       palmerpenguins,
       lubridate,
       viridis, 
       parsedate)


###############################################################################
### FACTORS #########################################
###############################################################################

## Working with factors

library(palmerpenguins)
colnames(penguins)


glimpse(penguins)

unique(penguins$species)

## Factor rules

ggplot(penguins, aes(x = species)) + 
  geom_bar()


## Changing the factor order: fct_infreq()

ggplot(penguins, aes(x = fct_infreq(species))) + 
  geom_bar()

## Changing the factor order: fct_rev()

ggplot(penguins, aes(x = fct_rev(species))) + 
  geom_bar()

## Factor rules: Missingness

unique(penguins$sex)

ggplot(penguins, aes(x = sex)) + 
  geom_bar()

ggplot(penguins, aes(x = species, fill = sex)) +
  geom_bar(position = "dodge") +
  facet_wrap(~island)

## Empty groups + NAs in factors

#filter to just adelie penguins
adelie_penguins <- penguins %>% 
  filter(species == "Adelie")

unique(adelie_penguins$species)

table(adelie_penguins$species)

table(as.character(adelie_penguins$species))

ggplot(adelie_penguins, aes(x = sex, fill = species)) +
  geom_bar(position = "dodge") +
  facet_wrap(~island)

# keep factor levels that are empty
ggplot(adelie_penguins, aes(x = sex, fill = species)) +
  geom_bar(position = "dodge") +
  scale_fill_discrete(drop=FALSE) +
  facet_wrap(~island)

# filter to just female penguins 
female_penguins <- penguins %>% 
  filter(sex == "female")

ggplot(female_penguins, aes(x = species, fill = sex)) +
  geom_bar(position = "dodge") +
  scale_fill_discrete(drop=FALSE) +
  facet_wrap(~island)

## Example: NHANES -- Creating age quartiles

# what is in the age column? 
summary(nhanes$age)

# create age quartiles
nhanes$age_quartiles <- ntile(nhanes$age, 4)

# what type of data is age_quartile? 
class(nhanes$age_quartiles)

ggplot(nhanes, aes(x = age_quartiles, y = mean_BP)) + 
  geom_boxplot()

## Transforming `age_quartiles` into a factor

nhanes$age_quartiles <- factor(nhanes$age_quartiles)

# now what type of data is age_quartile? 
class(nhanes$age_quartiles)


ggplot(nhanes, aes(x = age_quartiles, y = mean_BP)) + 
  geom_boxplot()

nhanes <- nhanes %>% 
  group_by(age_quartiles) %>% 
  mutate(age_quartiles = factor(age_quartiles, 
                                labels = c(paste0("[", min(age), "-", max(age), "]"))))

unique(nhanes$age_quartiles)

ggplot(nhanes, aes(x = age_quartiles, y = mean_BP)) + 
  geom_boxplot()

## Creating blood pressure categories

nhanes$bp_cat <- case_when(nhanes$mean_BP < 90 ~ "low BP",
                           nhanes$mean_BP > 140 ~ "high BP",
                           TRUE ~ "normal BP")


# look at blood pressure categories with age
ggplot(nhanes, aes(x = bp_cat, y = age)) + 
  geom_boxplot()

# manually set the order
nhanes$bp_cat <- factor(nhanes$bp_cat, levels = c("high BP", "normal BP", "low BP"))

# now the levels will retain the order for us 
unique(nhanes$bp_cat)

# when we plot it, the order will be determined by the levels
ggplot(nhanes, aes(x = bp_cat, y = age)) + 
  geom_boxplot()


## Caution: factor → numeric


penguins_fctyr <- penguins %>% 
  mutate(year = factor(year))

ggplot(penguins_fctyr, aes(x = species, y = flipper_length_mm, color = year)) + 
  geom_boxplot()


penguins_num <- penguins_fctyr %>% 
  mutate(year = as.integer(year))

unique(penguins_num$year)

ggplot(penguins, aes(x = species, 
                     y = flipper_length_mm, 
                     color = as.factor(year))) + 
  geom_boxplot()

## Caution: typos

penguins_sizes <- penguins %>% 
  mutate(size_cat = case_when(bill_length_mm > mean(bill_length_mm, na.rm = T) &
                                bill_depth_mm > mean(bill_depth_mm, na.rm = T) & 
                                flipper_length_mm > mean(flipper_length_mm, na.rm = T) ~ "big penguins",
                              bill_length_mm < mean(bill_length_mm, na.rm = T) &
                                bill_depth_mm < mean(bill_depth_mm, na.rm = T) & 
                                flipper_length_mm < mean(flipper_length_mm, na.rm = T) ~ "small penguins",
                              TRUE ~ "average penguins"))

table(penguins_sizes$size_cat, useNA = "ifany")

penguins_sizes$size_cat <- factor(penguins_sizes$size_cat, levels = c("smol penguins", "average penguins", "big penguins"))

table(penguins_sizes$size_cat, useNA = "ifany")



###############################################################################
### DATE-TIMES #########################################
###############################################################################


## Working with dates

today()

now()


## lubridate:: basics

year(now())

month(now())

month(now(), label = TRUE)

day(now())

yday(now())

wday(now())

wday(now(), label = TRUE)

hour(now())

minute(now())

second(now())


today()
#coerce today() into a date-time
as_datetime(today())

now()
#coerce now() into a date
as_date(now())


ymd("2023-01-12")

ymd_hms("2023-01-12 13:30:00")

ymd_hms("2023-01-12 13:30:00", tz = "EST")


## Time spans

# durations
ddays(9)


# periods
days(9)

#intervals
interval(start = today(), 
         end = today() + days(1))

## Durations: Subtraction

class_length <- ymd_hms("2023-01-12 17:30:00") -  ymd_hms("2023-01-12 13:30:00")
class_length
as.duration(class_length)

## Durations: Multiplication

# how many days does this class meet for? 
class_dates <- c(seq(ymd('2023-01-09'),ymd('2023-01-13'), by = 1),
                 seq(ymd('2023-01-17'),ymd('2023-01-20'), by = 1))
class_dates

class_length*length(class_dates)
as.duration(class_length)*length(class_dates)

## Durations: Addition


class_meeting_times <- tibble(dates =  class_dates,
                              week = c(rep(1, 5), rep(2, 4)),
                              start_time = c(rep(hms("13:30:00"), 9)),
                              start_datetime = c(ymd_hms(paste(dates, start_time), tz = "EST")),
                              end_time = c(rep(hms("17:30:00"), 9)),
                              end_datetime = c(ymd_hms(paste(dates, end_time), tz = "EST")),
                              class_time_int = interval(start = start_datetime,
                                                        end = end_datetime))
class(class_meeting_times$dates)
class(class_meeting_times$start_time)
class(class_meeting_times$class_time_int)

as.duration(sum(as.duration(class_meeting_times$end_time-class_meeting_times$start_time)))


## Caution: Working with intervals, durations, and periods {.smaller}
class_meeting_times$start_time[1] + hours(4)

interval(start = today(), end = ymd("2023-01-20"))
today() %--% ymd("2023-01-20")

class_date_interval <- interval(start = min(ymd(class_dates)), 
                                end = max(ymd(class_dates)))

#check whether a date happens during class
ymd("2023-01-22") %within% class_date_interval
ymd("2023-01-12") %within% class_date_interval


## Caution: Working with intervals, durations, and periods

class_meeting_times$start_time[1] + hours(4)

class_meeting_times$start_time[1] + dhours(4)

interval(start = now(), 
         end = ymd_hms("2023-01-12 17:30:00"))

interval(start = now(), 
         end = ymd_hms("2023-01-12 17:30:00",
                       tz = "EST"))



## Caution: time is a construct 

leap_year(2024)

ymd("2024-01-12") - dyears(1)


dst(today())
dst("2023-03-12 13:30:00")

ymd_hms("2023-03-11 13:30:00") + ddays(1)
ymd_hms("2023-03-11 13:30:00") + days(1)



## Example: Classroom CO2


hobo_g2 <- read_csv("data/hobo_g2.csv", 
                    col_types = cols(
                      date_time = col_character()))

glimpse(hobo_g2)

hobo_g2_dt <- hobo_g2 %>% 
  mutate(metric = factor(metric, levels = c("co2_ppm", "temp_f", "rh_percent"),
                         labels = c("CO2 (ppm)", "Temperature (F)", "Relative Humidity (%)")), 
         date_time = force_tz(as_datetime(date_time), tz = "EST"), 
         time = hms::as_hms(date_time),
         date = as_date(date_time),
         hour = hour(date_time),
         minute = minute(date_time),
         second = second(date_time))

glimpse(hobo_g2_dt)

ggplot(hobo_g2_dt, aes(x = date_time, y = result))  + 
  geom_line() + 
  facet_wrap(~metric, scales = "free_y", ncol = 1) + 
  scale_x_datetime(breaks = scales::date_breaks("30 mins"), date_labels = "%H:%M") + 
  xlab("Time") + 
  ylab("") +
  ggtitle(paste0("Indoor conditions in G2 (", unique(hobo_g2_dt$date), ")"))


#aggregate to minute averages
hobo_g2_1min <- hobo_g2_dt %>% 
  group_by(metric, date, hour, minute) %>% 
  summarize(avg_1min = mean(result)) %>% 
  mutate(date_time = ymd_hm(paste0(date, " ", hour, ":", minute)))

#aggregate to hourly averages
hobo_g2_1hr <- hobo_g2_dt %>% 
  group_by(metric, date, hour) %>% 
  summarize(avg_1hr = mean(result)) %>% 
  mutate(date_time = ymd_h(paste0(date, hour)))


ggplot(hobo_g2_dt, aes(x = date_time, y = result))  + 
  geom_line(color = "lightgrey", size = 1) + 
  facet_wrap(~metric, scales = "free_y", ncol = 1) + 
  theme_bw()

#add 1 min average line
ggplot(hobo_g2_dt, aes(x = date_time, y = result))  + 
  geom_line(color = "lightgrey", size = 1) + 
  geom_line(hobo_g2_1min, mapping = aes(x = date_time, y = avg_1min), color = "slateblue3") + 
  facet_wrap(~metric, scales = "free_y", ncol = 1) + 
  theme_bw()

#add 1 hour average line
ggplot(hobo_g2_dt, aes(x = date_time, y = result))  + 
  geom_line(color = "lightgrey", size = 1) + 
  geom_line(hobo_g2_1min, mapping = aes(x = date_time, y = avg_1min), color = "slateblue3") + 
  geom_line(hobo_g2_1hr, mapping = aes(x = date_time, y = avg_1hr), color = "paleturquoise2") + 
  facet_wrap(~metric, scales = "free_y", ncol = 1) + 
  theme_bw()


table(hobo_g2_dt$date_time %within% class_meeting_times$class_time_int)


ggplot(hobo_g2_dt)  + 
  geom_line(aes(x = date_time, y = result), color = "lightgrey", size = 1) + 
  geom_line(hobo_g2_1min, mapping = aes(x = date_time, y = avg_1min), color = "slateblue3") + 
  geom_line(hobo_g2_1hr, mapping = aes(x = date_time, y = avg_1hr), color = "paleturquoise2") +
  geom_rect(data = class_meeting_times %>%
              filter(dates %in% hobo_g2_dt$date),
            mapping = aes(xmin = start_datetime,
                          xmax = end_datetime,
                          ymin = 0, ymax = Inf),
            alpha = 0.2, fill = "lightpink") +
  facet_wrap(~metric, scales = "free_y", ncol = 1) + 
  theme_bw()
