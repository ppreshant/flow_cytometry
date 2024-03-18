# 16-subset_cytoset.R

#' Subset a cytoset using it's metadata from `pData(..)`
#' Side effect creates universal variable fl.subset - which is the main purpose of this script
#' @param : .flset = cytoset to subset
#' #' @param ... one ore more conditions for custom filtering
#' @param return_fcsunique.subset T/F: if you want to return the summary (from 7-..R for plots) or not (from 20-..R)
#' @return fcsunique.subset subseted summary for adding median/other labels on plots..
#' ..outputs a unique subset tibble with metadata and medians for labelling ridgeline plots

#' Side effect : creates global variables : fl.subset, num_of_unique_samples, and est_plt_side

subset_cytoset <- function(.flset = fl.set,
                           
                           non_data_stuff = 'NA|Beads|beads|PBS', 
                           specific_data = '.*', 
                           exclude_category = 'none',
                           return_fcsunique.subset = TRUE,
                           ...)
{
  #' Make a subset of data for plotting purposes :: ex: Remove PBS controls, beads etc. 
  #' Using this for plotting in nice a orientation mimicking the plate wells if possible
  
  samples_in_fl <- sampleNames(.flset) # get all the sample names
  
  
  # subset pData ----
  
  # subset the summary dataset : for overlaying medians onto plots 
  pdata.subset <- 
    
    pData(.flset) %>% # previously used flowworkspace_summary ; pData would be robust
    
    filter(!str_detect(full_sample_name, non_data_stuff), # remove samples without metadata or beads/pbs
           !str_detect(sample_category, exclude_category), # exclude a specific category
           
           str_detect(full_sample_name, specific_data), # select specific data by name
           str_detect(well, '.*'), # select with regex for wells : Example row D : 'D[:digit:]+'
           ...) # custom filtering
  
  # TODO : use sample_metadata when flowworkspace_summary is not available? Can't plot medians then
  
  
  # get the full filenames of the samples to be included  
  samples_to_include <- rownames(pdata.subset)  # take the sample names to be plotted
  # BUG? : selects the whole .flset to subset when samples_to_include is empty vector

  
  # Subset cytoset ----
  
  # subset the cytoset carrying the `.fcs` data : Make a global variable
  fl.subset <<- .flset[samples_to_include] # select only a subset of the .fcs data cytoset. 
  # Warning::  editing this fl.subset might change the original fl.set as well since this is a symbolic link
  
  
  # plot dimensions ----
  
  # estimate dimensions to save the plot in (for automated workflow)
  # num_of_facets <- pltden_red$facet$params %>% length() # find the number of panels after making pltden_red
  num_of_unique_samples <<- pData(fl.subset) %>% pull(full_sample_name) %>% unique() %>% length()
  est_plt_side <<- sqrt(num_of_unique_samples) %>% round() %>% {. * 2.5} # make 2.5 cm/panel on each side (assuming square shape)
  
  
  # subset flowworkspace_summary ----
  
  if(return_fcsunique.subset)
    
  {
  
    # Get unique values of the flowworkspace_summary: for adding labels to plot/medians
    fcsunique.subset <- 
      
      flowworkspace_summary %>% # filter the summary again 
      # TODO : can recalculate the summary by putting it in a function rather than repeat filtering..
      # develop in: 23-get-flowworkspace-summary.R
      
      filter(!str_detect(full_sample_name, non_data_stuff), # remove samples without metadata or beads/pbs
             !str_detect(sample_category, exclude_category), # exclude a specific category
             
             str_detect(full_sample_name, specific_data), # select specific data by name
             str_detect(well, '.*'), # select with regex for wells : Example row D : 'D[:digit:]+'
             ...) %>%  # custom filtering
      
      
      # select useful columns (for plotting medians on ridgelineplots)
      select(assay_variable, sample_category, any_of(c('data_set', 'other_category')), # other_categories for combined datasets
             Fluorophore, mean_medians) %>% 
      
      unique() %>% # choose unique entries in the tibble
      
      mutate(across(where(is.factor), fct_drop)) # drop unused factor levels
    
    
    return(fcsunique.subset)
  
  } else return(NULL) # if flowworkspace subset is not asked for, return NULL (only side effects matter)
  
}