methods_ui <-  fluidRow(
  column(10,offset=1,
         # h3("Descriptive Plots and Method Selection"),
         fluidRow(
           column(3,
                  wellPanel(
                    awesomeRadio( inputId = "box_plot_switch",
                                  label = "Layout", 
                                  choices = c("Per-Peptide", "Per-Metric"),
                                  selected = "Per-Peptide",
                                  status = "success"),
                    
                    actionButton(inputId ="desc_modal",label = "Descriptives : Show Boxplots")
                    )
                  ),
           column(9,
                  column(4,
                         wellPanel(p(strong("Method Selection")),
                            prettyRadioButtons(
                              inputId = "method_selection",
                              label = p("Choose a Method:"), 
                              choices = c("MSstatsQC-SPC", "MSstatsQC-ML"),
                              icon = icon("check"), 
                              bigger = TRUE,
                              status = "success",
                              animation = "jelly")
                            )
                         
                         ),
                  column(4,
                         fluidRow(
                           wellPanel(
                                conditionalPanel(
                                  condition = "input.method_selection == 'MSstatsQC-SPC'",
                                  p('SPC Method does not require any further settings')
                                ),
                                conditionalPanel(
                                  condition = "input.method_selection == 'MSstatsQC-ML'",
                                  prettySwitch(
                                    inputId = "use_sim_button",
                                    label = "Generate Extra Obs", 
                                    status = "success",
                                    fill = TRUE
                                  )
                                  ) ,         
                         conditionalPanel(
                           condition = "input.use_sim_button && input.method_selection == 'MSstatsQC-ML'",
                           span('Using Simulation to generate more failing runs'),
                           numericInput(label = "Simuation size", inputId="sim_size", value = 100)
                         ),
                         conditionalPanel(
                           condition = "input.method_selection == 'MSstatsQC-ML' && !input.use_sim_button",
                           span('Upload a data set with labeled failing runs for Model training.'),
                           fileInput("anno_in", label= strong("Annotated Data"), accept = c(".csv"), placeholder = "Upload labeled failing runs")
                         ),
                     )
                  )
                 ),
                 column(4,
                        wellPanel(
                          p("Configure Previous Settings and Press the button below to generate results !"),
                        #   prettySwitch(
                        #     inputId = "use_anno_button",
                        #     label = "Use user annotations", 
                        #     status = "success",
                        #     fill = TRUE
                        #   ),
                          br(),
                          actionButton(inputId ="run_method", label = "Generate Plots")
                        )
                   
                 )
                 
             ) 
         )
  )
)
