# 16-subset_cytoset.R

#' Subset a cytoset by using it's flowworkspace_summary (`summary(fl.set)`)/ in future, `pData()` might work too
#' outputs a unique subset tibble with metadata and medians for labelling ridgeline plots
#' Side effect : creates universal variable fl.subset - which is the main purpose of this script

subset_cytoset <- function(non_data_stuff, specific_data, exclude_category)
{
  #' Make a subset of data for plotting purposes :: ex: Remove PBS controls, beads etc. 
  #' Using this for plotting in nice a orientation mimicking the plate wells if possible
  
  samples_in_fl <- sampleNames(fl.set) # get all the sample names
  
  
  # subset the summary dataset : for overlaying medians onto plots 
  fcssummary.subset <- 
    flowworkspace_summary %>% 
    filter(!str_detect(full_sample_name, non_data_stuff), # remove samples without metadata or beads/pbs
           !str_detect(sample_category, exclude_category), # exclude a specific category
           
           str_detect(full_sample_name, specific_data), # select specific data by name
           str_detect(well, '.*')) # select with regex for wells : Example row D : 'D[:digit:]+'
  
  # TODO : use sample_metadata when flowworkspace_summary is not available?
  
  
  # get the full filenames of the samples to be included  
  samples_to_include <- pull(fcssummary.subset, filename) %>%  # take the sample names to be plotted
    unique()
  
  # subset the cytoset carrying the `.fcs` data : Make a global variable
  fl.subset <<- fl.set[samples_to_include] # select only a subset of the .fcs data cytoset. 
  # Warning::  editing this fl.subset might change the original fl.set as well since this is a symbolic link
  
  
  # Get unique values : for adding labels to plot/medians
  fcsunique.subset <- 
    select(fcssummary.subset, 
           assay_variable, sample_category, any_of('other_category'), # other_categories for pooled datasets
           Fluorophore, mean_medians) %>% 
    unique() %>% # choose unique entries in the tibble
    
    mutate(across(where(is.factor), fct_drop)) # drop unused factor levels
  
  
  # Optional (for cross experiment analysis): save subset of .fcs data with easier names (write.FCS)
  # Question : How did we make this cross expt dataset? 24/2/23 -- did I rewrite the combine workflow script?
  # TODO : make this using an optional user input variable?
  
  # mutate(fcssummary.subset,
  #        new_flnames = str_c(str_replace(name, ' /', '_'), '_', well)) %>% # unique names by well
  #   pull(new_flnames) %>% unique %>% # get the new filenames
  #   {str_c('processed_data/ramfacs_S1_variants/', ., '-S044.fcs')} %>% # make file path (ensure folder exists)
  #   {for (i in 1:length(.)) {write.FCS(fl.subset[[i]], filename = .[i])}} # save each .fcs files
  
  
  
}