# 6-wrappers_utilities.R
# miscellaneous functions 

# Convenience function for plotting directory and .png suffix for adhoc plots
plot_as <- function(plt_name, ...)  str_c('FACS_analysis/plots/', plt_name, ..., '.png')

#' Generate the full sample name from the wellname : A06 Well - A06 WLSM.fcs
#' @param wellname : should have format Axx, example A06
#' @return char : 'A06 Well - A06 WLSM.fcs'
expand_wellname <- function(wellname) str_c(wellname, ' Well - ', wellname, ' WLSM.fcs')


#' Arranges data in order for one fluorophore, and factorizes for easy visualization
#' @param .df : dataframe of .fcs summary data
#' @param .fluor_colour : pick which channel of the named fluor_channels vector you want the order based on. Default 'red'
#' @param .sorter_vars : the (typically) numeric value that is sorted on. Default 'mean_medians' which should be pre-calculated
#' @param meta_variables : a char vector of the variables that will be factorized
#' @param to_return : NULL or char - returns a rearranged tibble if NULL, and returns a list of levels if anything else

arrange_in_order_of_fluorophore  <- function(.df, .fluor_colour = 'red', .sorter_vars = 'mean_medians',
                                             meta_variables = metadata_variables,
                                             to_return = NULL) # to_return = 'order' returns a list of the levels
{ # usage
  # arrange_in_order_of_fluorophore(processed_flowcal) -> t1
  
  
  # TODO : change this to arrange in descending order and invert the levels later..
  
  # create a temporary array : filter out only the desired fluorescence
  temp_df <- 
    filter(.df, Fluorophore == fluor_chnls[[.fluor_colour]]) %>% # filter relevant fluorophores
    
    mutate(across(where(is.factor), fct_drop)) %>% # drop the levels that were filtered out of fluorophores
    
    arrange(across(any_of(.sorter_vars))) %>% # arrange by the provided variable - usually numeric 
    mutate(across(any_of(meta_variables), fct_inorder)) # freeze the order
  
  # get a list of the levels
  ordering_list <- 
    map(meta_variables, 
        ~ temp_df[[.x]] %>% levels) %>% 
    
    setNames(meta_variables) # name the elements
  
  
  if(!is.null(to_return)) {ordering_list
  } else # use the factor order from the temporary array and return the re-arranged and frozen order 
  
      {mutate(.df, across(any_of(meta_variables),
                          ~ fct_relevel(.x, # freeze the variables based on the above order
                                        ordering_list[[cur_column()]])
      )) %>%
          
          arrange(across(any_of(meta_variables))) # arrange the data similar to the above order
      }
  
  
}
