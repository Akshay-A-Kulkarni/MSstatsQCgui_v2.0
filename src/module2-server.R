mod2_server <- function(input, output, session) {
  

  
  observeEvent(input$switch_home, {
    shinyjs::click("clear_button", asis = FALSE)
    if (!is_page("home")) {
      change_page("/")}
  })

  errorStatus <- tryCatch({
    h2o.init(startH2O = FALSE)
  }, error = function(err) {
    errorStatus <- err[1]$message
    message(paste0(errorStatus,"\n Initializing new H2O cluster..."))
    # Inititialize H2o cluster
    try({h2o.shutdown(prompt = FALSE)}, silent=TRUE)
    h2o.init(ip = 'localhost', nthreads= -1)
    return(errorStatus)
  }) # END tryCatch
  
  
  ############################ MSstatsQCgui  ###########################
  data <- reactiveValues(df = NULL, 
                         mod2_upload_msg1 ="Upload Data or Try the Example",
                         mod2_upload_msg2 ="Upload Data or Try the Example",
                         guide = NULL, 
                         test = NULL,
                         anno = NULL,
                         metrics = NULL, 
                         L = NULL, 
                         U = NULL,
                         run=0)
  
  observeEvent(input$filein, { 
    file1 <- input$filein
    data$mod2_upload_msg1 <- file1$name
    data$guide <- input_checking(read.csv(file=file1$datapath, sep=",", header=TRUE, stringsAsFactors=TRUE))
    # data$guide <- read.csv(file=file1$datapath, sep=",", header=TRUE, stringsAsFactors=TRUE)
    
    validate(
      need(!is.null(data$guide), "Please upload your data"),
      need(is.data.frame(data$guide), data$guide)
    )
    # data$metrics <- c(find_custom_metrics(data$df))
  }, priority = 40)
  

  
  observeEvent(input$testin, {
    file2 <- input$testin
    data$mod2_upload_msg2 <- file2$name
    
    data$test <- input_checking(read.csv(file=file2$datapath, sep=",", header=TRUE, stringsAsFactors=TRUE))
    # data$test <- read.csv(file=file2$datapath, sep=",", header=TRUE, stringsAsFactors=TRUE)
    
    validate(
      need(!is.null(data$test), "Please upload your data"),
      need(is.data.frame(data$test), data$test)
    )
    
    guideset <- data$guide
    testset <- data$test
    df1 <- rbind(guideset,testset)
    
    data$df <- df1
    # data$df <- input_checking(df1)
    data$metrics <- c(find_custom_metrics(data$df))
  }, priority = 40)
  
  observeEvent(input$anno_in, {
    file3 <- input$anno_in
    data$mod2_upload_msg2 <- file3$name
    
    data$anno <- input_checking(read.csv(file=file3$datapath, sep=",", header=TRUE, stringsAsFactors=TRUE))
    # data$test <- read.csv(file=file2$datapath, sep=",", header=TRUE, stringsAsFactors=TRUE)
    
    validate(
      need(!is.null(data$anno), "Please upload your data"),
      need(is.data.frame(data$anno), data$anno)
    )
  }, priority = 40)
  
  observeEvent(input$run_method, {

    waitress <- Waitress$new("#module2-results", theme = "overlay-percent")
    for(i in 1:10){
      waitress$inc(10) # increase by 10%
      Sys.sleep(.1)
    }
    if (input$method_selection == 'MSstatsQC-ML'){
      hideTab(inputId = "module2-results", target = "spc1")
      hideTab(inputId = "module2-results", target = "spc2")
      showTab(inputId = "module2-results", target = "ml1")
    }
    else{
      showTab(inputId = "module2-results", target = "spc1")
      showTab(inputId = "module2-results", target = "spc2")
      hideTab(inputId = "module2-results", target = "ml1")    
      }
    waitress$close() # hide when done
  }, priority = 20)
  
  observeEvent(input$sample_button, {
    data$guide <- input_checking(read.csv("./Datasets/simData_guide.csv", stringsAsFactors = T))
    data$test <- input_checking(read.csv("./Datasets/simData_test.csv", stringsAsFactors = T))
    
    guideset <- data$guide
    testset <- data$test
    df1 <- rbind(guideset,testset)

    data$df <- input_checking(df1)
    data$mod2_upload_msg1 <- "Example loaded"
    data$mod2_upload_msg2 <- "Example loaded"

    data$metrics <- c(find_custom_metrics(data$df))
  }, priority = 20

  )

  output$mod2_upload_component1 <- renderUI({
    fileInput("filein", label= p(strong("Guide Data")), accept = c(".csv"), placeholder = data$mod2_upload_msg1)
  })
  
  output$mod2_upload_component2 <- renderUI({
    fileInput("testin", label= p(strong("Test Data")), accept = c(".csv"), placeholder = data$mod2_upload_msg2)
  })
  
  observeEvent(input$clear_button, {
    data$df <- NULL
    data$metrics <- NULL
    data$guide <-  NULL
    data$test <-  NULL
    data$anno <- NULL
    data$L <-  NULL
    data$U <- NULL
    data$mod2_upload_msg1 ="Upload Data or Try the Example"
    data$mod2_upload_msg2 ="Upload Data or Try the Example"
    run=0
  }, priority = 40)
  
  
  output$guideview <- DT::renderDataTable(DT::datatable({
    req(data$guide)
    outputdata <- data$guide
  }
  ,fillContainer = T
  ,options = list(lengthMenu = c(25, 50, 100), pageLength = 25, scroller = list(rowHeight = 100))
  )
  )

  output$testview <- DT::renderDataTable(DT::datatable({
    req(data$test)
    outputdata <- data$test
  }
  ,fillContainer = T
  ,options = list(lengthMenu = c(25, 50, 100), pageLength = 25, scroller = list(rowHeight = 100))
  )
  )
  
  ##### Precursor type selection #####################################################################################
  output$pepSelect <- renderUI({
    prodata <- data$df
    validate(
      need(!is.null(prodata), "Please upload your data.\n\n If your data contains min start time and max end time columns, the App will add a peak assymetry column automatically.\n\n Your data should contain a column named Annotation. Put all your metrics after this column.To see an example of a sample data click on the {Run with example data} button."),
      need(is.data.frame(prodata), prodata)
    )
    selectInput("pepSelection","Choose peptide"
                ,choices = c(levels(prodata$Precursor),"all peptides"), selected = "all peptides" )
  })
  ######Show table of data #####################################################################################################

  observeEvent(input$showguide, {
    showModal(modalDialog(
      title = "Uploaded Data",
      size = "l",
      easyClose = TRUE,
      if(is.null(data$guide)){p("Please upload your data or click [run with example data] to view the data here!")}
      else{DT::dataTableOutput("guideview",height = "70vh")}
    ))
  })
  
  observeEvent(input$showtest, {
    showModal(modalDialog(
      title = "Uploaded Data",
      size = "l",
      easyClose = TRUE,
      if(is.null(data$test)){p("Please upload your data or click [run with example data] to view the data here!")}
      else{DT::dataTableOutput("testview",height = "70vh")}
    ))
  })
  
  observeEvent(input$desc_modal, {
    showModal(modalDialog(
      title = "Uploaded Data",
      size = "l",
      easyClose = TRUE,
      if(is.null(data$test)){
        p("Please upload your data or click [run with example data] to view the data here!")
        }
      else if(input$box_plot_switch=="Per-Peptide"){uiOutput("box_plotly")}
      else if(input$box_plot_switch=="Per-Metric"){plotlyOutput("box_plot")}
      else{p("Something went wrong :(")}
      
    ))
  })
  
  ###### selection tab in Data Import and selection #####################################################
  check_mark_green <- HTML('<span class="glyphicon glyphicon glyphicon-ok-sign" style="font-size:3rem;color:green;"></span>')
  check_mark <- HTML('<span class="glyphicon glyphicon glyphicon-ok-circle" style="font-size:3rem;"></span>')
  
  output$upload_mark <- renderUI({
    uploaded <- !is.null(data$df)
    
    if(uploaded){ 
      # Given all checks pass set guide bounds  ( IMP - The number of observations of each peptide in the guideset MUST be equal.)
      # guideset <- data$guide
      data$L <- 1
      data$U <- nrow(data$guide)/length(levels(data$guide$Precursor))
      
      # Give Green-Light
      check_mark_green 
      }
    else{ check_mark }
  })
  output$metric_mark <- renderUI({
    if(length(input$user_selected_metrics)>=1){ check_mark_green }
    else{ check_mark }
  })

  output$threshold_mark <- renderUI({
    if(length(input$user_selected_metrics)>=1){ check_mark_green }
    else{ check_mark }
  })  
  
  output$selectMeanSD <- renderUI({
    lapply(input$user_selected_metrics,
           function(x){
             fluidRow(
               column(4,paste(x,":")),
               column(4,
                      numericInput(paste0("selectMean@",x),"mean",value = 1)
               ),
               column(4,
                      numericInput(paste0("selectSD@",x),"standard deviation",value = 1)
               )
             )
           })
  })
  
  # output$selectGuideSet <- renderUI({
  #   guideset <- data$guide
  #   print(nrow(guideset))
  #   
  #   fluidRow(
  #     column(6,
  #            numericInput("L","Lower bound of guide set",value = 1)
  #     ),
  #     column(6,
  #            numericInput("U","Upper bound of guide set", value = nrow(guideset))
  #     )
  #   )


  # })
  
  ###### Tab for selecting decision rule and metrics ###############################################
  
  output$metricSelection <- renderUI({
    pickerInput(
      inputId = "user_selected_metrics", 
      label = "Select one, multiple or all metrics", 
      choices = c(data$metrics), 
      options = list(
        `actions-box` = TRUE,
        `style`="background-color:white; color:black"
      ), 
      multiple = TRUE
    )
  })
  
   output$metricThresholdRed <- renderUI({
    numOfMetrics <- length(input$user_selected_metrics)
    numericInput('threshold_metric_red', '', value = 2, min = 0, max = numOfMetrics, step = 1)
  })
  
  output$peptideThresholdYellow <- renderUI({
    threshold_peptide_red <- input$threshold_peptide_red
    numericInput('threshold_peptide_yellow', '', value = threshold_peptide_red - 1, min = 1, max = threshold_peptide_red, step = 1)
  })
  
  output$metricThresholdYellow <- renderUI({
    numOfMetrics <- length(input$user_selected_metrics)
    threshold_metric_red <- input$threshold_metric_red
    validate(
      need(!is.null(numOfMetrics),"loading..."),
      need(!is.null(threshold_metric_red),"loading...")
    )
    
    numericInput('threshold_metric_yellow', '', value = threshold_metric_red , min = 0, max = threshold_metric_red, step = 1)
  })
  

  
  ################################################################# plots ###################################################
  #################################################################################################################
  output$XmR_tabset <- renderUI({
    
    validate(
      need(!is.null(data$df), "Please upload your data first"),
      need(is.data.frame(data$df), data$df),
      need(!is.null(input$user_selected_metrics),"Please first select metrics and create a decision rule")
    )
    is_guidset_selected <- FALSE
    if(input$selectGuideSetOrMeanSD == "Mean and standard deviation estimated from guide set") {
      is_guidset_selected <- TRUE
    }
    Tabs <- lapply(input$user_selected_metrics,
                   function(x) {
                     tabPanel(x,
                              tags$head(tags$style(type="text/css")),
                              conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                               tags$div("It may take a while to load the plots, please wait...",
                                                        id="loadmessage")),
                              renderPlotly(render.QC.chart(data$df, input$pepSelection, data$L,
                                                           data$U, metric = x,
                                                           plot.method = "XmR", normalization = FALSE,
                                                           y.title1 = "Individual Value", y.title2 = "Moving Range",
                                                           selectMean = input[[paste0("selectMean@",x)]],selectSD = input[[paste0("selectSD@",x)]],
                                                           guidset_selected = is_guidset_selected)
                              )
                              
                     )
                   })
    do.call(tabsetPanel, Tabs)
    
  })
  ################################################################################################################
  #################################################################################################################
  output$CUSUM_tabset <- renderUI({
    validate(
      need(!is.null(data$df), "Please upload your data first"),
      need(is.data.frame(data$df), data$df),
      need(!is.null(input$user_selected_metrics),"Please first select metrics and create a decision rule")
    )
    is_guidset_selected <- FALSE
    if(input$selectGuideSetOrMeanSD == "Mean and standard deviation estimated from guide set") {
      is_guidset_selected <- TRUE
    }
    Tabs <- lapply(input$user_selected_metrics,
                   function(x) {
                     
                     tabPanel(x,
                              tags$head(tags$style(type="text/css")),
                              conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                               tags$div("It may take a while to load the plots, please wait...",
                                                        id="loadmessage")),
                              renderPlotly(render.QC.chart(data$df, input$pepSelection, data$L, data$U, metric = x, plot.method = "CUSUM", normalization = TRUE, y.title1 = "CUSUM mean", y.title2 = "CUSUM variation",selectMean = input[[paste0("selectMean@",x)]],selectSD = input[[paste0("selectSD@",x)]],guidset_selected = is_guidset_selected))
                     )
                   })
    
    do.call(tabsetPanel, Tabs)
  })
  ################################################################################################################
  #################################################################################################################
  output$CP_tabset <- renderUI({
    validate(
      need(!is.null(data$df), "Please upload your data first"),
      need(is.data.frame(data$df), data$df),
      need(!is.null(input$user_selected_metrics),"Please first select metrics and create a decision rule")
    )
    is_guidset_selected <- FALSE
    if(input$selectGuideSetOrMeanSD == "Mean and standard deviation estimated from guide set") {
      is_guidset_selected <- TRUE
    }
    Tabs <- lapply(input$user_selected_metrics,
                   function(x) {
                     tabPanel(x,
                              tags$head(tags$style(type="text/css")),
                              conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                               tags$div("It may take a while to load the plots, please wait...",
                                                        id="loadmessage")),
                              renderPlotly(render.QC.chart(data$df, input$pepSelection, data$L, data$U, metric = x, plot.method = "CP", normalization = TRUE, y.title1 = "Change point for mean", y.title2 = "Change point for variation",selectMean = input[[paste0("selectMean@",x)]],selectSD = input[[paste0("selectSD@",x)]],guidset_selected = is_guidset_selected))
                     )
                   })
    
    do.call(tabsetPanel, Tabs)
  })
  ######################################################### height and width in Summary tab ########################################
  my_height <- reactive({
    l <- length(input$user_selected_metrics)
    k <- length(input$summary_controlChart_select)
    if(l < 5) {
      my_height <- ceiling(k)*700
    }else if(l < 9) {
      my_height <- ceiling(k)*1300
    }else if(l <15) {
      my_height <- ceiling(k)*1700
    }else if(l < 20) {
      my_height <- ceiling(k)*2000
    }else if(l < 25) {
      my_height <- ceiling(k)*2300
    }else {
      my_height <- ceiling(k)*2600
    }
  })
  
  my_width <- reactive({
    l = length(input$user_selected_metrics)
    if(l == 1) {
      my_width = 300
    }else if(l == 2) {
      my_width = 800
    }else if(l == 3) {
      my_width = 1000
    }
    my_width <- 1200
    
  })
  
  heatmap_height <- reactive({
    l <- length(input$user_selected_metrics)
    k <- length(input$heatmap_controlChart_select)
    if(l == 1) {
      heatmap_height <- ceiling(k)*300
    }else {
      heatmap_height <- ceiling(k)*ceiling(l)*100
    }
  })
  
  heatmap_width <- reactive({
    heatmap_width <- 1000
  })
  ########################################################## box plot in Metric Summary tab ##########################################
  output$box_plot <- renderPlotly({
    prodata <- data$df
    validate(
      need(!is.null(prodata), "Please upload your data"),
      need(is.data.frame(prodata), prodata),
      need(!is.null(input$user_selected_metrics),"Please first select metrics and create a decision rule")
    )
    metrics_box.plot(prodata, data.metrics = input$user_selected_metrics)
  })
  

  
  output$box_plotly <- renderUI({
    guideset <- data$guide
    testset <- data$test
    validate(
      need(!is.null(guideset), "Please upload your Guide data"),
      need(is.data.frame(guideset), guideset),
      need(!is.null(testset), "Please upload your Test data"),
      need(is.data.frame(testset), testset),
      need(!is.null(input$user_selected_metrics),"Please first select metrics and create a decision rule")
    )
    # guide_box_plots <- metrics_box.plot(guideset, data.metrics = input$user_selected_metrics, ret_obj_list = T)
    # test_box_plots <- metrics_box.plot(testset, data.metrics = input$user_selected_metrics, ret_obj_list = T)
    
    
    if(input$pepSelection == 'all peptides'){
      boxplot_peps <- c(levels(guideset$Precursor))
    }
    else{
      boxplot_peps <- input$pepSelection
    }
    
    
    get_plot_output_list <- function(input_n) {
      
      guide_box_plots <- peptide_box.plot(guideset, data.peptides = boxplot_peps, data.metrics = input$user_selected_metrics, ret_obj_list = T)
      test_box_plots <-  peptide_box.plot(testset, data.peptides = boxplot_peps, data.metrics = input$user_selected_metrics, ret_obj_list = T)
      
      data$box_plots <- guide_box_plots
      
      # Insert plot output objects the list
      plot_output_list <- lapply(1:input_n, function(i) {
        plotname <- paste("boxplot", i, sep="")
        plot_output_object <- plotlyOutput(plotname)
        plot_output_object <- wellPanel(h3(strong(levels(testset$Precursor)[[i]])),br(),
                                      fluidRow(column(6,h4("Guide Set"),renderPlotly({ guide_box_plots[[i]]})),column(6,h4("Test Set"),renderPlotly({ test_box_plots[[i]]})))  
                                      )
      })

      do.call(tagList, plot_output_list) # needed to display properly.
      

      return(plot_output_list)
    }

    get_plot_output_list(length(boxplot_peps))
    
    })
  
  
  
  ###############   summary plots and radar plots ############################################################################
  output$plot_summary <- renderPlot({
    
    prodata <- data$df
    validate(
      need(!is.null(prodata), "Please upload your data"),
      need(is.data.frame(prodata), prodata),
      need(!is.null(input$user_selected_metrics),"Please first select metrics and create a decision rule")
    )
    
    is_guidset_selected <- FALSE
    if(input$selectGuideSetOrMeanSD == "Mean and standard deviation estimated from guide set") {
      is_guidset_selected <- TRUE
    }
    listMean <- list()
    listSD <- list()
    for(metric in input$user_selected_metrics){
      listMean[[metric]] <- input[[paste0("selectMean@",metric)]]
      listSD[[metric]] <- input[[paste0("selectSD@",metric)]]
    }
    
    plots <- list()
    i <- 1
    for(method in input$summary_controlChart_select) {
      p1 <- NULL
      p2 <- NULL
      if(method == "XmR") {
        p1 <- XmR.Summary.plot(prodata, data.metrics = input$user_selected_metrics, data$L, data$U, listMean = listMean,listSD = listSD, guidset_selected = is_guidset_selected)
        p2 <- XmR.Radar.Plot(prodata, data.metrics = input$user_selected_metrics,data$L,data$U,listMean = listMean,listSD = listSD, guidset_selected = is_guidset_selected)
      } else if(method == "CUSUM") {
        p1 <- CUSUM.Summary.plot(prodata, data.metrics = input$user_selected_metrics, data$L, data$U,listMean = listMean,listSD = listSD, guidset_selected = is_guidset_selected)
        p2 <- CUSUM.Radar.Plot(prodata, data.metrics = input$user_selected_metrics, data$L,data$U,listMean = listMean,listSD = listSD, guidset_selected = is_guidset_selected)
      }
      plots[[i]]   <- p1
      plots[[i+1]] <- p2
      
      i <- i+2
    }
    if(length(plots) > 0)
      do.call("grid.arrange", c(plots, ncol = 1))
  }, height = my_height)
  ############################# heat_map in Summary tab #############################################
  output$heat_map <- renderPlot({
    validate(
      need(!is.null(data$df), "Please upload your data"),
      need(is.data.frame(data$df), data$df),
      need(!is.null(input$user_selected_metrics),"Please first select metrics and create a decision rule"),
      need(!is.null(data$df$AcquiredTime),"To view heatmaps, the dataset should include Acquired Time column.")
    )
    
    prodata <- data$df
    peptideThresholdRed <- (as.numeric(input$threshold_peptide_red))/100
    peptideThresholdYellow <- (as.numeric(input$threshold_peptide_yellow))/100


    if(is.null(prodata$AcquiredTime)) return(NULL)
    
    is_guidset_selected <- FALSE
    if(input$selectGuideSetOrMeanSD == "Mean and standard deviation estimated from guide set") {
      is_guidset_selected <- TRUE
    }
    
    listMean <- list()
    listSD <- list()
    for(metric in input$user_selected_metrics){
      listMean[[metric]] <- input[[paste0("selectMean@",metric)]]
      listSD[[metric]] <- input[[paste0("selectSD@",metric)]]
    }
    
    plots <- list()
    i <- 1
    for(method in input$heatmap_controlChart_select) {
      p1 <- metrics_heat.map(prodata,
                             data.metrics = input$user_selected_metrics, method = method,
                             peptideThresholdRed, peptideThresholdYellow,data$L, data$U, type = 1,
                             title = "Decision-map : mean",
                             listMean = listMean, listSD = listSD, guidset_selected = is_guidset_selected)
      p2 <- metrics_heat.map(prodata,
                             data.metrics = input$user_selected_metrics, method = method,
                             peptideThresholdRed, peptideThresholdYellow,data$L, data$U, type = 2,
                             title = "Decision-map : variability",
                             listMean = listMean, listSD = listSD, guidset_selected = is_guidset_selected)
      plots[[i]]   <- p1
      plots[[i+1]] <- p2
      
      i <- i+2
    }
    if(length(plots) > 0)
      do.call("grid.arrange", c(plots, ncol = 1))
    
  }, height = heatmap_height)
  
  
  ############################# ml-heat_map in Summary tab #############################################
  
  observeEvent(input$run_method, {
    data$run <- data$run + 1
  }) 

  output$ml_heat_map <- renderUI({
    guide.set <- data$guide
    test.set <- data$test
    anno.set <- data$anno
    validate(
      need(!is.null(guide.set), "Please upload your train data"),
      need(is.data.frame(guide.set), guide.set),
      need(!is.null(test.set), "Please upload your test data"),
      need(is.data.frame(test.set), test.set),
      need(!is.null(input$user_selected_metrics),"Please first select metrics and create a decision rule")
    )
    
    # Take a dependency
    data$run
    # Use isolate() to avoid dependency on all other controls
    user_sim_bool <- isolate(input$use_sim_button)
    user_sim_size <- isolate(input$sim_size)
    method <- isolate(input$method_selection)
    
    
    
    if (data$run == 0) { return() } 
  
    else if(data$run != 0 && method == "MSstatsQC-ML"){
      
    
    showNotification(type="warning", duration=10,
      "Training the RF model with supplied settings - [This may take a while]")
    

    if (!is.null(anno.set)){
      trained_model <- MSstatsQC.ML.trainR(guide.set, use_simulation=user_sim_bool, sim.size=user_sim_size, guide.set.annotations = anno.set)
    }
    else {
      trained_model <- MSstatsQC.ML.trainR(guide.set, use_simulation=user_sim_bool, sim.size=user_sim_size)
    }
    
    showNotification(type="message", duration=5,
                     "Model Training Complete !")


    showNotification(type="warning", duration=10,
                    "Starting the Test phase and Generating plots - [This may take a while]")
    
    


    ML_plots <- MSstatsQC.ML.testR(test.set, guide.set, rf_model = trained_model)
      
      # Insert plot output objects the list
      plot_output_list <- lapply(1:length(ML_plots), function(i) {
        plotname <- paste("mlPlot", i, sep="")
        plot_output_object <- plotOutput(plotname, height = 280, width = 250)
        plot_output_object <- wellPanel(
                                        fluidRow(renderPlot({ML_plots[[i]]}))
                                        )
      })
      
      do.call(tagList, plot_output_list) # needed to display properly.
      
      return(plot_output_list)
    }
    
    else{
      return()
    }
  
  })
  
  output$mod2report <- downloadHandler(
    # For PDF output, change this to "report.pdf"
    filename = "MSStatsQC-Mod2Report.html",
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions.
      
      tempReport <- file.path(tempdir(), "MSStatsQC-Mod2Report.Rmd")
      file.copy("MSStatsQC-Mod2Report.Rmd", tempReport, overwrite = TRUE)
      
      # Set up parameters to pass to Rmd document
      params <- list(
        box_plots = data$box_plots
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
  

  # Shut down H2O cluster on app exit
  onStop(function() {
    try({h2o.shutdown(prompt = FALSE)}, silent=TRUE)
  })
  
  session$onSessionEnded(function() {
    # h2o::h2o.shutdown(prompt = F)
    stopApp()
  })
  
}


