# 6-wrappers_utilities.R
# miscellaneous functions 

# Convenience function for plotting directory and .png suffix for adhoc plots
plot_as <- function(plt_name, ...)  str_c('FACS_analysis/plots/', plt_name, ..., '.png')

#' Generate the full sample name from the wellname : A06 Well - A06 WLSM.fcs
#' @param wellname : should have format Axx, example A06
#' @return char : 'A06 Well - A06 WLSM.fcs'
expand_wellname <- function(wellname) str_c(wellname, ' Well - ', wellname, ' WLSM.fcs')
