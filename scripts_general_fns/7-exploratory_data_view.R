# 7-exploratory_data_view.R

# Open multiple .fcs in directory as flowset and plot density and dot plots (takes long time)

# legacy version -- backup 
# run this without the dataset argument to figure out how many data segments are in the file

# fl <- read.FCS(filename = fl.path,  # reading individual datasets
#                          transformation = F, 
#                          emptyValue = F) #, dataset = 1)


# fcs.subset <- Subset(fl.set, 'G01.fcs')


# Exploratory plotting ----

# Make a subset of data to plot

samples_in_fl <- sampleNames(fl.set) # get all the sample names
# remove samples matching the regular expression :: Example row D : 'D[:digit:]+'
samples_to_include <- samples_in_fl[str_detect(samples_in_fl, 'D[:digit:]+')]  

fl.subset <- fl.set[samples_to_include] # filter out wells by regex

# for selecting a single sample
# fl.subset <- fl.set['A06 Well - A06 WLSM.fcs'] # get a single sample

# Change title name manually
# title_name <- 'S048_raw_ecoli dilutions'


# overview plots : take a long time to show 

# Plot density of all samples in the set
pltden <- ggcyto(fl.subset, # select subset of samples to plot
                 aes_string(x = as.name(ch[['red']]))#,  # plot 'YEL-HLog' for Guava bennett or Orange-G-A.. for Guava-SEA
                 # subset = 'A'
                 ) +
  geom_density(fill = 'red', alpha = 0.3) +
  facet_wrap('name', ncol = 10, scales = 'free') + # control facets
  scale_x_logicle() +  # some bi-axial transformation for FACS (linear near 0, logscale at higher values)
  ggtitle(title_name)

# save plot
ggsave(str_c('FACS_analysis/plots/', 
             title_name,  # title_name, 
             '-density', 
             '.png'),
       plot = pltden,
       height = 8, width = 20) # change height and width by number of panels


# plot scatterplots of all samples in the set

pltscatter <- ggcyto(fl.subset, # select subset of samples to plot
                     aes_string(x = as.name(ch[['red']]), y = as.name(ch[['green']]) )) +  # fluorescence channels

  # geom_point(alpha = 0.1) +
  geom_hex(bins = 64) + # make hexagonal bins with colour : increase bins for higher resolution
  scale_x_logicle() + scale_y_logicle() +
  # logicle = some bi-axial transformation for FACS (linear near 0, logscale at higher values)
  
  ggcyto_par_set(limits = list(x = c(-100, 1e4), y = c(-100, 1e4))) +
  
  facet_wrap('name', ncol = 10, scales = 'free') + # control facets
  ggtitle(title_name)


ggsave(str_c('FACS_analysis/plots/', 
             title_name,  # title_name, 
             '-scatter-subset2', 
             '.png'),
       plot = pltscatter,
       height = 8, width = 20) # change height and width by number of panels



# # testing simple plotting : is not as customizable
# # ggcyto::autoplot(fl.set, 'FSC-HLin')
# 
# # Plot to html file using R markdown
# rmarkdown::render('exploratory_plots.rmd', output_file = str_c('./FACS_analysis/', title_name, '.html'))


# (singlets) FSC-SSC plot of single sample -- troubleshooting
plt_fluor_single <- 
  {ggcyto(fl.set[3], aes_string(x = as.name(ch[['red']]), y = as.name(ch[['green']]))) + 
  geom_hex(bins = 120) + 
  geom_density2d(colour = 'black') + 
  
  scale_x_logicle() + scale_y_logicle()} %>% 
  
  print()

# custom save plot
# ggsave(str_c('FACS_analysis/plots/', 
#              'S045b',  # title_name, 
#              '-two populations-A5', 
#              '.png'),
#        plot = plt_scatter_single,
#        height = 5, width = 5)




# Gating practice ----

# practice gating on cytoframe

single_fcs <- fl.set[[3]]

# set gate
gate_quad <- openCyto:::.quadGate.tmix(single_fcs, channels = ch, K = 3, usePrior = "no")


plt_fl_single <- autoplot(single_fcs, ch[1], ch[2]) + 
  geom_density2d(colour = 'black') + 
  
  scale_x_logicle() + scale_y_logicle()

# view gate
plt_fl_single + geom_gate(gate_quad) + geom_stats()

# Gating stats



# More plotting ----

# Scatter
plt_red_scatter <- {ggcyto(single_fcs, aes_string(x = as.name(ch[['red']]), y = 'SSC-A')) + 
  geom_hex(bins = 120) + 
  geom_density2d(colour = 'black') + 
  
  scale_x_logicle()} %>% print()

plt_green_scatter <- {ggcyto(single_fcs, aes_string(x = as.name(ch[['green']]), y = 'SSC-A')) + 
  geom_hex(bins = 120) + 
  geom_density2d(colour = 'black') + 
  
  scale_x_logicle()} %>% print()


# Density
ggcyto(single_fcs, 
       aes_string(x = as.name(ch[['red']]) )#,  # plot 'YEL-HLog' for Guava bennett or Orange-G-A.. for Guava-SEA
       # subset = 'A'
) +
  geom_density(fill = 'red', alpha = 0.3) + 
  
  scale_x_logicle()
