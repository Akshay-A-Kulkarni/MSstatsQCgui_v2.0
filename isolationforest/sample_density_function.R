dens<-function(temp.Data, n){
dat.dens = stats::density(temp.Data, n=2^10)
sim.sample = sample(dat.dens$x, n, replace=TRUE, prob=dat.dens$y)
sim.sample}

sample_density <- function(guide.set, n){
  sample_data<-c()
  guide.set.scale<-data.frame(NULL)
  for(i in 1:nlevels(guide.set$peptide)){
  guide.set.temp<-robust.scale(guide.set[guide.set$peptide==levels(guide.set$peptide)[i],c(3:ncol(guide.set))])
  guide.set.scale<-rbind(guide.set.scale, guide.set.temp)
  }
  for(k in 1:ncol(guide.set.scale)){guide.set.scale[,k] <- bctrans(guide.set.scale[,k])}
  
  sample_data<-as.data.frame(matrix(0, n, ncol(guide.set.scale)))
  
  for(j in 1:ncol(guide.set.scale)){
    sample_data[,j] <- dens(guide.set.scale[,j], n)
  }
  
  names(sample_data) <- colnames(guide.set[,c(3:(ncol(guide.set)))])
  
  return(sample_data)
}

