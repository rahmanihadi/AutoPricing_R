#********************************************************************************************************************#
#                                                                                                                    #
# EarnixUploaderInput                                                                                             ####
#                                                                                                                    #
# Calls the EarnixUploader with the relevant input parameters                                           #
#                                                                                                                    #
#********************************************************************************************************************#

#*********************************************************************************************************#
#                                                                                                         #
# Common inputs over all Platforms                                                                        ####
#                                                                                                         #
#*********************************************************************************************************#

Brand <- 'RAC'
Product <- 'PC'
Transaction <- 'NBS'
Source <- 'RNW'

Submodels <- "c('RenewalDemand', 'NETDIF', 'YOY')"
Filters <- c("'Split_RenewalDemand'=\"Train\"", 
             "OR('Split_NETDIF'=\"Train\",'Split_NETDIF'=\"Test\")", 
             "AND('Split_YOY'=\"Train\",'YOY'>0)")

VersionNames <- c('Hybrid_RenewalDemand_0.2_Fit', 
                  'GLMNet_NETDIF_0.2_Cons', 
                  'Hybrid_YOY_0.2_Fit')

ModelFit <- "c(TRUE, FALSE, TRUE)" # IF TRUE {beta's are released to be fit by Earnix} else {beta's are constrained at ModelBot unless it is Hybrid}
#Drop_NoMapping <- "c(FALSE, FALSE, FALSE)" # IF TRUE, drops variables without mapping if they present in the model. This makes sense if the dataset is introduced.

Data_Dictionary_Location <- "C:/Users/HRahmaniBayegi/softs/pricing/Dictionaries/DataDictionary/Data_Dictionary_v3.6.csv"

User_Directory <- "C:/Users/HRahmaniBayegi/outputs/autopricing/MyFirstTest_4.0" # Hosts the outputs

#*********************************************************************************************************#
#                                                                                                         #
# Similar inputs to other Platforms                                                                    ####
#                                                                                                         #
#*********************************************************************************************************#

EarnixUploader_Package_Directory <- "C:/Users/HRahmaniBayegi/softs/pricing/EarnixUploader/EarnixUploader_R_Packages" # Hosts the R files
EarnixUploader_Working_Directory <- "C:/Users/HRahmaniBayegi/softs/pricing/EarnixUploader" 

#*********************************************************************************************************#
#                                                                                                         #
# EarnixUploader value inputs                                                                          ####
#                                                                                                         #
#*********************************************************************************************************#

DatePattern <- 'yyyy-mm-dd'

CreateTemplate <- "Y"  # if No: there must be already a template on Earnix at EarnixFolder, have the name EarnixProjectName
ImportData <- "Y" 
ImportModel <- "Y"

EarnixProjectName <- "MyFirstTest_6" # Name of the Earnix template (Either to be created or existed)

Earnix_Exe = "C:/earnix-9112/rungui.bat"

EarnixFolder <- "\\\\Budget Group\\\\2019\\\\All\\\\Development\\\\Test"

ConfigsFile = "C:/Users/HRahmaniBayegi/softs/pricing/EarnixUploader/Configs/ParametersTable.csv"
ParamasFile = "C:/Users/HRahmaniBayegi/softs/pricing/EarnixUploader/Configs/ParametersNames.csv"

#*********************************************************************************************************#
#                                                                                                         #
# Not to be changed for the time being                                                                 ####
#                                                                                                         #
#*********************************************************************************************************#

MakeTemplate <- TRUE
UploadData <- FALSE
UploadModels <- FALSE
CreatePricingVersion <- FALSE

#*********************************************************************************************************#
#                                                                                                         #
# Inputs to be provided by the Crunch/ModelBot                                                         ####
#                                                                                                         #
#*********************************************************************************************************#

ModelFiles <- c(
               "P:/Hadi Rahmani/outputs/PricingPlatforms/dummy_15/5. ModelBot/Models/RNW/RenewalDemand/Hybrid/Variables.csv",
               "P:/Hadi Rahmani/outputs/PricingPlatforms/dummy_15/5. ModelBot/Models/RNW/NETDIF/GLMNet/Variables.csv",
               "P:/Hadi Rahmani/outputs/PricingPlatforms/dummy_15/5. ModelBot/Models/RNW/YOY/Hybrid/Variables.csv"
               )

#ModelFiles <- c('C:/Users/HRahmaniBayegi/data_test/elf_model_test\\Orig_Elf1_200226_0807.csv')

DataFiles <- c(#"C:/Users/HRahmaniBayegi/data_test\\\\RNW_RAC_PC_NBS_ALL - Final_dummy_11.csv", 
  # "C:/Users/HRahmaniBayegi/data_test\\\\NBS_RAC_PC_NBS_ALL - Final_1.csv",
  #"P:/Hadi Rahmani/outputs/PricingPlatforms/dummy_14/3. Data/NBS/Crunch/Crunch_NBS_RAC_PC_NBS_ALL - Final.csv")
  "P:/Hadi Rahmani/outputs/PricingPlatforms/dummy_15/3. Data/RNW/Crunch/Crunch_RNW_RAC_PC_NBS_ALL - Final.csv")
  
#*********************************************************************************************************#
#                                                                                                         #
# Source 0_GeneralFunctions.R and EarnixUploader                                                       ####
#                                                                                                         #
#*********************************************************************************************************#

source("C:/Users/HRahmaniBayegi/softs/pricing/PricingPlatforms/General_Functions/0_GeneralFunctions.R")
source(file.path(EarnixUploader_Working_Directory, "Functions", "EarnixUploader.R"))

Run_Location <<- 'Pricing'

EarnixUploader(Brand, Product, Transaction, Source, Submodels, Filters, VersionNames,
               DatePattern, CreateTemplate, ImportData,  ImportModel, ModelFit, 
               User_Directory, EarnixUploader_Working_Directory, EarnixUploader_Package_Directory, 
               EarnixFolder, EarnixProjectName, Earnix_Exe,
               Data_Dictionary_Location, ConfigsFile, ParamasFile,
               MakeTemplate, UploadData, UploadModels, CreatePricingVersion,
               ModelFiles, DataFiles)
