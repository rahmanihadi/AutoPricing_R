#********************************************************************************************************************#
#                                                                                                                    #
# AutoPricing_R                                                                                              ####
#                                                                                                                    #
# produce the input files and the commands for the autopricing purpose                       #
#                                                                                                                    #
#********************************************************************************************************************#
AutoPricing_R <- function(Brand, Product, Transaction, DatePattern, CreateTemplate, ImportData, ImportModel, 
  User_Directory, Working_Directory, Opt_Directory, 
  EarnixFolder, EarnixProjectName, Eernix_Exe,
  DataDictionary, ConfigsFile,
  MakeTemplate, UploadData, UploadModels, CreatePricingVersion,
  ModelFiles, DataFiles,
  DataInfoFile, ModelInfoFile, ParameterFile, ProjectInfoFile, ReportInfoFile, EarnixMainscriptArgs){
  
  # Close any open connections
  
  closeAllConnections()
  
  
  ############################################## The file containing the executables
  
  MainFile <- file.path(User_Directory, EarnixProjectName, "CommandsFile.sh")
  
  
  ############################################## Outputs of AutoPricing_R, all are JSON files
  
  DataInfoFile <-  file.path(User_Directory, EarnixProjectName, "EarnixDataInfo.json") 
  ModelInfoFile <- file.path(User_Directory, EarnixProjectName, "EarnixModelInfo.json") 
  ParameterFile <- file.path(User_Directory, EarnixProjectName, "EarnixParametersTemplate.json") 
  ProjectInfoFile <- file.path(User_Directory, EarnixProjectName, "EarnixProjectInfo.json") 
  ReportInfoFile <- file.path(User_Directory, EarnixProjectName, "EarnixReportInfo.json")
  EarnixMainscriptArgs <- file.path(User_Directory, EarnixProjectName, "EarnixMainScriptArgs.json")
  
  ############################################## JavaScript files 
  
  earnix_load_template = file.path(Opt_Directory, "auto_pricing.js")
  earnix_load_data = file.path(Opt_Directory, "upload_data.js") 
  earnix_load_model = file.path(Opt_Directory, "upload_model.js")
  
  ############################################## This is where the data and models will be uploaded
  
  EarnixProjectFolder <- file.path(EarnixFolder, EarnixProjectName, fsep="\\" )
  # e.g. 
  # EarnixProjectFolder <- "\\\\Budget Group\\\\2019\\\\All\\\\Development\\\\Test\\2020-01 RAC PC ALL NBS TF_test"
  
  ############################################## 
  
  Out_Dir <- file.path(User_Directory, EarnixProjectName)
  print(paste0('Create the direcory, ', Out_Dir))
  dir.create(Out_Dir, showWarnings = FALSE)
  
  
  #*********************************************************************************************************#
  #                                                                                                         #
  # Setup Logging                                                                                        ####
  #                                                                                                         #
  #*********************************************************************************************************#
  
  AutoPricing_R_Log_Path <<- FileSerialNaming(Name = paste0(Out_Dir, "/4. Data Reports/", "AutoPricing_R-Logfile"), Type = "log")
  Log_Path <- AutoPricing_R_Log_Path
  
  capture_log <<- CaptureLog(Log_Path = AutoPricing_R_Log_Path, 
    Run_Location = Run_Location)
  
  eval(parse(text = capture_log$setup))
  
  PrintComment(capture_log$prefix, 1, 1, paste0("###########################################################"))
  PrintComment(capture_log$prefix, 1, 1, paste0("# Beginning AutoPricing_R Platform for Source: ", "Source_Appended"))
  PrintComment(capture_log$prefix, 1, 2, paste0("###########################################################"))
  
  PrintComment(capture_log$prefix, 1, 2, paste0("Crunch Log file location: ", AutoPricing_R_Log_Path))
  
  PrintComment(capture_log$prefix, 1, 1, paste0("###########################################################"))
  PrintComment(capture_log$prefix, 1, 1, paste0("# Section 0 - Preparation #################################"))
  PrintComment(capture_log$prefix, 1, 2, paste0("###########################################################"))
  
  # Print message to indicate beginning this stage
  
  PrintComment(capture_log$prefix, 1, 2, paste0("[", Sys.time(), "] Beginning (0) Preparation"))
  
  #*********************************************************************************************************#
  
  ############################################## Sourcing the functions
  
  PrintComment(capture_log$prefix, 1, 1, paste0("###########################################################"))
  PrintComment(capture_log$prefix, 1, 1, paste0("# Section 1 - Sourcing the Functions ######################"))
  PrintComment(capture_log$prefix, 1, 2, paste0("###########################################################"))

  source(paste0(Working_Directory, "/GenEearnixArgFile.R"))
  source(file.path(Working_Directory, "GenEearnixArgFile.R"))
  source(file.path(Working_Directory, "GetParameters.R")) 
  source(file.path(Working_Directory, "PrepareDatauploading.R"))
  source(file.path(Working_Directory, "UpdateDataDictionary.R"))
  source(file.path(Working_Directory, "GetEarnixMapping.R"))
  source(file.path(Working_Directory, "GetDataType.R"))
  source(file.path(Working_Directory, "FakeJson.R"))
  source(file.path(Working_Directory, "MakeModelsInfoFile.R"))
  source(file.path(Working_Directory, "MakeProjectInfoFile.R"))
  
  ############################################## Earnix project info file
 
  PrintComment(capture_log$prefix, 1, 1, paste0("###########################################################"))
  PrintComment(capture_log$prefix, 1, 1, paste0("# Section 1 - Preparation #################################"))
  PrintComment(capture_log$prefix, 1, 1, paste0("# Generating Project info file, EarnixProjectName #########"))
  PrintComment(capture_log$prefix, 1, 1, paste0("# ", EarnixProjectName))
  PrintComment(capture_log$prefix, 1, 2, paste0("###########################################################")) 
  #print(paste0('Generates the Project info file, EarnixProjectName, ', EarnixProjectName))
  
  MakeProjectInfoFile(Product, Transaction, EarnixProjectFolder, EarnixProjectName, EarnixFolder, ProjectInfoFile)
    
  ############################################## Earnix main arg file 
  
  PrintComment(capture_log$prefix, 1, 1, paste0("###########################################################"))
  PrintComment(capture_log$prefix, 1, 1, paste0("# Section 2 - Preparation #################################"))
  PrintComment(capture_log$prefix, 1, 1, paste0("# Generating Args info file, EarnixMainscriptArgs #########"))
  PrintComment(capture_log$prefix, 1, 1, paste0("# ", EarnixMainscriptArgs))
  PrintComment(capture_log$prefix, 1, 2, paste0("###########################################################"))   
  # print(paste0('Generates the Earnix Args file, EarnixMainscriptArgs, ', EarnixMainscriptArgs))
  
  GenEearnixArgFile(ProjectInfoFile, DataInfoFile, ModelInfoFile, ReportInfoFile, ParameterFile,
    EarnixMainscriptArgs)
  
  
  
  ############################################## Earnix template file
  
  if (CreateTemplate == 'Y'){
    
    PrintComment(capture_log$prefix, 1, 1, paste0("###########################################################"))
    PrintComment(capture_log$prefix, 1, 1, paste0("# Section 3 - Preparation #################################"))
    PrintComment(capture_log$prefix, 1, 1, paste0("# Creating Template file, ParameterFile ###################"))
    PrintComment(capture_log$prefix, 1, 1, paste0("# ", ParameterFile))
    PrintComment(capture_log$prefix, 1, 2, paste0("###########################################################"))    
    
    # print(paste0('Generates the Earnix Template file, EarnixParametersTemplate.json, ', ParameterFile))
    
    GetParameters(Product, Transaction, ParameterFile, ConfigsFile)
    
    TemplateCommand <- paste0('"', Eernix_Exe, '"', ' -script ', '"', earnix_load_template, '" "', EarnixMainscriptArgs, '"' )
    
    #cat(TemplateCommand, file= MainFile ,sep="\n")
    readr::write_lines(TemplateCommand, MainFile, sep = "\n")
    
  }
  
  
  ############################################## Earnix import data file(s)
  
  if (ImportData == 'Y'){

    PrintComment(capture_log$prefix, 1, 1, paste0("###########################################################"))
    PrintComment(capture_log$prefix, 1, 1, paste0("# Section 4 - Preparation #################################"))
    PrintComment(capture_log$prefix, 1, 1, paste0("# Creating DataInfo file, DataInfoFile ###################"))
    PrintComment(capture_log$prefix, 1, 1, paste0("# ", DataInfoFile))
    PrintComment(capture_log$prefix, 1, 2, paste0("###########################################################"))    
    
    
    print(paste0('Import data file(s), using EarnixDataInfo.json ', DataInfoFile))
    
    print('Following datafiles will be imported on Earnix, ')

    for(file in DataFiles){
      
      print(file)
      
    }
    
    PrepareDatauploading(Brand, Product, Transaction, DataDictionary,
      DataFiles, DataInfoFile, DatePattern)
      
    TemplateCommand <- paste0('"', Eernix_Exe, '"', ' -script ', '"', earnix_load_data, '" "', EarnixMainscriptArgs, '"' )
    
    #cat(TemplateCommand, file= MainFile ,sep="\n")
    readr::write_lines(TemplateCommand, MainFile, sep = "\n", append = TRUE)
    
  }
  
  
  
  ############################################## Earnix import model(s)
  
  if (ImportModel == 'Y'){
    
    
    print(paste0('Import model(s), using EarnixModelInfo.json ', ModelInfoFile))
    
    print('Following model files will be imported on Earnix, ')
    
    for(file in ModelFiles){
      
      print(file)
      
    }
    
    MakeModelsInfoFile(ModelFiles, ModelInfoFile)
    
    TemplateCommand <- paste0('"', Eernix_Exe, '"', ' -script ', '"', earnix_load_model, '" "', EarnixMainscriptArgs, '"' )
    
    readr::write_lines(TemplateCommand, MainFile, sep = "\n", append = TRUE)
    
  }
  
  
  closeAllConnections()
  
  
}




