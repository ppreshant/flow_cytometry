# -*- coding: utf-8 -*-
"""
Created on Fri May 20 17:28:59 2022

@author: Prashant
"""
def process_single_fcs_flowcal(single_fcs,
                               beads_to_mef,
                               scatter_channels, fluorescence_channels,
                               make_plots = False):
    
    """Processing a single .fcs file with FlowCal
    
    Takes the .fcs data and 
    1. Gates out saturated events
    2. Density gating for 50% highest dense events
    3. Use beads data (similarly gated) for MEF calibration
     

    Parameters
    ----------
    single_fcs : FlowCal.io.FCSData
        The .fcs file data for the current file to be processed.
    beads_to_mef : Function (functools.partial)
        The to_mef transformation function output from FlowCal.mef.get_transform_fxn(..)
        used for calibration. If None, then MEFL calibration will be skipped -- happens when no beads file found
    scatter_channels : list
        The channels to be used for scattering depending on instrument - ex: ['FSC-A', 'SSC-A']
    fluorescence_channels : list
        The channels to be used for fluorescence depending on experiment, instrument - ex: ['gfpmut3-A', 'mcherry2-A']
    make_plots : bool
        Indicate if plots for each iteration should be made or not
        
    Returns
    -------
    calibrated_fcs : FlowCal.io.FCSData
        Returns a cleaned up and calibrated .fcs dataset.

    """
    
        
    import matplotlib.pyplot as plt # plotting package
    import FlowCal # flow cytometry processing
    
    # import local packages
    from scripts_general_fns.g14_gating_functions import gate_and_reduce_dataset
    
    
    # import config : nothing to import
    # scatter_channels, fluorescence_channels are in the function arguments
    # density_gating_fraction is imported in g14.. for gate_and_reduce_dataset()
    
    
    # %% visualize raw data
    
    
    # # plot both density scatter plot and histogram for a channel
    if make_plots:
        
        print('---> Raw data')            
        FlowCal.plot.density_and_hist(single_fcs,
                                     density_channels = scatter_channels,
                                     density_params = {'mode': 'scatter'},
                                     hist_channels = fluorescence_channels)
        plt.tight_layout() # improves the dual plot label positioning
        plt.show()

    # %% transform to relative fluorescence units (a.u)
    # Useful if machine uses log amplifier
    # Not required for Sony data. check if your data requires it by running
    
    # transformed_fcs = FlowCal.transform.to_rfi(single_fcs, channels='mScarlet-I-A')
    
    # # plot before and after transformation
    # FlowCal.plot.hist1d(\
    #         [single_fcs, transformed_fcs],\
    #             channel = 'mScarlet-I-A', legend=True,\
    #             legend_labels = ['Raw', 'RFU transformed'])
    
    # FlowCal.plot.hist1d(single_fcs, channel='FSC-A')

    # %% Gating
    # Reduce dataset by gating out low and high, density gating - user defined threshold, singlet gate (90% events) with FlowCal
    singlefcs_singlets90 = gate_and_reduce_dataset(single_fcs,\
                                                   scatter_channels, fluorescence_channels,\
                                                   make_plots = make_plots)
    
    # %% Calibration
    # convert data into MEFLs
    if beads_to_mef != None :
        calibrated_fcs = beads_to_mef(singlefcs_singlets90.gated_data, fluorescence_channels)
    
        # %% Check if MEFL worked

        if make_plots:
            # confirm that MEFLs are different from a.u 
            FlowCal.plot.hist1d(\
                [singlefcs_singlets90.gated_data, calibrated_fcs],
                channel = fluorescence_channels[1], legend=True,
                legend_labels = ['A.U.', 'MEFL'])
            plt.show()

        # Return calibrated single fcs file
        return calibrated_fcs
    
    else :
        return singlefcs_singlets90.gated_data