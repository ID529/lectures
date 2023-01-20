# Functional Programming


# dependencies ------------------------------------------------------------

library(tidyverse)
library(purrr)
library(palmerpenguins)

# the fundamental idea ----------------------------------------------------

u <- 1:100
v <- sample.int(n = 100, size = sample.int(n = 100, size = 1))
w <- c('a', 'b')
x <- c(1,2,3)
y <- list(a = c(10, 20, 30), b = "apple", c = mtcars, d = TRUE)
z <- NULL

# we could write 
length(u)
length(v)
length(w)
length(x)
length(y)
length(z)

# or we could write 
sapply(list(u, v, x, y, z), length)

# we used to use the *apply family functions that are built into base R
# sapply - tries to automatically infer the output format that you want
# apply - can be specified to operate on rows or columns 
# lapply - formats the output as a list 
# vapply - requires explicit declaration of the output format 

# purrr -------------------------------------------------------------------

# purrr provides an updated syntax to perform functional programming 

purrr::map(list(u, v, x, y, z), length)

purrr::map(list(u, v, x, y, z), ~length(.))

purrr::map_dbl(list(u, v, x, y, z), ~length(.))

purrr::map_df(list(u = u, v = v, x = x, y = y, z = z), ~length(.))

# working with multiple arguments

power <- function(x, y) {
  x ^ y
}

purrr::map(c(1,2,3,4,5), power, y = 2)

purrr::map(c(1,2,3,4,5), power, 3)

purrr::map_dbl(c(1,2,3,4,5), ~ power(., 2))

# some examples you might use ---------------------------------------------

penguins %>% purrr::map_chr(class)
penguins %>% purrr::map_chr(~class(.))

penguins %>% purrr::map_dbl(~ sum(is.na(.)))

penguins %>% purrr::map_dbl(~ sum(is.na(.))/length(.))

penguins %>% purrr::map_dbl(function(x) sum(is.na(x))/length(x))

proportion_na <- function(x) {
  sum(is.na(x)) / length(x)
}

penguins %>% purrr::map_dbl(proportion_na)

# functional programming with dplyr ---------------------------------------

penguins %>% mutate(across(where(is.numeric), round))

penguins %>% mutate(across(where(is.factor), tolower))

penguins %>% mutate(across(where(is.factor), ~ tools::toTitleCase(as.character(.))))

# I wouldn't use title casing for column names, but you could i guess: 
# colnames(penguins) <- tools::toTitleCase(colnames(penguins))

zscore <- function(x, na.rm = FALSE) {
  (x - mean(x, na.rm = na.rm)) / sd(x, na.rm = na.rm)
}

penguins %>% 
  mutate(across(where(is.numeric), zscore, na.rm = TRUE))
