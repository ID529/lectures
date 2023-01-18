# Visualizing Missingness Patterns


# dependencies ------------------------------------------------------------

library(palmerpenguins)
library(VIM)
library(tidyverse)
library(gtsummary)
library(plotly)


# missingness in tables ---------------------------------------------------

# just keep in mind that gtsummary will automatically report the proportion
# missing for you for each variable
gtsummary::tbl_summary(penguins)

# visualize missingness ---------------------------------------------------

# first, let's just look by variable
VIM::aggr(penguins)

# google: vim aggr missing labels
# https://stackoverflow.com/questions/44913864/r-automatically-expand-margins-in-vimaggr-plots
VIM::aggr(penguins, oma = c(10,5,5,3))

# alternatively, this is not so hard to do on your own
penguins %>% 
  purrr::map(function(x) sum(is.na(x))/length(x)) %>% 
  as.data.frame() %>% 
  t.data.frame() %>% 
  as.data.frame() %>% 
  tibble::rownames_to_column(var = "variable") %>% 
  rename("prop_missing" = "V1") %>% 
  ggplot(aes(x = variable, y = prop_missing)) + 
  geom_col()



# visualize missingness patterns ------------------------------------------

penguins %>% 
  mutate(
    sex = forcats::fct_explicit_na(sex)
  ) %>% 
  ggplot(
       aes(
         x = bill_length_mm,
         y = bill_depth_mm,
         color = interaction(sex, species),
         shape = sex,
         size = ifelse(sex == '(Missing)', 'large', 'small'),
         alpha = ifelse(sex == '(Missing)', 'dark', 'light')
       )) + 
  geom_point() + 
  scale_size_manual(
    values = c('large' = 2, 'small' = 1.5)
  ) + 
  scale_shape_manual(values = c(15,16,1)) + 
  scale_alpha_manual(values = c(dark = 1, light = .7)) + 
  guides(
    alpha = guide_none(),
    size = guide_none()
  ) + 
  theme_bw()

ggplotly()
