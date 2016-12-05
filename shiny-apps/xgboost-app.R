# =======================================================================================
# shiny app
#
# you select 
#
# sliderInput("PCTPELL", "PCTPELL",
#             min = min(app_df$PCTPELL), 
#             max = max(app_df$PCTPELL), 
#             value = median(app_df$PCTPELL)
# ),
# sliderInput("UGDS", "UGDS",
#             min = min(app_df$UGDS), 
#             max = max(app_df$UGDS), 
#             value = median(app_df$UGDS)
# ),
# 
# sliderInput("HSI", "HSI",
#             min = min(app_df$HSI), 
#             max = max(app_df$HSI), 
#             value = median(app_df$HSI)
# ),
# 
# sliderInput("INC_PCT_H1", "INC_PCT_H1",
#             min = min(app_df$INC_PCT_H1), 
#             max = max(app_df$INC_PCT_H1), 
#             value = median(app_df$INC_PCT_H1)
# ),
# 
# sliderInput("REGION", "REGION",
#             min = min(app_df$REGION), 
#             max = max(app_df$REGION), 
#             value = median(app_df$REGION)
# ),
# 
#
# =======================================================================================

# =======================================================================================
# Setup
# =======================================================================================

setwd("C:/Users/Nura/Desktop/Education_Project/code/scripts/")
library(shiny)

# =======================================================================================
# Source our script
# =======================================================================================

#source("final-xgboost-script.R")

# =======================================================================================
# Select Data to Use
# =======================================================================================
dat     <- read.csv("../../data/complete-data.csv", row.names = 1)
df2 <- dat
df2$MINORITIES <- NULL     # This is essentially our response = overfit
df2$MINORITIES.1 <- NULL   # This is essentially our response = overfit
df2$INSTNM <- NULL         # Don't need
# Make data numeric
df2 <- as.data.frame(apply(df2, 2, as.numeric))

load("top_ten.RData")
load("xgb_model.RData")

# The below code will be replace with the widget input information for each column in 
# top ten
test2 <- df2[sample(3281,2000),c(top_ten,"ABOVE_MEDIAN_MINORITIES")]
test_labels <- test2$ABOVE_MEDIAN_MINORITIES
test2 <- test2[-grep('ABOVE_MEDIAN_MINORITIES', colnames(test2))]
test.matrix <- as.matrix(test2)


#app_df <- as.data.frame(test.matrix)

# =======================================================================================
# Running xtraboost
# =======================================================================================







# =======================================================================================
# App
# =======================================================================================
  


ui <- pageWithSidebar(
  
  
  headerPanel('THIS IS OUR SHINY APP'),
  
  sidebarPanel(
    sliderInput("CCSIZSET", "CCSIZSET",
                min = min(app_df$CCSIZSET), 
                max = max(app_df$CCSIZSET), 
                value = median(app_df$CCSIZSET)
    ),
    
    sliderInput("DEP_INC_PCT_LO", "DEP_INC_PCT_LO",
                min = min(app_df$DEP_INC_PCT_LO), 
                max = max(app_df$DEP_INC_PCT_LO), 
                value = median(app_df$DEP_INC_PCT_LO)
    ),
    
    sliderInput("AVGFACSAL", "AVGFACSAL",
                min = min(app_df$AVGFACSAL), 
                max = max(app_df$AVGFACSAL), 
                value = median(app_df$AVGFACSAL)
    ),
    
    
    sliderInput("NOPELL_RPY_3YR_RT", "NOPELL_RPY_3YR_RT",
                min = min(app_df$NOPELL_RPY_3YR_RT), 
                max = max(app_df$NOPELL_RPY_3YR_RT), 
                value = median(app_df$NOPELL_RPY_3YR_RT)
    ),
    
    sliderInput("PPTUG_EF", "PPTUG_EF",
                min = min(app_df$PPTUG_EF), 
                max = max(app_df$PPTUG_EF), 
                value = median(app_df$PPTUG_EF)
    ),

    mainPanel(plotOutput("plot"))
)
)

  
# Server logic
server <- function(input, output) {
    
    selectedData <- reactive({  
      data.frame(
        # PCTPELL           = input$PCTPELL,     # range 0 1
        # UGDS              = input$UGDS, # range: 0 151558
        # HSI               = input$HSI,     # range: 0 1
        # INC_PCT_H1        = input$INC_PCT_H1,    # range 0.0 0.297
        # REGION            = input$REGION,     # range 0 9
        # CCSIZSET          = input$CCSIZSET,     # range: -2, 18
        DEP_INC_PCT_LO    = input$DEP_INC_PCT_LO,    # range: 0.0 0.92
        AVGFACSAL         = input$AVGFACSAL, # range: 0 25143
        NOPELL_RPY_3YR_RT = input$NOPELL_RPY_3YR_RT,  # range: 0.0  0.99
        PPTUG_EF          = input$PPTUG_EF      # range: 0 1
      )
    })
    
    
    
    output$plot <- renderPlot({
      boxplot(selectedData())
    })
    
  }
  
  
# Complete app with UI and server components
shinyApp(ui, server)


