library(car)
library(corrplot)
library(Rtsne)
library(caret)
library(dplyr)
library(xgboost)


# =====================================================================================
# Load and prepare data
# =====================================================================================

source("code/scripts/calculate-best-value.R")
#dat_3 <- read.csv("data/complete-data.csv")
df2 <- dat_3
df2$MINORITIES <- NULL     # This is essentially our response = overfit
df2$MINORITIES.1 <- NULL   # This is essentially our response = overfit
df2$INSTNM <- NULL         # Don't need
# Make data numeric
df2 <- as.data.frame(apply(df2, 2, as.numeric))


# =====================================================================================
# Define test and training sets
# =====================================================================================
set.seed(1)
# Define datasets
train_ind <- sample(2166, 1500)
train <- df2[train_ind,]
test <- df2[-train_ind,]
# Get response labels
train_labels <- train$ABOVE_MEDIAN_MINORITIES
train <- train[-grep('ABOVE_MEDIAN_MINORITIES', colnames(train))]
test_labels <- test$ABOVE_MEDIAN_MINORITIES
test <- test[-grep('ABOVE_MEDIAN_MINORITIES', colnames(test))]
# convert data to matrix
train.matrix = as.matrix(train)
mode(train.matrix) == "numeric"
test.matrix = as.matrix(test)
mode(test.matrix) == "numeric"
# convert outcome from factor to numeric matrix 
#   bc xgboost takes multi-labels in [0, numOfClass)
y = as.matrix(as.integer(train_labels))

# =====================================================================================
# XGBOOST 1: Set up parameters
# =====================================================================================
# xgboost parameters
num.class = 2
param <- list("objective" = "multi:softprob",    # multiclass classification 
              "num_class" = 2,    # number of classes 
              "eval_metric" = "merror",    # evaluation metric 
              "nthread" = 8,   # number of threads to be used 
              "max_depth" = 16,    # maximum depth of tree 
              "eta" = 0.3,    # step size shrinkage 
              "gamma" = 0,    # minimum loss reduction 
              "subsample" = 1,    # part of data instances to grow tree 
              "colsample_bytree" = 1,  # subsample ratio of columns when constructing each tree 
              "min_child_weight" = 12  # minimum sum of instance weight needed in a child 
)


# =====================================================================================
# XGBOOST 2: Cross-Validate
# =====================================================================================
set.seed(1234)
# k-fold cross validation, with timing
nround.cv = 50
system.time( bst.cv <- xgb.cv(param=param, data=train.matrix, label=y, 
                              nfold=4, nrounds=nround.cv, prediction=TRUE, verbose=T) )

# Find best parameters for xgboost
# =====================================================================================
# XGBOOST 2: Optimizing XGBOOST
# =====================================================================================
# find parameters associated with minimum error, use to get best model
min.merror.idx = which.min(bst.cv$dt[, test.merror.mean]) # identify index of best classification
bst.cv$dt[min.merror.idx,]  # minimum error metrics
# predict 
pred.cv = matrix(bst.cv$pred, nrow=length(bst.cv$pred)/num.class, ncol=num.class)
pred.cv = max.col(pred.cv, "last")

# confusion matrix
confusionMatrix(factor(y+1), factor(pred.cv))

# =====================================================================================
# XGBOOST 2: Train XGBOOST with Best Parameters
# =====================================================================================
system.time( bst <- xgboost(param=param, data=train.matrix, label=y, 
                            nrounds=min.merror.idx, verbose=1) )
# Use best model to predict 
pred <- predict(bst, test.matrix)  
head(pred, 10)  
# Get accurracy of best model
pred = matrix(pred, nrow=num.class, ncol=length(pred)/num.class)
pred = t(pred)
pred = max.col(pred, "last")
pred.char = toupper(letters[pred])
cat("Accuracy: ", mean(as.numeric((pred -1)== test_labels)))
# =====================================================================================
# XGBOOST: Feature Importance
# =====================================================================================
model = xgb.dump(bst, with.stats=TRUE)
# get the feature real names
names = dimnames(train.matrix)[[2]]
# compute feature importance matrix
importance_matrix = xgb.importance(names, model=bst)
# plot feature importance
gp = xgb.plot.importance(importance_matrix)
print(gp) 

# =====================================================================================
# XGBOOST: Select best features
# =====================================================================================
par(mfrow=c(1,2))
op = par(bg = "wheat")
plot(importance_matrix$Gain,type='l', col='tomato', lwd=6, 
     xlim=c(0,25), main="How Many Featurs to Select?", xlab="Number of Features",
     ylab="Gain from Features")
abline(v=10, col='skyblue1',lwd=10)

plot(cumsum(importance_matrix$Gain),type='l', col='tomato', lwd=6, 
     xlim=c(0,40), main="How Many Featurs to Select?", xlab="Number of Features",
     ylab="Gain from Features")
abline(v=10, col='skyblue1',lwd=10) 

top_ten <- importance_matrix$Feature[1:10]
save(top_ten,file= "top_ten.RData")




















# =====================================================================================
# XGBOOST: Rerun XGBOOST with less features for more interpretability
# =====================================================================================
df2 <- dat
df2$MINORITIES <- NULL     # This is essentially our response = overfit
df2$MINORITIES.1 <- NULL   # This is essentially our response = overfit
df2$INSTNM <- NULL         # Don't need
# Make data numeric
df2 <- as.data.frame(apply(df2, 2, as.numeric))
set.seed(2)
# Define datasets
train_ind <- sample(2166, 1500)
train <- df2[train_ind,c(top_ten,"ABOVE_MEDIAN_MINORITIES")]
test <- df2[-train_ind,c(top_ten,"ABOVE_MEDIAN_MINORITIES")]
# Get response labels
train_labels <- train$ABOVE_MEDIAN_MINORITIES
train <- train[-grep('ABOVE_MEDIAN_MINORITIES', colnames(train))]
test_labels <- test$ABOVE_MEDIAN_MINORITIES
test <- test[-grep('ABOVE_MEDIAN_MINORITIES', colnames(test))]
# convert data to matrix
train.matrix = as.matrix(train)
mode(train.matrix) == "numeric"
test.matrix = as.matrix(test)
mode(test.matrix) == "numeric"
# convert outcome from factor to numeric matrix 
#   bc xgboost takes multi-labels in [0, numOfClass)
y = as.matrix(as.integer(train_labels))

# =====================================================================================
# XGBOOST 1: Set up parameters
# =====================================================================================
# xgboost parameters
num.class = 2
param <- list("objective" = "multi:softprob",    # multiclass classification 
              "num_class" = 2,    # number of classes 
              "eval_metric" = "merror",    # evaluation metric 
              "nthread" = 8,   # number of threads to be used 
              "max_depth" = 16,    # maximum depth of tree 
              "eta" = 0.3,    # step size shrinkage 
              "gamma" = 0,    # minimum loss reduction 
              "subsample" = 1,    # part of data instances to grow tree 
              "colsample_bytree" = 1,  # subsample ratio of columns when constructing each tree 
              "min_child_weight" = 12  # minimum sum of instance weight needed in a child 
)


# =====================================================================================
# XGBOOST 2: Cross-Validate
# =====================================================================================
set.seed(1235)
# k-fold cross validation, with timing
nround.cv = 50
system.time( bst.cv <- xgb.cv(param=param, data=train.matrix, label=y, 
                              nfold=4, nrounds=nround.cv, prediction=TRUE, verbose=T) )

# Find best parameters for xgboost
# =====================================================================================
# XGBOOST 2: Optimizing XGBOOST
# =====================================================================================
# find parameters associated with minimum error, use to get best model
min.merror.idx = which.min(bst.cv$dt[, test.merror.mean]) # identify index of best classification
bst.cv$dt[min.merror.idx,]  # minimum error metrics
# predict 
pred.cv = matrix(bst.cv$pred, nrow=length(bst.cv$pred)/num.class, ncol=num.class)
pred.cv = max.col(pred.cv, "last")

# confusion matrix
confusionMatrix(factor(y+1), factor(pred.cv))

# =====================================================================================
# XGBOOST 2: Train XGBOOST with Best Parameters
# =====================================================================================
system.time( bst <- xgboost(param=param, data=train.matrix, label=y, 
                            nrounds=min.merror.idx, verbose=1) )
# Use best model to predict 
pred <- predict(bst, test.matrix)  
head(pred, 10)  
# Get accurracy of best model
pred = matrix(pred, nrow=num.class, ncol=length(pred)/num.class)
pred = t(pred)
pred = max.col(pred, "last")
pred.char = toupper(letters[pred])
cat("Accuracy: ", mean(as.numeric((pred -1)== test_labels)))

model = xgb.dump(bst, with.stats=TRUE)
# get the feature real names
names = dimnames(train.matrix)[[2]]
# compute feature importance matrix
importance_matrix = xgb.importance(names, model=bst)
# plot feature importance
gp = xgb.plot.importance(importance_matrix)
print(gp) 



# Dave dataa
save(bst, file = "xgb_model.RData")



