# 7-exploratory_data_view.R

# Open multiple .fcs in directory as flowset and plot fluorescence density and dot plots (takes long time)
# Each dataset will appear in a separate panel for exploratory overview --
# Ridge plots will put data close to each other for easier comparisions


# Load data by running analyze_fcs atleast till line 37 (sample_metadata <- ..)
  # Run till the end : line 137 for ordering the ridge plot (list_of_ordered_levels <- ..)
# source('./analyze_fcs.R')


# Subset data ----

# Metada based sample filtering : to plot a subset of wells
non_data_stuff <- 'NA|Beads|beads|PBS' # NA removes samples not defined in the template
specific_data <- '.*' # use '.*' for everything ; use '51|MG1655' for specific data
exclude_category <- 'none' # use 'none' for selecting everything : experiment/data specific

# subset the fl.set according to above variables and return a unique metadata + mean_median data
source('scripts_general_fns/16-subset_cytoset.R') # source the script

fcsunique.subset <- subset_cytoset(non_data_stuff, specific_data, exclude_category, # use for labeling ridges' medians
                                   # optional manual filtering (additional to above)
                                   # str_detect(assay_variable, 'wt') | str_detect(data_set, 'd1') 
 )

# Side effect : creates a global variable fl.subset


# Exploratory plotting ----

# estimate dimensions to save the plot in (for automated workflow)
# num_of_facets <- pltden_red$facet$params %>% length() # find the number of panels after making pltden_red
num_of_unique_samples <- pData(fl.subset) %>% pull(full_sample_name) %>% unique() %>% length()
est_plt_side <- sqrt(num_of_unique_samples) %>% round() %>% {. * 2.5} # make 2.5 cm/panel on each side (assuming square shape)

# overview plots : take a long time to show - so save them and open the png to visualize

# Ridgeline plot
# Plot is ordered in descending order of fluorescence if `list_of_ordered_levels` provided

# Ridgeline plots ----

source('scripts_general_fns/17-plot_ridges_fluor.R') # source script
plt_ridges <- plot_ridges_fluor(.show_medians = show_medians) # make plots and optionally save them with title_name + suffixes

# TODO : change est_plt_side for ridge plots to include the max number of samples within the sample groups (and not total)
# context : ridge plot width seems to change with number of sample_categories ; set to constant width = 5 


# Other analysis ; run manually when required ; turned off when calling the whole script 
if(0)
{
  
  # scatter FSC-SSC ----
  
  # plot fwd-side scatterplots of all samples in the set
  plt_scatter <- plot_scatter(title_name, '-scatter')
  
  # dotplot is very very slow. will take 10 m to plot 
  # plt_dots <- plot_scatter(title_name, '-dotplot', .plot_mode = 'dotplot')
  
  
  # Scatter fluor 2 colours ----
  
  # plot scatterplots of fluorescences -- fails if only a single fluorophore is present
  plt_fluor2d <- plot_scatter(title_name, '-fluor2d', .x = fluor_chnls[['red']], .y = fluor_chnls[['green']])
  
  
  # density 1d plots ----
  
  # Older plots for density
  
  # Plot density of all samples in the set - red channel
  pltden_red <- ggcyto(fl.subset, # select subset of samples to plot
                       aes(x = .data[[fluor_chnls[['red']]]],
                           fill = 'sample_category')#,  # plot 'YEL-HLog' for Guava bennett or Orange-G-A.. for Guava-SEA
                       # subset = 'A'
  ) +
    
    geom_density(fill = 'red', alpha = 0.3) +
    # geom_stats() + # only works after geom_gate
    
    # scale_x_logicle() +  # some bi-axial transformation for FACS (linear near 0, logscale at higher values)
    scale_x_log10() +
    ggtitle(title_name)
  
  
  # save plot
  ggsave(str_c('FACS_analysis/plots/', 
               title_name,  # title_name, 
               '-density', fl_suffix, 
               '.png'),
         plot = pltden_red,
         # height = 8, width = 8) # change height and width by number of panels
         height = est_plt_side, width = est_plt_side) # use automatic estimate for plt sides : 2 / panel
  
  
  
  
  
  # # testing simple plotting : is not as customizable
  # # ggcyto::autoplot(fl.set, 'FSC-HLin')
  # 
  # # Plot to html file using R markdown
  # rmarkdown::render('exploratory_plots.rmd', output_file = str_c('./FACS_analysis/', title_name, '.html'))
  
  
  
  
  
  # Gating practice ----
  # ignore this section
  # Run manually the script 11-manual_gating_workflow.R in the scripts_archive folder, which has the tested functions
  
  
  # practice gating on cytoframe
  
  # single_fcs <- fl.set[[3]] # choose a single file to test things on
  single_fcs <- fl.set[expand_wellname('B02')] # select single file based on wellname
  
  # set gate
  gate_quad <- openCyto:::.quadGate.tmix(single_fcs, channels = fluor_chnls, K = 3, usePrior = "no")
  # takes ~ 10 s time
  
  plt_fl_single <- autoplot(single_fcs, fluor_chnls[1], fluor_chnls[2]) + 
    geom_density2d(colour = 'black') + 
    
    scale_x_logicle() + scale_y_logicle()
  
  # view gate
  plt_fl_single + geom_gate(gate_quad) + geom_stats()
  
  # Gating stats
  
  
  
  # Single plots ----
  
  # set single_fcs if not set before gating
  single_fcs <- get_matching_well(fl.set, 'A02') # select single file based on sampleName match
  
  
  # FSC-SSC plot of single sample
  plt_sctr_single <- plot_scatter(.cytoset = single_fcs) %>% print
  
  # fluorescence plot of single sample -- troubleshooting
  plt_fluor2d_single <- plot_scatter(.cytoset = single_fcs, .x = fluor_chnls[['red']], .y = fluor_chnls[['green']]) %>% print
  
  
  # singlet plot : FSC-H vs -A
  singlet_FSC_single <- {plot_scatter(.cytoset = single_fcs, 
                                   .x = scatter_chnls[['fwd']], .y = 'FSC-H')} %>% print
    
  
  # red-SSC scatter plot ; checking bimodality
  plt_redssc_single_points <- 
    {ggcyto(single_fcs, aes(x = .data[[fluor_chnls[['red']]]],
                            y = .data[[scatter_chnls[['side']]]])) + 
        geom_point(alpha = 0.05, size = .1) + 
        # geom_hex(bins = 120) + 
        geom_density2d(colour = 'black') + 
        
        scale_x_logicle() + scale_y_logicle()} %>% 
    print
  
  # custom save plot
  # ggsave(str_c('FACS_analysis/plots/', 
  #              'S045b',  # title_name, 
  #              '-two populations-A5', 
  #              '.png'),
  #        plot = plt_scatter_single,
  #        height = 5, width = 5)
  
  
  
  
  # fluor vs Scatter
  green_fsc_single <- {plot_scatter(.cytoset = single_fcs, 
                                   .x = scatter_chnls[['fwd']], .y = fluor_chnls[['green']])} %>% print
  
  ssc_green_single <- {plot_scatter(.cytoset = single_fcs, 
                                    .x = fluor_chnls[['green']], .y = scatter_chnls[['side']])} %>% print
  
  
  plt_red_scatter <- {ggcyto(single_fcs, aes(x = .data[[fluor_chnls[['red']]]], y = `SSC-A`)) + 
      geom_hex(bins = 120) + 
      geom_density2d(colour = 'black') + 
      
      scale_x_logicle()} %>% print()
  
  
  
  # Density
  
  # Fluorescence density
  ggcyto(single_fcs, 
         aes(x = .data[[fluor_chnls[['green']]]] )#,  # plot 'YEL-HLog' for Guava bennett or Orange-G-A.. for Guava-SEA
         # subset = 'A'
  ) +
    geom_density(fill = 'green', alpha = 0.3) + 
    
    scale_x_logicle()
  
  # TODO : make a neat function wrapper to do this --
  
  
  # FSC density
  ggcyto(single_fcs, 
         aes(x = .data[[scatter_chnls[['fwd']]]] )) +
    geom_density(fill = 'gray', alpha = 0.3) + 
    
    scale_x_logicle()
  
  
  # Complex plots ----
  
  
  # scatter FSC vs SSC plot coloured by fluorescence
  plt_sctr_with_fluor <- 
    {ggplot(single_fcs, aes(x = .data[[scatter_chnls[['fwd']]]],
                            y = .data[[scatter_chnls[['side']]]],
                            z = .data[[fluor_chnls[['green']]]])) + 
        stat_summary_hex(bins = 120, fun = 'median') + 
        geom_density2d(colour = 'black') + 
        
        scale_x_logicle() + scale_y_logicle()} %>% 
    
    print()
  # not plotting ; ggcyto fails by not finding z variable
  
  
  # scatter and fluor correlation arrangement (since the above colour method failed)
  library(patchwork)
  
  (ssc_green_single + plt_sctr_single) / (singlet_FSC_single + green_fsc_single) # align the fluor vs fsc and ssc (plot_spacer())
  
  # optional save
  ggsave(plot_as(title_name, 'A02-tr'), width = 8, height = 4)
  
}
