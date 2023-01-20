# dplyr Demo & Recap 

# dependencies ------------------------------------------------------------

library(tidyverse)
library(palmerpenguins)

# the pipe operator -------------------------------------------------------

# one of the most foundational tools in the tidyverse is the "pipe" operator %>% 
# https://magrittr.tidyverse.org/ 
# https://en.wikipedia.org/wiki/The_Treachery_of_Images 

# what you need to know: 
# 
# if you have a function f() then f(x) is the same as x %>% f()
# and if you have multiple arguments, then 
#   f(x,y) is the same as x %>% f(y)

f <- function(x) { x^2 }
x <- c(2, 5, 10)
f(x)
x %>% f()

f <- function(x, y = 2) { x^y }
f(x)
x %>% f(2)
x %>% f(3)

# why would we use the pipe? 
# because we like to read from left to right, not inside to outside. 
# 
# would you rather read: 
# 
# serve(plate(frost(bake(cake))))
# 
# or: 
# cake %>% bake() %>% frost() %>% plate() %>% serve() 
# 
# in R 4.1 (released in May 2021) they introduced a builtin pipe |> that
# works (almost) exactly the same as the %>% pipe from magrittr. 
# feel free to use either pipe. 


# a list of the most commonly used dplyr functions ------------------------

# organizational: 
# select() -- select columns to keep from a dataframe
# filter() -- filter rows in a dataframe
# arrange() -- order the rows in a dataframe
# rename() -- rename columns
# group_by() -- create a grouped a dataframe

# making new data:
# mutate() -- create or modify columns
# summarize() -- reduce rows into summary measures


# select ------------------------------------------------------------------

View(penguins)

select(penguins, bill_length_mm) # notice you don't need quote-marks

select(penguins, bill_length_mm, bill_depth_mm)

select(penguins, species:flipper_length_mm) # remember we read 1:10 as "one through 10" 

penguins %>% 
  select(species:flipper_length_mm)

penguins_with_dropped_columns <- 
  penguins %>% select(-c(island, bill_length_mm))

# filter ------------------------------------------------------------------

penguins %>% filter(year == 2007) # get just the penguins observed in 2007

penguins %>% filter(year == 2007 & sex == 'male')

penguins %>% filter(year == 2007, sex == 'male')

penguins %>% filter(row_number() %in% 1:10) 
# another way to do this is with slice or slice_head
penguins %>% slice(1:10)
penguins %>% slice_head(n=10)


# arrange -----------------------------------------------------------------

# sort the penguins by their flipper length
penguins %>% arrange(flipper_length_mm)

penguins %>% arrange(desc(flipper_length_mm)) # now for decreasing

penguins %>% arrange(year) # sort by year of observation

# put all the 2007 penguins together, then 2008, then 2009, but within 
# each year's penguins observed, sort them by flipper_length_mm
penguins_sorted <- 
  penguins %>% arrange(year, flipper_length_mm)

# rename ------------------------------------------------------------------

# the syntax for rename is 
# df %>% rename(new_column_name = old_column_name)

penguins %>% 
  rename(observation_year = year)

# remember, if we wanted to write the output from our pipe, we'd have to 
# assign the output of the pipe to a variable
penguins_with_fixed_year_column <- 
  penguins %>% 
  rename(observation_year = year)


# mutate ------------------------------------------------------------------

# mutate lets you create or modify columns
# 
# the syntax is: 
# df %>% mutate(column_name = values_for_the_column)
# 
# and you can put expressions to evaluate where values_for_the_column appears

# PS: remember what I said about using variables instead of magic numbers? 

penguins %>% mutate(body_mass_lbs = 0.00220462 * body_mass_g)

grams_to_pounds_conversion_ratio <- 0.00220462

penguins %>% mutate(body_mass_lbs = body_mass_g * grams_to_pounds_conversion_ratio) %>% 
  View()


# summarize ---------------------------------------------------------------

# if you use summarize _without_ group_by, you'll create summary measures 
# for the entire dataset. 

# syntax: 
# df %>% summarize(summary_measure_name = f(column_name))

penguins %>% summarize(
  mean_flipper_length_mm = mean(flipper_length_mm, na.rm = TRUE)
)

penguins %>% summarize(
  mean_flipper_length_mm = mean(flipper_length_mm, na.rm = TRUE),
  mean_body_mass_g = mean(body_mass_g, na.rm = TRUE)
)

penguins %>% summarize(
  mean_flipper_length_mm = mean(flipper_length_mm, na.rm = TRUE),
  ci_high_flipper_length_mm = quantile(flipper_length_mm, .975, na.rm = TRUE),
  ci_low_flipper_length_mm = quantile(flipper_length_mm, .025, na.rm = TRUE)
)



# group_by and summarize --------------------------------------------------

# if you group_by a variable and then pipe to summarize, you'll get summary
# measures for each group. 

penguins %>% 
  group_by(species) %>% 
  summarize(
    mean_flipper_length_mm = mean(flipper_length_mm, na.rm = TRUE),
    ci_high_flipper_length_mm = quantile(flipper_length_mm, .975, na.rm = TRUE),
    ci_low_flipper_length_mm = quantile(flipper_length_mm, .025, na.rm = TRUE)
  )


# note that you can group_by multiple variables

penguins %>% 
  group_by(species, sex) %>% 
  summarize(
    mean_flipper_length_mm = mean(flipper_length_mm, na.rm = TRUE),
    ci_high_flipper_length_mm = quantile(flipper_length_mm, .975, na.rm = TRUE),
    ci_low_flipper_length_mm = quantile(flipper_length_mm, .025, na.rm = TRUE)
  )

# maybe for reporting a cleaned up table, I might remove the missing
# observations and just mention that there were N penguins excluded from this
# table somewhere else in text if I were putting this table in a manuscript:
penguins %>% 
  group_by(species, sex) %>% 
  summarize(
    mean_flipper_length_mm = mean(flipper_length_mm, na.rm = TRUE),
    ci_high_flipper_length_mm = quantile(flipper_length_mm, .975, na.rm = TRUE),
    ci_low_flipper_length_mm = quantile(flipper_length_mm, .025, na.rm = TRUE)
  ) %>% 
  filter(! is.na(sex))

# okay, I know it's not a talk on ggplot2, but I couldn't help myself. 

flipper_length_stats <- 
  penguins %>% 
  group_by(species, sex) %>% 
  summarize(
    mean_flipper_length_mm = mean(flipper_length_mm, na.rm = TRUE),
    `q97.5_flipper_length_mm` = quantile(flipper_length_mm, .975, na.rm = TRUE),
    `q2.5_flipper_length_mm` = quantile(flipper_length_mm, .025, na.rm = TRUE),
    iq_low_flipper_length_mm = quantile(flipper_length_mm, .25, na.rm = TRUE),
    iq_high_flipper_length_mm = quantile(flipper_length_mm, .75, na.rm = TRUE),
  ) %>% 
  filter(! is.na(sex))

flipper_plt <- 
  ggplot(
  flipper_length_stats,
  aes(y = species,
      x = mean_flipper_length_mm,
      xmin = `q2.5_flipper_length_mm`,
      xmax = `q97.5_flipper_length_mm`,
      shape = sex,
      color = sex)) + 
  geom_pointrange(position = position_dodge(width=.25)) + 
  scale_color_manual(values = c("#ff9f43", "#0abde3")) + 
  xlab("Flipper Length (mean and 95% Percentile Range) [mm]") + 
  ylab("Species") + 
  theme_bw() + 
  ggtitle("Flipper Length by Species and Sex")
  
# a little trick with inserting an image:
library(magick)
library(cowplot)

logo <- image_read("https://allisonhorst.github.io/palmerpenguins/reference/figures/lter_penguins.png") 

ggdraw() +
  draw_plot(flipper_plt) + 
  draw_image(logo, x = .6, y =-.25, width = .4)
