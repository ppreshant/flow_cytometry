# -*- coding: utf-8 -*-
""" Process a directory of .fcs files using FlowCal
Created on Fri May 20 17:03:39 2022

Wrapper script to ease processing Flow cytometry data using 
FlowCal repository : https://github.com/taborlab/FlowCal/
- Opens all .fcs files within the directory
- Attaches sample names from a google sheet 
    (could change to local .csv file too)
- Run standard processes, uses sample named as beads for MEFLing
- Saves standard plots and outputs summary statistics data in .csv

@author: Prashant
@date 20/May/22
"""

# It is best to create a spyder project in the folder containing
# this file and the subdirectories as in this repository
#---- Make sure that python is running from the working directory
# --- containing this file; since the paths below are relative

# User inputs # paths are relative to the working directory
fcs_root_folder = 'flowcyt_data/'
fcs_experiment_folder = 'test/'


# %% imports

# import os # for changing file paths etc.
# If needed, change the current working directory
# os.chdir(r'C:\Users\new\Box Sync\Stadler lab\Data\Flow cytometry (FACS)')

import matplotlib.pyplot as plt # plotting package
import FlowCal # flow cytometry processing
from scripts_general_fns.g3_python_utils_facs import *
from scripts_general_fns.g4_file_inputs import get_fcs_files

# %% get .fcs file list
fcspaths, fcslist = get_fcs_files(fcs_root_folder + fcs_experiment_folder)

# %% get beads file 



# %% processing 

# the script runs through each .fcs file in the list
# 

# %% summarize data


# %% plotting 


# %% save plots

