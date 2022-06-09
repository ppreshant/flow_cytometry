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
fcs_experiment_folder = 'S048_e coli dilutions'

# channels to use : names change according to the flow cytometer machine 
scatter_channels = ['FSC-A', 'SSC-A']
fluorescence_channels = ['mGreenLantern cor-A', 'mScarlet-I-A']
# to check how the channels are named -
# fcs_data[0].channels
# in future we will convert them into standardized names in the script 
# based on a few instrument names?..
   

# Give the pattern/well to match the bead file (ex: E01 etc.)
beads_match_name =  'beads' # beads data is saved in a group/folder named beads for (Sony)
