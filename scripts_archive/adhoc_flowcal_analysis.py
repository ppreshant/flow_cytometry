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
import numpy as np # for array manipulations - faster
import pandas as pd # for small data frames, csv outputs
import re # for regular expression : string matching

# enables automatic reloading of local modules when updated : For interactive use
# %load_ext autoreload
# %autoreload 2

# import local packages
from scripts_general_fns.g4_file_inputs import get_fcs_files
from scripts_general_fns.g14_gating_functions import gate_and_reduce_dataset

# import config : directory name and other definitions
from scripts_general_fns.g10_user_config import fcs_root_folder, fcs_experiment_folder,\
    make_processing_plots, beads_match_name,\
    channel_lookup_dict, use_channel_dimension
import scripts_general_fns.g10_user_config as config # in case you need more stuff

# %% get .fcs file list
# Load fcs files

# If needed, change the current working directory
# os.chdir(r'C:\Users\new\Box Sync\Stadler lab\Data\Flow cytometry (FACS)')

fcspaths, fcslist = get_fcs_files(fcs_root_folder + '/' + fcs_experiment_folder + '/')
# Loads them as lists in alphabetical order I assume?

# %% [markdown]
# # Detect channel names
# - Need to load a small subset of data

# %%
# Testing features on a small subset of data
# subset the relevant files to load
from scripts_general_fns.g3_python_utils_facs import subset_matching_regex
regex_to_subset = 'B09' # 'F05|D06' or '.*' for all

fcspaths_subset = subset_matching_regex(fcspaths, regex_to_subset)
fcslist_subset = subset_matching_regex(fcslist, regex_to_subset)

# %%
fcslist_subset

# %% load the fcs data
# load the subset of the .fcs files
fcs_data_subset = [FlowCal.io.FCSData(fcs_file) for fcs_file in fcspaths_subset]
    
# Load one file for testing
single_fcs = fcs_data_subset[0]

# %%
# get the relevant channels present in the data
relevant_channels = single_fcs.channels | p(subset_matching_regex, px, use_channel_dimension) 

# autodetect the channels
fluorescence_channels, scatter_channels = tuple\
    (subset_matching_regex(relevant_channels, regx) for regx in channel_lookup_dict.values())

# %%
# check --
# fluorescence_channels
# fcslist_subset

# %% [markdown]
# # Check a dataset

# %% tags=[]
f'{single_fcs.__len__()} : number of events' # check that this is a non-empty file

# %% tags=[] jupyter={"outputs_hidden": true}
# Show plots of a dataset, adjust gating fraction manually. Use next code block for quick change of well too!
gated_single_fcs = \
gate_and_reduce_dataset(single_fcs,\
           scatter_channels, fluorescence_channels, density_gating_fraction=.5,
           make_plots = True) ;

# %% tags=[] jupyter={"outputs_hidden": true}
# Show plots of a dataset, adjust gating fraction manually for any well.
from scripts_general_fns.g3_python_utils_facs import select_well_and_show_gating
select_well_and_show_gating('B01', 0.5, fcspaths, fcslist)


# %% [markdown]
# # Troubleshooting basic python

# %%
';'.join(['ants', 'gpds'])

# %%
# interesting example to get both index and the interator
indx, empties = zip(*[(i, a) for (i,a) in enumerate(processed_fcs_data) if a.__len__() == 0])

# %%
a = range(3)
f'list is : {*a,}'

# %% [markdown]
# # Process the beads

# %%
# Get beads within the folder  
beads_filepaths_list = [m for m in fcspaths if re.search(beads_match_name, m, re.IGNORECASE)]
if len(beads_filepaths_list) > 0 : # if beads are found
    beads_found = True
    beads_filepath = beads_filepaths_list[0] # take the first beads file

# %%
# RUN THIS INSTEAD OF THE ABOVE CELL FOR KNOWN BEADS FILE PATH
# -------------------------------------------------------------
# Get a custom beads file from a different folder and process it
beads_filepath, beads_filename = get_fcs_files(fcs_root_folder + '/' + fcs_experiment_folder + 'S063c/S050_d-1/*/Beads/') 
# Tips: need to coerce the list to string before using "beads_filepath"


# %% tags=[]
# Test beads processing function
from scripts_general_fns.g15_beads_functions import process_beads_file # get and process beads data

to_mef = process_beads_file(beads_filepath, scatter_channels, fluorescence_channels) # works!

# %% [markdown] tags=[]
# # Run a customized analysis workflow : for efficiency/speed
# - Custom for S050 multi-plate dataset
# - The beads file is processed only once and re-used for all the plates
# - Trying to get a vectorized workflow/loop going

# %%
# More imports
import re # for regular expression : string matching
from IPython.display import display, Markdown # for generating markdown messages
from sspipe import p, px # pipes usage: x | p(fn) | p(fn2, arg1, arg2 = px)

# import local packages
import scripts_general_fns.g3_python_utils_facs as myutils # general utlilties
from scripts_general_fns.g4_file_inputs import get_fcs_files # reading in .fcs files
from scripts_general_fns.g15_beads_functions import process_beads_file # get and process beads data
from scripts_general_fns.g8_process_single_fcs_flowcal import process_single_fcs_flowcal # processing - gating-reduction, MEFLing
from scripts_general_fns.g9_write_fcs_wrapper import write_FCSdata_to_fcs # .fcs output

# %%
# test workflow on d-1 : updating g10_user_config now

# import config : directory names - refresh the config
from scripts_general_fns.g10_user_config import fcs_root_folder, fcs_experiment_folder
print(fcs_experiment_folder) # check that corect file is loaded

# %%
# loop for every experiment folder 
for fcs_experiment_folder in ['S050/S050_d' + str(x) for x in (np.array(range(7)) + 2)]:

    # get .fcs file list and load data
    fcspaths, fcslist = get_fcs_files(fcs_root_folder + '/' + fcs_experiment_folder + '/')
    # output file paths
    # trim the directory to remove excessive subsidectories (from Sony instruments)
    outfcspaths = ['processed_data/' + fcs_experiment_folder + '/' + os.path.basename(singlefcspath) \
                   for singlefcspath in fcspaths]

    # %% load the .fcs data jupyter={"outputs_hidden": true} tags=[]
    fcs_data = [FlowCal.io.FCSData(fcs_file) for fcs_file in fcspaths]

    # convert data into MEFLs for all .fcs files
    calibrated_fcs_data = [process_single_fcs_flowcal\
                           (single_fcs,
                            to_mef,
                            scatter_channels, fluorescence_channels)\
                      for single_fcs in fcs_data]

    # get summary statistics
    summary_stats_list = (['mean', 'median', 'mode'], # use these labels and functions below
                      [FlowCal.stats.mean, FlowCal.stats.median, FlowCal.stats.mode])

    # Generate a combined pandas DataFrame for mean, median and mode respectively
    summary_stats = map(lambda x, y: [y(single_fcs, channels = fluorescence_channels) for single_fcs in calibrated_fcs_data] |\
        p(pd.DataFrame, 
          columns = [x + '_' + chnl for chnl in fluorescence_channels], # name the columns: "summarystat_fluorophore"
          index = fcslist), # rownames as the .fcs file names
        summary_stats_list[0], # x for the map, y is below
        summary_stats_list[1]) | p(pd.concat, px, axis = 1)

    # Save summary statistic to csv file
    summary_stats.to_csv('FACS_analysis/tabular_outputs/' + fcs_experiment_folder + '-summary.csv',
                        index_label='well')

    # Save calibrated fcs data to file
    [write_FCSdata_to_fcs(filepath, fcs_data) \
     for filepath, fcs_data in zip(outfcspaths, calibrated_fcs_data)]

    # remove .fcs holding lists to save memory
    del fcs_data
    del calibrated_fcs_data

# %% [markdown] tags=[]
# # Testing utilities
# - on single fcs files etc.

# %%
# process all .fcs files : (skips MEFLing if beads are absent)
from scripts_general_fns.g8_process_single_fcs_flowcal import process_single_fcs_flowcal # processing - gating-reduction, MEFLing

processed_fcs_data = [process_single_fcs_flowcal\
                       (single_fcs,
                        to_mef,
                        scatter_channels, fluorescence_channels,
                        make_plots=None)\
                  for single_fcs in fcs_data_subset]

# %%
# Remove .fcs data where no events are left after the filtering process
empty_fcs_names = None # default

empty_fcs_indices = [i for (i,single_fcs) in enumerate(processed_fcs_data) if single_fcs.__len__() == 0] # get the index of the empties
empty_fcs_names = [x for i,x in enumerate(fcslist) if i in empty_fcs_indices]

fcslist_subset = [x for i,x in enumerate(fcslist_subset) if i not in empty_fcs_indices] 
fcspaths_subset = [x for i,x in enumerate(fcspaths_subset) if i not in empty_fcs_indices] 
processed_fcs_data = [x for i,x in enumerate(processed_fcs_data) if i not in empty_fcs_indices] 

# %%
fcslist_subset.__len__()

# %% jupyter={"outputs_hidden": true} tags=[]
[fl.__len__() for fl in processed_fcs_data]

# %% jupyter={"outputs_hidden": true} tags=[]
# Gate and plot a single file - testing the density_gating_fraction
singlefcs_singlets90 = gate_and_reduce_dataset(fcs_data_subset[1], scatter_channels, fluorescence_channels, density_gating_fraction = 0.7, make_plots = True)

# %% [markdown]
# # Testing other features

# %% tags=[] jupyter={"outputs_hidden": true}
# get summary stats and test pandas on the base data / processed data
summary_stats_list = (['mean', 'median', 'mode'],
                      [FlowCal.stats.mean, FlowCal.stats.median, FlowCal.stats.mode])

# Generate a combined dataframe for mean, median and mode respectively
summary_stats_processed = map(lambda x, y: [y(single_fcs, 
                         channels = fluorescence_channels)\
                   for single_fcs in processed_fcs_data] |\
    p(pd.DataFrame, 
      columns = [x + '_' + chnl for chnl in fluorescence_channels],
     index = fcslist_subset), summary_stats_list[0], summary_stats_list[1]) | p(pd.concat, px, axis = 1)

# %% [markdown]
# ## Bimodal troubleshooting : Plotting 1d histograms

# %% tags=[]
# Make processed data
from scripts_general_fns.g8_process_single_fcs_flowcal import process_single_fcs_flowcal # processing - gating-reduction, MEFLing

processed_single_fcs = \
process_single_fcs_flowcal(single_fcs,
                           to_mef,
                           scatter_channels, fluorescence_channels,
                           make_plots=True)

# %% [markdown]
# ### Logicle scale (default)

# %%
# plot density of single FCS

# see full range and then constrain below for better visual
# FlowCal.plot.hist1d(single_fcs, channel = fluorescence_channels[0])
FlowCal.plot.hist1d(single_fcs, channel = fluorescence_channels[0], xscale = 'logicle', xlim = (-200, 200), bins = 1000)


# %%
# see full range and then constrain below for better visual
# FlowCal.plot.hist1d(processed_single_fcs, channel = fluorescence_channels[0])

FlowCal.plot.hist1d(processed_single_fcs, channel = fluorescence_channels[0], xlim = (-2e3, 2e3), bins = 200)

# %% [markdown]
# ### Density2d plots

# %%
# FlowCal.plot.scatter2d(single_fcs, channels = ('SSC-A', 'FSC-A'))
FlowCal.plot.density2d(single_fcs, channels = ('SSC-A', 'mScarlet-I-A'), mode = 'scatter', xlim = (80, 8e3), ylim = (-200, 500), smooth = False) #, yscale='linear')

# %%
FlowCal.plot.density2d(processed_single_fcs, channels = ('SSC-A', 'mScarlet-I-A'), mode = 'scatter', xlim=(100, 1000), ylim=(-1e3, 2e3)) #, smooth = False)

# %% [markdown]
# ### Scatter2d plots

# %%
FlowCal.plot.scatter2d(single_fcs, channels = ('SSC-A', 'mScarlet-I-A'), xlim = (80, 8e3), ylim = (-200, 500))

# %%
FlowCal.plot.scatter2d(processed_single_fcs, channels = ('SSC-A', 'mScarlet-I-A'), xlim=(100, 1000), ylim=(-1e3, 2e3))

# %% [markdown] tags=[]
# ### linear scale
# Histogram doesn't work.. making a single bin for some reason
# let's try density / scatter

# %%
# FlowCal.plot.density2d(single_fcs, channels = ('SSC-A', 'mScarlet-I-A'), mode = 'scatter', xlim = (80, 8e3), ylim = (-200, 500), smooth = False, yscale='linear')
FlowCal.plot.scatter2d(single_fcs, channels = ('SSC-A', 'mScarlet-I-A'), 
                       xlim = (80, 8e3), ylim = (-200, 500), 
                       yscale='linear')

# %%
# FlowCal.plot.density2d(single_fcs, channels = ('SSC-A', 'mScarlet-I-A'), mode = 'scatter', xlim = (80, 8e3), ylim = (-200, 500), smooth = False, yscale='linear')
FlowCal.plot.scatter2d(processed_single_fcs, channels = ('SSC-A', 'mScarlet-I-A'), 
                       xlim = (80, 1e3), ylim=(-1e3, 1.5e3),
                       yscale='linear')

# %%
FlowCal.plot.hist1d(single_fcs, channel = fluorescence_channels[0], xscale = 'linear', xlim = (0, 500), bins = 1024)
# FlowCal.plot.hist1d(processed_single_fcs, channel = fluorescence_channels[0], xscale = 'linear', xlim = (-200, 200), bins = 1000)

# %% [markdown]
# ### Other investigations
# Look at hist_bins

# %%
single_fcs.hist_bins

# %%
processed_single_fcs.hist_bins

# %% [markdown]
# ### Explore MEFL calibration prameters
# As John Sexton [suggests](https://github.com/taborlab/FlowCal/issues/359).
# Need to run to_mef `FlowCal.mef.get_transform_fxn` with `full_output==True`
#  > (It would also be helpful to inspect the calibration model parameters and make sure they make sense--the exponential term should be near 1.0 for modern cytometers, and the linear scaling factor should depend on the detector voltage.

# %% jupyter={"outputs_hidden": true} tags=[]
mef_model = process_beads_file(beads_filepath, scatter_channels, fluorescence_channels, give_full_output=True) # works!

# %%
mef_model.fitting

# %% [markdown]
# Next steps :
# - try plotting this model and check if there is a zero avoidance going on
# - I assume m is the exponential term JS is referring to, check when posting the reply
# - Ask how this can be fixed - new beads etc.?

# %%
mef_model.selection

# %%
# adhoc run with functions
from scripts_general_fns.g8_process_single_fcs_flowcal import process_single_fcs_flowcal
calibrated_single_fcs = process_single_fcs_flowcal(single_fcs, to_mef, scatter_channels, fluorescence_channels)

# %% tags=[]
fcs_data = [FlowCal.io.FCSData(fcs_file) for fcs_file in fcspaths]

# %%
final_counts = np.array([single_fcs.__len__() for single_fcs in fcs_data])

# %%
tst = pd.DataFrame({ 'final_events' : [single_fcs.__len__() for single_fcs in fcs_data]})
