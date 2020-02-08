# if (!"package:MSstatsQCgui" %in% search())
#   import_fs("MSstatsQCgui", incl = c("shiny","shinyBS","dplyr","plotly","RecordLinkage","ggExtra","gridExtra","grid"))
library(shiny)
library(shinythemes)
library(DT)
library(shinyBS)
library(waiter)
library(pushbar)
library(tablerDash)
library(shinyjs)
library(shinyWidgets)
library(plotly)


mod2_ui <-fluidPage(
  waiter::use_waiter(),
  pushbar::pushbar_deps(),
  shinyjs::useShinyjs(),
  cicerone::use_cicerone(),
  navbarPage(theme = shinythemes::shinytheme('cosmo'),position = 'fixed-top',
             title = div(id='Logo', img(src="www/logo.png",height=75,width=75),
                 "MSstatsQC",style="width:200%;
                                        font-size:30px;
                                        display:table-cell; 
                                        vertical-align:middle;"), 
             windowTitle = "MSstatsQC",
             header=tags$head(
               tags$style(HTML('body {padding-top: 8%;}
                                .navbar > .container-fluid {
                                    padding-left:5%;
                                    box-shadow: 0 6px 2px -2px rgba(0,0,0,.5);
                                    background-color:#1d1d1f;}
                                .navbar-nav > li > a, .navbar-brand {
                                  font-size: 1.7rem;
                                  margin:0;
                                  align-items: center;
                                  display: flex;
                                  height: 10vh;
                                .navbar-default .navbar-nav > .active:after {
                                  position: absolute;
                                  bottom: 0;
                                  left: 0;
                                  width: 100%;
                                  content: " ";
                                  border-bottom: 6px solid #e4e4e4;}
                                .navbar {min-height:25px !important;}
                                .modal-body{min-height:70vh !important; align:center}
                               .modal-lg { width: 60vw;}'))
             ),
             tabPanel(title= "About", icon = icon("bar-chart-o"), fluidPage(style = "width:80%; align:center;",
                                                includeMarkdown("include.md"))),
             # tabPanel("Upload",
             #          fluidPage(style = "width:80%",
             #                    sidebarLayout(
             #                      sidebarPanel(
             #                        h2("Upload Files"),
             #                        tags$hr(),
             #                        fileInput("file1", h3("Guide Set"),accept = c(".xlsx",
             #                                                                      ".csv")),
             #                        actionButton("show1", "Show Table"),
             #                        fileInput("file2", h3("Test Set")),
             #                        fileInput("file3", h3("Annotated Set")),
             #                        radioButtons("disp", "Display",
             #                                     choices = c(Head = "head",
             #                                                 All = "all"),
             #                                     selected = "all")
             #                      ),
             #                      mainPanel(
             #                        h1("Upload Files Tab"),
             #                        p("MSstatsQC-ML is a new tool that makes allows users to employ ML techniques to tackle a variety of", 
             #                          strong("QC problems for Mass Spectrometry")),
             #                        br(),
             #                        p("For an introduction and live example",
             #                          a("Old app homepage.", 
             #                            href = "https://eralpdogu.shinyapps.io/msstatsqc/")),
             #                        br(),
             #                        h2("Features"),
             #                        
             #                      )
             #                    )
             #          )
             # ),
             tabPanel("Data import and selection",icon = icon("upload"), id='upload_tab',
                      fluidPage(style = "width:85%",
                                sidebarLayout(
                                  sidebarPanel(
                                    wellPanel(
                                      p("Upload your data (Comma-separated (*.csv) QC file format)"),
                                      
                                      p("To see acceptable example data, look at", strong("Help"),"tab"),
                                      fileInput("filein", h3("Upload file"),accept = c(".xlsx", ".csv")),
                                      shinyWidgets::circleButton("showUpload1", icon = icon("table"), status = "default", size = "default"),
                                    ),
                                    
                                    wellPanel(
                                      p("If you want to run", strong("MSstatsQC"), "with example data file, click this button"),
                                      actionButton("sample_button", "Run with example data"),
                                    ),
                                    
                                    wellPanel(
                                      p("If you want to clean existing results, click this button"),
                                      
                                      actionButton("clear_button", "Clear data and plots")
                                      
                                    ),
                                    
                                  ),
                                  mainPanel(
                                    
                                    p(strong("Select metrics for all further analyses:")),
                                    
                                    wellPanel(
                                      fluidRow(
                                        column(10,
                                               uiOutput("metricSelection"),
                                               htmlOutput("metricSelectionErrorMsg")
                                               
                                        )
                                      )
                                    ),
                                    wellPanel(
                                      radioButtons("selectGuideSetOrMeanSD",
                                                   
                                                   "If you want to select mean and standard deviation yourself select them here. Otherwise choose the guide set button.",
                                                   #"define mean and standard deviation",
                                                   choices = c("Mean and standard deviation estimated by the user","Mean and standard deviation estimated from guide set")
                                      ),
                                      conditionalPanel(
                                        condition = "input.selectGuideSetOrMeanSD == 'Mean and standard deviation estimated by the user'",
                                        p("Select the mean and standard deviation"),
                                        uiOutput("selectMeanSD")
                                      ),
                                      conditionalPanel(
                                        condition = "input.selectGuideSetOrMeanSD == 'Mean and standard deviation estimated from guide set'",
                                        p("Select a guide set to estimate control limits"),
                                        
                                        uiOutput("selectGuideSet")
                                      )
                                    ),
                                    wellPanel(
                                      p("Select a precursor or select all"),
                                      uiOutput("pepSelect")
                                    ),
                                  )
                                )
                                
             )
          ),
          tabPanel("Decision Rule", icon = icon("ruler-combined"),    
          fluidPage(style="width:80%",                               
            div(
            # bsCollapse(id = "collapseExample", open = "Panel 1",
            #            bsCollapsePanel("Panel 1", "This is a panel with just text ",
            #                            "and has the default style. You can change the style in ",
            #                            "the sidebar.")
            # ),
            h4(strong("Create your decision rule:")),
            bsCollapsePanel(p(strong("RED FLAG"), style="color:black; background-color: red;",align = "center",style="font-size:125%;"),
                            div(
                              p(strong("System performance is UNACCEPTABLE when:"),align = "center"),
                              p("1. greater than the selected % of peptides are", strong("out of control"),"and"),
                              p("2. greater than the selected # of metrics are", strong("out of control."))
                            ),
                            fluidRow(
                              column(2,
                                     br()
                              ),
                              column(5,
                                     p(strong("% out of control peptides: ")),
                                     numericInput('threshold_peptide_red', '', value = 70, min = 0, max = 100, step = 1)
                              ),
                              column(5,
                                     p(strong("# out of control metrics: ")),
                                     uiOutput("metricThresholdRed")
                              )
                            )
            ),
            
            bsCollapsePanel(p(strong("YELLOW FLAG"), style="color:black; background-color: yellow;",align = "center",style="font-size:125%;"),
              fluidPage(
                p(strong("System performance is POOR when:"),align = "center"),
                p("1. greater than the selected % of peptides are", strong("out of control"),"and"),
                p("2. greater than the selected # of metrics are", strong("out of control.")),
                p("Warning:The limits should be less than or equal to the the RED FLAG limits")
              ),
              fluidRow(
                column(2,
                       br()
                ),
                column(5,
                       p(strong("% of out of control peptides: ")),
                       uiOutput("peptideThresholdYellow")
                ),
                column(5,
                       p(strong("# of out of control metrics: ")),
                       uiOutput("metricThresholdYellow")
                )
              )
            ),
            bsCollapsePanel(p(strong("BLUE FLAG"), style="color:white; background-color: blue;",align = "center",style="font-size:125%;"),
              fluidPage(
                p(strong("System performance is ACCEPTABLE when:"),align = "center"),
                p("RED FLAG and YELLOW FLAG limits are not exceeded.")
              )
              
            )
          ))
          ),
          tabPanel("Metric summary",icon = icon("chart-line"),
                   tabsetPanel(
                     
                     tabPanel("Descriptives : boxplots for metrics",
                              tags$head(tags$style(type="text/css")),
                              conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                               tags$div("It may take a while to load the plots, please wait...",
                                                        id="loadmessage")),
                              plotlyOutput("box_plot", height = 2000)
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
                                mainPanel(plotOutput("heat_map")
                                )
                              )
                     ),
                     
                     tabPanel("Detailed performance: plot summaries",
                              tags$head(tags$style(type="text/css")),
                              conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                               tags$div("It may take a while to load the plots, please wait...",
                                                        id="loadmessage")),
                              sidebarLayout(
                                sidebarPanel(
                                  checkboxGroupInput("summary_controlChart_select", "Select your control chart",
                                                     choices = c("CUSUM charts" = "CUSUM","XmR chart" = "XmR"), selected = "XmR")
                                  #htmlOutput("summary_decision_txt")
                                ),
                                mainPanel(
                                  plotOutput("plot_summary")
                                )
                              )
                     )
                   )
          )
  ),
  fixedPanel(
    actionButton("openModulesPane", icon("chevron-up")),
    right = 10,
    bottom = 10
  ),
  # pushbar(id='bottom',
  #       fluidPage(
  #         fluidRow(actionButton("bottom_close", "", icon = icon("times"), class = "btn-danger"), style="padding-bottom:1%;float:right;"))
  #       ,fluidPage(
  #         fluidRow(
  #           column(4,wellPanel(includeMarkdown("mod1.md"))),
  #           column(4,wellPanel(includeMarkdown("mod2.md"))),
  #           column(4,wellPanel(includeMarkdown("mod3.md")))
  #         )),
  #       from = "bottom",
  #       style = "height:50%; background-color:white; padding:1%;"
  # )
)
