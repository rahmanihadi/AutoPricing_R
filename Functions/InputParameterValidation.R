#********************************************************************************************************************#
#                                                                                                                    #
# InputParameterValidation                                                                                        ####
#                                                                                                                    #
# Validate the input parameters provided by the user                                                                 #
#                                                                                                                    #
#********************************************************************************************************************#

InputParameterValidation <- function(Brand, Product, Transaction, Source, Submodels, filter, versionName,
                                     DatePattern, CreateTemplate, ImportData, ImportModel, ModelFit, 
                                     User_Directory, EarnixUploader_Working_Directory, EarnixUploader_Package_Directory,
                                     EarnixFolder, EarnixProjectName, Earnix_Exe,
                                     Data_Dictionary_Location, ConfigsFile, ParamasFile, 
                                     MakeTemplate, UploadData, UploadModels, CreatePricingVersion,
                                     ModelFiles, DataFiles) {
  
  options(warn=1)
  
  Updated_Parameters <- list()
  
  #*************************
  # Single Fixed Inputs ####
  #*************************
  
  # Those parameters that can only take one value from a fixed list of options
  
  Single_Fixed_Inputs <- list()
  
  Single_Fixed_Inputs$Product <- c("PC", "LC", "HH")  
  Single_Fixed_Inputs$Transaction <- c("NBS", "RNW")
  
  if (Transaction == "NBS") {
    
    Single_Fixed_Inputs$Source <- c("NBS", "RNW", "MTC", "Aquote")
    
  } else {
    
    Single_Fixed_Inputs$Source <- c("RNW", "MTC")
    
  }
  
  if (Source == "Aquote") {
    
    Single_Fixed_Inputs$Brand <- c("AG", "AT", "BA", "BBG", "BIS", "CS", "DB", "DIAL", "DIAL_PREM", "DIAL,DIAL_PREM", "DIAL_PREM,DIAL", "EC", "HL", "HS", "LG",
      "LT", "M&S", "M&S_PREM", "M&S,M&S_PREM", "M&S_PREM,M&S", "MT", "O2", "PE", "PO", "PO_PREM", "PO,PO_PREM", "PO_PREM,PO", 
      "QM", "RAC", "RAC_TELE", "SC", "SI", "SL", "YE", "ZE", "LT,HL")
    
    # Single_Fixed_Inputs$Channel <- c("AGG")
    
  } else {
    
    Single_Fixed_Inputs$Brand <- c("AG", "AT", "BA", "BBG", "BIS", "CS", "DB", "DIAL", "EC", "HL", "HS", "LG",
      "LT", "M&S", "MT", "O2", "PE", "PO", "QM", "RAC", "SC", "SI", "SL", "YE", 
      "ZE", "LT,HL")
    
    # Single_Fixed_Inputs$Channel <- c("ALL", "AGG", "TELE", "DIR")
    
  }
  
  Single_Fixed_Inputs$CreateTemplate <- c("Y", "N")
  Single_Fixed_Inputs$ImportData <- c("Y", "N")
  Single_Fixed_Inputs$ImportModel <- c("Y", "N")

  Single_Fixed_Inputs$DatePattern <- c("yyyy-mm-dd","yyyy-mm-dd")

  Single_Fixed_Inputs$MakeTemplate <- c(TRUE, TRUE)
  Single_Fixed_Inputs$UploadData <- c(FALSE, FALSE)
  Single_Fixed_Inputs$UploadModels <- c(FALSE, FALSE)
  Single_Fixed_Inputs$CreatePricingVersion <- c(FALSE, FALSE)

  # Call the SingleFixedInputCheck function on Single_Fixed_Inputs
  
  SingleFixedInputCheck(Inputs = Single_Fixed_Inputs)
  
  #***************************
  # Multiple Fixed Inputs ####
  #***************************
  
  # Those parameters that can take mutiple values from a fixed list of options
  
  Multiple_Fixed_Inputs <- list()
  
  Multiple_Fixed_Inputs$ModelFit <- c(TRUE, FALSE)
  
  if (Source == "NBS") {
    
    # Submodels applicable to both motor and home
    
    Multiple_Fixed_Inputs$Submodels <- c("Legal", "Switcher", "InverseSwitcher")
    
    # Submodels applicable to motor only
    
    if (Product %in% c("PC", "LC")) {
      
      Multiple_Fixed_Inputs$Submodels <- c(Multiple_Fixed_Inputs$Submodels, "PNCD", "GRC", "Breakdown", "KeyCare", "PAC")
      
    }
    
    # Submodels applicable to van only
    
    if (Product == "LC") {
      
      Multiple_Fixed_Inputs$Submodels <- c(Multiple_Fixed_Inputs$Submodels, "Tools")
      
    }
    
    # Submodels applicable to home only  
    
    if (Product == "HH") {
      
      Multiple_Fixed_Inputs$Submodels <- c(Multiple_Fixed_Inputs$Submodels, "KeyCover", "HEA")
      
    }
    
  } 
  
  if (Source == "RNW") {
    
    # Submodels applicable to both NBS and RNW Transaction
    
    Multiple_Fixed_Inputs$Submodels <- c("RenewalDemand", "NETDIF", "YOY")
    
    # Submodels applicable to RNW Transaction only
    
    if (Transaction == "RNW") {
      
      Multiple_Fixed_Inputs$Submodels <- c(Multiple_Fixed_Inputs$Submodels, "Discount")
      
    }
    
  }  
  
  if (Source == "MTC") {
    
    # Submodels applicable to both motor and home
    
    Multiple_Fixed_Inputs$Submodels <- c("MTA", "Cancellation")
    
    # Submodels applicable to motor only
    
    if (Product %in% c("PC", "LC")) {
      
      Multiple_Fixed_Inputs$Submodels <- c(Multiple_Fixed_Inputs$Submodels, "BadFee", "BadPrm")
      
    }
    
  } 
  
  if (Source == "Aquote") {
    
    Multiple_Fixed_Inputs$Submodels <- c("Origination")
    
  }
  
  
  # Call the MultipleFixedInputCheck function on Multiple_Fixed_Inputs
  
  MultipleFixedInputCheck(Inputs = Multiple_Fixed_Inputs)
  
  #*****************
  # File Inputs ####
  #*****************
  
  FileInputCheck(Input = Earnix_Exe, 
    Header = deparse(substitute(Earnix_Exe)))
  
  FileInputCheck(Input = User_Directory, 
    Header = deparse(substitute(User_Directory)))
  
  FileInputCheck(Input = EarnixUploader_Working_Directory, 
    Header = deparse(substitute(EarnixUploader_Working_Directory)))
  
  FileInputCheck(Input = EarnixUploader_Package_Directory, 
    Header = deparse(substitute(EarnixUploader_Package_Directory)))
  
  FileInputCheck(Input = Data_Dictionary_Location, 
    Header = deparse(substitute(Data_Dictionary_Location)))
  
  if (UploadModels == "Y"){
    
    FileInputCheck(Input = ModelFiles, 
      Header = deparse(substitute(ModelFiles)))
    
  }
  
  if (UploadData == "Y"){
    
    FileInputCheck(Input = DataFiles, 
      Header = deparse(substitute(DataFiles)))
    
  }
  
  if (CreateTemplate == 'Y'){
    
    FileInputCheck(Input = ConfigsFile, 
      Header = deparse(substitute(ConfigsFile)))
    
  }
  
}
