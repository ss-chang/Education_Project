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
dat <- read.csv("../../data/2014-15-clean-data.csv", row.names=1,
                stringsAsFactors = FALSE)


# =====================================================================================
# Add the University Rankings boolean column
# =====================================================================================

load("../../data/ranked_universities.RData")
RANKED <- rank_bool

dat <- cbind(dat, RANKED)

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

# remove our copy
rm(dat_2) 


# =====================================================================================
# Make MINORITIES column
# =====================================================================================

MINORITIES <- as.numeric(dat$UGDS_HISP)+
  as.numeric(dat$UGDS_BLACK)+
  + as.numeric(dat$UGDS_AIAN)+
  as.numeric(dat$UGDS_ASIAN)+as.numeric(dat$UGDS_2MOR)

#dat <- cbind(dat, MINORITIES)

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
dev.copy(png, "../../images/pca/screeplot.png")
dev.off()
dev.copy(pdf, "../../images/pca/screeplot.pdf")
dev.off()


my_colors <- c("tomato1", "tomato4")
plot(pca$scores, main = "PCA View of Universities",
     pch = 16,
     col = my_colors[(dat$RANKED+1)])
legend("topright",
       bty = "n",
       cex = 0.7,
       #pch = 16,
       legend = c("Non-Ranked", "Ranked"),
       title = "RANKED",
       fill = my_colors)
dev.copy(png, "../../images/pca/universities-all.png")
dev.off()
dev.copy(pdf, "../../images/pca/universities-all.pdf")
dev.off()

set.seed(16)
random_sample <- sample(1:nrow(dat_for_pca), 
                        200, replace = F)

smaller_pca <- princomp(dat_for_pca[random_sample,])

plot(smaller_pca$scores, main = "PCA View of 200 Universities", col = "white")
text(smaller_pca$scores[,1],
     smaller_pca$scores[,2],
     dat[random_sample,]$INSTNM,
     cex=0.5)
dev.copy(png, "../../images/pca/universities-smaller.png")
dev.off()
dev.copy(pdf, "../../images/pca/universities-smaller.pdf")
dev.off()


plot(pca$loadings, main  = "PCA View of Predictors", col = "white")
text(pca$loadings[,1],
     pca$loadings[,2],
     colnames(dat_for_pca),
     cex = 0.6)
dev.copy(png, "../../images/pca/predictors.png")
dev.off()
dev.copy(pdf, "../../images/pca/predictors.pdf")
dev.off()

random_sample_smaller <- sample(1:nrow(dat), 50, replace = FALSE)
dat_for_hclust <- dat_for_pca[random_sample_smaller,]
rownames(dat_for_hclust) <- dat$INSTNM[random_sample_smaller]

d <- dist(dat_for_hclust)
hc <- hclust(d)

plot(hc, cex = 0.7)
dev.copy(png, "../../images/pca/sample-hclust.png")
dev.off()
dev.copy(pdf, "../../images/pca/sample-hclust.pdf")
dev.off()

# =====================================================================================
# Make dat_for_lasso
# =====================================================================================

# Get rid of all UGDS columns
dat_for_lasso <- dat_for_pca[,-grep("^UGDS", colnames(dat_for_pca))]
dat_for_lasso <- scale(dat_for_lasso, T, T)


# =====================================================================================
# LASSO
# =====================================================================================

lasso <- cv.glmnet(x = as.matrix(dat_for_lasso),
          y = as.matrix(MINORITIES),
          nfolds = 5,
          type.measure = "auc")

coef(lasso)




