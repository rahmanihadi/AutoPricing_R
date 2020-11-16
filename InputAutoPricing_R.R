#********************************************************************************************************************#
#                                                                                                                    #
# InputAutoPricing_R                                                                                              ####
#                                                                                                                    #
# Handles the inputs for the autopricing over all the functions                       #
#                                                                                                                    #
#********************************************************************************************************************#

############################################## Basic inputs

Brand <- 'RAC'
Product <- 'PC'
Transaction <- 'NBS'

DatePattern <- 'yyyy-mm-dd'

CreateTemplate <- "Y"  # if No: there must be already a template on Earnix at EarnixFolder, have the name EarnixProjectName
                        # if Yes: the template with EarnixProjectName will be created under EarnixFolder 

ImportData <- "Y" 

ImportModel <- "Y"

User_Directory <- "C:/Users/HRahmaniBayegi/outputs/autopricing" # Hosts the outputs

Working_Directory <- "C:/Users/HRahmaniBayegi/softs/pricing/AutoPricing_R" # Hosts the R files

Opt_Directory <- "C:/Users/HRahmaniBayegi/softs/pricing/AutoPricing_0.6.3/Optimization" # Hosts the .js files

############################################## Earnix stuff 

###################### Earnix exe file

Eernix_Exe = "C:/earnix-9112/rungui.bat"

###################### Earnix directory

EarnixFolder <- "\\\\Budget Group\\\\2019\\\\All\\\\Development\\Test"

###################### Earnix template name

EarnixProjectName <- "MyFirstTest_3" 

###################### The data dictionary for earnix mapping and data type

DataDictionary <- "C:/Users/HRahmaniBayegi/softs/pricing/Dictionaries/DataDictionary/Data_Dictionary_v3.6.csv"

###################### WARNING: SHOULD NOT NOT CHANGE

MakeTemplate <- TRUE
UploadData <- FALSE
UploadModels <- FALSE
CreatePricingVersion <- FALSE

###################### Required for uploading models on Earnix (verfications required for the details)

ConfigsFile = "C:/Users/HRahmaniBayegi/softs/pricing/AutoPricing/Src/Configs/ParametersTable.csv"


############################################## Outputs of PricingPlatforms 

###################### Outputs of ModelBot with two columns of Transformation (variables) and beta (weights) 

ModelFiles <- c('C:/Users/HRahmaniBayegi/data_test\\RenewalDemand_H2OGLM_dummy_11.csv',
  'C:/Users/HRahmaniBayegi/data_test\\testtable.csv')

###################### An example one for Elf models

#ModelFiles <- c('C:/Users/HRahmaniBayegi/data_test/elf_model_test\\Orig_Elf1_200226_0807.csv')


###################### The data files to get uploaded on Earnix, ideally Crunch Final output. 
###################### Source will be found automatically, and the data will be uploaded under 
###################### that Earnix path

DataFiles <- c("C:/Users/HRahmaniBayegi/data_test\\\\RNW_RAC_PC_NBS_ALL - Final_dummy_11.csv") #, 
  # "C:/Users/HRahmaniBayegi/data_test\\\\NBS_RAC_PC_NBS_ALL - Final_1.csv", 
  # "C:/Users/HRahmaniBayegi/data_test\\\\Crunch_RNW_RAC_PC_NBS_ALL - Final.csv")

source("P:/PricingPlatforms/General_Functions/0_GeneralFunctions.R")
source(file.path(Working_Directory, "AutoPricing_R.R"))

Run_Location <<- 'Pricing'

AutoPricing_R(Brand, Product, Transaction, DatePattern, CreateTemplate, ImportData,  ImportModel,
  User_Directory, Working_Directory, Opt_Directory, 
  EarnixFolder, EarnixProjectName, Eernix_Exe,
  DataDictionary, ConfigsFile,
  MakeTemplate, UploadData, UploadModels, CreatePricingVersion,
  ModelFiles, DataFiles,
  DataInfoFile, ModelInfoFile, ParameterFile, ProjectInfoFile, ReportInfoFile, EarnixMainscriptArgs)
