# Grabbing the summary csv files output from python/FlowCal
# plotting across days to see trend

# Load libraries ----

library(tidyverse)
source('scripts_general_fns/13-formatting_plot_funs.R')
source('scripts_general_fns/6-wrappers_utilities.R')

# User inputs ----

base_directory <- 'FACS_analysis/tabular_outputs/S050/'
days <- -1:8

# Load metadata ----
sample_metadata <- read_csv('processed_data/S050_layout.csv') # read the pre-saved csv of the plate layout

# Load data ----

flowcal_summary <- map_dfr(days,
                       ~ read_csv(str_c(base_directory, 'S050_d', .x, '-summary.csv')) %>% 
                                    mutate(days_post_induction = .x)) %>% 
  rename(filename = well) %>% 
  mutate(well = str_extract(filename, '[A-H][:digit:]+')) %>% # detect the well numbers
  
  left_join(sample_metadata)


# process data ----

processed_flowcal <- 
  pivot_longer(flowcal_summary,
               matches('-A$'),
               names_to = c('measurement', 'Fluorophore'), # split columns
               names_pattern = '(.*)_(.*)') %>% 
  pivot_wider(names_from = measurement, values_from = value) %>%  # put mean, median .. in separate columns
  
  drop_na(assay_variable) # remove empty samples : Beads, PBS etc.
  

# TODO : arrange the stuff in visual order (factors) and control ncol in facet_wrap


# Overview plots ----

# plot generator function : filters to custom data-subset 
plot_median_data <- function(.filter = '.*', .fluor = 'gfp', .remove = 'nothing', .data = processed_flowcal)
  
{ggplot(.data %>% filter(str_detect(assay_variable, .filter), 
                         str_detect(Fluorophore, .fluor),
                         !str_detect(sample_category, .remove)),
        
        aes(x = days_post_induction, y = median, 
            colour = sample_category, shape = Fluorophore,
            label = biological_replicates)) +
    geom_point() + 
    geom_line(aes(group = interaction(sample_category, biological_replicates, Fluorophore))) +
    
    annotate(geom = 'rect', xmin = -1, xmax = 0, ymin = -Inf, ymax = Inf, alpha = 0.2) + # rectangle for induction
    ggtitle('Median fluorescence (MEFL) : Flow cytometry') + 
    
    theme(legend.position = 'top') +
    facet_wrap(c('assay_variable'), scales = 'free_y')}


# re-plot with independent y-axis scale for better viewing
plt.median_yfree <- plot_median_data(.fluor = '.*')

plotly::ggplotly(plt.median_yfree, dynamicTicks = T) # interactive plot

ggsave(plot_as('S050_median'), plt.median_yfree, width = 12, height = 9) # save
  

# Mode is fluctuating a lot over time -- use median for now
# plt.mode_yfree <- 
#   ggplot(processed_flowcal,
#          aes(x = days_post_induction, y = mode, 
#              colour = sample_category, shape = Fluorophore,
#              label = biological_replicates)) +
#   
#   geom_point() + 
#   geom_line(aes(group = interaction(sample_category, biological_replicates, Fluorophore))) +
#   
#   annotate(geom = 'rect', xmin = -1, xmax = 0, ymin = -Inf, ymax = Inf, alpha = 0.2) + # rectangle for induction
#   ggtitle('Mode fluorescence (MEFL) : Flow cytometry') + 
#   facet_wrap(c('assay_variable'), scales = 'free_y')
# 
# plotly::ggplotly(plt.mode_yfree, dynamicTicks = T) # interactive plot



# Individual plots ----

plot_median_data('pInt8', .remove = 'glycerol')
# the + needs to be escaped as \\+
ggsave(plot_as('S050_Ara'), width = 6, height = 3)


plot_median_data('pRV01 \\+ pEMF02')
ggsave(plot_as('S050_AHL_pflip'), width = 6, height = 3)


plot_median_data('pSS079', 'mcherry')
ggsave(plot_as('S050_pSS079'), width = 6, height = 3)
