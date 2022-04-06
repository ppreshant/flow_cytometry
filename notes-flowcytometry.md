notes on flow cytometry
Prashant Kalvapalle
started - 5/March/2022

# Tasks

- [x] Need to figure out how to get the `wellid` from .fcs file headers. _used it to name the individual files when saving them._
	- Could record these `wellid`s and put them into a column that I could use to merge metadata
- [ ] Learn how to explore a `flowworkspace::cytoset`
- [ ] Make exploratory_plots.rmd run a loop and plot each `colname` modality of data as scatter and histogram -- the file will be pretty bulky already :(
- [ ] Read a paper that does bacterial flow cytometry to see what kind of analysis they do

# minor tasks

Directory checking in `1-reading_multidata_fcs`
- [x] Check for empty directory to future proof when a directory exists but has no files in it
- [ ] Remove biological replicate counts from cytometry template layouts (metadata) - **justification** _Could attach the numbering in R, will save some effort while making template?, Unless you want to mark biological replicates from technical replicates, which will complicate the analysis by making more columns .. etc._  Could also think about this when multiple dilutions are read and need to be analyzed?
- [ ] How to get the raw-data from the cytoset to just plot mean/median _similar to how Lauren Gambill's script does with flow..python_
- [ ] How to incorporate sample names into the cytoset (would be great to show up on the automatic plots)
	- Looks like you can make a data.frame of the annotations and use `pData(gating_set) <- annotations.data.frame` ([Cytometry on air, Ryan Duggan, youtube, 2014](https://youtu.be/_B7mo6dB3BU?t=2337))
  
  
# Python/Flowcal
Advantage of flowcal?
- Nice looking plots
- Built-in normalization
- Density based gating : Semi-automatic but needs a user based selection of the % of cells that should be retained
	- Check if this can be done in R too?
  
  
# R/Understanding cytoset/cytoframes

The cytoset for `S032` dataset has `13` observables, and `26` cells : I assume each observable before and after gain adjustment/filtering and such. 

- [ ] What is TIME in `fl.set %>% colnames()`? _I assume the number of cells being counted? Since the first 4 have fewer, it was because I terminated the PBS samples as they were taking too long.. _


# R/others
FlopR looks to be better than flowcal, does doublet discrimination and background subtraction as well (though it is trivial)

FlowAI does some QC truncation of data based on flow rate anomalies ([OUP, 2016](https://academic-oup-com.ezproxy.rice.edu/bioinformatics/article/32/16/2473/2240408?login=true))
- Is also useful to get the flowrates and volume estimations for our case on the sorter data
	- Need this to do CFU or cells/ml volume normalization

