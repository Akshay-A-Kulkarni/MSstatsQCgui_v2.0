# if (!"package:MSstatsQCgui" %in% search())
#   import_fs("MSstatsQCgui", incl = c("shiny","shinyBS","dplyr","plotly","RecordLinkage","ggExtra","gridExtra","grid"))
# library(shiny)
# library(shinythemes)
# library(DT)
# library(shinyBS)
# library(waiter)
# library(pushbar)
# library(tablerDash)
# library(shinyjs)
# library(shinyWidgets)
# library(plotly)
# library(dplyr)
# library(ggExtra)
# library(gridExtra)
# library(grid)

hr_line <- HTML('<hr style ="border-color:black; font-size:5rem;">')



 
mod2_ui <-  fluidPage(
  navbarPage(theme = shinythemes::shinytheme('cosmo'),position = 'fixed-top',
             title = div(id='Logo', div(img(src="logo.png", height=75, width=75),"MSstatsQC"),
                                  style="width:200%;
                                        font-size:30px;
                                        display:table-cell; 
                                        vertical-align:middle;"), 
             windowTitle = "MSstatsQC",
             header=tags$head(
               tags$style(HTML('body { padding-top: 8%;}
                                .navbar > .container-fluid {
                                    padding-left:5%;
                                    box-shadow: 0 6px 2px -2px rgba(0,0,0,.5);
                                    background-color:#1d1d1f;}
                                .navbar-nav > li > a > .fa { padding-right:25px }
                                .navbar-nav > li > a > b { margin-left:10px }
                                .navbar-nav > li > a, .navbar-brand {
                                  font-size: 1.7rem;
                                  margin:0;
                                  align-items: center;
                                  display: flex;
                                  height: 10vh;
                                .navbar-default .navbar-nav > a > .active:after {
                                  position: absolute;
                                  bottom: 0;
                                  left: 0;
                                  width: 100%;
                                  content: " ";
                                  border-bottom: 6px solid #e4e4e4;}
                                .navbar {min-height:250px !important;}
                                .modal-body{min-height:70vh !important; align:center}
                               .modal-content, modal-lg {min-width: 80vw;}'))
             ),
             tabPanel(title= "About", icon = icon("bar-chart-o"), 
                      fluidPage(style = "width:80%; align:center;",
                                                includeMarkdown("www/mod2.md"),
                                                h3("How-To:"),
                                                br(),
                                                h4(strong("- Uploading files")),
                                                br(),
                                                img(src="upload.gif", width="80%" , align= "center"),
                                                br(),
                                                br(),
                                                br(), 
                                                h4(strong("- Selecting Metrics")),
                                                br(),
                                                img(src="metrics.gif", width="80%" , align= "center"))),

             tabPanel(title = "Data Import & Metric Rules",icon = icon("upload"), id='upload_tab',
                      fluidPage(style = "width:95%",
                            fluidRow(
                                    column(3,
                                           fluidRow(column(5,hr_line),column(2,style="padding: 0%",align="center",strong("1.Upload"),br(),uiOutput("upload_mark")),column(5,hr_line)),
                                           p(strong("Upload File")),                               
                                          wellPanel(
                                            p("Upload your data (Comma-separated (*.csv) QC file format)"),
                                            p("To see acceptable example data, look at", strong("Help"),"tab"),
                                            fluidRow(column(9,fileInput("filein", label= p(strong("Guide Data")), accept = c(".csv"))),
                                                     column(3,style = "padding-top: 10%", tipify(actionButton("showguide", "", icon = icon("fullscreen", lib = "glyphicon")),"Click to View Guideset"))
                                                     ),
                                            fluidRow(column(9,fileInput("testin", label= p(strong("Test Data")), accept = c(".csv"))),
                                                     column(3,style = "padding-top: 10%",tipify(actionButton("showtest", "", icon = icon("fullscreen", lib = "glyphicon")),"Click to View Testset"))
                                            ),
                                            ),
                                          
                                          wellPanel(
                                            p("If you want to run", strong("MSstatsQC"), "with example data file, click this button"),
                                            actionButton("sample_button", "Run with example data"),
                                          ),
                                          
                                          wellPanel(
                                            p("If you want to clean existing results, click this button"),
                                            
                                            actionButton("clear_button", "Clear data and plots")
                                            
                                          )),
                                    column(5,
                                           fluidRow(column(5,hr_line),column(2,style="padding: 0%", align="center",strong("2.Metrics"),br(),uiOutput("metric_mark")),column(5,hr_line)),
                                           p(strong("Select metrics for all further analysis:")),
                                                            wellPanel(
                                                              fluidRow(
                                                                column(10,
                                                                       uiOutput("metricSelection"),
                                                                       uiOutput("metricSelection1"),
                                                                       htmlOutput("metricSelectionErrorMsg")
                                                                       
                                                                )
                                                              )
                                                            ),
                                                            wellPanel(
                                                              radioButtons("selectGuideSetOrMeanSD",
                                                                           
                                                                           "If you want to select mean and standard deviation yourself select them here. Otherwise choose the guide set button.",
                                                                           #"define mean and standard deviation",
                                                                           choices = c("Mean and standard deviation estimated from guide set","Mean and standard deviation estimated by the user")
                                                              ),
                                                              conditionalPanel(
                                                                condition = "input.selectGuideSetOrMeanSD == 'Mean and standard deviation estimated by the user'",
                                                                p(strong("Using Below values for mean and standard deviation")),
                                                                uiOutput("selectMeanSD")
                                                              ),
                                                              conditionalPanel(
                                                                condition = "input.selectGuideSetOrMeanSD == 'Mean and standard deviation estimated from guide set'",
                                                                p(strong("Using the guide set to estimate control limits")),
                                                                )
                                                            ),
                                                            wellPanel(
                                                              p("Select a precursor or select all"),
                                                              uiOutput("pepSelect")
                                                            )),
                                  column(4,
                                         fluidRow(column(5,hr_line),column(2, style="padding: 0%", align="center",strong("3.Thresholds"),br(),uiOutput("threshold_mark")),column(5 ,hr_line)),
                                      p(strong("Create Your Decision Rules")),
                                      wellPanel(
                                      div(p(strong("RED FLAG"), style="color:black; background-color: red;",align = "center",style="font-size:125%;"), 
                                                   fluidPage(p(strong("System performance is UNACCEPTABLE when:"),align = "center"),
                                                                    p("peptides greater than the selected % of peptides are", strong("out of control")),
                                                                    fluidRow(
                                                                      column(6,
                                                                             div(style ="padding-top:15%;", strong("% out of control peptides: "))),
                                                                      column(6,
                                                                             numericInput('threshold_peptide_red', '', value = 70, min = 0, max = 100, step = 1)
                                                                      )
                                                                    ))),
                                      div(p(strong("YELLOW FLAG"), style="color:black; background-color: #ffd700;",align = "center",style="font-size:125%;"), 
                                              fluidPage(p(strong("System performance is POOR when:"),align = "center"),
                                                                 p(" peptides greater than the selected % of peptides are", strong("out of control")),
                                                                 p("Warning:The limits should be less than or equal to the the RED FLAG limit") ,
                                                                 fluidRow(
                                                                   column(6,
                                                                          div(style ="padding-top:15%;", strong("% of out of control peptides: "))),
                                                                   column(6,
                                                                          uiOutput("peptideThresholdYellow")),
                                                                         ))),
                                      div(p(strong("BLUE FLAG"), style="color:white; background-color: blue;",align = "center",style="font-size:125%;"),
                                                  fluidPage(
                                                    p(strong("System performance is ACCEPTABLE when:"),align = "center"),
                                                    p("RED FLAG and YELLOW FLAG limits are not exceeded.")
                                                  )
                                                ) 
                                  ))
                          )
                                  
             )
          ),
          tabPanel("Metric summary",icon = icon("chart-line"),
                   tabsetPanel(
                     
                     tabPanel("Descriptives : boxplots for metrics",
                              tags$head(tags$style(type="text/css")),
                              conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                               tags$div("It may take a while to load the plots, please wait...",
                                                        id="loadmessage")),
                              fluidPage(
                                awesomeRadio(
                                  inputId = "box_plot_switch",
                                  label = "Layout", 
                                  choices = c("Per-Peptide", "Per-Metric"),
                                  selected = "Per-Peptide",
                                  inline = TRUE, 
                                  status = "success"
                                ),
                              conditionalPanel(condition = 'input.box_plot_switch=="Per-Peptide"',uiOutput("box_plotly")),
                              conditionalPanel(condition = 'input.box_plot_switch=="Per-Metric"',(plotlyOutput("box_plot"))),
                              )
                              
                     ),
                     
                     tabPanel("Overall performance : decision maps",
                              tags$head(tags$style(type="text/css")),
                              conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                               tags$div("It may take a while to load the plots, please wait...",
                                                        id="loadmessage")),
                              sidebarLayout(
                                sidebarPanel(
                                  checkboxGroupInput("heatmap_controlChart_select", "Select your control chart",
                                                     choices = c("CUSUM charts" = "CUSUM","XmR chart" = "XmR"), selected = "XmR")
                                  #htmlOutput("heatmap_txt")
                                ),
                                mainPanel(plotOutput("heat_map"))
                              )
                     ),
                     
                     tabPanel("Detailed performance: plot summaries",
                              tags$head(tags$style(type="text/css")),
                              conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                               tags$div("It may take a while to load the plots, please wait...",
                                                        id="loadmessage")),
                              fluidPage(fluidRow(br(),column(2,wellPanel(
                                prettyCheckboxGroup(
                                  'summary_controlChart_select',
                                  'Select your control chart',
                                  choices = c("CUSUM charts" = "CUSUM","XmR chart" = "XmR"),
                                  selected = "XmR",
                                  shape = "square",
                                  thick = TRUE,
                                  animation = "jelly",
                                  icon = icon("check"),
                                  bigger = TRUE,
                                ),
                                # checkboxGroupInput("summary_controlChart_select1", "Select your control chart",
                                #                                              choices = c("CUSUM charts" = "CUSUM","XmR chart" = "XmR"), selected = "XmR")
                                )),
                                  column(10,plotOutput("plot_summary"))
                                  )),
                     )
                   )
          ),
          navbarMenu("Control charts",
                     tabPanel("XmR control charts",
                              uiOutput("XmR_tabset")
                     ),
                     
                     tabPanel("CUSUMm and CUSUMv control charts",
                              uiOutput("CUSUM_tabset")
                     ),
                     tabPanel("Change point analysis for mean and variability",
                              uiOutput("CP_tabset")
                     )
          )
  ),
  fixedPanel(
    actionButton("switch_home", icon("home")),
    left = 15,
    bottom = 15
  ),
)
