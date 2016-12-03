# =====================================================================================
# title: calculate-best-value.R
# author: Shannon Chang, Nura Kawa, Jared Wilbur
# summary: + Calculate a best value score for each school in our main dataset
#          + The scoring formula is based on that given by U.S. News and World Report
#            for determining which colleges and university offer the best value for 
#            students
#          + 60% of the score is comprised of the ratio of quality to price; we 
#            created a proxy for quality by executing LASSO and PCA analysis on ranked 
#            schools (by U.S. News and World Report) in our main dataset to find 
#            variables associated with ranked schools and their associated weights; 
#            price is given by U.S. News and World Report as discounted total cost 
#            for the academic year (after subtracting average academic year need-based 
#            scholarship or grant aid
#          + 25% of the score is comprised of need-based aid, which U.S. News and World 
#            Report gives as the percentage of undergraduate students 
#            receiving need-based grants
#          + 15% of the score is comprised of average discounts, which U.S. News and 
#            World Report gives as the percentage of a school's 2015-2016 total sticker 
#            cost (tuition, room and board, fees, books and other expenses) that was 
#            covered by the average need-based scholarship or grant award for 
#            undergraduates in the 2015-2016 academic year
# =====================================================================================



# =====================================================================================
# Load relevant data and apply appropriate filters
# =====================================================================================

library(dplyr)

dat <- read.csv("../../data/complete-data.csv",
                row.names = 1,
                stringsAsFactors = FALSE)

my_file <- "../../data/MERGED2014_15_PP.csv"
dat_2 <- read.csv(my_file, 
                  row.names = 1,
                  stringsAsFactors = FALSE)

dat_2 <- dat_2[dat_2$ICLEVEL == 1,]
dat_2 <- dat_2[dat_2$RELAFFIL == -2,]
dat_2 <- dat_2[!grepl("seminary", dat_2$INSTNM, ignore.case = TRUE), ]



# =====================================================================================
# Create columns for discounted total cost and sticker price of each school
# =====================================================================================

COSTT4_P  <- dat_2$COSTT4_P
COSTT4_A  <- dat_2$COSTT4_A
NPT4_PUB  <- dat_2$NPT4_PUB
NPT4_PRIV <- dat_2$NPT4_PRIV

COSTT4_P  <- as.numeric(COSTT4_P)
COSTT4_A  <- as.numeric(COSTT4_A)
NPT4_PUB  <- as.numeric(NPT4_PUB)
NPT4_PRIV <- as.numeric(NPT4_PRIV)

# Create DISCOUNTED_TOTAL_COST
NPT4_PUB[is.na(NPT4_PUB)] <- 0
NPT4_PRIV[is.na(NPT4_PRIV)] <- 0
COST <- NPT4_PRIV + NPT4_PUB
COST[which(COST==0)] <- mean(NPT4_PRIV)
hist(COST)
dat$DISCOUNTED_TOTAL_COST <- COST

# Create STICKER_PRICE
COSTT4_P[is.na(COSTT4_P)] <- 0
COSTT4_A[is.na(COSTT4_A)] <- 0
tuition <- COSTT4_P+ COSTT4_A
tuition[which(tuition==0)] <- mean(COSTT4_A)
hist(tuition)
dat$STICKER_PRICE <- tuition



# =====================================================================================
# Calculate best value schools based on the U.S. News and World Report formula and our 
# proxy for "quality"
# =====================================================================================

dat_3 <- dat %>% 
  mutate(BV_SCORE = .60*(QUALITY_INDEX/DISCOUNTED_TOTAL_COST) + .25*PCTPELL + .15*(DISCOUNTED_TOTAL_COST/STICKER_PRICE))

# Top 20 schools
head(dat_3[order(dat_3$BV_SCORE), "INSTNM"], 20)