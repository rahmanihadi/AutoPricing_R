#********************************************************************************************************************#
#                                                                                                                    #
# NestedList                                                                                              ####
#                                                                                                                    #
# Converts a simple 2D dataframe (of strings) to a list that is suitable for json output                       #
#                                                                                                                    #
#********************************************************************************************************************#
NestedList <- function(dataframe){
  
  
  # keys_sub <- names(dataframe)
  
  list_all <- list()
  
  for (i in 1:nrow(dataframe)){
    
    tmp_i <- dataframe[i,]
    list_tmp <- list()
    
    # each row of tmp (tmp_i) is converted to a list (like Python dictionary)
    
    for (name in names(tmp_i)){
      
      list_tmp[[as.character(name)]] <- as.character(tmp_i[[name]])
      
    }
    
    list_all[[i]] <- list_tmp
    
  }
  
  return(list_all)

}