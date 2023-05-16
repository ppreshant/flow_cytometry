# S050_dist_analysis.R

# S050 plot subsets ----

# subset using the special condition in `7-exploratory_data_view.R` line 23

fcsunique.subset <- subset_cytoset(non_data_stuff, specific_data, exclude_category, # use for labeling ridges' medians
                                   
                                   (str_detect(assay_variable, 'MG1655') & data_set == 'd-1') | str_detect(assay_variable, '79') # optional manual filtering (additional to above)
)

# run plotter without saving
plt_ridges <- plot_ridges_fluor(.show_medians = show_medians, .save_plots = F)

plt_ridges[[2]] + facet_grid(facets = NULL) + ggtitle(str_c(title_name, '- pSS079')) # merge facets to join MG1655 with others

ggsave(plot_as('S050_subset2-processed', '-pSS079'), width = 3, height = 6)


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

# now plot 7-exploratory..
plt_ridges <- plot_ridges_fluor(.show_medians = show_medians, .save_plots = F) # make plots and optionally save them with title_name + suffixes

plt_ridges[[1]] + facet_wrap(facets = NULL)
ggsave(plot_as(title_name, '-pRV01+rGFP'), width = 3, height = 6)
