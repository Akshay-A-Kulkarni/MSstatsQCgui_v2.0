robust.scale<-function(sample_data_k){
  for(i in 1:ncol(sample_data_k)){
    sample_data_k[,i]=(sample_data_k[,i]-median(sample_data_k[,i]))/mad(sample_data_k[,i])
  }
  return(sample_data_k)
}