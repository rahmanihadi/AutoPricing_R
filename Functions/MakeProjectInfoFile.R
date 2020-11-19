#********************************************************************************************************************#
#                                                                                                                    #
# MakeProjectInfoFile                                                                                              ####
#                                                                                                                    #
# Generates the EarnixProjectInfo.json required for making a template on Earnix                      #
#                                                                                                                    #
#********************************************************************************************************************#
MakeProjectInfoFile <- function(Product, Transaction, EarnixProjectFolder,EarnixProjectName, EarnixFolder, ProjectInfoFile){
  
  MakeTemplate <- TRUE
  UploadData <- FALSE
  UploadModels <- FALSE
  CreatePricingVersion <- FALSE
  
  # Brand <- 'RAC'
  # Product <- 'PC'
  # Transaction <- 'NBS'
  # EarnixProjectFolder <- "\\\\Budget Group\\\\2019\\\\All\\\\Development\\\\Test\\2020-01 RAC PC ALL NBS TF_test"
  # EarnixProjectName <- "2020-01 RAC PC ALL NBS TF_test"
  # EarnixFolder <- "\\\\Budget Group\\\\2019\\\\All\\\\Development\\Test"
  # 
  # ProjectInfoFile <- "C:/Users/HRahmaniBayegi/softs/pricing/AutoPricing_R/EarnixProjectInfo.json"
  
  # PrintComment(capture_log$prefix, 2, 2, paste0("[", Sys.time(), "] Beginning (2.1) ", ProjectInfoFile))
  
  df <- data.frame(Product = Product, Transaction = Transaction, 
    EarnixProjectFolder = EarnixProjectFolder, EarnixProjectName=EarnixProjectName, EarnixFolder=EarnixFolder,
    MakeTemplate = MakeTemplate, UploadData = UploadData, UploadModels=UploadModels, CreatePricingVersion=CreatePricingVersion)

  
  jsonlite::write_json(as.list(df), ProjectInfoFile, pretty=TRUE, auto_unbox =T)
  
  # PrintComment(capture_log$prefix, 2, 2, paste0("[", Sys.time(), "] Completed (2.1) ", ProjectInfoFile))
  
  # print(paste0('The ProjectInfoFile is created: ',ProjectInfoFile))
  
}