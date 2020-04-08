
mod1_server <- function(input, output, session) {
  
  
  data <- reactiveValues(df = NULL, plot = NULL, cf = NULL )

  observeEvent(input$jumpToP2, {
    updateTabsetPanel(session, "inTabset",
                      selected = "panel2")
  },priority = 40)
  # 
  # observeEvent(input$go, {
  #   updateTabsetPanel(session, "inPlotSet",
  #                     selected = "pcaplottab")
  # },priority = 30)
  
  observeEvent(input$anomalyfilein, {
    
    file1 <- input$anomalyfilein
    data$cf <-input$cf
    
    data_in <- read.csv(file=file1$datapath, sep=",", header=TRUE, stringsAsFactors=TRUE)
    data_in$anom <- rep("Normal",length(data_in[1]))
    
    data$df <- data_in
    validate(
      need(!is.null(data$df), "Please upload your data"),
      need(is.data.frame(data$df), data$df)
    )
    # data$metrics <- c(find_custom_metrics(data$df))
  }, priority = 20)
  
  observeEvent(input$cf, {
    req(input$cf)
    feedbackWarning("cf", input$cf > 0.5, text = "Contamination Factor is High" ,
                    color = "#F89406", icon = icon("warning-sign", lib ="glyphicon"))
  
  }) 

  observeEvent(input$clear_button, {
    
    data$df <- NULL
    data$plot <- NULL
    waitress <- NULL
  }, priority = 30)
  
  
  output$table <- DT::renderDataTable(DT::datatable({
    req(data$df)
    outputdata <- data$df
    data$df <- outputdata
    outputdata
  }
  ,fillContainer = T
  ,options = list(lengthMenu = c(25, 50, 100), pageLength = 25,
                  rowCallback = DT::JS(sprintf('function(row, data) {
                                          if (String(data[%s]) == "Anomaly"  ){
                                                  $("td", row).css("background", "#BF382A");
                                                  $("td", row).css("color", "white");}}',toString(length(data$df))))
                  )
  ))
  
  output$pairplot <- renderPlot({
    req(data$df)
    req(input$lb)
    req(input$ub)
    
    data_in <- data$df
    pch <- rep(".", length(data_in[input$lb]))
    col <- rep("blue", length(data_in[input$lb]))
    
    if (!is.null(data$plot)){
      pch <- if_else(data_in$anom == "Anomaly", "X", "." )
      col <- if_else(data_in$anom == "Anomaly", "red", "blue" )
      }
    
    pairs(data_in[input$lb:input$ub], pch=pch, col=col)
  })
  
  fetchplot <- observeEvent(input$go, {
    req(data$df)
    updateTabsetPanel(session, "inPlotSet",
                      selected = "pcaplottab")
    waitress <- Waitress$new("#inPlotSet", theme = "overlay-percent")
    for(i in 1:10){
      waitress$inc(10) # increase by 10%
      Sys.sleep(.5)
    }
    data$plot <- get_anomaly_plot(data$df)
    waitress$close() # hide when done
  }, priority = 10)
  
  output$plot <- renderPlotly({
    req(data$plot)
    fig <- data$plot
    fig
  })

  output$tree <- renderVisNetwork({
    # minimal example
    req(data$plot)
    data_in <- data$df
    Anomaly <- as.vector(data_in$anom)
    input_df <- cbind(data_in[input$lb:input$ub],Anomaly)
    tree <- rpart(Anomaly~., data=input_df, method="class")

    visTree(tree, main = "Classification Tree", width = "100%")
  })

  
  get_anomaly_plot <- function(df_input){
    # waitress <- Waitress$new("#loadpca", theme = "overlay-percent") 
    metrics <- length(colnames(df_input))
    df_input <- df_input[input$lb:input$ub]
    # df_input <- df_input %>% mutate_at(1:metrics-1, ~(scale(., center = T) %>% as.vector))
    # for(i in 1:10){
    #   waitress$inc(10) # increase by 10%
    #   Sys.sleep(.5)
    # }
    
    
    model <- isolationForest$new(
      num_trees = 100,
      sample_size = base::round(nrow(df_input)*0.05 + 2),
      replace = T,
      mtry = (length(colnames(df_input))),
      seed = 123
    )
    
    model$fit(df_input)
  
    predictions <-  model$predict(df_input)
    conf <-  1-input$cf
    
    n = length(predictions$anomaly_score)/2
    B = 10000
    boot_result = rep(NA, B)
    for (i in 1:B) {
      boot.sample = sample(n, replace = TRUE)
      boot_result[i] = quantile(predictions$anomaly_score[boot.sample], conf)
    }
    
    thresh<-median(boot_result)

    pca <- prcomp(df_input, scale. = T , center = T)
    pcainfo <-  summary(pca)

    x <- as.vector(pca[["x"]][,1])
    y <- as.vector(pca[["x"]][,2])
    z <- as.vector(pca[["x"]][,3])
    anom <- as.vector(predictions$anomaly_score)
    
    pca_df <-  as.data.frame(cbind(x,y,z,anom))
    
    pca_df <- pca_df %>% mutate(anom = if_else(anom > thresh, 'Anomaly', 'Normal') )
  
    fig <- plot_ly(pca_df, x = ~x, y = ~y, z = ~z, color = ~anom, colors = c('#BF382A', '#0C4B8E'))
    fig <- fig %>% add_markers()
    fig <- fig %>% layout(scene = list(xaxis = list(title = paste('PC1 ', pcainfo$importance[2]*100,"%")),
                                       yaxis = list(title = paste('PC2 ', pcainfo$importance[5]*100,"%")),
                                       zaxis = list(title = paste('PC3 ', pcainfo$importance[8]*100,"%"))
    ))
    
    df_input <-  data$df 
    df_input$anom <- pca_df$anom
    data$df <- df_input
    
    # waitress$close() # hide when done
    fig
  }
  
}
