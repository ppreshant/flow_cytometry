# adhoc script to combine data from multiple plates ; will generalize slowly
# S063 1a, 1b, 2

# User inputs ---- 

fcs_export_folder_name <- 'S063_combined' # the combined dataset will be exported to this folder inside 'processed_data/..'
title_name <- 'S063_Marine promoters-2'

# Label x axis (assay_variable) : attaches plasmid numbers with informative names for plotting
sample_name_translation <- c('(^10.|110|119).*' = 'J23x', # 'oldnames|regex' = informative_name
                            '^HW.*' = 'H.Wang P-RBS', 
                            '^(S|P|Empty).*' = 'Salis, others',
                            '^(54|^6.|^9.|^13.|112|113).*' = 'Origins')

# Get data ----

# run general analyze_fcs.R and save each fl.set iteration as a cytoset variable to store the data to be combined
# flset1 <- fl.set
# in future this could be a map command - returning a list of cytoframes ; 
# can unlist / map rbind2 somehow (read map cheatsheet)  :https://raw.githubusercontent.com/rstudio/cheatsheets/master/purrr.pdf


# Combine data ----

# fix overlapping sample names
library(magrittr) # required for assignment pipe : "%<>%"

# walk over each flset and add a prefix to their sample names 
walk2(list(flset1, flset2, flset3),
     letters[1:3],
      ~ sampleNames(.x) %<>% {str_c(.y, '_', .)})
# TODO : add the letters into individual pData first before combining cytosets?

# combine the cytosets
fl.set <- list(flset1, flset2, flset3) %>% reduce(rbind2) %>% flowSet_to_cytoset() # combine two at a time


# Polish ----

# Add categories to pData of the superset
new_pdata <- pData(fl.set) %>% 
  
  mutate(other_category = str_replace_all(name, sample_name_translation)) # split names into categories

pData(fl.set) <- new_pdata # replace the pData


# Skip till here if loading combined cytoset directly

# Polish 2/start here ----

# get a subset of the pData to continue workflow from regular analyze_fcs.R workflow
sample_metadata <- mutate(new_pdata, filename = name) # duplicate column with 'filename' for matching


# Autodetect channels and flowworkspace_summary / run sample_metadata command above

# run from analyze_fcs.R

# Plotting ----

# use 7-exploratory_data_view to plot ridges ; then run command below to facet the plot


# determine the fig width based on # of facets
n_facets_plt = pull(fcssummary.subset, other_category) %>% unique() %>% length()

plt_ridges_facets <- 
  map(plt_ridges, # add facets
    ~ .x + facet_wrap(facets = vars(other_category), ncol = n_facets_plt,
                      scales = 'free_y')) # control facets

# save plots

map(names(fluor_chnls), # iterate over fluorescence channels
    
    ~ ggsave(str_c('FACS_analysis/plots/', 
                   title_name,  # title_name, 
                   '-', .x, 
                   '.png'),
             plot = plt_ridges_facets[[.x]], # plt_ridges
             height = est_plt_side/n_facets_plt, width = 3 * n_facets_plt) # use automatic estimate for plt sides : 2 / panel
)

# Summary stats ----

# Data export ----


# Save backup data of the superset with easier names (write.FCS)
dir.create(str_c('processed_data/', fcs_export_folder_name, '/')) # create the new directory

mutate(new_pdata,
       new_flnames = str_c(str_replace(name, ' /', '_'), 
                           well, # unique names by well
                           rownames(new_pdata) %>% str_extract('^(.)'), # add plate id letter (a, b, c etc.)
                           sep = '_')) %>%
  pull(new_flnames) %>% # get the new filenames
  
  {str_c('processed_data/', fcs_export_folder_name, '/', # make filepaths for all the above filenames
         ., '.fcs')} %>% # make file path
  
  {for (i in 1:length(.)) {write.FCS(fl.set[[i]], filename = .[i])}} # save each .fcs file by looping


# TODO : create another script to read in from these combined datasets now / check if pData is still retained!

# Save summary stats