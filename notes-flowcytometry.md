notes on flow cytometry
Prashant Kalvapalle
started - 5/March/2022

# Reading

- [x] Read a paper that does bacterial flow cytometry to see what kind of analysis they do : _Read a bunch of Tabor papers : Castillo hair etc._
  
  
# Python/Flowcal
Advantage of flowcal
- Nice looking plots
- Built-in normalization
- Density based gating : Semi-automatic but needs a user based selection of the % of cells that should be retained
	- Check if this can be done in R too?
  
  **Tasks**
  - [x] Practicing the [flowcal tutorial](https://taborlab.github.io/FlowCal/python_tutorial)
  - [ ] Read in a bunch of `.fcs` files from given directory into a vectorized `FlowCal.io.FCSRead`
  - [ ] Vectorize the flowcal processing script by putting it in a function
  - [ ] Bring in plate layout from the google sheets
  - [ ] Convert plate layout to columns like in R -- using pandas? or a dplyr for python
  - [ ] Attach the names and make sure they appear on the plot?
  - [ ] Figure out how to compose multiple data into a matplotlib by colour etc. -- Don't know if it will work as good as ggplot; and if FlowCal does it automatically as flowworkspace
  - [ ] Plot summary stats - median..? with violin

**File handling**
- [ ] _(Guava data)_ To expand single .fcs file into multiple .fcs : use `subprocess.run` module to open an R function [use case](https://stackoverflow.com/questions/19894365/running-r-script-from-python); [documentation](https://docs.python.org/3/library/subprocess.html#subprocess.run)
- [ ] Getting plate layout google sheet : Can use the same approach to call the existing R function to do this for us
 
 **Error-handling**
 - [ ] Could have a user input if beads data gating looks acceptable before proceeding to MEFLing
 
 Literature
  - [ ] read the flowcal introduction paper to understand the data storage format and theme etc.
	  - wondering how extendable the formats are compared to the R/bioconductor ones that are building on the original FlowCore so more future proof?
  
# R/cytoset/cytoframes
Need to understand the data format a bit

The cytoset for `S032` dataset has `13` observables, and `26` cells : I assume each observable before and after gain adjustment/filtering and such. 

- [ ] What is TIME in `fl.set %>% colnames()`? _I assume the number of cells being counted? Since the first 4 have fewer, it was because I terminated the PBS samples as they were taking too long.. _
- [x] Need to figure out how to get the `wellid` from .fcs file headers. _used it to name the individual files when saving them._
	- Could record these `wellid`s and put them into a column that I could use to merge metadata
- [ ] Learn how to explore a `flowworkspace::cytoset`
- [ ] Make exploratory_plots.rmd run a loop and plot each `colname` modality of data as scatter and histogram -- the file will be pretty bulky already :(
- [ ] How to incorporate sample names into the cytoset (would be great to show up on the automatic plots)
	- Looks like you can make a data.frame of the annotations and use `pData(gating_set) <- annotations.data.frame` ([Cytometry on air, Ryan Duggan, youtube, 2014](https://youtu.be/_B7mo6dB3BU?t=2337))

**file handling**
Directory checking in `1-reading_multidata_fcs`
- [x] Check for empty directory to future proof when a directory exists but has no files in it
- [ ] Remove biological replicate counts from cytometry template layouts (metadata) - **justification** _Could attach the numbering in R, will save some effort while making template?, Unless you want to mark biological replicates from technical replicates, which will complicate the analysis by making more columns .. etc._  Could also think about this when multiple dilutions are read and need to be analyzed?
- [ ] How to get the raw-data from the cytoset to just plot mean/median _similar to how Lauren Gambill's script does with flow..python_

# R/flopR
showing error in `process_fcs` from the `get_bacteria` function.
```
[1] "2 clusters found"
[1] "only debris found"
'x' must be an object of class flowframe
``` 
Looks like this is unable to get the correct cluster when multiple are found. 
- For now, I'm moving onto using flowcal

# R/others
FlopR looks to be better than flowcal, does doublet discrimination and background subtraction as well (though it is trivial)

FlowAI does some QC truncation of data based on flow rate anomalies ([OUP, 2016](https://academic-oup-com.ezproxy.rice.edu/bioinformatics/article/32/16/2473/2240408?login=true))
- Is also useful to get the flowrates and volume estimations for our case on the sorter data
	- Need this to do CFU or cells/ml volume normalization

