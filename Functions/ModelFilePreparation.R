#********************************************************************************************************************#
#                                                                                                                    #
# ModelFilePreparation                                                                                            ####
#                                                                                                                    #
# Converts the ModelBot output, suitable for EarnixUploader                                                          #
#                                                                                                                    #
#********************************************************************************************************************#
#
#********************************************************************************************************************#
#                                                                                                                    #
# Possible next step modifications:                                                                               ####
#                                                                                                                    #
# Make it closer to the current style of Earnix model import where betas remains~1 after fitting                     #
#                                                                                                                    #
#********************************************************************************************************************#

ModelFilePreparation <- function(Model, Flag_Hybrid){

  Numcol <- ncol(Model)
  Numrow <- nrow(Model)
  
  if (Numcol == 1){
    
    # If this is a Hybrid model, we add an extra weight columns of ones
    
    if (Flag_Hybrid){
      
      Model[['beta']] <- rep(1.0, Numrow)
      
    } else {
      
      Spl_Bra <- strsplit(Model$formula, ')', fixed = TRUE)
      
      #Tr_Under_Rep <- gsub('[^[:alnum:][:blank:]) (<>\'+-=.?&/"\\-_]', "___", Model$formula)
      
      SplVar_1 <- Model$formula
      SplVar_2 <- Model$formula
      
      for (i in 1:Numrow){
        
        # Split in two parts based on '___'
        
        splited <- Spl_Bra[[i]]
        splited_Sub <- strsplit(splited, '*(', fixed = TRUE)[[length(splited)]]
        value <- splited_Sub[length(splited_Sub)]
        
        SplVar_2[i] <- value
        
        Remained <- splited[1:length(splited)-1]
        # Since the right brackets are stripped with add it and then join them 
        Trans <- paste0(paste0(Remained, ')') , collapse = '')
        
        # splited <- stringr::str_split(Tr_Under_Rep[i], "___", simplify=TRUE)
        SplVar_1[i] <-  Trans # The Transition column
        
        Mask_1 <- SplVar_1 == '(1)'
        SplVar_1[Mask_1] <- "(Intercept)"

      }
      
      # For Beta, gsub is used since there are only two brackets 
      
      SplVar_2 <- gsub("[()]", "", SplVar_2) # Will be still treated as string to avoid any round off issues and to be precisely same as the input
      
      # For Transitions, a more accuarte way can be done: Droping the first and the last character of the string using gsub
      # `^.` : To drop the first character. `.$`: To drop the last character string
      
      SplVar_1 <- gsub('^.|.$', '', SplVar_1) 
      
      Model$formula <- SplVar_1
      Model$beta <- SplVar_2
      
    }
    
  } 
  
  return(Model)
  
}