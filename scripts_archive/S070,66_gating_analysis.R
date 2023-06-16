# S070,66_gating_analysis.R


# Pre-steps/first time ----
# Steps to get `counts_gated` data

# Load data by running analyze_fcs atleast till line 37 (sample_metadata <- ..)
# Run till the end : line 137 for ordering the ridge plot (list_of_ordered_levels <- ..)
# source('./analyze_fcs.R')

# run the manual gating workflow step by step to get `counts_gated`
# 'scripts_archive/11-manual_gating_workflow.R'

# Prelim ----

# load packages
library(tidyverse) # load mother of all pacakges!
source('scripts_general_fns/13-formatting_plot_funs.R')


# Load data ----

flnms <- 'S070_Ara'
title_name <- "S070_Ara-processed" # overwrite title_name 

# S066 datasets
# flnms <- c('S066x_Ara dose-1', 'S066b1_Ara dose_ d2-d4', 'S066b2_Ara dose d5')
# title_name <- 'S066-processed' # appears on fig title and saved plot name

counts_gated <- 
  flnms %>% 
  {str_c('FACS_analysis/tabular_outputs/', ., '-processed-gated_counts.csv')} %>% 
  
  map_dfr(read.csv) %>% # read all the gated counts files
  
  # processing for dose_response type of data
  mutate(sample_type = if_else(str_detect(assay_variable, 'glu|OFF|ON'), 'Controls', 'Induction'), # mark controls
         Arabinose = as.numeric(assay_variable), .before = assay_variable) %>%  # convert to numeric for plotting properly
  mutate(day = str_remove(sample_category, '^d'), .before = sample_category) # make a new column for day

unique_counts <- summarise(counts_gated, mean_freq = mean(freq),
                           .by = c(Arabinose, assay_variable, sample_category, day, Population))


# dose response plot ----

source('scripts_general_fns/19-plot_dose_response_and_controls.R')
dose_response_title <- 'Memory with Ara conc., flow cytometry'
plt_dosec <- plot_dose_response_and_controls()
plt_dosec[[1]] # call the combined plot

plotly::ggplotly(plt_dosec[[2]]) # interactive partial plot with numeric Arabinose : chase outliers
ggsave(plot_as(title_name, '-dose_response'), plt_dosec[[1]], width = 6, height = 4)

# save pdf for paper
ggsave(str_c('FACS_analysis/plots/', title_name, '.pdf'), plt_dosec[[1]], width = 5, height = 4)



# Dynamic range calc ----

# max Ara
max_ara_freq <- filter(unique_counts, Arabinose == 1e4) %>% pull(mean_freq)

# min Glu, d0
min_glu_freq <- filter(unique_counts, assay_variable == 'glu', sample_category == 'd0') %>% pull(mean_freq) %>% 
  print


# dynamic range
max_ara_freq / min_glu_freq

# Max
filter(unique_counts, mean_freq == max(mean_freq))

# Min
filter(unique_counts, mean_freq == min(mean_freq))



# Plot timecourse S066 ----
# relevant for S066 only

plt_timecourse <-
  {ggplot(counts_gated,
          aes(day, freq, label = biological_replicates)) + # change `biological_replicates` to `replicate` : S070
      
      geom_point(size = 1, position = position_jitter(width = 0.2, height = 0)) + 
      
      # join each replicate      
      geom_line(aes(group = interaction(assay_variable, biological_replicates)), alpha = 0.2) + 
      
      # Line through mean
      # geom_line(aes(y = mean_freq, label = NULL, 
      #               group = assay_variable), unique_counts) +
      
      facet_wrap(~ assay_variable) +
      
      ggtitle('ON state fraction', subtitle = title_name)} %>% 
  print
    
ggsave(plot_as(title_name, '-timecourse-repl'), plt_timecourse, width = 8, height = 7)

plotly::ggplotly(plt_timecourse)

# Day 0 plot ----

# look at d0 fractions only
d0_counts <- filter(counts_gated, sample_category == 'd0') 
  

d0_unique <- summarise(ungroup(d0_counts), mean_freq = mean(freq),
                       .by = c(Arabinose, Population))

# plot dose-response
{ggplot(d0_counts,
       aes(Arabinose, freq)) +
  
  geom_point() + 
  geom_line(aes(y = mean_freq), d0_unique)} %>% 
  
  format_logscale_x() + 
  
  ggtitle('ON state fraction', subtitle = title_name)

# save plot ----

ggsave(plot_as(title_name, '-dose_response'))



# Distribution plot ----

# plotting this with threshold for supplementary fig S1

# load data 
# Make plot with axis rearranged (manually change list_of_ordered_variables)

# subset S070 only
fcsunique.subset <- subset_cytoset(specific_data = 'd.')

list_of_ordered_levels$assay_variable <- c('OFF', 'ON', 'glu', '0', '1e-1', '1e0', '1e1', '1e2', '1e3', '1e4')

plt_ridges <- plot_ridges_fluor(.show_medians = T, .save_plots = F, .fluor_colour = 'green')

plt_green <- 
  plt_ridges$green + ggtitle(NULL) + geom_vline(xintercept = 647.82, colour = 'red')

# do gating and add value manually w geom_vline()
ggsave('FACS_analysis/plots/S070_Ara_dist.pdf', width = 3, height = 6)

