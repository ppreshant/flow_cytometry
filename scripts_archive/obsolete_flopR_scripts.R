# obsolete_flopR_scripts.R

# was at the end of analyze_fcs.R ; now moved for future reference 

# Obsolete/ FlopR processing ----

# Currently using processed files from custom python script based on FlowCal.py ; So ignore this section


# The below was attempts to use R based processing similar to FlowCal -- fails in gating for cells due to noisy data
# is also 60 times slower than FlowCal (without plotting for both)

# # using FlopR single file processing : : error : 'x' must be object of class 'flowFrame'
# process_fcs('flowcyt_data/S044_new fusions_4-5-22/96 Well Plate (deep)/Sample Group - 1/Unmixing-1/F11 Well - F11 WLSM.fcs',
#             flu_channels = c('mScarlet-I-A'),
#             do_plot = T
#             )

# # FlopR full directory processing
# ptm <- proc.time() # time initial
# process_fcs_dir(dir_path = str_c('flowcyt_data', 'test', sep = '/'), 
#                 pattern = '.fcs',
#                 flu_channels = c('mScarlet-I-A'),
#                 neg_fcs = 'E03',
#                 
#                 calibrate = TRUE,
#                 mef_peaks = beads_values
#                 )
# proc.time() - ptm # time duration of the run