# =============================================================================
# title: style guide
# author: Shannon Chang and Nura Kawa
#
# description: this is a guide on how we write scripts and commit messages
# for purpose of consistency.
#
# output files: 
# =============================================================================

# general rule: always use lower-case letters for writing.

# =============================================================================
# writing R code
# =============================================================================

# comment on what you will do!

# this-is-a-filename.png
# function_name <- function()
# variable_name <- x

# =============================================================================
# writing things
# =============================================================================

# please include one item per line for multi-argument functions.

# for example:

plot(x,
     y,
     main = "name of plot",
     pch = 16,
     col = "tomato")

lm(y~x,
   data = our_data)

lapply(our_data,
       our_function)


# keep your assignment arrows level

# apple   <- 3
# oranage <- 4
# banana  <- 5

# =============================================================================
# commit messages
# =============================================================================

# remember: for commit messages use everything lowercase!
# to fix bug use commit message: bugfix: or typo: or initial commit
