# =====================================================================================
# title: rename-missing-schools.R
# author: Shannon Chang
# summary: find schools from Washington Post school rankings data that we were not 
#          able to match with our dataset and rename schools that do exist in our 
#          main dataset, but were not matched because of slight differences in name
# =====================================================================================

# select your file
my_file <- "../../data/MERGED2014_15_PP.csv"

# read in your file
dat <- read.csv(my_file, row.names = 1)


# =====================================================================================
# scrape data from Washington Post for school rankings
# =====================================================================================

library(XML)
library(httr)
wh <- "http://www.washingtonpost.com/apps/g/page/local/us-news-college-ranking-trends-2015/1819/"
wh_url <- GET(wh)
wh_table <- readHTMLTable(rawToChar(wh_url$content), stringsAsFactors = F)
uni_ranks1 <- wh_table[[1]]
uni_ranks2 <- wh_table[[2]]
# create vector of ranked school names
ranked_unis <- c(uni_ranks1$Name, uni_ranks2$Name)

rank_bool <- dat$INSTNM %in% ranked_unis

rank_bool <- as.numeric(rank_bool)






# =====================================================================================
# find schools we don't have
# =====================================================================================

# this finds the schools we found
data_we_got <- dat$INSTNM[which(rank_bool==1)]
# This finds the data from wh_post that didnt we get
didntget <- !(ranked_unis %in% data_we_got)

names_didntget <- subset(ranked_unis, !(ranked_unis %in% data_we_got), Name)



# =====================================================================================
# manually rename universities that were left out to match names in our main dataset
# =====================================================================================

# this is the first round of renaming
new_names_1 <- c("Columbia University in the City of New York", 
                 "Washington University in St Louis",
                 "University of Virginia-Main Campus", 
                 "University of North Carolina at Chapel Hill", 
                 "Georgia Institute of Technology-Main Campus",
                 "Tulane University of Louisiana",
                 "University of Illinois at Urbana-Champaign",
                 "Pennsylvania State University-Main Campus",
                 "Ohio State University-Main Campus",
                 "The University of Texas at Austin",
                 "University of Washington-Seattle Campus",
                 "University of Maryland-College Park",
                 "Purdue University-Main Campus",
                 "University of Pittsburgh-Pittsburgh Campus", 
                 "Texas A & M University-College Station", 
                 "Virginia Polytechnic Institute and State University", 
                 "Rutgers University-New Brunswick", 
                 "Miami University-Oxford", 
                 "SUNY at Binghamton", 
                 "North Carolina State University at Raleigh", 
                 "Stony Brook University",
                 "University of Colorado Boulder", 
                 "Saint Louis University",
                 "The University of Alabama",
                 "University at Buffalo",
                 "University of Missouri-Columbia", 
                 "University of New Hampshire-Main Campus", 
                 "The University of Tennessee-Knoxville", 
                 "University of Oklahoma-Norman Campus", 
                 "University of South Carolina-Columbia")

for (i in 1:length(new_names_1)){
  names_to_replace_1 <- which(!(ranked_unis %in% data_we_got))[1:length(new_names_1)]
  
  ranked_unis[names_to_replace_1[i]] <- new_names_1[i]
}


# there are two schools named "Univerty of St Thomas," so skip rename here and manually
# assign a 1 to RANKED column later for the corrrect school
rank_bool[which(dat$INSTNM == "University of St Thomas")[2]] == 1


# re-run previous code to get updated vector of data from wh_post that we didn't get
rank_bool <- dat$INSTNM %in% ranked_unis
rank_bool <- as.numeric(rank_bool)
data_we_got <- dat$INSTNM[which(rank_bool==1)]
didntget <- !(ranked_unis %in% data_we_got)
names_didntget <- subset(ranked_unis, !(ranked_unis %in% data_we_got), Name)


# this isthe second round of renaming

new_names_2 <- c("Colorado State University-Fort Collins",
                 "The New School")
for (i in 1:length(new_names_2)){
  names_to_replace_2 <- which(!(ranked_unis %in% data_we_got))[2:(length(new_names_2)+1)]
  
  ranked_unis[names_to_replace_2[i]] <- new_names_2[i]
}


# Arizona State University is listed as five separate campuses in our main dataset, 
# but the wh_post data ranks all campuses as one
# we will skip renaming here and manually assign a 1 to the RANKED column for all 
# five campuses later

rank_bool[grep("^Arizona State University *", dat$INSTNM)] = 1



# re-run previous code to get updated vector of data from wh_post that we didn't get

rank_bool <- dat$INSTNM %in% ranked_unis
rank_bool <- as.numeric(rank_bool)
data_we_got <- dat$INSTNM[which(rank_bool==1)]
didntget <- !(ranked_unis %in% data_we_got)
names_didntget <- subset(ranked_unis, !(ranked_unis %in% data_we_got), Name)


# this is the third round of renaming

new_names_3 <- c("Louisiana State University and Agricultural & Mechanical College",
                 "SUNY at Albany",
                 "University of Illinois at Chicago",
                 "Ohio University-Main Campus",
                 "Rutgers University-Newark",
                 "University of Cincinnati-Main Campus",
                 "The University of Texas at Dallas",
                 "Saint John Fisher College",
                 "Oklahoma State University-Main Campus",
                 "University of Alabama at Birmingham")

for (i in 1:length(new_names_3)){
  names_to_replace_3 <- which(!(ranked_unis %in% data_we_got))[3:(length(new_names_3)+2)]
  
  ranked_unis[names_to_replace_3[i]] <- new_names_3[i]
}


# re-run previous code to get updated vector of data from wh_post that we didn't get

rank_bool <- dat$INSTNM %in% ranked_unis
rank_bool <- as.numeric(rank_bool)
data_we_got <- dat$INSTNM[which(rank_bool==1)]
didntget <- !(ranked_unis %in% data_we_got)
names_didntget <- subset(ranked_unis, !(ranked_unis %in% data_we_got), Name)

# The U.S. Naval, Military and Air Force Academies do not appear in our main dataset, 
# so we will not rename them here

# this is the fourth round of renaming

new_names_4 <- c("Sewanee-The University of the South", 
                 "St Olaf College", 
                 "St Lawrence University", 
                 "The College of Wooster", 
                 "Hobart William Smith Colleges")

for (i in 1:length(new_names_4)){
  names_to_replace_4 <- which(!(ranked_unis %in% data_we_got))[6:(length(new_names_4)+5)]
  
  ranked_unis[names_to_replace_4[i]] <- new_names_4[i]
}


# re-run previous code to get updated vector of data from wh_post that we didn't get

rank_bool <- dat$INSTNM %in% ranked_unis
rank_bool <- as.numeric(rank_bool)
data_we_got <- dat$INSTNM[which(rank_bool==1)]
didntget <- !(ranked_unis %in% data_we_got)
names_didntget <- subset(ranked_unis, !(ranked_unis %in% data_we_got), Name)


# Hillsdale College does not appear in our main dataset, so we will not rename here


# this is the fifth round of renaming

new_names_5 <- c("Saint Johns University", 
                 "Saint Mary's College", 
                 "College of Saint Benedict", 
                 "St Mary's College of Maryland", 
                 "Washington & Jefferson College", 
                 "Saint Michael's College", 
                 "Saint Anselm College", 
                 "Birmingham Southern College", 
                 "Concordia College at Moorhead", 
                 "Linfield College-McMinnville Campus" 
                 )
for (i in 1:length(new_names_5)){
  names_to_replace_5 <- which(!(ranked_unis %in% data_we_got))[7:(length(new_names_5)+6)]
  
  ranked_unis[names_to_replace_5[i]] <- new_names_5[i]
}


# re-run previous code to get updated vector of data from wh_post that we didn't get

rank_bool <- dat$INSTNM %in% ranked_unis
rank_bool <- as.numeric(rank_bool)
data_we_got <- dat$INSTNM[which(rank_bool==1)]
didntget <- !(ranked_unis %in% data_we_got)
names_didntget <- subset(ranked_unis, !(ranked_unis %in% data_we_got), Name)


# Principia College does not appear in our main dataset, so we will not it rename here


# this is the sixth round of renaming

new_names_6 <- c("Saint Norbert College")

for (i in 1:length(new_names_6)){
  names_to_replace_6 <- which(!(ranked_unis %in% data_we_got))[8:(length(new_names_6)+7)]
  
  ranked_unis[names_to_replace_6[i]] <- new_names_6[i]
}


# re-run previous code to get updated vector of data from wh_post that we didn't get

rank_bool <- dat$INSTNM %in% ranked_unis
rank_bool <- as.numeric(rank_bool)
data_we_got <- dat$INSTNM[which(rank_bool==1)]
didntget <- !(ranked_unis %in% data_we_got)
names_didntget <- subset(ranked_unis, !(ranked_unis %in% data_we_got), Name)


# Grove City College does not appear in our main dataset, so we will not rename it here

new_names_7 <- c("University of North Carolina at Asheville")

for (i in 1:length(new_names_7)){
  names_to_replace_7 <- which(!(ranked_unis %in% data_we_got))[9:(length(new_names_7)+8)]
  
  ranked_unis[names_to_replace_7[i]] <- new_names_7[i]
}


# re-run previous code one more time to get updated vector of data from wh_post and 
# check if there are any more discrepancies we can fix

rank_bool <- dat$INSTNM %in% ranked_unis
rank_bool <- as.numeric(rank_bool)
data_we_got <- dat$INSTNM[which(rank_bool==1)]
didntget <- !(ranked_unis %in% data_we_got)
names_didntget <- subset(ranked_unis, !(ranked_unis %in% data_we_got), Name)


save(rank_bool, file = "../../data/ranked_universities.RData")
