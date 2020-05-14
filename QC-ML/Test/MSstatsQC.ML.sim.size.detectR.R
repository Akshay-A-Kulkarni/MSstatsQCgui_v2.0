#' A function to train random forest classifiers for QC data
#'
#' @param guide.set comma-separated (.csv), metric file. It should contain a "peptide" column and the metrics columns. It should also include "Annotations" for each run.
#' @param Test.set comma-separated (.csv), metric file. It should contain a "peptide" column and the metrics columns. It should also include "Annotations" for each run.
#' @param peptide the name of peptide of interest.
#' @param method the method used to model. Two values can be assigned, "randomforest" or "neuralnetwork".
#' @export
#' @import caret ggplot2 MASS dplyr
#' @import h2o
#' @examples
#' # First process the data to make sure it's ready to use
#' sampleData <- MSstatsQC::DataProcess(S9Site54)
#' head(sampleData)
#' # Find the name of the peptides
#' levels(sampleData$Precursor)
#' # Calculate change point statistics
#' QcClassifierTrain(guide.set = sampleData[1:20,])

MSstatsQC.ML.sim.size.detectR<-function(guide.set, sim.start, sim.end){
  
  source("MSstatsQC.ML.trainR.R")
  source("MSstatsQC.ML.train_data.R") 
  
  sequence<-seq(sim.start, sim.end, 100)
  results<-matrix(NA, 100000, 4)
  for(i in sequence){
    rf_model<-MSstatsQC.ML.trainR(guide.set, i, guide.set.annotations = NULL)
    cf<- data.frame(h2o.confusionMatrix(rf_model),stringsAsFactors = F)
    sens<-cf[1,1]/(cf[1,1]+cf[2,1])
    err1<-cf[1,3]
    err3<-cf[3,3]
    results[i,]<-cbind(i,sens,err1,err3)
  }
  results<-as.data.frame(results[complete.cases(results),])
  colnames(results)<-c("Simulation.size", "Accuracy", "False positive rate", "False negative rate")
  
  results_melt <- melt(results,id.vars ="Simulation.size", 
                       measure.vars=c("Accuracy", "False positive rate", "False negative rate"))
  ggplot(results_melt, aes(Simulation.size, value)) + 
    geom_point()+
    geom_smooth(aes(color="red"), show.legend = FALSE)+
    ylab("Probability")+
    xlab("Simulation size")+
    facet_wrap(~variable,scales = "free")+
    theme(text = element_text(size=12),
          axis.text.x = element_text(angle=45, hjust=1))
}

MSstatsQC.ML.sim.size.detectR(guide.set, sim.start=10, sim.end=2500)

