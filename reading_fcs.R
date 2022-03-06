# flow cytometry -- beginer level
# read .fcs file, visualize data

# user inputs ----

# include the trailing slash "/" in the folder paths
folder_name <- 'guava_data/' # guava_data/ or sony_data/

subfolder_name <- 'S032 66,sPK14,15-6-7-21/'
file.name_input <- '2021-07-06_at_11-30-50am' # input file name without .fcs


title_name <- 'S032:66+48 flowcyt'


# Prelims ----
source('./0-general_functions_fcs.R') # call the function to load libraries and auxilliary functions


fl.path = str_c(folder_name, subfolder_name, file.name_input, '.fcs')


# Load data ----


# reading multiple data sets from .fcs file, writes to multiple .fcs files and re-reads as as cytoset

fl.set <- read_multidata_fcs(fl.path, # returns multiple fcs files as a cytoset (package = flowWorkspace)
                          directory_path = str_c(folder_name, subfolder_name, file.name_input))

# legacy version -- backup 
# run this without the dataset argument to figure out how many data segments are in the file

# fl <- read.FCS(filename = fl.path,  # reading individual datasets
#                          transformation = F, 
#                          emptyValue = F) #, dataset = 1)


# fcs.subset <- Subset(fl.set, 'G01.fcs')

# Exploratory plotting ----

# overview plots : take a long time to show 

# Plot density of all samples in the set
pltden <- ggcyto(fl.set, aes(x = 'FSC-HLin')) + 
  geom_density(fill = 'blue', alpha = 0.3) + 
  scale_x_logicle() # some bi-axial transformation for FACS (linear near 0, logscale at higher values)

  
# plot scatterplots of all samples in the set
pltscatter <- ggcyto(fl.set, aes(x = 'FSC-HLin', y = 'SSC-HLin')) +  # initialize a ggplot
  # geom_point(alpha = 0.1) + 
  geom_hex(bins = 64) + # make hexagonal bins with colour : increase bins for higher resolution
  scale_x_logicle() + scale_y_logicle()
# logicle = some bi-axial transformation for FACS (linear near 0, logscale at higher values)

# testing simple plotting : is not as customizable
# ggcyto::autoplot(fl.set, 'FSC-HLin')

# Plot to html file using R markdown
rmarkdown::render('exploratory_plots.rmd', output_file = str_c('./FACS_analysis/', title_name, '.html'))


# Inspecting data ----



# Gating ----



# Processing ----



# Plotting ----


# Save dataset ----


