# S048_correlation_qPCR_flowcyt.R

# Load libraries -----
library(tidyverse)


# Load data -----

# load qPCR data
qdat <- 
  read_csv('../qPCR/excel files/paper_data/conjug_ram_facs/ramfacs-3B Limit of detection of splicing-qPCR.csv') %>% 
  
  # remove ntc rows and Tm columns
  filter(assay_variable != 'ntc') %>% select(-matches('^Tm')) %>% 
  
  # make Copies into the wide format
  pivot_wider(names_from = Target_name, values_from = matches('Copies|^CT$'))


# load flow cytometry data
flodat <- 
  read_csv('FACS_analysis/tabular_outputs/S048_e coli dilutions-raw-gated_counts.csv') %>% 
  
  # remove the first column
  select(-`...1`) %>%
  
  # convert population to wide format
  pivot_wider(names_from = Population, values_from = c(Count, mean_Count))
  

# Processing ----

# BUG: fraction calculation is different between the qPCR and flow? 9.09 vs 9.99.. for 1/10x?

# join data
combined_data <-
  left_join(qdat, flodat, by = join_by('fraction of RAM cells', biological_replicates == replicate))


# Plotting ----

# plot red counts vs U64 qPCR
plt_counts <- 
  {ggplot(combined_data, 
         
         aes(x = Count_Red, y = Copies.per.ul.template_U64,
             label = assay_variable.x
             )) + 
  
  geom_point() + 
  geom_line(aes(x = mean_Count_Red, y = mean_Copies.per.ul.template_U64), 
            linetype = 2) +
  
  # ggtitle('3B Limit of detection of splicing-flow cyt') + # add title to plot
  # theme(legend.position = 'top') +  # position legend on the top 
  
  # formatting
  scale_x_log10() + scale_y_log10() } %>% 
  
  print()

# interactive plot
plotly::ggplotly(plt_counts)



