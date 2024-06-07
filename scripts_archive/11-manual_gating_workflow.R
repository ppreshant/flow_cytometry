# 11-manual_gating_workflow

#' Gating on a single (or few?) representative sample and applying it to other fcs files
#' Currently this is a general workflow but will be copied when it has been modified for specific expts

# Load data by running analyze_fcs till line 37 (sample_metadata <- ..)
source('./analyze_fcs.R')


# Select sample(s) ----

# select a single fcs using regex match: well name for regular data ; sample name for combined data
subset_this_file <- 'A07_d-1' 
# provide this in the adhoc script for the particular experiment


# select a single fcs now
single_fcs <- get_matching_well(fl.set, subset_this_file) # select a representative sample to set gates on
# selected the 1:1 dilution for S048 : well E03


# Visualize sample ----

# plot density to get idea for gating
density_green_single <- plot_density(.cytoset = single_fcs) %>% print

# plot scatterplots of fluorescences -- fails if only a single fluorophore is present
plt_fluor2d_single <- plot_scatter(.cytoset = single_fcs, .x = fluor_chnls[['red']], .y = fluor_chnls[['green']]) %>% print

# fluor vs scatter 
green_fsc_single <- {plot_scatter(.cytoset = single_fcs, 
                                  .x = scatter_chnls[['fwd']], .y = fluor_chnls[['green']])} %>% print



# Gating ----

# (setting 1D gates on both channels stored in vector 'fluor_chnls')
# set the gate at 99.9% percentile in the negative control sample (empty cells)
gates_1d_list <- 
  map(fluor_chnls, 
      ~ openCyto::gate_quantile(single_fcs, channel = .x))
   
# other gating functions : minimum density / valley in 1D when there are 2 peaks
# gate_red <- openCyto::mindensity(single_fcs, channel = fluor_chnls['red']) %>% print
                                  # gate_range = c(150, Inf) # manual use: need a gate range to set higher than cluster
# gate_red <- openCyto:::.boundary(single_fcs, channels = fluor_chnls['red'], min = 300, max = Inf) %>% print
                       
 
# Look at openCyto documentation for other gating functions 
# https://www.bioconductor.org/packages/release/bioc/vignettes/openCyto/inst/doc/HowToAutoGating.html


# Visualize gates

# density plot
plt_den_1d_list <- 
  map2(fluor_chnls, gates_1d_list,
       ~ {ggcyto(single_fcs, 
                 aes(x = .data[[.x]])) + # use respective channel name
           geom_density(fill = 'red', alpha = 0.3) + 
           
           geom_gate(.y, size = 0.8) + # plot the respective gate
           
           labs_cyto('marker') +  # show clean axis titles
           # ref: https://bioconductor.org/help/course-materials/2015/BioC2015/ggcyto.html  
           
           scale_x_flowjo_biexp() # use log10 or biexp when logicle does not converge
         
       } %>% print()
  )

# scatter plot
# plt_scatter_1dgate_list <- 
#   map2(fluor_chnls, gates_1d_list,
#        ~ {ggcyto(single_fcs, 
#                  aes(x = .data[[.x]], y = 'SSC-A')) + # use respective channel name
#            geom_hex(bins = 120) + 
#            geom_density2d(colour = 'black') + 
#            
#            geom_gate(.y, size = 0.8) + # plot the respective gate
#            
#            labs_cyto('marker') +  # show clean axis titles
#            # ref: https://bioconductor.org/help/course-materials/2015/BioC2015/ggcyto.html  
#            
#            scale_x_flowjo_biexp() + # use log10 or biexp when logicle does not converge
#            scale_y_flowjo_biexp()
#          
#        } %>% print()
#   )

# Broadcast gates ----
# Set gates to all samples

gate_set <- GatingSet(fl.set) # create a gatingset for all the samples / can use fl.subset too

# Add the 1D gates we set above
node1 <- gs_pop_add(gate_set, gates_1d_list[[1]], name = 'Green') # add gates to root node of gating set
node2 <- gs_pop_add(gate_set, gates_1d_list[[2]], name = 'Red') # add gates to root node // each is optional
# These named populations correpond to the events ABOVE the gate/red line
# Now all the gates are added to the gating tree but the actual data is not gated yet

# Add a dummy gate : for practice
# rg <- rectangleGate("FSC-H"=c(200,400), "SSC-H"=c(250, 400), filterId="rectangle")
# node3 <- gs_pop_add(gate_set, rg)


# print the gating hierarchy (for verification)
# plot(gate_set[[1]]) 
gs_get_pop_paths(gate_set)

# apply gate to the population
recompute(gate_set)

# check the gated data : of a random sample
autoplot(gate_set[[13]]) + scale_x_flowjo_biexp() + scale_y_flowjo_biexp() # check the gate on a random data
# TODO : scale_x_logicle() doesn't converge here for some reason


# User input ----

# Sample name modifiers : For informative labelling
# use by replacing assay_variable with these translated names 
# mutate(new_var = str_replace_all(assay_variable, sample_name_translator))
# sample_name_translator <- c('Base strain|green' = 'Inf', # changes the LHS into the RHS
#                             'ntc' = 'Inf',
#                             '51|red' = '0',
#                             '1/|,' = '') # remove commas and convert the 1/x into x 


# Count gated events ----

metadata_variables_gating <- c('assay_variable', 'sample_category', 'Population')

# Get population counts
counts_gated <- gs_pop_get_count_fast(gate_set) %>% 
  mutate(freq = Count/ParentCount) %>% # get the fraction of events in the gate
  
  rename(filename = 'name') %>% # rename to be consistent with flowworkspace..?
  
  # fish out well information from filename
  mutate(well = if(combined_data) {str_match(filename, '_([A-H][:digit:]+)') %>% .[,2] # look for well after underscore (combined data)
  } else  str_extract(filename, '[A-H][:digit:]+') # regular data - well should be clear (could use ^ : start with)
  ) %>%
  
  # join with metadata
  left_join(sample_metadata) %>%  # join the sample names from the plate layout

  # # transform the metadata to final plot variable (ad-hoc, changes w expt)
  # mutate('fraction of RAM cells' = 
  #           %>% 
  #          as.numeric %>% {1/(1+.)}, # convert to numbers and to fraction (1:1 -> 0.5 ; 1:10 -> 1/11)
  #        .before = well) %>% 
  
  # clean the gates name (remove '/')
  mutate(across(Population, ~ str_replace(.x, '/', ''))) %>% 
  
  # summary statsfor replicate wells
  group_by(across(all_of(metadata_variables_gating))) %>% # group within replicates
  mutate(across(c(Count, freq), # create mean of counts
                mean,  
                .names = 'mean_{.col}'), 
         .before = well) %>% 
  
  ungroup() %>% 
  # arrange in order for plotting
  arrange(mean_freq) %>% 
  mutate(across(assay_variable, fct_inorder))


# Save gated counts ----

write.csv(counts_gated, 
          str_c('FACS_analysis/tabular_outputs/', title_name, '-gated_counts', '.csv'),
          na = '')


# Plotting ----

facet_by_sample_category <- FALSE

# plot red and green cell counts 
plt_counts <- {ggplot(counts_gated, 
                      aes(x = freq, y = assay_variable, 
                          colour = Population,
                          label = assay_variable)) + 
    
    geom_point() + 
    # geom_line(aes(x = mean_Count), linetype = 2) + 
    
    # facets
    facet_wrap(facets = if(combined_data & !facet_by_sample_category) vars(data_set) 
               else vars(sample_category),
               scales = 'free') +
    
    ggtitle(title_name) + # add title to plot
    theme(legend.position = 'top')} %>%  # position legend on the top 
  
  print
  
  # formatting
  # format_logscale_x() %>% format_logscale_y()

# interactive plot
# plotly::ggplotly(plt_counts)  
  
# save plot
ggsave(plot_as(title_name, '-counts'), plt_counts, width = 6, height = 8)



# Subset gated events ----
# How to get intensity of only the gated events?
# Idea : subset the gated events ; then run flowworkspace summary on this dataset


fl.green <- gs_pop_get_data(gate_set, 'Green')

# TODO : generate a fcsunique.subset using the gated_summary to annotate ridges
# TODO: add the gated frequency on the right side of the ridgeline plot (separately)


# plot to check
# plot_density(.cytoset = fl.green) %>% print()

source('scripts_general_fns/17-plot_ridges_fluor.R') # source script
green_ridges <- plot_ridges_fluor(.show_medians = show_medians, .cytoset = fl.green, 
                                  # .show_jittered_points = TRUE,
                                  # .save_plots = F, # don't save plots for now
                                  .plot_filename = 'S089_gated' # save plot 
                                  )

# check if gating worked
# need to count the number of events before and after gating. 
nrow(fl.set[[30]])
nrow(fl.green[[30]])

# facet by sample category
gated_ridges_faceted <- 
  green_ridges$green + 
  facet_wrap(facets = vars(sample_category), scales = 'free_y', ncol = 6) + # facet by organism (sample_category)
  theme(legend.position = 'none') # remove legend/redundant

# save plot
ggsave(str_c('FACS_analysis/plots/', 
             'S089_gated',
             '.png'),
       height = 6, width = 20) # change height and width by number of panels


## summarize gated data intensity ----

# get summary statistics
gated_summary <-
  summary(fl.green) %>% # base R's summary function : gives min, max, mean, median and quartiles; a column for each well and channel
  map( ~ as_tibble(.x, rownames = 'statistic') %>% # convert array into dataframe
         .[, c('statistic', fluor_chnls)]) %>% # select the relevant channels (avoiding dplyr, renaming issue with named vector)
  
  # Convert to a cleaner format
  {map2_df(.x = ., .y = names(.),
           ~ pivot_wider(.x,
                         names_from = statistic,
                         values_from = all_of(set_names(fluor_chnls, NULL)),
                         names_glue = "{statistic}_{.value}"
           ) %>%
             
             add_column(filename = .y)
           
  )} %>%
  select(filename, everything()) %>%  # gives the min, max quartiles, mean for fluorescence channels
  
  # fish out well information from filename
  mutate(well = if(combined_data) {str_match(filename, '_([A-H][:digit:]+)') %>% .[,2] # look for well after underscore (combined data)
  } else  str_extract(filename, '[A-H][:digit:]+') # regular data - well should be clear (could use ^ : start with)
  ) %>%
  
  # attach metadata and counts by well
  left_join(counts_gated) %>%  # attach the metadata : sample names from google sheets (, by = 'well')
  
  
  # reshape data for ease of use by code
  pivot_longer(matches('-A$'),
               names_to = c('measurement', 'Fluorophore'), # split columns
               names_pattern = '(.*)_(.*)') %>% 
  pivot_wider(names_from = measurement, values_from = value) %>%  # put mean, median .. in separate columns
  
  # get mean of replicates
  group_by(across(all_of(metadata_variables))) %>% # group -- except replicate
  mutate(mean_medians = mean(Median)) %>%  # find the mean of replicates
  ungroup() %>% 
  
  # arrangement by median of red fluorescence in ascending order
  arrange_in_order_of_fluorophore


# save summary

write.csv(gated_summary,
          str_c('FACS_analysis/tabular_outputs/', title_name, '_gated-summary', '.csv'),
          na = '')


# manual gating ----

# gate different subpopulations in FSC-SSC and plot their fluors together?