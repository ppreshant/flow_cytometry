# g15_beads_functions.py

""" To detect, load beads fcs file and make calibration set
Created: 1-10-22
@Prashant
"""

def process_beads_file(beads_filepath,
                       scatter_channels, fluorescence_channels,
                      give_full_output=False):
    
    """ Load the beads .fcs file, gate it, plot and make calibration curve
    
    Parameters
    ----------
    beads_filepath : str
        The full path of the .fcs file where beads are found
    scatter_channels : list
        The channels to be used for scattering depending on instrument - ex: ['FSC-A', 'SSC-A']
    fluorescence_channels : list
        The channels to be used for fluorescence depending on experiment, instrument - ex: ['gfpmut3-A', 'mcherry2-A']
    give_full_output : bool
        Use True only for troubleshooting of the beads calibration model
    
    Returns
    -------
    transform_fxn : function
        Transformation function to convert flow cytometry data from RFI units to MEF. This function has the following signature:

    `data_mef = transform_fxn(data_rfi, channels)`


    
    """
    
    # %% imports
    
    import matplotlib.pyplot as plt # plotting package
    import FlowCal # flow cytometry processing
    import os # for file path manipulations
    from IPython.display import display, Markdown # for generating markdown messages
    
    # read in the beads
    beads_data = FlowCal.io.FCSData(beads_filepath)
    
    # Message about the beads file being read
    print('Reading beads from file : ' + os.path.basename(beads_filepath))
    
    
    # Error check : for fluorescence channels
    fluor_channels_check = [i in beads_data.channels for i in fluorescence_channels] # check for presence
    if not(all(fluor_channels_check)):
        print("Fluorescence not found in the beads, to skip MEFLing, re-run with 'beads_match_name = None' \n\n\
fluorescence channel check in beads")
        print([f'{i} : {i in beads_data.channels}' for i in fluorescence_channels])
        
        print("\n Here are all channels in the beads : ") ; print(beads_data.channels)
        ValueError('Code stopped because beads file didnt have the right fluor channels. happens when reusing beads from another run. Make sure to remove the beads file from the dataset before running!') 
    
    
    
    
    # Visualize raw data of beads : for troubleshooting 
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
    
    # Error check : low beads after gating
    if beads_gate1.__len__() < 2000:
        if input('Beads have aberrant scatter profile, look at the plot and decide to proceed; yes (1) or no (0)'):
            ValueError('Code stopped by user intervention due to beads file. Change beads file and rerun')
    
    # TODO: Have a way to discard the aberrant files with a warning and continue running?
    
    
    # gate 30% # since my beads have lot of debris at low FSC, SSC ranges
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
    
    # Note : not doing singlet gating since the fsc vs ssc profile looks pretty tight 
    # and we're discarding lot of events already
    
    # %% Calibration transformation
    
    display(Markdown('## Getting calibration data from beads')) # Indicate section
    
    # specify the mefl values from data sheet
    # eventually will read this off an excel file or two 
    mGreenLantern_mefl_vals = [0, 771, 2106, 6262, 15183, 45292, 136258, 291042]
    mScarlet_mefl_vals =      [0, 487, 1474, 4516, 11260, 34341, 107608, 260461]
    
    # Make the MEFL transformation function using gated beads data
    to_mef = FlowCal.mef.get_transform_fxn(beads_densitygate30.gated_data, 
                                           mef_values = [mGreenLantern_mefl_vals, mScarlet_mefl_vals],
                                           mef_channels = fluorescence_channels,
                                           plot=True,
                                          full_output = give_full_output)
    plt.show()
    
    
    return to_mef # return the calibration matrix..