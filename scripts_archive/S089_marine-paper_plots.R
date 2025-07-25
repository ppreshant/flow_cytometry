# S089_adhoc_plots.R

# modifying this script to plot a reduced datasaet (only S089 / exclude S089b)
# 25/July/2025 ; PK

# run analyze_fcs until line 105
# Load data into `fl.set`
# "S089_marine-SS_4" dir from 'flowcyt_data'

# custom settings ----

# make subset without the controls and some other stuff
non_data_stuff <- 'NA|Beads|beads|PBS|Chl|LB' # NA removes samples not in template
specific_data <- '.*' # use '.*' for everything ; use '51|MG1655' for specific data
exclude_category <- 'Negative' # use 'none' for selecting everything

# order the promoters for consistent ordering in the paper (take from sheet)
list_of_ordered_levels$assay_variable <- 
  readODS::read_ods('flowcyt_data/S089_sample order.ods') %>% 
  pull(Alias) |> rev()

# list the organisms
list_of_ordered_levels$sample_category <- c('Ds', 'Rd', 'Pg', 'Rp', 'Ec')

# each organism in a facet ----


# subset the fl.set according to above variables and 
# return a unique metadata + mean_median data

fcsunique.subset <- 
  subset_cytoset(fl.set, 
                 
                 non_data_stuff, specific_data, exclude_category, 
                 # optional manual filtering (additional to above)
                 # str_detect(assay_variable, '79') | str_detect(data_set, 'd-1')
  )


# run plot without saving
source('scripts_general_fns/17-plot_ridges_fluor.R') # source script
plt_ridges <- plot_ridges_fluor(.show_medians = show_medians, .save_plots = FALSE)

# facet by organism
plt_ridges$green + 
  
  # add a line for E. coli control
  geom_vline(xintercept = 1721, linetype = 'dotted') +
  
  # axis labels
  xlab('Fluorescence intensity (sf.GFP-A) (a.u.)') +

  # facet by organism (sample_category)
  facet_wrap(facets = vars(
    fct_relevel(sample_category, list_of_ordered_levels$sample_category)), 
            scales = 'free_y', ncol = 6) + 
  theme(legend.position = 'none') # remove legend/redundant

# save plot
ggsave(str_c('FACS_analysis/plots/', 
             title_name,  # title_name, 
             '-ridges-by-organism', fl_suffix, 
             '.png'),
       height = 6, width = 15) # change height and width by number of panels

# save vector plots (PDF, SVG, EPS)
fig_path <- "C:\\Users\\new\\Box Sync\\Stadler lab\\Writing\\marine_plots_pk"

ggsave(str_c(fig_path, 
             '/flowcyt_S089', 
             '.pdf'),
       height = 6, width = 15)

ggsave(str_c(fig_path, 
             '/flowcyt_S089', 
             '.svg'),
       height = 6, width = 15)

# EPS warning:
# semi-transparency is not supported on this device: reported only once per page
ggsave(str_c(fig_path, 
             '/flowcyt_S089', 
             '.eps'),
             bg = 'transparent',
       height = 6, width = 15)

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
  
  # facet by organism (sample_category)
  facet_wrap(facets = vars(sample_category), scales = 'free_y', ncol = 1) + 
  theme(legend.position = 'none') # remove legend/redundant

# save plot (overwrite)
ggsave(str_c('FACS_analysis/plots/', 
             'S089_WT-green', # overwrite above plot
             '.png'),
       height = 6, width = 5) # change height and width by number of panels


## gating ----

# Choose to gate by Pi : H07 in a (S089)
sampleNames(fl.set) %>% .[str_detect(., 'H07')] # check sample names

## summary stats on gating ----

facet_by_sample_category <- TRUE

# run 11-manual_gating_workflow with these parameters 
# skip the analysis.R sourcing in the script (since it was already run)

subset_this_file <- 'Pi_H07' # subset the data to this file


## plotting gated counts ----

# run from here if gated summary is already saved..
# get the saved gated data 

# load the saved gated data
gated_summary <- 
  read_csv(str_c('FACS_analysis/tabular_outputs/', 
                 title_name, '_gated-summary', '.csv'),
           na = '') 

# order for gated data 
promoter_order <- 
  readODS::read_ods('flowcyt_data/S089_sample order.ods') %>% 
  pull(Alias)

# Prepare for plotting : order the data, remove NAs, cleanup stuff to not plot
gated_summary <- 
  mutate(gated_summary,
         across(assay_variable, ~ fct_relevel(., promoter_order))) %>% 
  
  # remove J23100-2, WT-2 etc
  filter(!str_detect(assay_variable, 'J23100-2|WT-2|WT Chl')) %>% 
  
  drop_na(Median) # remove NAs

# plot the gated data

plt_gated_intensity <- 
  {ggplot(gated_summary, 
          aes(x = Median, y = assay_variable, size = freq, 
              label = assay_variable)) + # label is for the tooltip/interactive
      
      geom_point() + 
      geom_point(aes(x = mean_medians), shape = '|', size = 3) +
      
      # facets
      facet_wrap(vars(sample_category), scales = 'free_y') +
      
      ggtitle(title_name) # add title to plot
      } %>%  # position legend on the top 
  
  print()


# Polish the plot: log scale etc. 

plt_gated_intensity + 
  scale_y_discrete(limits = rev) + # reverse y axis order
  
  labs(y = 'Promoter', x = 'Median fluorescence (a.u.) post gating') + # change axis labels
  
  scale_x_log10(label = scales::label_log()) + # log scale x
  theme_bw() # minimal theme: white background, light gridlines, filled facet labels

# save plot
ggsave(plot_as(title_name, 'gated_intensity'), 
       height = 6, width = 8) # change height and width by number of panels


# TODO: size by freq ;  


# why are there so many J23110?
filter(gated_summary, assay_variable == 'J23100') %>% 
  view()
