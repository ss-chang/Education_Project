# =====================================================================================
# title: initial-eda.R
# author: Nura Kawa
# =====================================================================================


# =====================================================================================
# load libraries
# =====================================================================================
library(dplyr)
library(glmnet)
library(XML)
library(httr)

# =====================================================================================
# load data
# =====================================================================================
dat <- read.csv("data/2014-15-clean-data.csv", row.names=1,
                stringsAsFactors = FALSE)

# =====================================================================================
# Keep only the ICLEVEL is 1: Four-year institutions
# =====================================================================================
dat <- dat %>% filter(ICLEVEL == 1)

# =====================================================================================
# Replace NULL, PrivacySuppressed, and NA as 0
# =====================================================================================
is_NULL <- function(x) x == "NULL"
is_PRIVATE <- function(x) x == "PrivacySuppressed"
is_NA <- function(x) is.na(x)
dat_2 <- dat
dat_2[is.na(dat_2)] = 0
dat_2[is_NULL(dat_2)] = 0
dat_2[is_PRIVATE(dat_2)] = 0
dat <- dat_2

# =====================================================================================
# Make dat_for_pca
# =====================================================================================
dat_for_pca <- dat[,4:ncol(dat)]
dat_for_pca <- apply(dat_for_pca, 2, as.numeric)
dat_for_pca[is.na(dat_for_pca)] = 0

dat_for_pca <- scale(dat_for_pca, T, T)
dat_for_pca <- dat_for_pca[,-which(colnames(dat_for_pca) =="ICLEVEL")]

# =====================================================================================
# PCA
# =====================================================================================
pca <- princomp(dat_for_pca)
screeplot(pca, type = "l")

plot(pca$scores, main = "PCA View of Universities")


set.seed(16)
random_sample <- sample(1:nrow(dat_for_pca), 
                        200, replace = F)

smaller_pca <- princomp(dat_for_pca[random_sample,])

plot(smaller_pca$scores, main = "PCA View of 200 Universities", col = "white")
text(smaller_pca$scores[,1],
     smaller_pca$scores[,2],
     dat[random_sample,]$INSTNM,
     cex=0.5)



plot(pca$loadings, main  = "PCA View of Predictors", col = "white")
text(pca$loadings[,1],
     pca$loadings[,2],
     colnames(dat_for_pca),
     cex = 0.6)
# =====================================================================================
# Make MINORITIES column
# =====================================================================================

MINORITIES <- as.numeric(dat$UGDS_HISP)+
  as.numeric(dat$UGDS_BLACK)+
  as.numeric(dat$UGDS_ASIAN)+as.numeric(dat$UGDS_2MOR)

# =====================================================================================
# Make RANKED column
# =====================================================================================

# wh <- "http://www.washingtonpost.com/apps/g/page/local/us-news-college-ranking-trends-2015/1819/"
# wh_url <- GET(wh)
# wh_table <- readHTMLTable(rawToChar(wh_url$content), stringsAsFactors = F)
# uni_ranks1 <- wh_table[[1]]
# uni_ranks2 <- wh_table[[2]]
# # create vector of ranked school names
# ranked_unis <- c(uni_ranks1$Name, uni_ranks2$Name)
# 
# inst <- dat$INSTNM
# inst <- tolower(inst)
# ranked_unis <- tolower(ranked_unis)
# 
# rank_bool <- ranked_unis %in% dat$INSTNM
# 
# rank_bool <- as.numeric(rank_bool)
# 
# RANKED <- dat$INSTNM %in% ranked_unis + 0
# 

# =====================================================================================
# Make dat_for_lasso
# =====================================================================================

# Get rid of all UGDS columns
dat_for_lasso <- dat_for_pca[,-grep("^UGDS", colnames(dat_for_pca))]

# =====================================================================================
# LASSO
# =====================================================================================

lasso <- cv.glmnet(x = as.matrix(dat_for_lasso),
          y = as.matrix(MINORITIES))

coef(lasso)
