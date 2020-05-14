bctrans<-function( data1){
  
  lambda.fm1 <- car::boxCox(data1 ~ 1, family ="yjPower", plotit = FALSE)
  lambda.max <- lambda.fm1$x[which.max(lambda.fm1$y)]
  metric = yjPower(data1, lambda=lambda.max, jacobian.adjusted=FALSE)
  return(metric)
}

bctrans.test<-function( data1, data2){
  
  lambda.fm1 <- car::boxCox(data1 ~ 1, family ="yjPower", plotit = FALSE)
  lambda.max <- lambda.fm1$x[which.max(lambda.fm1$y)]
  metric = yjPower(data2, lambda=lambda.max, jacobian.adjusted=FALSE)
  return(metric)
}
