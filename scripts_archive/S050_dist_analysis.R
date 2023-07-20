# S050_dist_analysis.R


# Gating analysis ----
# documenation of adhoc runs -: 

# Green
# use 'A07_d-1' ; 99 quantile gate : sets at 172.39
# old : gate_range = c(150, Inf) # uses exactly 150

# Red
# well : 'A06_d-1' ; 300 manual gate
  # old : gate_range = c(200, Inf) # using 888.3559 
  # Notes: older range 1500 is too high, quartile 99 too high ; Try minden D02_d2 (induced)?

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
  
  
# do in post processing in inkscape to name the inducers properly


# Plotting wrappers ----

# plot generator function : filters to custom data-subset 
timeseries_plot <- function(.filter_assay = '.*', .fluor = 'Green', .filter_inducer = '.*', .data = processed_counts,
                            .order_inducer = c('0', 'I'),
                            .y = freq,
                            
                            use_colour = 'black')
  
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
    
    geom_point(colour = use_colour) + 
    geom_line(aes(group = interaction(sample_category, replicate),
                  alpha = Inducer),
              colour = use_colour) +
    
    # formatting
    {if(two_shapes) scale_shape_manual(values = c(1, 16))} + # shape : open and closed circles
    scale_alpha_discrete(guide = 'none', range = c(0.2, 0.5)) + # control line transparency
    
    # inducer duration
    annotate(geom = 'rect', xmin = -1, xmax = 0, ymin = -Inf, ymax = Inf, alpha = 0.2) + # rectangle for induction
    
    # labels
    ggtitle('S050 : Flow cytometry. S050') + 
    
    # layout
    theme(legend.position = 'top', legend.justification = 'left') +
    facet_wrap(facets = vars(assay_variable), scales = 'free_y', ncol = 3)} %>% print
  
}

# Convenience function for plotting directory and .png suffix for adhoc plots
plot_as <- function(plt_name, ..., ext = '.png')  str_c('FACS_analysis/plots/', plt_name, ..., ext)

remove_title <- function(plot_handle) plot_handle + ggtitle(NULL, subtitle = NULL) # removes title and subtitle for plots - pdf



# Plot gated ----

# arabinose w glucose
plt.ara <- timeseries_plot(.filter_assay = 'pInt8 \\+ rGFP', .fluor = 'Green', 
                           .filter_inducer = '(0|I)$') # remove glycerol
ggsave(plot_as('S050_Ara-fraction'), width = 6, height = 3)
ggsave('FACS_analysis/plots/S050_Ara-fraction.pdf', plot = remove_title(plt.ara), width = 6, height = 3)


# arabinose w glycerol
plt.ara.glycerol <- timeseries_plot(.filter_assay = 'pInt8 \\+ rGFP', .fluor = 'Green', 
                           .filter_inducer = 'glycerol', .order_inducer = c('0-glycerol', 'I-glycerol'))
ggsave(plot_as('Archive/S050_Ara-fraction-glycerol'), width = 6, height = 3)


# AHL v0
plt.ahlv0 <- timeseries_plot(.filter_assay = 'pRV01 \\+ rGFP', .fluor = 'Green')
ggsave(plot_as('S050_AHL-v0-fraction'), width = 6, height = 3)
ggsave('FACS_analysis/plots/S050_AHL-v0-fraction.pdf', remove_title(plt.ahlv0), width = 6, height = 3)

# AHL v0
plt.ahl <- timeseries_plot(.filter_assay = 'pSS079', .fluor = 'Red', use_colour = '#9E2A2B')
ggsave(plot_as('S050_AHL-fraction'), width = 6, height = 3)
ggsave('FACS_analysis/plots/S050_AHL-fraction.pdf', remove_title(plt.ahl), width = 4, height = 3) # width 6, height 3

# Bad gate? -- check



# Exponential fitting ----

# fitting exponentials to Ara and AHL ; 
# need half lives of 3 independent fits each + do t.test on half lives Ara vs AHL

metadata_var_expfit <- c('assay_variable', 'sample_category', 'Population', 'replicate') # fit each replicate as paired

counts_for_fit <- processed_counts %>% 
  
  group_by(across(all_of(metadata_var_expfit))) %>% 
  
  filter(str_detect(sample_category, 'Induced$'), # select only induced
         # str_detect(assay_variable, 'pInt8 \\+ rGFP'), Population == 'Green' # select specific data
         ) %>%  # filter only relevant data
  
  nest() # make into nested data for fitting



# Generalized exp fitting : copied from qPCR:: S8_RAM stability.R

safe_exp_fit <- safely(.f = ~ nls(freq ~ SSasymp(day, ys, y0, log_alpha), data = .x))
# use as map(data, ~ safe_exp(.x)); tidied = map(.fit, ~ broom::tidy(.x$result)) / to avoid singular gradient error
# Source : https://aosmith.rbind.io/2020/08/31/handling-errors/

get_t_half_from_exp_fits <- function(.df)
  
{
  .df %>% 
    
    mutate( # extract parameters from fit, attach to data
      tidied = map(.fit, ~ broom::tidy(.x$result)), # extracting fitting parameters
      augmented = map(.fit, ~ broom::augment(.x$result)), # extrapolating fitting data, for plotting
      # extrapolated = map(.fit, ~ broom::augment(.x$result, newdata = extrapol_tibble)) # extrapolate when fit didn't work
    ) %>% 
    
    # unnest the model parameters
    unnest(tidied) %>% 
    
    # arrange the parameter estimate, std. error and other stuff for each paramameter in each column
    pivot_wider(names_from = term,
                values_from = c(estimate, std.error, statistic, p.value)) %>% 
    
    # produce t1/2 estimates
    mutate(t.half = log(2)* exp(-estimate_log_alpha), 
           std.error_t.half = log(2) * exp(-estimate_log_alpha) * std.error_log_alpha,
           
           t.half.text = str_c( format(t.half, digits = 2), 
                                '+/-', 
                                format(std.error_t.half, digits = 2),
                                sep = ' ')
    ) # using error propagation - https://en.wikipedia.org/wiki/Propagation_of_uncertainty#Example
  
}


# Test on specific data before generalizing / to save time
ara_exp_fits <-
  counts_for_fit %>%
  filter(str_detect(assay_variable, 'pInt8 \\+ rGFP'), Population == 'Green') %>% # filter for ara data
  
  mutate(.fit = map(data,
                    # ~ nls(freq ~ SSasymp(day, ys, y0, log_alpha), data = .x)
                    ~ safe_exp_fit(.x)
  )) %>% 
  
  get_t_half_from_exp_fits()


# Works on 1/3 curves : singular gradient error
ahl_exp_fits <-
  counts_for_fit %>%
  filter(str_detect(assay_variable, 'pRV01 \\+ rGFP'), Population == 'Green') %>% # filter for ara data
  mutate(data = map(data, ~ filter(.x, day > 2))) %>%  # truncate from d2
  
  mutate(.fit = map(data,
                    # ~ nls(freq ~ SSasymp(day, ys, y0, log_alpha), data = .x)
                    ~ safe_exp_fit(.x)
  )) %>% 
  
  get_t_half_from_exp_fits # discarding two curves ; they decay linearly rather than exp - singular gradient



# make mock data when fit fails (not tested..)
extrapol_tibble <- tibble(day = 
                            counts_for_fit$data[[1]]$day %>% range %>% {.[1]:.[2]}) 

# Make fits
normalized_with_exponential_fit <-
  
  counts_for_fit %>% 
  # filter(plasmid == 'Ribo') %>%  # select only the good curves with decreasing trend
  
  mutate(.fit = # making the exponential fit
           map(data, # SSasymp fitting y ~ ys+(y0-ys)*exp(-exp(log_alpha)*day)
               # https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/SSasymp
               
               ~ safe_exp_fit(.x) # makes a list with $result and $error
               # ~ nls(normalized_Copies_per_ul ~ SSasymp(day, ys, y0, log_alpha),
               #       data = .)
           ),
         
         
         tidied = map(.fit, ~ broom::tidy(.x$result)), # extracting fitting parameters
         augmented = map(.fit, ~ broom::augment(.x$result)), # extrapolating fitting data, for plotting
         extrapolated = map(.fit, ~ broom::augment(.x$result, newdata = extrapol_tibble))
  ) #%>% 
  
  # Get fitting parameters
  


# Statistics ----

metadata_var_stats <- c('assay_variable', 'day', 'Population') # fit each replicate as paired

counts_for_stats <- processed_counts %>% 
  
  group_by(across(all_of(metadata_var_stats))) %>% 
  
  filter( str_detect(assay_variable, '(pInt8|pRV01) \\+ rGFP'), # select specific data 
          Population == 'Green', day >= 0, # select specific data
          str_detect(sample_category, 'nduced$'), # select only normal ones (without **-Glycerol)
         
  ) %>%  # filter only relevant data
  
  nest() # make into nested data for fitting


# welch t.tests : induced vs uninduced # using in fig 3B, C
stats_on_counts <- counts_for_stats %>% 
  mutate(t_test = map(data, # t.test for alternative hypothesis [Induced - Uninduced > 0]
                      ~ t.test(freq ~ sample_category, paired = T, alternative = 'greater', data = .x)),
         
         p_val = map_dbl(t_test, ~ .x$p.value), # extract the p value
         sig = p_val <= 0.05) 

# plot distributions ----

# subset using the special condition in `7-exploratory_data_view.R` line 23
# these plots help check if gating went right for specific samples (to be concise)


# pSS079/red ----

# Subset the desired data for supplementary fig
fcsunique.subset <- subset_cytoset(non_data_stuff, specific_data, exclude_category, # use for labeling ridges' medians
                                   # optional manual filtering (additional to above)
                                   str_detect(assay_variable, '79') | str_detect(data_set, 'd-1')
)

# custom plot with gate (supplementary fig)
plt_ridges <- plot_ridges_fluor(.show_medians = F, .save_plots = F, .fluor_colour = 'red')

plt_ss79 <-
  plt_ridges$red + facet_grid(rows = NULL) + # merge into one facet
  ggtitle(str_c(title_name, '- pSS079')) + geom_vline(xintercept = 300, colour = 'red') # add title, show gate

ggsave(plot_as('Archive/S050_pSS079'), plt_ss79, width = 3, height = 6)


# Ara samples ----

# : pInt8 + rGFP / green : w glucose
fcsunique.subset <- subset_cytoset(non_data_stuff, specific_data = '.*', exclude_category, # use for labeling ridges' medians
                                   # optional manual filtering (additional to above)
                                   (str_detect(assay_variable, 'MG1655') & data_set == 'd-1') | 
                                     str_detect(assay_variable, 'pInt8 \\+ rGFP') & !str_detect(sample_category, 'glycerol')
)

plt_ridges2 <- plot_ridges_fluor(.show_medians = F, .save_plots = F, .fluor_colour = 'green')

plt_2 <- 
  plt_ridges2$green + facet_grid(rows = NULL) + # merge into one facet
  ggtitle(str_c(title_name, '- Ara')) + geom_vline(xintercept = 172.391035766601, colour = 'red') # add title, show gate

ggsave(plot_as('Archive/S050_Ara'), plot = plt_2, width = 3, height = 6)



# pRV samples ----

# : pRV01 + rGFP / green
fcsunique.subset <- subset_cytoset(non_data_stuff, specific_data = '.*', exclude_category, # use for labeling ridges' medians
                                   # optional manual filtering (additional to above)
                                   (str_detect(assay_variable, 'MG1655') & data_set == 'd-1') | 
                                     str_detect(assay_variable, 'pRV01 \\+ rGFP') & !str_detect(sample_category, 'glycerol')
)

plt_ridges3 <- plot_ridges_fluor(.show_medians = F, .save_plots = F, .fluor_colour = 'green')
plt_ridges3$green + facet_grid(rows = NULL) + # merge into one facet
  ggtitle(str_c(title_name, '- pRV01')) + geom_vline(xintercept = 172.391035766601, colour = 'red') # add title, show gate

ggsave(plot_as('Archive/S050_pRV01'), width = 3, height = 6)



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
