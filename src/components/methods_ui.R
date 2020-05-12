methods_ui <-  fluidRow(
  column(10,offset=1,
         h3("Descriptive Plots and Method Selection"),
         fluidRow(
           column(6,
                  wellPanel(
                    awesomeRadio( inputId = "box_plot_switch",
                                  label = "Layout", 
                                  choices = c("Per-Peptide", "Per-Metric"),
                                  selected = "Per-Peptide",
                                  inline = TRUE, 
                                  status = "success"),
                    
                    actionButton(inputId ="desc_modal",label = "Descriptives : Show Boxplots")
                    )
                  ),
           column(6,wellPanel( h4("SPC or ML"),
                               p("Input control 1"),
                               p("Input control 2 ...")
                               
                               
                               ) 
                  )
         )
        )
)