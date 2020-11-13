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
  mask <- (DD0$Status == "Rename") & (DD0$Type != "Review")
  DD0[mask, "Field"] <- DD0[mask, "Live_Name"]
  
  # Those of Type = "Review" are renamed to "Review_" + "Live_Name"

  mask = DD0$Type == "Review"
  if(sum(mask) !=0){DD0[mask, "Field"] <-  paste0("Review_", DD0[mask, "Live_Name"])} 
  
  # selecting only seven columns 
  NotYetThere <- DD0[, c("Field", "Live_Name", "Earnix_Mapping", "Type", "Format", "Missing_Value", "Submodel")]
  
  # dropping the duplicated rows 
  UpdateDictionary <- unique(NotYetThere)

  return(UpdateDictionary)
}