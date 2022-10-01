# g11_gating_functions.py

"""
Created: 30-9-22
@Prashant
"""

def gate_and_reduce_dataset(single_fcs,
                            scatter_channels,
                            fluorescence_channels,
                            density_gating_fraction = 0,
                            make_plots = False):

    
    """Reduce dataset by gating out low and high, density gating, singlet gate with FlowCal
    Make optional plots
    
    density gating threshold is user controlled in the g10_user_config.py file
    singlet gating retains 90% of events
    
    
    Parameters
    ----------
    single_fcs : FlowCal.io.FCSData
        The .fcs file data for the current file to be processed.
    scatter_channels : list
        The channels to be used for scattering depending on instrument - ex: ['FSC-A', 'SSC-A']
    fluorescence_channels : list
        The channels to be used for fluorescence depending on experiment, instrument - ex: ['gfpmut3-A', 'mcherry2-A']
    make_plots : bool
        Indicate if plots for each iteration should be made or not
        
    Returns
    -------
    reduced FlowCal.io.FCSData dataset.

    """
    
    
    
    import re # regular expressions
    import matplotlib.pyplot as plt # plotting package
    import FlowCal # flow cytometry processing
    
    # import config : directory name and other definitions
    from scripts_general_fns.g10_user_config import density_gating_fraction as default_density_gating_fraction
    
    # determine the density gating fraction user input to function vs default -- in the g10_user_config.py
    if not density_gating_fraction : density_gating_fraction = default_density_gating_fraction
    
    # gate out saturated events - high and low
    singlefcs_gate1 = FlowCal.gate.high_low(single_fcs, channels = scatter_channels)

    # auto density gating : for 50% of cells
    singlefcs_densitygate = FlowCal.gate.density2d(singlefcs_gate1,
                                       channels = scatter_channels,
                                       gate_fraction = density_gating_fraction,
                                       full_output=True) # full => saves outline
    
    
    if make_plots:
        print('---> density gate')
        FlowCal.plot.density_and_hist(singlefcs_gate1,
                                      gated_data = singlefcs_densitygate.gated_data,
                                      gate_contour = singlefcs_densitygate.contour,
                                      density_channels=scatter_channels,
                                      density_params={'mode': 'scatter'},
                                      hist_channels=fluorescence_channels)
        plt.tight_layout(); plt.show()

    # %% doublet discrimination
    singlet_channels = [scatter_channels[0], re.sub('-A$', '-H', scatter_channels[0])]
    
    # Singlets: auto density gating : for 90% of cells w FSC-A vs H
    singlefcs_singlets90 = FlowCal.gate.density2d(singlefcs_densitygate.gated_data,
                                       channels = singlet_channels,
                                       gate_fraction = 0.90,
                                       full_output=True) # full => saves outline
    
    if make_plots:
        print('---> singlet gate')
        # plot before and after singlet gating
        FlowCal.plot.density_and_hist(singlefcs_densitygate.gated_data,
                                      gated_data = singlefcs_singlets90.gated_data,
                                      gate_contour = singlefcs_singlets90.contour,
                                      density_channels=singlet_channels,
                                      density_params={'mode': 'scatter'},
                                      hist_channels=fluorescence_channels)
        plt.tight_layout(); plt.show()
        
        print('--------------------------------------------------------------')

    # confirm that the gating only retains the good high density area
    # where H and A are linear
    
    return singlefcs_singlets90
    