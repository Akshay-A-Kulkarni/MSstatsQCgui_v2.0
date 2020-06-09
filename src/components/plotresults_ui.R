plotresults_ui <- fluidRow(style="height:50vh;",column(offset=1,10,
  # fluidRow(h3("Plots & Results")),
  conditionalPanel(condition = "input.run_method != 0",
  tabsetPanel(type = 'pill', id='module2-results',
              tabPanel(title = "Overall performance : SPC decision maps",value = 'spc1',
                       tags$head(tags$style(type="text/css")),
                       br(),
                       conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                        tags$div(style="display: flex;justify-content: center;align-items: center",
                                                 "It may take a while to load the plots, please wait...",
                                                 id="loadmessage")),
                       sidebarLayout(
                         sidebarPanel(
                           checkboxGroupInput("heatmap_controlChart_select", "Select your control chart",
                                              choices = c("CUSUM charts" = "CUSUM","XmR chart" = "XmR"), selected = "XmR")
                         ),
                         mainPanel(plotOutput("heat_map"))
                       )
              ),
              tabPanel(title = "Detailed performance: plot summaries",value = 'spc2',
                       tags$head(tags$style(type="text/css")),
                       conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                        tags$div(style="display: flex;justify-content: center;align-items: center",
                                                 "It may take a while to load the plots, please wait...",
                                                 id="loadmessage")),
                       fluidPage(
                         fluidRow(
                           br(),
                           column(2,
                                  wellPanel(
                                    prettyCheckboxGroup(
                                      'summary_controlChart_select',
                                      'Select your control chart',
                                      choices = c("CUSUM charts" = "CUSUM","XmR chart" = "XmR"),
                                      selected = "XmR",
                                      shape = "square",
                                      thick = TRUE,
                                      animation = "jelly",
                                      icon = icon("check"),
                                      bigger = TRUE,),
                                  )
                           ),
                           column(10,plotOutput("plot_summary"))
                         )
                       ),
              ),
              tabPanel(title = "Overall performance : ML decision maps",value = 'ml1',
                       tags$head(tags$style(type="text/css")),
                       br(),
                       conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                        tags$div(style="display: flex;justify-content: center;align-items: center",
                                                 "It may take a while to load the plots, please wait...",
                                                 id="loadmessage")),
                       fluidPage(uiOutput("ml_heat_map"))
              )
  )
)
)
)