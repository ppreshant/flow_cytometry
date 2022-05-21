# -*- coding: utf-8 -*-
"""
Created on Tue Apr 19 20:40:52 2022

@author: Prashant Kalvapaplle
File input helpers
"""

def get_fcs_files(parent_path):
    
    """Get fcs files in all subdirectories """
    
    import glob # regular expression of filepaths
    from pathlib import PurePath # path manipulation
    
    # %% get paths : glob
    # get the list of all .fcs files in the experiment
    fcspaths = glob.glob(parent_path + '**/*.fcs', 
              recursive=True)
    
    # using pathlib to get the parent path
     # fcspaths[0] | p(PurePath).parent | p(str)
    
    # %% get filenames : pathlib
    # list of fcs file names without path
    fcslist = [PurePath(fl).name for fl in fcspaths]
    # len(fcslist) # check that all files are read
    
    # %% return
    return ((fcspaths, fcslist))

