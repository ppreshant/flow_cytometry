# S050_dist_analysis.R


# Gating analysis ----
# documenation of adhoc runs -: 

# Green
# use 'A07_d-1'
# gate_range = c(150, Inf)

# Red
# well : 'A06_d-1'
# gate_range = c(1500, Inf)

# Notes: The samples were gated, and gating checked (`S050 plot subsets` below) and saved
# Saved data is opened, processed (based on `S070,66_gating_analysis.R`) 
# and plotted (based on `S050_summary_plots.R`)


# user inputs ----

flnm <- 'S050_combined'
title_name <- 'S050_processed' # to display on plots + file headers for saving plots

# inducer translation : placeholders 
inducer_translation <- c('Induced' = 'I',
                         'Uninduced' = '0')


# Prelim ----

# load packages
library(tidyverse) # load mother of all pacakges!
source('scripts_general_fns/13-formatting_plot_funs.R')


# Load data ----
counts_gated <- 
  flnm %>% 
  {str_c('FACS_analysis/tabular_outputs/', ., '-processed-gated_counts.csv')} %>% # make file path
   
  read_csv # read the gated counts from file


# Processing ----
processed_counts <-
  counts_gated %>%
  
  # create numeric days vector for plotting
  mutate(day = str_remove(data_set, 'd') %>% as.numeric) %>% 
  
  # rename Inducers with shorter placeholders
  mutate(Inducer = str_replace_all(sample_category, inducer_translation)) %>% 

  # create replicates column
  group_by(assay_variable, sample_category, data_set, Population) %>% 
  mutate(replicate = row_number()) %>% 
  ungroup()
  
  
# can't use -- has Ara samples too - do in post processing in inkscape


# Plot ----

# plot generator function : filters to custom data-subset 
timeseries_plot <- function(.filter_assay = '.*', .fluor = 'Green', .filter_inducer = '.*', .data = processed_counts,
                            .order_inducer = c('0', 'I'),
                            .y = freq)
  
{
  # subset data
  data_subset <- 
    .data %>% filter(str_detect(assay_variable, .filter_assay), 
                     str_detect(Population, .fluor),
                     str_detect(Inducer, .filter_inducer)) %>% 
    
    mutate(across(Inducer, ~ fct_relevel(.x, .order_inducer))) # order levels for plotting
    
  
  # formatting helpers
  two_shapes =  data_subset$Inducer %>% unique %>% length == 2 # to fix shapes open and close circles
  
  # TODO : nest data into populations (green vs red) and map for plotting each separately
  
  # Plot
  {ggplot(data_subset,
        
        aes(x = day, y = {{.y}}, 
            shape = Inducer,
            label = replicate)) + # for interactive plots and maybe joining with lines 
    
    geom_point() + 
    geom_line(aes(group = interaction(sample_category, replicate),
                  alpha = Inducer)) +
    
    # formatting
    {if(two_shapes) scale_shape_manual(values = c(1, 16))} + # shape : open and closed circles
    scale_alpha_discrete(guide = 'none', range = c(0.2, 0.5)) + # control line transparency
    
    # inducer duration
    annotate(geom = 'rect', xmin = -1, xmax = 0, ymin = -Inf, ymax = Inf, alpha = 0.2) + # rectangle for induction
    
    # labels
    ggtitle('S050 : Flow cytometry. S050') + 
    
    # layout
    theme(legend.position = 'top') +
    facet_wrap(facets = vars(assay_variable), scales = 'free_y', ncol = 3)} %>% print
  
}

# Convenience function for plotting directory and .png suffix for adhoc plots
plot_as <- function(plt_name, ..., ext = '.png')  str_c('FACS_analysis/plots/', plt_name, ..., ext)


# arabinose
plt.ara <- timeseries_plot(.filter_assay = 'pInt8 \\+ rGFP', .fluor = 'Green', 
                           .filter_inducer = '(0|I)$')
ggsave(plot_as('S050_Ara-fraction'), width = 6, height = 3)


# arabinose w glycerol
plt.ara <- timeseries_plot(.filter_assay = 'pInt8 \\+ rGFP', .fluor = 'Green', 
                           .filter_inducer = 'glycerol', .order_inducer = c('0-glycerol', 'I-glycerol'))
ggsave(plot_as('Archive/S050_Ara-fraction-glycerol'), width = 6, height = 3)

# AHL v0
plt.ahlv0 <- timeseries_plot(.filter_assay = 'pRV01 \\+ rGFP', .fluor = 'Green')
ggsave(plot_as('S050_AHL-v0-fraction'), width = 6, height = 3)

# AHL v0
plt.ahl <- timeseries_plot(.filter_assay = 'pSS079', .fluor = 'Red')
ggsave(plot_as('S050_AHL-fraction'), width = 6, height = 3)
# Bad gate? -- check





# S050 plot subsets ----

# subset using the special condition in `7-exploratory_data_view.R` line 23
# these plots help check if gating went right for specific samples (to be concise)

fcsunique.subset <- 
  subset_cytoset(non_data_stuff, specific_data, exclude_category, # use for labeling ridges' medians
                 
                 (str_detect(assay_variable, 'MG1655') & data_set == 'd-1') | 
                   str_detect(assay_variable, '79') # optional manual filtering (additional to above)
  )

# run plotter without saving
plt_ridges <- plot_ridges_fluor(.show_medians = show_medians, .save_plots = F)

# merge facets to join MG1655 with others
plt_red <- plt_ridges[[2]] + facet_grid(facets = NULL) + ggtitle(str_c(title_name, '- pSS079')) 

# add gate for red
# plt_red + geom_gate(gates_1d_list[[2]], size = 0.8) 
# Error: Can't subset by cols when gh is not data-only object! 

ggsave(plot_as('S050_subset2-processed', '-pSS079'), width = 3, height = 6)


# S050 subset (old) ----

# modify pData for S050 subsets 
# recognize day from filename and make a `data_set` column

# use python script to process selected regex (adhoc pipeline) without beads 
# load the S050_subset data with analyze_fcs.R

original_pdata <- pData(fl.set)

new_pdata <- original_pdata %>% 
  mutate(data_set = str_extract(rownames(.), 'd-?[:digit:]+')) # add day key as `data_set`

pData(fl.set) <- new_pdata

combined_data <- T

# continue running analysis.R from line 39 till 100 (flowworkspace_summary)

new_pdata2 <- new_pdata %>% mutate(filename = rownames(.)) %>% # enable to join to flowworkspace summary
  select(filename, data_set)


flowworkspace_summary <- flowworkspace_summary %>% 
  left_join(new_pdata2)

# now plot 7-exploratory.. # make plots and optionally save them with title_name + suffixes
plt_ridges <- plot_ridges_fluor(.show_medians = show_medians, .save_plots = F) 

plt_ridges[[1]] + facet_wrap(facets = NULL)
ggsave(plot_as(title_name, '-pRV01+rGFP'), width = 3, height = 6)
