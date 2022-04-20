"""
Adhoc coding to test out Flowcal 
Copying snippets of script from Lauren Gambill's workflow


@author: Prashant
@date 9/April/22
"""


# User inputs
dir_path = 'flowcyt_data/'
inter_path = 'S044_new fusions_4-5-22/96 Well Plate (deep)/Sample Group - 1/Unmixing-1/'
fl_nm =  'E01 Well - E01 WLSM'
beads_fl_nm = 'F11 Well - F11 WLSM'

fl_path = dir_path + inter_path + fl_nm + '.fcs'
beads_fl_path = dir_path + inter_path + beads_fl_nm + '.fcs'
# fl_path = 'flowcyt_data/E1.4a_Vmax-Ribozyme-1_8-12-20.fcs'
# %% imports

# import os # for changing file paths etc.
# os.chdir(r'C:\Users\new\Box Sync\Stadler lab\Data\Flow cytometry (FACS)\FACS analysis')
import matplotlib.pyplot as plt # plotting package
import FlowCal # flow cytometry processing
import scripts_general_fns.g3_python_utils_facs

# %% load data
s = FlowCal.io.FCSData(fl_path)

# %% see channels
s.channels # data from different machines have different names

# %% visualize
FlowCal.plot.hist1d(s, channel=['mGreenLantern cor-A'])

# plt.pyplot.hist(s[:, 'FSC-HLin'], bins=100)
# plt.pyplot.show()

# plot both density scatter plot and histogram
FlowCal.plot.density_and_hist(s,
                              density_channels = ['FSC-A', 'SSC-A'],
                              density_params = {'mode': 'scatter'},
                              hist_channels = ['mScarlet-I-A'])
plt.tight_layout() # improves the dual plot label positioning
plt.show()


# %% Gating
# gate saturated events - high and low
s_g1 = FlowCal.gate.high_low(s, channels = ['FSC-A', 'SSC-A'])

# auto density gating : for 50% of cells
s_gate50 = FlowCal.gate.density2d(s_g1,
                                   channels = ['FSC-A', 'SSC-A'],
                                   gate_fraction = 0.50,
                                   full_output=True) # full => saves outline

FlowCal.plot.density_and_hist(s_g1,
                              gated_data = s_gate50.gated_data,
                              gate_contour = s_gate50.contour,
                              density_channels=['FSC-A', 'SSC-A'],
                              density_params={'mode': 'scatter'},
                              hist_channels=['mGreenLantern cor-A', 'mScarlet-I-A'])
plt.tight_layout(); plt.show()


# %% visualize gate
# auto density gating
# full output saves the contour of the gate which will be shown in plot
s_gate75 = FlowCal.gate.density2d(s_g1,
                                   channels = ['FSC-A', 'SSC-A'],
                                   gate_fraction = 0.75,
                                   full_output=True)

FlowCal.plot.density_and_hist(s_g1,
                              gated_data = s_gate75.gated_data,
                              gate_contour = s_gate75.contour,
                              density_channels=['FSC-A', 'SSC-A'],
                              density_params={'mode': 'scatter'},
                              hist_channels=['mScarlet-I-A'])
plt.tight_layout(); plt.show()

FlowCal.plot.density2d(s_gate75.gated_data,
                       channels=['mScarlet-I-A', 'SSC-A'],
                       mode = 'scatter')

# %% doublet discrimination

FlowCal.plot.density2d(s_g1,
                       channels=['FSC-A', 'FSC-H'],
                       mode = 'scatter')

FlowCal.plot.density2d(s_gate75.gated_data,
                       channels=['FSC-A', 'FSC-H'],
                       mode = 'scatter')
# confirm that the gating only retains the good high density area
# where H and A are linear

# %% beads
# read in the beads
b = FlowCal.io.FCSData(beads_fl_path)

# trim saturated : more than 1000 in FSC, SSC
# removes the large cloud of points 
b_g1 = FlowCal.gate.high_low(b,
                             channels = ['FSC-A', 'SSC-A'],
                             low=(1000))

# gate 30% 
b_gate30 = FlowCal.gate.density2d(b_g1,
                                    channels=['FSC-A', 'SSC-A'],
                                    gate_fraction= 0.3,
                                    full_output=True)

# visualize the gating effect
FlowCal.plot.density_and_hist(b_g1,
                              gated_data = b_gate30.gated_data,
                              gate_contour = b_gate30.contour,
                              density_channels = ['FSC-A', 'SSC-A'],
                              density_params = {'mode': 'scatter'},
                              hist_channels= ['mGreenLantern cor-A','mScarlet-I-A'])
plt.tight_layout(); plt.show()

# visualize the gated population
FlowCal.plot.density_and_hist(b_gate30.gated_data,
                              density_channels = ['FSC-A', 'SSC-A'],
                              density_params = {'mode': 'scatter'},
                              hist_channels = ['mGreenLantern cor-A', 'mScarlet-I-A'])
plt.tight_layout(); plt.show()


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

# %% PBS check
pbs = FlowCal.io.FCSData(sony_well_to_file('F10'))


FlowCal.plot.density_and_hist(pbs,
                              density_channels = ['FSC-A', 'SSC-A'],
                              density_params = {'mode': 'scatter'},
                              hist_channels= ['mScarlet-I-A'])
