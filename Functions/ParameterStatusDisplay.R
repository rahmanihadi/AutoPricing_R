#********************************************************************************************************************#
#                                                                                                                    #
# ParameterStatusDisplay                                                                                          ####
#                                                                                                                    #
# Print the input parameters provided by the user                                                                    #
#                                                                                                                    #
#********************************************************************************************************************#

ParameterStatusDisplay <- function(Brand, Product, Transaction, Source, DatePattern, CreateTemplate, ImportData, ImportModel, 
                                   User_Directory, Working_Directory, Opt_Directory, EarnixUploader_Package_Directory,
                                   EarnixFolder, EarnixProjectName, Eernix_Exe,
                                   DataDictionary, ConfigsFile,
                                   MakeTemplate, UploadData, UploadModels, CreatePricingVersion,
                                   ModelFiles, DataFiles,
                                   DataInfoFile, ModelInfoFile, ParameterFile, ProjectInfoFile, ReportInfoFile, EarnixMainscriptArgs){
  
  PrintComment(capture_log$prefix, 3, 2, "Parameters Inputted are:")
  
  InputParAsList <- as.list(match.call())
  InputParAsList[[1]] <- NULL
  Nprnt <- rep(1, length(InputParAsList))
  Nprnt[length(InputParAsList)] <- 2
  for (i in 1:length(InputParAsList)){
    
    item <- InputParAsList[[i]]
    itemEqNA <- paste0(as.character(item),' = NA')
    itemEqTo <- paste0(as.character(item),' = "')
    PrintComment(capture_log$prefix, 3, Nprnt[i], paste0(ifelse(is.na(eval(parse(text = item))), itemEqNA , paste0(itemEqTo, eval(parse(text = item)), '"'))))
    
  }
  
  
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(Brand), 'Brand = NA' , paste0('Brand= "', Brand, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(Product), 'Product = NA' , paste0('Product= "', Product, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(Transaction), 'Transaction = NA' , paste0('Transaction= "', Transaction, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(Source), 'Source = NA' , paste0('Source= "', Source, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(DatePattern), 'DatePattern = NA' , paste0('DatePattern= "', DatePattern, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(CreateTemplate), 'CreateTemplate = NA' , paste0('CreateTemplate= "', CreateTemplate, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(ImportData), 'ImportData = NA' , paste0('ImportData= "', ImportData, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(ImportModel), 'ImportModel = NA' , paste0('ImportModel= "', ImportModel, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(User_Directory), 'User_Directory = NA' , paste0('User_Directory= "', User_Directory, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(EarnixUploader_Working_Directory), 'EarnixUploader_Working_Directory = NA' , paste0('EarnixUploader_Working_Directory= "', EarnixUploader_Working_Directory, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(EarnixUploader_Package_Directory), 'EarnixUploader_Package_Directory = NA' , paste0('EarnixUploader_Package_Directory= "', EarnixUploader_Package_Directory, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(Opt_Directory), 'Opt_Directory = NA' , paste0('Opt_Directory= "', Opt_Directory, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(EarnixFolder), 'EarnixFolder = NA' , paste0('EarnixFolder= "', EarnixFolder, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(EarnixProjectName), 'EarnixProjectName = NA' , paste0('EarnixProjectName= "', EarnixProjectName, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(Eernix_Exe), 'Eernix_Exe = NA' , paste0('Eernix_Exe= "', Eernix_Exe, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(DataDictionary), 'DataDictionary = NA' , paste0('DataDictionary= "',  DataDictionary, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(ConfigsFile), 'ConfigsFile = NA' , paste0('ConfigsFile= "', ConfigsFile, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(MakeTemplate), 'MakeTemplate = NA' , paste0('MakeTemplate= "',  MakeTemplate, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(UploadData), 'UploadData = NA' , paste0('UploadData= "', UploadData, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(UploadModels), 'UploadModels = NA' , paste0('UploadModels= "', UploadModels, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(CreatePricingVersion), 'CreatePricingVersion = NA' , paste0('CreatePricingVersion= "', CreatePricingVersion, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(ModelFiles), 'ModelFiles = NA' , paste0('ModelFiles= "',  ModelFiles, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(DataFiles), 'DataFiles = NA' , paste0('DataFiles= "', DataFiles, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(DataInfoFile), 'DataInfoFile = NA' , paste0('DataInfoFile= "',  DataInfoFile, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(ModelInfoFile), 'ModelInfoFile = NA' , paste0('ModelInfoFile= "', ModelInfoFile, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(ParameterFile), 'ParameterFile = NA' , paste0('ParameterFile= "', ParameterFile, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(ProjectInfoFile), 'ProjectInfoFile = NA' , paste0('ProjectInfoFile= "', ProjectInfoFile, '"'))))
  # PrintComment(capture_log$prefix, 3, 1, paste0(ifelse(is.na(ReportInfoFile), 'ReportInfoFile = NA' , paste0('ReportInfoFile= "', ReportInfoFile, '"'))))
  # PrintComment(capture_log$prefix, 3, 2, paste0(ifelse(is.na(EarnixMainscriptArgs), 'EarnixMainscriptArgs = NA' , paste0('EarnixMainscriptArgs= "', EarnixMainscriptArgs, '"')))) 
  # 
}
