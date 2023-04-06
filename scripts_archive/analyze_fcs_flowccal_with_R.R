# analyze_fcs_flowCal_with_R.R


# set python to correct conda env
Sys.setenv(RETICULATE_PYTHON = "C:/Users/new/.conda/envs/flowcal/python.exe")

# change conda env -- alternate method to above
# use_condaenv('flowcal') # causes error : unable to load shared object in Local/R/..sass.dll


# Load package
library(reticulate)

# try to add python to path
# Sys.setenv(RETICULATE_PYTHON = 'C:\\ProgramData\\Miniconda3\\python.exe') # this uses the base conda env right?

# import user config
config <- import('scripts_general_fns.g10_user_config')
title_name <- config$fcs_experiment_folder # make title name for the html file naming


# calling quarto file

quarto::quarto_render('scripts_archive/flowcal_html_output.qmd',
                      output_file = stringr::str_c('../FACS_analysis/html_outputs/', title_name, '.html'))

# Error in py_call_impl(callable, dots$args, dots$keywords) : 
#   ValueError: gfpmut3-A is not a valid channel name.

# old error : Error: .onLoad failed in loadNamespace() for 'later', details:
# call: createCallbackRegistry(id, parent_id)
# error: Can't create event loop 0 because it already exists.


# calling r markdown file
# rmarkdown::render('scripts_archive/flowcal_html_output.Rmd',
#                   output_file = stringr::str_c('../FACS_analysis/html_outputs/', title_name, '.html'))
# does not work :(