about_page_ui <- fluidPage(fluidRow(column(8,offset=2,style = "width:80%; align:center;",
                                                              includeMarkdown("www/mod2.md"),
                                                              h3("How-To:"),
                                                              br(),
                                                              h4(strong("- Uploading files")),
                                                              br(),
                                                              img(src="upload.gif", width="80%" , align= "center"),
                                                              br(),
                                                              br(),
                                                              br(), 
                                                              h4(strong("- Selecting Metrics")),
                                                              br(),
                                                              img(src="metrics.gif", width="80%" , align= "center")
                                           )),
                           
                           # Footer
                           ######################################################
                           br(),br(),br(),br(),br(),
                           wellPanel(fluidPage(
                             column(2,wellPanel(strong("Current Maintainers:"),
                                                p("1. Akshay Kulkarni",br(),"2. Eralp Dogu"))),
                             
                             column(6,wellPanel(strong("Contact"),
                                                p("For Bugs,comments or suggestions, please go to our",tags$a(href="https://github.com/Akshay-A-Kulkarni/MSstatsQCgui_v2.0", "GithHub"), " repo.",br()))),
                             
                             column(4,
                                    wellPanel(strong("MSstatsQCgui"),br(),
                                              p("MSstatsQC 1.2.0 (Bioconductor version : Release 3.7"))),
                           )))