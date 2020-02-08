library(cicerone)

guide <- Cicerone$
  new()$ 
  step(
    el = "Logo",
    title = "Welcome to MSstatsQC",
    description = "This is a guided tour of the app to help you navigate the workflow for MSstatsQC"
  )$
  step(
    "openModulesPane",
    "Modules Pane",
    "Click this button to open the modules pane and switch to a different mode of the MSstatsQC tool anytime"
  )