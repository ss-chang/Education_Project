library(XML)
library(httr)
wh <- "http://www.washingtonpost.com/apps/g/page/local/us-news-college-ranking-trends-2015/1819/"
wh_url <- GET(wh)
wh_table <- readHTMLTable(rawToChar(wh_url$content), stringsAsFactors = F)
uni_ranks <- wh_table[[1]]

setwd("~/Desktop/RCSDS/Education_Project_TEST")   # set to wherever you have the data
dat2 <- read.csv("MERGED2014_15_PP.csv", stringsAsFactors = FALSE)
data <- dat2[,1:20]
uni_names <- dat2$INSTNM

dat2_merged <- merge(dat2, uni_ranks, by.x = "INSTNM", all.x = TRUE)
dat2_merged$`2015-16` <- as.numeric(dat2_merged$`2015-16`)
dat2_merged$RANKED <- vector(mode = "numeric", length = length(dat2_merged))
for (i in 1:length(dat2_merged)){
  if (is.na(dat2_merged$`2015-16`[i])){
    dat2_merged$RANKED[i] <- 0
  } else {
    dat2_merged$RANKED[i] <- 1
  }
}



best_value_score <- function(college){
  if (as.numeric(subset(dat2, INSTNM == college, CONTROL)) == 1){
    discounted_total_cost <- as.numeric(subset(dat2, INSTNM == college, NPT4_PUB))
  } else {
    discounted_total_cost <- as.numeric(subset(dat2, INSTNM == college, NPT4_PRIV))
  }
  
  if (as.numeric(subset(dat2, INSTNM == college, CONTROL)) == 1){
    need_based_aid <- as.numeric(subset(dat2, INSTNM == college, NUM4_PUB))
  } else {
    need_based_aid <- as.numeric(subset(dat2, INSTNM == college, NUM4_PRIV))
  }
  
  if (is.null(subset(dat2, INSTNM == college, COSTT4_A)[1, ])){
    average_discount <- as.numeric(subset(dat2, INSTNM == college, COSTT4_P))
  } else {
    average_discount <- as.numeric(subset(dat2, INSTNM == college, COSTT4_A))
  }
  
  return(discounted_total_cost + .25*need_based_aid  + .15*average_discount)
}
