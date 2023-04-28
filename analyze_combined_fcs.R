# adhoc script to plot combined data from multiple plates ; will generalize slowly
# S063 1a, 1b, 2 : test case

# Prelims ----
source('./0-general_functions_fcs.R') # call the function to load libraries and auxilliary functions

source('./0.5-user_inputs.R') # gather user inputs : file name, fluorescent channel names


# User inputs ---- 

base_directory <- 'processed_data/' # processed_data/ or flowcyt_data/ and any subfolders
folder_name <- 'S063_combined/' # the combined dataset will be exported to this folder inside 'processed_data/..'

title_name <- 'S063_Marine promoters-2' # override after loading user_inputs.R

# Label x axis (assay_variable) : attaches plasmid numbers with informative names for plotting
sample_name_translation <- c('(^10.|110|119).*' = 'J23x', # 'oldnames|regex' = informative_name
                            '^HW.*' = 'H.Wang P-RBS', 
                            '^(S|P|Empty).*' = 'Salis, others',
                            '^(54|^6.|^9.|^13.|112|113).*' = 'Origins')


# Merge data using `merge_cytosets_and_save.R` here


# Load combined dataset ----

source('scripts_general_fns/18-load_combined_cytosets.R') # source script
fl.set <- load_combined_cytosets(folder_name, make_other_category = T)


# Side processing ----

# ------------------------ NOTE ----------------------------
# run `Autodetect channels` and `Processing` from `analyze_fcs.R`
# Get a subset of the data -- run the `Subset data` section from `7-exploratory_data_view.R`
# Also run the variables in the first 2 lines of the `Exploratory plots` section in `7-..R`


# Plotting ----


# Call function to plot ridges ; optionally save them with title_name + suffixes
source('scripts_general_fns/17-plot_ridges_fluor.R') # source script
plt_ridges <- plot_ridges_fluor(.show_medians = F, .facets_other_category = T) 


# Summary stats ----

# Save summary stats