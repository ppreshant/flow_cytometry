notes on flow cytometry
Prashant Kalvapalle
started - 5/March/2022

# Tasks

- [x] Need to figure out how to get the `wellid` from .fcs file headers.
	- used it to name the individual files when saving them.
	- Could record these `wellid`s and put them into a column that I could use to merge metadata
- [ ] Learn how to explore a `flowworkspace::cytoset`
- [ ] Make exploratory_plots.rmd run a loop and plot each `colname` modality of data as scatter and histogram -- the file will be pretty bulky already :(


# minor tasks

Directory checking in `1-reading_multidata_fcs`
- [x] Check for empty directory to future proof when a directory exists but has no files in it
- [ ] Remove biological replicate counts from cytometry template layouts (metadata) - **justification** _Could attach the numbering in R, will save some effort while making template?, Unless you want to mark biological replicates from technical replicates, which will complicate the analysis by making more columns .. etc._  Could also think about this when multiple dilutions are read and need to be analyzed?
  
# Understanding cytoset/cytoframes

The cytoset for `S032` dataset has `13` observables, and `26` cells : I assume each observable before and after gain adjustment/filtering and such. 

- [ ] What is TIME in `fl.set %>% colnames()`? _I assume the number of cells being counted? Since the first 4 have fewer, it was because I terminated the PBS samples as they were taking too long.. _
- [ ] 