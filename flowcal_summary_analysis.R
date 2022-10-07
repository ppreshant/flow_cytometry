# Grabbing the summary csv files output from python/FlowCal
# plotting across samples to see quick trend

# Prelims ----

source('./0-general_functions_fcs.R') # call the function to load libraries and auxilliary functions

source('./0.5-user_inputs.R') # gather user inputs : file name, fluorescent channel names


# User inputs ----

title_name <- str_replace(str_c(folder_name, file.name_input), '/', '')


# Load metadata ----

# Read the sample names and metadata from google sheet
sample_metadata <- get_and_parse_plate_layout(str_c(folder_name, file.name_input))

# Load data ----

flowcal_summary <- 
  read_csv(str_c(summary_base_directory, str_replace(folder_name, '/', '-summary.csv')) )  %>% 
     
     rename(filename = well) %>% 
     mutate(well = str_extract(filename, '[A-H][:digit:]+')) %>% # detect the well numbers
     
     left_join(sample_metadata)


# process data ----
metadata_variables <- c('assay_variable', 'sample_category', 'Fluorophore') # used for grouping and while making factors for ordering


processed_flowcal <- 
  pivot_longer(flowcal_summary,
               matches('-A$'),
               names_to = c('measurement', 'Fluorophore'), # split columns
               names_pattern = '(.*)_(.*)') %>% 
  pivot_wider(names_from = measurement, values_from = value) %>%  # put mean, median .. in separate columns
  
  drop_na(assay_variable) %>%  # remove empty samples : Beads, PBS etc.
  
  group_by(across(all_of(metadata_variables))) %>% # group -- except replicate
  mutate(mean_medians = mean(median)) %>%  # find the mean of replicates
  ungroup() %>% 
  
  # arrangement by median of red fluorescence in ascending order
  arrange_in_order_of_fluorophore # freeze the order of these columns for plotting
  

list_of_ordered_levels <- arrange_in_order_of_fluorophore(processed_flowcal, to_return = 'ordered')
# Use this list of ordered levels in the other code analyze_fcs

# Overview plots ----

# plot generator function : filters to custom data-subset 
plot_median_data <- function(.filter = '.*', .fluor = '.*', .remove = 'nothing', .data = processed_flowcal)
  
{
  
  # make a reduced dataset with the mean of replicates
  mean_only_data <- select(.data = .data, metadata_variables, mean_medians) %>% unique()
  
  # Plotting
  ggplot(.data %>% dplyr::filter(str_detect(assay_variable, .filter), 
                         str_detect(Fluorophore, .fluor),
                         !str_detect(sample_category, .remove)),
        
        aes(x = median, y = assay_variable, 
            colour = sample_category, fill = sample_category,
            label = biological_replicates)) +
    
    geom_jitter(width = 0, height = .3) + # plot individual replicates
    
    # plot mean as a vertical dash (for small point, use size = 0.5)
    geom_point(.data = mean_only_data,
               aes(x = mean_medians), size = 5, shape = '|', show.legend = F) + 
    
    # # add a text label for quick reference of the mean
    # geom_text(data = gfp_unique_mean,  
    #           mapping = aes(x = GFP_mean, label = GFP_mean %>% round, 
    #                         hjust = if_else(GFP_mean > max(GFP_mean)/2, 1.3, -0.3))) +  
    
    # Indicate a light grey bar for the mean - to aid the eye
    # geom_bar(aes(x = mean_medians), alpha = 0.2, stat = 'identity', #position = 'dodge',
    #          show.legend = F) +
    # Bug : using a bar with colour and fill creates wierd effects
    
    ggtitle('Median fluorescence (MEFL) : Flow cytometry') + 
    # TODO : get the units based on if calibration happened or not -- from the logfile.txt?
    
    theme(legend.position = 'top') + 
    facet_wrap(facets = 'Fluorophore', scales = 'free')
  }
# FIXTHIS: Warning message:
#   Ignoring unknown parameters: .data 

# re-plot with independent y-axis scale for better viewing
# plt.median_yfree <- 
plot_median_data(.fluor = 'mScarlet')

plotly::ggplotly(plt.median_yfree, dynamicTicks = T) # interactive plot

ggsave(plot_as(title_name), width = 5, height = 4) # save



# Individual plots ----

plot_median_data('sPK17|Dam-')
# the + needs to be escaped as \\+
ggsave(plot_as('S050_Ara'), width = 6, height = 3)
