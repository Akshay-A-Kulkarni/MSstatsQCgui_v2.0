
#' A function to test random forest classifiers for QC data
#'
#' @param guide.set comma-separated (.csv), metric file. It should contain a "Precursor" column and the metrics columns. It should also include "Annotations" for each run.
#' @param Test.set comma-separated (.csv), metric file. It should contain a "Precursor" column and the metrics columns. It should also include "Annotations" for each run.
#' @param Precursor the name of Precursor of interest.
#' @param method the method used to model. Two values can be assigned, "randomforest" or "neuralnetwork".
#' @export
#' @import caret pdp ggplot2 MASS dplyr
#' @import h2o
#' @examples
#' # First process the data to make sure it's ready to use
#' sampleData <- MSstatsQC::DataProcess(S9Site54)
#' head(sampleData)
#' # Find the name of the Precursors
#' levels(sampleData$Precursor)
#' # Calculate change point statistics
#' QcClassifierTrain(guide.set = sampleData[1:20,], Precursor = "LVNELTEFAK", method = "randomforest")

  MSstatsQC.ML.testR<- function(Test.set, guide.set,address="", rf_model){
  
  source("src/auto_add_features.R")
  source("src/robust_scaling.R")
  source("src/boxcox_transformation.R")
  
    # if (address != FALSE) {
    #   allfiles <- list.files()
    # 
    #   num <- 0
    #   filenaming <- paste0(address,"MSstatsQC.ML.Plots")
    #   finalfile <- paste0(address,"MSstatsQC.ML.Plots.pdf")
    # 
    #   while (is.element(finalfile, allfiles)) {
    #     num <- num + 1
    #     finalfile <- paste0(paste(filenaming, num, sep="-"), ".pdf")
    #   }
    # 
    #   pdf(finalfile, width=20, height=20)
    # }

  Test.set$Precursor<-as.factor(Test.set$Precursor)
  guide.set$Precursor<-as.factor(guide.set$Precursor)
  Results<-list()
  Results_annotated<-list()
  Test.set.features<-list()
  interpret.plots<-list()
  
  for(i in 1:nlevels(Test.set$Precursor)){

  Test.set.scale <- Test.set[Test.set$Precursor==levels(Test.set$Precursor)[i],c(1, 4:(ncol(Test.set)))]
  
  guide.set.new<-guide.set[guide.set$Precursor==levels(guide.set$Precursor)[i],c(4:(ncol(guide.set)))]
  
  for(k in 2:ncol(Test.set.scale)){
  Test.set.scale[,k]=(Test.set.scale[,k]-median(guide.set.new[,(k-1)]))/mad(guide.set.new[,(k-1)])
  }
  
  guide.set.new <- robust.scale(guide.set.new)
  
  for(k in 2:ncol(Test.set.scale)){Test.set.scale[,k] <- bctrans.test((guide.set.new[,k-1]),Test.set.scale[,k])}
  
  names(Test.set.scale) <- colnames(Test.set[,c(1,4:(ncol(Test.set)))])

  Test.set.scale.temp <- add_features(Test.set.scale[,2:ncol(Test.set.scale)])
  
  Test.set.scale.temp <- Test.set.scale.temp[,order(names(Test.set.scale.temp), decreasing = TRUE)]
  
  Test.set.scale.h2o <- as.h2o(Test.set.scale.temp)
  
  Predict<-as.data.frame(h2o.predict(rf_model, Test.set.scale.h2o, type="prob"))
  
  Predict<-cbind(idfile=Test.set.scale[,1],Predict)
  Results[[i]]<-Predict[,c(1,3)]
  Results_annotated[[i]]<-Predict$predict
  #colnames(Results)[i]<-levels(Test.set$Precursor)[i]
  #colnames(Results_annotated)[i]<-levels(Test.set$Precursor)[i]
  
  Test.set.features[[i]]<-cbind(Test.set.scale.temp,idfile=1:length(Test.set.scale[,1]))
  Test.set.features[[i]]<-melt(as.data.frame(Test.set.features[[i]]), id.vars = "idfile")
  g0<-eval(substitute(ggplot(Test.set.features[[i]][-1,], aes(idfile, variable)) + 
      geom_tile(aes(fill = value), colour = "white") +
      labs(x = "Time",y = NULL)+
      removeGrid()+
      scale_y_discrete(expand=c(0,0))+
      scale_fill_gradient(low = "white",
                          high = "darkorange", 
                          limits=c(-15, 100),
                          #breaks=c(0,50,100),
                          name = "Standardized and\nengineered feature values")+
      ggtitle(label = levels(Test.set$Precursor)[i])+
      theme(legend.title=element_text(size=8), legend.key.size = unit(0.5, "cm"), 
            legend.key.height=unit(0.5, "cm"), legend.justification = "bottom",
            legend.position="bottom", panel.background = element_blank(),
            plot.background = element_blank(), plot.margin = unit(c(0.1,0,0,0), "cm"),
            axis.ticks.length = unit(0, "pt"))
      ,list(i = i)))
  interpret.plots[[i]] <- g0
  }
  
  FAIL<-NA
  id<-cbind(Test.set[Test.set$Precursor== levels(Test.set$Precursor)[which.max(table(Test.set$Precursor))],1], FAIL)
  colnames(id)<-c("idfile", "FAIL")
  
  for (i in 1:nlevels(Test.set$Precursor)){
  Results[[i]]<- dplyr::left_join(as.data.frame(id), Results[[i]], by=c("idfile","idfile"))
  Results[[i]]<- Results[[i]] %>% distinct()
  Results[[i]]<- Results[[i]][,c(1,3)]
  colnames(Results[[i]])<-c("idfile", "FAIL")
  }
  
  Results.new<-Results[[1]]
  for (i in 2:nlevels(Test.set$Precursor)){
  Results.new<-dplyr::full_join(Results.new, Results[[i]], by="idfile")
  }
  
  colnames(Results.new)<-c("idfile",levels(Test.set$Precursor))
  Results<-data.frame(RUN=1:(dim(Results.new)[1]), Results.new[,-1])
  Results_melt <- melt(Results[-1,],id.vars ="RUN")
  decision.map<-ggplot(Results_melt, aes(RUN, variable)) + 
    geom_tile(aes(fill = value), colour = "white") +
    labs(x = "Time",y = NULL)+
    removeGrid()+
    scale_y_discrete(expand=c(0,0))+
    scale_fill_gradient(low = "white", 
                        high = "red",
                        limits=c(0, 1),
                        breaks=c(0,0.5,1),
                        name = "Probability\nof failure")+
    theme(legend.title=element_text(size=8), legend.key.size = unit(0.5, "cm"), 
          legend.key.height=unit(0.5, "cm"), legend.justification = "bottom",
          legend.position="bottom", panel.background = element_blank(),
          plot.background = element_blank(), plot.margin = unit(c(0.1,0,0,0), "cm"),
          axis.ticks.length = unit(0, "pt"))

  message(paste("Drew the plot for final evaluation"))
  
  message(paste("Drew the plots for interpretation"))
  
  interpret.plots[[length(interpret.plots)+1]] <- decision.map

  return(interpret.plots)
}

  
