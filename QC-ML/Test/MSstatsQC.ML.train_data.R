
# Step shift --------------------------------------------------------------

QcClassifier_data_step <- function(guide.set,nmetric,factor.names,sim.size,peptide.colname, L, U){
  
  if(!is.factor(guide.set[,paste(peptide.colname)])){
    guide.set$peptide <-as.factor(new_data$peptide.colname)  
  }
  #factorial matrix  
  factorial <- FrF2(2^nmetric, nmetric,factor.names=colnames(guide.set[,3:ncol(guide.set)]))
  
  
  tag_neg <- 0
  data <- data.frame(NULL)
  
  for(i in 1:nrow(factorial)){
    data.set <- data.frame(NULL)
    if(all(factorial[i,]== rep(-1,nmetric))){
      ####### In cntrol observation ~ 5* sim size  the of the actual 
      sample_data_k <- sample_density(guide.set, sim.size*(2^(nmetric)-1))
    }
    
    else{
      ###### Base Data set to begin with 
      sample_data_k <- sample_density(guide.set, sim.size)
      #sample_data_k <- robust.scale(sample_data_k)
      
      for(j in 1:ncol(sample_data_k)){
        #change in a metric for some peptides
        if(factorial[i,j]== "1" & colnames(factorial[i,j])==colnames(sample_data_k)[j]){ 
          beta=runif(sim.size,L,U)
          sample_data_k[,j] <- sample_data_k[,j] + beta*mad(sample_data_k[,j])
          tag_neg <- 1 
          
        }# column ends 
      }
    }
    data.set <- rbind(data.set,add_features(sample_data_k))
    #data.set[,"peptide"] <- NULL 
    if(tag_neg == 1){
      data.set$RESPONSE <- c("FAIL")
      tag_neg <- 0
    }
    else{
      data.set$RESPONSE <- c("PASS")
    }
    data <- data[,order(names(data))]
    data.set <- data.set[,order(names(data.set))]
    data <-rbind(data,data.set)
  }
  
  data <- data[sample(nrow(data), nrow(data)), ] # shuffle the data
  data$RESPONSE <- as.factor(data$RESPONSE)
  
  return(data) 
}

# Variance change ---------------------------------------------------------

QcClassifier_data_var <- function(data,nmetric,factor.names,sim.size,peptide.colname, L, U){
  
  if(!is.factor(guide.set[,paste(peptide.colname)])){
    guide.set$peptide <-as.factor(guide.set$peptide.colname)  
  }
  #factorial matrix  
  factorial <- FrF2(2^nmetric, nmetric,factor.names=colnames(guide.set[,3:ncol(guide.set)]))
  
  
  tag_neg <- 0
  data <- data.frame(NULL)
  
  for(i in 1:nrow(factorial)){
    data.set <- data.frame(NULL)
    if(all(factorial[i,]== rep(-1,nmetric))){
      ####### In cntrol observation ~ 5* sim size  the of the actual 
      sample_data_k <- sample_density(guide.set, sim.size*(2^(nmetric)-1))
    }
    
    else{
      ###### Base Data set to begin with 
      sample_data_k <- sample_density(guide.set, sim.size)
      #sample_data_k <- robust.scale(sample_data_k)
      
      for(j in 1:ncol(sample_data_k)){
        #change in a metric for some peptides
        if(factorial[i,j]== "1" & colnames(factorial[i,j])==colnames(sample_data_k)[j]){ 
          beta=runif(sim.size,L,U)
          sample_data_k[,j]<-ifelse(sample_data_k[,j] > median(sample_data_k[,j]), sample_data_k[,j]+beta, sample_data_k[,j]-beta)
          tag_neg <- 1 
        }# column ends 
      }
    }
    data.set <- rbind(data.set,add_features(sample_data_k))
    #data.set[,"peptide"] <- NULL 
    if(tag_neg == 1){
      data.set$RESPONSE <- c("FAIL")
      tag_neg <- 0
    }
    else{
      data.set$RESPONSE <- c("PASS")
    }
    data <- data[,order(names(data))]
    data.set <- data.set[,order(names(data.set))]
    data <-rbind(data,data.set)
  }
  
  data <- data[sample(nrow(data), nrow(data)), ] # shuffle the data
  data$RESPONSE <- as.factor(data$RESPONSE)
  
  return(data) 
}


# Linear drift ------------------------------------------------------------

QcClassifier_data_linear <- function(data,nmetric,factor.names,sim.size,peptide.colname, L, U){
  
  if(!is.factor(guide.set[,paste(peptide.colname)])){
    guide.set$peptide <-as.factor(guide.set$peptide.colname)  
  }
  #factorial matrix  
  factorial <- FrF2(2^nmetric, nmetric,factor.names=colnames(guide.set[,3:ncol(guide.set)]))
  
  
  tag_neg <- 0
  data <- data.frame(NULL)
  
  for(i in 1:nrow(factorial)){
    data.set <- data.frame(NULL)
    if(all(factorial[i,]== rep(-1,nmetric))){
      ####### In cntrol observation ~ 5* sim size  the of the actual 
      sample_data_k <- sample_density(guide.set, sim.size*(2^(nmetric)-1))
    }
    
    else{
      ###### Base Data set to begin with 
      sample_data_k <- sample_density(guide.set, sim.size)
      #sample_data_k <- robust.scale(sample_data_k)
      
      for(j in 1:ncol(sample_data_k)){
        #change in a metric for some peptides
        if(factorial[i,j]== "1" & colnames(factorial[i,j])==colnames(sample_data_k)[j]){ 
          beta=runif(sim.size,L,U)
          beta=sort(beta)
          #for(k in 1:sim.size){beta[k]=beta[k]*(k-sim.size)/sim.size}
          sample_data_k[,j] <- sample_data_k[,j]-beta[sim.size-j+1]*mad(sample_data_k[,j])
          tag_neg <- 1 
          
        }# column ends 
      }
    }
    data.set <- rbind(data.set,add_features(sample_data_k))
    #data.set[,"peptide"] <- NULL 
    if(tag_neg == 1){
      data.set$RESPONSE <- c("FAIL")
      tag_neg <- 0
    }
    else{
      data.set$RESPONSE <- c("PASS")
    }
    data <- data[,order(names(data))]
    data.set <- data.set[,order(names(data.set))]
    data <-rbind(data,data.set)
  }
  
  data <- data[sample(nrow(data), nrow(data)), ] # shuffle the data
  data$RESPONSE <- as.factor(data$RESPONSE)
  
  return(data) 
}

####################################################################################
QcClassifier_data_annotated <- function(guide.set, guide.set.annotations){
  
  data<-list()
  
  for(i in 1:nlevels(guide.set.annotations$peptide)){
    
    guide.set.annotations.scale <- guide.set.annotations[guide.set.annotations$peptide==levels(guide.set.annotations$peptide)[i],c(1, 3:(ncol(guide.set.annotations)))]
    
    guide.set.new<-guide.set[guide.set$peptide==levels(guide.set$peptide)[i],c(3:(ncol(guide.set)))]
    
    for(k in 2:ncol(guide.set.annotations.scale)){
      guide.set.annotations.scale[,k]=(guide.set.annotations.scale[,k]-median(guide.set.new[,k-1]))/mad(guide.set.new[,k-1])
    }
    
    guide.set.new <- robust.scale(guide.set.new)
    
    for(k in 2:ncol(guide.set.annotations.scale)){guide.set.annotations.scale[,k] <- bctrans.test((guide.set.new[,k-1]),guide.set.annotations.scale[,k])}
    
    names(guide.set.annotations.scale) <- colnames(guide.set.annotations[,c(1,3:(ncol(guide.set.annotations)))])
    
    data[[i]] <- add_features(guide.set.annotations.scale[,2:ncol(guide.set.annotations.scale)])
    
    data[[i]] <- data[[i]][,order(names(data[[i]]), decreasing = TRUE)]
    
  }
  
  data<- dplyr::bind_rows(data)
  data <- data[sample(nrow(data), nrow(data)), ] # shuffle the data
  RESPONSE<-"FAIL"
  data <- cbind(data,RESPONSE)
  
  return(data) 
}
