### Importing UI components
hr_line <- HTML('<hr style ="border-color:black; font-size:5rem;">')
divider <- function(icon_str){ 
  fluidRow(column(4,offset = 1,hr_line),column(2, style="padding: 0%; margin:0%; font-size:2rem;", align="center",icon(icon_str)),column(4,hr_line))}
source("src/components/input_section_ui.R")
source("src/components/about_page_ui.R")
source("src/components/plotresults_ui.R")
source("src/components/methods_ui.R")





mod2_ui <-  fluidPage(style='padding-top: 6%', bsplus::use_bs_accordion_sidebar(), 
                      navbarPage(theme = 'cosmo.min.css',position = 'fixed-top',
                                 title = div(id='Logo', div(img(src="logo.png", height=50, width=50),"MSstatsQC")),
                                 windowTitle = "MSstatsQC",
                                 header=tags$head(tags$style(HTML(module2css))),#### module 2 css from about_page.r ###
                                 
                           tabPanel(title= "About", icon = icon("bar-chart-o"),
                                   
                                      ########## About page ui component #########
                                      about_page_ui
                                      ############################################
                                    
                                      ), 

                           tabPanel(title = "Tool",icon = icon("upload"), id='tool_tab',
                                      br(),br(),
                                      divider("cog"),
                                      fluidRow(column(offset=1,10,h3("Data Import & Metric Rules"))),
                                      ########## Input File and Metrics ui Component #######
                                      input_section_ui,
                                      ######################################################
                                      
                                      br(),br(),
                                      divider("user-cog"),
                                      ########## Input File and Metrics ui Component #######
                                      methods_ui,
                                      ######################################################
                                      
                                      br(),br(),
                                      divider("chart-bar"),
                                      ########## Heatmaps and summary ui Component #########
                                      plotresults_ui 
                                      ######################################################
                                    
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
