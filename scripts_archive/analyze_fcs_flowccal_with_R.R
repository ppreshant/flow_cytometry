# analyze_fcs_flowCal_with_R.R

# Pre-requisites ---- 
# All prerequisites are moved to the `.qmd` file now!

# set python to correct conda env
# Sys.setenv(RETICULATE_PYTHON = "C:/Users/new/.conda/envs/flowcal/python.exe")

# change conda env -- alternate method to above
# use_condaenv('flowcal') # causes error : unable to load shared object in Local/R/..sass.dll

# library(reticulate) # Load package

# try to add python to path
# Sys.setenv(RETICULATE_PYTHON = 'C:\\ProgramData\\Miniconda3\\python.exe') # this uses the base conda env right?


# Config ----

# import user config
config <- reticulate::import('scripts_general_fns.g10_user_config')
title_name <- config$fcs_experiment_folder # make title name for the html file naming


# Run markdown script ----

# calling quarto file

quarto::quarto_render('scripts_archive/flowcal_html_output.qmd',
                      output_file = stringr::str_c('FACS_analysis/html_outputs/', title_name, '.html'))

# calling r markdown file
# rmarkdown::render('scripts_archive/flowcal_html_output.Rmd',
#                   output_file = stringr::str_c('../FACS_analysis/html_outputs/', title_name, '.html'))
# does not work :(