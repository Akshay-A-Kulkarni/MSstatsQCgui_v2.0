getPolarCoord <- function(r, matrix = F, na = F){
  # Get starting angle and angle increments
  theta <- 0
  dtheta <- 360 / length(r)
  dtheta <- (pi / 180) * dtheta  # in radians
  
  # Get polar coordinates
  x <- c()
  y <- c()
  
  for(i in seq_len(length(r))){
    
    x <- c(x, r[i] * cos(theta))
    y <- c(y, r[i] * sin(theta))
    
    theta <- theta + dtheta
  }
  
  x[length(x) + 1] <- x[1]
  y[length(y) + 1] <- y[1]
  
  if(na == T){
    x[length(x) + 1] <- NA
    y[length(y) + 1] <- NA
  }
  
  
  if(matrix == T){
    return(cbind(x, y))
  }else{
    return(list(x = x, 
                y = y))
  }
  
}

import_fs <- function(ns, libs = c(), incl = c(), excl = c()) {
  tmp <- sapply(libs, library, character.only = TRUE); rm(tmp)
  if (length(incl) != 0 || length(excl) != 0) {
    import_list <- getNamespaceImports(ns)
    if (length(incl) == 0)
      import_list[names(import_list) %in% c("base", "methods", "stats", "utils", libs, excl)] <- NULL
    else
      import_list <- import_list[names(import_list) %in% incl]
    import_names <- names(import_list)
    
    for (i in seq_len(length(import_list))) {
      fun <- import_list[[i]]
      lib <- import_names[[i]]
      eval(parse(text = paste0("import::from(",lib,", '",paste0(fun,collapse="', '"),"')")))
    }
  }
  invisible()
}

if (!"package:MSstatsQCgui" %in% search())
  import_fs("MSstatsQCgui", incl = c("dplyr","plotly"))