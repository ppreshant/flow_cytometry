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

# Choose a density gate fraction : 0.5 (50%) is decent, if you need to retain more events try 80%
density_gating_fraction = .8

# Give the pattern/well to match the bead file (ex: E01 etc.)
beads_match_name =  'beads' # beads data is saved in a group/folder named beads for (Sony)


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


