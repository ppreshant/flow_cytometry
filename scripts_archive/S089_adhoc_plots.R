# S089_adhoc_plots.R

# run analyze_fcs until line 105

# each organism in a facet ----

# make subset without the controls
non_data_stuff <- 'NA|Beads|beads|PBS' # NA removes samples not defined in the template
specific_data <- '.*' # use '.*' for everything ; use '51|MG1655' for specific data
exclude_category <- 'Negative' # use 'none' for selecting everything : experiment/data specific

# subset the fl.set according to above variables and return a unique metadata + mean_median data

fcsunique.subset <- subset_cytoset(fl.set, 
                                   non_data_stuff, specific_data, exclude_category, # use for labeling ridges' medians
                                   # optional manual filtering (additional to above)
                                   # str_detect(assay_variable, '79') | str_detect(data_set, 'd-1')
)

# run plot without saving
source('scripts_general_fns/17-plot_ridges_fluor.R') # source script
plt_ridges <- plot_ridges_fluor(.show_medians = show_medians, .save_plots = FALSE)

# facet by organism
plt_ridges$green + 
  facet_wrap(facets = vars(sample_category), scales = 'free_y', ncol = 6) + # facet by organism (sample_category)
  theme(legend.position = 'none') # remove legend/redundant

# save plot
ggsave(str_c('FACS_analysis/plots/', 
             title_name,  # title_name, 
             '-ridges-by-organism', fl_suffix, 
             '.png'),
       height = 6, width = 20) # change height and width by number of panels
