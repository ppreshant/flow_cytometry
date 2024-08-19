# gating script for S048 dilution experiment
# this has been forked and somewhat generalized in 11-manual_gating_workflow.R 
# gating scheme here (mindensity) is different than 11-..script (quantilegate) on negative control


# Load data into `fl.set` by running analyze_fcs till line 88 with 
# 'S048_e coli dilutions' data from 'flowcyt_data'

# source('./analyze_fcs.R')


# visualize all data ----

# subset data from 7-exploratory_data_analysis.R using custom parameter
fcsunique.subset <- subset_cytoset(fl.set, 
                                   non_data_stuff, specific_data, exclude_category, # use for labeling ridges' medians
                                   return_fcsunique.subset = FALSE,
                                   # optional manual filtering (additional to above)
                                   # str_detect(assay_variable, '79') | str_detect(data_set, 'd-1')
)

# run "Scatter fluor 2 colours"
# 


# Select sample(s) ----

single_fcs <- get_matching_well(fl.set, 'E03') # select a representative sample to set gates on
# selected the 1:1 dilution for S048 : well E03


# run the rest of steps from 11-manual_gating_workflow.R 

# Visualize single sample ----

pltscatter_single <- {ggcyto(single_fcs, # select subset of samples to plot
                     aes(x = 'mScarlet-I-A', y = 'mGreenLantern cor-A')) +  # fluorescence channels
  # geom_point(alpha = 0.1) +
  geom_hex(bins = 64) + # make hexagonal bins with colour : increase bins for higher resolution
  scale_x_logicle() + scale_y_logicle() +
  # logicle = some bi-axial transformation for FACS (linear near 0, logscale at higher values)
  
  ggcyto_par_set(limits = list(x = c(-100, 1e4), y = c(-100, 1e4))) +
  
  facet_wrap('name', ncol = 10, scales = 'free') + # control facets
  ggtitle(title_name)} %>% 
  print()

# save plot
ggsave(str_c('FACS_analysis/plots/', 
             title_name,  # title_name, 
             '-scatter-E03', 
             '.png'),
       plot = pltscatter_single,
       height = 5, width = 5) # change height and width by number of panels

# save PDF
ggsave(str_c('FACS_analysis/plots/', 
             title_name,  # title_name, 
             '-scatter-E03', 
             '.pdf'),
       plot = pltscatter_single,
       height = 5, width = 5) # change height and width by number of panels


# Gating ----
# (setting 1D gates on both channels stored in vector 'fluor_chnls')
# gate at the valley of minimum density between -ve and +ve populations
gates_1d_list <- 
  map(fluor_chnls, 
      ~ openCyto::mindensity(single_fcs, channel = .x)) # draws a line at the minimum density region in 1d


# Visualize gates

# scatter plot
plt_scatter_1dgate_list <- 
  map2(fluor_chnls, gates_1d_list,
       ~ {ggcyto(single_fcs, 
                 aes(x = .data[[.x]], y = 'SSC-A')) + # use respective channel name
           geom_hex(bins = 120) + 
           geom_density2d(colour = 'black') + 
           
           geom_gate(.y, size = 0.8) + # plot the respective gate
           
           labs_cyto('marker') +  # show clean axis titles
           # ref: https://bioconductor.org/help/course-materials/2015/BioC2015/ggcyto.html  
           
           scale_x_flowjo_biexp() + # use log10 or biexp when logicle does not converge
           scale_y_logicle()
         
       } %>% print()
  )


# density plot
plt_den_1d_list <- 
  map2(fluor_chnls, gates_1d_list,
       ~ {ggcyto(single_fcs, 
                 aes_string(x = as.name(.x))) + # use respective channel name
           geom_density(fill = 'red', alpha = 0.3) + 
           
           geom_gate(.y, size = 0.8) + # plot the respective gate
           
           labs_cyto('marker') +  # show clean axis titles
           # ref: https://bioconductor.org/help/course-materials/2015/BioC2015/ggcyto.html  
           
           scale_x_flowjo_biexp() # use log10 or biexp when logicle does not converge
         
       } %>% print()
  )

# Broadcast gates ----
# Set gates to all samples

gate_set <- GatingSet(fl.set) # create a gatingset for all samples

# Add the 1D gates
node1 <- gs_pop_add(gate_set, gates_1d_list[[1]], name = 'Green') # add gates to root node of gating set
node2 <- gs_pop_add(gate_set, gates_1d_list[[2]], name = 'Red') # add gates to root node
# Now all the gates are added to the gating tree but the actual data is not gated yet

# Add a dummy gate
# rg <- rectangleGate("FSC-H"=c(200,400), "SSC-H"=c(250, 400), filterId="rectangle")
# node3 <- gs_pop_add(gate_set, rg)


# plot the gating hierarchy (for verification)
# plot(gate_set[[1]]) 
gs_get_pop_paths(gate_set)

# apply gate to the population
recompute(gate_set)

# check the gated data
autoplot(gate_set[[13]]) + scale_x_flowjo_biexp() + scale_y_logicle() # plot data doesn't show up

# TODO: some plot showing all gated data? -- will be hard to identify the samples still?


# Check gates comprehensive ----

# doesn't work.. issues with showing gates

# plot gated data of all samples
# pltscatter_gated <-
#   ggcyto(fl.set[-(1:3)], # select subset of samples to plot : 
#          aes(x = 'mScarlet-I-A', y = 'mGreenLantern cor-A')) + 
#   
#   geom_gate(data = gates_1d_list) + # show gate?
#   
#   geom_hex(bins = 64) + 
#   scale_x_logicle() + scale_y_logicle() + 
#   # facet_wrap('name', ncol = 10, scales = 'free') + 
#   ggtitle(title_name)
# 
# ggsave(str_c('FACS_analysis/plots/', 
#              title_name, 
#              '-gated', 
#              '.png'),
#        plot = pltscatter_gated,
#        height = 12, width = 40) # change height and width by number of panels


# User input ----

# Sample name modifiers 

sample_name_translator <- c('Base strain|green' = 'Inf', # changes the LHS into the RHS
                            'ntc' = 'Inf',
                            '51|red' = '0',
                            '1/|,' = '') # remove commas and convert the 1/x into x 

# title_name <- '3B Limit of detection of splicing-flow cyt'


# Analysis ----

# Get population counts
counts_gated <- gs_pop_get_count_fast(gate_set) %>% 
  mutate(well = str_extract(name, '[A-H][:digit:]*')) %>%  # extract well from .fcs name
  left_join(sample_metadata, by = 'well') %>%  # join the sample names from the plate layout

  # transform the metadata to final plot variable (ad-hoc, changes w expt)
  mutate('fraction of RAM cells' = 
           str_replace_all(assay_variable, sample_name_translator) %>% 
           as.numeric %>% {1/(1+.)}, # convert to numbers and to fraction (1:1 -> 0.5 ; 1:10 -> 1/11)
         .before = well) %>% 
  
  # clean the gates name (remove '/')
  mutate(across(Population, ~ str_replace(.x, '/', ''))) %>% 
  
  # summary stats
  group_by(assay_variable, Population) %>% # group within replicates
  mutate(across(Count, mean,  .names = 'mean_{.col}', .before = well)) # create mean of counts


# Save gated counts ----

write.csv(counts_gated, 
          str_c('FACS_analysis/tabular_outputs/', title_name, '-gated_counts', '.csv'),
          na = '')


# Plotting ----

# plot red and green cell counts 
plt_counts <- {ggplot(counts_gated, 
                      aes(x = `fraction of RAM cells`, y = Count, 
                          colour = Population,
                          label = assay_variable)) + 
    
    geom_point() + 
    geom_line(aes(y = mean_Count), linetype = 2) + 
    
    ggtitle(title_name) + # add title to plot
    theme(legend.position = 'top')} %>%  # position legend on the top 
  
  # formatting
  format_logscale_x() %>% format_logscale_y()

# interactive plot
# plotly::ggplotly(plt_counts)  
  
# save plot
ggsave(plot_as(title_name, '-counts'), plt_counts, width = 4, height = 4)

# save PDF
ggsave(str_c('FACS_analysis/plots/', title_name, '-counts.pdf'), plt_counts, width = 4, height = 4)
# note: later renamed this PDF to `limit of detection..` if you are looking for it