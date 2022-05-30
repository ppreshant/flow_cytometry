# -*- coding: utf-8 -*-
"""
Created on Sun May 29 12:57:24 2022

@author: Prashant
"""



def write_FCSdata_to_fcs(filepath, fcs_data,
                         channels='all'):
    """ save data to .fcs files with correct metadata 
    

    Parameters
    ----------
    filepath : str
        give the path of the final .fcs file to be saved, include the .fcs extension.
    channels : str
        'all' will save all channels;
        Future feature: A list of channels to be saved; only these will be subset from the file.
    fcs_data : FlowCal.io.FCSData
        FCSData file to be saved
        is a numpy ndarray (N data x D channel dimensions) with metadata and other features.

    Returns
    -------
    None. Just saves the file and prints the filename
    
    Corrects the $TOT metadata to the fix number of cells from the file
    Creates directory if it does not exist 

    """
    
    from fcswrite import write_fcs # import the fcswriting function
    
    # update the total number of cells in the text attribute ($TOT) - metadata
    # fcs_data.text['$TOT'] = str(fcs_data.__len__()) # convert to string
    # already done in the write_fcs script
    
    
    # Create a directory if it does not exist
    # from https://stackoverflow.com/a/273227/9049673
    from pathlib import Path
    Path(filepath).parents[0].mkdir(parents=True, exist_ok=True)
    # Path object. get parent directory. make new directory, include parents
    
    
    # select channels
    if channels == 'all': channels = list(fcs_data.channels)
    # unsupported : saving only desired channels
    # text metadata needs to be updated to select and renumber PnX
    # PnX ; X = B,D,E,N,R,S ; n = 1,2,3, in order of channels
    # Use write_fcs(.. , data=fcs_data[:, channels])
    
    # Save data to file
    write_fcs(filename= filepath, 
              chn_names=channels, 
              data=fcs_data,
              # text_kw_pr=fcs_data.text, # causes duplicates in HEADER and TEXT
              compat_chn_names=False) # don't remove special chars
    
    # print success message
    print('\n', 'file saved : ', Path(filepath).name)