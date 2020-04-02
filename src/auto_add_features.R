add_features<-function(temp.Data){
    for(i in 1:ncol(temp.Data)){
      v <- numeric(length(temp.Data[,i]))
      moving.range <- numeric(length(temp.Data[,i]))
      mean.increase <- numeric(length(temp.Data[,i]))
      mean.decrease <- numeric(length(temp.Data[,i]))
      dispersion.increase <- numeric(length(temp.Data[,i]))
      mean.increase[1]<-0
      mean.decrease[1]<-0
      dispersion.increase[1]<-0
      moving.range[1]<-0
      v[1] <- (sqrt(abs(temp.Data[1,i]))-0.822)/0.349
      d<-0.5
      for(k in 2:length(temp.Data[,i])) {
        moving.range[k] <- abs(temp.Data[k,i]-temp.Data[(k-1),i])
        v[k] <- (sqrt(abs(temp.Data[k,i]))-0.822)/0.349
        if ( mean.increase[k]>5){mean.increase[k] <- max(0,(temp.Data[k,i]-d+0))}
        else {mean.increase[k] <- max(0,(temp.Data[k,i]-d+mean.increase[k-1]))}
        if ( mean.decrease[k]>5){mean.decrease[k] <- max(0,(-d-temp.Data[k,i]+0))}
        else {mean.decrease[k] <- max(0,(-d-temp.Data[k,i]+mean.decrease[k-1]))}
        if ( dispersion.increase[k]>5){dispersion.increase[k] <- max(0,(v[k]-d+0))}
        else {dispersion.increase[k] <- max(0,(v[k]-d+dispersion.increase[k-1]))}
      
        # mean.increase[k] <- max(0,(temp.Data[k,i]-d+mean.increase[k-1]))
        # mean.decrease[k] <- max(0,(-d-temp.Data[k,i]+mean.decrease[k-1]))
        # dispersion.increase[k] <- max(0,(v[k]-d+dispersion.increase[k-1]))
      }
      addfeatures<-cbind(moving.range,mean.increase,mean.decrease, dispersion.increase)
      #addfeatures<-cbind(MR,CUSUMpoz.m,CUSUMneg.m)
      colnames(addfeatures) <- paste(colnames(temp.Data)[i], colnames(addfeatures), sep = ".")
      temp.Data<-cbind(temp.Data,addfeatures) # full dataset with external features
    }
  return(temp.Data)
}
