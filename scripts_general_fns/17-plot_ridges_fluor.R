# 17-plot_ridges_fluor

#' wrapper for plotting ridgeline plots with some user controls
#' Optional showing of median lines and text of median values
#' Automatically detects ordering variable `list_of_ordered_levels`
#' @param .show_medians Use this to show medians and annotate their value (when figure is not crowded)
#' @param .facets_other_category Use when there is a user generated `other_category` to facet by.
#' @param .save_plots Make `TRUE` to save the plot(s) for each fluorophore.
#' @param .clip_fraction Clips away density when it is < this fraction of the max height : to avoid showing long tails.
#' @param .show_jittered_points Shows points below the distribution. Use for gated data to highlight lower density of points.
#' @param .cytoset T data to plot. Defaults to `fl.subset`.
 
plot_ridges_fluor <- function(.show_medians = TRUE, # shows median lines and text labels 
                              .facets_other_category = FALSE, .save_plots = TRUE,
                              
                              .clip_fraction = 0.001,
                              .show_jittered_points = FALSE,
                              
                              .cytoset = fl.subset)
{
  
  # yaxis variable ----
  # variable name to plot on y axis. Typically assay_variable. Use "data_set" for combined data
  .yvar <- if(combined_data) expr(data_set) else expr(assay_variable)
  
  # plot dimensions ----
  # only for other_category stuff
  
  if(.facets_other_category)
  {# determine the fig width based on # of facets
  n_facets_plt = pull(fcsunique.subset, other_category) %>% unique() %>% length()
  plt_height = est_plt_side/n_facets_plt
  
  } else if(combined_data) {
    n_facets_plt = pull(fcsunique.subset, assay_variable) %>% unique %>% length
    plt_height = pull(fcsunique.subset, data_set) %>% unique %>% length * 1.2
    
  }
  
  
  plt_ridges <- 
    map(fluor_chnls, # run the below function for each colour of fluorescence
        
        ~ ggcyto(.cytoset, # select subset of samples to plot
                 aes(x = .data[[.x]], 
                     fill = sample_category) #,  
                 # plot 'YEL-HLog' for Guava bennett or Orange-G-A.. for Guava-SEA
                 # subset = 'A'
        ) +
          
          # conditional plotting of ridges : if ordering exists or not
          ggridges::geom_density_ridges(
            aes(
              
              y = if(exists('list_of_ordered_levels') && !combined_data) 
                
              {fct_relevel(assay_variable, 
                           list_of_ordered_levels[['assay_variable']]) 
                
              } else {{.yvar}}), 
            
            alpha = 0.3,
            
            # clip off density below cutoff
            rel_min_height = .clip_fraction, 
            
            # adding mean/median lines
            # source: https://datavizpyr.com/add-mean-line-to-ridgeline-plot-in-r-with-ggridges/
            
            quantile_lines = .show_medians, # to show median
            quantiles = 2, # check if works when quantile_lines is F
            # quantile_fun = function(x, ...) median(x) # make a function to calculate median
            
            # optional : jittered points below the distribution
            jittered_points = .show_jittered_points,
            position = ggridges::position_points_jitter(width = 0.05, height = 0), # only applicable if points shown
            point_shape = '|', point_size = 1, point_alpha = 0.2 # only applicable if points are shown
            
          ) +
          
          
          # Add facets for other_category or remove default facets (default = each sample in a facet)
          {if(.facets_other_category) { # facets for other category
            facet_wrap(facets = vars(other_category), ncol = n_facets_plt, # control facets
                       scales = 'free_y') 
            
          } else if(combined_data) { # facets for assay_variable
            facet_wrap(facets = vars(assay_variable), ncol = n_facets_plt, # control facets
                       scales = 'free_y')
            
          }  else facet_wrap(facets = NULL)} + # No facets
          
          
          scale_x_logicle() +  # some bi-axial transformation for FACS (linear near 0, logscale at higher values)
          # scale_x_flowjo_biexp() + # temporary instead of logicle scale (similar principle)  # scale_x_flowjo_biexp() + # temporary instead of logicle scale
          # scale_x_log10() + # simple logarithmic scale (backup for logicle)
          
          
          # Labels of the median line
          {if (exists('fcsunique.subset') & .show_medians) { # only if the labelling subset data exists
            geom_text(data = filter(fcsunique.subset, Fluorophore == .x),
                      mapping = aes(x = mean_medians, y = {{.yvar}},
                                    label = round(mean_medians, 0)),
                      nudge_y = -0.1) } } + 
          # median text is imperfect : showing the mean of the medians of 3 replicates. Refer to link for better alternative
          # https://stackoverflow.com/questions/52527229/draw-line-on-geom-density-ridges
          
          
          # gridline y
          theme(panel.grid.major.x = element_line(colour = 'gray60', linewidth = .1)) + 
          
          theme(legend.position = 'top') +
          ggtitle(title_name) + ylab('Sample name')
    )
  
  # CAVEAT : The median values shown on the chart are slightly different from the lines 
  # Text: (mean of median/replicate) ; lines :  (median/combined distribution?)
  # TODO : generalize to plot all fluorophores on different charts? 
  
  # plotting limited axis ranges
  # plt_trunc_ridges <- plt_ridges + ggcyto_par_set(limits = list(x = c(10, 3e5))) # arbitrary axis limits for log10 scale
  
  # save plots
  
  if(.save_plots){ # save plots unless user input prevents this
    
    if(.facets_other_category | combined_data) { # saving plots if faceted by other_category/data_set
      map(names(fluor_chnls), # iterate over fluorescence channels
          
          ~ ggsave(str_c('FACS_analysis/plots/', 
                         title_name,  # title_name, 
                         '-', .x, 
                         '.png'),
                   plot = plt_ridges[[.x]], # plt_ridges
                   height = plt_height, width = 3 * n_facets_plt) # use automatic estimate for plt sides : 2 / panel
      )
      
      
    } else { # saving plots if not faceted : width, height and naming is different 
      
      map(names(fluor_chnls), # iterate over fluorescence channels
          
          ~ ggsave(str_c('FACS_analysis/plots/', 
                         title_name,  # title_name, 
                         '-', .x, 
                         '.png'),
                   plot = plt_ridges[[.x]], # plt_ridges
                   height = est_plt_side, width = 5) # use automatic estimate for plt sides : 2 / panel
      ) }
    # TODO : convert into a function? call for specific colour..
  }
  
  return(plt_ridges)
  
  
}