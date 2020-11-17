#********************************************************************************************************************#
#                                                                                                                    #
# PrepareDatauploading                                                                                              ####
#                                                                                                                    #
# Generates the EarnixDataInfo.json required for uploading the data on an Earnix template                     #
#                                                                                                                    #
#********************************************************************************************************************#

PrepareDatauploading <- function(Brand, Product, Transaction, DataDictionary,
  DataFiles, DataInfoFile, DatePattern) {
  
  # closeAllConnections()
  # Possbile modifications:
  # --- Print into file ... that is not clever
  # --- the dafaframe of DataDictionary can be an input instead of the file
  

  
  # Brand <- 'RAC'
  # Product <- 'PC'
  # Transaction <- 'NBS'
  # DataDictionary <- "C:/Users/HRahmaniBayegi/softs/pricing/Dictionaries/DataDictionary/Data_Dictionary_v3.6.csv"
  # DataFiles <- c("C:/Users/HRahmaniBayegi/data_test\\\\RNW_RAC_PC_NBS_ALL - Final_dummy_11.csv",
  #   "C:/Users/HRahmaniBayegi/data_test\\\\NBS_RAC_PC_NBS_ALL - Final_1.csv",
  #   "C:/Users/HRahmaniBayegi/data_test\\\\Crunch_RNW_RAC_PC_NBS_ALL - Final.csv")
  # DataInfoFile <- "C:/Users/HRahmaniBayegi/softs/pricing/AutoPricing_R/EarnixDataInfo.json"
  # DatePattern <- 'yyyy-mm-dd'
    
  PrintComment(capture_log$prefix, 2, 2, paste0("[", Sys.time(), "] Beginning (4.1) ", "Reading the DataDaictionary: ", DataDictionary))
  
  DD <- read.csv(DataDictionary, stringsAsFactors = FALSE)
  
  
  data_info <- list()
  
  split_path <- function(x) if (dirname(x)==x) x else c(basename(x),split_path(dirname(x)))
  

  # Stu_Counter <- 0

  # sink(DataInfoFile)
  
  # cat('[','\n')
  
  PrintComment(capture_log$prefix, 2, 2, paste0( "Available DataFiles: "))
  
  for(i in 1:length(DataFiles)){
    
    PrintComment(capture_log$prefix, 3, 2, paste0( as.character(i), "- ", DataFiles[i]))
    
  }
  

  for(file in DataFiles){
    
    PrintComment(capture_log$prefix, 3, 2, paste0("peparation for: ",file))
    
    BaseName <- tools::file_path_sans_ext(split_path(file)[1])
    
    PrintComment(capture_log$prefix, 4, 2, paste0("the basename is: ",BaseName))
    
    SourceChk <- strsplit(split_path(file)[1], split = '_')[[1]]
    
    Source <- ifelse(startsWith(BaseName, 'Crunch_'), SourceChk[[2]], SourceChk[[1]])
    
    PrintComment(capture_log$prefix, 4, 2, paste0("the Source is: ",Source))
    # cat('{','\n')
    # cat(paste0('"dataTableFile": "',file,'",'), "\n")
    
    if ( Source == "Aquote" ){
      
      TableName <- paste0('4. Optimisation\\\\', BaseName)
      
    } else if ( Source == "NBS" ){
      
      TableName <- paste0('1. NBS\\\\', BaseName)
      
    } else if ( Source == "RNW" ){
      
      TableName <- paste0('2. RNW\\\\', BaseName)
      
    } else if ( Source == "MTC" ){
      
      TableName <- paste0('3. MTC/MTA\\\\', BaseName)
      
    } else 
      
      print('Error: Source is wrong ... This is redundant when variable verification is performed')
    
    PrintComment(capture_log$prefix, 4, 2, paste0("Table name under Earnix: ",TableName))
    
    # cat(paste0('"earnixTableName": "',TableName,'",'), "\n")
    dependents <- paste0(c(Brand, Product, Transaction, Source), collapse = ', ')
    
    PrintComment(capture_log$prefix, 4, 2, paste0("Compilation of the DD based on: ", dependents))
    
    updated_dict <- UpdateDataDictionary(Brand, Product, Transaction, Source, DD)
    
    dim_ud <- paste0(dim(updated_dict), collapse = 'x')
    
    PrintComment(capture_log$prefix, 4, 2, paste0("The the dimension of the compiled DD is: ", dim_ud))
    
    
    variables <- colnames(read.csv(file, nrows = 1))
    
    PrintComment(capture_log$prefix, 4, 2, paste0("There are ", length(variables)  ," columns in: ", file))
    
    
    # perform the Earnix mapping
    
    PrintComment(capture_log$prefix, 4, 2, paste0("Performing the Earnix mapping, using columns and the updated DD"))
    
    map <- GetEarnixMapping(variables, updated_dict)
    
    # FakeJson('map', map)
    
    # fetch the variable types
    
    PrintComment(capture_log$prefix, 4, 2, paste0("Finding the variable types, using columns and the updated DD"))
    
    types <- GetDataType(variables, updated_dict)
    
    # print the variable type
    # FakeJson('Types', types)
    
    # cat(paste0('"datePattern": "',DatePattern,'"\n'))
    
    # Stu_Counter <- Stu_Counter + 1
    # LoopClose <- ifelse(Stu_Counter == length(DataFiles), "}\n", "},\n")
    # cat(LoopClose)
    
    info = list('dataTableFile'= file, 
      'earnixTableName'= TableName,
      'map'= map, 
      'Types'= types, 
      'datePattern'= DatePattern)
    data_info <- append(data_info, list(info))
  }  
       
  
  # cat("]")
  
  # sink()
  # closeAllConnections()
  jsonlite::write_json(data_info, 'test.json', pretty=TRUE, auto_unbox =T)
  
  return(data_info)
  
}
