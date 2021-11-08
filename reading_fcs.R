# flow cytometry -- beginer level
# read .fcs file, visualize data

# user inputs ----

folder_data <- 'guava_data/'

subfolder_name <- 'Marielles cyanostuff/'
file.name_input <- 'Marielle cyanostuff_2021-10-01_at_02-56-43pm' # input file name without .fcs

# Prelims ----
source('./0-general_functions_fcs.R') # call the function to load libraries and auxilliary functions


fl.path = str_c(folder_data, subfolder_name, file.name_input, '.fcs')


# Load data ----

# fl <- read.FCS(filename = fl.path,  # reading individual datasets
#                          transformation = F, 
#                          emptyValue = F, dataset = 1)

# reading multiple data sets from same file : Does not work :()

fl.set <- read_multidata_fcs(fl.path,
                          directory_path = str_c(folder_data, subfolder_name, file.name_input))

# fcs.subset <- Subset(fl.set, 'G01.fcs')

# Plotting ----

# testing simple plotting
# ggcyto::autoplot(fl.set, 'FSC-HLin')

# Plot density
pltden <- ggcyto(fl.set, aes(x = 'FSC-HLin')) + 
  geom_density(fill = 'blue', alpha = 0.3) + 
  scale_x_logicle() # some bi-axial transformation for FACS (linear near 0, logscale at higher values)

# plot scatterplots
ggcyto(fl.set, aes(x = 'FSC-HLin', y = 'SSC-HLin')) + 
  # geom_point(alpha = 0.1) + 
  geom_hex(bins = 64) + 
  scale_x_logicle() + scale_y_logicle()
