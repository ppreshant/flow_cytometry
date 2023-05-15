# S050_dist_analysis.R

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
