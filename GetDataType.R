#********************************************************************************************************************#
#                                                                                                                    #
# GetEarnixMapping                                                                                              ####
#                                                                                                                    #
# Returns a list of mapped variables                       #
#                                                                                                                    #
#********************************************************************************************************************#

GetDataType <- function(variables, data_dictionary){
  
  datypes <- list()
  varlist <- list()
  flist <- list()
  varlist_notmapped <- list()
  variables <- unique(variables)
  
  for( var in variables ){
    
    statement <- sum(startsWith(var, c("Dep_", "Filter_", "Dummy_", "Random", "Split")))
    if ( statement > 0 ){
      
      next
      
    }
    
    var_type <- data_dictionary[data_dictionary$Field == var, "Format"]
    if ( length(var_type)==1 ){ 
      
      if ( var_type == "Nominal_0" ){ var_type <- "Nominal" }
      if ( var_type == "Numeric" ){ var_type <- "Real" }
      if ( startsWith(var_type,'Misc_') & endsWith(var_type, '_Key') ){ var_type <- "Text" }
      if ( var_type != ""){
        
        datypes <- append(datypes, var_type)
        varlist <- append(varlist, var)
        tmplist <- list(c(var, var_type))
        flist <- append(flist, tmplist)
        
      }
      
    }
  
  }
  
  
  return(flist)

  #return(setNames( as.list(datypes), as.list(varlist)))
}