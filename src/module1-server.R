library(h2o)
library(DT)
library(plotly)


mod1_server <- function(input, output, session) {
  
  
  data <- reactiveValues(df = NULL, plot = NULL, cf = NULL )
  
  
  
  observeEvent(input$jumpToP2, {
    updateTabsetPanel(session, "inTabset",
                      selected = "panel2")
  },priority = 30)
  
  
  observeEvent(input$filein, {
    h2o.init(max_mem_size = "1g", nthreads = -1 )
    h2o.removeAll()
    file1 <- input$filein
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
  }, priority = 20)
  
  
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
  
  
  fetchplot <- observeEvent(input$go, {
    req(data$df)
    data$plot <- get_anomaly_plot(data$df)
  })
  
  output$plot <- renderPlotly({
    req(data$plot)
    fig <- data$plot
    fig
  })
  
  
  get_anomaly_plot <- function(df_input){
    waitress <- Waitress$new("#plot", theme = "overlay-percent") 
    metrics <- length(colnames(df_input))
    df_input <- df_input[input$lb:input$ub]
    # df_input <- df_input %>% mutate_at(1:metrics-1, ~(scale(., center = T) %>% as.vector))

    data_h2o <- as.h2o(df_input,destination_frame = "data_h2o")
    
    
    for(i in 1:10){
      waitress$inc(10) # increase by 10%
      Sys.sleep(.5)
    }
    
    model <- h2o.isolationForest(training_frame=data_h2o,
                                 model_id = "isolation_forest.hex",
                                 ntrees = 100,
                                 seed= 12345)
  
    predictions <- h2o.predict(model, data_h2o)
    conf <-  1-input$cf
    thresh <-  h2o.quantile(predictions$predict,conf)

    pca <- prcomp(df_input, scale. = T , center = T)
    pcainfo <-  summary(pca)

    x <- as.vector(pca[["x"]][,1])
    y <- as.vector(pca[["x"]][,2])
    z <- as.vector(pca[["x"]][,3])
    anom <- as.vector(predictions$predict)
    
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
    
    
    waitress$close() # hide when done
    fig

  }
  
  
  
  session$onSessionEnded(function() {
    h2o.shutdown(prompt = FALSE)
    stopApp()
  })
  
}
