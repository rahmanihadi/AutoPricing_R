#********************************************************************************************************************#
#                                                                                                                    #
# GetEarnixMapping                                                                                              ####
#                                                                                                                    #
# Returns a list of mapped variables                       #
#                                                                                                                    #
#********************************************************************************************************************#
GetEarnixMapping <- function(variables, data_dictionary){
  
  mapping <- list()
  varlist <- list()
  flist <- list()
  varlist_notmapped <- list()
  variables <- unique(variables)
  
  for( var in variables ){
    
    statement <- sum(startsWith(var, c("Dep_", "Filter_", "Dummy_", "Random", "Split")))
    if ( statement > 0 ){
      
      next
      
    }
    
    var_mapping <- data_dictionary[data_dictionary$Field == var, "Earnix_Mapping"]
    if(length(var_mapping)==1){
      
      var_mapping <- var_mapping
      if(var_mapping != "Not Mapped" & var_mapping != "" ){
        
        mapping <- append(mapping, var_mapping)
        varlist <- append(varlist, var)
        tmplist <- list(c(var, var_mapping))
        flist <- append(flist, tmplist)       
      }
      
    }

    
    }
  
  return(flist)
  #return(setNames(as.list(mapping), as.list(varlist)))
  
}