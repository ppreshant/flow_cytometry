# analyze_fcs_flowCal_with_R.R

# Load package
library(reticulate)

# set python

# try to add python to path
Sys.setenv(RETICULATE_PYTHON = 'C:\\ProgramData\\Miniconda3\\python.exe')

# import user config
config <- import('scripts_general_fns.g10_user_config')
title_name <- config$fcs_experiment_folder # make title name for the html file naming


# calling r markdown file
rmarkdown::render('flowcal_html_output.Rmd', output_file = str_c('./FACS_analysis/html_outputs/', title_name, '.html'))
# does not work :(