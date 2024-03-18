# S062,63,74_adhoc.R

# User-inputs ----

# regular expression for all directories of interest
expt_dir_names <- 'S0(62|63|74)'


# Pre-requisites ----

# enable all prerequisites for a full-run
source('./0-general_functions_fcs.R') # call the function to load libraries and auxilliary functions

source('./0.5-user_inputs.R') # gather user inputs : file name, fluorescent channel names


# Merge data into combined directory -----

# older way to do this was in 'scripts_archive/obsolete_analyze_combined_fcs.R"
# S063 1a, 1b, 2 : test case
# Current way is vectorized!

# recognize directories with a regex pattern for expt name
dir.paths <- 
  map_chr(
    c('S063c_2_Ds, Rd second', 'S074_Rp again', 'S063b_1b_Pi, Rd'),
    ~ str_c(base_directory, .x)
  )


# testing on a single dir
tstdir <- dir.paths[[3]]

fl.set_tst <- get_fcs_and_metadata(tstdir, 
                                   subset_by_metadata = TRUE, specific_data = 'Pi')

tstpdat <- pData(fl.set_tst)


# implement with map2 on dir.paths and regexex for subsetting specific_data




# Compare metadata ----
# get metadata for a bunch of runs and compare


# Get directories

# recognize directories with a regex pattern for expt name
subdirs_multi_expts <- dir(base_directory, expt_dir_names) %>% 
  str_c('/') # add the trailing slash to the directory

# get metadata 
sample_metadata <- 
  map(subdirs_multi_expts,
      get_and_parse_plate_layout)

# name the list for informative retrieval
names(sample_metadata) <- subdirs_multi_expts

