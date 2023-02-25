# 18-load_combined_cytosets.R

#' Load combined cytosets from multiple independent runs/plates
#' The names of datasets need to be processed a different way

load_combined_cytosets <- function(folder_name)
{
  
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
  
  
  # Save as separate universal variable
  # get a subset of the pData to continue workflow from regular analyze_fcs.R workflow
  sample_metadata <<- mutate(new_pdata, filename = name) # duplicate column with 'filename' for matching
  
  
  return(fl.set) 
  
}