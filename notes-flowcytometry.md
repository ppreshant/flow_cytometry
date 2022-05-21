notes on flow cytometry
Prashant Kalvapalle
started - 5/March/2022
tags: #notes


# Reading

- [x] Read a paper that does bacterial flow cytometry to see what kind of analysis they do : _Read a bunch of Tabor papers : Castillo hair etc._
  
  
# Workflow  +Which tool to use?
 1. [x] Loading files
 2. [ ] Attaching names from google sheet
 3. [ ] Processing :: _FlowCal ahead, Flop**R** working but too slow. Need to automate FlowCal, and use beads named for FlopR_
 4. [ ] Gating :: _Not really needed other than FSC-SSC gating. R workflow is more familiar right now_
 5. [ ] Plotting distribution :  Who has the better violins automated?
 6. [ ] Retrieving data :: FlowCal is easier/have Lauren's template, need to figure out in R 
 
 Let's focus on processing with FlowCal since it is faster - 14/5/22
 ~~FlopR, since R is good for the other steps - 30/4/22

  
# Python/Flowcal
Advantage of flowcal
- Nice looking plots
- Built-in normalization
- Density based gating : ~automatic but needs a user based selection of the % of cells that should be retained
	- Check if this can be done in R too?
  
  ## Tasks
  - [x] Practicing the [flowcal tutorial](https://taborlab.github.io/FlowCal/python_tutorial)
  
  - [x] Read in a bunch of `.fcs` files from given directory into a vectorized `FlowCal.io.FCSRead`
  - [ ] (_working_) Vectorize the flowcal processing script by putting it in a function / or vectorizing each step with list comprehensions
  - [ ] Bring in plate layout from the google sheets
  - [ ] Convert plate layout to columns like in R -- using pandas? or a dplyr for python
  - [ ] Attach the names (with some kind of `regex` matching) 
  
  **Plotting - matplotlib**
  - [ ] Add sample names to the plot using `plt.legend(list of names in the same order, loc = 'best')`
	  - [ ] Or figure out what variable in the .fcs file is being made the title of the plots?
    - [ ] Figure out how to compose multiple data into a matplotlib by colour etc. -- Don't know if it will work as good as ggplot; and if FlowCal does it automatically as flowworkspace
  - [ ] Plot summary stats - median..? with violin

**File handling**
- [ ] _(Guava data)_ To expand single .fcs file into multiple .fcs : use `subprocess.run` module to open an R function [use case](https://stackoverflow.com/questions/19894365/running-r-script-from-python); [documentation](https://docs.python.org/3/library/subprocess.html#subprocess.run)
- [ ] Getting plate layout google sheet : Can use the same approach to call the existing R function to do this for us
 
 **Error-handling**
 - [ ] Could have a user input if beads data gating looks acceptable before proceeding to MEFLing
 
 **Other information**
 - How do we get volume information to get cell density data (_Cells/ul_) from the .fcs file? 
	 - [ ] Is the **flow rate** recorded in the .FCS file so we can use the time units (assume seconds?) to do:  $\Large \frac{<cells>/sec}{flow rate (ul) / sec}$

**Literature**
  - [ ] read the flowcal introduction paper to understand the data storage format and theme etc.
	  - wondering how extendable the formats are compared to the R/bioconductor ones that are building on the original FlowCore so more future proof?
  
# R/cytoset/cytoframes


## data format

Need to understand the data format a bit
- The cytoset for `S032` dataset has `13` observables, and `26` cells : I assume each observable before and after gain adjustment/filtering and such. 

- [ ] What is TIME in `fl.set %>% colnames()`? _I assume the number of cells being counted? Since the first 4 have fewer, it was because I terminated the PBS samples as they were taking too long.. _
- [x] Need to figure out how to get the `wellid` from .fcs file headers. _used it to name the individual files when saving them._
	- Could record these `wellid`s and put them into a column that I could use to merge metadata
- [ ] Learn how to explore a `flowworkspace::cytoset`
- [ ] Make exploratory_plots.rmd run a loop and plot each `colname` modality of data as scatter and histogram -- the file will be pretty bulky already :(
- [ ] How to incorporate sample names into the cytoset (would be great to show up on the automatic plots)
	- Looks like you can make a data.frame of the annotations and use `pData(gating_set) <- annotations.data.frame` ([Cytometry on air, Ryan Duggan, youtube, 2014](https://youtu.be/_B7mo6dB3BU?t=2337))
	- Or `sampleNames(cytoset) <- new_values` as a vector [cytoset documentation](https://rdrr.io/bioc/flowWorkspace/man/cytoset.html)
	- How to ensure that the order of samples is matched by the replacement file name? I guess the data.frame workflow might be easier, make a new column called well

## file handling
Directory checking in `1-reading_multidata_fcs`
- [x] Check for empty directory to future proof when a directory exists but has no files in it
- [ ] Change sampleNames of the fcs set when [reading files](https://rdrr.io/bioc/flowWorkspace/man/load_cytoset_from_fcs.html) by passing a vector(?) to  
	- ``` name.keyword: An optional character vector that specifies which FCS keyword to use as the sample names. If this is not set, the GUID of the FCS file is used for sampleNames, and if that is not present (or not unique), then the file names are used. ```

- [ ] Remove biological replicate counts from cytometry template layouts (metadata) - **justification** _Could attach the numbering in R, will save some effort while making template?, Unless you want to mark biological replicates from technical replicates, which will complicate the analysis by making more columns .. etc._  Could also think about this when multiple dilutions are read and need to be analyzed?
- [ ] 

## Processing 
- [ ] How to get the raw-data from the cytoset to just plot mean/median _similar to how Lauren Gambill's script does with flow..python_

## flow rate
- Tried using the flowAI's `flow_auto_qc` but it does not work due to number of cells incompatibility
- [ ] Try the interactive method `flowiQC`
- [ ] Go into the functions of the flowAI package and fish out the one that is making the flow rate plot and use it by itself
- [ ] Calculate an avg flow rate (either all stuff or only gated cells) once you understand what the $Time variable is storing.. and its units

## data trimming/processing
Inspired from FlowCal, seeing if the processes can be mimiced. And if flopR can't do it automatically, we can incorporate it before hand or within the flopR functions..

- `RemoveMargins` : Remove margin events in flow cyt data. [PeacoQC documentation](https://rdrr.io/github/saeyslab/PeacoQC/man/RemoveMargins.html); [github](https://github.com/saeyslab/PeacoQC); 
	- > The PeacoQC package provides quality control functions that will check for monotonic increasing channels and that will remove outliers and unstable events introduced due to e.g. clogs, speed changes etc. during the measurement of your sample. It also provides the functionality of visualising the quality control result of only one sample and the visualisation of the results of multiple samples in one experiment.
- 

# R/flopR
### What exactly does flopR do?
1. Log10 transform, trim zero values (-Inf after log transf)
2. Density gating
3. **Singlet gating** ; _May not be as useful if density gating already makes it clean enough.; beads seem to matter -- compare with FlowCal_ for S044 beads
4. **Autofluorescence (geometric mean) subtraction** ; _straightforward task_
5. MEFL calculation

#### Issues 
- Is **too slow**. 5 files, with calibration takes >5 mins even failing in the beads step.
	- flowClust of the beads is the slowest step, approx 1 min ; ggplot saving is also long -- too many points?
 user | system | elapsed 
 --| --|-- 
 155.77 |  12.20 | 291.44 
- [x] Get_calibration not selecting the correct bead population. Our sample has too much junk, but the `process_fcs` that was getting bacteria and then singlets was doing ok -- so maybe short-circuit the program to do this for the beads too..

Tasks
- [x] Fixed : [issue](https://github.com/ucl-cssb/flopr/issues/8) on github!  : showing error in `process_fcs` from the `get_bacteria` function.
	```
	[1] "2 clusters found"
	[1] "only debris found"
	'x' must be an object of class flowframe
	``` 
	- this was due to a hardcoded 1e4 threshold for calling debris. I guess our FSC/SSC voltages are on the lower side, and increases them might separate out debris more easily (especially for vibrio)
- [x] Fix the hardcoded beads file : `pattern = utils::glob2rx("*beads*.fcs")`. Can make a variable to fill with the appropriate well; with this pattern as the default
- [x] Feed in the calibration data as list of lists, with proper names
- [ ] _Channel names_ : Generalize with an if loop later, _Currently hard-coded to Sony_
- [ ] Test a small dir with 5 files + beads and autofluorescence subtractor (_if even relevant for Sony_). _Running into errors : `x is empty.., negative values retained in log-transform` _

- For now, I'm moving onto using flowcal; since flopR is too slow and failing with the density plot of beads.  Decision was initially reconsidered after issue with _cells not found_ was fixed

# R/others
FlopR looks to be better than flowcal, does doublet discrimination and background subtraction as well (though it is trivial)

FlowAI does some QC truncation of data based on flow rate anomalies ([OUP, 2016](https://academic-oup-com.ezproxy.rice.edu/bioinformatics/article/32/16/2473/2240408?login=true))
- Is also useful to get the flowrates and volume estimations for our case on the sorter data
	- Need this to do CFU or cells/ml volume normalization



table 1 | table 2
--------|--------
God knows |       What does
Who is | God really?

