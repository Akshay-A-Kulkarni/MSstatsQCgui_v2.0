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

MSstatsQC.ML.trainR<- function(guide.set, sim.size, address="", guide.set.annotations=NULL){
  
  source("src/auto_add_features.R")
  source("src/sample_density_function.R")
  source("src/boxcox_transformation.R")
  source("src/robust_scaling.R")
  source("src/MSStatsQC.ML.train_data.R")
  
  
  #function inputs
  nmetric<-ncol(guide.set)-3
  factor.names = colnames(guide.set[,4:ncol(guide.set)])
  #optional 
  guide.set$Precursor <-as.factor(guide.set$Precursor)
  
  #optional 
  peptide.colname <-"Precursor"
  
  d1 <- QcClassifier_data_step(guide.set,nmetric,factor.names,sim.size*1,peptide.colname, L=3, U=10)
  d2 <- QcClassifier_data_var(guide.set,nmetric,factor.names,sim.size*1,peptide.colname, L=3, U=10)
  d3 <- QcClassifier_data_linear(guide.set,nmetric,factor.names,sim.size*1,peptide.colname, L=3, U=10)
  
  d4 <- QcClassifier_data_step(guide.set,nmetric,factor.names,sim.size*1,peptide.colname, L=-10, U=-3)
  d5 <- QcClassifier_data_var(guide.set,nmetric,factor.names,sim.size*1,peptide.colname, L=-10, U=-3)
  d6 <- QcClassifier_data_linear(guide.set,nmetric,factor.names,sim.size*1,peptide.colname, L=-10, U=-3)
  if (is.null(dim(guide.set.annotations))==TRUE) {d<-rbind(d1,d2,d3, d4,d5,d6)}
  else{
  d7 <- QcClassifier_data_annotated(guide.set, guide.set.annotations)
  #d<-rbind(d1,d2, d3, d4,d5,d6, d7)}
  d<-rbind(d1,d2, d3, d4,d5,d6, d7)}
  ## 80% of the sample size
  smp_size <- floor(0.8 * nrow(d))
  
  set.seed(123)
  train_ind <- sample(seq_len(nrow(d)), size = smp_size)
  
  train <- d[train_ind,]
  test <- d[-train_ind,]
  
  #launch h2o cluster
  localH2O <- h2o.init(nthreads = -1)
  
  #import r objects to h2o cloud
  train_h2o <- as.h2o(train)
  test_h2o <- as.h2o(test)
  
  ## run our first predictive model
  rf_model <- h2o.randomForest(         ## h2o.randomForest function
    training_frame = train_h2o,        ## the H2O frame for training
    validation_frame = test_h2o,      ## the H2O frame for validation (not required)
    x= colnames(train_h2o),
    y= "RESPONSE",
    model_id = "rf_model",    ## name the model in H2O
    nfolds = 10,
    ntrees = 100,                  ##   not required, but helps use Flow
    ## use a maximum of 200 trees to create the
    ##  random forest model. The default is 50.
    stopping_rounds = 2,           ## Stop fitting new trees when the 2-tree
    ##  average is within 0.001 (default) of 
    ##  the prior two 2-tree averages.
    ##  Can be thought of as a convergence setting
    score_each_iteration = TRUE,
    max_depth = 20,
    seed = 123) 
  
  message(paste("Constructed the RF model"))
  print(rf_model)
  
}
