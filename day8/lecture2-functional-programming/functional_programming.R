# Functional Programming


# dependencies ------------------------------------------------------------

library(tidyverse)
library(purrr)

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

