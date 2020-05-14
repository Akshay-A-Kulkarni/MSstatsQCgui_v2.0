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
                         wellPanel( h4("SPC | ML"),
                            prettyRadioButtons(
                              inputId = "method_selection",
                              label = "Choose a Method:", 
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
                                    inputId = "sim_button",
                                    label = "Simulate Obs", 
                                    status = "success",
                                    fill = TRUE
                                  )
                                  ) ,         
                         conditionalPanel(
                           condition = "input.sim_button",
                           p('Using Simulation to generate out of control obs'),
                           numericInput(label = "Simuation size",inputId="sim_size", value = 100)
                         )
                     )
                  )
                 ),
                 column(4,
                        wellPanel(
                          p("Configure Setting and Press the button below to generate results"),
                          actionButton(inputId ="run_method", label = "Generate Plots !")
                        
                        )
                   
                 )
                 
             ) 
         )
  )
)
