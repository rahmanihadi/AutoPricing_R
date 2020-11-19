#********************************************************************************************************************#
#                                                                                                                    #
# GenEearnixArgFile                                                                                              ####
#                                                                                                                    #
# Generates the EarnixMainScriptArgs.json required for all Earnix actions                     #
#                                                                                                                    #
#********************************************************************************************************************#
GenEearnixArgFile <- function(ProjectInfoFile, DataInfoFile, ModelInfoFile, ReportInfoFile, ParameterFile,
  EarnixMainscriptArgs){
  
  # PrintComment(capture_log$prefix, 2, 2, paste0("[", Sys.time(), "] Beginning (3.1) ", EarnixMainscriptArgs))
  
  df <- data.frame(projectInfoFile=ProjectInfoFile, dataInfoFile=DataInfoFile, modelInfoFile=ModelInfoFile, 
    reportInfoFile=ReportInfoFile, parametersTemplateFile=ParameterFile)
  
  jsonlite::write_json(as.list(df), EarnixMainscriptArgs, pretty=TRUE, auto_unbox =T)
  
  # PrintComment(capture_log$prefix, 2, 2, paste0("[", Sys.time(), "] Completed (3.1) ", EarnixMainscriptArgs))
  
    
}