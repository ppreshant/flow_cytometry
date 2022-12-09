# 7-exploratory_data_view.R

# Open multiple .fcs in directory as flowset and plot density and dot plots (takes long time)
# Each dataset will appear in a separate panel --


# Subset data ----

# Make a subset of data to plot :: Remove PBS controls, beads etc. 
# Using this for plotting in nice a orientation mimicking the plate wells if possible

samples_in_fl <- sampleNames(fl.set) # get all the sample names

# remove samples matching the regular expression :: Example row D : 'D[:digit:]+'
# samples_to_include <- samples_in_fl[str_detect(samples_in_fl, '.*')] # use: .* to keep everything  

# Metada based sample filtering : to plot a subset 
samples_to_include <- 
  pData(fl.set) %>% 
  filter(!str_detect(name, 'NA|Beads|beads|PBS'), # remove samples without metadata or beads/pbs
         str_detect(well, '.*')) %>% # select with regex for wells : Example row D : 'D[:digit:]+'
  rownames() # take the sample names to be plotted

fl.subset <- fl.set[samples_to_include] # filter out wells by regex

# for selecting a single sample
# fl.subset <- fl.set[expand_wellname('A06')] # get a single sample

# Reorder samples by factors
# fl.set

# Exploratory plotting ----

# estimate dimensions to save the plot in
# num_of_facets <- pltden_red$facet$params %>% length() # find the number of panels after making pltden_red
num_of_unique_samples <- new_pdata$name %>% unique() %>% length()
est_plt_side <- sqrt(num_of_unique_samples) %>% round() %>% {. * 2.5} # make 2.5 cm/panel on each side (assuming square shape)


# overview plots : take a long time to show 

# Plot density of all samples in the set - red channel
pltden_red <- ggcyto(fl.subset, # select subset of samples to plot
                 aes_string(x = as.name(fluor_chnls[['red']]), 
                            fill = 'sample_category')#,  # plot 'YEL-HLog' for Guava bennett or Orange-G-A.. for Guava-SEA
                 # subset = 'A'
                 ) +
  
  geom_density(fill = 'red', alpha = 0.3) +
  # geom_stats() + # only works after geom_gate
  
  scale_x_logicle() +  # some bi-axial transformation for FACS (linear near 0, logscale at higher values)
  ggtitle(title_name)


# save plot
ggsave(str_c('FACS_analysis/plots/', 
             title_name,  # title_name, 
             '-density', fl_suffix, 
             '.png'),
       plot = pltden_red,
       # height = 8, width = 8) # change height and width by number of panels
       height = est_plt_side, width = est_plt_side) # use automatic estimate for plt sides : 2 / panel


# Ridgeline plot
# Plot is ordered in descending order of fliorescence 

plt_ridges <- ggcyto(fl.subset, # select subset of samples to plot
                       aes_string(x = as.name(fluor_chnls[['red']]), 
                                  fill = 'sample_category')#,  
                     # plot 'YEL-HLog' for Guava bennett or Orange-G-A.. for Guava-SEA
                       # subset = 'A'
                       ) +
  
  # conditional plotting of ridges : if ordering exists or not
  {if (exists('list_of_ordered_levels')) {
    ggridges::geom_density_ridges(aes
                             (y = fct_relevel(assay_variable, 
                                              list_of_ordered_levels[['assay_variable']])), 
                             alpha = 0.3
                             
                             
                             # adding mean/meadian -- doesn't work. Error:  Computation failed in `stat_density_ridges()`:
                                                                    # unused argument (probs = probs) 
                             # source: https://datavizpyr.com/add-mean-line-to-ridgeline-plot-in-r-with-ggridges/
                             
                             # quantile_lines = TRUE, # to show median
                             # quantile_fun = function(x) mean(x) # make a function to calculate median
    )
    
  } else ggridges::geom_density_ridges(aes(y = assay_variable), alpha = 0.3) } +
  
  facet_wrap(facets = NULL) + # control facets
  # scale_x_logicle() +  # some bi-axial transformation for FACS (linear near 0, logscale at higher values)
  scale_x_log10() + 
  
  theme(legend.position = 'top') +
  ggtitle(title_name) + ylab('Sample name')

# TODO : add median values on the chart? Fix error
# TODO : generalize to plot all fluorophores on different charts? 

# save plot
ggsave(str_c('FACS_analysis/plots/', 
             title_name,  # title_name, 
             '-ridge density', fl_suffix, 
             '.png'),
       plot = plt_ridges,
       height = est_plt_side, width = 5) # use automatic estimate for plt sides : 2 / panel



# plot scatterplots of all samples in the set

pltscatter_fluor <- ggcyto(fl.subset, # select subset of samples to plot
                     aes_string(x = as.name(fluor_chnls[['red']]), 
                                y = as.name(fluor_chnls[['green']]) )) +  # fluorescence channels

  # geom_point(alpha = 0.1) +
  geom_hex(bins = 64) + # make hexagonal bins with colour : increase bins for higher resolution. Strating at 64
  # scale_x_logicle() + scale_y_logicle() +
  # logicle = some bi-axial transformation for FACS (linear near 0, logscale at higher values)
  
  scale_x_flowjo_biexp() + scale_y_log10() + # temporary use
  
  ggcyto_par_set(limits = list(x = c(-100, 1e4), y = c(-100, 1e4))) +
  
  # visual changes
  # scale_fill_gradientn(colours = ?) + # to change the default colour scheme which is "spectral"
  # scale_fill_viridis_c(direction = -1) + # colourscale viridis
  
  # facet_wrap('name', ncol = 10, scales = 'free') + # control facets for full panel
  ggtitle(title_name) + 
  
  theme_gray()


ggsave(str_c('FACS_analysis/plots/', 
             title_name,  # title_name, 
             '-fluor', fl_suffix,
             '.png'),
       plot = pltscatter_fluor,
       # height = 8, width = 20) # change height and width by number of panels
       height = est_plt_side, width = est_plt_side) # use automatic estimate for plt sides : 2 / panel

# error possible ; logicle scale did not converge. Known issue from Nov 2022 ggplot update
# https://github.com/RGLab/ggcyto/issues/88


# plot fwd-side scatterplots of all samples in the set
plt_scatter <- ggcyto(fl.subset, # select subset of samples to plot
                           aes_string(x = as.name(scatter_chnls[['fwd']]), 
                                      y = as.name(scatter_chnls[['side']]) )) +  # fluorescence channels
  
  # geom_point(alpha = 0.1) +
  geom_hex(bins = 64) + # make hexagonal bins with colour : increase bins for higher resolution
  scale_x_logicle() + scale_y_logicle() +
  # logicle = some bi-axial transformation for FACS (linear near 0, logscale at higher values)
  ggcyto_par_set(limits = list(x = c(-100, 1e4), y = c(-100, 1e4))) + # maybe won't work for Guava?
  
  # visual changes
  # scale_fill_gradientn(colours = ?) + # to change the default colour scheme which is "spectral"
  # scale_fill_viridis_c(direction = -1) + # colourscale viridis
  
  # facet_wrap('name', ncol = 10, scales = 'free') + # control facets for full panel
  ggtitle(title_name) + 
  
  theme_gray()


ggsave(str_c('FACS_analysis/plots/', 
             title_name,  # title_name, 
             '-scatter', fl_suffix, 
             '.png'),
       plot = plt_scatter,
       # height = 8, width = 20) # change height and width by number of panels
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

single_fcs <- fl.set[[3]] # choose a single file to test things on

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


# fluorescence plot of single sample -- troubleshooting
plt_fluor_single <- 
  {ggcyto(single_fcs, aes_string(x = as.name(fluor_chnls[['red']]), y = as.name(fluor_chnls[['green']]))) + 
      geom_hex(bins = 120) + 
      geom_density2d(colour = 'black') + 
      
      scale_x_logicle() + scale_y_logicle() + 
      theme_gray()} %>% 
  
  print()

# FSC-SSC plot of single sample
plt_sctr_single <- 
  {ggcyto(single_fcs, aes_string(x = as.name(scatter_chnls[['fwd']]), 
                                y = as.name(scatter_chnls[['side']]))) + 
      geom_hex(bins = 120) + 
      geom_density2d(colour = 'black') + 
      
      scale_x_logicle() + scale_y_logicle()} %>% 
  
  print()


# custom save plot
# ggsave(str_c('FACS_analysis/plots/', 
#              'S045b',  # title_name, 
#              '-two populations-A5', 
#              '.png'),
#        plot = plt_scatter_single,
#        height = 5, width = 5)




# fluor vs Scatter
plt_red_scatter <- {ggcyto(single_fcs, aes_string(x = as.name(fluor_chnls[['red']]), y = 'SSC-A')) + 
  geom_hex(bins = 120) + 
  geom_density2d(colour = 'black') + 
  
  scale_x_logicle()} %>% print()

plt_green_scatter <- {ggcyto(single_fcs, aes_string(x = as.name(fluor_chnls[['green']]), y = 'SSC-A')) + 
  geom_hex(bins = 120) + 
  geom_density2d(colour = 'black') + 
  
  scale_x_logicle()} %>% print()


# Density
ggcyto(single_fcs, 
       aes_string(x = as.name(fluor_chnls[['red']]) )#,  # plot 'YEL-HLog' for Guava bennett or Orange-G-A.. for Guava-SEA
       # subset = 'A'
) +
  geom_density(fill = 'red', alpha = 0.3) + 
  
  scale_x_logicle()
