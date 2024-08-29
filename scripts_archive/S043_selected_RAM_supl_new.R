# S043_selected_RAM_supl_new.R

# Load data into `fl.set` by running analyze_fcs till line 88 with 
# 'S043_28-3-22/' data from 'processed_data'

# source('./analyze_fcs.R')


# subset data ----

# Metada based sample filtering : to plot a subset of wells
# non_data_stuff <- 'NA'
non_data_stuff <- 'NA|Beads|beads|PBS' # NA removes samples not defined in the template
specific_data <- '48 |51 ' # use '.*' for everything ; use '51|MG1655' for specific data
exclude_category <- 'none' # use 'none' for selecting everything : experiment/data specific

# subset the fl.set according to above variables and return a unique metadata + mean_median data

fcsunique.subset <- subset_cytoset(fl.set, 
                                   non_data_stuff, specific_data, exclude_category, # use for labeling ridges' medians
                                   # optional manual filtering (additional to above)
                                   # str_detect(assay_variable, '79') | str_detect(data_set, 'd-1')
)
# Side effect : creates global variables : fl.subset, num_of_unique_samples, and est_plt_side


# Ridgeline plots ----

# Ridgeline plot - good for comparing multiple sets in a concise density plot (density is per ridge :(
# Plot is ordered in descending order of fluorescence if `list_of_ordered_levels` provided

title_name <- 'S043-subset-48,51_processed'

source('scripts_general_fns/17-plot_ridges_fluor.R') # source script
plt_ridges <- plot_ridges_fluor(.show_medians = show_medians, .save_plots = F) # make plots and optionally save them with title_name + suffixes

# show plot
plt_ridges$red

# save plot
ggsave('FACS_analysis/plots/S043-subset-48,51_processed.pdf', 
       plt_ridges$red,
       width = 4, height = 4)
