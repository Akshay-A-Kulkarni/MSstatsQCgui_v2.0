### Importing UI components
hr_line <- HTML('<hr style ="border-color:black; font-size:5rem;">')
divider <- function(title_str,icon_str,off_x){
  width <- ((10-2*off_x)*0.5)
  fluidRow(column(width,offset = off_x,hr_line),column(2,style="margin:0%;padding: 0% display:block;",align="center",icon(icon_str),h4(title_str)),column(width,hr_line))
}

source("src/components/input_section_ui.R")
source("src/components/about_page_ui.R")
source("src/components/plotresults_ui.R")
source("src/components/methods_ui.R")
source("src/components/common_css.R")
source("src/components/footer.R")


mod2_ui <-  fluidPage(style='padding-top: 6%', bsplus::use_bs_accordion_sidebar(), 
                      navbarPage(theme = 'cosmo.min.css',position = 'fixed-top',
                                 title = div(id='Logo', "MSstatsQC-Module 2"),
                                 windowTitle = "MSstatsQC-Module2",
                                 header=tags$head(tags$style(HTML(modulecss))),#### module 2 css from common_css.r ###
                                 
                           tabPanel(title= "About", icon = icon("bar-chart-o"),
                                   
                                      ########## About page ui component #########
                                      about_page_ui
                                      ############################################
                                    
                                      ), 

                           tabPanel(title = "Tool",icon = icon("upload"), id='tool_tab',
                                      br(),br(),
                                      divider("Data Import & Metric Rules","cog",1),
                                      # fluidRow(column(offset=1,10,h3("Data Import & Metric Rules"))),
                                      ########## Input File and Metrics ui Component #######
                                      input_section_ui,
                                      ######################################################
                                      
                                      br(),br(),
                                      divider("Descriptive Plots and Method Selection","user-cog",1),
                                      ########## Input File and Metrics ui Component #######
                                      methods_ui,
                                      ######################################################
                                      
                                      br(),br(),
                                      divider("Plots & Results","chart-bar",1),
                                      ########## Heatmaps and summary ui Component #########
                                    
                                      plotresults_ui,
                                    
                                      ######################################################
                                      br(),br(),
                                      divider("Report","file",1),
                                    
                                      # Report
                                      fluidRow(
                                        column(10, offset=1,
                                               fluidRow(
                                                 div(
                                                   h4(strong("Add any comments/descriptions for plots to be included in the report in the respective text boxes.")),
                                                   column(4,textAreaInput("input_data_desc", "Data/Table Comments", rows = 2,cols = 4, placeholder = 'Add comments here')),
                                                   column(4,textAreaInput("boxplot_desc", "BoxPlot Comments", rows = 2,cols = 4, placeholder = 'Add comments here')),
                                                   column(4,textAreaInput("HeatMap", "SPC/ML Heatmap Comments", rows = 2,cols = 4, placeholder = 'Add comments here')),
                                                   downloadButton("mod2report", "Generate report")
                                                 )
                                               )
                                        )
                                      ),
                                      br(),br(),
                                      # Footer
                                      ######################################################
                                      footer
   
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
