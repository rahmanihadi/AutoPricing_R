#********************************************************************************************************************#
#                                                                                                                    #
# MakeModelsInfoFile                                                                                              ####
#                                                                                                                    #
# Generates the EarnixModelInfo.json required for importing models on an Earnix template                     #
#                                                                                                                    #
#********************************************************************************************************************#
MakeModelsInfoFile <- function(ModelFiles, ModelInfoFile){
  
  # ModelFiles <- c('C:/Users/HRahmaniBayegi/data_test\\RenewalDemand_H2OGLM_dummy_11.csv',
  #   'C:/Users/HRahmaniBayegi/data_test\\testtable.csv')
  # #ModelFiles <- c('C:/Users/HRahmaniBayegi/data_test/elf_model_test\\Orig_Elf1_200226_0807.csv')
  # ModelInfoFile <- "EarnixModelInfo.json"

  PrintComment(capture_log$prefix, 2, 2, paste0( "Available Models: "))
  
  for(i in 1:length(ModelFiles)){
    
    PrintComment(capture_log$prefix, 3, 2, paste0( as.character(i), "- ", ModelFiles[i]))
    
  }
  
  PrintComment(capture_log$prefix, 2, 2, paste0( "Making the ModelInfo: "))
  
  model_info <- list()
  seg_model_files <- list()
  models <- list()
  
  model_counter <- 1
  for (file in ModelFiles){
    
    PrintComment(capture_log$prefix, 3, 2, paste0('- The model file is: ', file))
    
    if ( grepl("Elf", basename(file), fixed = TRUE) ){
      
      PrintComment(capture_log$prefix, 4, 2, paste0('This is an Elf model file: Will be explored separately ...'))
      
      seg_model_files <- append(seg_model_files, file)
      
      model_counter <- model_counter + 1
      
      next
      
    }
    
    name_Without_ext <- tools::file_path_sans_ext(basename(file))
    ext <- tools::file_ext(file)
    file_info <- paste0(dirname(file),'/',name_Without_ext,'_Info.',ext)
    
    PrintComment(capture_log$prefix, 4, 2, paste0('The _Info is: ', file_info))
    
    df_model <- read.csv(file, stringsAsFactors = FALSE)
    df_info <- read.csv(file_info, stringsAsFactors = FALSE)
    
    # Dropping the Intercep
    
    mask <- df_model$Transformations != 'Intercept'
    df_model <- df_model[mask, ]
    
    # Renaming the two columns
    
    names(df_model)[names(df_model)=='Transformations'] <- 'formula'
    names(df_model)[names(df_model)=='Beta'] <- 'beta'
    
    # Re-organizing the dataframe in a shape that can be fed as json
    
    list_all <- NestedList(df_model)
    
    model = list('parameterName'= df_info$parameterName,
      'versionName'= df_info$versionName,
      'regressionType'= df_info$regressionType,
      'sample'= df_info$sample ,
      'filter' = df_info$filter,
      'dependentColumn'= df_info$dependentColumn,
      'transformations' = list_all)

    model_counter <- model_counter +1
    
    if(length(models) == 0){
      
      models <- list(model)
      
    } else{
      
      models <- append(models, list(model))
      
    } 
    
  }
  
  model_info[['GlmGamRegression']] = models
  
  
  # The rest is for the Elf models
  
  models <- list()
  models_formula <- list()
  overall_model_formula <- "IF_MULTI("
  overall_model_version_name <- NA
  overall_model_parameter_name <- NA
  overall_model_regression_type <- NA
  overall_model_sample <- NA
  overall_model_data_filter <- NA
  overall_model_dependent_col <- NA
  n_models <- length(seg_model_files)
  n <- 0
  
  sorted_files <- stringr::str_sort(seg_model_files)
  
  if(length(sorted_files != 0)){  
    
    PrintComment(capture_log$prefix, 2, 2, paste0( "Exploring the Elf Models: "))
      
  }
  
  for (file in sorted_files){
    
    PrintComment(capture_log$prefix, 3, 2, paste0(model_counter, '- The model file is: ', file))
    
    n <- n+1
    
    name_Without_ext <- tools::file_path_sans_ext(basename(file))
    ext <- tools::file_ext(file)
    file_info <- paste0(dirname(file),'/',name_Without_ext,'_Info.',ext)
    
    PrintComment(capture_log$prefix, 4, 2, paste0('The _Info is: ', file_info))
    
    df_model <- read.csv(file, stringsAsFactors = FALSE)
    df_info <- read.csv(file_info, stringsAsFactors = FALSE)
    
    # Renaming the columns 
    
    names(df_model)[names(df_model)=='Transformations'] <- 'formula'
    names(df_model)[names(df_model)=='Beta'] <- 'beta'
    
    formula <- "GET_GAM_RESPONSE(0, "
    mask <- df_model$formula == 'Intercept'
    formula <- paste0(formula, as.character(df_model[mask,'beta']))
    
    mask <- df_model$formula != 'Intercept'
    
    df_model <- df_model[mask, ]
    row.names(df_model) <- NULL
    
    # Generating the formula by stitching the strings using betas and transormations (engineered variables)
    for (i in 1:nrow(df_model)){
      
      transformation <- df_model[i, "formula"]
      beta <- df_model[i, "beta"]
      formula <- paste0(formula, ' + ', beta, '*(', transformation, ')')  
 
    }
    
    formula <- paste0(formula,')')
    
    PrintComment(capture_log$prefix, 4, 2, paste0('The formula is: ', formula))
    
    model <- list('parameterFolder' = "\\\\Split Models\\\\ELF",
      'parameterName'= df_info[1,'versionName'],
      'versionName'= 'GlmGamRegression - Formula',
      'formula'= formula)
    models_formula <- append(models_formula, list(model))
    
    # Overall model
    
    
    if(is.na(overall_model_version_name)){    # TRUE for the first model
      
      # removing the possible numbers/digits to have purely _elf_
      
      spl <- str_split(model['parameterName'], '_')[[1]]
      spl[grepl('elf', spl)] <- 'elf'
      overall_model_version_name <- paste(spl, collapse = '_')
      
      overall_model_parameter_name <- df_info[1,'parameterName']
      overall_model_regression_type <- df_info[1,'regressionType']
      overall_model_sample <- df_info[1, 'sample']
      overall_model_data_filter <- df_info[1, 'filter']
      overall_model_dependent_col <- df_info[1,'dependentColumn']
      
    }
    
    if (n < n_models){ 

      overall_model_formula <- paste0(overall_model_formula, df_info[1, 'mappedFilter'])
      overall_model_formula <- paste0(overall_model_formula, ', ',  " '", model['parameterName'], "'", ',')
      
    } else{
      
      overall_model_formula <- paste0(overall_model_formula, " '", model['parameterName'], "'")
      
    }
    
    list_all <- NestedList(df_model)

    # GlmGam regression
    
    model <- list('parameterName'= df_info[1,'versionName'],
      'versionName'= 'GlmGamRegression',
      'regressionType'= df_info[1,'regressionType'],
      'sample'= df_info[1,'sample'],
      'filter'= df_info[1,'filter'],
      'dependentColumn'= df_info[1,'dependentColumn'],
      'transformations'= list_all)
    
    models <- append(models, list(model))
    
  }

  if (length(seg_model_files) > 0){
    
    # strip ','s from both sides (https://stackoverflow.com/questions/10502787/removing-trailing-spaces-with-gsub-in-r)
    # This is supposed to do the rstrip in Python:         overall_model_formula = overall_model_formula.rstrip(',')
    # So it drops comas fro either side of it 
    overall_model_formula <- gsub("^,*|(?<= ) |,*$", "", overall_model_formula, perl=T)
    
    overall_model_formula <- paste0(overall_model_formula, ")")
    
    overall_model <- list()
    overall_model[['formula']] <- overall_model_formula
    overall_model[['beta']] <- 1  
    
    model <- list('parameterName'= overall_model_parameter_name,
      'versionName'= overall_model_version_name,
      'regressionType'= overall_model_regression_type,
      'sample'= overall_model_sample,
      'filter'= overall_model_data_filter,
      'dependentColumn'= overall_model_dependent_col,
      'transformations'= list(overall_model))
    
    models <- append(models, list(model))
    
  }

  
  model_info[['ElfFormula']] = models_formula
  model_info[['ElfGlmGam']] = models
  
  jsonlite::write_json(model_info, ModelInfoFile, pretty=TRUE, auto_unbox =T)
  
  
  return(model_info)
  

  
}




