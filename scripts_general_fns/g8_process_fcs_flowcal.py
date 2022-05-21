# -*- coding: utf-8 -*-
"""
Created on Fri May 20 17:28:59 2022

@author: Prashant
"""
def process_fcs_flowcal(fcs_file, beads_file):
    """Processing a single .fcs file with FlowCal
    
    Takes the .fcs data and 
    1. Gates out saturated events
    2. Density gating for 50% highest dense events
    3. Use beads data (similarly gated) for MEF calibration
     

    Parameters
    ----------
    fcs_file : TYPE
        DESCRIPTION.

    Returns
    -------
    None.

    """
    
    import FlowCal # flow cytometry processing

    # %% Gating
    # gate saturated events - high and low
    s_g1 = FlowCal.gate.high_low(fcs_file, channels = ['FSC-A', 'SSC-A'])

    # auto density gating : for 50% of cells
    s_gate50 = FlowCal.gate.density2d(s_g1,
                                       channels = ['FSC-A', 'SSC-A'],
                                       gate_fraction = 0.50,
                                       full_output=True) # full => saves outline

# %% Calibration

# specify the mefl values from data sheet
# eventually will read this off an excel file or two 
mGreenLantern_mefl_vals = [0, 771, 2106, 6262, 15183, 45292, 136258, 291042]
mScarlet_mefl_vals =      [0, 487, 1474, 4516, 11260, 34341, 107608, 260461]
 
to_mef = FlowCal.mef.get_transform_fxn(b_gate30.gated_data, 
                                       mef_values = [mGreenLantern_mefl_vals, mScarlet_mefl_vals],
                                       mef_channels = ['mGreenLantern cor-A', 'mScarlet-I-A'],
                                       plot=True)
plt.show()

# convert data into MEFLs 
s = to_mef(s, ['mGreenLantern cor-A', 'mScarlet-I-A'])

# visualize the gated data : should translate the MEFLs already
FlowCal.plot.density_and_hist(s_gate50.gated_data,
                              density_channels = ['FSC-A', 'SSC-A'],
                              density_params = {'mode': 'scatter'},
                              hist_channels = ['mGreenLantern cor-A', 'mScarlet-I-A'])
plt.tight_layout(); plt.show()
