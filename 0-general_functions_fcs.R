# Functions to load qPCR data and manipulate it. The functions can be called from another R file

# read in excel file (.xls) of qPCR exported from Quantstudio 3 
# Make sure to include raw data as well

# Library calling  ----
# calling libraries ; make sure they are installed (install.packages)
library(flowCore) # flow cytometry data types library
library(flopr)  # flow cytometry specific library
library(ggcyto) # plotting package for flow cytometry data
library(tidyverse)  # general data handline

# Sources ----

# google sheets
sheeturls <- list(plate_layouts_PK = 'https://docs.google.com/spreadsheets/d/1RffyflHCQ_GzlRHbeH3bAkiYo4zNlnFWx4FXo7xkUt8/edit#gid=0')

# pre-authorization for google sheets: Works if there is only 1 cached account (after first access)
googlesheets4::gs4_auth(email = TRUE) # reference: https://googlesheets4.tidyverse.org/reference/gs4_auth.html


# dummy data  ---- 
# or test data for testing simple functions 

# dummy test tibble
a <- tibble(a1 = 1:6, a2 = 6:1, a3 = rep(c('a', 'b'),3), a4 = a2 ^2)

# calling more funs in separate scripts ----

list_of_general_functions <- c("1-reading_multidata_fcs.R",
                               "2-get_number_of_datasets_fcs.R",
                               "6-wrappers_utilities.R",
                               "12-read_layout_fns.R",
                               "13-formatting_plot_funs.R")

# Source all the functions listed above
map(str_c('./scripts_general_fns/', list_of_general_functions),
    source)
