#********************************************************************************************************************#
#                                                                                                                    #
# PrepareDatauploading                                                                                              ####
#                                                                                                                    #
# Generates the EarnixDataInfo.json required for uploading the data on Earnix                      #
#                                                                                                                    #
#********************************************************************************************************************#

PrepareDatauploading <- function(Brand, Product, Transaction, DataDictionary,
  DataFiles, DataInfoFile, DatePattern) {
  
  closeAllConnections()
  # Possbile modifications:
  # --- Print into file ... that is not clever
  # --- the dafaframe of DataDictionary can be an input instead of the file
  
  source('C:/Users/HRahmaniBayegi/softs/pricing/AutoPricing_R/UpdateDataDictionary.R')
  source("C:/Users/HRahmaniBayegi/softs/pricing/AutoPricing_R/GetEarnixMapping.R")
  source("C:/Users/HRahmaniBayegi/softs/pricing/AutoPricing_R/GetDataType.R")
  source("C:/Users/HRahmaniBayegi/softs/pricing/AutoPricing_R/FakeJson.R")
  
  Brand <- 'RAC'
  Product <- 'PC'
  Transaction <- 'NBS'
  DataDictionary <- "C:/Users/HRahmaniBayegi/softs/pricing/Dictionaries/DataDictionary/Data_Dictionary_v3.6.csv"
  DataFiles <- c("C:/Users/HRahmaniBayegi/data_test\\\\RNW_RAC_PC_NBS_ALL - Final_dummy_11.csv", 
    "C:/Users/HRahmaniBayegi/data_test\\\\NBS_RAC_PC_NBS_ALL - Final_1.csv", 
    "C:/Users/HRahmaniBayegi/data_test\\\\Crunch_RNW_RAC_PC_NBS_ALL - Final.csv")
  DataInfoFile <- "C:/Users/HRahmaniBayegi/softs/pricing/AutoPricing_R/EarnixDataInfo.json"
  DatePattern <- 'yyyy-mm-dd'
    
  print("Create Earnix data info files \n")  
  
  DD <- read.csv(DataDictionary, stringsAsFactors = FALSE)
  
  data_info <- list()
  
  split_path <- function(x) if (dirname(x)==x) x else c(basename(x),split_path(dirname(x)))
  
  # For the print into file (that is not clever ... )
  
  Stu_Counter <- 0

  sink(DataInfoFile)
  
  cat('[','\n')

    for(file in DataFiles){
      
      BaseName <- tools::file_path_sans_ext(split_path(file)[1])
    
      SourceChk <- strsplit(split_path(file)[1], split = '_')[[1]]
      
      Source <- ifelse(startsWith(BaseName, 'Crunch_'), SourceChk[[2]], SourceChk[[1]])
      
      # for print into file ... think of a more clever way !!!
      
      cat('{','\n')
      cat(paste0('"dataTableFile": "',file,'",'), "\n")
    #
    
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
    
    # for print into file ... think of a more clever way !!!
    
    cat(paste0('"earnixTableName": "',TableName,'",'), "\n")
    
    updated_dict <- UpdateDataDictionary(Brand, Product, Transaction, Source, DD)
    
    variables <- colnames(read.csv(file, nrows = 1))
    
    # perform the Earnix mapping
    
    map <- GetEarnixMapping(variables, updated_dict)
    
    FakeJson('map', map)

    # fetch the variable types
    
    types <- GetDataType(variables, updated_dict)
    
    # print the variable type
    FakeJson('Types', types)
    
    cat(paste0('"datePattern": "',DatePattern,'"\n'))
    
    Stu_Counter <- Stu_Counter + 1
    LoopClose <- ifelse(Stu_Counter == length(DataFiles), "}\n", "},\n")
    cat(LoopClose)
    }      
  
  cat("]")
  
  sink()
  closeAllConnections()
  return(map)
  
}
