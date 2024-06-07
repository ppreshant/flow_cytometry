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


# gating analysis ----

## plot all the WTs -----

fcsunique.subset <- 
  subset_cytoset(fl.set,
                 
                 # optional manual filtering (additional to above)
                 custom_filtering = str_detect(assay_variable, 'WT$') # only WT samples
  )

source('scripts_general_fns/17-plot_ridges_fluor.R') # source script

# make ridgeline plot. Save with a different suffix
plt_ridges_wt <- 
  plot_ridges_fluor(.show_medians = show_medians, 
                    .plot_filename = 'S089_WT') 

# facet by sample category
plt_ridges_wt$green + 
  facet_wrap(facets = vars(sample_category), scales = 'free_y', ncol = 1) + # facet by organism (sample_category)
  theme(legend.position = 'none') # remove legend/redundant

# save plot (overwrite)
ggsave(str_c('FACS_analysis/plots/', 
             'S089_WT-green', # overwrite above plot
             '.png'),
       height = 6, width = 5) # change height and width by number of panels


## gating ----

# Choose to gate by Pi : H07 in a (S089)
sampleNames(fl.set) %>% .[str_detect(., 'H07')] # check sample names

## plotting gated counts ----
facet_by_sample_category <- TRUE


# run 11-manual_gating_workflow with these parameters 
# skip the analysis.R sourcing in the script (since it was already run)

subset_this_file <- 'Pi_H07' # subset the data to this file
