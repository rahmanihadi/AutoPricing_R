#********************************************************************************************************************#
#                                                                                                                    #
# EarnixUploader                                                                                                  ####
#                                                                                                                    #
# produce the input files and the commands for the EarnixUploader purpose                                            #
#                                                                                                                    #
#********************************************************************************************************************#

EarnixUploader <- function(Brand, Product, Transaction, Source, DatePattern, CreateTemplate, ImportData, ImportModel, 
                           User_Directory, EarnixUploader_Working_Directory, Opt_Directory, EarnixUploader_Package_Directory, 
                           EarnixFolder, EarnixProjectName, Earnix_Exe,
                           Data_Dictionary_Location, ConfigsFile,
                           MakeTemplate, UploadData, UploadModels, CreatePricingVersion,
                           ModelFiles, DataFiles,
                           DataInfoFile, ModelInfoFile, ParameterFile, ProjectInfoFile, ReportInfoFile, EarnixMainscriptArgs){
 
  #*********************************************************************************************************#
  #                                                                                                         #
  # SEC 0 Preparation                                                                                    ####
  #                                                                                                         #
  #*********************************************************************************************************#
  
  options(scipen = 999)
  options(max.print = 1000000)
  options(width = 10000)
  
  # Close any open connections
  
  closeAllConnections()
  
  # Capture start time to keep track of overall run time
  
  overall_start_time <- Sys.time()
  
  if (Source == 'Aquote') {

    Source_Appended <- paste0(Source, "_", Aquote_Extract_Type)
    Aquote_Extract_Type <<- Aquote_Extract_Type

  } else {

    Source_Appended <- Source

  }
  
  #*********************************************************************************************************#
  #                                                                                                         #
  # Setup Logging                                                                                        ####
  #                                                                                                         #
  #*********************************************************************************************************#
  
  dir.create(file.path(User_Directory, "/4. Data Reports"), showWarnings = FALSE)
  dir.create(file.path(paste0(User_Directory, "/4. Data Reports"), Source), showWarnings = FALSE)
  
  EarnixUploader_Log_Path <<- FileSerialNaming(Name = paste0(User_Directory, "/4. Data Reports/", Source, "/EarnixUploader - ", Source_Appended, " - Logfile"), Type = "log")
  Log_Path <- EarnixUploader_Log_Path
  
  capture_log <<- CaptureLog(Log_Path = EarnixUploader_Log_Path, 
    Run_Location = Run_Location)
  
  eval(parse(text = capture_log$setup))
  
  PrintComment(capture_log$prefix, 1, 1, paste0("###########################################################"))
  PrintComment(capture_log$prefix, 1, 1, paste0("# Beginning EarnixUploader Platform for Source: ", Source_Appended))
  PrintComment(capture_log$prefix, 1, 2, paste0("###########################################################"))
  
  PrintComment(capture_log$prefix, 1, 2, paste0("EarnixUploader Log file location: ", EarnixUploader_Log_Path))
  
  PrintComment(capture_log$prefix, 1, 1, paste0("###########################################################"))
  PrintComment(capture_log$prefix, 1, 1, paste0("# Section 0 - Preparation #################################"))
  PrintComment(capture_log$prefix, 1, 2, paste0("###########################################################"))
  
  # Print message to indicate beginning this stage
  
  PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Beginning (0) Preparation"))
  
  EarnixUploaderFileList <- list()
  
  ############################################## The file containing the executables ... Where should it be saved?
  
  MainFile <- file.path(User_Directory, "CommandsFile.sh")
  EarnixUploaderFileList <- append(EarnixUploaderFileList, MainFile)
  
  PrintComment(capture_log$prefix, 1, 2, paste0("CMD/Java commands are stored in: ", MainFile))
  
  ############################################## Outputs of EarnixUploader, all are JSON files ... Where should it be saved?
  
  DataInfoFile <-  file.path(User_Directory, "EarnixDataInfo.json") 
  ModelInfoFile <- file.path(User_Directory, "EarnixModelInfo.json") 
  ParameterFile <- file.path(User_Directory, "EarnixParametersTemplate.json") 
  ProjectInfoFile <- file.path(User_Directory, "EarnixProjectInfo.json") 
  ReportInfoFile <- file.path(User_Directory, "EarnixReportInfo.json")
  EarnixMainscriptArgs <- file.path(User_Directory, "EarnixMainScriptArgs.json")
  
  ############################################## JavaScript files (they are the original ones developed by Haifang) ... Should be moved to the _Dev
  
  earnix_load_template = file.path(Opt_Directory, "auto_pricing.js")
  earnix_load_data = file.path(Opt_Directory, "upload_data.js") 
  earnix_load_model = file.path(Opt_Directory, "upload_model.js")
  
  ############################################## This is where the data and models will be uploaded
  
  EarnixProjectFolder <- file.path(EarnixFolder, EarnixProjectName, fsep="\\\\" )
  
  PrintComment(capture_log$prefix, 1, 2, paste0("The targeted Earnix template is: ", EarnixProjectFolder))
  
  #*********************************************************************************************************#
  #                                                                                                         #
  # 0.1 Source Function Files                                                                            ####
  #                                                                                                         #
  #*********************************************************************************************************#
  
  # Print message to indicate beginning this stage
  
  PrintComment(capture_log$prefix, 2, 2, paste0("[", Sys.time(), "] Beginning (0.1) Source Function Files"))
  
  setwd(EarnixUploader_Working_Directory)

  source(file.path(EarnixUploader_Working_Directory, 'Functions', "GenEarnixArgFile.R"))
  source(file.path(EarnixUploader_Working_Directory, 'Functions', "GetParameters.R")) 
  source(file.path(EarnixUploader_Working_Directory, 'Functions', "PrepareDatauploading.R"))
  source(file.path(EarnixUploader_Working_Directory, 'Functions', "UpdateDataDictionary.R"))
  source(file.path(EarnixUploader_Working_Directory, 'Functions', "GetEarnixMapping.R"))
  source(file.path(EarnixUploader_Working_Directory, 'Functions', "GetDataType.R"))
  source(file.path(EarnixUploader_Working_Directory, 'Functions', "MakeModelsInfoFile.R"))
  source(file.path(EarnixUploader_Working_Directory, 'Functions', "MakeProjectInfoFile.R"))
  source(file.path(EarnixUploader_Working_Directory, 'Functions', "NestedList.R"))
  source(file.path(EarnixUploader_Working_Directory, 'Functions', "ParameterStatusDisplay.R"))
  source(file.path(EarnixUploader_Working_Directory, 'Functions', "InputParameterValidation.R"))
  
  # Print message to indicate completing this stage
  
  PrintComment(capture_log$prefix, 2, 2, paste0("[", Sys.time(), "] Completed (0.1) Source Function Files"))
  
  #*********************************************************************************************************#
  #                                                                                                         #
  # 0.2 Load Packages                                                                                    ####
  #                                                                                                         #
  #*********************************************************************************************************#
  
  # Print message to indicate beginning this stage
  
  PrintComment(capture_log$prefix, 2, 2, paste0("[", Sys.time(), "] Beginning (0.2) Load Packages"))
  
  # Load required R packages
  
  Required_Packages <- c("jsonlite", "readr", "stringr", "stringi" )
  
  LoadPackages(Required_Packages = Required_Packages, 
    Package_Directory = EarnixUploader_Package_Directory)
  
  # Print message to indicate completing this stage
  
  PrintComment(capture_log$prefix, 2, 2, paste0("[", Sys.time(), "] Completed (0.2) Load Packages"))
  
  #*********************************************************************************************************#
  #                                                                                                         #
  # 0.3 Parameter Status Display                                                                         ####
  #                                                                                                         #
  #*********************************************************************************************************#
  
  PrintComment(capture_log$prefix, 2, 2, paste0("[", Sys.time(), "] Beginning (0.3) Parameter Status Display"))
  
  ParameterStatusDisplay(Brand, Product, Transaction, Source, DatePattern, CreateTemplate, ImportData, ImportModel, 
                        User_Directory, EarnixUploader_Working_Directory, Opt_Directory, EarnixUploader_Package_Directory,
                        EarnixFolder, EarnixProjectName, Earnix_Exe,
                        Data_Dictionary_Location, ConfigsFile,
                        MakeTemplate, UploadData, UploadModels, CreatePricingVersion,
                        ModelFiles, DataFiles,
                        DataInfoFile, ModelInfoFile, ParameterFile, ProjectInfoFile, ReportInfoFile, EarnixMainscriptArgs)
  
  # Print message to indicate completing this stage
  
  PrintComment(capture_log$prefix, 2, 2, paste0("[", Sys.time(), "] Completed (0.3) Parameter Status Display"))
  
  # Print message to indicate completing this stage
  
  PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Completed (0) Preparation"))
  
  #*********************************************************************************************************#
  #                                                                                                         #
  # SEC 1 Input Parameter Validation                                                                     ####
  #                                                                                                         #
  #*********************************************************************************************************#
  
  PrintComment(capture_log$prefix, 1, 1, paste0("###########################################################"))
  PrintComment(capture_log$prefix, 1, 1, paste0("# Section 1 - Input Parameter Validation ##################"))
  PrintComment(capture_log$prefix, 1, 2, paste0("###########################################################"))
  
  # Print message to indicate beginning this stage
  
  PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Beginning (1) Input Parameter Validation"))
  
  # Function call to InputParameterValidation
  
  Updated_Parameters <- InputParameterValidation(Brand, Product, Transaction, Source, DatePattern, CreateTemplate, ImportData, ImportModel, 
                                                 User_Directory, EarnixUploader_Working_Directory, Opt_Directory, EarnixUploader_Package_Directory,
                                                 EarnixFolder, EarnixProjectName, Earnix_Exe,
                                                 Data_Dictionary_Location, ConfigsFile,
                                                 MakeTemplate, UploadData, UploadModels, CreatePricingVersion,
                                                 ModelFiles, DataFiles,
                                                 DataInfoFile, ModelInfoFile, ParameterFile, ProjectInfoFile, ReportInfoFile, EarnixMainscriptArgs)
  
  # Print message to indicate completing this stage
  
  PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Completed (1) Input Parameter Validation"))
  
  #*********************************************************************************************************#
  #                                                                                                         #
  # SEC 2 Generating the JSON file ProjectInfo                                                           ####
  #                                                                                                         #
  #*********************************************************************************************************#
  
  PrintComment(capture_log$prefix, 1, 1, paste0("###########################################################"))
  PrintComment(capture_log$prefix, 1, 1, paste0("# Section 2 - Earnix project info file ####################"))
  PrintComment(capture_log$prefix, 1, 2, paste0("###########################################################"))
  
  # Print message to indicate beginning this stage
  
  PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Beginning (2) ProjectInfo"))
  
  MakeProjectInfoFile(Product, Transaction, EarnixProjectFolder, EarnixProjectName, EarnixFolder, ProjectInfoFile)
  EarnixUploaderFileList <- append(EarnixUploaderFileList, ProjectInfoFile)
  
  PrintComment(capture_log$prefix, 1, 2, paste0("The ProjectInfo file is generated: ", ProjectInfoFile))
  
  PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Completed (2) ProjectInfo"))
  
  #*********************************************************************************************************#
  #                                                                                                         #
  # SEC 3 Generating the JSON file EarnixMainscriptArgs                                                  ####
  #                                                                                                         #
  #*********************************************************************************************************#
  
  PrintComment(capture_log$prefix, 1, 1, paste0("###########################################################"))
  PrintComment(capture_log$prefix, 1, 1, paste0("# Section 3 - Earnix Main Argument file ###################"))
  PrintComment(capture_log$prefix, 1, 2, paste0("###########################################################"))
  
  # Print message to indicate beginning this stage
  
  PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Beginning (3) EarnixMainscriptArgs"))
  
  GenEarnixArgFile(ProjectInfoFile, DataInfoFile, ModelInfoFile, ReportInfoFile, ParameterFile,
                  EarnixMainscriptArgs)
  EarnixUploaderFileList <- append(EarnixUploaderFileList, EarnixMainscriptArgs)
  
  PrintComment(capture_log$prefix, 1, 2, paste0("The EarnixMainscriptArgs file is generated: ", EarnixMainscriptArgs))
  
  PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Completed (3) EarnixMainscriptArgs")) 
    
  #*********************************************************************************************************#
  #                                                                                                         #
  # SEC 4 Generating the Earnix template file                                                            ####
  #                                                                                                         #
  #*********************************************************************************************************#
  
  PrintComment(capture_log$prefix, 1, 1, paste0("###########################################################"))
  PrintComment(capture_log$prefix, 1, 1, paste0("# Section 4 - Earnix Template file      ###################"))
  PrintComment(capture_log$prefix, 1, 2, paste0("###########################################################"))
  
  # Print message to indicate beginning this stage
  
  PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Beginning (4) Earnix Parameter template file"))
  
  if (CreateTemplate == 'Y'){
    
    PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Beginning (4) Earnix Parameter template file ", ParameterFile))
    
    GetParameters(Product, Transaction, ParameterFile, ConfigsFile)
    EarnixUploaderFileList <- append(EarnixUploaderFileList, ParameterFile)
    
    TemplateCommand <- paste0('"', Earnix_Exe, '"', ' -script ', '"', earnix_load_template, '" "', EarnixMainscriptArgs, '"' )
    
    readr::write_lines(TemplateCommand, MainFile, sep = "\n")
    
    PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Completed (4) Earnix Parameter template file"))
    
  } else {
    
    PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] (4) No ParameterFile is created, since CreateTemplate = ", '"', CreateTemplate,'"'))
    
  }
  
  
  #*********************************************************************************************************#
  #                                                                                                         #
  # SEC 5 Generating the Earnix data import file                                                         ####
  #                                                                                                         #
  #*********************************************************************************************************#
  
  PrintComment(capture_log$prefix, 1, 1, paste0("###########################################################"))
  PrintComment(capture_log$prefix, 1, 1, paste0("# Section 5 - Creating DataInfo file, DataInfoFile ########"))
  PrintComment(capture_log$prefix, 1, 2, paste0("###########################################################"))
  
  # Print message to indicate beginning this stage
  
  PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Beginning (5) creation of Earnix Data Info file"))
  
  if (ImportData == 'Y'){

    PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Beginning (5) Earnix Data Info file, ", DataInfoFile))
    
    PrepareDatauploading(Brand, Product, Transaction, Source, Data_Dictionary_Location,
                         DataFiles, DataInfoFile, DatePattern)
    EarnixUploaderFileList <- append(EarnixUploaderFileList, DataInfoFile) 
    
    TemplateCommand <- paste0('"', Earnix_Exe, '"', ' -script ', '"', earnix_load_data, '" "', EarnixMainscriptArgs, '"' )
    
    AppendTheCommand <- ifelse(CreateTemplate == 'Y', TRUE, FALSE)
    readr::write_lines(TemplateCommand, MainFile, sep = "\n", append = AppendTheCommand)
    
    PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Completed (5) creation of Earnix Data Info file"))
    
  } else {
    
    PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] (5) No Data Info is created, since ImportData = ", '"', ImportData,'"'))
    
  }
  
  #*********************************************************************************************************#
  #                                                                                                         #
  # SEC 6 Generating the Earnix model import file                                                         ####
  #                                                                                                         #
  #*********************************************************************************************************#
  
  PrintComment(capture_log$prefix, 1, 1, paste0("###########################################################"))
  PrintComment(capture_log$prefix, 1, 1, paste0("# Section 6 - Creating ModelInfo file, DataInfoFile ########"))
  PrintComment(capture_log$prefix, 1, 2, paste0("###########################################################"))
  
  # Print message to indicate beginning this stage
  
  PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Beginning (6) creation of Earnix Model Info file"))
  
  if (ImportModel == 'Y'){
    
    PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Beginning (6) Model Info file, ", ModelInfoFile))
    
    MakeModelsInfoFile(ModelFiles, ModelInfoFile)
    EarnixUploaderFileList <- append(EarnixUploaderFileList, ModelInfoFile)
    
    TemplateCommand <- paste0('"', Earnix_Exe, '"', ' -script ', '"', earnix_load_model, '" "', EarnixMainscriptArgs, '"' )
    
    AppendTheCommand <- ifelse(CreateTemplate == 'Y' | ImportData == 'Y', TRUE, FALSE)
    readr::write_lines(TemplateCommand, MainFile, sep = "\n", append = AppendTheCommand)
    
    PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Completed (6) Earnix Model Info file"))
    
  } else {
    
    PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] (6) No Model Info is created, since ImportData = ", '"', ImportModel,'"'))
    
  }
  
  PrintComment(capture_log$prefix, 1, 2, paste0("List of generated files (apart from the logfile): "))
  Nprnt <- rep(1, length(EarnixUploaderFileList))
  Nprnt[length(EarnixUploaderFileList)] <- 2
  for (i in 1:length(EarnixUploaderFileList)){
    
    PrintComment(capture_log$prefix, 2, Nprnt[i], paste0(EarnixUploaderFileList[[i]]))
    
  }
  
  PrintComment(capture_log$prefix, 1, 1, paste0("###########################################################"))
  PrintComment(capture_log$prefix, 1, 1, paste0("# Completed EarnixUploader Platform for Source: ", Source_Appended))
  PrintComment(capture_log$prefix, 1, 2, paste0("###########################################################"))
  
  closeAllConnections()
  
  
}




