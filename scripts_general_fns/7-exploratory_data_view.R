# 7-exploratory_data_view.R

# Open multiple .fcs in directory as flowset and plot density and dot plots (takes long time)

# legacy version -- backup 
# run this without the dataset argument to figure out how many data segments are in the file

# fl <- read.FCS(filename = fl.path,  # reading individual datasets
#                          transformation = F, 
#                          emptyValue = F) #, dataset = 1)


# fcs.subset <- Subset(fl.set, 'G01.fcs')

# See the variables in the data
# colnames(fl.set)

# Exploratory plotting ----

# overview plots : take a long time to show 

# Plot density of all samples in the set
pltden <- ggcyto(fl.set, 
                 aes(x = 'mScarlet-I-A'),  # plot 'YEL-HLog' for Guava
                 subset = 'A') +
  geom_density(fill = 'red', alpha = 0.3) +
  # facet_grid() + # plot overlapping stuff
  scale_x_logicle() +  # some bi-axial transformation for FACS (linear near 0, logscale at higher values)
  ggtitle(title_name)

# save plot
ggsave(str_c('FACS_analysis/plots/', 
             'S044_mScarlet-U64-fusions',  # title_name, 
             '-density', 
             '.png'),
       plot = pltden,
       height = 8, width = 10)


# FSC-SSC plot of single sample -- troubleshooting
ggcyto(fl.set[1], aes(x = 'FSC-A', y = 'SSC-A')) + 
  geom_hex(bins = 120) + 
  geom_density2d(colour = 'black') + 
  
  scale_x_logicle() + scale_y_logicle() 

# # plot scatterplots of all samples in the set
# pltscatter <- ggcyto(fl.set, aes(x = 'FSC-HLin', y = 'SSC-HLin')) +  # initialize a ggplot
#   # geom_point(alpha = 0.1) + 
#   geom_hex(bins = 64) + # make hexagonal bins with colour : increase bins for higher resolution
#   scale_x_logicle() + scale_y_logicle()
# # logicle = some bi-axial transformation for FACS (linear near 0, logscale at higher values)
# 
# # testing simple plotting : is not as customizable
# # ggcyto::autoplot(fl.set, 'FSC-HLin')
# 
# # Plot to html file using R markdown
# rmarkdown::render('exploratory_plots.rmd', output_file = str_c('./FACS_analysis/', title_name, '.html'))

