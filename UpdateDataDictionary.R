#********************************************************************************************************************#
#                                                                                                                    #
# UpdateDataDictionary                                                                                              ####
#                                                                                                                    #
# Returns the portion of the DataDictionary suitable for a given source and datatable                      #
#                                                                                                                    #
#********************************************************************************************************************#

UpdateDataDictionary <- function(Brand, Product, Transaction, Source, data_dictionary){
  
  xx1 <- data_dictionary[grepl(Brand, data_dictionary[["Brand"]]) | grepl("ALL", data_dictionary[["Brand"]]), ]
  DD0 <- xx1[grepl(Transaction, xx1[["Transaction"]]) & grepl(Product, xx1[["Product"]]) & grepl(Source, xx1[["Source"]]), ]
  
  # rename those Status=Rename but Type not equal to Review
  
  PrintComment(capture_log$prefix, 4, 2, paste0('Renaming `Field`s satisfying : ', '`Status` == "Rename" & `Type` != "Review"', ' to `Live_Name`'))
 
  DD0_keep <- DD0
  
  mask <- (DD0$Status == "Rename") & (DD0$Type != "Review")
  DD0[mask, "Field"] <- DD0[mask, "Live_Name"]
  
  DD0_keep_p <- DD0_keep[mask, ]
  DD0_p <- DD0[mask, ]
  
  for(i in 1:nrow(DD0_p)){
    
    PrintComment(capture_log$prefix, 5, 2, paste0(c(DD0_keep_p[i, "Field"], DD0_p[i, "Field"]), collapse = ' --> '))
    
  }
  
  # Those of Type = "Review" are renamed to "Review_" + "Live_Name"
  
  PrintComment(capture_log$prefix, 4, 2, paste0('Renaming `Field`s satisfying :' , '`Type` == "Review"',' to Review_`Live_Name`'))
  
  DD0_keep <- DD0
  
  mask = DD0$Type == "Review"
  DD0_keep_p <- DD0_keep[mask, ]
  DD0_p <- DD0[mask, ]
  
  if(sum(mask) !=0){
    
    DD0[mask, "Field"] <-  paste0("Review_", DD0[mask, "Live_Name"])
    
  } 
  
  for(i in 1:nrow(DD0_p)){
    
    PrintComment(capture_log$prefix, 5, 2, paste0(c(DD0_keep_p[i, "Field"], DD0_p[i, "Field"]), collapse = ' --> '))
    
  }
  
  # selecting only seven columns 
  
  NotYetThere <- DD0[, c("Field", "Live_Name", "Earnix_Mapping", "Type", "Format", "Missing_Value", "Submodel")]
  
  # dropping the duplicated rows 
  
  UpdateDictionary <- unique(NotYetThere)

  return(UpdateDictionary)
  
}