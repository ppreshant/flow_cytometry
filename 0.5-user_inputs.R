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
title_name <- stringr::str_replace(folder_name, '/$', '-raw') # Use the folder name without the slash, -raw suffix


# regular expression to load only a subset of files : use '.*' for taking full data
# fcs_pattern_to_subset <- '[A-H]06|E0[7-9]'
fcs_pattern_to_subset <- '.*'

# Other parameters ----
# for future autodetection stuff 

Machine_type <- 'Sony' # Sony or Guava # use this to plot appropriate variables automatically
# To be implemented in future: using an if() to designate the names of the fluorescent channels 


# Channel names ----
autodetect_channels <- TRUE # make it TRUE so the fluorescence and scatter channels are auto-detected with below dimension, 
# else uses the channel names given below

use_channel_dimension <- '-A$' # indicate the first letter : for Area, Height or Width.. (typically Area is better)
# Will try to autodetect the scatter channels and designate other ones as fluorescence -- will only work for Sony/BRC currently

channel_colour_lookup <- c('(mScarlet|mcherry).*' = 'red', # uses regex matching to assign the colour
                           '(mGreenLantern|gfp).*' = 'green')

scatter_direction_lookup <- c('FSC.*' = 'fwd', 'SSC.*' = 'side') # regex matching to assign the side/fwd



# Fluorescence channel names :: default / if not autodetecting
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