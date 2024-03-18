# 20-load_fcs_and_save_renamed.R

#' Rename .fcs files using information from the metadata (/pData) 
#' and save in any directory with `write.FCS()`
#' Use case : For analysis of merged files from multiple runs (in whole or subsets w regex)
#' @param fcs_export_folder_name Char. name of the combined folder to export fcs data to
#' @param base_export_dir Char. base of the export directory, usually will be 'procesesed_files'
#' @param .flset `flowWorkspace::cytoset`. Set of multiple fcs files read into R
#' @param fcs_pattern_to_subset Char for regex filtering. Used to print to the logfile
#' @param add_dir_key_from_source_dirname T/F : To grab an additional signal of the directory name 
#' @param : interactive_session : prompts user check of filename before saving ; use F for automation
rename_fcs_and_save <- function(fcs_export_folder_name = fcs_export_dir, 
                                base_export_dir = base_directory,
                                .flset = fl.set,
                                fcs_pattern_to_subset = NULL,
                                add_dir_key_from_source_dirname = TRUE, source_dir, 
                                interactive_session = TRUE)
{
  
  current_pdata <- pData(.flset) # get the pData
  
  # parameters ----
  
  if(!'dir_key' %in% colnames(current_pdata)) # if dir_key column is not in the pData ; make a variable
  {
    # Generate a short key to signify the directory that the .fcs files are from 
    # looking for format (day : dx or letter after S0xx expt name)
    # if add_dir_key_from_source_dirname is FALSE, ...
    # ... it will create make dir_key = NULL and new filename won't include it
  
    dir_key <- if(add_dir_key_from_source_dirname) 
      str_match(source_dir, 'S[:digit:]+([:alpha:])')[2] # get 'b' in S0xxb ; else below
    
    if(!is.null(dir_key) && is.na(dir_key)) 
      dir_key <- str_extract(source_dir, 'd-?[:digit:]+') # get day key 
    
  }
  
  # generate new file names ----
  
  new_file_names <- 
    mutate(current_pdata,
           new_flnames = str_c(assay_variable, 
                               sample_category, 
                               # str_replace(full_sample_name, ' /', '_'), 
                               well, # unique names by well
                               dir_key, # add a key to all .fcs files within a dir / from column in pData
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
  
  # if path doesn't exist, create the directory within 'processed_data'
  str_c(base_export_dir, fcs_export_folder_name, '/') %>% 
    {if(!dir.exists(.)) dir.create(.)} 

  
  # Proceed to saving all renamed .fcs files now
  new_file_names %>%   
    {str_c(base_export_dir, fcs_export_folder_name, '/', # make filepaths for all the above filenames
           ., '.fcs')} %>% # make file path
    
    {for (i in 1:length(.)) {write.FCS(.flset[[i]], filename = .[i])}} # save each .fcs file by looping
  
  
  # copy logfile ----
  
  logfile <- str_c(base_directory, source_dir, 'processing-log.txt')
  
  if(file.exists(logfile)) 
  {
    # make a path for the logfile by appending source folder name
    dest_logfile <- str_c(base_export_dir, 
                          fcs_export_folder_name, 
                          
                          str_replace(source_dir, '/', '-'), # append the source folder name with "-"
                          'processing-log.txt')
    
    # copy the logfile to destination
    file.copy(logfile, dest_logfile)
    
    # add lines indicating the number and subset of .fcs data copied over
    cat(
      str_c('Copied (', length(new_file_names), ') files to this directory.', 
            
            # if only a subset of the directory was copied basedon regex/pattern match
            if(!is.null(fcs_pattern_to_subset)) 
              str_c(' matching regular expression :',
                    fcs_pattern_to_subset)),
      
      file = dest_logfile, 
      append = TRUE
    )
  
  }
  
  # print message
  str_c('Saved (', length(new_file_names), ') files to directory : ', fcs_export_folder_name) %>% print   
  str_c('from source : ', source_dir) %>% print # print message
  
}


#' load cytoset from a directory, attach metadata to pData, rename files w metadata and save to output dir
#' If loading a combined dataset, makes the metadata & pData from filenames (no saving/manual modify invoked)
#' @param : .get_metadata : T/F : Make F if using a common metadata (in global env) across datasets (ex: S050)
#' @param : manually_modify_pdata : T/F : pipe pData into a function for manual modification for 
#' @param : rename_and_save_fcs : T/F : Use when combining multiple datasets. Saves renamed .fcs files to a dir
#' @param : .interactive_session : T/F : Asks user to check the first filename before batch saving to dir 
#' @return fl.set, a `flowWorkspace::cytoset` that includes multiple .fcs files
#' Side effect : creates global variables: `sample_metadata` if `.get_metadata` is `TRUE`

get_fcs_and_metadata <- function(.dirpath, .get_metadata = TRUE,
                                 manually_modify_pdata = FALSE,
                                 
                                 subset_by_metadata = FALSE,
                                 non_data_stuff = 'NA|Beads|beads|PBS', 
                                 specific_data = '.*', 
                                 exclude_category = 'none',
                                 
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
      sample_metadata <<- basename(.dirpath) %>% get_and_parse_plate_layout
    
    # TODO : Make informative error if sample_metadata is absent while `.get_metadata` is FALSE
    
    
    # attach metadata to the pData
    new_pdata <- pData(fl.set) %>% 
      mutate(well = str_extract(name, '[A-H][:digit:]+')) %>% # detect the well numbers
      rename(original_name = name) %>% # rename the "name" column
      
      left_join(sample_metadata, by = 'well') %>% # join the metadata: assay_variable, Sample_category.. 
      
      # pipe into a manual modification function to change columns / add categories / bring days to `data_set`
      {if(manually_modify_pdata) manual_modify_pdata(.) else .} %>% 
      
      # remake the rownames -- compatibility to data.table : to enable attachment as pData?
      column_to_rownames('original_name')
      
    
    pData(fl.set) <- new_pdata # replace the pData
    
    
    # subset by metadata ----
    
    if(subset_by_metadata)
    {
      subset_cytoset(.flset = fl.set,
                     
                     non_data_stuff, specific_data, exclude_category, 
                     return_fcsunique.subset = FALSE)
      
      # re-name the fl.set to point to the subset
      fl.set <- fl.subset 
      # fl.subset is a global variable from the above function
      # TODO: can implement this better than using a global variable
    }

    
    # rename and save workflow ----
    
    # saves .fcs files into a "combined" folder with metadata based names
    if(rename_and_save_fcs)
      
      # run the `rename_fcs_and_save()` function now ; non interactive?
    {rename_fcs_and_save(source_dir = str_c(basename(.dirpath), '/'), 
                         .flset = fl.set, interactive_session = .interactive_session)
    } else return(fl.set)
    
    
  }
  
  
}
