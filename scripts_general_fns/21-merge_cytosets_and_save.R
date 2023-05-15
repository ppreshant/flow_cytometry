# merge_cytosets_and_save.R
# adhoc script to merge cytosets and save them into a folder

# Prelims ----
source('./0-general_functions_fcs.R') # call the function to load libraries and auxilliary functions

source('./0.5-user_inputs.R') # gather user inputs : file name, fluorescent channel names


# Inputs ----

# the combined dataset will be exported to this folder inside 'processed_data/..'
fcs_export_dir <- 'S071_combined/' # end with "_combined"


# manual workflow ----
# Use this to load files, manually change the pData (which goes into file renaming) before calling the saver


# fix pData manually
manual_modify_pdata <- function(.pdata)
{
  
  # for filling abbreviations in sample_category
  sample_cat_fill <- c('^U' = 'Uninduced', '^I' = 'Induced') 
  
  new_pdata2 <- .pdata %>% 
    
    # separate day from `U-d0` into a `dir_key` column
    separate(sample_category, into = c('sample_category', 'dir_key'), sep = '-') %>% # add new category for directory
    
    mutate(across(dir_key, # fix d-1 trunc and make controls as d-1 
                  ~ replace_na(.x, 'd-1') %>% str_replace('d$', 'd-1') )) %>% 
    
    
    # fill abbreviations of induced and uninduced
    mutate(across(sample_category, 
                  ~ str_replace_all(.x, sample_cat_fill))) 
  
  # TODO : include optional calculations for the other variable, for facetting S066-67 data
}

# for single dir : Load data, modify and write : Uncomment to use
# fl.set <- get_fcs_and_metadata(str_c(base_directory, folder_name, file.name_input),
#                                manually_modify_pdata = T, # needs a function `manual_modify_pdata` -- above
#                                rename_and_save_fcs = T)

# Vectorized merger ----
# iterate through the list of folders and put them all into the export folder specified above



# Get directories ----

# recognize directories with a regex pattern for expt name
subdirs <- dir(base_directory, '^S071._') %>% 
  str_c('/') # add the trailing slash to the directory

# dir.paths <- str_c(base_directory, subdirs)


# manual subdirectory building (uncomment to use)

# Geared for S050 ; but edit as necessary (one time use anyway right?) 
# days <- 1:8 # -1:8 # User inputs
# 
# dir.paths = map(days, ~ str_c(base_directory, 'S050_d', .x, '/')) # Make a list of folders



# Modify-rename-save ----
# with same metadata for all directories

# get metadata -- enable if using only once for all data/ else use .get_metadata = T below
# sample_metadata <- get_and_parse_plate_layout(folder_name) 

# vectorized to work in all of the dir paths loaded above

# rm(folder_name) # remove this from the global environment to prevent confusion
# subdirs %>%
#   map( \(x) 
#        {folder_name <- x ; dir.path <- str_c(base_directory, x) ; # set assignments
#          get_fcs_and_metadata(.dirpath = dir.path,
#                               
#                               # other inputs to the function
#                               .get_metadata = F,
#                               manually_modify_pdata = T, # needs a function `manual_modify_pdata` -- above
#                               
#                               rename_and_save_fcs = T, .interactive_session = T)} )

dir.paths %>% map(get_fcs_and_metadata,
                  manually_modify_pdata = T, # needs a function `manual_modify_pdata` -- above
                  rename_and_save_fcs = T, .interactive_session = T)


# for same metadata workflow : S050
# dir.paths %>% map(get_fcs_and_metadata, .get_metadata = F,
#                   rename_and_save_fcs = T, .interactive_session = F)


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


