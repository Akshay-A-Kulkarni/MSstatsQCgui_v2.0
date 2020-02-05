

# Run the app ----
shinyApp(ui = ui, server = server)
# runApp(appDir = getwd(), port = 8888,
#        launch.browser = TRUE,
#        host = getOption("shiny.host", "127.0.0.1"), workerId = "",
#        quiet = FALSE, display.mode = c("auto", "normal", "showcase"),
#        test.mode = getOption("shiny.testmode", FALSE))
