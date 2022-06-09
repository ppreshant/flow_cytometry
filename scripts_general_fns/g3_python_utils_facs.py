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
    return dir_path + inter_path + \
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
    single_fcs : str
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
    