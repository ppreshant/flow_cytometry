# read a multi data .fcs 3.0 file

read_multidata_fcs <- function(multi_data_fcs_path, ndataset = 10, 
                               transformation_key = FALSE, emptyvalue_key = FALSE,
                               
                               directory_path = NULL, # give directory path if you want the files saved
                               data_prefix = 'dataset') # prefix for the data file
{
  
  # decide path - either save files or create a temporary directory
  outpath <- if(is.null(directory_path)) {
    
    tempdir() # create a temporary directory if path is not specified
  
  } else {
      dir.create(directory_path) # create a directory to write files
    outpath = directory_path }
    
    for(i in 1:ndataset){
    # Load in each dataset as a floFrame and write it out as its own FCS
    cf <- read.FCS(multi_data_fcs_path, dataset = i, # read each file
                   transformation = transformation_key,
                   emptyValue = emptyvalue_key)
    
    write.FCS(cf, file.path(outpath, 
                            paste0(data_prefix, "_", i, ".fcs"))) # write each dataset as individual .fcs file
    }
  
  # Read the split FCS files back in to a single floSet
  fs <- read.flowSet(list.files(outpath, pattern="*.fcs", full.names = TRUE)) 
}