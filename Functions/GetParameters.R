#********************************************************************************************************************#
#                                                                                                                    #
# GetParameters                                                                                              ####
#                                                                                                                    #
# Generates the Parmeters Template file required for making a template on Earnix                      #
#                                                                                                                    #
#********************************************************************************************************************#
GetParameters <- function(Product, Transaction, ParameterFile, ConfigsFile){

  #### Self working example inputs
  #ParameterFile <- "C:/Users/HRahmaniBayegi/softs/pricing/AutoPricing_R/EarnixParametersTemplate.json"
  #ConfigsFile = "C:/Users/HRahmaniBayegi/softs/pricing/AutoPricing/Src/Configs/ParametersTable.csv"
  #Product <- 'PC'
  #Transaction <- 'NBS'
  
  Product <- ifelse(Product == 'PC' | Product == 'LC', 'PCLC', Product) 

  prod_trans <- paste(c(Product, Transaction), collapse = '_')
  formula <- paste(c('Formula',prod_trans), collapse = '_')

  all_table = read.csv(ConfigsFile, stringsAsFactors = FALSE)
  
  mask <- (all_table$CustomParameter == "Y") & (all_table[[prod_trans]] == "Y")
  
  param_table <- all_table[mask, c('Parameter', 'ParameterComment', 'DataType', 'Version', formula, 'Folder')]

  param_table$Version <- sub("^$", "NA", param_table$Version)  
  param_table$ParameterComment <- sub("^$", "NA", param_table$ParameterComment)
  
  names(param_table)[names(param_table)==formula] <- 'Formula'
  
  keys <- unique(param_table$Folder)

  param_out <- list()
  custom_param <- list()
  
  # loop over the unique folders 
  
  for (key in keys){
    
    mask <- param_table$Folder == key
    tmp <- param_table[mask,]
    
    if (grepl("\\", key, fixed = TRUE)){
      
      library(stringr)
      key_1 <- gsub("\\\\", "___",key)
      splited <- str_split(key_1, "__", simplify=TRUE)
      folder <- splited[1] 
      
      n_exist <- grep(paste0("^",folder,'$'), keys)

      if (length(n_exist) == 0){
        
        custom_param[[folder]] <- list()
        
      }
      
      DoLoop <- ifelse(length(splited)>2, c(1:length(splited)-1), 'BETE' )
      if (DoLoop=='BETE'){ DoLoop<- seq_len(0)}
      
      for(i in DoLoop){
        
        folder <- paste(c(folder,splited[i]), collapse = '\\') # "{}\\{}".format(folder, splited[i])
        n_exist_1 <- sum(grepl(folder, keys, fixed = TRUE))
        
        if (n_exist_1 !=0 ){
          
          print(paste0('Empty folder created, ',folder))
          
          custom_param[[folder]] <- list()
          
        }
        
      }
      
    }    
    
    list_all <- NestedList(tmp)
    
    custom_param[[as.character(key)]] <- list_all
    
  }

  param_out[['CustomParameters']] = custom_param

  # Core parameters
  
  mask_core <- all_table$Folder == 'CoreParameters' & all_table[[prod_trans]] == 'Y'
  
  param_table <-  all_table[mask_core, c('Parameter', formula)]
  
  names(param_table)[names(param_table)==formula] <- 'Formula'
  
  # converting the dataframe into a list
  
  list_all <- NestedList(param_table)
  
  param_out[['CoreParameters']] <- list_all 
  
  # Pricing behavior of the parameters
  
  mask_dummy <- all_table$Folder == 'PricingBehavior' & all_table[[prod_trans]] == 'Y'
  
  param_table <- all_table[mask_dummy, c('Parameter', formula)]
  
  param_table[[formula]] <- sub("^$", "0", param_table[[formula]])  
  
  names(param_table)[names(param_table)==formula] <- 'Formula'
  
  # Dummy parameter for creating behavior parameters
  
  Dummy_Behavior <- ""
  
  for (par in param_table$Parameter){
    
    if (Dummy_Behavior == ""){
      
      Dummy_Behavior <- paste0("'",par,"'")  
      
    } else {
      
      Dummy_Behavior <- paste0(Dummy_Behavior, "+'",par,"'")
      
    }
    
  }
  
  
  df_dummy <- data.frame('Parameter' = 'DummyForBehavior', 'Formula' = Dummy_Behavior, 'DataType' = 'Real')
  list_dummy <- list()
  for (name in names(df_dummy)){list_dummy[[name]] <- df_dummy[[name]]}
  
  param_out[['DummyForBehavior']] = list_dummy
  
  list_all <- NestedList(param_table)

  param_out[['BehaviorParameters']] = list_all
  
  # Some parameters have more than one modeling version
  
  max_version <- max(all_table$NbrVersions, na.rm = TRUE) 

  alter_version <- list()
  
  for (ver in c(2:max_version)){
    formula <- paste0('Formula', ver, '_', prod_trans)
    version <- paste0("Version",ver)
    mask_ver <- all_table$NbrVersions >= 2 & all_table[[prod_trans]] == 'Y'
 
    param_table <- all_table[mask_ver, c('Parameter', version, formula)]
    param_table[param_table==""] <-NA
    param_table <- param_table[complete.cases(param_table[ , 3]),]
    
    names(param_table)[names(param_table)==formula] <- 'Formula'
    names(param_table)[names(param_table)==version] <- 'Version'

    list_all <- NestedList(param_table)
    key <- paste0("Version_", as.character(ver))
    alter_version[[key]] <- list_all
    
  }
  
  param_out[['AlternativeVersions']] = alter_version
  
  jsonlite::write_json(param_out, ParameterFile, pretty=TRUE, auto_unbox =T)

  #return(param_out)
  
}