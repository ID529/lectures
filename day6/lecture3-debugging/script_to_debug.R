func1 <- function(x) { x - func2(x) }
func2 <- function(y) { y * func3(y) }
func3 <- function(z) {
  r <- log(z)
  if (r < 10) {
    r^2
  } else {
    r^3
  }
}

func1(10)
func1(1)
func1(-10)

traceback()

