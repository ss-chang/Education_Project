# =====================================================================================
# title: app.R
# author: Shannon Chang
# summary: + 
# =====================================================================================



# =====================================================================================
# Load relevant packages
# =====================================================================================
library(shiny)
library(car)
library(corrplot)
library(Rtsne)
library(caret)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(ggfortify)
library(cluster)
library(ggthemr)



# =====================================================================================
# Load relevant data and set-up data for app
# =====================================================================================
# read in your file, call it "dat"
dat     <- read.csv("../../data/complete-data.csv", row.names = 1)

# data must be numeric for eda
dat_eda <- dat[,-106]
dat_eda <- apply(dat_eda, 2, function(x) as.numeric(x))
dat_eda <- data.frame(dat_eda)

# get data ready for pca
non_zero_var <- as.vector(sapply(dat_eda, function(x) var(x) != 0))
nonzero_columns <- names(dat_eda)[non_zero_var]
cols_to_keep <- names(dat_eda)[names(dat_eda) %in% nonzero_columns]

# perform pca
pca <- prcomp(dat_eda[,cols_to_keep], scale = T)


xgb_10 <- c("PCTPELL", "UGDS", "HSI", "INC_PCT_H1", "REGION", "CCSIZSET", "DEP_INC_PCT_LO", "AVGFACSAL", "NOPELL_RPY_3YR_RT", "PPTUG_EF")


# =====================================================================================
# App architecture
# =====================================================================================

ui <- fluidPage(
  selectInput(inputId = "variable", 
              label = "Select the variable you would like to investigate!", 
              xgb_10),
  mainPanel(
    plotOutput("pcaPlot")
  )
)

server <- function(input, output) {
  selectedColumn <- reactive({
    input$variable
  })
  
  output$pcaPlot <- renderPlot({
    autoplot(pca, data=dat_eda, colour = selectedColumn(), alpha=.6, size=3, pch=4) + 
      ggtitle(paste0("PCA of ", selectedColumn())) +
      theme_wsj() + 
      scale_colour_gradient(limits=c(0, 1), low="goldenrod", high="navyblue", space="Lab") 
  })
}
shinyApp(server = server, ui = ui) 