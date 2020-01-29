

server <- function(input, output) {
  
  output$table <- DT::renderDataTable(DT::datatable({
    
    req(input$file1)
    data <- read.csv(input$file1$datapath)
    if (input$disp == "head") {
      data <- head(data)
    }
    data
  }
  ,fillContainer = T
  ,options = list(lengthMenu = c(10, 50, 100), pageLength = 10, scroller = list(rowHeight = 100))
  )
  )
  
  observeEvent(input$show1, {
    showModal(modalDialog(
      title = "Uploaded file",
      size = "l",
      DT::dataTableOutput("table", height = "500px"),
      easyClose = TRUE
    ))
  })
  
  ############################ MS-stats  ###########################
  
}


