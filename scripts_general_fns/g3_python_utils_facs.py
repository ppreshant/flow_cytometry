# -*- coding: utf-8 -*-
"""
Created on Thu Apr 14 16:50:33 2022

@author: Prashant Kalvapalle
@purpose : creating wrapers for commandline use of python
flow cytometry
"""

# pipes using sspipes package : simple smart pipes
# https://pypi.org/project/sspipe/
# usage: x | p(fn) | p(fn2, arg1, arg2 = px)
# %% pipes
from sspipe import p, px # pipes operator, for code readability

# %% packages
import numpy as np # numpy
import os # for directory navigation

#-----------------------------------
# change to previous directory : for going to /qPCR 
# os.chdir('..')

# get current cirectory
# curdir = os.getcwd()

# %% dummy data for troubleshootings

# Dummy 2d array
a = np.array([[1, 2, 3], [4, 5, 6]], np.int32) # np 2d array
b = dict(b1 = range(4), b2 = 'cats') # dictionary
c = list(range(5)) # list

# %% wrapper fcs file path
# returns dirpath/interpath/Sony formatted well name.fcs
def sony_well_to_file(wellname):
    return fcs_root_folder + fcs_experiment_folder + \
    wellname + ' Well - ' + wellname + ' WLSM' + \
    '.fcs'
        

# %% fcs events plot 
def plot_number_of_events(fcs_data_list, plt_title='Flow cytometry events by well'): 
    """ Plot the total number of events in each fcs file in the list on a single plot

    Parameters
    ----------
    fcs_list : list of FlowCal.io.FCSData
        Give the list of fcs files loaded through analyze_fcs_flowcal.
    plt_title : str
        What should the plot title say?

    Returns
    -------
    dict of the wells and corresponding number of events. Plots a matplotlib plot

    """
    
    import matplotlib.pyplot as plt # for plotting
    
    # make a dictionary of short well names and lengths
    events_by_well = ((str(single_fcs) | p(get_well_name),
                 single_fcs.__len__()
             ) for single_fcs in fcs_data_list) | p(dict)
    
    # Arrange in ascending order of wells
    events_by_well = sorted(events_by_well.items(), key=lambda item: item[1]) | p(dict)
    
    # dict(sorted(tst.items(), key=lambda item: item[1])) # # Sort in ascending order of values
    
    # Change dictionary for plotting
    event_data = {'Well' : events_by_well.keys(), 
                  'Event count' : events_by_well.values()}
    
    # # Plotting
    # fig = plt.figure()  # an empty figure with no Axes
    fig, ax = plt.subplots(figsize=(5,12))  # Create a figure containing a single axes.
    ax.scatter('Event count', 'Well', data=event_data);  # Plot some data on the axes.
    ax.set_xlabel('Total events measured')
    ax.set_ylabel('Well name');
    ax.set_title(plt_title)
    
    # return the dictionary    
    return events_by_well


# %% Get the wellname (Ex: A11) from a string
def get_well_name(string):
    """ Get the wellname (Ex: A11) from a longer string
    

    Parameters
    ----------
    string : str
        String containing the wellname

    Returns
    -------
    str of wellname.

    """
    
    import re # for regular expression string manipulations
    
    try:
        return re.compile("[A-H][0-9]+").search(string).group(0)
         #  compile to regex object .search in string . return the matching region 
    except:
         print('Well name not present in : ', string)
         return string # return back the string if there is an error
    

# %% Get the matching entries from a list of strings (use to subset by wells : A01 etc.)
def subset_matching_regex(list_strings, regex_string):
    """ Get the wellname (Ex: A11) from a longer string
    

    Parameters
    ----------
    list_strings : list
        list of strings that needs to be subset
    regex_string : str
        String with the containing the wellname

    Returns
    -------
    subseted list with regex matching entries.

    """
    
    import re # for regular expression string manipulations
    
    return [str for str in list_strings
            if re.search(regex_string, str)]
    
    
# %% wrapper to select well and show effect on gating percentage
def select_well_and_show_gating(well_regex, dens_gating_fraction, fcspaths, fcslist):
    """ss work in progress here. Issue # 1
    Need too many things input to this function ; check if it's worth / do when free
    
    """
    import FlowCal
    from scripts_general_fns.g14_gating_functions import gate_and_reduce_dataset
    from scripts_general_fns.g3_python_utils_facs import subset_matching_regex
    # import config : directory name and other definitions
    from scripts_general_fns.g10_user_config import channel_lookup_dict, use_channel_dimension
    
    regex_to_subset = well_regex # 'F05|D06' or '.*' for all

    fcspaths_subset = subset_matching_regex(fcspaths, regex_to_subset)
    fcslist_subset = subset_matching_regex(fcslist, regex_to_subset)
    
    # load the subset of the .fcs files
    fcs_data_subset = [FlowCal.io.FCSData(fcs_file) for fcs_file in fcspaths_subset]

    # Load one file for testing
    single_fcs = fcs_data_subset[0]

    # get the relevant channels present in the data
    relevant_channels = single_fcs.channels | p(subset_matching_regex, px, use_channel_dimension) 

    # autodetect the channels
    fluorescence_channels, scatter_channels = tuple\
        (subset_matching_regex(relevant_channels, regx) for regx in channel_lookup_dict.values())    
    
    
    # DO THE GATING
    gate_and_reduce_dataset(single_fcs,\
           scatter_channels, fluorescence_channels, density_gating_fraction=dens_gating_fraction,
           make_plots = True) ;