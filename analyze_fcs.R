# flow cytometry -- beginer level
# read .fcs file, visualize data


# Prelims ----
source('./0-general_functions_fcs.R') # call the function to load libraries and auxilliary functions

source('./0.5-user_inputs.R') # gather user inputs : file name, fluorescent channel names


# Run python/flowcal wrapper through R : for trimming data and doing MEFLs
# Experimental feature: This might be faster to run in direct python w jupyter-lab?
# rmarkdown::render('flowcal_html_output.Rmd', output_file = str_c('./FACS_analysis/html_outputs/', title_name, '.html'))


fl.path <- str_c(base_directory, folder_name, file.name_input, '.fcs')
dir.path <- str_c(base_directory, folder_name, file.name_input)
combined_data <- str_detect(folder_name, '_combined') # will be TRUE if folder_name contains "combined"

# Load fcs, metadata ----


# reading multiple data sets from .fcs file, writes to multiple .fcs files and re-reads as as cytoset
# also works with single multidata .fcs files from Guava machine

fl.set <- get_fcs_and_metadata(dir.path)


# check the sample names
# sampleNames(fl.set) # returns names as a vector
  # for a single file/cytoframe use "identifier(single_fcs)"
# pData(fl.set) %>% mutate(number = row_number()) %>% view() # data frame with column 'name' and numbering

# See the variables in the data : names of the channels
# colnames(fl.set) # vector


# Autodetect channels ----
if(autodetect_channels) {
  channels_used <- colnames(fl.set) %>% str_subset(use_channel_dimension) # ex: select only the -Area channels
  
  scatter_chnls <- channels_used %>% str_subset('(F|S)SC') %>% 
    set_names(str_replace_all(., scatter_direction_lookup)) # set names 
  
  fluor_chnls <- channel_colour_lookup %>% names %>% str_c(collapse = '|') %>% # collate all the fluore channel names
    {str_subset(channels_used, .)} %>% # subset the channels that match
    set_names(str_replace_all(., channel_colour_lookup)) # set names
}

# TODO : make this into a function -- so it can be run in analyze_combined_fcs?
# TODO: generalize for case insensitive matching

# Processing ----

# Saving summary stats from flowWorkspace function

# used for grouping and while making factors for ordering
metadata_variables <- c('assay_variable', 'sample_category', 'Fluorophore', if(combined_data) 'data_set') 

# get summary statistics
flowworkspace_summary <-
  summary(fl.set) %>% # base R's summary function : gives min, max, mean, median and quartiles; a column for each well and channel
  map( ~ as_tibble(.x, rownames = 'statistic') %>% # convert array into dataframe
         .[, c('statistic', fluor_chnls)]) %>% # select the relevant channels (avoiding dplyr, renaming issue with named vector)
  
  # Convert to a cleaner format
  {map2_df(.x = ., .y = names(.),
          ~ pivot_wider(.x,
                        names_from = statistic,
                        values_from = all_of(set_names(fluor_chnls, NULL)),
                        names_glue = "{statistic}_{.value}"
            ) %>%

            add_column(filename = .y)

            )} %>%
  select(filename, everything()) %>%  # gives the min, max quartiles, mean for fluorescence channels
  
  # fish out well information from filename
  mutate(well = if(combined_data) {str_match(filename, '_([A-H][:digit:]+)') %>% .[,2] # look for well after underscore (combined data)
  } else  str_extract(filename, '[A-H][:digit:]+') # regular data - well should be clear (could use ^ : start with)
  ) %>%
  
  # attach metadata by well
  left_join(sample_metadata) %>%  # attach the metadata : sample names from google sheets (, by = 'well')

  
  # reshape data for ease of use by code
  pivot_longer(matches('-A$'),
               names_to = c('measurement', 'Fluorophore'), # split columns
               names_pattern = '(.*)_(.*)') %>% 
  pivot_wider(names_from = measurement, values_from = value) %>%  # put mean, median .. in separate columns
  
  # get mean of replicates
  group_by(across(all_of(metadata_variables))) %>% # group -- except replicate
  mutate(mean_medians = mean(Median)) %>%  # find the mean of replicates
  ungroup() %>% 
  
  # arrangement by median of red fluorescence in ascending order
  arrange_in_order_of_fluorophore # freeze the order of these columns for plotting


# Make a list of metadata elements to order the data in the figures by
list_of_ordered_levels <- arrange_in_order_of_fluorophore(flowworkspace_summary, to_return = 'ordered')



# Save summary stats ----


# These are slightly different from the flowCal data (due to some weird transformations).
# But this will match the distributions plotted by R

if(save_summary_stats_from_R) {
  write.csv(flowworkspace_summary,
            str_c('FACS_analysis/tabular_outputs/', title_name, '_R-summary', '.csv'),
            na = '')   }

# TODO : could prevent rewrites using file.exists() function..


# ridgeline plots ----

# Run the below portions of the script to manually to make ggplots of density and scatter etc 
# -- time intensive, so run required subsets and not entire data

if(make_ridge_line_plots) source('scripts_general_fns/7-exploratory_data_view.R')


# Gating (*manual) ----

# Run manually the script 11-manual_gating_workflow.R in the scripts_archive folder

# Note: Will need to select the representative data to gate on ; around line 11
# single_fcs <- fl.set[[x]] # select a representative sample to set gates on

