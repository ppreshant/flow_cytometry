# -*- coding: utf-8 -*-
"""
Created on Fri May 20 17:28:59 2022

@author: Prashant
"""
def process_single_fcs_flowcal(single_fcs, 
                               beads_to_mef, 
                               scatter_channels=scatter_channels,
                               fluorescence_channels=fluorescence_channels,
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
        used for calibration
    make_plots : bool
        Indicate if plots for each iteration should be made or not
        
    Returns
    -------
    calibrated, cleaned up .fcs dataset.

    """
    
    import matplotlib.pyplot as plt # plotting package
    import FlowCal # flow cytometry processing

   # %% visualize raw data

   # # plot both density scatter plot and histogram for a channel
   # FlowCal.plot.density_and_hist(single_fcs,
   #                               density_channels = scatter_channels,
   #                               density_params = {'mode': 'scatter'},
   #                               hist_channels = ['mScarlet-I-A'])
   # plt.tight_layout() # improves the dual plot label positioning
   # plt.show()

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
    # gate out saturated events - high and low
    singlefcs_gate1 = FlowCal.gate.high_low(single_fcs, channels = scatter_channels)

    # auto density gating : for 50% of cells
    singlefcs_densitygate50 = FlowCal.gate.density2d(singlefcs_gate1,
                                       channels = scatter_channels,
                                       gate_fraction = 0.50,
                                       full_output=True) # full => saves outline

    if make_plots:
        FlowCal.plot.density_and_hist(singlefcs_gate1,
                                      gated_data = singlefcs_densitygate50.gated_data,
                                      gate_contour = singlefcs_densitygate50.contour,
                                      density_channels=scatter_channels,
                                      density_params={'mode': 'scatter'},
                                      hist_channels=fluorescence_channels)
        plt.tight_layout(); plt.show()

    # %% doublet discrimination

    # Singlets: auto density gating : for 90% of cells w FSC-A vs H
    singlefcs_singlets90 = FlowCal.gate.density2d(singlefcs_densitygate50.gated_data,
                                       channels = scatter_channels,
                                       gate_fraction = 0.90,
                                       full_output=True) # full => saves outline

    if make_plots:
        # plot before and after gating
        FlowCal.plot.density_and_hist(singlefcs_densitygate50.gated_data,
                                      gated_data = singlefcs_singlets90.gated_data,
                                      gate_contour = singlefcs_singlets90.contour,
                                      density_channels=scatter_channels,
                                      density_params={'mode': 'scatter'},
                                      hist_channels=fluorescence_channels)
        plt.tight_layout(); plt.show()

    # confirm that the gating only retains the good high density area
    # where H and A are linear
    
    # %% Calibration
    # convert data into MEFLs 
    calibrated_fcs = beads_to_mef(singlefcs_singlets90.gated_data, fluorescence_channels)
    
    # %% Check if MEFL worked
    
    if make_plots:
        # confirm that MEFLs are different from a.u 
        FlowCal.plot.hist1d(\
            [singlefcs_densitygate50.gated_data, calibrated_fcs],
            channel = fluorescence_channels[2], legend=True, # 'mScarlet-I-A'
            legend_labels = ['A.U.', 'MEFL'])
 
    # Return calibrated single fcs file
    return calibrated_fcs