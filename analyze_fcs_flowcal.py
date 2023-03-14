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

def process_fcs_dir(make_processing_plots= None):
    
    """ Processes a full directory of .fcs files
    
    Parameters
    ----------
    make_processing_plots : str / None
        Parameters such as None, 'all', 'first n' allowed where n is integer to plot these many processing sets
    
    Returns
    -------
    None
        Processes .fcs data into a "processed_data/" directory; 
        Saves a "processing-log.txt" into the same directory;
        saves the mean, median, and mode of the processed data into "FACS_analysis/tabular_outputs/" directory
        
    """
    
    
    
    # %% imports
    
    import matplotlib.pyplot as plt # plotting package
    import FlowCal # flow cytometry processing
    import os # for file path manipulations
    import numpy as np # for arrays
    import pandas as pd # for summary statistics data frame
    import re # for regular expression : string matching
    from IPython.display import display, Markdown # for generating markdown messages
    from sspipe import p, px # pipes usage: x | p(fn) | p(fn2, arg1, arg2 = px)
    from datetime import datetime # date and time module for the log file
    import random # module for random numbers and shuffling vector
    from sys import exit

    # import local packages
    import scripts_general_fns.g3_python_utils_facs as myutils # general utlilties
    from scripts_general_fns.g4_file_inputs import get_fcs_files # reading in .fcs files
    from scripts_general_fns.g15_beads_functions import process_beads_file # get and process beads data
    from scripts_general_fns.g8_process_single_fcs_flowcal import process_single_fcs_flowcal # processing - gating-reduction, MEFLing
    from scripts_general_fns.g9_write_fcs_wrapper import write_FCSdata_to_fcs # .fcs output
    
    # import config : directory name and other definitions
    from scripts_general_fns.g10_user_config import fcs_root_folder, fcs_experiment_folder,\
        beads_match_name, retrieve_custom_beads_file,\
        channel_lookup_dict, use_channel_dimension # channels configuration and dimension
        
    
    import scripts_general_fns.g10_user_config as config # for future reference of any variables
    
    # If needed, change the current working directory
    # os.chdir(r'C:\Users\new\Box Sync\Stadler lab\Data\Flow cytometry (FACS)')
    
    # %% get .fcs file list
    fcspaths, fcslist = get_fcs_files(fcs_root_folder + '/' + fcs_experiment_folder + '/')
    # Loads them as lists in alphabetical order I assume?
    
    # Display the name of the data folder being analyzed as markdown
    Markdown('## Analyzing dataset : "{a}"'.format(a = fcs_experiment_folder)) | p(display)
        
    # %% get beads file
    # Retrieve custom beads file, if user wants (ex: current dataset has no beads) ; else
    # Get the beads file from current dataset using well/pattern : selects the first of multiple matches
    if retrieve_custom_beads_file: 
        from scripts_general_fns.g10_user_config import beads_filepath as beads_list
        beads_filepath = beads_list[0]
        beads_found = True
    else: 
        if beads_match_name is None: # user input says to skip beads
            beads_found = False
        else : # look for beads file by matching to 'beads_match_name' among the .fcs paths
            beads_filepaths_list = [m for m in fcspaths if re.search(beads_match_name, m, re.IGNORECASE)]
            if len(beads_filepaths_list) > 0 : # if beads are found
                beads_found = True
                beads_filepath = beads_filepaths_list[0] # take the first beads file
            else :
                beads_found = False
    
    
    # Remove beads from the fcs path list if using from current dataset (not custom beads file)
    if beads_found and not retrieve_custom_beads_file:
        fcspaths.remove(beads_filepath)
        fcslist = [m for m in fcslist if m not in os.path.basename(beads_filepath)] # and filename list
    # TODO: Need a better index based way to trim fcslist of the beads
    # when multiple beads files present;
    
    
    
    # %% load the .fcs data
    fcs_data = [FlowCal.io.FCSData(fcs_file) for fcs_file in fcspaths]
    
    # select one file for workflow making / testing 
    # single_fcs = fcs_data[0] # load first file for testing purposes
    
    # %% Autodetect channel names
    # get the relevant channels present in the data
    relevant_channels = fcs_data[0].channels | p(myutils.subset_matching_regex, px, use_channel_dimension) 

    # autodetect the channels
    fluorescence_channels, scatter_channels = tuple\
        (myutils.subset_matching_regex(relevant_channels, regx) for regx in channel_lookup_dict.values())
    
    # Error check : for no fluorescence channels (could happen for beads)
    if len(fluorescence_channels) == 0 :
        print('no fluorescence channels found in ' + fcslist[0])
        exit(1)
        
    
    # %% Beads processing
    
    if beads_found :
        Markdown('## Processing beads file') | p(display)

        # Get beads .fcs, cleanup, and generate calibration data structure
        to_mef = process_beads_file(beads_filepath,\
                                   scatter_channels, fluorescence_channels)
    else :
        Markdown('## Skipping -- beads/not found') | p(display)
        to_mef = None
        print('Beads file not found in the directory, skipping to data cleanup without MEFL calibration')
    
    # TODO : need some way to ask user input if the calibration data is ok before going to the rest of the pipeline. Problem : running through jupyter notebook, does not wait for user inputs..
    
    # %% Cleanup and MEFL calibration of each fcs file
    
    Markdown('## Data cleanup, ~MEFL calibration') | p(display) # post message
    
    # parse how many processing outputs should be plotted and pass a True/False vector accordingly
    if make_processing_plots is None:
        plot_n_things = 0
        make_plots_vector = [False] * len(fcs_data)
    else : 
        regex_match = re.search('(first|random) ([0-9])', make_processing_plots)
        matches_all = re.search('all', make_processing_plots)
        
        if matches_all : 
            plot_n_things = len(fcs_data) # all plots will be plotted
            make_plots_vector = [True] * len(fcs_data)
            
        if regex_match is not None:
            plot_n_things = regex_match.group(2) | p(int) 
            make_plots_vector = [i < plot_n_things for i in range(len(fcs_data))] # first n are True
            
            if regex_match.group(1) == 'random':
                random.shuffle(make_plots_vector) # randomize the Truths
    
    
    # %% convert data into MEFLs for all .fcs files : (skips MEFLing if beads are absent)
    processed_fcs_data = [process_single_fcs_flowcal\
                           (single_fcs,
                            to_mef,
                            scatter_channels, fluorescence_channels,
                            make_plots=truth_value)\
                      for single_fcs, truth_value in zip(fcs_data, make_plots_vector)]
    
    
    # Remove .fcs data where no events are left after the filtering process
    empty_fcs_names = None # default
    
    empty_fcs_indices = [i for (i,single_fcs) in enumerate(processed_fcs_data) if single_fcs.__len__() == 0] # get the index of the empties
    empty_fcs_names = [x for i,x in enumerate(fcslist) if i in empty_fcs_indices]
    
    # remove the empties from all the relevant lists
    fcslist = [x for i,x in enumerate(fcslist) if i not in empty_fcs_indices] 
    fcspaths = [x for i,x in enumerate(fcspaths) if i not in empty_fcs_indices] 
    processed_fcs_data = [x for i,x in enumerate(processed_fcs_data) if i not in empty_fcs_indices] 
        
    
    
    # %% summary statistics
    
    # get summary statistics
    summary_stats_list = (['mean', 'median', 'mode'], # use these labels and functions below
                      [FlowCal.stats.mean, FlowCal.stats.median, FlowCal.stats.mode])

    # Generate a combined pandas DataFrame for mean, median and mode respectively : Complex map pipe
    summary_stats = map(lambda x, y: [y(single_fcs, channels = fluorescence_channels) for single_fcs in processed_fcs_data] |\
        p(pd.DataFrame, 
          columns = [x + '_' + chnl for chnl in fluorescence_channels], # name the columns: "summarystat_fluorophore"
          index = fcslist), # rownames as the .fcs file names
        summary_stats_list[0], # x = summary stat names for the map, below has y = summary stat functions
        summary_stats_list[1]) | p(pd.concat, px, axis = 1)
    
    # Get final counts in the cleaned dataset
    final_counts = pd.DataFrame({'final_event_count' : [single_fcs.__len__() for single_fcs in processed_fcs_data]},
                               index = fcslist) # make index as the filenames -- to match to the summary stats                                
    summary_stats = pd.concat([summary_stats, final_counts], axis=1) # concatenate to the summary stats data
    
    # Save summary statistic to csv file
    summary_stats.to_csv('FACS_analysis/tabular_outputs/' + fcs_experiment_folder + '_flowcal-summary.csv',
                        index_label='well')
    
    # %% violin plots 
    
    Markdown('## Summary plots') | p(display) # Post message and explanation
    print('Summary plots for visual reference only, better plots will be made in R/ggcyto/ggplot workflow')
    
    # Make violin plot and show medians
    FlowCal.plot.violin(processed_fcs_data,
                        channel = fluorescence_channels[-1], # 'mScarlet-I-A' / last fluor channel
                        draw_summary_stat=True,
                        draw_summary_stat_fxn=np.median)  
    
    
    # %% Save calibrated or processed fcs data to file
    
    # output file paths
    # trim the directory to remove excessive subsidectories (from Sony instruments)
    outfcspaths = ['processed_data/' + fcs_experiment_folder + '/' + os.path.basename(singlefcspath) \
                   for singlefcspath in fcspaths]
    
    
    [write_FCSdata_to_fcs(filepath, fcs_data) \
     for filepath, fcs_data in zip(outfcspaths, processed_fcs_data)]
    
    # %% make a logfile
    logtext = [f'Processed on : {datetime.now()}',
               f'MEFL calibration done? :{beads_found}',
               '\n',
               f'Density gating fraction : {config.density_gating_fraction}',
               f'initial event count : {max([fcs_data[i].__len__() for i in random.sample(range(len(fcslist)) , k = 5)])}', # pick 5 random files
               f'Fraction retained : {config.density_gating_fraction * 0.9}',
               f'beads file : {beads_filepath if beads_found else "no beads found"}',
               f'Empty FCS files post processing : {*empty_fcs_names,}'] # print all the names of the empty files after processing
               
    with open('processed_data/' + fcs_experiment_folder + '/' + 'processing-log.txt', 'w') as log:
        '\n'.join(logtext) | p(log.write)
        
    # Show parameters under configuration within the markdown too
    Markdown('### Configuration') | p(display)
    print('\n'.join(logtext))

    

    def __main__():
        """ main function for calling the function. When using the script directly from commandlines
        """
        
        process_fcs_dir()