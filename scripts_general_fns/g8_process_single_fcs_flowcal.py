# -*- coding: utf-8 -*-
"""
Created on Fri May 20 17:28:59 2022

@author: Prashant
"""
def process_single_fcs_flowcal(fcs_file, beads_file):
    """Processing a single .fcs file with FlowCal
    
    Takes the .fcs data and 
    1. Gates out saturated events
    2. Density gating for 50% highest dense events
    3. Use beads data (similarly gated) for MEF calibration
     

    Parameters
    ----------
    fcs_file : fcs data file
        The .fcs file data for the current file to be processed.
    beads_file : str
        The beads .fcs data -- used for calibration
        
    Returns
    -------
    calibrated, cleaned up .fcs dataset.

    """
    
    import FlowCal # flow cytometry processing

    # %% Gating
    # gate out saturated events - high and low
    singlefcs_gate1 = FlowCal.gate.high_low(single_fcs, channels = ['FSC-A', 'SSC-A'])

    # auto density gating : for 50% of cells
    singlefcs_densitygate50 = FlowCal.gate.density2d(singlefcs_gate1,
                                       channels = ['FSC-A', 'SSC-A'],
                                       gate_fraction = 0.50,
                                       full_output=True) # full => saves outline

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

    # specify the mefl values from data sheet
    # eventually will read this off an excel file or two 
    mGreenLantern_mefl_vals = [0, 771, 2106, 6262, 15183, 45292, 136258, 291042]
    mScarlet_mefl_vals =      [0, 487, 1474, 4516, 11260, 34341, 107608, 260461]
     
    to_mef = FlowCal.mef.get_transform_fxn(beads_file.gated_data, 
                                           mef_values = [mGreenLantern_mefl_vals, mScarlet_mefl_vals],
                                           mef_channels = ['mGreenLantern cor-A', 'mScarlet-I-A'],
                                           plot=True)
    plt.show()
    
    # convert data into MEFLs 
    calibrated_fcs = to_mef(singlefcs_singlets90.gated_data, ['mGreenLantern cor-A', 'mScarlet-I-A'])
    
    # %% Check if MEFL worked
    
    # confirm that MEFLs are different from a.u 
    FlowCal.plot.hist1d(\
        [singlefcs_densitygate50.gated_data, calibrated_fcs],
        channel = 'mScarlet-I-A', legend=True,
        legend_labels = ['A.U.', 'MEFL'])
 