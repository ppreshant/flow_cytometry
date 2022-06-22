# 6-wrappers_utilities.R
# miscellaneous functions 

# Convenience function for plotting directory and .png suffix for adhoc plots
plot_as <- function(plt_name, ...)  str_c('FACS_analysis/plots/', plt_name, ..., '.png')