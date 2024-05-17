# Enter the User inputs in this script
# Will be sourced into relevant scripts ex: analyze_fcs.R

# Prashant ; 1/Aug/22

# user inputs ----

# include the trailing slash "/" in the folder paths
base_directory <- 'processed_data/' # processed_data/ or flowcyt_data/ and any subfolders

# for Sony flow cyt : top directory for expt containing all fcs files
folder_name <- 'S089_combined/' # 'foldername/'  

# Name of .fcs file to read: Relevant only when reading a multi-data .fcs file (from Guava)
# Leave this empty using '' for reading multiple .fcs files from the folder_name mentioned above
file.name_input <- '' # input file name without .fcs


# get templates from google sheet or from data excel file
template_source <- "googlesheet" # googlesheet/excel = parse through a list of templates in the respective formats and
# get the template with the matching qxx ID. 'excel' looks for the file 'excel files/Plate layouts.xlsx'

# regular expression to load only a subset of files : use '.*' or NULL for taking full data
# fcs_pattern_to_subset <- '[A-H]06|E0[7-9]'
fcs_pattern_to_subset <- NULL # leave as NULL if you need all files or use '.*.fcs'

# Channel to order ridgeplots by
order_by_channel <- 'red' # decide 'red' or 'green' or other colour key within "channel_colour_lookup" above

# Make ridgelineplots ? Make False if plots already made or want to skip
make_ridge_line_plots <- TRUE 

# Show median lines and labels in ridgeplot? enable only when ridges don't overlap too much
show_medians <- TRUE

# Save summary stats through R as .csv: mean, median, quartiles
save_summary_stats_from_R <- TRUE


# secondary inputs ----

# TODO: include combined data workflow into analyze_fcs.R
# get user input directory regex and combined dir name and a switch

# Decide if you want ridge plots y for each data_set / key (=> facet by assay_var)
ridge_plot_by_data_set <- FALSE # make it TRUE to make ridgeplot y as data directory (use case: days)
# only works on combined data sets!

# directory for saving the summary stats
summary_base_directory <- 'FACS_analysis/tabular_outputs/'


# calculated values ----

# title_name <- 'S045b-Vmax red dilutions' # provide a name for saving plot/as plot titles
fl_suffix = if_else(str_detect(base_directory, 'processed_data'), '-processed', '-raw')

title_name <- stringr::str_replace(folder_name, '/$', fl_suffix) # Use the folder name without the slash, -raw suffix
# TODO : make an if for raw vs processed based on the base_directory with str_detect()..



# Other parameters ----
# for future automating autodetection of channel names 


Machine_type <- 'Sony' # Sony or Guava/Bennett or Guava/SEA # use this to plot appropriate variables automatically
# To be implemented in future: using an if() to designate the names of the fluorescent channels 
# probably obsolete?


# Channel names ----
autodetect_channels <- TRUE # make it TRUE so the fluorescence and scatter channels are auto-detected with below dimension, 
# else uses the channel names given below

use_channel_dimension <- '-A$' # indicate the first letter : for Area, Height or Width.. (typically Area is better)
# -HLog for Guava/Bennett ; 
# TODO: Will try to autodetect the scatter channels and designate other ones as fluorescence -- will only work for Sony/BRC currently

# add more colourr/fluorophore names as needed
channel_colour_lookup <- c('.*(mScarlet|mcherry|RFP|YEL).*' = 'red', # uses regex matching to assign the colour to colourkey
                           '.*(mGreenLantern|gfp|GFP|GRN).*' = 'green')

scatter_direction_lookup <- c('FSC.*' = 'fwd', 'SSC.*' = 'side') # regex matching to assign the side/fwd



# Fluorescence channel names :: default / ignore this if not autodetecting, check "channel_colour_lookup" above
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


# Error checks ----

# ensure that folder_name has a '/' in the end
if(!str_detect(folder_name, '/$')) stop('Did you forget the slash (/) in the folder_name?')

