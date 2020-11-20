#********************************************************************************************************************#
#                                                                                                                    #
# EarnixUploader                                                                                              ####
#                                                                                                                    #
# Handles the inputs for the EarnixUploader over all the functions                       #
#                                                                                                                    #
#********************************************************************************************************************#

############################################## Basic inputs

Brand <- 'RAC'
Product <- 'PC'
Transaction <- 'NBS'
Source <- 'NBS'

DatePattern <- 'yyyy-mm-dd'

CreateTemplate <- "Y"  # if No: there must be already a template on Earnix at EarnixFolder, have the name EarnixProjectName
                        # if Yes: the template with EarnixProjectName will be created under EarnixFolder 
ImportData <- "Y" 
ImportModel <- "Y"

User_Directory <- "C:/Users/HRahmaniBayegi/outputs/autopricing/MyFirstTest_3-1" # Hosts the outputs
EarnixUploader_Package_Directory <- "C:/Users/HRahmaniBayegi/softs/pricing/EarnixUploader/EarnixUploader_R_Packages"
EarnixUploader_Working_Directory <- "C:/Users/HRahmaniBayegi/softs/pricing/EarnixUploader" # Hosts the R files

#Opt_Directory <- "C:/Users/HRahmaniBayegi/softs/pricing/EarnixUploader/Functions" # Hosts the .js files

############################################## Earnix stuff 

###################### Earnix exe file

Earnix_Exe = "C:/earnix-9112/rungui.bat"

###################### Earnix directory

EarnixFolder <- "\\\\Budget Group\\\\2019\\\\All\\\\Development\\\\Test"

###################### Earnix template name

EarnixProjectName <- "MyFirstTest_5" 

###################### The data dictionary for earnix mapping and data type

Data_Dictionary_Location <- "C:/Users/HRahmaniBayegi/softs/pricing/Dictionaries/DataDictionary/Data_Dictionary_v3.6.csv"

###################### WARNING: SHOULD NOT NOT CHANGE

MakeTemplate <- TRUE
UploadData <- FALSE
UploadModels <- FALSE
CreatePricingVersion <- FALSE

###################### Required for uploading models on Earnix (verfications required for the details)

ConfigsFile = "C:/Users/HRahmaniBayegi/softs/pricing/AutoPricing/Src/Configs/ParametersTable.csv"

############################################## Outputs of PricingPlatforms 

###################### Outputs of ModelBot with two columns of Transformation (variables) and beta (weights) 

ModelFiles <- c(#'C:/Users/HRahmaniBayegi/data_test/RenewalDemand_H2OGLM_dummy_11.csv',
  'C:/Users/HRahmaniBayegi/data_test//dummy_14_NBS/h2glm.csv') #,
  # 'C:/Users/HRahmaniBayegi/data_test/elf_model_test/Orig_Elf1_200226_0807.csv')

###################### An example one for Elf models

#ModelFiles <- c('C:/Users/HRahmaniBayegi/data_test/elf_model_test\\Orig_Elf1_200226_0807.csv')


###################### The data files to get uploaded on Earnix, ideally Crunch Final output. 
###################### Source will be found automatically, and the data will be uploaded under 
###################### that Earnix path

DataFiles <- c(#"C:/Users/HRahmaniBayegi/data_test\\\\RNW_RAC_PC_NBS_ALL - Final_dummy_11.csv", 
  # "C:/Users/HRahmaniBayegi/data_test\\\\NBS_RAC_PC_NBS_ALL - Final_1.csv",
  # "C:/Users/HRahmaniBayegi/data_test\\\\Crunch_RNW_RAC_PC_NBS_ALL - Final.csv",
  "P:/Hadi Rahmani/outputs/PricingPlatforms/dummy_14/3. Data/NBS/Crunch/Crunch_NBS_RAC_PC_NBS_ALL - Final.csv")

source("C:/Users/HRahmaniBayegi/softs/pricing/PricingPlatforms/General_Functions/0_GeneralFunctions.R")
source(file.path(EarnixUploader_Working_Directory, "Functions", "EarnixUploader.R"))

Run_Location <<- 'Pricing'

EarnixUploader(Brand, Product, Transaction, Source, DatePattern, CreateTemplate, ImportData,  ImportModel,
              User_Directory, EarnixUploader_Working_Directory, EarnixUploader_Package_Directory, 
              EarnixFolder, EarnixProjectName, Earnix_Exe,
              Data_Dictionary_Location, ConfigsFile,
              MakeTemplate, UploadData, UploadModels, CreatePricingVersion,
              ModelFiles, DataFiles,
              DataInfoFile, ModelInfoFile, ParameterFile, ProjectInfoFile, ReportInfoFile, EarnixMainscriptArgs)
