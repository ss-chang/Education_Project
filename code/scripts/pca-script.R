# -------------------------------------
# -------------------------------------
# dimensionality reduction script
# -------------------------------------
# -------------------------------------


# -------------------------------------
# load libraries and set dir to wherever data is and load it in
# -------------------------------------
library(dplyr)
library(ggfortify)
library(ggplot)
library(ggthemes)
library(cluster)

setwd("~/Desktop/proj3/")
dat2 <- read.csv("MERGED2014_15_PP.csv", stringsAsFactors = FALSE)

# -------------------------------------
# Manually Find Interesting columns
# -------------------------------------
names_to_use <- c("ICLEVEL", "PREDDEG", "CCBASIC", "CCUGPROF", "CCSIZSET",
                  "HBCU", "PBI","ANNHI", "TRIBAL", "AANAPII", "HSI", "NANTI", "AVGFACSAL", 
                  "FTE", "INEXPFTE", "ADM_RATE", "ADM_RATE_ALL", "SATMT*",
                  "COSTT4_A", "COSTT4_P", "TUITIONFEE_IN", "TUITIONFEE_OUT", "TUITIONFEE_PROG",
                  "SFA", "_PRIV", "UGDS", "UGDS_MEN", "UGDS_WOMEN", "UGDS_WHITE", 
                  "UGDS_BLACK", "UGDS_HISP", "UGDS_ASIAN", "UGDS_AIAN", "UGDS_NHPI", "UGDS_NRA", "UGDS_UNKN",
                  "PPTUG_EF", "PPTUG_EF2", "INC_PCT_LO", "INC_PCT_M1", "INC_PCT_M2", "INC_PCT_H1", "INC_PCT_H2",
                  "RET_FT4", "RET_PT4", "UG25abv","PAR_ED_PCT_1STGEN", "PAR_ED_PCT_MS", "PAR_ED_PCT_HS",
                  "PAR_ED_PCT_PS", "APPL_SCH_PCT_GE*", "MARRIED", "VETERAN", "DEPENDENT", "FIRST_GEN", "FAMINC",
                  "MD_FAMINC", "FAMINC_IND", "PCT_WHITE", "PCT_BLACK", "PCT_ASIAN", "PCT_HISPANIC", "PCT_BORN_US", 
                  "POVERTY_RATE", "MEDIAN_HH_INC", "UNEMP_RATE", "PCTFLOAN", "PCTPELL", "DEBT_MDN", "GRAD_DEBT_MDN",
                  "WDRAW_DEBT_MDN", "LO_INC_DEBT_MDN","MD_INC_DEBT_MDN", "HI_INC_DEBT_MDN", "DEP_DEBT_MDN",
                  "IND_DEBT_MDN", "PELL_DEBT_MDN","NOPELL_DEBT_MDN", "GRAD_DEBT_MDN_SUPP","GRAD_DEBT_MDN10YR_SUPP", 
                  "PCTFLOAN")

# -------------------------------------
# Check if we mispelled anything. If we did whatever, get rid of column 
# -------------------------------------
nms <- names(dat2)
names_to_use <- names_to_use[names_to_use %in% nms]
dat <- dat2[,names_to_use]

# -------------------------------------
# Find columns with high Null Values and get rid of them
# -------------------------------------
null_counts <- apply(dat, 2, function(x) sum(x=="NULL"))  
good_vars <- null_counts < 5000
names_to_use <- names(good_vars[good_vars==TRUE])  
dat <- dat2[,names_to_use[1:60]]   #[1:60] because there's a problem


# -------------------------------------
# Assign NULL & 'PrivacySuppressed' values to 0; coerce columns to numeric type
# -------------------------------------
dat[dat=="NULL"] <- 0
dat[dat=="PrivacySuppressed"] <- 0
dat <- as.data.frame(sapply(dat, as.numeric))

# -------------------------------------
# Create new columns (1 so far)
# -------------------------------------
dat <- dat %>% mutate(minors = UGDS_WOMEN + UGDS_BLACK + UGDS_HISP+UGDS_ASIAN+UGDS_NHPI) %>%
  mutate(minor_bin = minors > 1.3) 

dat <- dat %>% mutate(highdebt = GRAD_DEBT_MDN > 15000)

# Create column: minority representation >= national average
  # 

# ==========================
# PCA
# ==========================

# -------------------------------------
# Investigate PCA
# -------------------------------------
pca2 <- prcomp(dat, scale=T)
head(unclass(pca2$rotation)[, 1:4])

# -------------------------------------
# Plot PCA
# -------------------------------------
autoplot(pca2, data=dat, colour = "minor_bin") + ggtitle("PCA of Minority Serving Schools") +
  theme_solarized()

autoplot(pca2, data=dat, colour = "GRAD_DEBT_MDN") + ggtitle("PCA of Schools by Median Debt (>$15,000)") +
  theme_wsj() + scale_colour_wsj()






