#********************************************************************************************************************#
#                                                                                                                    #
# MakeProjectInfoFile                                                                                              ####
#                                                                                                                    #
# Generates the EarnixMainScriptArgs.json required for all Earnix actions                     #
#                                                                                                                    #
#********************************************************************************************************************#
GenEearnixArgFile <- function(ProjectInfoFile, DataInfoFile, ModelInfoFile, ReportInfoFile, ParametersTemplateFile,
  EarnixMainscriptArgs){
  
  library(rjson)
  
  ProjectInfoFile <-  "C:\\Users\\HRahmaniBayegi\\softs\\pricing\\AutoPricing_R\\EarnixProjectInfo.json"
  DataInfoFile <-     "C:\\Users\\HRahmaniBayegi\\softs\\pricing\\AutoPricing_R\\EarnixDataInfo.json"
  ModelInfoFile <-    "C:\\Users\\HRahmaniBayegi\\softs\\pricing\\AutoPricing_R\\EarnixModelInfo.json"
  ReportInfoFile <-   "C:\\Users\\HRahmaniBayegi\\softs\\pricing\\AutoPricing_R\\EarnixReportInfo.json"
  ParametersTemplateFile <- "C:\\Users\\HRahmaniBayegi\\softs\\pricing\\AutoPricing_R\\EarnixParametersTemplate.json"
  EarnixMainscriptArgs <- "C:/Users/HRahmaniBayegi/softs/pricing/AutoPricing_R/EarnixMainScriptArgs.json"
  
  
  df <- data.frame(projectInfoFile=ProjectInfoFile, dataInfoFile=DataInfoFile, modelInfoFile=ModelInfoFile, 
    reportInfoFile=ReportInfoFile, parametersTemplateFile=ParametersTemplateFile)
  
  jsonlite::write_json(as.list(df), EarnixMainscriptArgs, pretty=TRUE, auto_unbox =T)
    
}