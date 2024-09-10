# S048_correlation_qPCR_flowcyt.R

# Load libraries -----
library(tidyverse)

# other inputs ----

# Sample name modifiers 

sample_name_translator <- c('Base strain|green' = 'Inf', # changes the LHS into the RHS
                            'ntc' = 'Inf',
                            '51|red' = '0',
                            '1/|,' = '') # remove commas and convert the 1/x into x 


# Load data -----

# load qPCR data
qdat <- 
  read_csv('../qPCR/excel files/paper_data/conjug_ram_facs/ramfacs-3B Limit of detection of splicing-qPCR.csv') %>% 
  
  # remove ntc rows and Tm columns
  filter(assay_variable != 'ntc') %>% select(-matches('^Tm')) %>% 
  
  # create a matching column from assay variable
  mutate('ratio_matcher' = str_replace_all(assay_variable, sample_name_translator)) %>% 
  
  # make Copies into the wide format
  pivot_wider(names_from = Target_name, values_from = matches('Copies|^CT$'))


# load flow cytometry data
flodat <- 
  read_csv('FACS_analysis/tabular_outputs/S048_e coli dilutions-raw-gated_counts.csv') %>% 
  
  # remove the first column
  select(-`...1`) %>%
  
  # create a matching column from assay variable
  mutate('ratio_matcher' = str_replace_all(assay_variable, sample_name_translator)) %>% 
  
  # convert population to wide format
  pivot_wider(names_from = Population, values_from = c(Count, mean_Count))
  

# Processing ----

# join data
combined_data <-
  left_join(qdat, flodat, by = join_by(ratio_matcher, biological_replicates == replicate))


# Plotting ----

# plot red counts vs U64 qPCR
plt_counts <- 
  {ggplot(combined_data, 
         
         aes(x = Count_Red, y = Copies.per.ul.template_U64,
             # label = assay_variable.x
             )) + 
  
      geom_point() + 
      
      # enclose replicates with ellipses
      ggforce::geom_mark_ellipse(aes(group = `fraction of RAM cells.x`, label = NULL),
                                     expand = unit(2, "mm"), # smaller ellipses than default
                                 alpha = 0.1) +
      
      # connect the means with a line
      # geom_line(aes(x = mean_Count_Red, y = mean_Copies.per.ul.template_U64), 
      #           linetype = 2) +
  
      # plot linear regression
      # geom_smooth(method = 'lm', alpha = 0.5) +
      ggpmisc::stat_poly_line() + # plot linear regression
      ggpmisc::stat_poly_eq() + # show R2 value
      
      # formatting
      theme_classic() +
      
      # label axes
      labs(x = 'Counts of mScarlet positive cells', y = 'Copies of spliced 16S per ul') +
      
      scale_x_continuous(labels = scales::label_number_auto())
      
      # logscale: neat labels from https://stackoverflow.com/a/73526579/9049673
      # scale_x_log10(labels = scales::label_log()) + 
      # scale_y_log10(labels = scales::label_log()) 
    } %>% 
  
  print()

# interactive plot
plotly::ggplotly(plt_counts)

## save plot ----
ggsave('FACS_analysis/plots/S048_correlation_qPCR_flowcyt.png', plt_counts, 
       width = 5, height = 5)

# save pdf
ggsave('FACS_analysis/plots/S048_correlation-linear_qPCR_flowcyt.pdf', plt_counts, 
       width = 4, height = 4)


# Correlation ----

# get the correlation for above plot: 
with(combined_data, # for columns in this data
     
     # correlation
    cor(x = Count_Red, y = Copies.per.ul.template_U64, 
        use = "pairwise.complete.obs")) # specify this to drop NAs
