# 7-exploratory_data_view.R

# Open multiple .fcs in directory as flowset and plot fluorescence density and dot plots (takes long time)
# Each dataset will appear in a separate panel for exploratory overview --
# Ridge plots will put data close to each other for easier comparisions


# Load data by running analyze_fcs atleast till line 37 (sample_metadata <- ..)
  # Run till the end : line 137 for ordering the ridge plot (list_of_ordered_levels <- ..)
source('./analyze_fcs.R')


# Subset data ----

# Metada based sample filtering : to plot a subset of wells
non_data_stuff <- 'NA|Beads|beads|PBS'
specific_data <- '.*' # use '.*' for everything ; use '51|MG1655' for specific data
exclude_category <- 'none' # use 'none' for everything : experiment/data specific

# subset the fl.set according to above variables and return a unique metadata + mean_median data
source('scripts_general_fns/16-subset_cytoset.R') # source the script
fcsunique.subset <- subset_cytoset(non_data_stuff, specific_data, exclude_category) # use for labeling ridges' medians
# Side effect : creates a global variable fl.subset


# Exploratory plotting ----

# estimate dimensions to save the plot in (for automated workflow)
# num_of_facets <- pltden_red$facet$params %>% length() # find the number of panels after making pltden_red
num_of_unique_samples <- pData(fl.subset) %>% pull(name) %>% unique() %>% length()
est_plt_side <- sqrt(num_of_unique_samples) %>% round() %>% {. * 2.5} # make 2.5 cm/panel on each side (assuming square shape)

# overview plots : take a long time to show - so save them and open the png to visualize

# Ridgeline plot
# Plot is ordered in descending order of fluorescence if `list_of_ordered_levels` provided

# Ridgeline plots ----

source('scripts_general_fns/17-plot_ridges_fluor.R') # source script
plt_ridges <- plot_ridges_fluor() # make plots and optionally save them with title_name + suffixes


# plot scatterplots of fluorescences -- fails if only a single fluorophore is present

pltscatter_fluor <- ggcyto(fl.subset, # select subset of samples to plot
                     aes(x = .data[[fluor_chnls[['red']]]], 
                         y = .data[[fluor_chnls[['green']]]] )) +  # fluorescence channels

  # geom_point(alpha = 0.1) +
  geom_hex(bins = 64) + # make hexagonal bins with colour : increase bins for higher resolution. Strating at 64
  scale_x_logicle() + scale_y_logicle() + # hidden until some ggplot error is fixed
  # logicle = some bi-axial transformation for FACS (linear near 0, logscale at higher values)
  
  # scale_x_flowjo_biexp() + scale_y_log10() + # temporary use
  
  # ggcyto_par_set(limits = list(x = c(-100, 1e4), y = c(-100, 1e4))) +
  
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


# scatter FSC-SSC ----

# plot fwd-side scatterplots of all samples in the set
plt_scatter <- ggcyto(fl.subset, # select subset of samples to plot
                           aes(x = .data[[scatter_chnls[['fwd']]]], 
                               y = .data[[scatter_chnls[['side']]]] )) +  # fluorescence channels
  
  # geom_point(alpha = 0.1) +
  geom_hex(bins = 64) + # make hexagonal bins with colour : increase bins for higher resolution
  scale_x_logicle() + scale_y_logicle() +
  # logicle = some bi-axial transformation for FACS (linear near 0, logscale at higher values)
  # ggcyto_par_set(limits = list(x = c(-100, 1e4), y = c(-100, 1e4))) + # maybe won't work for Guava?
  
  # visual changes
  # scale_fill_gradientn(colours = ?) + # to change the default colour scheme which is "spectral"
  # scale_fill_viridis_c(direction = -1) + # colourscale viridis
  
  # facet_wrap('name', ncol = 10, scales = 'free') + # control facets for full panel
  ggtitle(title_name) + 
  
  theme_gray()

# TODO : Need some relative scale for each panel -- it is hard to see here. Maybe good for catching low events?

ggsave(str_c('FACS_analysis/plots/', 
             title_name,  # title_name, 
             '-scatter', fl_suffix, 
             '.png'),
       plot = plt_scatter,
       # height = 8, width = 20) # change height and width by number of panels
       height = est_plt_side, width = est_plt_side) # use automatic estimate for plt sides : 2 / panel


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
single_fcs <- fl.set[expand_wellname('G05')] # select single file based on wellname

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
# single_fcs <- fl.set[expand_wellname('G05')] # select single file based on wellname

# fluorescence plot of single sample -- troubleshooting
plt_fluor_single <- 
  {ggcyto(single_fcs, aes(x = .data[[fluor_chnls[['red']]]], y = .data[[fluor_chnls[['green']]]])) + 
      geom_hex(bins = 120) + 
      geom_density2d(colour = 'black') + 
      
      scale_x_logicle() + scale_y_logicle() + 
      theme_gray()} %>% 
  
  print()

# FSC-SSC plot of single sample
plt_sctr_single <- 
  {ggcyto(single_fcs, aes(x = .data[[scatter_chnls[['fwd']]]],
                          y = .data[[scatter_chnls[['side']]]])) + 
      geom_hex(bins = 120) + 
      geom_density2d(colour = 'black') + 
      
      scale_x_logicle() + scale_y_logicle()} %>% 
  
  print()

# singlet plot : FSC-H vs -A
plt_singlet_FSC <- 
  {ggcyto(single_fcs, aes(x = .data[[scatter_chnls[['fwd']]]],
                          y = 'FSC-H')) + 
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
plt_red_scatter <- {ggcyto(single_fcs, aes(x = .data[[fluor_chnls[['red']]]], y = `SSC-A`)) + 
  geom_hex(bins = 120) + 
  geom_density2d(colour = 'black') + 
  
  scale_x_logicle()} %>% print()

plt_green_FSC <- {ggcyto(single_fcs, aes(x = `FSC-A`, y = .data[[fluor_chnls[['green']]]])) + 
  geom_hex(bins = 120) + 
  geom_density2d(colour = 'black') + 
  
  scale_x_logicle() + scale_y_logicle()} %>% print()

plt_SSC_green <- {ggcyto(single_fcs, aes(x = .data[[fluor_chnls[['green']]]], y = `SSC-A`)) + 
    geom_hex(bins = 120) + 
    geom_density2d(colour = 'black') + 

    scale_x_logicle() + scale_y_logicle()} %>% print()

    

# Density
ggcyto(single_fcs, 
       aes(x = .data[[fluor_chnls[['green']]]] )#,  # plot 'YEL-HLog' for Guava bennett or Orange-G-A.. for Guava-SEA
       # subset = 'A'
) +
  geom_density(fill = 'green', alpha = 0.3) + 
  
  scale_x_logicle()


# scatter FSC vs SSC plot coloured by fluorescence
plt_sctr_with_fluor <- 
  {ggcyto(single_fcs, aes(x = .data[[scatter_chnls[['fwd']]]],
                          y = .data[[scatter_chnls[['side']]]],
                          z = .data[[fluor_chnls[['green']]]])) + 
      stat_summary_hex(bins = 120) + 
      geom_density2d(colour = 'black') + 
      
      scale_x_logicle() + scale_y_logicle()} %>% 
  
  print()
# error in `.data[["mGreenLantern cor-A"]]`:
# ! Column `mGreenLantern cor-A` not found in `.data`.


# scatter and fluor correlation arrangement (since the above colour method failed)
library(patchwork)

(plt_SSC_green + plt_sctr_single) / (plt_singlet_FSC + plt_green_FSC) # align the fluor vs fsc and ssc (plot_spacer())

# optional save
ggsave(plot_as(title_name, 'D01-tr'))
