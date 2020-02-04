library(shiny)
library(shinythemes)
library(DT)
library(shinyBS)
library(waiter)
library(pushbar)
library(tablerDash)

ui <-fluidPage(
  use_waiter(),
  pushbar_deps(),
  style='padding:0%; margin:0%',
  list(
    tags$head(
      HTML('<link rel="icon" href="logo.png" 
                type="image/png" />'))),
  navbarPage(theme = shinythemes::shinytheme('cosmo'),position = 'fixed-top',
             title = div(img(src="logo.png",height=75,width=75),
                 "MSstatsQC",style="width:200%;
                                        font-size:30px;
                                        display:table-cell; 
                                        vertical-align:middle;"), 
             windowTitle = "MSstatsQC",
             header=tags$head(
               tags$style(HTML('body {padding-top: 150px;}
                                .navbar > .container-fluid {padding-left:5%;}
                                .navbar-nav > li > a, .navbar-brand {
                                  margin:0;
                                  align-items: center;
                                  display: flex;
                                  height: 10vh;}
                                .navbar-default .navbar-nav > .active:after {
                                  position: absolute;
                                  bottom: 0;
                                  left: 0;
                                  width: 100%;
                                  content: " ";
                                  border-bottom: 5px solid #e4e4e4;}
                                .navbar {min-height:25px !important;}
                                .modal-body{ min-height:500px; align:center}'))
             ),
             tabPanel(title= "About", icon = icon("bar-chart-o"), fluidPage(style = "width:80%; align:center",
                                                includeMarkdown("include.md"))),
             tabPanel("Upload",
                      fluidPage(style = "width:80%",
                                sidebarLayout(
                                  sidebarPanel(
                                    h2("Upload Files"),
                                    tags$hr(),
                                    fileInput("file1", h3("Guide Set"),accept = c(".xlsx",
                                                                                  ".csv")),
                                    actionButton("show1", "Show Table"),
                                    fileInput("file3", h3("Test Set")),
                                    fileInput("file3", h3("Annotated Set")),
                                    radioButtons("disp", "Display",
                                                 choices = c(Head = "head",
                                                             All = "all"),
                                                 selected = "all")
                                  ),
                                  mainPanel(
                                    h1("Upload Files Tab"),
                                    p("MSstatsQC-ML is a new tool that makes allows users to employ ML techniques to tackle a variety of", 
                                      strong("QC problems for Mass Spectrometry")),
                                    br(),
                                    p("For an introduction and live example",
                                      a("Old app homepage.", 
                                        href = "https://eralpdogu.shinyapps.io/msstatsqc/")),
                                    br(),
                                    h2("Features"),
                                    
                                  )
                                )
                      )
             ),
             tabPanel("Data import and selection",
                      fluidPage(style = "width:85%",
                                sidebarLayout(
                                  sidebarPanel(
                                    wellPanel(
                                      p("Upload your data (Comma-separated (*.csv) QC file format)"),
                                      
                                      p("To see acceptable example data, look at", strong("Help"),"tab"),
                                      
                                      fileInput("filein", "Upload file")
                                    ),
                                    
                                    wellPanel(
                                      p("If you want to run", strong("MSstatsQC"), "with example data file, click this button"),
                                      actionButton("sample_button", "Run with example data")
                                      
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
          tabPanel("Decision Rule", fluidPage(style="width:80%",                                   
            div(
            bsCollapse(id = "collapseExample", open = "Panel 1",
                       bsCollapsePanel("Panel 1", "This is a panel with just text ",
                                       "and has the default style. You can change the style in ",
                                       "the sidebar.")
            ),
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
          )))
  ),
  fixedPanel(
    actionButton("open", icon("chevron-up")),
    right = 10,
    bottom = 10
  ),
  pushbar(id='bottom',
        fluidPage(
          fluidRow(actionButton("bottom_close", "", icon = icon("times"), class = "btn-danger"), style="padding-bottom:1%;float:right;"))
        ,fluidPage(
          fluidRow(
            column(4,wellPanel(includeMarkdown("mod1.md"))),
            column(4,wellPanel(includeMarkdown("mod2.md"))),
            column(4,wellPanel(includeMarkdown("mod3.md")))
          )),
        from = "bottom",
        style = "height:50%; background-color:white; padding:1%;"
  )
)
