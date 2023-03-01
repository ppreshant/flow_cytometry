# 17-plot_ridges_fluor

#' wrapper for plotting ridgeline plots with some user controls
#' Optional showing of median lines and text of median values
#' Automatically detects ordering variable `list_of_ordered_levels`

plot_ridges_fluor <- function(.show_medians = TRUE, # shows median lines and text labels 
                              .facets_other_category = FALSE, .save_plots = TRUE)
{
  
  # plot dimensions ----
  # only for other_category stuff
  
  if(.facets_other_category)
  {# determine the fig width based on # of facets
  n_facets_plt = pull(fcsunique.subset, other_category) %>% unique() %>% length()
  }
  
  
  plt_ridges <- 
    map(fluor_chnls, # run the below function for each colour of fluorescence
        
        ~ ggcyto(fl.subset, # select subset of samples to plot
                 aes(x = .data[[.x]], 
                     fill = sample_category) #,  
                 # plot 'YEL-HLog' for Guava bennett or Orange-G-A.. for Guava-SEA
                 # subset = 'A'
        ) +
          
          # conditional plotting of ridges : if ordering exists or not
          {if (exists('list_of_ordered_levels')) {
            ggridges::geom_density_ridges(aes
                                          (y = fct_relevel(assay_variable, 
                                                           list_of_ordered_levels[['assay_variable']])), 
                                          alpha = 0.3,
                                          
                                          
                                          # adding mean/median lines
                                          # source: https://datavizpyr.com/add-mean-line-to-ridgeline-plot-in-r-with-ggridges/
                                          
                                          quantile_lines = .show_medians, # to show median
                                          quantiles = 2 # check if works when quantile_lines is F
                                          # quantile_fun = function(x, ...) median(x) # make a function to calculate median
            )
            
          } else ggridges::geom_density_ridges(aes(y = assay_variable), alpha = 0.3) } + # TODO : put quantile lines here
          
          
          # Add facets for other_category or remove default facets (default = each sample in a facet)
          {if(.facets_other_category) {
            facet_wrap(facets = vars(other_category), ncol = n_facets_plt, # control facets
                       scales = 'free_y') 
          } else facet_wrap(facets = NULL)} + # control facets
          
          
          scale_x_logicle() +  # some bi-axial transformation for FACS (linear near 0, logscale at higher values)
          # scale_x_flowjo_biexp() + # temporary instead of logicle scale (similar principle)  # scale_x_flowjo_biexp() + # temporary instead of logicle scale
          # scale_x_log10() + # simple logarithmic scale (backup for logicle)
          
          # Labels of the median line
          {if (exists('fcsunique.subset') & .show_medians) { # only if the labelling subset data exists
            geom_text(data = filter(fcsunique.subset, Fluorophore == .x),
                      mapping = aes(x = mean_medians, y = assay_variable,
                                    label = round(mean_medians, 0)),
                      nudge_y = -0.1) } } + 
          # median text is imperfect : showing the mean of the medians of 3 replicates. Refer to link for better alternative
          # https://stackoverflow.com/questions/52527229/draw-line-on-geom-density-ridges
          
          theme(legend.position = 'top') +
          ggtitle(title_name) + ylab('Sample name')
    )
  
  # CAVEAT : The median values shown on the chart are slightly different from the lines 
  # Text: (mean of median/replicate) ; lines :  (median/combined distribution?)
  # TODO : generalize to plot all fluorophores on different charts? 
  # TODO : put the subsetting + ridge plots into a two functions for easily calling adhoc
  
  # plotting limited axis ranges
  # plt_trunc_ridges <- plt_ridges + ggcyto_par_set(limits = list(x = c(10, 3e5))) # arbitrary axis limits for log10 scale
  
  # save plots
  
  if(.save_plots){ # save plots unless user input prevents this
    
    if(.facets_other_category) { # saving plots if faceted by other_category
      map(names(fluor_chnls), # iterate over fluorescence channels
          
          ~ ggsave(str_c('FACS_analysis/plots/', 
                         title_name,  # title_name, 
                         '-', .x, 
                         '.png'),
                   plot = plt_ridges[[.x]], # plt_ridges
                   height = est_plt_side/n_facets_plt, width = 3 * n_facets_plt) # use automatic estimate for plt sides : 2 / panel
      )
      
      
    } else { # saving plots if not faceted : width, height and naming is different 
      
      map(names(fluor_chnls), # iterate over fluorescence channels
          
          ~ ggsave(str_c('FACS_analysis/plots/', 
                         title_name,  # title_name, 
                         '-ridge density', fl_suffix, '-', .x, 
                         '.png'),
                   plot = plt_ridges[[.x]], # plt_ridges
                   height = est_plt_side, width = 5) # use automatic estimate for plt sides : 2 / panel
      ) }
    # TODO : convert into a function? call for specific colour..
  }
  
  
}