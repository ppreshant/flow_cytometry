""" Process a directory of .fcs files using FlowCal

Wrapper script to process a directory of Flow cytometry data
using FlowCal, repository : https://github.com/taborlab/FlowCal/
- Opens all .fcs files within the directory
- Attaches sample names from a google sheet 
    (could change to local .csv file too)
- Run standard processes, uses sample named as beads for MEFLing
- Saves standard plots and outputs summary statistics data in .csv

----------
Following tutorial to use Flowcal 
https://taborlab.github.io/FlowCal/python_tutorial/

@author: Prashant
@date 9/April/22
"""
# It is best to create a spyder project in the folder containing
# this file and re-create the subdirectories as in this repository
#---- Make sure that python is running from the working directory
# --- containing this file; since the paths below are relative
#  Can use spyder -p . to start spyder from the project in the working dir


# %% processing fcs directory function

def process_fcs_dir(make_processing_plots=False):

    # %% imports
    
    import matplotlib.pyplot as plt # plotting package
    import FlowCal # flow cytometry processing
    import os # for file path manipulations
    import numpy as np # for arrays
    import pandas as pd # for summary statistics data frame
    import re # for regular expression : string matching
    from IPython.display import display, Markdown # for generating markdown messages
    from sspipe import p, px # pipes usage: x | p(fn) | p(fn2, arg1, arg2 = px)
    
    # import local packages
    import scripts_general_fns.g3_python_utils_facs as myutils # general utlilties
    from scripts_general_fns.g4_file_inputs import get_fcs_files # reading in .fcs files
    from scripts_general_fns.g15_beads_functions import process_beads_file # get and process beads data
    from scripts_general_fns.g8_process_single_fcs_flowcal import process_single_fcs_flowcal # processing - gating-reduction, MEFLing
    from scripts_general_fns.g9_write_fcs_wrapper import write_FCSdata_to_fcs # .fcs output
    
    # import config : directory name and other definitions
    from scripts_general_fns.g10_user_config import fcs_root_folder, fcs_experiment_folder,\
        beads_match_name, retrieve_custom_beads_file,\
        channel_lookup_dict  # channels configuration
    
    # If needed, change the current working directory
    # os.chdir(r'C:\Users\new\Box Sync\Stadler lab\Data\Flow cytometry (FACS)')
    
    # %% get .fcs file list
    fcspaths, fcslist = get_fcs_files(fcs_root_folder + '/' + fcs_experiment_folder + '/')
    # Loads them as lists in alphabetical order I assume?
    
    # Display the name of the data folder being analyzed as markdown
    Markdown('## Analyzing dataset : "{a}"'.format(a = fcs_experiment_folder)) | p(display)
    
    # %% get beads file
    # Retrieve custom beads file, if user wants (current dataset has no beads) ; else
    # Get the beads file from current dataset using well/pattern : selects the first of multiple matches
    if retrieve_custom_beads_file: 
        from scripts_general_fns.g10_user_config import beads_filepath as beads_list
        beads_filepath = beads_list[0]
    else: 
        beads_filepath = [m for m in fcspaths if re.search(beads_match_name, m, re.IGNORECASE)][0]
    
    
    # Remove beads from the fcs path list if using from current dataset (not custom beads file)
    if not retrieve_custom_beads_file:
        fcspaths.remove(beads_filepath)
        fcslist = [m for m in fcslist if m not in os.path.basename(beads_filepath)] # and filename list
    # TODO: Need a better index based way to trim fcslist of the beads
    # when multiple beads files present;
    
    # output file paths
    # trim the directory to remove excessive subsidectories (from Sony instruments)
    outfcspaths = ['processed_data/' + fcs_experiment_folder + '/' + os.path.basename(singlefcspath) \
                   for singlefcspath in fcspaths]
    
    # %% load the .fcs data
    fcs_data = [FlowCal.io.FCSData(fcs_file) for fcs_file in fcspaths]
    
    # select one file for workflow making / testing 
    # single_fcs = fcs_data[0] # load first file for testing purposes
    
    # %% Autodetect channel names
    # get the relevant channels present in the data
    relevant_channels = fcs_data[0].channels | p(myutils.subset_matching_regex, px, '-A$') 

    # autodetect the channels
    fluorescence_channels, scatter_channels = tuple\
        (myutils.subset_matching_regex(relevant_channels, regx) for regx in channel_lookup_dict.values())
    
    # %% bring sample names and metadata
    
    # bring sample names from google sheet, 
    # attach them to the dataset as a name entry
    
    
    # %% Beads processing
    
    Markdown('## Processing beads file') | p(display)
    
    # Get beads .fcs, cleanup, and generate calibration data structure
    to_mef = process_beads_file(beads_filepath,\
                               scatter_channels, fluorescence_channels)
            
    # %% Cleanup and MEFL calibration of each fcs file
    
    Markdown('## Data cleanup, MEFL calibration') | p(display) # post message
    
    
    # convert data into MEFLs for all .fcs files
    calibrated_fcs_data = [process_single_fcs_flowcal\
                           (single_fcs,
                            to_mef,
                            scatter_channels, fluorescence_channels,
                            make_plots=make_processing_plots)\
                      for single_fcs in fcs_data]
    
       
    # timing and testing
    # %timeit -n 1 -r 1 python command here
    
    # %% summary statistics
    
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
    
    # %% violin plots 
    
    Markdown('## Summary plots') | p(display) # Post message and explanation
    print('Summary plots for visual reference only, better plots will be made in R/ggcyto/ggplot workflow')
    
    # Make violin plot and show medians
    FlowCal.plot.violin(calibrated_fcs_data,
                        channel = fluorescence_channels[1], # 'mScarlet-I-A'
                        draw_summary_stat=True,
                        draw_summary_stat_fxn=np.median)  
    
    # %% Save calibrated fcs data to file
    
    [write_FCSdata_to_fcs(filepath, fcs_data) \
     for filepath, fcs_data in zip(outfcspaths, calibrated_fcs_data)]


    def __main__():
        process_fcs_dir()