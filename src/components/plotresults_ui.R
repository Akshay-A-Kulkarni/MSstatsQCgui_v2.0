plotresults_ui <- fluidRow(column(offset=1,10,
  # fluidRow(h3("Plots & Results")),
  tabsetPanel(type = 'pill',
              # tabPanel("Descriptives : boxplots for metrics",
              #          tags$head(tags$style(type="text/css")),
              #          br(),
              #          conditionalPanel(condition="$('html').hasClass('shiny-busy')",
              #                           tags$div("It may take a while to load the plots, please wait...",
              #                                    id="loadmessage")),
              #          # fluidPage(style="width:90%",uiOutput("box_plotly"), plotlyOutput("box_plot"))
              # ),
              tabPanel("Overall performance : decision maps",
                       tags$head(tags$style(type="text/css")),
                       br(),
                       conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                        tags$div("It may take a while to load the plots, please wait...",
                                                 id="loadmessage")),
                       sidebarLayout(
                         sidebarPanel(
                           checkboxGroupInput("heatmap_controlChart_select", "Select your control chart",
                                              choices = c("CUSUM charts" = "CUSUM","XmR chart" = "XmR"), selected = "XmR")
                         ),
                         mainPanel(plotOutput("heat_map"))
                       )
              ),
              tabPanel("Detailed performance: plot summaries",
                       tags$head(tags$style(type="text/css")),
                       conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                        tags$div("It may take a while to load the plots, please wait...",
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
              )
  )
)
)