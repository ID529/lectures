library(tidyverse)
scrabble_points <- function(word) {
  stopifnot(class(word) == 'character')
  stopifnot(length(word) == 1)
  score <- 0
  word <- tolower(word)
  for (i in 1:nchar(word)) {
    letter <- substring(word, i, i)
    case_when(
      letter %in% c('a', 'e', 'i', 'o', 'u', 'l', 'n', 's', 't', 'r') ~ { score <- score + 1 },
      letter %in% c('d', 'g') ~ { score <- score + 2 },
      letter %in% c('b', 'c', 'm', 'p') ~ { score <- score + 3 },
      letter %in% c('f', 'h', 'v', 'w', 'y') ~ { score <- score + 4 },
      letter == 'k' ~ { score <- score + 5 } ,
      letter %in% c('j', 'x') ~ { score <- score + 8 },
      letter %in% c('q', 'z') ~ { score <- score + 10 }
    )
  }
  score
}
scrabble_points("quixotic")
