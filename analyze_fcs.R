# flow cytometry -- beginer level
# read .fcs file, visualize data


# Prelims ----
source('./0-general_functions_fcs.R') # call the function to load libraries and auxilliary functions

source('./0.5-user_inputs.R') # gather user inputs : file name, fluorescent channel names


# Run python/flowcal wrapper through R : for trimming data and doing MEFLs
# Experimental feature: This might be faster to run in direct python w jupyter-lab?
# rmarkdown::render('flowcal_html_output.Rmd', output_file = str_c('./FACS_analysis/html_outputs/', title_name, '.html'))


fl.path = str_c(base_directory, folder_name, file.name_input, '.fcs')

# Load data ----


# reading multiple data sets from .fcs file, writes to multiple .fcs files and re-reads as as cytoset
# also works with single multidata .fcs files from Guava machine

fl.set <- read_multidata_fcs(fl.path, # returns multiple fcs files as a cytoset (package = flowWorkspace)
                             fcs_pattern_to_subset = fcs_pattern_to_subset,
                          directory_path = str_c(base_directory, folder_name, file.name_input))

# check the sample names
# sampleNames(fl.set) # returns names as a vector
  # for a single file/cytoframe use "identifier(single_fcs)"
# pData(fl.set) %>% mutate(number = row_number()) %>% view() # data frame with column 'name' and numbering

# See the variables in the data : names of the channels
# colnames(fl.set) # vector


# metadata ----

# Read the sample names and metadata from google sheet
sample_metadata <- get_and_parse_plate_layout(str_c(folder_name, file.name_input))

# # read the Mean equivalent fluorophores for the peaks
# beads_values <-
#   read.csv('flowcyt_data/calibration_beads_sony.csv') %>% 
#   select(FITC, 'PE.TR') %>%  # Retain only relevant channels
#   rename('mGreenLantern cor-A' = 'FITC', # rename to fluorophores used in Sony
#          'mScarlet-I-A' = 'PE.TR') %>% 
#   
#   map2(., colnames(.), # make into a nested list
#        ~ list(channel = .y, peaks = .x))


# Autodetect channels ----
if(autodetect_channels) {
  channels_used <- colnames(fl.set) %>% str_subset(use_channel_dimension) # ex: select only the -Area channels
  
  scatter_chnls <- channels_used %>% str_subset('(F|S)SC') %>% 
    set_names(str_replace_all(., scatter_direction_lookup)) # set names 
  
  fluor_chnls <- channel_colour_lookup %>% names %>% str_c(collapse = '|') %>% # collate all the fluore channel names
    {str_subset(channels_used, .)} %>% # subset the channels that match
    set_names(str_replace_all(., channel_colour_lookup)) # set names
}


# Attach metadata ----
new_pdata <- pData(fl.set) %>% 
  mutate(well = str_extract(name, '[A-H][:digit:]+')) %>% # detect the well numbers
  rename(original_name = name) %>% # rename the "name" column
  
  left_join(sample_metadata, by = 'well') %>% # join the metadata -- assay_variable, Sample_category etc. 
  
  
  column_to_rownames('original_name') # remake the rownames -- to enable attachment
  
  # # Does arrangement and factor help plotting order in ggcyto? no..
  # arrange(sample_category, assay_variable) %>% 
  # mutate(across(c(sample_category, assay_variable), fct_inorder))

pData(fl.set) <- new_pdata # replace the pData

# Inspecting data (*manual) ----

# Run this script to make ggplots of density and scatter for all files -- time intensive, so run required subsets
# source('scripts_general_fns/7-exploratory_data_view.R')



# Processing ----

# Saving summary stats from flowWorkspace function

metadata_variables <- c('assay_variable', 'sample_category', 'Fluorophore') # used for grouping and while making factors for ordering

# get summary statistics
flowworkspace_summary <-
  summary(fl.set) %>% # base R's summary function : gives min, max, mean, median and quartiles; a column for each well and channel
  map( ~ .x[, fluor_chnls]) %>% # select the relevant channels
  
  # Convert to a cleaner format
  {map2_df(.x = ., .y = names(.),
          ~ as_tibble(.x, rownames = 'statistic') %>% # make a dataframe with fluor channels only
            pivot_wider(names_from = statistic,
                        values_from = all_of(set_names(fluor_chnls, NULL)),
                        names_glue = "{statistic}_{.value}"
            ) %>%

            add_column(filename = .y)

            )} %>%
  select(filename, everything()) %>%  # gives the min, max quartiles, mean for fluorescence channels
  
  
  # attach metadata
  mutate(well = str_extract(filename, '[A-H][:digit:]+')) %>% # detect the well numbers
  
  left_join(sample_metadata, by = 'well') %>%  # attach the metadata : sample names from google sheets

  
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

write.csv(flowworkspace_summary,
          str_c('FACS_analysis/tabular_outputs/', title_name, '_R-summary', '.csv'),
          na = '')
# could prevent rewrites using file.exists() function..

# Gating (*manual) ----

# Run manually the script 11-manual_gating_workflow.R in the scripts_archive folder

# Note: Will need to select the representative data to gate on ; around line 11
# single_fcs <- fl.set[[x]] # select a representative sample to set gates on



# Obsolete/ R processing ----

# Currently using processed files from custom python script based on FlowCal.py ; So ignore this section


# The below was attempts to use R based processing similar to FlowCal -- fails in gating for cells due to noisy data
# is also 60 times slower than FlowCal (without plotting for both)

# # using FlopR single file processing : : error : 'x' must be object of class 'flowFrame'
# process_fcs('flowcyt_data/S044_new fusions_4-5-22/96 Well Plate (deep)/Sample Group - 1/Unmixing-1/F11 Well - F11 WLSM.fcs',
#             flu_channels = c('mScarlet-I-A'),
#             do_plot = T
#             )

# # FlopR full directory processing
# ptm <- proc.time() # time initial
# process_fcs_dir(dir_path = str_c('flowcyt_data', 'test', sep = '/'), 
#                 pattern = '.fcs',
#                 flu_channels = c('mScarlet-I-A'),
#                 neg_fcs = 'E03',
#                 
#                 calibrate = TRUE,
#                 mef_peaks = beads_values
#                 )
# proc.time() - ptm # time duration of the run
