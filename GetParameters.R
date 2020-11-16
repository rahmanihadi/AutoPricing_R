#********************************************************************************************************************#
#                                                                                                                    #
# GetParameters                                                                                              ####
#                                                                                                                    #
# Generates the Parmeters Template file required for making a template on Earnix                      #
#                                                                                                                    #
#********************************************************************************************************************#
GetParameters <- function(Product, Transaction, ParameterFile, ConfigsFile){
  closeAllConnections()
  
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
  
  # library(Dict)
  # library(reticulate)
  # WJ <- import("WriteAsJson")
  # custom_param <- dict()
  # param_out = {}
  # 
  # for (key in keys){
  #   
  #   mask <- param_table$Folder == key
  #   group <- param_table[mask,]
  #   
  #   if (grepl("\\", key, fixed = TRUE)){
  #     library(stringr)
  #     splited <- str_split(keys[2], "\\\\", simplify=TRUE)
  #     folder <- splited[1]
  #     n_exist <- sum(grepl(folder, keys, fixed = TRUE))
  #     
  #     if (n_exist == 0){
  #       
  #       custom_param[folder] <- dict()
  #       
  #     }
  #     
  #     DoLoop <- ifelse(length(splited)>2, c(1:length(splited)-1), 'BETE' )
  #     if (DoLoop=='BETE'){ DoLoop<- seq_len(0)}
  #     for(i in DoLoop){
  #       
  #       folder <- paste(c(folder,splited[i]), collapse = '\\') # "{}\\{}".format(folder, splited[i])
  #       n_exist_1 <- sum(grepl(folder, keys, fixed = TRUE))
  #       if (n_exist_1 !=0 ){custom_param[folder] <- dict()}
  #       
  #     }
  #   }
  #  
  #   custom_param[paste(key)] <- group
  #   
  # }
  # custom_param['CoreParam'] <- param_table

  # param_table['ParameterComment'].fillna("NA", inplace=True)
  # param_table['Version'].fillna("NA", inplace=True)
  # param_table.rename({formula: 'Formula'}, axis='columns', inplace=True)
  # param_table = param_table.groupby(['Folder'])
  # param_out = {}
  # custom_param = {}
  # 
#  sink('test.json')
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
      #print(n_exist)
      if (length(n_exist) == 0){
        
        #print(paste0('Empty folder created, ',folder))
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
    
    
    
    keys_sub <- names(tmp)
    
    list_all <- list()
    
   # print(paste0('the Folder is :', key))
    #print(paste0('The number of occurance is: ',nrow(tmp)))
    
    for (i in 1:nrow(tmp)){
      
      tmp_i <- tmp[i,]
      list_tmp <- list()
      
      # each row of tmp (tmp_i) is converted to a list (like Python dictionary)
      
      for (name in keys_sub){
        
        list_tmp[[as.character(name)]] <- as.character(tmp_i[[name]])
        
      }
      
      list_all[[i]] <- list_tmp
      
    }
    
    custom_param[[as.character(key)]] <- list_all
    
  }
  
  param_out[['CustomParameters']] = custom_param

  closeAllConnections()  
  
  # Core parameters
  
  mask_core <- all_table$Folder == 'CoreParameters' & all_table[[prod_trans]] == 'Y'
  
  param_table <-  all_table[mask_core, c('Parameter', formula)]
  
  names(param_table)[names(param_table)==formula] <- 'Formula'
  
  # converting the dataframe into a list
  
  list_all <- list()
  for (i in 1:nrow(param_table)){
    
    tmp_i <- param_table[i,]
    list_tmp <- list()
    
    # each row of tmp (tmp_i) is converted to a list (like Python dictionary)
    
    for (name in names(tmp_i)){
      
      list_tmp[[as.character(name)]] <- as.character(tmp_i[[name]])
      
    }
    
    list_all[[i]] <- list_tmp
  }
  
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
  
  
  list_all <- list()
  
  for (i in 1:nrow(param_table)){
    
    tmp_i <- param_table[i,]
    list_tmp <- list()
    
    # each row of tmp (tmp_i) is converted to a list (like Python dictionary)
    
    for (name in names(tmp_i)){
      
      list_tmp[[as.character(name)]] <- as.character(tmp_i[[name]])
      
    }
    
    list_all[[i]] <- list_tmp
  }
  
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
    #print(nrow(param_table))
    names(param_table)[names(param_table)==formula] <- 'Formula'
    names(param_table)[names(param_table)==version] <- 'Version'
    #print(nrow(param_table))
    list_all <- list()
    
    for (i in 1:nrow(param_table)){
      
      tmp_i <- param_table[i,]
      list_tmp <- list()
      
      # each row of tmp (tmp_i) is converted to a list (like Python dictionary)
      
      for (name in names(tmp_i)){
        
        list_tmp[[as.character(name)]] <- as.character(tmp_i[[name]])
        
      }
      
      list_all[[i]] <- list_tmp
    }
    
    key <- paste0("Version_", as.character(ver))
    alter_version[[key]] <- list_all
    
  }
  param_out[['AlternativeVersions']] = alter_version

  
  # param_out['AlternativeVersions'] = alter_versions
  
  
  jsonlite::write_json(param_out, ParameterFile, pretty=TRUE, auto_unbox =T)

  #return(param_out)
  
}