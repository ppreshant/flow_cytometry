# Enter the User inputs in this script
# Will be sourced into relevant scripts ex: analyze_fcs.R

# Prashant ; 1/Aug/22

# user inputs ----

# include the trailing slash "/" in the folder paths
base_directory <- 'flowcyt_data/' # processed_data/ or flowcyt_data/
folder_name <- 'S048_e coli dilutions/' # 'foldername/'  # for Sony flow cyt : top directory for expt containing all fcs files

# for single file fcs guava data
file.name_input <- '' # input file name without .fcs
# Relevant only when reading a multi-data .fcs file (from Guava)

# title_name <- 'S045b-Vmax red dilutions' # provide a name for saving plot/as plot titles
title_name <- stringr::str_replace(folder_name, '/', '-raw') # Use the folder name without the slash


# regular expression to load only a subset of files : use '.*' for taking full data
# fcs_pattern_to_subset <- '[A-H]06|E0[7-9]'
fcs_pattern_to_subset <- '.*'

# Other parameters

Machine_type <- 'Sony' # Sony or Guava # use this to plot appropriate variables automatically
# To be implemented in future: using an if() to designate the names of the fluorescent channels 

# Fluorescence channel names
fluor_chnls <- c('red' = 'mScarlet-I-A', # change according to cytometer, fluorophores and for changing from area to width height etc.
        'green' = 'mGreenLantern cor-A')
# red = 'YEL-HLog' for Guava bennett or Orange-G-A.. for Guava-SEA ; and variable for Sony

# fluor_chnls <- c('red' = 'mcherry2-A',
#         'green' = 'gfpmut3-A')

# Scatter channel names
scatter_chnls <- c('fwd' = 'FSC-A', # set according to cytometer machine convention, and for changing from area to width height etc.
        'side' = 'SSC-A')


# FEATURE: can rename channels so that generic names can be used throughout the script : cf_rename_channel(x, old, new)
# FEATURE: in the future, can build in robustness to consider as fl channels the colnames "*-A" that are not FSC and SSC 