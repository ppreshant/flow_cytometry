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
from sspipe import p, px # pipes

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
        
