# 22-fitting_functions.R

# copied over from qPCR for same task (simple lm fit for exponential)


# Exponential fitting ----

#' Access fitting parameters, calculate t half and attach augmented data for plotting
#' Fitting simpler expoonential with lm for robust fits - no singular gradients!
#' formula used : ~ lm(log(flipped_fraction) ~ day, data = .x)
#' @param .df dataframe with list column `.fit` that has the lm fit (typically nested)
get_t_half_from_lm_exp_fits <- function(.df)
  
{
  .df %>% 
    
    mutate( # extract parameters from fit, attach to data
      tidied = map(.fit, ~ broom::tidy(.x)), # extracting fitting parameters
      augmented = map(.fit, ~ broom::augment(.x)), # extrapolating fitting data, for plotting
      
    ) %>% 
    
    # unnest the model parameters
    unnest(tidied) %>% 
    
    # arrange the parameter estimate, std. error and other stuff for each paramameter in each column
    pivot_wider(names_from = term,
                values_from = c(estimate, std.error, statistic, p.value)) %>% 
    
    # produce t1/2 estimates
    mutate(t.half = -log(2)/ estimate_day, 
           std.error_t.half = -t.half / estimate_day * std.error_day, # error propagation
           
           t.half.text = str_c( format(t.half, digits = 2), 
                                '+/-', 
                                format(std.error_t.half, digits = 2),
                                sep = ' ')
    ) # using error propagation - https://en.wikipedia.org/wiki/Propagation_of_uncertainty#Example
  
}