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
{
    "metadata": {
        "jupyter" : {
        "source_hidden": true
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

# Utilities
from sspipe import p, px

# %%
# Run the flow cytometry processing script 
from analyze_fcs_flowcal import process_fcs_dir
# %timeit -r 1 -n 1 process_fcs_dir(True)

# %%
