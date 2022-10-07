notes on flow cytometry
Prashant Kalvapalle
started - 5/March/2022
tags: #notes

# Reading

Read papers that does bacterial flow cytometry to see what kind of analysis they do : _Read a bunch of Tabor papers : Castillo hair etc._
- [Sexton et al, MSB, 2020](https://www.embopress.org/doi/full/10.15252/msb.20209618) "Multiplexing cell‐cell communication." _Molecular systems biology_ 16.7 (2020): e9618.
	- 60% SSC threshold ; 20,000–30,000 _E. coli_-sized events were recorded; 85% events density gated
- [Sebastian, 2019](https://www-nature-com.ezproxy.rice.edu/articles/s41589-019-0286-6) Schmidl, Sebastian R., et al. "Rewiring bacterial two-component systems by modular DNA-binding domain swapping." _Nature Chemical Biology_ 15.7 (2019): 690-698.
	- 35% SSC threshold ; 20,000 events ; 30% density retained : Nice image showing gating workflow (S15)
	- Combined histograms of 3 replicates after gating
	- Tried B. subtilis, S oneidensis; used geometric mean?; combines separate day replicates for histograms; Took avg (arithmetic?) of 3 replicates' geometric mean for 
- [Klümper, Uli, et al. 2015](https://www-nature-com.ezproxy.rice.edu/articles/ismej2014191) "Broad host range plasmids can invade an unexpectedly diverse fraction of a soil bacterial community." _The ISME journal_ 9.4 (2015): 934-945.
	- Sorting: 0.1% to 82% enrichment fast sorting; second 100% sorting, 10,000 cells : 2,000 eps speed

## tutorials
Full tutorial (_flowcore, ggcyto_): https://jchellmuth.com/posts/FACS-with-R/
[openCyto](https://bioconductor.org/packages/devel/bioc/vignettes/openCyto/inst/doc/HowToAutoGating.html#1D_gating_methods) automatic gating schemes
[ggcyto](https://www.bioconductor.org/packages/release/bioc/vignettes/ggcyto/inst/doc/Top_features_of_ggcyto.html#1:_suppoort_3_types_of_plot_constructor) plotting help, adding gates, axis limits

# Which tool to use?
 1. [x] Loading files
 2. [ ] Attaching names from google sheet :: R done, python can [try](https://www.analyticsvidhya.com/blog/2020/07/read-and-update-google-spreadsheets-with-python/)
 3. [ ] Processing :: _FlowCal ahead, ~~Flop**R** working but too slow~~. Need to automate FlowCal, ~~and use beads named for FlopR_~~
	 - FlowCal lets you pre-trim data before automatic clustering and MEFLing, FlopR does not currently
 4. Gating :: _Useful for determining % of population that is red etc. R/flopR workflow is more familiar right now_
	 - (_verify_) Neither have a nice gating heirarchy, but R's flowworkset has good ones for gating and stats
 5. Plotting distribution :  Who has the better violins automated? FlowCal : violins, _but without sample name_ and matplotlib is not compositional like ggplot; flopr -- check
 6. Retrieving summary stats :: `FlowCal.stats` module Python, `flowWorkspace::gs_pop_get_count_fast()` in R

## Other considerations
1. Run-time
	- _FlowCal_ : Run time for single .fcs ~ 9-10 sec with plotting and 1 sec without plotting. using `%timeit -n 1 -r 1 _process_single_fcs(..)`. For full workflow of 4 files + beads calibration = 23.4 sec (without plotting calibration details)
	- _FlopR_ : ~ 1 min per sample ; maybe turn plotting off? Which step takes the most time?
2. What kind of stats do we want from data? 
	- (S048 mainly) % and numbers of cells in red high, red low and gr .. 
	- Other expts : distributions of fcs data plotted 
3. Can we skip MEFL calibration for certain experiments? -  _Especially if only population fraction in a gate is desired (S048)?_ Could stay within R if doing this -

## Conclusions
 - 10/6/22 : Use adhoc R openCyto, flowWorkspace - for S048 data -- flowcal is discarding useful data. *Re-calibrate FlowCal to retain more events (~ >80%) in the future?*
 - 14/5/22 : Let's focus on trim-mefl processing with FlowCal since it is faster 
 - 30/4/22 : ~~FlopR, since R is good for the other steps - 



# Ideal workflow
Script in rmd
1. R script loads google sheet names
2. python script for calibration w flow cal
	- [x] Pass variable of which well(s) are beads; Save the calibrated data to .fcs again
	1. Can't proceed to next step .. Figure out a way to beautify the existing plot; Ask John Sexton for custom code
3. Re-read processed fcs, attach names and condense replicates
4. plot using ggcyto + geom_violin/ggridges


# Running flowcytometer
- [ ] Check with Harsha: Issues with clogs/air from Vibrio?
Running vibrio through the machine seems to clog the SEA Sony in BRC. Even beads have air issues with these sample sets (S0045, S045b) and the data looks like this with SSC around 0 ; but beads run on the same day in S046 are fine..
- How old are the cells? vibrio are known to aggregate- _Swetha says_ ; Especially true if they are in stationary phase right?

![[Pasted image 20220530125021.png]]


# Python/Flowcal
Advantage of flowcal
- Nice looking plots to show transformations, ex: gated vs full samples, MEFLing
- Built-in normalization
- Density based gating : ~automatic but needs a user based selection of the % of cells that should be retained
	- Check if this can be done in R too?

## Bugs
- [ ] Code: input() function called from within a module in jupyterlab does not work. See `analyze_fcs_flowcal`/Line 121 for beads with low events
- [x] _(fixed now) Looks like singlet gating is using the wrong y axis- should be FSC-H? 
  
## Tasks
- [x] Practicing the [flowcal tutorial](https://taborlab.github.io/FlowCal/python_tutorial)

- [x] Read in a bunch of `.fcs` files from given directory into a vectorized `FlowCal.io.FCSRead`
- [x] (_working_) Vectorize the flowcal processing script by putting it in a function / or vectorizing each step with list comprehensions
- [x] (_connecting through R better_) : Bring in plate layout from the google sheets, Convert plate layout to columns like in R -- using pandas? or a dplyr for python, Attach the names (with some kind of `regex` matching) 


### Plotting - matplotlib
  - [ ] Add sample names to the plot using `plt.legend(list of names in the same order, loc = 'best')`
	  - [ ] Or figure out what variable in the .fcs file is being made the title of the plots?
    - [ ] Figure out how to compose multiple data into a matplotlib by colour etc. -- Don't know if it will work as good as ggplot; and if FlowCal does it automatically as flowworkspace
  - [ ] Plot summary stats - median..? with violin along with sample names: [docs matplotlib](https://matplotlib.org/stable/gallery/statistics/customized_violin.html#sphx-glr-gallery-statistics-customized-violin-py)

### File/fcs handling
- [ ] _(Guava data)_ To expand single .fcs file into multiple .fcs : use `subprocess.run` module to open an R function [use case](https://stackoverflow.com/questions/19894365/running-r-script-from-python); [documentation](https://docs.python.org/3/library/subprocess.html#subprocess.run)
- [ ] Getting plate layout google sheet : Can use the same approach to call the existing R function to do this for us
- [ ] Merge data for replicates : as simple as ndarray.concatenate? do before plotting violins/ distributions 
	> All fluorescence histograms shown are composed of three histograms taken from samples on three separate days and combined into 128 logarithmically spaced bins between 101–106 MEFL units (Supplementary Fig. [15c](https://www-nature-com.ezproxy.rice.edu/articles/s41589-019-0286-6#MOESM1)) unless otherwise stated. *[Source](https://www-nature-com.ezproxy.rice.edu/articles/s41589-019-0286-6): Schmidl, Sebastian R., et al. "Rewiring bacterial two-component systems by modular DNA-binding domain swapping." _Nature Chemical Biology_ 15.7 (2019): 690-698.*

- [x] Saving output .fcs: Idea - from `FCSData/numpy ndarray` use [fcswrite](https://github.com/ZELLMECHANIK-DRESDEN/fcswrite) to convert to .fcs 3.0 file. Can write [any numpy array](https://github.com/ZELLMECHANIK-DRESDEN/fcswrite/blob/master/examples/numpy2fcs.py). For metadata etc, can convert to the data format used by [fcsparser](https://pypi.org/project/fcsparser/) or [flowcytometry tools](https://pypi.org/project/FlowCytometryTools/) which are alluded to in fcswrite documentation.
	- solved : ~~`Error:` ValueError - `If odd number of keys + values detected (indicating an unpaired key or value).` due to duplicates in HEADER and TEXT
 
### Error-handling
 - [ ] Could have a user input if beads data gating looks acceptable before proceeding to MEFLing

### Gating
- [x] Make a variable for density gating percentage, 
	- [ ] (_fancy) get it from user input after showing a plot of 50%, interactive analysis.?_


### Other information
 - How do we get volume information to get cell density data (_Cells/ul_) from the .fcs file? 
	 - [ ] Is the **flow rate** recorded in the .FCS file so we can use the time units (assume seconds?) to do:  $\Large \frac{<cells>/sec}{flow rate = (ul/ sec)}$

### Quality controls
- [x] Write an output log file as `.txt` in the output folder - include the initial event count, density fraction gated, final event fraction, _calibrated or not_, what beads file was used
- [ ] Show the number of (_final gated?_) events in all files loaded -- look for anomalies? _some automated metric with a warning would be nice, looking through each file would be tedious, unless.. below _
	- [ ] Implement a QC data output - count the number of cells in each gating step for every .fcs file and save as csv file -- _and_/Or make a plot to help look for anomalies?


### html output
- [ ] convert to Quarto document with jupytext : _Advantages_
	1. Make the saved html file after the folder name
	2. Run through R studio and integrate with the later plotting code..?
- [ ] Also convert to pluto and see if we can slowly inject julia for practice?
- [x] Add a separator between output of individual well plots '----' and print the well name maybe? 
	- [x] Separate the beads from the data files
	- [x] split into functions that can be run independantly too --
- [x] _option to_ Save plots along the gating procedure for the first 3 (_or 3 random_) `.fcs` files? _better than showing for all right?_
- [x] Would it be worthwhile to save all plots along the gating process for each file in the dataset for manual QC purposes -- a RMD style html output would be good
	- [x] How do we dump the plots from each .fcs file from within the loop into an RMD output? _using jupyter-notebook_
	- (_can't use since subplots are already made by `FlowCal.plots`_) Can squeeze into a pdf by doing subplots - [source](https://stackoverflow.com/a/41277685/9049673) 
	- [x] Would a pluto notebook (_or jupyter notebook_) work for calling the python script and collecting all the plots generated?

**Literature**
  - [ ] read the flowcal introduction paper to understand the data storage format and theme etc.
	  - wondering how extendable the formats are compared to the R/bioconductor ones that are building on the original FlowCore so more future proof?

**Data display**

Nice plot from tabor lab, 4c : Schmidl, Sebastian R., et al. "Rewiring bacterial two-component systems by modular DNA-binding domain swapping." [_Nature Chemical Biology_](https://www-nature-com.ezproxy.rice.edu/articles/s41589-019-0286-6#Fig3) 15.7 (2019): 690-698.

![[Pasted image 20220526020446.png]]

# R/cytoset/cytoframes

## Packages/tools
- flowCore : core data format (flowFrame et.)
- [flowWorkspace](https://www.bioconductor.org/packages/release/bioc/vignettes/flowWorkspace/inst/doc/flowWorkspace-Introduction.html#01_Purpose) : gating and operations on facs : 
> samples, groups, transformations, compensation matrices, gates, and population statistics in the gating tree, which is represented as a `GatingSet` object in `R`. 
- [openCyto](https://bioconductor.org/packages/devel/bioc/vignettes/openCyto/inst/doc/HowToAutoGating.html) - Automated gating functions and workflows for serial gating

## data format

Need to understand the data format a bit
flowframe/cytoframe = single files ; set = set of files. cyto - stores data in C for efficiency 
- The cytoset for `S032` dataset has `13` observables, and `26` cells : I assume each observable before and after gain adjustment/filtering and such? 

- [ ] What is TIME in `fl.set %>% colnames()`? _Time is recorded as each event passes through._. _Since the first 4 in S032 have fewer, it was because I terminated the PBS samples as they were taking too long.._
- [x] Need to figure out how to get the `wellid` from .fcs file headers. _used it to name the individual files when saving them._
	- Could record these `wellid`s and put them into a column that I could use to merge metadata
- [ ] Learn how to explore a `flowworkspace::cytoset`
- [ ] Make exploratory_plots.rmd run a loop and plot each `colname` modality of data as scatter and histogram -- the file will be pretty bulky already :(
- [ ] How to incorporate sample names into the cytoset (would be great to show up on the automatic plots)
	- Looks like you can make a data.frame of the annotations and use `pData(gating_set) <- annotations.data.frame` ([Cytometry on air, Ryan Duggan, youtube, 2014](https://youtu.be/_B7mo6dB3BU?t=2337))
	- Or `sampleNames(cytoset) <- new_values` as a vector [cytoset documentation](https://rdrr.io/bioc/flowWorkspace/man/cytoset.html)
	- How to ensure that the order of samples is matched by the replacement file name? I guess the data.frame workflow might be easier, make a new column called well

## file handling
Implement a regex command to capture files from multiple directories (S050 - multiday expt). 
- [ ] How to solve the problem of non unique names?
- [ ] Attach the names from the template to cytoset? `cf_rename_channel(x, old, new)`. _there is non uniqueness here too -- need to merge before attaching names_

### Questions :
- [ ] _Scaling_: Do we need to do any non default transformation (such as Pn6 scaling - power transform for parameters stroed on a log scale) : 
	- _keyword(single_fcs) and element P1D shows "Logarithmic,6,1"_ 
	- does that mean the data needs to be log transformed and is this done by the default linearize option?  
	- Ref [documentation](https://rdrr.io/bioc/flowWorkspace/man/load_cytoframe_from_fcs.html) for `load_cytoframe_from_fcs`

Directory checking in `1-reading_multidata_fcs`
- [x] Check for empty directory to future proof when a directory exists but has no files in it
- [ ] Change sampleNames of the fcs set when [reading files](https://rdrr.io/bioc/flowWorkspace/man/load_cytoset_from_fcs.html) by passing a vector(?) to  
	- ``` name.keyword: An optional character vector that specifies which FCS keyword to use as the sample names. If this is not set, the GUID of the FCS file is used for sampleNames, and if that is not present (or not unique), then the file names are used. ```

- [ ] Remove biological replicate counts from cytometry template layouts (metadata) - **justification** _Could attach the numbering in R, will save some effort while making template?, Unless you want to mark biological replicates from technical replicates, which will complicate the analysis by making more columns .. etc._  Could also think about this when multiple dilutions are read and need to be analyzed?
- [ ] Equalize processing for Guava vs Sony :: use alias feature to harmonize names to green/red or fluorophores.. `#manually supply the alias vs channel options mapping as a data.frame` in [read.FCS](https://rdrr.io/bioc/flowCore/man/read.FCS.html)

## Processing 
- [ ] why does `R/flowWorkspace`'s calculation have positive medians vs negative medians for `python/FlowCal`'s median calculation and output -- happens only for a few samples but needs to be sorted if using data from both sources  ![[Pasted image 20221006162045.png |1000]]
- [x] (_use ggcyto for plotting, no need to get raw data out_) How to get the raw-data from the cytoset to just plot mean/median _similar to how Lauren Gambill's script does with flow..python_
- [ ] Break the processing modules into functions that can be called interactively _ex: while figuring out the correct density fraction etc._
- [x] (_ggcyto is already merging them_) Merge data from biological replicates (_as mentioned in paper_) : ideas [CytoTree](https://rdrr.io/bioc/CytoTree/man/runExprsMerge.html) ; post issue in [flowWorkspace](https://github.com/RGLab/flowWorkspace/issues) or flowCore?
	> CombineFCS; This function can be used to combine 2 FCS files having a set of shared markers and return one FCS file (matrix) with the total number of cells is equal to the summation of cells in both FCS files, with each cell has an extended number of measured markers. [CyTOFmerge](https://github.com/tabdelaal/CyTOFmerge)

## flow rate
- Tried using the flowAI's `flow_auto_qc` but it does not work due to number of cells incompatibility
- [ ] Try the interactive method `flowiQC`
- [ ] Go into the functions of the flowAI package and fish out the one that is making the flow rate plot and use it by itself
- [ ] Calculate an avg flow rate (either all stuff or only gated cells) once you understand what the $Time variable is storing.. and its units

## data trimming/processing
Inspired from FlowCal, seeing if the processes can be mimiced. And if flopR can't do it automatically, we can incorporate it before hand or within the flopR functions..

## Gating
- [ ] Is there a `flowWorkspace` way to gate (quad gate..?) on a single sample and use the same gating parameters across all samples?
	- [x] (_use biexp_): `mindensity` gate value causes convergence problems with logicle transform
- [ ] figure out how to add filterID with mindensity

- `RemoveMargins` : Remove margin events in flow cyt data. [PeacoQC documentation](https://rdrr.io/github/saeyslab/PeacoQC/man/RemoveMargins.html); [github](https://github.com/saeyslab/PeacoQC); 
	- > The PeacoQC package provides quality control functions that will check for monotonic increasing channels and that will remove outliers and unstable events introduced due to e.g. clogs, speed changes etc. during the measurement of your sample. It also provides the functionality of visualising the quality control result of only one sample and the visualisation of the results of multiple samples in one experiment.

## Plotting
- The `name` column of the `pData` appears as facets ; and samples with same name are merged before plotting (verified for histograms)
- [x] (_fixed using_ `aes_string(as.name(ch))`) Pass channel names stored in a variable (by reference) to the ggcyto aes call does not work easily -- something about (quasi)quotation?
- [ ] _Error:_ `xlim(c(-100, 1e3))` not working on ggcyto + geomhex + geomdensity2d plot
- [x] _changing title of the plots_ : do it manually for now
- [x] _Replicates merge:_ ggcyto automatically merges replicates!

## Git organization
For manual scripts with possible changes across experiments, should they be in a separate branch for each dataset used vs copying over into different files? _until of course, the script is eventually broken into functions that don't change across expts._
`11-manual_gating.R -> S048..`
- Branch : new universal changes can be ported by merging main into branch (moving the branch along; but manually rejecting experiment specific changes) ; Static branch should be in a working state ; retains history
- Copy : (universal) Changes in everything other than the current file will be retained but could break the code. _breaking has not happened so far for qPCR files where I apply this philosophy_ using fucntions from general code
 - branch + copy single file: doing both could enable mergeability, cause confusion too? -- _thinking too much.. go do some actual work now_


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
	- Put a profiler to figure out where it is being slowed down, and how to improve it.. 

 user | system | elapsed 
 --| --|-- 
 155.77 |  12.20 | 291.44 

- Some error when processing beads -- 

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

# Julia/python

Notes to reproduce running python scripts inside Pluto notebooks as a way to capture output plots in a nice html format - 21/5/22

## Setting up Julia -> python
- Load julia with `julia` in the gitbash terminal
- Create new julia environment using `]` then `activate .` 
- Add packages with `add ..` : Added `Pluto`, `Plots`, `PyCall`
- load package with `using PyCall`. following [PyCall documentation](https://github.com/JuliaPy/PyCall.jl)
- Add python of the desired conda environment to path variable `ENV["PYTHON"] = "C:/Users/new/.conda/envs/flowcal/python.exe"` 
- Load Pkg with `using Pkg` and build PyCall (_need to do everytime the path changes or any major changes are made_) with `Pkg.build("PyCall")`

Error
- `from scripts_general_fns.g3_python_utils_facs import *` causes `ModuleNotFoundError("No module named 'scripts_general_fns'")`
- Same error in jupyter-lab
- Looks like you need empty `__init__.py` files within subdirectories where the modules are located (or all dirs starting from the closest path in `sys.path`)

# Jupyter-lab - to save html of plots
- Idea: have the base python code as a standalone runnable script. and call the `..py` from jupyter or pluto when you need the plots to be saved.


# Notes of individual analyses
## S050
Noticed that name of fluophores: _gfpmut3, mcherry2_ names are not showing up in channel names on d0/d1/d8 data. Did we forget to unmix or something else gone wrong? 
- Is the fluor data completely missing? _Confirmed in the Sony software: Happens when the spectrum does not show up, implying that compensation removes the fluorescenc channels from the data_
- Check sizes for comparable number of samples : data for d-1 has gfpmut3 and mcherry2 channels
	
data | # samples | size | Notes
-----| ------------| -----|------------------
S048 |  35 |         164 MB|
S050.d8| 78 | 80 MB | definitely missing data :( 
S052 | 33 | 53 MB |  mGL, mSc present; Maybe less off target events due to thresholding on SSC instead of FSC?
* S052 PBS wells were missing the fl channels and preventing making of cytoset.. Could this property have been carried over from the S050 dataset?

> `> colnames(fl.set) # vector
[1] "FSC-A" "FSC-H" "FSC-W" "SSC-A" "SSC-H" "SSC-W" "TIME" `

in comparison, S048 gives
> [1] "FSC-A"               "FSC-H"               "FSC-W"               "SSC-A"               "SSC-H"               "SSC-W"              
 [7] "mGreenLantern cor-A" "mGreenLantern cor-H" "mGreenLantern cor-W" "mScarlet-I-A"        "mScarlet-I-H"        "mScarlet-I-W"       
[13] "TIME"

