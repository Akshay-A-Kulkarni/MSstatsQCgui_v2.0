
library(shiny)
library(tablerDash)
library(shinyWidgets)


profileCard <- tablerProfileCard(
  width = 12,
  title = "Peter Richards",
  subtitle = "Big belly rude boy, million
        dollar hustler. Unemployed.",
  background = "https://preview.tabler.io/demo/photos/ilnur-kalimullin-218996-500.jpg",
  src = "https://preview.tabler.io/demo/faces/male/16.jpg",
  tablerSocialLinks(
    tablerSocialLink(
      name = "facebook",
      href = "https://www.facebook.com",
      icon = "facebook"
    ),
    tablerSocialLink(
      name = "twitter",
      href = "https://www.twitter.com",
      icon = "twitter"
    )
  )
)




mod2Card <- tablerCard(
  title = "Module 2",
  zoomable = TRUE,
  closable = FALSE,
  width = 10,
  div(fluidRow(column(8,p("Allows the user to upload data of one time runs to assess optimality w.r.t the guide set")),
               column(4,includeMarkdown('www/mod1.md')))),
  options = tagList(
    actionBttn(
      inputId = "mod2_help",
      label = "Help",
      style = "float", 
      color = "success"
    )
  ),
  footer = tagList(
    column(12,
      align = "center",
      actionBttn(
        inputId = "switch_mod2",
        label = "Launch Logitudinal Tool",
        style = "fill",
        color = "black"
      )
    )
  )
)


# app
shiny::shinyApp(
  ui = fluidPage(
    useTablerDash(),
    h1("Import tablerDash elements inside shiny!", align = "center"),
    h5("Don't need any sidebar, navbar, ...", align = "center"),
    h5("Only focus on basic elements for a pure interface", align = "center"),
    
    fluidRow(
      column(
        width = 3,
        profileCard,
        tablerStatCard(
          value = 43,
          title = "Followers",
          trend = -10,
          width = 12
        )
      ),
      column(
        width = 6,
        mod2Card
      ),
      column(
        width = 3,
        tablerCard(
          width = 12,
          tablerTimeline(
            tablerTimelineItem(
              title = "Item 1",
              status = "green",
              date = "now"
            ),
            tablerTimelineItem(
              title = "Item 2",
              status = NULL,
              date = "yesterday",
              "Lorem ipsum dolor sit amet,
                  consectetur adipisicing elit."
            )
          )
        )
      )
    )
  ),
  server = function(input, output) { 
    
  }
)

