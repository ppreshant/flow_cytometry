# read a multi data .fcs 3.0 file

# if the file was already opened into a directory of individual files, they will be read
# otherwise the multi file will be read into a directory of the same name or into a temporary directory

read_multidata_fcs <- function(multi_data_fcs_path, # path of the FCS file with multiple datasets
                               number_of_datasets = NULL,  # number of datasets if predetermined (will automatically get if NULL)
                               transformation_key = FALSE, emptyvalue_key = FALSE, # don't know what these are
                               
                               directory_path = NULL) # give directory path if you want the files saved
                              
{
  
  # key -- Should I read the multi-file .fcs or not 
  # TRUE = read multi-fcs file, write to individual files with numbering and read them back as a multi-fcs cytoset
  # FALSE = just read the individual files (which will already be present)
  read_multi_file_key = FALSE # set to TRUE if directory holding individual files is not specified / does not exist yet
  # if the directory exists, it has to be created by R hence holds the files already :: Could check for empty directory to future proof this
  
  # decide path - either save files or create a temporary directory
  if(is.null(directory_path)) {
    
    outpath <-  tempdir() # create a temporary directory if path is not specified
    read_multi_file_key = TRUE # set to TRUE
    
  } else { # if directory_path is specified
    
    # Record the path to read the individual files from now
    outpath <- directory_path # record the path of the directory
    
    
    if(!dir.exists(directory_path)) # if path doesn't exist, create the directory and load files 
    
    { dir.create(directory_path) # create a directory to write files if doesn't exist
      read_multi_file_key = TRUE # set to TRUE
    } else if(dir(directory_path) %>% length == 0) # directory is empty
      {
      read_multi_file_key = TRUE # set to TRUE
        
      }
  }
  
  if(read_multi_file_key) # if the file has to be read
  {
    
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
    
  }
    
  
  # Read the split FCS files back in to a single floSet
  fs <- flowWorkspace::load_cytoset_from_fcs(list.files(outpath, 
                                                        pattern="*.fcs", 
                                                        full.names = TRUE), # add recursive = T for Sony data-nested folders
                                             transformation = transformation_key,
                                             emptyValue = emptyvalue_key) 
}