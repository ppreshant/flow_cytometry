# Enter the User inputs in this script
# Will be sourced into relevant scripts ex: analyze_fcs.R

# Prashant ; 1/Aug/22

# user inputs ----

# include the trailing slash "/" in the folder paths
base_directory <- 'flowcyt_data/S050/' # processed_data/ or flowcyt_data/
folder_name <- 'S050_d1/' # 'foldername/'  # for Sony flow cyt : top directory for expt containing all fcs files

# for single file fcs guava data
file.name_input <- '' # input file name without .fcs
# Relevant only when reading a multi-data .fcs file (from Guava)

# title_name <- 'S045b-Vmax red dilutions' # provide a name for saving plot/as plot titles
title_name <- stringr::str_replace(folder_name, '/', '-raw') # Use the folder name without the slash

Machine_type <- 'Sony' # Sony or Guava # use this to plot appropriate variables automatically
# To be implemented in future: using an if() to designate the names of the fluorescent channels 

# Fluorescence channel names
ch <- c('red' = 'mScarlet-I-A', # change according to cytometer, for changing from area to width height etc.
        'green' = 'mGreenLantern cor-A')

# Scatter channel names
sc <- c('fwd' = 'FSC-A', # change according to cytometer, for changing from area to width height etc.
        'side' = 'SSC-A')

# ch <- c('red' = 'mcherry2', 
#         'green' = 'gfpmut3b')
