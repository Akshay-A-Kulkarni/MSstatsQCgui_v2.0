# library(shiny)
# library(shinythemes)
# library(DT)
# library(shinyBS)
# library(waiter)
# library(pushbar)
# library(shinyjs)
# library(shinyWidgets)
# library(plotly)
# 

mod1_ui <-fluidPage(
  navbarPage(id = "inTabset",
    theme = 'cosmo.min.css', position = 'fixed-top',
             title = div(id='Logo', 
                         div(img(src="logo.png", height=50),
                                        p("MSstatsQC - Module 1",style = "font-size:25px;
                                                                          padding-left:20px; 
                                                                          padding-top:5%"),
                                        style= "display:flex"),
                         ), 
             windowTitle = "MSstatsQC - Module 1",
             header=tags$head(
               tags$style(HTML('body { padding-top: 8%; }
                                .navbar > .container-fluid {
                                    padding-left:5%;
                                    padding-right:5%;
                                    box-shadow: 0 6px 2px -2px rgba(0,0,0,.5);
                                    background-color:#1d1d1f;}
                                .navbar .navbar-nav {float: right}
                                .navbar-nav > li > a > .fa { padding-right:30px }
                                .navbar-nav > li > a > b { margin-left:10px }
                                .navbar-nav > li > a, .navbar-brand {
                                  font-size: 1.5rem;
                                  letter-spacing: 1px;
                                  margin:0;
                                  padding-top:auto;
                                  padding-bottom:1%;
                                  align-items: center;
                                  display: flex;
                                  height: 10vh;
                                .navbar-default .navbar-nav > a > .active:after {
                                  position: absolute;
                                  bottom: 0;
                                  left: 0;
                                  width: 100%;
                                  }
                                .navbar {min-height:250px !important;}
                                .modal-body{min-height:70vh !important; align:center}
                                .modal-content, modal-lg {min-width: 80vw;}'))
             ),
             tabPanel(title= "About", value = "panel1",icon = icon("bar-chart-o"), 
                      fluidPage(style= 'font-size: 20px;',
                                fluidRow(column(8,offset = 2,
                                includeMarkdown("www/mod1.md"),
                                actionButton("jumpToP2","Begin")
                                )))),
             
             tabPanel(title = "Data Import & Plotting",value = "panel2", icon = icon("upload"), id='upload_tab',
                      fluidPage(style = "width:95%",
                                fluidRow(
                                  column(6,wellPanel(DT::dataTableOutput("table", height ="60vh"))),
                                  column(6,
                                         fluidPage(
                                           tabsetPanel(id = 'inPlotSet',
                                                  tabPanel(value  = 'pairplottab',title = "Original Plot", plotOutput('pairplot',height='60vh')),
                                                  tabPanel(value = 'pcaplottab',title = "PCA Plot", div(id = "loadpca",plotlyOutput('plot',height='60vh'))),
                                                  tabPanel(value = 'treeplot', title = "Tree Plot", visNetworkOutput("tree",height='60vh')),
                                                  tabPanel(value = 'treeplot', title = "Extracted Rules", DT::dataTableOutput("ruletable", height ="60vh"))
                                                  )
                                              ),
                                         )
                                  ),
                                wellPanel(fluidRow(
                                          column(3,fileInput("anomalyfilein", label= p(strong("Upload Dataset")), accept = c(".csv"))),
                                          column(2,numericInput("lb", div("Starting Col Idx:", style="padding-bottom:6%;"),1, min = 1)),
                                          column(2,numericInput("ub", div("Ending Col Idx:", style="padding-bottom:6%;"), 2,min = 1)),
                                          column(2,numericInput("cf", "Contamination Factor:",min = 0, max = 1,value = 0.05)),
                                          column(3,div(style="padding-top:6%;",
                                                       actionGroupButtons(
                                                          c("go", "clear_button"),
                                                          c("Plot!", "Clear Data"),
                                                          status = "default",
                                                          size = "normal",
                                                          direction = "horizontal",
                                                          fullwidth = TRUE
                                          )))
                                        ))
                                )
                                
                      )
             )
)

