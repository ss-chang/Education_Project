
# ==================================================================
# ==================================================================
# ==================================================================
# ==================================================================
dat     <- read.csv("data/complete-data.csv", row.names = 1)
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
# Use best model to predict 
num.class <- 2
# INPUT DATA
input_data <- data.frame(
    PCTPELL           = 0.3143,     # range 0 1
    UGDS              = 27126, # range: 0 151558
    HSI               = 0,     # range: 0 1
    INC_PCT_H1        = .0824,    # range 0.0 0.297
    REGION            = 8,     # range 0 9
    CCSIZSET          = 16,     # range: -2, 18
    DEP_INC_PCT_LO    = .3995485,    # range: 0.0 0.92
    AVGFACSAL         = 15194, # range: 0 25143
    NOPELL_RPY_3YR_RT = 0.9548,  # range: 0.0  0.99
    PPTUG_EF          = .029      # range: 0 1
)

input_data <- as.matrix(input_data)
num.class  <- 2

# Predict outcome
pred <- predict(bst, input_data)  
pred = matrix(pred, nrow=num.class, ncol=length(pred)/num.class)
pred = t(pred)
pred = max.col(pred, "last")
print(c("Underserves Minorities","Overserves Minorities")[pred])

# ==================================================================
# Distance: Find 10 most similar schools to our input school
# ==================================================================
# Find 10 most similar schools to our input school
input_data <- as.data.frame(input_data)
#input_data$INSTNM <- "NGO choice"
# get data ready
dat2 <- dat[,c(top_ten,"INSTNM")]
dat2$INSTNM <- as.character(dat2$INSTNM)
dist_dat <- dat2[,-grep("INSTNM", colnames(dat2))] # take out INSTNM so all numeric
dist_dat <- rbind(input_data, dist_dat)
dist_dat <- apply(dist_dat, 2, as.numeric)

rownames(dist_dat) <- c("test case", dat2$INSTNM)

d <- dist(dist_dat)
dMat <- as.matrix(d)
tc <- head(order(dMat[-1,1]),10)+1

# The output is below
ten_closest_schools <- rownames(dMat)[tc]
print(ten_closest_schools)




