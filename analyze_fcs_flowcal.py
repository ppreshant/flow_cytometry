""" Process a directory of .fcs files using FlowCal

Wrapper script to process a directory of Flow cytometry data
using FlowCal, repository : https://github.com/taborlab/FlowCal/
- Opens all .fcs files within the directory
- Attaches sample names from a google sheet 
    (could change to local .csv file too)
- Run standard processes, uses sample named as beads for MEFLing
- Saves standard plots and outputs summary statistics data in .csv

----------
Following tutorial to use Flowcal 
https://taborlab.github.io/FlowCal/python_tutorial/

@author: Prashant
@date 9/April/22
"""
# It is best to create a spyder project in the folder containing
# this file and the subdirectories as in this repository
#---- Make sure that python is running from the working directory
# --- containing this file; since the paths below are relative

# User inputs # paths are relative to the working directory
fcs_root_folder = 'flowcyt_data/'
fcs_experiment_folder = 'test/'

# Give the pattern/well to match the bead file (ex: E01 etc.)
beads_match_name =  'beads'

# %% imports

# import os # for changing file paths etc.
# If needed, change the current working directory
# os.chdir(r'C:\Users\new\Box Sync\Stadler lab\Data\Flow cytometry (FACS)')

import matplotlib.pyplot as plt # plotting package
import FlowCal # flow cytometry processing

# import local packages
from scripts_general_fns.g3_python_utils_facs import *
from scripts_general_fns.g4_file_inputs import get_fcs_files
from scripts_general_fns.g8_process_single_fcs_flowcal import process_single_fcs_flowcal

# %% get .fcs file list
fcspaths, fcslist = get_fcs_files(fcs_root_folder + fcs_experiment_folder)
# Loads them as lists in alphabetical order I assume?

# Get the beads file based on user provided well/pattern
beads_filepath = [m for m in fcspaths if beads_match_name in m][0]

# Remove beads from the fcs path list
fcspaths.remove(beads_filepath)
fcslist = [m for m in fcslist if beads_match_name not in m]
# TODO: Need a better index based way to trim fcslist of the beads

# %% load data
fcs_data = [FlowCal.io.FCSData(fcs_file) for fcs_file in fcspaths]

# select one file for workflow making 
single_fcs = fcs_data[1] # load second file
# %% bring sample names

# bring sample names from google sheet, 
# attach them to the dataset as a name entry


# %% see channels to verify how they are named
fcs_data[0].channels # data from different machines have different names
# in future we will convert them into standardized names in the script..

# %% visualize raw data

# # plot both density scatter plot and histogram for a channel
# FlowCal.plot.density_and_hist(single_fcs,
#                               density_channels = ['FSC-A', 'SSC-A'],
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
    

# %% Beads processing

# read in the beads
beads_data = FlowCal.io.FCSData(beads_filepath)

# trim saturated : more than 1000 in FSC, SSC
# removes the large cloud of points 
beads_gate1 = FlowCal.gate.high_low(beads_data,
                             channels = ['FSC-A', 'SSC-A'],
                             low=(1000)) 
# TODO: low=threshold of 1,000 is arbitrary : my beads have lot of debris, 
# might change depending on gains. Try to generalize
 

# gate 30% # since my beads have lot of debris
beads_densitygate30 = FlowCal.gate.density2d(beads_gate1,
                                    channels=['FSC-A', 'SSC-A'],
                                    gate_fraction= 0.3,
                                    full_output=True)

# visualize the gating effect
FlowCal.plot.density_and_hist(beads_gate1,
                              gated_data = beads_densitygate30.gated_data,
                              gate_contour = beads_densitygate30.contour,
                              density_channels = ['FSC-A', 'SSC-A'],
                              density_params = {'mode': 'scatter'},
                              hist_channels= ['mGreenLantern cor-A','mScarlet-I-A'])
plt.tight_layout(); plt.show()

# visualize the gated population
FlowCal.plot.density_and_hist(beads_densitygate30.gated_data,
                              density_channels = ['FSC-A', 'SSC-A'],
                              density_params = {'mode': 'scatter'},
                              hist_channels = ['mGreenLantern cor-A', 'mScarlet-I-A'])
plt.tight_layout(); plt.show()


# %% Calibration transformation

# specify the mefl values from data sheet
# eventually will read this off an excel file or two 
mGreenLantern_mefl_vals = [0, 771, 2106, 6262, 15183, 45292, 136258, 291042]
mScarlet_mefl_vals =      [0, 487, 1474, 4516, 11260, 34341, 107608, 260461]

# Make the MEFL transformation function using gated beads data
to_mef = FlowCal.mef.get_transform_fxn(beads_densitygate30.gated_data, 
                                       mef_values = [mGreenLantern_mefl_vals, mScarlet_mefl_vals],
                                       mef_channels = ['mGreenLantern cor-A', 'mScarlet-I-A'],
                                       plot=True)
plt.show()




# %% Calibration vectorized
# trial run

# convert data into MEFLs
calibrated_fcs = [process_single_fcs_flowcal(\
                        single_fcs,
                        to_mef,
                        make_plots=False)\
                  for single_fcs in fcs_data]


# timing and testing
# %timeit -n 1 -r 1 calibrated_fcs = process_single_fcs_flowcal(\
#                         singlefcs_singlets90.gated_data,
#                         to_mef,
#                         make_plots=True)




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

# %% Alternate gating percentage
# auto density gating
# full output saves the contour of the gate which will be shown in plot
# singlefcs_gate75 = FlowCal.gate.density2d(singlefcs_gate1,
#                                     channels = ['FSC-A', 'SSC-A'],
#                                     gate_fraction = 0.75,
#                                     full_output=True)

# FlowCal.plot.density_and_hist(singlefcs_gate1,
#                               gated_data = singlefcs_gate75.gated_data,
#                               gate_contour = singlefcs_gate75.contour,
#                               density_channels=['FSC-A', 'SSC-A'],
#                               density_params={'mode': 'scatter'},
#                               hist_channels=['mScarlet-I-A'])
# plt.tight_layout(); plt.show()

# # Singlets: auto density gating : for 90% of cells w FSC-A vs H
# singlefcs_g75_singlets90 = FlowCal.gate.density2d(singlefcs_gate75.gated_data,
#                                    channels = ['FSC-A', 'FSC-H'],
#                                    gate_fraction = 0.90,
#                                    full_output=True) # full => saves outline

# # plot before and after gating
# FlowCal.plot.density_and_hist(singlefcs_gate75.gated_data,
#                               gated_data = singlefcs_g75_singlets90.gated_data,
#                               gate_contour = singlefcs_g75_singlets90.contour,
#                               density_channels=['FSC-A', 'FSC-H'],
#                               density_params={'mode': 'scatter'},
#                               hist_channels=['mGreenLantern cor-A', 'mScarlet-I-A'])
# plt.tight_layout(); plt.show()

# # Plot FSC vs SSC now
# FlowCal.plot.density2d(singlefcs_g75_singlets90.gated_data,
#                        mode='scatter',
#                        channels=['FSC-A', 'SSC-A'])

# %% Calibration

# specify the mefl values from data sheet
# eventually will read this off an excel file or two 
mGreenLantern_mefl_vals = [0, 771, 2106, 6262, 15183, 45292, 136258, 291042]
mScarlet_mefl_vals =      [0, 487, 1474, 4516, 11260, 34341, 107608, 260461]
 
to_mef = FlowCal.mef.get_transform_fxn(beads_densitygate30.gated_data, 
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
        
    # %% PBS check
# pbs = FlowCal.io.FCSData(sony_well_to_file('F10'))


# FlowCal.plot.density_and_hist(pbs,
#                               density_channels = ['FSC-A', 'SSC-A'],
#                               density_params = {'mode': 'scatter'},
#                               hist_channels= ['mScarlet-I-A'])

# %% summary plots

FlowCal.stats.median(calibrated_fcs, 
                     channels = ['mGreenLantern cor-A', 'mScarlet-I-A'])

# %% violin plots 

# Make violin plot and show medians
FlowCal.plot.violin(calibrated_fcs,
                    channel = 'mScarlet-I-A',
                    draw_summary_stat=True,
                    draw_summary_stat_fxn=np.median)  
