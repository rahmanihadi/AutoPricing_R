#********************************************************************************************************************#
#                                                                                                                    #
# WriteAsJson                                                                                              ####
#                                                                                                                    #
# Generates the output file as json                      #
#                                                                                                                    #
#********************************************************************************************************************#
import json
import pandas as pd

def WriteAsJson(param, file):
  
  if isinstance(param, pd.DataFrame):
    
    out = param.to_dict('records')
    print('we came here ')
    
  else: out = param
  
  with open(file, "w") as file_handle:
    
    json.dump(out, file_handle, indent=4)
    
  return out

def DFToDic(df):
  
  return df.to_dict('records')
