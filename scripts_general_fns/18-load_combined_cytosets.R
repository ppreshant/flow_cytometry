# 18-load_combined_cytosets.R

#' Load combined cytosets from multiple independent runs/plates
#' The names of datasets need to be processed a different way
#' @param : folder_name : load datasets from this folder
#' @pram : make_other_category : Make TRUE to group samples into `other_category` to facet plots
load_combined_cytosets <- function(folder_name, 
                                   make_other_category = FALSE)
{
  
  # Get data ----
  
  fl.path = str_c(base_directory, folder_name, file.name_input, '.fcs')
  
  fl.set <- read_multidata_fcs(fl.path, # returns multiple fcs files as a cytoset (package = flowWorkspace)
                               fcs_pattern_to_subset = fcs_pattern_to_subset,
                               directory_path = str_c(base_directory, folder_name, file.name_input))
  
  # Fix metadata ----
  
  new_pdata <- pData(fl.set) %>% 
    
    separate(name, # split metadata into columns
             into = c('assay_variable', 'sample_category', 'well', 'data_set', NA), sep = '_|\\.',
             remove = F) %>% 
    
    mutate(full_sample_name = str_c(assay_variable, sample_category, sep = " /")) %>%  # make a fusion column for unique name per replicate
    
    {if(make_other_category) # translate groups of variables into other_category
      mutate(., other_category = str_replace_all(assay_variable, sample_name_translation)) else .} # split names into categories
  
  pData(fl.set) <- new_pdata # replace the pData
  
  
  # Save as separate universal variable
  # get a subset of the pData to continue workflow from regular analyze_fcs.R workflow
  sample_metadata <<- mutate(new_pdata, filename = name) # duplicate column with 'filename' for matching
  
  
  return(fl.set) 
  
}