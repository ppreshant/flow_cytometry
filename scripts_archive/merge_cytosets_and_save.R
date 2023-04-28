# merge_cytosets_and_save.R
# adhoc script to merge cytosets and save them into a folder

# Prelims ----
source('./0-general_functions_fcs.R') # call the function to load libraries and auxilliary functions

source('./0.5-user_inputs.R') # gather user inputs : file name, fluorescent channel names


# Inputs ----

# the combined dataset will be exported to this folder inside 'processed_data/..'
fcs_export_dir <- 'S050_combined' # end with "_combined"


# new style ----
# iterate through the list of folders and put them all into the export folder specified above

# Geared for S050 ; but edit as necessary (one time use anyway right?) 

# User inputs
days <- -1:8

# Make a list of folders
dir.paths = map(days, ~ str_c(base_directory, 'S050_d', .x, '/'))


# General rename-save ----
# vectorized to work in all of the dir paths loaded above

source('scripts_general_fns/20-rename_fcs_and_save.R')
dir.paths %>% map(get_fcs_and_metadata, .get_metadata = F,
                  rename_and_save_fcs = T) # .interactive_session = F,
  
# work in progress ; vectorize this over dir.paths now..



# Old script -----
# run till line 14 of `analyze_combined_fcs.R`





# Get data ----

# run general analyze_fcs.R and save each fl.set iteration as a cytoset variable to store the data to be combined
# flset1 <- fl.set
# in future this could be a map command - returning a list of cytoframes ; 
# can unlist / map rbind2 somehow (read map cheatsheet)  
# :https://raw.githubusercontent.com/rstudio/cheatsheets/master/purrr.pdf


# Combine data ----

# fix overlapping sample names
library(magrittr) # required for assignment pipe : "%<>%"

# walk over each flset and add a prefix to their sample names 
walk2(list(flset1, flset2, flset3),
      letters[1:3],
      ~ sampleNames(.x) %<>% {str_c(.y, '_', .)})
# TODO : add the letters into individual pData first before combining cytosets?

# combine the cytosets
fl.set <- list(flset1, flset2, flset3) %>% reduce(rbind2) %>% flowSet_to_cytoset() # combine two at a time


# Polish ----

# Add categories to pData of the superset
new_pdata <- pData(fl.set) %>% 
  
  mutate(other_category = str_replace_all(name, sample_name_translation)) # split names into categories

pData(fl.set) <- new_pdata # replace the pData


# Data export ----


# Save backup data of the superset with easier names (write.FCS)
dir.create(str_c('processed_data/', fcs_export_dir, '/')) # create the new directory

mutate(new_pdata,
       new_flnames = str_c(str_replace(name, ' /', '_'), 
                           well, # unique names by well
                           rownames(new_pdata) %>% str_extract('^(.)'), # add plate id letter (a, b, c etc.)
                           sep = '_')) %>%
  pull(new_flnames) %>% # get the new filenames
  
  {str_c('processed_data/', fcs_export_dir, '/', # make filepaths for all the above filenames
         ., '.fcs')} %>% # make file path
  
  {for (i in 1:length(.)) {write.FCS(fl.set[[i]], filename = .[i])}} # save each .fcs file by looping


