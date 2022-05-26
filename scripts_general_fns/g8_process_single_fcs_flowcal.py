# -*- coding: utf-8 -*-
"""
Created on Fri May 20 17:28:59 2022

@author: Prashant
"""
def process_single_fcs_flowcal(single_fcs, 
                               beads_to_mef, 
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

    # %% Gating
    # gate out saturated events - high and low
    singlefcs_gate1 = FlowCal.gate.high_low(single_fcs, channels = ['FSC-A', 'SSC-A'])

    # auto density gating : for 50% of cells
    singlefcs_densitygate50 = FlowCal.gate.density2d(singlefcs_gate1,
                                       channels = ['FSC-A', 'SSC-A'],
                                       gate_fraction = 0.50,
                                       full_output=True) # full => saves outline

    if make_plots:
        FlowCal.plot.density_and_hist(singlefcs_gate1,
                                      gated_data = singlefcs_densitygate50.gated_data,
                                      gate_contour = singlefcs_densitygate50.contour,
                                      density_channels=['FSC-A', 'SSC-A'],
                                      density_params={'mode': 'scatter'},
                                      hist_channels=['mGreenLantern cor-A', 'mScarlet-I-A'])
        plt.tight_layout(); plt.show()

    # %% doublet discrimination

    # Singlets: auto density gating : for 90% of cells w FSC-A vs H
    singlefcs_singlets90 = FlowCal.gate.density2d(singlefcs_densitygate50.gated_data,
                                       channels = ['FSC-A', 'FSC-H'],
                                       gate_fraction = 0.90,
                                       full_output=True) # full => saves outline

    if make_plots:
        # plot before and after gating
        FlowCal.plot.density_and_hist(singlefcs_densitygate50.gated_data,
                                      gated_data = singlefcs_singlets90.gated_data,
                                      gate_contour = singlefcs_singlets90.contour,
                                      density_channels=['FSC-A', 'FSC-H'],
                                      density_params={'mode': 'scatter'},
                                      hist_channels=['mGreenLantern cor-A', 'mScarlet-I-A'])
        plt.tight_layout(); plt.show()

    # confirm that the gating only retains the good high density area
    # where H and A are linear
    
    # %% Calibration
    # convert data into MEFLs 
    calibrated_fcs = beads_to_mef(singlefcs_singlets90.gated_data, ['mGreenLantern cor-A', 'mScarlet-I-A'])
    
    # %% Check if MEFL worked
    
    if make_plots:
        # confirm that MEFLs are different from a.u 
        FlowCal.plot.hist1d(\
            [singlefcs_densitygate50.gated_data, calibrated_fcs],
            channel = 'mScarlet-I-A', legend=True,
            legend_labels = ['A.U.', 'MEFL'])
 
    # Return calibrated single fcs file
    return calibrated_fcs