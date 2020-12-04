#********************************************************************************************************************#
#                                                                                                                    #
# ParameterStatusDisplay                                                                                          ####
#                                                                                                                    #
# Print the input parameters provided by the user                                                                    #
#                                                                                                                    #
#********************************************************************************************************************#

ParameterStatusDisplay <- function(Brand, Product, Transaction, Source, Submodels, filter, versionName,
                                   DatePattern, CreateTemplate, ImportData, ImportModel, ModelFit, 
                                   User_Directory, Working_Directory, EarnixUploader_Package_Directory,
                                   EarnixFolder, EarnixProjectName, Earnix_Exe,
                                   DataDictionary, ConfigsFile, ParamasFile,
                                   MakeTemplate, UploadData, UploadModels, CreatePricingVersion,
                                   ModelFiles, DataFiles){
  
  PrintComment(capture_log$prefix, 3, 2, "Parameters Inputted are:")
  
  InputParAsList <- as.list(match.call())
  InputParAsList[[1]] <- NULL
  Nprnt <- rep(1, length(InputParAsList))
  Nprnt[length(InputParAsList)] <- 2
  
  for (i in 1:length(InputParAsList)){
    
    item <- InputParAsList[[i]]
    itemEqNA <- paste0(as.character(item),' = NA')
    itemEqTo <- paste0(as.character(item),' = "')
    Evaluated <- eval(parse(text = item))
    if (length(Evaluated)>1){ Evaluated<- paste0('c(',paste0(Evaluated, collapse=', ') , ')')}
    PrintComment(capture_log$prefix, 3, Nprnt[i], paste0(ifelse(is.na(Evaluated), itemEqNA , paste0(itemEqTo, Evaluated, '"'))))
    
  }
  
}
