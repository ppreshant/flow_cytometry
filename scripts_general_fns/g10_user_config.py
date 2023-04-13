# -*- coding: utf-8 -*-
""" User inputs to analyze_fcs_flowcal

Enter the experimental folder to find fcs files in
and names of scatter and fluorescence channels according to your instrument
hint: use command fcs_data[0].channels to see the names of the channels

Created on Wed Jun  1 01:00:43 2022

@author: Prashant
"""

# %% User inputs 
# paths are relative to the working directory
# without the trailing slash "/"
fcs_root_folder = 'flowcyt_data'
fcs_experiment_folder = 'S067b1_143_ww'

# Input a regular expression to subset a limited number of wells

# Choose a density gate fraction : 0.5 (50%) is decent, if you need to retain more events try 80%
# for very poor data with lots of debris/noise, try 30% 
density_gating_fraction = .5

# Important: Select "all" ONLY if you want detailed plots of the processing steps for each .fcs file
# making plots takes very long: 
# Select 'first n' to generate the first few plots for visualization -- first 3 or 5 is good idea
# Select 'random n' to generate plots for n random .fcs files
# select None to skip plots -- None is without quotes
make_processing_plots = 'random 5'


# Give the pattern/well to match the bead file (ex: E01 etc.) - if present in current dataset / else skips MEFLing
beads_match_name = 'beads' # None skips beads continues processing. use well; Ex: 'A06' or foldername. Searches for match to the path -- I make a group for beads when running samples to save in a folder named 'beads' (for Sony machines)

# Optional: Get a custom beads file from a different folder with regex (if not present in current dataset)
retrieve_custom_beads_file = False # make true to use the file from below else will autodetect from dataset / skip MEFLing if not found

if retrieve_custom_beads_file :
    from scripts_general_fns.g4_file_inputs import get_fcs_files # function for reading in .fcs files
    beads_filepath, beads_filename = get_fcs_files(fcs_root_folder + '/' + 'S050/S050_d-1/*/Beads/') # use the [0] subset from these lists


# %% Channel paremeters 

# parameters for auto-recognizing channels
use_channel_dimension = '-A$' # indicate the first letter : for Area, Height or Width, '-HLog'.. (typically Area is better)
# TODO : default to -A$ and if not found, then provide other things

channel_lookup_dict = {'fluorescence': 'mScarlet|mcherry|YEL|mGreenLantern|gfp|GRN', # uses regex matching to assign the fluorescence
                       'scatter': 'FSC|SSC'} # and scattering channels
# Add more/standardized names for other instruments etc.

# Default channels to use : names change according to the flow cytometer machine
# Feature: get code to use this in case the auto-recognition fails
# scatter_channels = ['FSC-A', 'SSC-A']
# fluorescence_channels = ['mGreenLantern cor-A', 'mScarlet-I-A']
# to check how the channels are named -
# fcs_data[0].channels


