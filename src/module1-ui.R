## Importing UI components
hr_line <- HTML('<hr style ="border-color:black; font-size:5rem;">')
divider <- function(title_str,icon_str,off_x){
  width <- ((10-2*off_x)*0.5)
  fluidRow(column(width,offset = off_x,hr_line),column(2,style="margin:0%;padding: 0% display:block;",align="center",icon(icon_str),h4(title_str)),column(width,hr_line))
}
source("src/components/common_css.R")


mod1_ui <-fluidPage(style='padding-top: 8%;',
  navbarPage(id = "inTabset",
    theme = 'cosmo.min.css', position = 'fixed-top',
             title = div(id='Logo',div(p("MSstatsQC - Module 1",style = "font-size:3rem;padding-left:1.5rem;padding-top:5%"),
                                        style= "display:flex")), 
             windowTitle = "MSstatsQC - Module1",
             header=tags$head(tags$style(HTML(modulecss))),#### module 1 css from common_css.r ###
    
             tabPanel(title= "About", value = "panel1",icon = icon("bar-chart-o"), 
                      fluidPage(style= 'font-size: 18px;',
                                fluidRow(column(8,offset = 2,
                                includeMarkdown("www/mod1.md"),
                                actionButton("jumpToP2","Begin")
                                )))),
             
             tabPanel(title = "Tool",value = "panel2", icon = icon("upload"), id='upload_tab',
                      fluidPage(style = "width:90%",
                                divider("Input and Parameter settings","user-cog",0),
                                br(),br(),
                                wellPanel(fluidRow(
                                  column(3,fileInput("anomalyfilein", label= p(strong("Upload Dataset")), accept = c(".csv"))),
                                  column(2,numericInput("lb", div("Starting Col Idx:", style="padding-bottom:6%;"),1, min = 1)),
                                  column(2,numericInput("ub", div("Ending Col Idx:", style="padding-bottom:6%;"), 2,min = 1)),
                                  column(3,numericInput("cf", "Contamination Factor:",min = 0, max = 1,value = 0.05)),
                                  column(2,div(
                                    actionGroupButtons(
                                      c("go", "clear_button", "report"),
                                      c("Plot!", "Clear Data", "Generate report"),
                                      status = "default",
                                      size = "normal",
                                      direction = "vertical",
                                    )))
                                )),   
                                br(),br(),br(),br(),
                                divider("DataTable and Results","chart-bar",0), ### custom section header fucn from app.r
                                br(),br(),
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
                                br(),br(),br(),br(),br(),
                                wellPanel(fluidPage(
                                  column(2,wellPanel(strong("Current Maintainers:"),
                                                     p("1. Akshay Kulkarni",br(),"2. Eralp Dogu"))),
                                  
                                  column(6,wellPanel(strong("Contact"),
                                                     p("For Bugs,comments or suggestions, please go to our",tags$a(href="https://github.com/Akshay-A-Kulkarni/MSstatsQCgui_v2.0", "GithHub"), " repo.",br()))),
                                  
                                  column(4,
                                    wellPanel(strong("MSstatsQCgui"),br(),
                                              p("MSstatsQC 1.2.0 (Bioconductor version : Release 3.7"))),
                                ))
                                ),
                                
                      )
             ),
  fixedPanel(
    actionButton("switch_home", icon("home")),
    left = 15,
    bottom = 15
  ),
)

