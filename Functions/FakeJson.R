FakeJson <- function(Process, Variable){

  cat(paste0('"',Process,'": [\n'))
  for(i in 1:(length(Variable)-1)){
    item <- Variable[[i]]
    cat('[\n')
    cat(paste0('"',item[[1]],'"',',\n'))
    cat(paste0('"',item[[2]],'"\n'))
    cat('],\n')
  }
  cat('[\n')
  cat(paste0('"',Variable[[i+1]][[1]],'"',',\n'))
  cat(paste0('"',Variable[[i+1]][[2]],'"\n'))
  cat(']\n')    
  cat('],\n')
  return()
  
}