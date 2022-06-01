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
# this file and re-create the subdirectories as in this repository
#---- Make sure that python is running from the working directory
# --- containing this file; since the paths below are relative
#  Can use spyder -p . to start spyder from the project in the working dir


# %% processing fcs directory function

def process_fcs_dir(make_processing_plots=False):

    # %% imports
    
    import matplotlib.pyplot as plt # plotting package
    import FlowCal # flow cytometry processing
    import os # for file path manipulations
    import numpy as np # for arrays
    import re # for regular expression : string matching
    
    # import local packages
    import scripts_general_fns.g3_python_utils_facs as myutils
    from scripts_general_fns.g4_file_inputs import get_fcs_files
    from scripts_general_fns.g8_process_single_fcs_flowcal import process_single_fcs_flowcal
    from scripts_general_fns.g9_write_fcs_wrapper import write_FCSdata_to_fcs
    
    # import config : directory name and other definitions
    from scripts_general_fns.g10_user_config import fcs_root_folder, fcs_experiment_folder,\
        beads_match_name,\
        scatter_channels, fluorescence_channels
    
    # If needed, change the current working directory
    # os.chdir(r'C:\Users\new\Box Sync\Stadler lab\Data\Flow cytometry (FACS)')
    
    # %% get .fcs file list
    fcspaths, fcslist = get_fcs_files(fcs_root_folder + '/' + fcs_experiment_folder + '/')
    # Loads them as lists in alphabetical order I assume?
    
    # Get the beads file based on user provided well/pattern
    beads_filepath = [m for m in fcspaths if re.match(beads_match_name, m, re.IGNORECASE)][0]
    
    # Remove beads from the fcs path list
    fcspaths.remove(beads_filepath)
    fcslist = [m for m in fcslist if m not in os.path.basename(beads_filepath)] # and filename list
    # TODO: Need a better index based way to trim fcslist of the beads
    # when multiple beads files present;
    
    # output file paths
    # trim the directory to remove excessive subsidectories (from Sony instruments)
    outfcspaths = ['processed_data/' + fcs_experiment_folder + '/' + os.path.basename(singlefcspath) \
                   for singlefcspath in fcspaths]
    
    # %% load data
    fcs_data = [FlowCal.io.FCSData(fcs_file) for fcs_file in fcspaths]
    
    # select one file for workflow making 
    single_fcs = fcs_data[0] # load first file
    # %% bring sample names
    
    # bring sample names from google sheet, 
    # attach them to the dataset as a name entry
    

    # %% Beads processing
    
    # read in the beads
    beads_data = FlowCal.io.FCSData(beads_filepath)
    
    # troubleshooting beads : raw data visual
    FlowCal.plot.density_and_hist(beads_data,
                                  density_channels=scatter_channels,
                                  density_params={'mode': 'scatter'},
                                  hist_channels=fluorescence_channels)
    plt.tight_layout(); plt.show()
    
    
    # trim saturated : more than 1000 in FSC, SSC
    # removes the large cloud of points 
    beads_gate1 = FlowCal.gate.high_low(beads_data,
                                 channels = scatter_channels,
                                 low=(1000)) 
    # TODO: low=threshold of 1,000 is arbitrary : Generalize this--
    # my Spherotech beads have lot of debris < 1,000, 
    # but threshold might change depending on gains.
    
    if beads_gate1.__len__() < 2000:
        if input('Beads have aberrant scatter profile, look at the plot and decide to proceed; yes (1) or no (0)'):
            ValueError('Code stopped by user intervention due to beads file. Change beads file and rerun')
        
    # TODO: Have a way to discard the aberrant files with a warning and continue running?
     
    
    # gate 30% # since my beads have lot of debris
    beads_densitygate30 = FlowCal.gate.density2d(beads_gate1,
                                        channels=scatter_channels,
                                        gate_fraction= 0.3,
                                        full_output=True)
    
    # visualize the gating effect
    FlowCal.plot.density_and_hist(beads_gate1,
                                  gated_data = beads_densitygate30.gated_data,
                                  gate_contour = beads_densitygate30.contour,
                                  density_channels = scatter_channels,
                                  density_params = {'mode': 'scatter'},
                                  hist_channels= fluorescence_channels)
    plt.tight_layout(); plt.show()
    
    # visualize the gated population
    FlowCal.plot.density_and_hist(beads_densitygate30.gated_data,
                                  density_channels = scatter_channels,
                                  density_params = {'mode': 'scatter'},
                                  hist_channels = fluorescence_channels)
    plt.tight_layout(); plt.show()
    
    
    # %% Calibration transformation
    
    # specify the mefl values from data sheet
    # eventually will read this off an excel file or two 
    mGreenLantern_mefl_vals = [0, 771, 2106, 6262, 15183, 45292, 136258, 291042]
    mScarlet_mefl_vals =      [0, 487, 1474, 4516, 11260, 34341, 107608, 260461]
    
    # Make the MEFL transformation function using gated beads data
    to_mef = FlowCal.mef.get_transform_fxn(beads_densitygate30.gated_data, 
                                           mef_values = [mGreenLantern_mefl_vals, mScarlet_mefl_vals],
                                           mef_channels = fluorescence_channels,
                                           plot=True)
    plt.show()
    
    
    
    
    # %% Calibration vectorized
    # trial run
    
    # convert data into MEFLs for all .fcs files
    calibrated_fcs_data = [process_single_fcs_flowcal\
                           (single_fcs,
                            to_mef,
                            make_plots=make_processing_plots)\
                      for single_fcs in fcs_data]
    
       
    # timing and testing
    # %timeit -n 1 -r 1 python command here
    
    # %% summary plots
    
    median_data = [FlowCal.stats.median(single_fcs, 
                         channels = fluorescence_channels)\
                   for single_fcs in calibrated_fcs_data]
    
    # %% violin plots 
    
    # Make violin plot and show medians
    FlowCal.plot.violin(calibrated_fcs_data,
                        channel = fluorescence_channels[1], # 'mScarlet-I-A'
                        draw_summary_stat=True,
                        draw_summary_stat_fxn=np.median)  
    
    # %% Save calibrated fcs data to file
    
    write_FCSdata_to_fcs('processed_data/test/test2.fcs', single_fcs)
    
    [write_FCSdata_to_fcs(filepath, fcs_data) \
     for filepath, fcs_data in zip(outfcspaths, calibrated_fcs_data)]


    def __main__():
        process_fcs_dir()