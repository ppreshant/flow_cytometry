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
flnms <- c('S066x_Ara dose-1', 'S066b1_Ara dose_ d2-d4', 'S066b2_Ara dose d5')
title_name <- 'S066-processed' # appears on fig title and saved plot name

counts_gated <- 
  flnms %>% 
  {str_c('FACS_analysis/tabular_outputs/', ., '-processed-gated_counts.csv')} %>% 
  
  map_dfr(read.csv) %>% # read all the gated counts files
  mutate(Arabinose = as.numeric(assay_variable), .before = assay_variable) %>% # make Ara numeric
  mutate(day = str_remove(sample_category, '^d'), .before = sample_category) # make a new column for day

unique_counts <- summarise(counts_gated, mean_freq = mean(freq),
                           .by = c(Arabinose, assay_variable, sample_category, day, Population))


# Plots ----

# plot dose-response
# save_jitter <- position_jitter(width = .5, height = 0)

plt_dose <-
{ggplot(counts_gated,
        aes(Arabinose, freq, colour = sample_category)) +
    
    geom_point() + 
    geom_line(aes(y = mean_freq), unique_counts) + 
    
    guides(colour = guide_legend(title = 'day'))} %>% 
  
  format_logscale_x() + 
  
  ggtitle('ON state fraction', subtitle = title_name)


plt_controls <- 
  
  {filter(counts_gated, str_detect(assay_variable, 'glu|OFF|ON')) %>% # plot non Ara samples
  
  ggplot(aes(assay_variable, freq, colour = sample_category)) +
      
      geom_point(show.legend = F) + 
      ylab(NULL) + xlab('Controls')} %>% 
  print

# Assemble plots
library(patchwork)

full_plot <- 
plt_dose + plt_controls + 
  plot_layout(guides = 'collect', widths = c(4, 1))

ggsave(plot_as(title_name, '-dose_response'), full_plot, width = 6, height = 4)


# Plot timecourse 
plt_timecourse <-
  {ggplot(counts_gated,
          aes(day, freq, label = biological_replicates)) +
      
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
