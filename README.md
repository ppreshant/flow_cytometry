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
- After this R provides commands to use for gating based on a single representative `.fcs`, and broadcasts the gate to all other data. Using the  [`openCyto`](https://www.bioconductor.org/packages/release/bioc/html/openCyto.html)  package for this 
- Calculates population statistics for all the data using [.flowWorkspace](https://bioconductor.org/packages/release/bioc/html/flowWorkspace.html) package and save data into `.csv` file 
- Plots distributions of data as highly customizable ggplots. The plots can be made with a one liner code using the powerful [`ggcyto`](https://www.bioconductor.org/packages/release/bioc/html/ggcyto.html) package. Example figure : 


# How to run

## First time setup
For the first time, run the steps in R to to load all the required packages
`install.packages('tidyverse')` ; and do the same for - 
- reticulate
- BiocManager
 
Use BiocManager to install the bioconductor packages - 
`BiocManager::install("flowCore")` ; and others - 
- ggcyto
- openCyto

## Data, and config
1. Put your data into the `flowcyt_data` directory.
2.  Update the files for user_inputs for both python and R: 
	1. `./0.5-user_inputs.R` : for R steps
		1. base_directory <- 'flowcyt_data' or 'processed_data'
		2. folder_name <- '..' : the folder your individual `.fcs` files are in within the base_directory
		3. file.name_input <- '..' : Use this option if you have a single `.fcs` file holding multiple data (such as from Guava machines). _After unpacking these data you will use the same name for the `folder_name` option
	2. `scripts_general_fns/g10_user_config.py` : for python steps
		1. fcs_experiment_folder = '..' : the folder your individual `.fcs` files are in within the base_directory
		2. density_gating_fraction = .5 ; might need to adjust
3. Put sample names into the excel file `flowcyt_data/plate_layoyts.xlsx` or a google sheet. Each well with sample will have the format `plasmid1_positive`. The value after the '\_' is the `sample_category` : used to colour plots ; and the value before is `assay_variable` will be on the x/y-axis of the plots.

-  If you have a single `.fcs` file with multiple data run and you want to run the flowCal workflow. Run the `# prelims` and `# load data` sections in the code `analyze_fcs.R`. This will unpack each individual well into a separate `.fcs` file in a folder. For subsequent steps, change the `folder_name` option to the name of the new folder and change `file.name_input` to be empty `''`. Now you can go ahead with the python module and come back the the R module.

## python module : density gating, MEFL

.. _to be elaborated_


