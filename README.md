# Description
The scripts are divided into two modules using python and R for each of them

## Density gating, MEFL transformation (python)
The python script `analyze_fcs_flowcal.py` and jupyter notebook `scripts_archive/flowcal_pipeline_report.py/ipnb` is a wrapper for (semi-)automated processing of flow cytometry data using FlowCal submodule from Tabor lab : https://github.com/taborlab/FlowCal/ in a standard workflow
> Castillo-Hair, Sebastian M., et al. "FlowCal: a user-friendly, open source software tool for automatically converting flow cytometry data from arbitrary to calibrated units." _ACS synthetic biology_ 5.7 (2016): 774-780.

Briefly, **this is what the python wrapper does :**
- Opens all .fcs files within the directory; identify the file for calibration beads
- Prepares the beads data for calibration into mean equivalent fluorophore units (MEFL)
- _FlowCal functions_ : Cleanup data, convert arbitrary fluorescence into MEFLs. Clean up includes
	- Gates out saturated events (low and high end)
	- Density gating for cells, to remove debris. Retains 50% events from the highest density region. This parameter can be changed by user and would be good to test : 0.3, 0.5, 0.8 fractions before running all the data
	- Retains singlet population : top 90% of the FSC-A vs FSC-H plot. This excludes any clumps of cells..
- Saves the plots showing cleanup steps for all/5 random data in `.html` from the jupyter notebook. 
- Outputs summary statistics of mean, median, mode to a .csv file
- Saves the cleaned up `.fcs` files to the `processed_data` directory. These can be analyzed by any tool of the user's choice. 
To interact with each of these steps individually and test different parameters, such as the fraction retained for density gating, use the jupyter notebook `scripts_archive/adhoc_flowcal_analysis.py/ipnb`

Note: _I save the data from flowcal for analysis by R later. Users can use any other tool they wish. The reason for this decision is that I wasn't satisfied with the analysis and plotting capabilities provided by FlowCal and I prefer ggplot to python's plots. + R has a very good general purpose flowcytometry ecocystem with many packages built upon the [`flowCore`](https://bioconductor.org/packages/release/bioc/html/flowCore.html) package; These work on `.fcs` files without keeping them in the RAM!_

## Gating, counts, plotting distributions (R)

_The R section is not fully automated yet, but it should work pretty well once you get a hang of the R commands in an hour or two. Do reach out to me by using the issues section on github if you have questions_ 

- The R section of the pipeline uses the processed data saved by flowcal. _If you wish, you can skip the cleanup in python and look at the raw data with the same R scripts as well.
- It attaches the sample names to wells from a 96-well layout in google sheet/.csv file. 
- After this R provides commands to use for gating based on a single representative `.fcs`, and broadcasts the gate to all other data. Using the  [`openCyto`](https://www.bioconductor.org/packages/release/bioc/html/openCyto.html)  package for this. 
	- Currently I use the function `openCyto::mindensity(..)` which  draws a gate threshold at the minimum density region in 1d, so is applicable when the sample has a bimodal distribution with two populations
	- Look at the documentations in `openCyto`'s [autogating](https://www.bioconductor.org/packages/release/bioc/vignettes/openCyto/inst/doc/HowToAutoGating.html) for other gating schemes in 1D and 2D. And [`flowCore`](https://bioconductor.org/packages/release/bioc/vignettes/flowCore/inst/doc/HowTo-flowCore.pdf) for `rectangleGate()` and `quadGate()`
- Calculates population statistics for all the data using [.flowWorkspace](https://bioconductor.org/packages/release/bioc/html/flowWorkspace.html) package and save data into `.csv` file 
- Plots distributions of data as highly customizable ggplots both with and without gating. The plots can be made with a one liner code using the powerful [`ggcyto`](https://www.bioconductor.org/packages/release/bioc/html/ggcyto.html) package. _Note: replicate wells with same name are merged._ Example figure with lots of customizations (no gating here) : ![[FACS_analysis/plots/S043_28-3-22-processed-ridge density-processed-red.png]]


# How to run

## First time setup
1. Setup git on your computer if you haven't already - [git helper](https://rogerdudler.github.io/git-guide/) 
2. Please clone this R-python hybrid code into your computer with the command `git clone https://github.com/ppreshant/flow_cytometry.git` or the `ssh` version `git clone git@github.com:ppreshant/flow_cytometry.git` (_which is more secure, and takes a couple mins extra setting up, but I would recommend it - here's some [help](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)_). 
	- The same folder will hold your flow cytometry data and the outputs so it can get large. Choose the folder location accordingly. 
3. For the first time, run the steps in R to to load all the required packages `install.packages('tidyverse')` ; and do the same for - 
	- reticulate
	- BiocManager
	 
	Use BiocManager to install the bioconductor packages - 
	`BiocManager::install("flowCore")` ; and others - 
	- ggcyto
	- openCyto
4. use conda to setup the python requirements : Mostly need the standard `pandas`, `matplotlib`, `numpy` etc.
	1. Install miniconda : a minimal version of the package and environment manager `conda`. use instructions from the [documentation page](https://docs.conda.io/en/latest/miniconda.html) 
	2. Use the command `conda env create -f flowcal_wrappers_environment.yaml`. _This will create an environment with the name `flowcal` and install all the python dependancies listed in the file to your conda environment_

## Data, and config
1. Put your data into the `flowcyt_data` directory.
2.  Update the files for user_inputs for both python and R: 
	1. `./0.5-user_inputs.R` : for R steps
		1. base_directory <- 'flowcyt_data' or 'processed_data'
		2. folder_name <- '..' : the folder your individual `.fcs` files are in within the base_directory
		3. file.name_input <- '..' : Use this option if you have a single `.fcs` file holding multiple data (such as from Guava machines). _After unpacking these data you will use the same name for the `folder_name` option
		4. template_source <- 'googlesheet' # use 'googlesheet' or 'excel' options depending on where you are providing the plate layout to name the wells.
	2. `scripts_general_fns/g10_user_config.py` : for python steps
		1. fcs_experiment_folder = '..' : the folder your individual `.fcs` files are in within the base_directory
		2. density_gating_fraction = .5 ; might need to adjust
3. Put sample names into the excel file `flowcyt_data/plate_layoyts.xlsx` or a google sheet. Each well with sample will have the format `plasmid1_positive`. The value after the '\_' is the `sample_category` : used to colour plots ; and the value before is `assay_variable` will be on the x/y-axis of the plots.
	- `excel` option is easier but if you would prefer to use the `googlesheet` for naming the samples, then duplicate the `Flow cytometry layouts` tab from this [sheet](https://docs.google.com/spreadsheets/d/1RffyflHCQ_GzlRHbeH3bAkiYo4zNlnFWx4FXo7xkUt8/edit#gid=2024050710) into your own googlesheet, and put its url in the `0-general_functions_fcs.R/sheeturls` for the `plate_layouts_pk` option.

-  If you have a single `.fcs` file with multiple data run and you want to run the flowCal workflow. Run the `# prelims` and `# load data` sections in the code `analyze_fcs.R`. This will unpack each individual well into a separate `.fcs` file in a folder. For subsequent steps, change the `folder_name` option to the name of the new folder and change `file.name_input` to be empty `''`. Now you can go ahead with the python module and come back the the R module.

## python module : density gating, MEFL

1. open a suitable terminal that works for `conda` and activate the `flowcal` environment that you created above with `conda activate flowcal`
2. launch your favorite IDE to access python. `jupyter-lab` should be installed in this environment, so type it's name in the same terminal and a browser window will open
3. Follow instructions in the [[#Data, and config]] above and, add your directory name etc. to the config file `scripts_general_fns/g10_user_config.py` 
4. Open the jupyter notebook `flowcal_pipeline_report.ipnb` and execute the two cells and your data should be ready in about 3 min!
.. _to be elaborated_

## R : gating and visualizations

1. Ensure that the data is in the folder and config file specific to `R` : `./0.5-user_inputs.R` is updated
2. run `source('./analyze_fcs.R')` to load the data into R
3. run `7-exploratory_data_view.R` for saving overview of all data. 
4. run `11-manual_gating_workflow.R` for gating and saving counts of populations above the gated thresholds

Do contact me if you have any questions about running this by creating an issue [here](https://github.com/ppreshant/flow_cytometry/issues)

# Copyleft : GPL-3.0-or-later license
```
wrappers for automated processing and plotting of bacterial flow cytometry data 
Copyright (C) 2023  Prashant Kalvapalle

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
```