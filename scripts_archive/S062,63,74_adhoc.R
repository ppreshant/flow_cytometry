# S062,63,74_adhoc.R

# User-inputs ----

# regular expression for all directories of interest
expt_dir_names <- 'S0(62|63|74)'


# Pre-requisites ----

# enable all prerequisites for a full-run
# source('./0-general_functions_fcs.R') # call the function to load libraries and auxilliary functions

source('./0.5-user_inputs.R') # gather user inputs : file name, fluorescent channel names

# minimal-prerequisites
library(tidyverse) # data manupulation basics
source('./scripts_general_fns/12-read_layout_fns.R')
# google sheets
sheeturls <- list(plate_layouts_PK = 'https://docs.google.com/spreadsheets/d/1RffyflHCQ_GzlRHbeH3bAkiYo4zNlnFWx4FXo7xkUt8/edit#gid=0')

# pre-authorization for google sheets: Works if there is only 1 cached account (after first access)
googlesheets4::gs4_auth(email = TRUE) # reference: https://googlesheets4.tidyverse.org/reference/gs4_auth.html


# Compare metadata ----
# get metadata for a bunch of runs and compare


# Get directories

# recognize directories with a regex pattern for expt name
subdirs <- dir(base_directory, expt_dir_names) %>% 
  str_c('/') # add the trailing slash to the directory

# get metadata 
sample_metadata <- 
  map(subdirs,
      get_and_parse_plate_layout)

# name the list for informative retrieval
names(sample_metadata) <- subdirs

