# 19-plot_dose_response_and_controls.R

# Copied from plate reader repo : 18-April-23

# dose_response + controls plotter ----

# dose_response plot / flipped
plot_dose_response_and_controls <- function(.data = counts_gated, # use ratio_data for fractions
                                            .target_to_filter = 'flipped', # ignore if plotting other datasets
                                            .yvar = freq, # 40 - CT or flipped_fraction
                                            .xvar_dose = Arabinose, .xlabel = 'Arabinose (uM)',
                                            .xvar_control = assay_variable) # assay_variable/qPCR, flowcyt ; Samples/plate reader
  
{
  
  # data subset ----
  data_subset <- ungroup(.data) %>% 
    filter({{.xvar_control}} != 'water', # remove water samples
           if_any(any_of('Target_name'), ~ .x == .target_to_filter)) # filter if column is present..!
  
  
  # y-axis limits ----
  yrange <- reframe(data_subset, range({{.yvar}}, na.rm = T))
  ymin <- floor(yrange[[1,1]])
  ymax <- ceiling(yrange[[2,1]])
  
  # TODO : remove ceiling with user input?
  
  # dose response ----
  ara_plt <- 
    {ggplot(filter(data_subset, sample_type == 'Induction'),
            
            aes({{.xvar_dose}}, {{.yvar}}, label = replicate, 
                label2 = well)) + # for interactive troubleshooting
        
        geom_point() + 
        
        geom_line(aes(group = replicate), alpha = 0.2) +
        
        theme(legend.position = 'top') + 
        
        ylim(c(ymin, ymax)) + # set consistant yaxis ranges
        # labels and titles
        xlab(.xlabel) + 
        ggtitle(dose_response_title, subtitle = title_name)
      
    } %>% 
    
    format_logscale_x() # format_logscale_y()
  
  
  # controls -----
  control_plt <- 
    ggplot(filter(data_subset, sample_type == 'Controls'),
           
           aes({{.xvar_control}}, {{.yvar}}, label = replicate, 
               label2 = well)) + # for interactive troubleshooting
    
    ylim(c(ymin, ymax)) + # set consistant yaxis ranges
    geom_point(position = position_jitter(width = 0.2, height = 0)) + 
    ylab(NULL) + xlab('Controls')
  
  
  # merge plots -----
  library(patchwork)
  
  # attach panels [dose response x 4 + controls x 1 widths]
  combine_plt <-
  ara_plt + control_plt + 
    plot_layout(widths = c(4, 1))
  
  # return two plots
  list(combine_plt, ara_plt)
  
}