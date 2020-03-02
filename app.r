library(shiny)
library(shiny.router)
library(shinythemes)
library(DT)
library(shinyBS)
library(shinyjs)
library(shinyWidgets)
library(waiter)
library(pushbar)
library(bsplus)
library(htmltools)
#####################################
library(plotly)
library(RecordLinkage)
library(MSstatsQC)
library(MSstatsQCgui)
library(dplyr)
library(ggExtra)
library(gridExtra)
library(grid)
library(fresh)
library(tippy)
library(tidyr)



if (!"package:MSstatsQCgui" %in% search())
  import_fs("MSstatsQCgui", incl = c("shiny","shinyBS","dplyr","plotly","RecordLinkage","ggExtra","gridExtra","grid"))

# ARCHIVED RECORD LINKAGE PACKAGE.
# RecordLinkageURL <- "https://cran.r-project.org/src/contrib/Archive/RecordLinkage/RecordLinkage_0.4-11.tar.gz"
# install.packages(RecordLinkageURL, repos=NULL, type="source")




# Sourcing all modules pages to the main routing app.
source("src/module1-ui.R")
source("src/module1-server.R")
source("src/module2-ui.R")
source("src/module2-server.R")
source("src/module3-ui.R")
source("src/module3-server.R")


cardCSS <- "box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
            border-radius: 0.5rem;
            box-shadow: 7px 7px 30px -5px rgba(0,0,0,0.1);
            position: relative;
            height: 50%;"



# Main Home Page cards

mod1p <- div(h4(strong("One Time QC")),br(),
             fluidRow(
               column(5,img(src='mod1.png',width="100%")),
               column(7,p("Allows the user to upload data of one time runs to assess optimality w.r.t the guide set "),br(),
                      fluidRow(column(3, offset = 0,actionButton("switch_mod1", "Launch One-Time Tool"))),br(),
                      fluidRow(column(2, offset = 0,actionButton("help_mod1", "Help"))))
             ),
)
mod2p <- div(h4(strong("Longitudinal QC")),br(),
             fluidRow(
               column(5,img(src='mod2.png',width="100%")),
               column(7,p("Allows the user to upload data of one or more peptide to assess optimality w.r.t the guide set for multiple runs"),br(),
                      fluidRow(column(3, offset = 0,actionButton("switch_mod2", "Launch Longitudinal Tool"))),br(),
                      fluidRow(column(2, offset = 0,actionButton("help_mod2", "Help")))
               )
             ),
)

mod3p <- div(h4(strong("Complex QC")),br(),
             fluidRow(column(5,img(src='mod3.png',width="100%")),
                      column(7,p("Allows the user to upload data of complex runs to assess optimality (Requires Test DataSet)"),br(),
                             fluidRow(column(3, offset = 0,actionButton("switch_mod3", "Launch Complex Tool"))), br(),
                             fluidRow(column(2, offset = 0, actionButton("help_mod3", "Help")))
                      ),
             )
)




# Part of both pages.
home_page <- fluidPage(style="padding:0%; margin:0%",
                        tags$head(
                          tags$style(HTML("@import url('https://fonts.googleapis.com/css?family=Open+Sans:300,400,700');"),
                                     HTML("padding-top:0;"))),
                       # NAVBAR
                        fluidRow(style="font-family:Open Sans;
                                        position: fixed;
                                        width: 100%;
                                        height: 8%;
                                        box-shadow: 0 6px 2px -2px rgba(0,0,0,.1);
                                        background-color:#FFF;
                                        z-index:1000;" ,
                                 fluidPage(style="width:80%;font-family:Open Sans;",
                                           column(6,div(style="padding-top:1.5%; display:flex",img(src="logo.png", width="50vh"),div(style="padding-left:2%",h3(("MSstats"),style='color:DarkBlue; font-weight:500;')))),
                                           column(6,align='right',
                                            div(style="padding-top:3.5%; display:inline-block",
                                            actionBttn(
                                             inputId = "temporary1",
                                             label = a("Help", href="https://google.com", target="_blank") , 
                                             style = "bordered",
                                             color = "success"),
                                            actionBttn(
                                              inputId = "temporary2",
                                              label = a("MSstats", href="http://msstats.org/", target="_blank") , 
                                              style = "bordered",
                                              color = "success")))
                                           )),
                       # Main Body
               fluidPage(style = "width:80%; padding-top:8%;font-family:Open Sans;",

                       fluidRow(column(7,div(style="padding-top:15%;", h1(strong('MSstatsQC'), align="right", style='font-size:5rem;'),h4('Longitudinal system suitability monitoring and quality control for proteomic experiments',align="right"))),
                                column(5, align='center',img(src='heat2.png', width="400vh"))
                                ),
                       fluidRow( br(),br(),br(),br(),
                         fluidRow(
                           column(4,wellPanel(style=cardCSS, mod1p,br(),br())),
                           column(4,wellPanel(style=cardCSS, mod2p,br(),br())),
                           column(4,wellPanel(style=cardCSS, mod3p)),                        
                         ),
                         column(10,offset=1, h3("About"),includeMarkdown("www/include.md"))),
                       br(),br(),
)
)


# Callbacks on the server side for the sample pages
home_server <- function(input, output, session) {
  
  observeEvent(input$switch_mod2, {
    if (!is_page("module2")) {
      change_page("module2")}
  })
  
  observeEvent(input$help_mod2, {
    showModal(modalDialog(
      title = "Uploaded Data",
      size = "l",
      includeMarkdown("www/mod2.md"),
      easyClose = TRUE
    ))
  })
}

# Create routing. We provide routing path, a UI as well as a server-side callback for each page.
router <- shiny.router::make_router(
  shiny.router::route("/", home_page, home_server),
  shiny.router::route("module2", mod2_ui, mod2_server)
)

# Create output for our router in main UI of Shiny app.
ui <- fluidPage(
  waiter::use_waiter(),
  pushbar::pushbar_deps(),
  shinyjs::useShinyjs(),
  shiny.router::router_ui()
)

# Plug router into Shiny server.
server <- function(input, output, session) {
  router(input, output, session)
  
  # loading_screen <- tagList(
  #   h3("Initializing MSstatsQC", style = "color:white;"),
  #   br(),
  #   waiter::spin_flower(),
  #   div(style='padding:15vh') 
  # )
  
  # loadScreen <- Waiter$new(html = loading_screen, color='#242424')
  #
  #
  # loadScreen$show()
  #
  # Sys.sleep(2)
  #
  # loadScreen$update(html = tagList(img(src="logo.png", height=150),div(style='padding:15vh')))
  #
  # Sys.sleep(1)
  #
  # loadScreen$hide()
}

# Run server in a standard way.
shinyApp(ui=ui, server=server)