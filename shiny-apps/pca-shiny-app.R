# =====================================================================================
# title: pca-app.R
# author: Shannon Chang
# summary: + This app will produce pca plots from a sample of fifty schools within 
#            our main dataset and color code the plots by a specified variable.
#          + A user can select the variable from a drop-down menu, which lists the top 
#            ten variables of importance that we identified through our XGBOOST model.
#          + The sidebar panel also contains a glossary that explains to the user what 
#            each variable means. 
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
dat                   <- read.csv("../data/complete-data.csv", row.names = 1)
dat                   <- dat[-which(duplicated(dat$INSTNM)), ]
rownames(dat)         <- dat$INSTNM
random_sample_smaller <- sample(1:nrow(dat), 50, replace = FALSE)
dat                   <- dat[random_sample_smaller,]

# data must be numeric for eda
dat_eda <- dat[,-106]
dat_eda <- apply(dat_eda, 2, function(x) as.numeric(x))
dat_eda <- data.frame(dat_eda)
row.names(dat_eda) <- row.names(dat)

# get data ready for pca
non_zero_var <- as.vector(sapply(dat_eda, function(x) var(x) != 0))
nonzero_columns <- names(dat_eda)[non_zero_var]
cols_to_keep <- names(dat_eda)[names(dat_eda) %in% nonzero_columns]

# perform pca
pca <- prcomp(dat_eda[,cols_to_keep], scale = T)

load("../data/top_ten.RData")



# =====================================================================================
# App architecture
# =====================================================================================

ui <- fluidPage(
  titlePanel("PCA Plots for Top 10 XGBOOST-Selected Variables"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId = "variable", 
                  label = "Select a top-10 variable that you would like to investigate!", 
                  top_ten),
      h3("Variable Glossary"),
      p(span("INC_PCT_H1", style = "color:blue"),
        "is the share of students with family incomes between $75,001-$110,000 in nominal dollars."),
      p(span("PCTPELL", style = "color:blue"),
        "is the sample of undergraduates who receive a Pell Grant."),
      p(span("FAMINC", style = "color:blue"),
        "is the average family income in real 2015 dollars."), 
      p(span("UGDS", style = "color:blue"),
        "is the number of enrolled undergraduate certificate/degree-seeking students."),
      p(span("REGION", style = "color:blue"),
        "is split into U.S. Service Schools, New England (CT, ME, MA, NH, RI, VT), Mid East (DE, DC, MD, NJ, NY, PA), Great Lakes (IL, IN, MI, OH, WI), Plains (IA, KS, MN, MO, NE, ND, SD), Southeast (AL, AR, FL, GA, KY, LA, MS, NC, SC, TN, VA, WV), Southwest (AZ, NM, OK, TX), Rocky Mountains (CO, ID, MT, UT, WY), Far West (AK, CA, HI, NV, OR, WA), and Outlying Areas (AS, FM, GU, MH, MP, PR, PW, VI)."),
      p(span("HSI", style = "color:blue"),
        "indicates whether a school is a Hispanic-serving institution (0 for No and 1 for Yes."),
      p(span("AVGFACSAL", style = "color:blue"),
        "is the average faculty salary."),
      p(span("DEP_INC_PCT_LO", style = "color:blue"),
        "is the percentage of students who are financially independent and have family incomes between $0-30,000."),
      p(span("MARRIED", style = "color:blue"),
        "is the share of married students."),
      p(span("CCSIZSET", style = "color:blue"),
        "is the school's Carnegie Classification (size and setting).")
      
      ),
    mainPanel(
      plotOutput("pcaPlot")
    )
  )
)

server <- function(input, output) {
  selectedColumn <- reactive({
    input$variable
  })
  
  output$pcaPlot <- renderPlot({
    autoplot(pca, data=dat_eda, colour = selectedColumn(), alpha=.6, size=8.5, pch=3) + 
      ggtitle(paste0("PCA of ", selectedColumn())) +
      theme_wsj() + 
      geom_text(label = row.names(dat_eda), size = 3) + 
      scale_colour_gradient(limits=c(0, 1), low="goldenrod", high="navyblue", space="Lab")
  })
}
shinyApp(server = server, ui = ui) 