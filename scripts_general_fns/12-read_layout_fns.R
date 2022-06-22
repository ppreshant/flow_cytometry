# 12-read_layout_fns

#' Functions to hand plate layouts and sample names
#' gets the plate layout matching the experiment name from a list in a google sheet 
#' convert 96 well grid to columns and matching well names
#' Adapted from qPCR: https://github.com/ppreshant/qPCR-analysis/blob/main/scripts_general_fns/1-reading_files_funs.R

# Gets the 96 well layout with template names matching the experiment ID from filename in a google sheet
get_template_for <- function(bait, sheet_url = sheeturls$plate_layouts_PK)
{ # Looking for WWx or Stdx - example WW21 or Std7 within the filename; Assumes plate spans from row B to N (1 row below the matching ID)
  
  # Finding the plate to be read
  plate_names_row <- googlesheets4::read_sheet(sheet_url, sheet = 'Flow cytometry layouts', range = 'C:C', col_types = 'c')
  m_row <- plate_names_row %>% unlist() %>% as.character() %>% 
    # find the row with standard beginnings matching the filename
    str_detect(., str_c('^', bait %>% str_match('^(S)[:digit:]*') %>% .[1]) ) %>% # select the S0xy digits part of the file
    # str_detect(., bait) %>% 
    which() + 1
  range_to_get <- str_c('B', m_row + 1, ':N', m_row + 9)
  
  # Eror message and terminate if plate ID is not unique
  if(length(m_row) > 1) {stop( str_c('Plate ID of :', bait, 'repeats in', paste0(m_row, collapse = ' & '), 
                                     'row numbers. Please fix and re-run the script', sep = ' ')) 
    # or if no matching plate is found
  } else if(!length(m_row)) stop( str_c('Plate ID of :', bait, 'does not match anything on the plate layout. 
    Please fix and re-run the script', sep = ' '))
  
  # read the template corresponding to the file name
  plate_template_raw <- googlesheets4::read_sheet(sheet_url, sheet = 'Flow cytometry layouts', range = range_to_get)
  
  # Convert the 96 well into a single column, alongside the well
  plate_template <- read_plate_to_column(plate_template_raw, 'Sample_name_bulk') # convert plate template (Sample_names) into a single vector, columnwise
  
}



# gets plate layout from 96 well format and parse it into individual columns
get_and_parse_plate_layout <- function(flnm)
{
  
  plate_template <- get_template_for(flnm, sheeturls$plate_layouts_PK) %>% # read samplenames from googlesheets
    
    # Parsing sample names from the google sheet table  
    separate(`Sample_name_bulk`, # Split the components of the sample name bulk by delimiters ('-', '_', '.')
             c('assay_variable', 'sample_category'),
             sep = '_') %>% 
    
    
    mutate(across('assay_variable', as.character)) %>% # useful when plasmid numbers are provided, will convert to text
    
    group_by(assay_variable, sample_category) %>% 
    mutate('biological_replicates' = row_number()) # Infer biological replicates in order of occurrence
  
  
}

# Convert the 96 well into a single column, alongside the well
read_plate_to_column <- function(data_tibble, val_name)
{ # transforms a plate reader table into a column (named after the top left cell, unless mentioned)
  # eliminates plate row,column numbering ; Select 1 row above the plate (even if it doesn't contain a label)
  
  # colnames(data_tibble) <- data_tibble[1,] # set column names as the first row
  data_tibble[,] %>% 
    pivot_longer(cols = -`<>`, names_to = 'col_num', values_to = val_name, ) %>% 
    rename(row_num = `<>`) %>% # make the first column with LETTERS A-H as row_num
    
    # format the numbers to be two digits : 01, 02 .. 10, 11, 12 
    mutate(across(col_num, ~ sprintf('%02d', as.numeric(.x)) )) %>% 
    
    unite('well', c('row_num', 'col_num'), sep = '') %>% drop_na() # merge letters and numbers into 'well'
}