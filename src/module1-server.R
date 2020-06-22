
mod1_server <- function(input, output, session) {
  
  
  observeEvent(input$switch_home, {
    if (!is_page("home")) {
      change_page("/")}
  })
  
  
  data <- reactiveValues(
                    df = NULL,
                    cols=NULL, 
                    mod1_uploadmsg="Upload Data or Try the Example",
                    selected_cols=NULL, 
                    pairplot = NULL , 
                    plot = NULL, 
                    cf = NULL, 
                    tree_obj= NULL, 
                    rule_table= NULL 
                    )

  observeEvent(input$jumpToP2, {
    updateTabsetPanel(session, "inTabset",
                      selected = "panel2")
  },priority = 40)
  
  observeEvent(input$anomalyfilein, {
    
    user_upload <- input$anomalyfilein
    data$mod1_uploadmsg <-  user_upload$name
    data$cf <-input$cf
    
    data_in <- read.csv(file=user_upload$datapath, sep=",", header=TRUE, stringsAsFactors=TRUE)
    data_in$Predicted_Label <- rep("Normal",length(data_in[1]))
    
    data$cols <-  base::colnames(data_in)[1:(length(data_in)-1)]
    data$df <- data_in

  }, priority = 30)
  
  
  observeEvent(input$mod1_example, {
    data$mod1_uploadmsg <- "Example Dataset loaded"
    
    data$cf <-input$cf
    
    data_in <- read.csv("./Datasets/anomaly_example_delta5.csv", header=TRUE, stringsAsFactors=TRUE)

    data_in$Predicted_Label <- rep("Normal",length(data_in[1]))
    
    data$cols <-  base::colnames(data_in)[1:(length(data_in)-1)]
    data$df <- data_in
  }, priority = 30

  )
  
  
  output$mod1_upload_component <- renderUI({
    fileInput("anomalyfilein", label= strong("Upload Dataset"), placeholder = data$mod1_uploadmsg, accept = c(".csv"))
  })
  
  observeEvent(input$cf, {
    req(input$cf)
    feedbackWarning("cf", (input$cf > 0.5 & input$cf < 1) , text = "Contamination Factor is High" ,
                    color = "#F89406", icon = icon("warning-sign", lib ="glyphicon"))
    
  }) 
  
  
  

  observeEvent(input$clear_button, {
    
    data$df <- NULL
    data$plot <- NULL
    data$mod1_uploadmsg <- "Upload Data or Try the Example"
    data$selected_cols <- NULL
    data$cols <- NULL
    data$pairplot <-  NULL 
    data$plot <-  NULL
    data$cf <-  NULL 
    data$tree_obj <-  NULL
    data$rule_table <-  NULL
    waitress <- NULL
  }
  , priority = 30)
  
  
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
        )
  )
  
  output$init_buttons <- renderUI({
    if(is.null(data$selected_cols) || is.null(data$df)){
      return(div(p(strong("Make sure Data is uploaded and Columns are selected before running the model."))))
    }
    div(
      p(style="margin:0 0 5px",strong("Controls: ")),
      div(style='width=100%',
        actionButton(inputId = "go", label = "Run Model/Plot", width = '100%')
        ),
      br(),
      div(  
        actionButton(inputId = "clear_button", label = "Reset/Clear All", width = '100%')
      )
    )
  })
  
  output$colSelection <- renderUI({
    pickerInput(
      inputId = "user_selected_columns", 
      label = "Select One or Multiple Columns", 
      choices = data$cols, 
      options = list(
        `actions-box` = TRUE,
        `style`="background-color:white; color:black"
      ), 
      multiple = TRUE
    )
  })
  
  observeEvent(input$user_selected_columns, {
    selected_cols <- input$user_selected_columns
    data$selected_cols <- c(selected_cols,"Predicted_Label")
  }, priority = 30)
  
  output$pairplot <- renderPlot({
    validate(
      need(!is.null(data$df), "Please upload your data first"),
      need(length(input$user_selected_columns) > 1,"Please Select atleast 2 Metrics/ Columns for pair plot")
    )
    req(data$df)
    
    data_in <- data$df[data$selected_cols]
    pch <- rep(".", length(data_in[1]))
    col <- rep("blue", length(data_in[1]))
    
    if (!is.null(data$plot)){
      pch <- if_else(data_in$Predicted_Label == "Anomaly", "X", "." )
      col <- if_else(data_in$Predicted_Label == "Anomaly", "red", "blue" )
      }
    
    if (length(input$user_selected_columns) > 8) {
      pair_plot_cols <-  head(input$user_selected_columns,8)
    }
    
    data$pairplot <- pairs(data_in[pair_plot_cols], pch=pch, col=col)
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
    input <- data$df[input$user_selected_columns]
    data$plot <- train_isoforest_anomaly_plot(input)
    waitress$close() # hide when done
  }, priority = 10)
  
  output$plot <- renderPlotly({
    validate(
      need(!is.null(data$plot), "Please press the plot button to run the model and plot results.")
    )
    req(data$plot)
    fig <- data$plot
    fig
  })

  output$tree <- renderVisNetwork({
    req(data$plot)
    data_in <- data$df[data$selected_cols]
    tree <- rpart(Predicted_Label~., data=data_in, method="class")
    data$tree_obj <- tree
    visTree(data$tree_obj, main = "Anomaly Classification Tree", width = "100%")
  })

  # build_tree <- function(data_in){
  #   Anomaly <- as.vector(data_in$Predicted_Label)
  #   input_df <- cbind(data_in[input$lb:input$ub],Anomaly)
  #   tree
  # }
  
  get_rule_table <- function(rpart_tree_obj){
    
    rule_table <- as.data.frame(rpart.rules(rpart_tree_obj, extra = 4, cover = TRUE, roundint = F))
    cols <- colnames(rule_table)
    colnames(rule_table) <- c("Response",paste0("Probabilty <br>","[",cols[2],"]"),seq(3,length(rule_table)-1),"% of Total Obs.")
    rules <- unite(rule_table, 'Conditions/Rules',4:length(rule_table)-1, sep = ' ', remove = TRUE)
    rules
  }
  
  output$ruletable <- DT::renderDataTable(DT::datatable({
    req(data$tree_obj)
    tree <- data$tree_obj
    data$rule_table <- get_rule_table(tree)
  }
  ,escape = F
  ,fillContainer = T
  ,options = list(lengthMenu = c(25, 50, 100), pageLength = 25,
                  rowCallback = DT::JS(sprintf('function(row, data) {
                                          if (String(data[%s]).trim() == "Anomaly"  ){
                                                  $("td", row).css("background", "#994141");
                                                  $("td", row).css("color", "white");}}',toString(1)))
      )
    )
  )
  
  train_isoforest_anomaly_plot <- function(df_input){
    
    df_input <-  df_input %>% select_if(~ !any(is.na(.)))
    #Initialising IF model
    model <- isolationForest$new(
      num_trees = 100,
      sample_size = base::round(nrow(df_input)*0.10 + 2),
      replace = T,
      mtry = base::ceiling(sqrt(length(df_input))),
      seed = 12345
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
    #Removing cols with non numeric vals
    pca_input <- dplyr::select_if(df_input, is.numeric)
    #Removing cols with constant variance
    pca_input <- pca_input[ , which(apply(pca_input, 2, var) != 0)]
    
    if(length(pca_input) != length(df_input)){
      showNotification(type="warning", duration=10,
        div(p("Note: The Selected columns seem to contain non-numeric types or columns with constant VAR. Such columns will not be used for computation on PCA plots "))
        )
    }
    
    # Getting Principal Component
    pca <- prcomp(pca_input, scale. = T , center = T)
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
    df_input$Predicted_Label <- pca_df$anom
    data$df <- df_input
    
    fig
  }
  
  output$report_tab <- renderUI({
    validate(
      need(!is.null(data$df), "Please upload your data first"),
      need(!is.null(data$rule_table),"Please Run through the complete workflow in order to add comments and export plots")
    )
    
    fluidRow(
      column(10, offset=2,
            div(
              h3("Add any comments/descriptions for plots to be included in the report in the respective text boxes."),
              textAreaInput("pair_desc", "Pair Plot", rows = 2,width = '100%' , placeholder = 'Add comments for plots here'),
              textAreaInput("pca_desc", "PCA Plot", rows = 2,width = '100%' , placeholder = 'Add comments for plots here'),
              textAreaInput("tree_desc", "Tree Plot", rows = 2, width = '100%', placeholder = 'Add comments for plots here'),
              textAreaInput("rule_desc", "PCA Plot", rows = 2 ,width = '100%', placeholder = 'Add comments for plots here'),
              downloadButton("report", "Generate report")
              
              )
      )
    )
    
    
  })
  
  output$report <- downloadHandler(
    # For PDF output, change this to "report.pdf"
    filename = "MSStatsQC-Mod2Report.html",
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions.
      
      tempReport <- file.path(tempdir(), "MSStatsQC-Mod1Report.Rmd")
      file.copy("MSStatsQC-Mod1Report.Rmd", tempReport, overwrite = TRUE)
      
      # Set up parameters to pass to Rmd document
      params <- list(
                     pair_plot = data$pairplot,
                     pair_desc = input$pair_desc,
                     plotly_fig = data$plot,
                     pca_desc=input$pca_desc,
                     tree_plot = data$tree_obj,
                     tree_desc = input$tree_desc,
                     rule_table = data$rule_table,
                     rule_desc = input$rule_desc
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
