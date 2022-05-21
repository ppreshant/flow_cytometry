# flow cytometry -- beginer level
# read .fcs file, visualize data

# user inputs ----

# include the trailing slash "/" in the folder paths
folder_name <- 'S044_new fusions_4-5-22/' # 'foldername/'

file.name_input <- '' # input file name without .fcs
# Relevant only when reading a multi-data .fcs file (from Guava)

title_name <- 'S044:mScarlet-U64 fusions_flowcyt'

Machine_type <- 'Sony' # Sony or Guava # use this to plot appropriate variables automatically
# To be implemented in future: using an if() to designate the names of the fluorescent channels 

# Prelims ----
source('./0-general_functions_fcs.R') # call the function to load libraries and auxilliary functions


fl.path = str_c('flowcyt_data/', folder_name, file.name_input, '.fcs')


# Load data ----


# reading multiple data sets from .fcs file, writes to multiple .fcs files and re-reads as as cytoset

fl.set <- read_multidata_fcs(fl.path, # returns multiple fcs files as a cytoset (package = flowWorkspace)
                          directory_path = str_c('flowcyt_data/', folder_name, file.name_input))


# read the Mean equivalent fluorophores for the peaks
beads_values <-
  read.csv('flowcyt_data/calibration_beads_sony.csv') %>% 
  select(FITC, 'PE.TR') %>%  # Retain only relevant channels
  rename('mGreenLantern cor-A' = 'FITC', # rename to fluorophores used in Sony
         'mScarlet-I-A' = 'PE.TR') %>% 
  
  map2(., colnames(.), # make into a nested list
       ~ list(channel = .y, peaks = .x))

# Inspecting data ----

# Run this script to make ggplots of density and scatter for all files -- time intensive
# source('scripts_general_fns/7-exploratory_data_view.R')


# Processing ----

# using FlopR single file processing : : error : 'x' must be object of class 'flowFrame'
# process_fcs('flowcyt_data/S044_new fusions_4-5-22/96 Well Plate (deep)/Sample Group - 1/Unmixing-1/F11 Well - F11 WLSM.fcs',
#             flu_channels = c('mScarlet-I-A'),
#             do_plot = T
#             )

ptm <- proc.time() # time initial
process_fcs_dir(dir_path = str_c('flowcyt_data', 'test', sep = '/'), 
                pattern = '.fcs',
                flu_channels = c('mScarlet-I-A'),
                neg_fcs = 'E03',
                
                calibrate = TRUE,
                mef_peaks = beads_values
                )
proc.time() - ptm # time duration of the run


# Gating ----



# Processing ----



# Plotting ----


# Save dataset ----


