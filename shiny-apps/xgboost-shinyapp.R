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

set.seed(1)
sample_rows <- sample(nrow(df2),floor(0.7*nrow(df2)), replace = FALSE)
test2 <- df2[sample_rows,c(top_ten,"ABOVE_MEDIAN_MINORITIES")]
test_labels <- test2$ABOVE_MEDIAN_MINORITIES
test2 <- test2[-grep('ABOVE_MEDIAN_MINORITIES', colnames(test2))]
test.matrix <- as.matrix(test2)

num.class <- 2

# =======================================================================================
# Data Frame for our app
# =======================================================================================
app_df <- as.data.frame(test.matrix)

# =======================================================================================
# Function to Generate Predictions
# =======================================================================================

# =======================================================================================
# Variable Names for Table Output
# =======================================================================================
table_names <- c("Percent of Family Income in $75k-$110k",
                 "Percentage of Pell-Grant Recipients",
                 "Number of Undergraduates",
                 "Family Income",
                 "Average Faculty Salary",
                 "Hispanic-Serving Institution",
                 "Region",
                 "Percent of Low-Income Dependent Students",
                 "Average Cost, if Private University",
                 "Location Type"
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
# Locale Conversion
# =======================================================================================

LOCALE_TEXT <- c(
  "City: Large",# (population of 250,000 or more)"
  "City: Midsize", #City: Midsize (population of at least 100,000 but less than 250,000)
  "City: Small", #City: Small (population less than 100,000)
  "Suburb: Small" ,#Suburb: Large (outside principal city, in urbanized area with population of 250,000 or more)
  "Suburb: Midsize",#Suburb: Midsize (outside principal city, in urbanized area with population of at least 100,000 but less than 250,000)
  "Suburb: Small",
  "Town: Fringe",
  "Town: Distant",
  "Town: Remote",
  "Rural: Fringe",
  "Rural: Distant",
  "Rural: Remote"
)

Locale_conversion <- data.frame("TEXT" = LOCALE_TEXT, "Value" = sort(unique(app_df$LOCALE), decreasing = F))
#Locale_conversion$Value = as.vector(Locale_conversion$Value, mode = "numeric")
new_LOCALE <- character(length(app_df$LOCALE))

for(i in 1:nrow(app_df)){
  new_LOCALE[i] <- as.character(Locale_conversion$TEXT[which(Locale_conversion$Value == app_df$LOCALE[i])])
}
app_df[,"LOCALE_TEXT"] <- factor(new_LOCALE)


# =======================================================================================
# server
# =======================================================================================

server <- function(input, output, session) {
  
  
  
  inputValues <- reactive({
    matrix(c(
      
      input$INC_PCT_H1,
      input$PCTPELL,
      input$UGDS,
      input$FAMINC,
      input$AVGFACSAL,
      input$HSI,
      input$DEP_INC_PCT_LO,
      (which(region_conversion_table$TEXT == input$new_REGION))-1, #REGION
      input$NUM4_PRIV,
      Locale_conversion$Value[which(Locale_conversion$TEXT == input$LOCALE_TEXT)] #Locale
      
    ),ncol=1)
  })
  
  PredValue <- reactive({
    generate_preds <- function(input_values)
    {
      #predict(bst, input_values)
      max.col(t(matrix(predict(bst, input_values),
                       nrow=num.class, 
                       ncol=(length(predict(bst, input_values))/num.class)
      )
      ), "last") - 1
    }
    generate_preds(inputValues())
    })
  
  sliderValues <-   reactive({
    data.frame(
      "Names" = table_names,
      "Selected Values" = c(input$INC_PCT_H1,
                            input$PCTPELL,
                            input$UGDS,
                            input$FAMINC,
                            input$AVGFACSAL,
                            input$HSI,
                            input$new_REGION,
                            input$DEP_INC_PCT_LO,
                            input$NUM4_PRIV,
                            input$LOCALE_TEXT)
    )
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
    d <- dist(dist_dat, method = "manhattan")
    dMat <- as.matrix(d)
    tc <- head(order(dMat[-1,1]),10)+1
    
    # The output is below
    ten_closest_schools <- rownames(dMat)[tc]
    return(matrix(ten_closest_schools, ncol = 1))
  }
  
  output$table <- renderTable(sliderValues(),
                              include.rownames = FALSE)
  
  output$sol <- renderText(
    if(mean(PredValue()) >= 0.5){"A school with this profile serves minorities"}
    else {"A school with this profile underserves Minorities"})
  
  output$schools <- renderTable(
    close_schools_output(closeSchools()),
    include.rownames = FALSE,
    include.colnames = FALSE
    )
  
  output$text <- renderText(
    "A list of ten schools with a similar profile:"
  )
  
}

# =======================================================================================
# ui
# =======================================================================================

ui <- pageWithSidebar(
  
  headerPanel('       Minority-Serving Schools Profile',
              windowTitle = 'Minority-Serving Schools Profile'),
  
  sidebarPanel(
    selectInput("new_REGION", "Region",
                levels(app_df$NEW_REGION),
                selected = "Far West"),
    
    
    selectInput("LOCALE_TEXT", "Location Type",
                levels(app_df$LOCALE_TEXT),
                selected = "City: Small"),
    

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
    )
  ),

  mainPanel(
    tableOutput("table"),
    tags$br(),
    h4(textOutput("sol")),
    tags$br(),
    tags$br(),
    h4(textOutput("text")),#cat("Similar Schools with this Profile:"),
    tableOutput("schools")
    )
  )


shinyApp(ui, server)