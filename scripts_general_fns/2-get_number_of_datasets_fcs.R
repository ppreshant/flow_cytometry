
get_number_of_datasets_fcs <- function(input_file_path) # provide the path of the FCS file to retrieve the number of datasets in it

{ # source : https://support.bioconductor.org/p/9135360/#9135370
  
  # get file connection : 'filename' is the local file with multiple data segments; rb = read as binary file
  fl_connection <- file(input_file_path, open = 'rb')
  
  ## relevant code taken from findOffsets as just calling the function itself doesn't return the right info
  offsets <- flowCore:::readFCSheader(fl_connection) # reading part of the TEXT section of the fcs file
  offsets <- matrix(offsets, nrow = 1, dimnames = list(NULL, names(offsets)))
  txt <- flowCore:::readFCStext(fl_connection, offsets[1, ], emptyValue = FALSE)
  
  addOff <- 0  # no clue what this is
  
  if("$NEXTDATA" %in% names(txt)) {
    nd <- as.numeric(txt[["$NEXTDATA"]]) } else {nd <- 0}
  
  txt.list <- list(txt)
  i <- 1
  
  while(nd != 0) {
    i <- i + 1
    addOff <- addOff + nd
    offsets <- rbind(offsets, flowCore:::readFCSheader(fl_connection, addOff))
    this.txt <- flowCore:::readFCStext(fl_connection, offsets[nrow(offsets),], emptyValue = FALSE)
    nd <- as.numeric(this.txt[["$NEXTDATA"]])
    txt.list[[i]] <- this.txt
  }
  
  # close the file connection
  close(fl_connection)
  
  # return number of data sets
  nDataset <- length(txt.list)
  
}
