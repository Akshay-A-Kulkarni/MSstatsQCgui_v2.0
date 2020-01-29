ui <-fluidPage(style='padding:0%; margin:0%',
  list(
    tags$head(
      HTML('<link rel="icon" href="logo.png" 
                type="image/png" />'))),
  navbarPage(theme = shinytheme('cosmo'),
             title = div(img(src="logo.png",height=75,width=75),
                 "MSstatsQC-ML",style="width:200%;
                                        font-size:30px;
                                        display:table-cell; 
                                        vertical-align:middle;"), 
             windowTitle = "MSstatsQC",
             header=tags$head(
               tags$style(HTML('.navbar-nav > li > a, .navbar-brand {
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
             tabPanel(title= "About", fluidPage(style = "width:80%; align:center",
                                                includeMarkdown("include.md"))),
             tabPanel("Upload",
                      fluidPage(style = "width:85%",
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
                      tabsetPanel(
                        tabPanel("Data import",
                                 sidebarLayout(
                                   
                                   sidebarPanel(
                                     wellPanel(
                                       p("Upload your data (Comma-separated (*.csv) QC file format)"),
                                       
                                       p("To see acceptable example data, look at", strong("Help"),"tab"),
                                       #p("If your data contains min start time and max end time, the app will add a peak assymetry column automatically."),
                                       
                                       fileInput("filein", "Upload file")
                                     ),
                                     
                                     wellPanel(
                                       p("If you want to run", strong("MSstatsQC"), "with example data file, click this button"),
                                       actionButton("sample_button", "Run with example data")
                                       #bsTooltip("sample_button","If you want to run MSstatsQC with example data file, click this button", placement = "bottom", trigger = "hover",
                                       #options = NULL)
                                     ),
                                     
                                     wellPanel(
                                       p("If you want to clean existing results, click this button"),
                                       
                                       actionButton("clear_button", "Clear data and plots")
                                       
                                       #bsTooltip("clear_button","click this button to clear your data and all the tables and plots from the system.", placement = "bottom", trigger = "hover",
                                       #options = NULL)
                                     ),
                                     
                                   ),
                                   mainPanel(
                                     
                                     tabPanel("Data",
                                              dataTableOutput('prodata_table'))
                                   ),
                                   position = "left")
                        ),
                        
                        tabPanel("Options",
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
                                 )
                        )
                      )
             )
          )
  )
)
