# read a multi data .fcs 3.0 file

read_multidata_fcs <- function(multi_data_fcs_path, # path of the FCS file with multiple datasets
                               number_of_datasets = NULL,  # number of datasets if predetermined (will automatically get if NULL)
                               transformation_key = FALSE, emptyvalue_key = FALSE, # don't know what these are
                               
                               directory_path = NULL) # give directory path if you want the files saved
                              
{
  
  # decide path - either save files or create a temporary directory
  outpath <- if(is.null(directory_path)) {
    
    tempdir() # create a temporary directory if path is not specified
  
  } else { # if directory_path is specified
    
    if(!dir.exists(directory_path)) dir.create(directory_path) # create a directory to write files if doesn't exist
    outpath = directory_path } # record the path of the directory

  # Find the number of datasets in the FCS file
  number_of_datasets <- if(is.null(number_of_datasets)) {
    get_number_of_datasets_fcs(multi_data_fcs_path)
  }
    
    for(i in 1:number_of_datasets){
    
      # Load in each dataset as a floFrame and write it out as its own FCS
      dataset_i <- flowWorkspace::load_cytoframe_from_fcs(multi_data_fcs_path, dataset = i, # read each file
                            transformation = transformation_key,
                            emptyValue = emptyvalue_key)
      
      # get the well ID of the current dataset loaded
      wellid <- keyword(dataset_i, '$WELLID')
      
      # write the output file to a output directory or temporary directory 
      write.FCS(dataset_i, file.path(outpath, 
                                     paste0(wellid, ".fcs"))) # write each dataset as individual .fcs file
    }
  
  # Read the split FCS files back in to a single floSet
  fs <- flowWorkspace::load_cytoset_from_fcs(list.files(outpath, 
                                                        pattern="*.fcs", 
                                                        full.names = TRUE),
                                             transformation = transformation_key,
                                             emptyValue = emptyvalue_key) 
}