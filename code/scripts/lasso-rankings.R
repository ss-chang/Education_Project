# =====================================================================================
# title: lasso-rankings.R
# author: Nura Kawa
# =====================================================================================

# =====================================================================================
# Loading Libraries
# =====================================================================================
library(glmnet)

# =====================================================================================
# USA Minorities
# =====================================================================================
USA_MINORITIES <- 0.14+0.17+0.056+0.0005


# =====================================================================================
# Loading Data
# =====================================================================================
dat <- read.csv("../../data/2014-15-clean-data.csv", 
                row.names=1, 
                stringsAsFactors = FALSE)
dat <- dat[dat$ICLEVEL==1,]

colnames(dat)

# =====================================================================================
# create MINORITIES column
# =====================================================================================

UGDS_columns <- grep("^UGDS*", colnames(dat), value = TRUE)[c(3,4,5,7)]
UGDS_dat <- dat[,UGDS_columns]
UGDS_dat <- apply(UGDS_dat, 2, as.numeric)
#UGDS_dat[is.na(UGDS_dat)] <- USA_MINORITIES

MINORITIES <- rowSums(UGDS_dat)
MINORITIES[is.na(MINORITIES)] <- USA_MINORITIES #set NA to median

ABOVE_MEDIAN_MINORITIES <- (MINORITIES >= USA_MINORITIES)+0


# =====================================================================================
# Create lasso_dat and our response, RANKED
# =====================================================================================

# our response
RANKED <- dat[,which(colnames(dat)=="RANKED")]

# our predictors
lasso_dat <- dat[,5:ncol(dat)]
lasso_dat <- sapply(lasso_dat, as.numeric)
lasso_dat[is.na(lasso_dat)] <- 0
lasso_dat <- lasso_dat[,-which(colnames(lasso_dat) == "RANKED")]
lasso_dat <- cbind(lasso_dat, MINORITIES)

# remove UGDS from our predictors
lasso_dat <- lasso_dat[,-c(grep("^UGDS_", colnames(lasso_dat)))]

# =====================================================================================
# Run LASSO and find coefs
# =====================================================================================

lasso <- cv.glmnet(x = as.matrix(lasso_dat),
                   y = as.matrix(RANKED),
                   nfolds = 5,
                   alpha = 1,
                   type.measure = "mse")

lasso_coefs <- coef(lasso)

# =====================================================================================
# Select nonzero LASSO coefs
# =====================================================================================

not_zero <- !(lasso_coefs == 0)

coef_names <- rownames(not_zero)
coef_names <- coef_names[which(not_zero == 1)]
coef_vals <- lasso_coefs[not_zero]

good_values <- data.frame("names" =coef_names, "values"= coef_vals)[-1,]

# =====================================================================================
# Create "data_new", data frame of all our LASSO-selected predictors
# =====================================================================================
data_new <- data.frame(lasso_dat)[,coef_names[-1]]

# =====================================================================================
# Run PCA for dimensionality Reduction
# =====================================================================================
pca <- princomp(scale(data_new, T,T))

screeplot(pca)

# =====================================================================================
# Select PCA loadings
# =====================================================================================
pca_loadings <- pca$loadings[,1]
if(median(pca_loadings) < 0){pca_loadings <- pca_loadings*(-1)}

# =====================================================================================
# Create QUALITY_INDEX using PCA loadings and LASSO-selected columns
# =====================================================================================

QUALITY_INDEX = as.matrix(data_new) %*% as.matrix(pca_loadings)

# scale quality index
QUALITY_INDEX <- (QUALITY_INDEX - min(QUALITY_INDEX))/(max(QUALITY_INDEX) - min(QUALITY_INDEX))
hist(QUALITY_INDEX)

# =====================================================================================
# Exporting
# =====================================================================================

# Export our weights
pca_loadings <- weights
save(weights, file="../../data/weights.RData")

# Export new data frame

adding_cols <- data.frame("INSTNM" = dat$INSTNM,
           "MINORITIES" = MINORITIES,
           "ABOVE_MEDIAN_MINORITIES" = ABOVE_MEDIAN_MINORITIES,
           "QUALITY_INDEX" = QUALITY_INDEX)

new_dat <- cbind(lasso_dat,adding_cols)

write.csv(new_dat,file = "../../data/complete-data.csv")