# =====================================================================================
# title: best-value-score.R
# author: Shannon Chang
# summary: + write a function that will calculate a best value score for each school 
#            our main dataset
#          + the scoring formula is based on that given by U.S. News and World Report
#            for determining which colleges and university offer the best value for 
#            students
#          + 60% of the score is comprised of the ratio of quality to price; we 
#            create a proxy for quality by executing XGBOOST analysis on ranked schools
#            (by U.S. News and World Report) in our main dataset to find variables 
#            associated with ranked schools; price is given by U.S. News and World 
#            Report as discounted total cost for the academic year (after subtracting 
#            average academic year need-based scholarship or grant aid
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
# Load relevant script and data
# =====================================================================================

source("../scripts/initial-eda.R")



# =====================================================================================
# Write a function to calculate best value
# =====================================================================================

best_value_score <- function(college, dataset){
  quality <- as.numeric(subset(dataset, INSTNM == college, QUALITY))
  
  if (as.numeric(subset(dataset, INSTNM == college, CONTROL)) == 1){
    discounted_total_cost <- as.numeric(subset(dataset, INSTNM == college, NPT4_PUB))
  } else {
    discounted_total_cost <- as.numeric(subset(dataset, INSTNM == college, NPT4_PRIV))
  }
  
  need_based_aid <- as.numeric(subset(dataset, INSTNM == college, PCTPELL))
  
  if (is.null(subset(dataset, INSTNM == college, COSTT4_A)[1, ])){
    sticker_price <- as.numeric(subset(datset, INSTNM == college, COSTT4_P))
  } else {
    sticker_price <- as.numeric(subset(datset, INSTNM == college, COSTT4_A))
  }
  
  average_discount <- need_based_aid/sticker_price
  
  return(.60*(quality*discounted_total_cost) + .25*need_based_aid  + .15*average_discount)
}