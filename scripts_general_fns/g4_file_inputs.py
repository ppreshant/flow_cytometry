# -*- coding: utf-8 -*-
"""
Created on Tue Apr 19 20:40:52 2022

@author: Prashant Kalvapaplle
File input helpers
"""

def get_fcs_files(parent_path, include_day_key = False):
    
    """Get fcs files in all subdirectories 
    
    Parameters
    ----------
    parent_path : str
        directory path containing .fcs files 
    include_day_key : bool
        Appends a day regex (ex: d2) from the path to the fcslist if True

    Returns
    -------
    subseted list with regex matching entries.

    """
    
    import glob # regular expression of filepaths
    from pathlib import PurePath # path manipulation
    import re # for regular expression string manipulations
    
    # %% get paths : glob
    # get the list of all .fcs files in the experiment
    fcspaths = glob.glob(parent_path + '**/*.fcs', 
              recursive=True) # ** and recursive => includes all subfolders
    
    # using pathlib to get the parent path
     # fcspaths[0] | p(PurePath).parent | p(str)
    
    # %% get filenames : pathlib
    # list of fcs file names without path + day key if asked for
    fcslist = [(re.search('d.?[0-9]', fl).group(0) + '_'
                if include_day_key else '') + 
               PurePath(fl).name for fl in fcspaths]
    # Note: possible BUG : fails at .group(0) when regex is not found. 
    
    # len(fcslist) # check that all files are read
    
    # %% return
    return ((fcspaths, fcslist))

