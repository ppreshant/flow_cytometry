# load_combined_cytosets
# start as an adhoc script then make into a function that can be loaded

# only for independent script run
# Prelims ----
source('./0-general_functions_fcs.R') # call the function to load libraries and auxilliary functions

source('./0.5-user_inputs.R') # gather user inputs : file name, fluorescent channel names


# User inputs ---- 

base_directory <- 'processed_data/' # processed_data/ or flowcyt_data/ and any subfolders
folder_name <- 'S063_combined/' # the combined dataset will be exported to this folder inside 'processed_data/..'

# Label x axis (assay_variable) : attaches plasmid numbers with informative names for plotting
sample_name_translation <- c('(^10.|110|119).*' = 'J23x', # 'oldnames|regex' = informative_name
                             '^HW.*' = 'H.Wang P-RBS', 
                             '^(S|P|Empty).*' = 'Salis, others',
                             '^(54|^6.|^9.|^13.|112|113).*' = 'Origins')


# Get data ----

fl.path = str_c(base_directory, folder_name, file.name_input, '.fcs')

fl.set <- read_multidata_fcs(fl.path, # returns multiple fcs files as a cytoset (package = flowWorkspace)
                             fcs_pattern_to_subset = fcs_pattern_to_subset,
                             directory_path = str_c(base_directory, folder_name, file.name_input))




# Fix metadata ----

new_pdata <- pData(fl.set) %>% 
  
  separate(name, into = c('assay_variable', 'sample_category', 'well', 'data_set', NA), remove = F) %>% # split into metadata
  mutate(other_category = str_replace_all(assay_variable, sample_name_translation)) # split names into categories

pData(fl.set) <- new_pdata # replace the pData

