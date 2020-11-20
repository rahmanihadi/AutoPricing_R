#********************************************************************************************************************#
#                                                                                                                    #
# PrepareDatauploading                                                                                              ####
#                                                                                                                    #
# Generates the EarnixDataInfo.json required for uploading the data on an Earnix template                     #
#                                                                                                                    #
#********************************************************************************************************************#

PrepareDatauploading <- function(Brand, Product, Transaction, Source, Data_Dictionary_Location,
                                 DataFiles, DataInfoFile, DatePattern) {
  
  # Fetching all the input parameters
  
  InputParAsList <- as.list(match.call())
  if ( sum(grepl('Source', names(InputParAsList))) & length(DataFiles) >1 ){
    
    PrintComment(capture_log$prefix, 2, 2, paste0( "WARNING: Source is an Input, but there are ", length(DataFiles), " DataFiles"))
    PrintComment(capture_log$prefix, 2, 2, paste0( "WARNING: Verify all DataFiles having the same Source"))
    
  }
  
  # Possbile modifications:
  # --- the dafaframe of Data_Dictionary_Location can be an input instead of the file
    
  DD <- read.csv(Data_Dictionary_Location, stringsAsFactors = FALSE)

  data_info <- list()
  
  split_path <- function(x) if (dirname(x)==x) x else c(basename(x),split_path(dirname(x)))
  
  PrintComment(capture_log$prefix, 2, 2, paste0( "Available DataFiles: "))
  
  Nprnt <- rep(1,length(DataFiles))
  Nprnt[length(DataFiles)] <- 2
  for(i in 1:length(DataFiles)){
    
    PrintComment(capture_log$prefix, 3, Nprnt[i], paste0( as.character(i), "- ", DataFiles[i]))
    
  }
  
  PrintComment(capture_log$prefix, 3, 2, paste0("[", Sys.time(), "] Beginning (5.1) Data Info extraction"))
  file_counter <- 0
  
  for(file in DataFiles){
    
    PrintComment(capture_log$prefix, 3, 2, paste0("[", Sys.time(), "] Beginning (5.1.", file_counter,") Data Info for ", file))
    
    BaseName <- tools::file_path_sans_ext(split_path(file)[1])
    PrintComment(capture_log$prefix, 4, 1, paste0("the basename is: ",BaseName))
    SourceChk <- strsplit(split_path(file)[1], split = '_')[[1]]
    Source_Extr <- ifelse(startsWith(BaseName, 'Crunch_'), SourceChk[[2]], SourceChk[[1]])
    PrintComment(capture_log$prefix, 4, 1, paste0("the Extracted Source is: ",Source_Extr))
    
    if (Source_Extr != Source){
      
      PrintComment(capture_log$prefix, 4, 2, paste0("WARNING, the extracted Source, ", Source_Extr, "does not match the input Source, ", Source ))
      
    }
    
    if ( Source == "Aquote" ){
      
      TableName <- paste0('4. Optimisation\\\\', BaseName)
      
    } else if ( Source == "NBS" ){
      
      TableName <- paste0('1. NBS\\\\', BaseName)
      
    } else if ( Source == "RNW" ){
      
      TableName <- paste0('2. RNW\\\\', BaseName)
      
    } else if ( Source == "MTC" ){
      
      TableName <- paste0('3. MTC/MTA\\\\', BaseName)
      
    }
    
    PrintComment(capture_log$prefix, 4, 2, paste0("Table name under Earnix: ", TableName))
    
    dependents <- paste0(c(Brand, Product, Transaction, Source), collapse = ', ')
    
    PrintComment(capture_log$prefix, 4, 2, paste0("Compilation of the DD based on (Brand, Product, Transaction, Source): ", dependents))
    
    updated_dict <- UpdateDataDictionary(Brand, Product, Transaction, Source, DD)
    
    dim_ud <- paste0(dim(updated_dict), collapse = 'x')
    PrintComment(capture_log$prefix, 4, 1, paste0("The the dimension of the compiled DD is: ", dim_ud))
    
    
    variables <- colnames(read.csv(file, nrows = 1))
    
    PrintComment(capture_log$prefix, 4, 2, paste0("There are ", length(variables)  ," columns in: ", file))
    
    # perform the Earnix mapping
    
    PrintComment(capture_log$prefix, 4, 1, paste0("Performing the Earnix mapping, using columns and the updated DD"))
    
    map <- GetEarnixMapping(variables, updated_dict)
    
    # fetch the variable types
    
    PrintComment(capture_log$prefix, 4, 2, paste0("Finding the variable types, using columns and the updated DD"))
    
    types <- GetDataType(variables, updated_dict)
    
    PrintComment(capture_log$prefix, 4, 2, paste0("Variable types, are found"))
    
    info = list('dataTableFile'= file, 
      'earnixTableName'= TableName,
      'map'= map, 
      'Types'= types, 
      'datePattern'= DatePattern)
    data_info <- append(data_info, list(info))
    
    file_counter <- file_counter +1
  }  
       
  jsonlite::write_json(data_info, DataInfoFile, pretty=TRUE, auto_unbox =T)
  
  return(data_info)
  
}
