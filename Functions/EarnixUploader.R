#********************************************************************************************************************#
#                                                                                                                    #
# EarnixUploader                                                                                                  ####
#                                                                                                                    #
# produce the input files and the commands for the EarnixUploader purpose                                            #
#                                                                                                                    #
#********************************************************************************************************************#

EarnixUploader <- function(Brand, Product, Transaction, Source, Submodels, Filters, VersionNames,
                           DatePattern, CreateTemplate, ImportData, ImportModel, ModelFit, 
                           User_Directory, EarnixUploader_Working_Directory, EarnixUploader_Package_Directory, 
                           EarnixFolder, EarnixProjectName, Earnix_Exe,
                           Data_Dictionary_Location, ConfigsFile, ParamasFile,
                           MakeTemplate, UploadData, UploadModels, CreatePricingVersion,
                           ModelFiles, DataFiles){
 
  #*********************************************************************************************************#
  #                                                                                                         #
  # SEC 0 Preparation                                                                                    ####
  #                                                                                                         #
  #*********************************************************************************************************#
  
  options(scipen = 999)
  options(max.print = 1000000)
  options(width = 10000)
  # options(warn=1)
  
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
  # 0.1 Setup Logging                                                                                        ####
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
  
  #*********************************************************************************************************#
  #                                                                                                         #
  # 0.2 Setup Json files and executable commands file                                                    ####
  #                                                                                                         #
  #*********************************************************************************************************#
  
  EarnixMainscriptArgs <- list()
    
  #*********************************************************************************************************#
  #                                                                                                         #
  # 0.2.1 Main Script containing the commands and the Project Info                                       ####
  #                                                                                                         #
  #*********************************************************************************************************#
  
  direname_Main <- file.path(User_Directory, '6. EarnixUploader', 'Main', Source)
  dir.create(direname_Main, recursive = TRUE, showWarnings = FALSE)
  MainFile <- file.path(direname_Main, "CommandsFile.sh")
  ProjectInfoFile <- file.path(direname_Main, "EarnixProjectInfo.json")
  EarnixUploaderFileList <- append(EarnixUploaderFileList, MainFile)
  
  PrintComment(capture_log$prefix, 1, 2, paste0("CMD/Java commands are stored in: ", MainFile))
  
  #*********************************************************************************************************#
  #                                                                                                         #
  # 0.2.2 Create Template input file                                                                     ####
  #                                                                                                         #
  #*********************************************************************************************************#
  
  if ( CreateTemplate=='Y' ){
    
    direname_Template <- file.path(User_Directory, '6. EarnixUploader', 'Template', Source)
    dir.create(direname_Template, recursive = TRUE, showWarnings = FALSE)
    ParameterFile <- file.path(direname_Template, "EarnixParametersTemplate.json")
    EarnixMainscriptArgs['Template'] <- file.path(direname_Template, "EarnixMainScriptArgs.json")
    
  }
  
  #*********************************************************************************************************#
  #                                                                                                         #
  # 0.2.3 Create DataInfo input file                                                                     ####
  #                                                                                                         #
  #*********************************************************************************************************#
  
  if ( ImportData=='Y' ){
    
    direname_Data <- file.path(User_Directory, '6. EarnixUploader', 'Data', Source)
    dir.create(direname_Data, recursive = TRUE, showWarnings = FALSE)
    DataInfoFile <-  file.path(direname_Data, "EarnixDataInfo.json") 
    EarnixMainscriptArgs['Data'] <- file.path(direname_Data, "EarnixMainScriptArgs.json")
    
  }
  
  #*********************************************************************************************************#
  #                                                                                                         #
  # 0.2.4 Create ModelInfo input file                                                                    ####
  #                                                                                                         #
  #*********************************************************************************************************#
  
  if (ImportModel=='Y'){
    
    submodels <- eval(parse(text = Submodels))
    ModelInfoFile <- rep('', length(submodels))
    ModelArgs <- rep('', length(submodels))
    
    for (i in 1:length(submodels)){
      
      direname_Model <- file.path(User_Directory, '6. EarnixUploader', 'Model', Source, submodels[i])
      dir.create(direname_Model, recursive = TRUE, showWarnings = FALSE)
      ModelInfoFile_s <- file.path(direname_Model, "EarnixModelInfo.json") 
      ModelInfoFile[i] <- ModelInfoFile_s
      ModelArgs[i] <- file.path(direname_Model, "EarnixMainScriptArgs.json")
      
    }
    
    EarnixMainscriptArgs['Model'] <- list(ModelArgs)
    
  }
  
  ############################################## JavaScript files (they are the original ones developed by Haifang)
  
  earnix_load_template = file.path(EarnixUploader_Working_Directory, 'Functions', "auto_pricing.js")
  earnix_load_data = file.path(EarnixUploader_Working_Directory, 'Functions', "upload_data.js") 
  earnix_load_model = file.path(EarnixUploader_Working_Directory, 'Functions', "upload_model.js")
  
  ############################################## This is where the data and models will be uploaded
  
  EarnixProjectFolder <- file.path(EarnixFolder, EarnixProjectName, fsep="\\\\" )
  
  PrintComment(capture_log$prefix, 1, 2, paste0("The targeted Earnix template is: ", EarnixProjectFolder))
  
  #*********************************************************************************************************#
  #                                                                                                         #
  # 0.3 Source Function Files                                                                            ####
  #                                                                                                         #
  #*********************************************************************************************************#
  
  # Print message to indicate beginning this stage
  
  PrintComment(capture_log$prefix, 2, 2, paste0("[", Sys.time(), "] Beginning (0.1) Source Function Files"))
  
  setwd(EarnixUploader_Working_Directory)

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
  source(file.path(EarnixUploader_Working_Directory, 'Functions', "ModelFilePreparation.R"))
  
  # Print message to indicate completing this stage
  
  PrintComment(capture_log$prefix, 2, 2, paste0("[", Sys.time(), "] Completed (0.1) Source Function Files"))
  
  #*********************************************************************************************************#
  #                                                                                                         #
  # 0.4 Load Packages                                                                                    ####
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
  # 0.5 Parameter Status Display                                                                         ####
  #                                                                                                         #
  #*********************************************************************************************************#
  
  PrintComment(capture_log$prefix, 2, 2, paste0("[", Sys.time(), "] Beginning (0.3) Parameter Status Display"))
  
  ParameterStatusDisplay(Brand, Product, Transaction, Source, Submodels, Filters, VersionNames,
                        DatePattern, CreateTemplate, ImportData, ImportModel, ModelFit, 
                        User_Directory, EarnixUploader_Working_Directory, EarnixUploader_Package_Directory,
                        EarnixFolder, EarnixProjectName, Earnix_Exe,
                        Data_Dictionary_Location, ConfigsFile, ParamasFile, 
                        MakeTemplate, UploadData, UploadModels, CreatePricingVersion,
                        ModelFiles, DataFiles)
  
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
  
  Updated_Parameters <- InputParameterValidation(Brand, Product, Transaction, Source, Submodels, Filters, VersionNames,
                                                 DatePattern, CreateTemplate, ImportData, ImportModel, ModelFit,  
                                                 User_Directory, EarnixUploader_Working_Directory, EarnixUploader_Package_Directory,
                                                 EarnixFolder, EarnixProjectName, Earnix_Exe,
                                                 Data_Dictionary_Location, ConfigsFile, ParamasFile,
                                                 MakeTemplate, UploadData, UploadModels, CreatePricingVersion,
                                                 ModelFiles, DataFiles)
  
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
  # SEC 3 Generating the Earnix template file                                                            ####
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
    
    df <- data.frame(projectInfoFile=ProjectInfoFile, parametersTemplateFile=ParameterFile)
    jsonlite::write_json(as.list(df), EarnixMainscriptArgs$Template, pretty=TRUE, auto_unbox =T)   
    
    EarnixUploaderFileList <- append(EarnixUploaderFileList, c(ParameterFile,EarnixMainscriptArgs$Template))
    
    TemplateCommand <- paste0('"', Earnix_Exe, '"', ' -script ', '"', earnix_load_template, '" "', EarnixMainscriptArgs$Template, '"' )
    
    readr::write_lines(TemplateCommand, MainFile, sep = "\n")
    
    PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Completed (4) Earnix Parameter template file"))
    
  } else {
    
    PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] (4) No ParameterFile is created, since CreateTemplate = ", '"', CreateTemplate,'"'))
    
  }
  
  #*********************************************************************************************************#
  #                                                                                                         #
  # SEC 4 Generating the Earnix data import file                                                         ####
  #                                                                                                         #
  #*********************************************************************************************************#
  
  # Extracting the location of the data this can be used for model import as well
  
  if (ImportData == 'Y' | ImportModel == 'Y'){
    
    split_path <- function(x) if (dirname(x)==x) x else c(basename(x),split_path(dirname(x)))
    BaseName <- tools::file_path_sans_ext(split_path(DataFiles[1])[1])
    
    if ( Source == "Aquote" ){
      
      TableName <- paste0('4. Optimisation\\\\', BaseName)
      
    } else if ( Source == "NBS" ){
      
      TableName <- paste0('1. NBS\\\\', BaseName)
      
    } else if ( Source == "RNW" ){
      
      TableName <- paste0('2. RNW\\\\', BaseName)
      
    } else if ( Source == "MTC" ){
      
      TableName <- paste0('3. MTC/MTA\\\\', BaseName)
      
    }  
    
  }
  
  PrintComment(capture_log$prefix, 1, 1, paste0("###########################################################"))
  PrintComment(capture_log$prefix, 1, 1, paste0("# Section 5 - Creating DataInfo file, DataInfoFile ########"))
  PrintComment(capture_log$prefix, 1, 2, paste0("###########################################################"))
  
  # Print message to indicate beginning this stage
  
  PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Beginning (5) creation of Earnix Data Info file"))
  
  if (ImportData == 'Y'){

    PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Beginning (5) Earnix Data Info file, ", DataInfoFile))
    
    PrepareDatauploading(Brand, Product, Transaction, Source, Data_Dictionary_Location,
                         DataFiles, DataInfoFile, DatePattern, TableName)
    
    df <- data.frame(projectInfoFile=ProjectInfoFile, dataInfoFile=DataInfoFile)
    jsonlite::write_json(as.list(df), EarnixMainscriptArgs$Data, pretty=TRUE, auto_unbox =T)   
    
    EarnixUploaderFileList <- append(EarnixUploaderFileList, c(DataInfoFile,EarnixMainscriptArgs$Data)) 
    
    DataCommand <- paste0('"', Earnix_Exe, '"', ' -script ', '"', earnix_load_data, '" "',EarnixMainscriptArgs$Data, '"' )
    
    AppendTheCommand <- ifelse(CreateTemplate == 'Y', TRUE, FALSE)
    readr::write_lines(DataCommand, MainFile, sep = "\n", append = AppendTheCommand)
    
    PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Completed (5) creation of Earnix Data Info file"))
    
  } else {
    
    PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] (5) No Data Info is created, since ImportData = ", '"', ImportData,'"'))
    
  }
  
  #*********************************************************************************************************#
  #                                                                                                         #
  # SEC 5 Generating the Earnix model import file                                                         ####
  #                                                                                                         #
  #*********************************************************************************************************#
  
  PrintComment(capture_log$prefix, 1, 1, paste0("###########################################################"))
  PrintComment(capture_log$prefix, 1, 1, paste0("# Section 6 - Creating ModelInfo file, DataInfoFile ########"))
  PrintComment(capture_log$prefix, 1, 2, paste0("###########################################################"))
  
  # Print message to indicate beginning this stage
  
  PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Beginning (6) creation of Earnix Model Info file"))
 
  if (ImportModel == 'Y'){
    
    PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Beginning (6) Model Info file, ", ModelInfoFile))
    
    AppendTheCommand <- ifelse(CreateTemplate == 'Y' | ImportData == 'Y', TRUE, FALSE)
    
    modelFit <- eval(parse(text = ModelFit))
    for (i in 1:length(ModelFiles)){
      
      MakeModelsInfoFile(ModelFiles[i], ModelInfoFile[i], ParamasFile, submodels[i], Filters[i], VersionNames[i], TableName, modelFit[i])
      
      df <- data.frame(projectInfoFile=ProjectInfoFile, modelInfoFile=ModelInfoFile[i])
      jsonlite::write_json(as.list(df), EarnixMainscriptArgs$Model[i], pretty=TRUE, auto_unbox =T)   
      
      EarnixUploaderFileList <- append(EarnixUploaderFileList, c(ModelInfoFile[i],EarnixMainscriptArgs$Model[i]))
      TemplateCommand <- paste0('"', Earnix_Exe, '"', ' -script ', '"', earnix_load_model, '" "', EarnixMainscriptArgs$Model[i], '"' )
      readr::write_lines(TemplateCommand, MainFile, sep = "\n", append = AppendTheCommand)
      
    }
    
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




