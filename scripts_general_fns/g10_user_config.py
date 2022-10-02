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
fcs_experiment_folder = 'S050/S050_d1'

# Input a regular expression to subset a limited number of wells

# Choose a density gate fraction : 0.5 (50%) is decent, if you need to retain more events try 80%
density_gating_fraction = .8

# Give the pattern/well to match the bead file (ex: E01 etc.) - if present in current dataset
beads_match_name =  'beads' # beads data is saved in a group/folder named beads for (Sony)

# Optional: Get a custom beads file from a different folder with regex (if not present in current dataset)
retrieve_custom_beads_file = True # make true to use the file from below else will autodetect from dataset

from scripts_general_fns.g4_file_inputs import get_fcs_files # function for reading in .fcs files
beads_filepath, beads_filename = get_fcs_files(fcs_root_folder + '/' + 'S050/S050_d-1/*/Beads/') # use the [0] subset from these lists


# %% Channel paremeters 

# parameters for auto-recognizing channels
use_channel_dimension = '-A$' # indicate the first letter : for Area, Height or Width.. (typically Area is better)
# Will try to autodetect the scatter channels and designate other ones as fluorescence -- will only work for Sony/BRC currently

channel_lookup_dict = {'fluorescence': 'mScarlet|mcherry|mGreenLantern|gfp', # uses regex matching to assign the fluorescence
                       'scatter': 'FSC|SSC'} # and scattering channels
# Add more/standardized names for other instruments etc.

# Default channels to use : names change according to the flow cytometer machine
# Feature: get code to use this in case the auto-recognition fails
scatter_channels = ['FSC-A', 'SSC-A']
fluorescence_channels = ['mGreenLantern cor-A', 'mScarlet-I-A']
# to check how the channels are named -
# fcs_data[0].channels


