library(readxl)
library(h2o)
library(caret)
library(MASS)
library(car) #boxCox
library(ggplot2)
library(gridExtra)
library(reshape) #melt
library(ggExtra) #rotateTextX() 

factorial <- read_xlsx("Factorialcombinatins.xlsx",sheet = 1)


source("auto_add_features.R")
source("ml_algo.R")

sim.size = 100
num_peptides <- nlevels(guide.set.scale$peptide)
prob <- floor(runif(1,min = 0, max = num_peptides))
out_peptides <- sample(levels(guide.set.scale$peptide),prob)
in_peptides <-  levels(guide.set.scale$peptide)[!levels(guide.set.scale$peptide) %in% out_peptides]
tag_neg <- 0
data <- data.frame(NULL)
for(i in 2:nrow(factorial)){
  if(i == 2){
    sample_data<- list()
    ###### In cntrol observation ~ 5* sim size  the of the actual 
    for(k in 1:nlevels(guide.set.scale$peptide)){ 
      sample_data_k <- sample_density(guide.set.scale,levels(guide.set.scale$peptide)[k], sim.size*15)
      colnames(sample_data_k)<- paste(levels(guide.set.scale$peptide)[k],colnames(sample_data_k),sep = ".")
      sample_data_k <- cbind(peptide=rep(levels(guide.set.scale$peptide)[k],sim.size),
                             sample_data_k,
                             RESPONSE= c("PASS"))
      sample_data[[k]] <- sample_data_k
      sample_data[[k]] <- add_features(sample_data[[k]])
    }
    
  }
  else{
    sample_data<- list()
    ###### In cntrol observation ~ 5* sim size  the of the actual 
    for(k in 1:nlevels(guide.set.scale$peptide)){ 
      sample_data_k <- sample_density(guide.set.scale,levels(guide.set.scale$peptide)[k], sim.size)
      colnames(sample_data_k)<- paste(levels(guide.set.scale$peptide)[k],colnames(sample_data_k),sep = ".")
      sample_data_k <- cbind(peptide=rep(levels(guide.set.scale$peptide)[k],sim.size),
                             sample_data_k,
                             RESPONSE= c("PASS"))
      sample_data[[k]] <- sample_data_k
      sample_data[[k]] <- add_features(sample_data[[k]])
    }
    
    
    for(j in 2:5){
      #change in RT Drift for some peptides
      if(factorial[i,j]== "+" & colnames(factorial[i,j])=="RT drift"){ 
        for(k in 1:length(sample_data)){
          
          if(sample_data[[k]]$peptide[1] %in% out_peptides){
            sample_data[[k]][[paste(sample_data[[k]]$peptide[1],"RT",sep = ".")]] <- 
              sample_data[[k]][[paste(sample_data[[k]]$peptide[1],"RT",sep = ".")]] +
              runif(1,-2,2)*IQR(sample_data[[k]][[paste(sample_data[[k]]$peptide[1],"RT",sep = ".")]])
            tag_neg <- 1 
          }
        }
        sample_data[[k]][,"RESPONSE"] = rep("FAIL",sim.size)  
        sample_data[[k]] <- add_features(sample_data[[k]])
      }
      
      #change in Total Area Drift for some peptides
      if(factorial[i,j]== "+" & colnames(factorial[i,j])=="Total Area drift"){ 
        for(k in 1:length(sample_data)){
          
          if(sample_data[[k]]$peptide[1] %in% out_peptides){
            sample_data[[k]][[paste(sample_data[[k]]$peptide[1],"TotalArea",sep = ".")]] <- 
              sample_data[[k]][[paste(sample_data[[k]]$peptide[1],"TotalArea",sep = ".")]] +
              runif(1,-2,2)*IQR(sample_data[[k]][[paste(sample_data[[k]]$peptide[1],"TotalArea",sep = ".")]])
            tag_neg <- 1 
          }
          
        }
        sample_data[[k]][,"RESPONSE"] = rep("FAIL",sim.size)  
        sample_data[[k]] <- add_features(sample_data[[k]])
      }
      
      #change in Mass Accu Drift for some peptides
      if(factorial[i,j]== "+" & colnames(factorial[i,j])=="Mass Accu drift"){ 
        for(k in 1:length(sample_data)){
          
          if(sample_data[[k]]$peptide[1] %in% out_peptides){
            sample_data[[k]][[paste(sample_data[[k]]$peptide[1],"MassAccu",sep = ".")]] <- 
              sample_data[[k]][[paste(sample_data[[k]]$peptide[1],"MassAccu",sep = ".")]] +
              runif(1,-2,2)*IQR(sample_data[[k]][[paste(sample_data[[k]]$peptide[1],"MassAccu",sep = ".")]])
            tag_neg <- 1 
          }
          
        }
        sample_data[[k]][,"RESPONSE"] = rep("FAIL",sim.size)  
        sample_data[[k]] <- add_features(sample_data[[k]])
      }
      
      #change in FWHM Drift for some peptides
      if(factorial[i,j]== "+" & colnames(factorial[i,j])=="FWHM drift"){ 
        for(k in 1:length(sample_data)){
          
          if(sample_data[[k]]$peptide[1] %in% out_peptides){
            sample_data[[k]][[paste(sample_data[[k]]$peptide[1],"FWHM",sep = ".")]] <- 
              sample_data[[k]][[paste(sample_data[[k]]$peptide[1],"FWHM",sep = ".")]] +
              runif(1,-2,2)*IQR(sample_data[[k]][[paste(sample_data[[k]]$peptide[1],"FWHM",sep = ".")]])
            tag_neg <- 1 
          }
        }
        sample_data[[k]][,"RESPONSE"] = rep("FAIL",sim.size)  
        sample_data[[k]] <- add_features(sample_data[[k]])
      }
    }# column ends 
  }
    
  data.set <- do.call("cbind",sample_data)
  data.set <- data.set[, !duplicated(colnames(data.set))]
  data.set[,"peptide"] <- NULL 
  if(tag_neg == 1){
      data.set[,"RESPONSE"] = rep("FAIL",sim.size)
  }
  tag_neg <- 0
  data <-rbind(data,data.set)
    
}

data <- data[sample(nrow(data), nrow(data)), ] # shuffle the data
    
    
    
rf_model <- ml_algo(data)
    
summary(rf_model)    
    
cf<- data.frame(h2o.confusionMatrix(rf_model,valid = T),stringsAsFactors = F)
  
cf
