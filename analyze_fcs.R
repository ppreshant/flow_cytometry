# flow cytometry -- beginer level
# read .fcs file, visualize data

# user inputs ----

# include the trailing slash "/" in the folder paths
folder_name <- 'S044_new fusions_4-5-22/' # 'foldername/'

file.name_input <- '' # input file name without .fcs


title_name <- 'S044:mScarlet-U64 fusions_flowcyt'

Machine_type <- 'Sony' # Sony or Guava # use this to plot appropriate variables automatically


# Prelims ----
source('./0-general_functions_fcs.R') # call the function to load libraries and auxilliary functions


fl.path = str_c('flowcyt_data/', folder_name, file.name_input, '.fcs')


# Load data ----


# reading multiple data sets from .fcs file, writes to multiple .fcs files and re-reads as as cytoset

fl.set <- read_multidata_fcs(fl.path, # returns multiple fcs files as a cytoset (package = flowWorkspace)
                          directory_path = str_c('flowcyt_data/', folder_name, file.name_input))

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


# Inspecting data ----

# using FlopR : : error : 'x' must be object of class 'flowFrame'
process_fcs('flowcyt_data/S044_new fusions_4-5-22/96 Well Plate (deep)/Sample Group - 1/Unmixing-1/E01 Well - E01 WLSM.fcs',
            flu_channels = c('mScarlet-I-A'),
            do_plot = T
            )

# Gating ----



# Processing ----



# Plotting ----


# Save dataset ----


