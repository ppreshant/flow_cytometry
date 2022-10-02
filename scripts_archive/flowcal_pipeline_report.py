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

# %% [markdown]
# # Run and capture plots of FlowCal processing of flow cytometry data

# %%
# commands to hide the code when making a .html output from jupyter
{
    "metadata": {
        "jupyter" : {
        "source_hidden": True
        }
    }
}

# Change the working directory to the base directory : 'Flow cytometry(FACS)'
import os
os.chdir("..") # set path to the head directory of the project
os.getcwd() # check current working directory

# add project path to sys.path: enables loading local modules in other folders
import sys
module_path = os.getcwd()
# module_path = os.path.abspath(os.path.join('..'))

if module_path not in sys.path:
    sys.path.append(module_path)
sys.path # check that the last entry is the head project path

# Utilities
from sspipe import p, px
import importlib # for reloading modules that changed

# %%
# Run the flow cytometry processing script 
# importlib.reload(analyze_fcs_flowcal)
from analyze_fcs_flowcal import process_fcs_dir
# %timeit -r 1 -n 1 process_fcs_dir(True) # time and run the pipeline
# reading .fcs data, beads processing, cleanup and calibration, saving summary statistics and cleaned files

# %%
# Running from commandline
# jupyter nbconvert --execute --to html flowcal_pipeline_report.ipynb
