library(shiny)
library(shiny.router)
library(shinythemes)
library(DT)
library(shinyBS)
library(waiter)
library(pushbar)
library(tablerDash)
library(shinyjs)
library(shinyWidgets)
library(plotly)

source(ui.R)
source(server.R)



# Part of both pages.
home_page <- fluidPage( h1("Home Page"),
                        fluidRow(
                          column(4,wellPanel(includeMarkdown("www/mod1.md"))),
                          column(4,wellPanel(includeMarkdown("www/mod2.md"))),
                          column(4,wellPanel(includeMarkdown("www/mod3.md")))
                        )
)

module2_page <- mod2_ui


# Callbacks on the server side for the sample pages
home_server <- function(input, output, session) {

}

mod2_server <- mod2_server

# Create routing. We provide routing path, a UI as well as a server-side callback for each page.
router <- make_router(
  route("home", home_page, home_server),
  route("side", module2_page, mod2_server)
)

# Create output for our router in main UI of Shiny app.
ui <- shinyUI(fluidPage(
  router_ui()
))

# Plug router into Shiny server.
server <- shinyServer(function(input, output, session) {
  router(input, output, session)
})

# Run server in a standard way.
shinyApp(ui, server)
