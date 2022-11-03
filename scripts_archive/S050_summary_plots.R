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

# order of facets
assay_var_order <- c('MG1655', 'rGFP', 'pEMF02', 
                     'pInt8 + rGFP', 'pRV01 + rGFP', 'pRV01 + pEMF02', 
                     'pSS079', '7.32 + rGFP', '7.32 + pEMF02', 
                     '149', 'fGFP', 'pPK015')

# make new columns, remove beads, PBS etc.
processed_flowcal <- 
  pivot_longer(flowcal_summary,
               matches('-A$'),
               names_to = c('measurement', 'Fluorophore'), # split columns
               names_pattern = '(.*)_(.*)') %>% 
  pivot_wider(names_from = measurement, values_from = value) %>%  # put mean, median .. in separate columns
  
  drop_na(assay_variable) %>%  # remove empty samples : Beads, PBS etc.
  
  # order the facets - assay_variable
  mutate(across(assay_variable, ~ fct_relevel(.x, assay_var_order)))
  

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
    ggtitle('Median fluorescence (MEFL) : Flow cytometry. S050') + 
    
    theme(legend.position = 'top') +
    facet_wrap(c('assay_variable'), scales = 'free_y', ncol = 3)}


# re-plot with independent y-axis scale for better viewing
plt.median_yfree <- plot_median_data(.fluor = '.*') + 
  ggthemes::scale_colour_colorblind() + # new colourscheme
  guides(colour = guide_legend(nrow = 2))

plotly::ggplotly(plt.median_yfree, dynamicTicks = T) # interactive plot

ggsave(plot_as('S050_median'), plt.median_yfree, width = 8, height = 9) # save plot
  

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

plot_median_data('pInt8', .remove = 'glycerol') # ara without glycerol - high induction
# the + needs to be escaped as \\+
ggsave(plot_as('S050_Ara'), width = 6, height = 3)


# look for leak
plot_median_data('pRV01|MG1655|^rGFP|^pEMF', .remove = 'Induced', .fluor = '.*') %>% 
  plotly::ggplotly(dynamicTicks = T)
ggsave(plot_as('S050_rGFP look for leak'), width = 6, height = 4)

# individual for presentation
plot_median_data('pRV01 \\+ pEMF02')
ggsave(plot_as('S050_AHL_pflip'), width = 6, height = 3)


plot_median_data('pSS079', 'mcherry')
ggsave(plot_as('S050_pSS079'), width = 6, height = 3)


# check red in positive controls
plot_median_data('fGFP|pPK015', .fluor = 'mcherry') # weird increasing trend

# green-red correlation ----
# check if the uninduced samples are indeed leaky or fluctuations are random

corr_data <- select(processed_flowcal, -mean, -mode) %>% 
  pivot_wider(names_from = Fluorophore, values_from = median) %>% # make green and red columns
  
  group_by(assay_variable, sample_category, biological_replicates) %>% # group by unique sample
  
  summarize(red_green_correlation = cor(`gfpmut3-A`, `mcherry2-A`))

# plot correlations
plt_cor <- 
  ggplot(corr_data, aes(y = assay_variable, x = red_green_correlation, 
                      colour = sample_category, label = biological_replicates)) + 
  geom_jitter(width = 0) + 
  scale_y_discrete(limits = rev) + # reverse the order
  ggthemes::scale_colour_colorblind() + # new colourscheme
  theme(legend.position = 'top') + guides(colour = guide_legend(nrow = 2)) # legend

ggsave(plot_as('S050_red-green_correlations'), width = 6, height = 4)

plotly::ggplotly(plt_cor, dynamicTicks = T)
