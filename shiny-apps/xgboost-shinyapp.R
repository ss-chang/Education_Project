# =======================================================================================
# setting working directory
# =======================================================================================
setwd("C:/Users/Nura/Desktop/Education_Project/shiny-apps/")

# =======================================================================================
# loading libraries
# =======================================================================================
library(shiny)

# =======================================================================================
# loading xgboost model items
# =======================================================================================
load("../data/top_ten.RData")
load("../data/xgb_model.RData")

# =======================================================================================
# preliminary work
# =======================================================================================

dat     <- read.csv("../data/complete-data.csv", row.names = 1)
df2 <- dat
df2$MINORITIES <- NULL     # This is essentially our response = overfit
df2$MINORITIES.1 <- NULL   # This is essentially our response = overfit
df2$INSTNM <- NULL         # Don't need

# Make data numeric
df2 <- as.data.frame(apply(df2, 2, as.numeric))

# The below code will be replace with the widget input information for each column in 
# top ten

# check for NA
# print(paste("No NA values in df2:", sum(is.na(df2)) == 0))

set.seed(1)
sample_rows <- sample(nrow(df2),floor(0.7*nrow(df2)), replace = FALSE)
test2 <- df2[sample_rows,c(top_ten,"ABOVE_MEDIAN_MINORITIES")]
test_labels <- test2$ABOVE_MEDIAN_MINORITIES
test2 <- test2[-grep('ABOVE_MEDIAN_MINORITIES', colnames(test2))]
test.matrix <- as.matrix(test2)

# check for NA
#print(paste("No NA values in test2:", sum(is.na(test2)) == 0))

# select number of classes for xgboost model
num.class <- 2

# =======================================================================================
# Data Frame for our app
# =======================================================================================
app_df <- as.data.frame(test.matrix)

# =======================================================================================
# Function to Generate Predictions
# =======================================================================================
generate_preds <- function(input_values)
{
  max.col(t(matrix(predict(bst, input_values),
                   nrow=num.class, 
                   ncol=(length(predict(bst, input_values))/num.class)
  )
  ), "last") - 1
}


# =======================================================================================
# Variable Names for Table Output
# =======================================================================================
table_names <- c("Region", 
                 "Percent of Family Income in $75k-$110k",
                 "Percent of Low-Income Dependent Students",
                 "Number of Undergraduates",
                 "Family Income",
                 "Percentage of Pell-Grant Recipients",
                 "Hispanic-Serving Institution",
                 "Average Faculty Salary",
                 #"Married",
                 #"Percentage of Federal Loan Recipients",
                 "Average Cost, if Private University",
                 "Carnegie Classification"
                 )

# =======================================================================================
# Region Metric Conversion
# =======================================================================================

region_values <- c("U.S. Service Schools",
                   "New England", #(CT, ME, MA, NH, RI, VT)
                   "Mid East", #(DE, DC, MD, NJ, NY, PA)
                   "Great Lakes", #(IL, IN, MI, OH, WI)
                   "Plains", #(IA, KS, MN, MO, NE, ND, SD)
                   "Southeast", # (AL, AR, FL, GA, KY, LA, MS, NC, SC, TN, VA, WV)
                   "Southwest", # (AZ, NM, OK, TX)
                   "Rocky Mountains", # (CO, ID, MT, UT, WY)
                   "Far West", # (AK, CA, HI, NV, OR, WA)
                   "Outlying Areas") # (AS, FM, GU, MH, MP, PR, PW, VI)

REGION <- app_df$REGION
new_REGION <- character(length(REGION))
for(i in 1:nrow(app_df)){new_REGION[i] <- region_values[REGION[i]+1]}
app_df$NEW_REGION <- factor(new_REGION)

region_conversion_table <- data.frame("TEXT" = region_values, "NUMERIC" = 0:9)

# =======================================================================================
# server
# =======================================================================================

server <- function(input, output, session) {
  
  inputValues <- reactive({
    matrix(c(
      input$INC_PCT_H1,
      input$PCTPELL,
      input$UGDS,
      input$HSI,
      (which(region_conversion_table$TEXT == input$new_REGION))-1,
      input$AVGFACSAL,
      input$DEP_INC_PCT_LO,
      input$FAMINC,
      input$NUM4_PRIV,
      input$LOCALE
      
    ),ncol=1)
  })
  
  PredValue <- reactive({
    generate_preds(inputValues())
    })
  
  sliderValues <-   reactive({
    data.frame(
      "Names" = table_names,
      "Values" = inputValues(),
      "Minority-Serving Indicator" = as.logical(PredValue()))
  })
  
  dat2 <- dat[,c(top_ten,"INSTNM")]
  dat2$INSTNM <- as.character(dat2$INSTNM)
  dist_dat <- dat2[,-grep("INSTNM", colnames(dat2))] # take out INSTNM so all numeric
  
  closeSchools <- reactive({
    dist_dat <- rbind(as.vector(inputValues(), mode = "numeric"), dist_dat)
  })
  
  close_schools_output <- function(dist_dat)
  {
    dist_dat <- apply(dist_dat, 2, as.numeric)
    rownames(dist_dat) <- c("test case", dat2$INSTNM)
    d <- dist(dist_dat)
    dMat <- as.matrix(d)
    tc <- head(order(dMat[-1,1]),10)+1
    # The output is below
    ten_closest_schools <- rownames(dMat)[tc]
    return(matrix(ten_closest_schools, ncol = 1))
  }
  
  output$table <- renderTable(sliderValues(),
                              include.rownames = FALSE)
  
  output$sol <- renderPrint(
    if(mean(PredValue()) >= 0.5){"Servers Minorities"} else {"Underserves Minorities"})
  
  output$schools <- renderTable(
    close_schools_output(closeSchools()),
    include.rownames = FALSE,
    include.colnames = FALSE
    )
  
}

# =======================================================================================
# ui
# =======================================================================================

ui <- pageWithSidebar(
  headerPanel('xgboost important predictors'),
  sidebarPanel(
    selectInput("new_REGION", "Region",
                levels(app_df$NEW_REGION),
                selected = "Far West"),

    sliderInput("INC_PCT_H1", "Percent of Family Income in $75k-$110k",
                min = min(app_df$INC_PCT_H1), 
                max = max(app_df$INC_PCT_H1), 
                value = median(app_df$INC_PCT_H1)
    ),
    
    sliderInput("DEP_INC_PCT_LO", "Percent of Low-Income Dependent Students",
                min = min(app_df$DEP_INC_PCT_LO), 
                max = max(app_df$DEP_INC_PCT_LO), 
                value = median(app_df$DEP_INC_PCT_LO)
    ),
    
    sliderInput("UGDS", "Number of Undergraduates",
                min = min(app_df$UGDS), 
                max = max(app_df$UGDS), 
                value = median(app_df$UGDS)
    ),
    
    sliderInput("FAMINC", "Family Income",
                min = min(app_df$FAMINC), 
                max = max(app_df$FAMINC), 
                value = median(app_df$FAMINC)
    ),
    
    sliderInput("PCTPELL", "Percentage of Pell-Grant Recipients",
                min = min(app_df$PCTPELL), 
                max = max(app_df$PCTPELL), 
                value = median(app_df$PCTPELL)
    ),
    
    sliderInput("HSI", "Hispanic-Serving Institution",
                min = min(app_df$HSI), 
                max = max(app_df$HSI),
                step = 1,
                value = min(app_df$HSI)
    ),
    
    sliderInput("AVGFACSAL", "Average Faculty Salary",
                min = min(app_df$AVGFACSAL), 
                max = max(app_df$AVGFACSAL), 
                value = median(app_df$AVGFACSAL)
    ),
    
    sliderInput("NUM4_PRIV", "Average Net Cost, if Private",
                min = min(app_df[,top_ten[9]]), 
                max = max(app_df[,top_ten[9]]), 
                value = median(app_df[,top_ten[9]])
    ),
    
    sliderInput("LOCALE", "Locale",
                min = min(app_df[,top_ten[10]]), 
                max = max(app_df[,top_ten[10]]), 
                value = median(app_df[,top_ten[10]]),
                step = 1
    )
    
  ),

  mainPanel(
    tableOutput("table"),
    tableOutput("schools")
    )
  )


shinyApp(ui, server)