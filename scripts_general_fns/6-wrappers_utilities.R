# 6-wrappers_utilities.R
# miscellaneous functions 

# Convenience function for plotting directory and .png suffix for adhoc plots
plot_as <- function(plt_name, ...)  str_c('FACS_analysis/plots/', plt_name, ..., '.png')

#' Generate the full sample name from the wellname : A06 Well - A06 WLSM.fcs
#' @param wellname : should have format Axx, example A06
#' @return char : 'A06 Well - A06 WLSM.fcs'
expand_wellname <- function(wellname) str_c(wellname, ' Well - ', wellname, ' WLSM.fcs')


# General wrappers -----

#' Arranges data in order for one fluorophore, and factorizes for easy visualization
#' @param .df : dataframe of .fcs summary data
#' @param .fluor_colour : pick which channel of the named fluor_channels vector you want the order based on. Default 'red'
#' @param .sorter_vars : the (typically) numeric value that is sorted on. Default 'mean_medians' which should be pre-calculated
#' @param meta_variables : a char vector of the variables that will be factorized
#' @param to_return : NULL or char - returns a rearranged tibble if NULL, and returns a list of levels if anything else

arrange_in_order_of_fluorophore  <- function(.df, .fluor_colour = order_by_channel, .sorter_vars = 'mean_medians',
                                             meta_variables = metadata_variables,
                                             to_return = NULL) # to_return = 'order' returns a list of the levels
{ # usage
  # arrange_in_order_of_fluorophore(processed_flowcal) -> t1
  
  # TODO : change this to arrange in descending order and invert the levels later..
  
  # Error check for single colour data
  # check if the default colour is available and swap with the last colour
  if(!.fluor_colour %in% names(fluor_chnls)) .fluor_colour <- names(fluor_chnls) %>% tail(1)
  
  # create a temporary array : filter out only the desired fluorescence
  temp_df <- 
    filter(.df, Fluorophore == fluor_chnls[[.fluor_colour]]) %>% # filter relevant fluorophores
    
    mutate(across(where(is.factor), fct_drop)) %>% # drop the levels that were filtered out of fluorophores
    
    arrange(desc(across(any_of(.sorter_vars)))) %>% # arrange by the provided variable/ descending - usually numeric 
    mutate(across(any_of(meta_variables), fct_inorder)) # freeze the order or metadata variables
  
  # TODO : need to order descending: .sorter_vars ; then reverse the factor levels below :: levels() %>% rev()
  
  # get a list of the levels
  ordering_list <- 
    map(meta_variables, 
        ~ temp_df[[.x]] %>% levels %>% rev) %>% # reverse the levels to go in ascending order
    
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


#' Select the sampleName matching one or more regular expressions
#' @param : .flset = cytoset to retrieve well from
#' @param : .matcher = regex expression : preferably wellname etc. that is unique
get_matching_well <- function(.flset, .matcher)
{
  samples <- 
    sampleNames(.flset) %>% 
    .[str_detect(., .matcher)]
  
  if(length(samples) > 1) print('multiple matches found : ') else print('Selected well : ')
  print(samples)
  
  .flset[[samples]]
  # TODO : include ... to match multiple regexes ; still figuring out best way to do this
}


# Adhoc wrappers ----

# to be generalized in due time

#' Plot the density of the green fluorescent channel of a single well
#' @param .cytoset : give the subsetted cytoset (other single fcs data might also work)
#' @param plot_file_name : The name of the .png file to save as
#' @param save_folder : plot save folder inside 'FACS_analysis/plots/..' ; use NULL to not save. Default 'Archive/'


plot_single_density_green <- function(.cytoset,
                                      plot_file_name,
                                      save_folder = 'Archive/') # make save_folder NULL to not save
{
  
  plt <- 
    ggcyto(.cytoset, 
           aes(x = .data[[fluor_chnls[['green']]]] )#,  # plot 'YEL-HLog' for Guava bennett or Orange-G-A.. for Guava-SEA
           # subset = 'A'
    ) +
    geom_density(fill = 'green', alpha = 0.3) + 
    
    scale_x_logicle()
  
  # save plot if save_folder is specified
  if(!is.null(save_folder)) ggsave(plot_as(str_c(save_folder, plot_file_name)))
  
  return(plt)
}
