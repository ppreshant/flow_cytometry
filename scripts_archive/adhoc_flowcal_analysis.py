# ---
# jupyter:
#   jupytext:
#     formats: ipynb,py:percent
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.14.0
#   kernelspec:
#     display_name: Python 3 (ipykernel)
#     language: python
#     name: python3
# ---

# %%
# Run the flow cytometry script components from outside 


# prelims - setting working directory is important
{
    "metadata": {
        "jupyter" : {
        "source_hidden": True
        }
    }
}

# check current working directory
import os
os.chdir("..") # set path to the head directory of the project
os.getcwd()

# add project path to sys.path: enables loading local modules in other folders
import sys
module_path = os.getcwd()
# module_path = os.path.abspath(os.path.join('..'))

if module_path not in sys.path:
    sys.path.append(module_path)
sys.path # check that the last entry is the head project path

# Use for reloading modules when changes are made on the fly
import importlib # usage importlib.reload(module_name)

# Utilities
from sspipe import p, px # pipes usage: x | p(fn) | p(fn2, arg1, arg2 = px)

# %%
# flowcal prerequisites
import FlowCal # flow cytometry processing

# enables automatic reloading of local modules when updated
# %load_ext autoreload
# %autoreload 2

# import local packages
from scripts_general_fns.g4_file_inputs import get_fcs_files
from scripts_general_fns.g11_gating_functions import gate_and_reduce_dataset

# import config : directory name and other definitions
from scripts_general_fns.g10_user_config import fcs_root_folder, fcs_experiment_folder,\
    beads_match_name,\
    scatter_channels, fluorescence_channels,\
    channel_lookup_dict

# %%
# Load fcs files
# If needed, change the current working directory
# os.chdir(r'C:\Users\new\Box Sync\Stadler lab\Data\Flow cytometry (FACS)')

# %% get .fcs file list
fcspaths, fcslist = get_fcs_files(fcs_root_folder + '/' + fcs_experiment_folder + '/')
# Loads them as lists in alphabetical order I assume?

# %%
# subset the relevant files to load
from scripts_general_fns.g3_python_utils_facs import subset_matching_regex
fcspaths_subset = subset_matching_regex(fcspaths, 'F05|D06')

# %%
# %% load the fcs data
fcs_data = [FlowCal.io.FCSData(fcs_file) for fcs_file in fcspaths_subset]
    
# Load one file for testing
single_fcs = fcs_data[0]

# %%
# get the relevant channels present in the data
relevant_channels = single_fcs.channels | p(subset_matching_regex, px, '-A$') 

# autodetect the channels
fluorescence_channels, scatter_channels = tuple\
    (subset_matching_regex(relevant_channels, regx) for regx in channel_lookup_dict.values())

# %%
from scripts_general_fns.g11_gating_functions import gate_and_reduce_dataset

# %%
# Gate and plot a single file
singlefcs_singlets90 = gate_and_reduce_dataset(fcs_data[1], scatter_channels, fluorescence_channels, density_gating_fraction = 0.7, make_plots = True)
