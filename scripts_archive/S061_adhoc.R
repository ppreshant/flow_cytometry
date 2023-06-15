# S061_adhoc.R

# Subset only d2
fcsunique.subset <- subset_cytoset(non_data_stuff = 'NA|Beads|beads', exclude_category = 'd1')



# Make ridgeplot and save
plt_ridges <- plot_ridges_fluor(.show_medians = T, .save_plots = F)

plt_red <- plt_ridges$red



# gating 
gate_red_value <- 2668.32 # adhoc gating : C08 at 99 percentile

plt_red + geom_vline(xintercept = gate_red_value, colour = 'red')

ggsave(plot_as(title_name, '-ridges'), width = 4, height = 10)


# Subset only 3 WW organisms + controls

# fcsunique.subset <- subset_cytoset(exclude_category = 'd1', ... = str_detect(assay_variable, 'a4|a17|a23|Sensor|a10|M'))
fcsunique.subset <- subset_cytoset(non_data_stuff, specific_data, exclude_category = 'd1', 
                                   str_detect(assay_variable, 'a4|a17|a23|Sensor|a10|M')
)

plt_ridges <- plot_ridges_fluor(.show_medians = T, .save_plots = T)
plt_subset <- plt_ridges$red + geom_vline(xintercept = gate_red_value, colour = 'red')

plt_subset
ggsave(plot_as('S061_subset-ridges2'), plt_subset, width = 4, height = 6)
ggsave('FACS_analysis/plots/S061_subset-ridges.pdf', plt_subset, width = 4, height = 6)
