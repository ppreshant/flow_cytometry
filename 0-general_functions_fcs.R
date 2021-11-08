# Functions to load qPCR data and manipulate it. The functions can be called from another R file

# read in excel file (.xls) of qPCR exported from Quantstudio 3 
# Make sure to include raw data as well

# Library calling  ----
# calling libraries ; make sure they are installed (install.packages)
library(tidyverse)  # general data handline
library(flowCore) # flow cytometry data types library
library(flopr)  # flow cytometry specific library
library(ggcyto) # plotting package for flow cytometry data


# dummy data  ---- 
# or test data for testing simple functions 

# dummy test tibble
a <- tibble(a1 = 1:6, a2 = 6:1, a3 = rep(c('a', 'b'),3), a4 = a2 ^2)

# calling more funs in separate scripts ----

list_of_general_functions <- c("1-reading_multidata_fcs.R",
                               "2-get_number_of_datasets_fcs.R")

# Source all the functions listed above
map(str_c('./scripts_general_fns/', list_of_general_functions),
    source)
