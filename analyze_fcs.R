# flow cytometry -- beginer level
# read .fcs file, visualize data


# Prelims ----
source('./0.5-user_inputs.R') # gather user inputs : file name, fluorescent channel names

source('./0-general_functions_fcs.R') # call the function to load libraries and auxilliary functions


fl.path = str_c(base_directory, folder_name, file.name_input, '.fcs')

# Load data ----


# reading multiple data sets from .fcs file, writes to multiple .fcs files and re-reads as as cytoset
# also works with single multidata .fcs files from Guava machine

fl.set <- read_multidata_fcs(fl.path, # returns multiple fcs files as a cytoset (package = flowWorkspace)
                             fcs_pattern_to_subset = fcs_pattern_to_subset,
                          directory_path = str_c(base_directory, folder_name, file.name_input))

# check the sample names
# sampleNames(fl.set) # returns names as a vector
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


# Inspecting data ----

# Run this script to make ggplots of density and scatter for all files -- time intensive
# source('scripts_general_fns/7-exploratory_data_view.R')


# Processing ----

# Currently using processed files from custom python script based on FlowCal.py

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


# Gating ----



# Processing ----



# Plotting ----


# Save dataset ----


