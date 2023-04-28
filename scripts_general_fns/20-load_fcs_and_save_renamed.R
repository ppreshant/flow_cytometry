# 20-load_fcs_and_save_renamed.R

#' Rename .fcs files using information from the metadata (/pData) and save in any directory with `write.FCS()`
#' Use case : when merging files from multiple runs to analyze together in whole or subsets w regex retrieval
#' @param : add_dir_key = T/F : whether or not to grab an additional signal of the directory name 
#' @param : interactive_session : select F if not interactive session ; will not prompt user check of ex filename
rename_fcs_and_save <- function(fcs_export_folder_name = fcs_export_dir, 
                                base_export_dir = 'processed_data/',
                                .flset = fl.set,
                                add_dir_key = TRUE, source_dir,
                                interactive_session = TRUE)
{
  
  # generate new file names ----
  
  # Generate a short key to signify the directory that the .fcs files are from 
  # looking for format (day : dx or letter after S0xx expt name)
  dir_key <- if(add_dir_key) str_match(source_dir, 'S[:digit:]+([:alpha:])')[2] # get 'b' in S0xxb ; else below
  if(!is.null(dir_key) && is.na(dir_key)) dir_key <- str_extract(source_dir, 'd-?[:digit:]+') # get day key from dx
  
  new_file_names <- 
    mutate(new_pdata,
           new_flnames = str_c(str_replace(full_sample_name, ' /', '_'), 
                               well, # unique names by well
                               dir_key, # add a key for the directory to all .fcs files within it
                               # rownames(new_pdata) %>% str_extract('^(.)'), # add plate id letter (a, b, c etc.)
                               sep = '_')) %>%
    pull(new_flnames) # get the new filenames as a vector
  
  
  # Show example filename and ask user prompt before saving : only if using interactively
  if(interactive_session)
  {
    # Show first filename for user 
    print(new_file_names[1])
    # Ask to proceed saving files or stop
    proceed_key <- 
      menu(c('Yes', 'No'), 
           title = '\n Check the example filename above;  Should I proceed to saving all files now?')
    
    if(proceed_key == 2) return(0) 
  }
    
  
  # Save files ----
  
  if(!dir.exists(fcs_export_folder_name)) # if path doesn't exist, create the directory
    dir.create(str_c('processed_data/', fcs_export_folder_name, '/')) # create the new directory

  
  # Proceed to saving all renamed .fcs files now
  new_file_names %>%   
    {str_c(base_export_dir, fcs_export_folder_name, '/', # make filepaths for all the above filenames
           ., '.fcs')} %>% # make file path
    
    {for (i in 1:length(.)) {write.FCS(fl.set[[i]], filename = .[i])}} # save each .fcs file by looping
  
  # TODO : add feature to copy the logfile, append directory name to the file name
  
}


#' load cytoset from a directory, attach metadata to pData, rename files w metadata and save to output dir
get_fcs_and_metadata <- function(.dirpath, .get_metadata = TRUE,
                                 rename_and_save_fcs = FALSE, 
                                 .interactive_session = TRUE)
{
  
  # Load .fcs ----
  
  # Read all .fcs files within the directory
  # also works with single multidata .fcs files from Guava machine : 
  # Extracts multidata .fcs file to multiple .fcs files and re-reads as as cytoset

  if(str_detect(folder_name, '_combined')) 
  {
    # Load combined dataset ----
    
    source('scripts_general_fns/18-load_combined_cytosets.R') # source script
    fl.set <- load_combined_cytosets(folder_name)
    
  } else 
  { 
    # Load regular dataset ----
    
    fl.set <- read_multidata_fcs(fl.path, # returns multiple fcs files as a flowWorkspace::cytoset
                                 fcs_pattern_to_subset = fcs_pattern_to_subset,
                                 directory_path = .dirpath)
    
    
    # metadata ----
    
    # Read the sample names and metadata from google sheet
    if(.get_metadata)
      sample_metadata <- get_and_parse_plate_layout(.dirpath)
    
    
    # attach metadata to the pData
    new_pdata <- pData(fl.set) %>% 
      mutate(well = str_extract(name, '[A-H][:digit:]+')) %>% # detect the well numbers
      rename(original_name = name) %>% # rename the "name" column
      
      left_join(sample_metadata, by = 'well') %>% # join the metadata: assay_variable, Sample_category.. 
      
      
      column_to_rownames('original_name') # remake the rownames -- to enable attachment
    
    
    pData(fl.set) <- new_pdata # replace the pData
    
    
    # rename and save workflow ----
    
    if(rename_and_save_fcs)
      
      # run the `rename_fcs_and_save()` function now ; non interactive?
    {rename_fcs_and_save(source_dir = .dirpath, interactive_session = .interactive_session)
      
    } else return(fl.set)
    
    
  }
  
  
}
