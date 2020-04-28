
mod1_server <- function(input, output, session) {
  
  
  data <- reactiveValues(df = NULL, pairplot = NULL , plot = NULL, cf = NULL, tree_obj= NULL, rule_table= NULL )

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
    outputdata
  }
  ,fillContainer = T
  ,options = list(lengthMenu = c(25, 50, 100), pageLength = 25,
                  rowCallback = DT::JS(sprintf('function(row, data) {
                                          if (String(data[%s]).trim() == "Anomaly"  ){
                                                  $("td", row).css("background", "#994141");
                                                  $("td", row).css("color", "white");}}',toString(length(data$df))))
                  )
  ))
  
  output$ruletable <- DT::renderDataTable(DT::datatable({
    req(data$tree_obj)
    tree <- data$tree_obj
    data$rule_table <- get_rule_table(tree)
  },escape = F
  ,fillContainer = T
  ,options = list(lengthMenu = c(25, 50, 100), pageLength = 25,
                  rowCallback = DT::JS(sprintf('function(row, data) {
                                          if (String(data[%s]).trim() == "Anomaly"  ){
                                                  $("td", row).css("background", "#994141");
                                                  $("td", row).css("color", "white");}}',toString(1)))
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
    
    data$pairplot <- pairs(data_in[input$lb:input$ub], pch=pch, col=col)
    data$pairplot
  })
  
  fetchplot <- observeEvent(input$go, {
    req(data$df)
    updateTabsetPanel(session, "inPlotSet",
                      selected = "pcaplottab")
    waitress <- Waitress$new("#inPlotSet", theme = "overlay-percent")
    for(i in 1:10){
      waitress$inc(10) # increase by 10%
      Sys.sleep(.1)
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
    data$tree_obj <- build_tree(data_in)
    visTree(data$tree_obj, main = "Anomaly Classification Tree", width = "100%")
  })

  build_tree <- function(data_in){
    Anomaly <- as.vector(data_in$anom)
    input_df <- cbind(data_in[input$lb:input$ub],Anomaly)
    tree <- rpart(Anomaly~., data=input_df, method="class")
    tree
  }
  
  get_rule_table <- function(rpart_tree_obj){
    
    rule_table <- as.data.frame(rpart.rules(rpart_tree_obj, extra = 4, cover = TRUE, roundint = F))
    cols <- colnames(rule_table)
    colnames(rule_table) <- c("Response",paste0("Probabilty <br>","[",cols[2],"]"),seq(3,length(rule_table)-1),"% of Total Obs.")
    rules <- unite(rule_table, 'Conditions/Rules',4:length(rule_table)-1, sep = ' ', remove = TRUE)
    rules
  }
  
  get_anomaly_plot <- function(df_input){
    
    # Subscripting input based on given indices
    df_input <- df_input[input$lb:input$ub]
    
    #Initialising IF model
    model <- isolationForest$new(
      num_trees = 100,
      sample_size = base::round(nrow(df_input)*0.05 + 2),
      replace = T,
      mtry = (length(colnames(df_input))),
      seed = 123
    )
    
    # fitting on input 
    model$fit(df_input)
  
    # Extracting Predictons 
    predictions <-  model$predict(df_input)
    conf <-  1-input$cf
    
    #A scertaining a threshold via boostrap
    n = length(predictions$anomaly_score)/2
    B = 10000
    boot_result = rep(NA, B)
    for (i in 1:B) {
      boot.sample = sample(n, replace = TRUE)
      boot_result[i] = quantile(predictions$anomaly_score[boot.sample], conf)
    }
    
    thresh<-median(boot_result)

    # Getting Principal Components
    pca <- prcomp(df_input, scale. = T , center = T)
    pcainfo <-  summary(pca)

    x <- as.vector(pca[["x"]][,1])
    y <- as.vector(pca[["x"]][,2])
    z <- as.vector(pca[["x"]][,3])
    anom <- as.vector(predictions$anomaly_score)
    
    pca_df <-  as.data.frame(cbind(x,y,z,anom))
    
    # Ploting 3d Plot
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
    
    fig
  }
  
  output$report <- downloadHandler(
    # For PDF output, change this to "report.pdf"
    filename = "report.html",
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions.
      
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy("report.Rmd", tempReport, overwrite = TRUE)
      
      # Set up parameters to pass to Rmd document
      params <- list(
                     pair_plot = data$pairplot,
                     plotly_fig = data$plot,
                     tree_plot = data$tree_obj,
                     rule_table = data$rule_table
                     )
      
      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      rmarkdown::render(tempReport, output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv())
      )
    }
  )
}
