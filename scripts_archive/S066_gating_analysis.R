# S066_gating_analysis.R


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
title_name <- 'S066x_Ara dose-1-processed'

counts_gated <- str_c('FACS_analysis/tabular_outputs/', title_name, '-gated_counts.csv') %>% read.csv


# look at d0 fractions only
d0_counts <- filter(counts_gated, sample_category == 'd0') %>% 
  mutate(Arabinose = as.numeric(assay_variable), .before = assay_variable)

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
