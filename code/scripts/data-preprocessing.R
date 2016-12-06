# =====================================================================================
# title: data-preprocessing.R
# author: Nura Kawa
# summary: pre-process data, export clean CSV
#
# give us initial data with all column names as .csv
# load in WH rankings and append the columns
# =====================================================================================

# =====================================================================================
# loading libraries
# =====================================================================================

library(tm)
library(dplyr)
library(glmnet)
library(XML)
library(httr)

# =====================================================================================
# loading data
# =====================================================================================

# select file to load
my_file <- "../../data/MERGED2014_15_PP.csv"

# read in your file, call it "dat"
dat <- read.csv(my_file, row.names = 1)

# =====================================================================================
# column selection
# =====================================================================================

# -------------------------------------------------------------------------------------
# Nura
# -------------------------------------------------------------------------------------

select_columns <- function(df, columns) #df is a data frame, columns is vector
{
  columns <- df[,columns]
  
  # select columns with these names: 
  pattern <- c("BLACK", "ASIAN", "PELL", "INCOME", "LO", "FIRSTGEN")
  
  # select matches
  matches <- unique(grep(paste(pattern,collapse="|"),
                         colnames(columns),
                         value = TRUE))
  
  
  # now remove things that you do not need
  to_remove <- c("DEATH", "TRANS", "UNKN")                  
  
  remove <- unique(grep(paste(to_remove,collapse="|"),
                        matches,
                        value = FALSE))
  
  # finally, remove the unwanted columns
  matches <- matches[-remove]           
  
  return(matches)
}

nura_names <- select_columns(dat, 1000:1500)

# -------------------------------------------------------------------------------------
# Jared
# -------------------------------------------------------------------------------------

jared_names <- "ICLEVEL,PREDDEG,CCBASIC,CCUGPROF,CCSIZSET,HBCU,PBI,ANNHI,TRIBAL,AANAPII,HSI,NANTI,AVGFACSAL,INEXPFTE,ADM_RATE,ADM_RATE_ALL,COSTT4_A,COSTT4_P,TUITIONFEE_IN,TUITIONFEE_OUT,TUITIONFEE_PROG,UGDS,UGDS_MEN,UGDS_WOMEN,UGDS_WHITE,UGDS_BLACK,UGDS_HISP,UGDS_ASIAN,UGDS_AIAN,UGDS_NHPI,UGDS_NRA,UGDS_UNKN,PPTUG_EF,PPTUG_EF2,INC_PCT_LO,INC_PCT_M1,INC_PCT_M2,INC_PCT_H1,INC_PCT_H2,RET_FT4,RET_PT4,PAR_ED_PCT_1STGEN,PAR_ED_PCT_MS,PAR_ED_PCT_HS,PAR_ED_PCT_PS,MARRIED,VETERAN,DEPENDENT,FIRST_GEN,FAMINC,MD_FAMINC,FAMINC_IND,PCT_WHITE,PCT_BLACK,PCT_ASIAN,PCT_HISPANIC,PCT_BORN_US,POVERTY_RATE,MEDIAN_HH_INC,UNEMP_RATE,PCTFLOAN,PCTPELL,DEBT_MDN,GRAD_DEBT_MDN,WDRAW_DEBT_MDN,LO_INC_DEBT_MDN,MD_INC_DEBT_MDN,HI_INC_DEBT_MDN,DEP_DEBT_MDN,IND_DEBT_MDN,PELL_DEBT_MDN,NOPELL_DEBT_MDN,GRAD_DEBT_MDN_SUPP,GRAD_DEBT_MDN10YR_SUPP,PCTFLOAN"
jared_names <- strsplit(jared_names, ",")[[1]]

# -------------------------------------------------------------------------------------
# Manny
# -------------------------------------------------------------------------------------

manny_names <- c(
  'INSTNM',
  'CITY',
  'STABBR',
  'ZIP',
  'REGION',
  'LOCALE',
  'RELAFFIL',
  'ADM_RATE',
  'UGDS',
  'UGDS_WHITE',
  'UGDS_BLACK',
  'UGDS_HISP',
  'UGDS_ASIAN',
  'UGDS_AIAN',
  'UGDS_NHPI',
  'UGDS_2MOR',
  'UGDS_NRA',
  'UGDS_UNKN')  

# -------------------------------------------------------------------------------------
# Shannon
# -------------------------------------------------------------------------------------

shannon_names <- c("C100_4, 
                    TRANS_4, 
                   ICLEVEL, 
                   UGDS_MEN, 
                   UGDS_WOMEN, 
                   LOAN_EVER, 
                   PELL_EVER, 
                   FEMALE, 
                   MARRIED, 
                   DEPENDENT, 
                   VETERAN, 
                   FIRST_GEN, 
                   PAR_ED_PCT_1STGEN, 
                   PAR_ED_PCT_MS, 
                   PAR_ED_PCT_HS, 
                   PAR_ED_PCT_PS, 
                   MALE_ENRL_4YR_TRANS_YR8_RT, 
                   PELL_COMP_ORIG_YR8_RT, 
                   PELL_COMP_4YR_TRANS_YR8_RT, 
                   PELL_ENRL_4YR_TRANS_YR8_RT, 
                   LOAN_COMP_ORIG_YR8_RT, 
                   LOAN_COMP_4YR_TRANS_YR8_RT, 
                   LOAN_ENRL_ORIG_YR8_RT, 
                   LOAN_ENRL_4YR_TRANS_YR8_RT, 
                   FIRSTGEN_COMP_ORIG_YR8_RT, 
                   FIRSTGEN_COMP_4YR_TRANS_YR8_RT, 
                   FIRSTGEN_ENRL_ORIG_YR8_RT, 
                   FIRSTGEN_ENRL_4YR_TRANS_YR8_RT, 
                   RPY_1YR_RT, 
                   COMPL_RPY_1YR_RT, 
                   LO_INC_RPY_1YR_RT, 
                   MD_INC_RPY_1YR_RT, 
                   HI_INC_RPY_1YR_RT, 
                   DEP_RPY_1YR_RT, 
                   IND_RPY_1YR_RT, 
                   PELL_RPY_1YR_RT, 
                   NOPELL_RPY_1YR_RT, 
                   FEMALE_RPY_1YR_RT, 
                   MALE_RPY_1YR_RT, 
                   FIRSTGEN_RPY_1YR_RT, 
                   NOTFIRSTGEN_RPY_1YR_RT, 
                   RPY_3YR_RT, 
                   COMPL_RPY_3YR_RT, 
                   LO_INC_RPY_3YR_RT, 
                   MD_INC_RPY_3YR_RT, 
                   HI_INC_RPY_3YR_RT, 
                   DEP_RPY_3YR_RT, 
                   IND_RPY_3YR_RT, 
                   PELL_RPY_3YR_RT, 
                   NOPELL_RPY_3YR_RT, 
                   FEMALE_RPY_3YR_RT, 
                   MALE_RPY_3YR_RT, 
                   FIRSTGEN_RPY_3YR_RT, 
                   NOTFIRSTGEN_RPY_3YR_RT, 
                   RPY_5YR_RT, 
                   COMPL_RPY_5YR_RT, 
                   LO_INC_RPY_5YR_RT, 
                   MD_INC_RPY_5YR_RT, 
                   HI_INC_RPY_5YR_RT, 
                   DEP_RPY_5YR_RT, 
                   IND_RPY_5YR_RT, 
                   PELL_RPY_5YR_RT, 
                   NOPELL_RPY_5YR_RT, 
                   FEMALE_RPY_5YR_RT, 
                   MALE_RPY_5YR_RT, 
                   FIRSTGEN_RPY_5YR_RT, 
                   NOTFIRSTGEN_RPY_5YR_RT, 
                   RPY_7YR_RT, 
                   COMPL_RPY_7YR_RT, 
                   LO_INC_RPY_7YR_RT, 
                   MD_INC_RPY_7YR_RT, 
                   HI_INC_RPY_7YR_RT, 
                   DEP_RPY_7YR_RT, 
                   IND_RPY_7YR_RT, 
                   PELL_RPY_7YR_RT, 
                   NOPELL_RPY_7YR_RT, 
                   FEMALE_RPY_7YR_RT, 
                   MALE_RPY_7YR_RT, 
                   FIRSTGEN_RPY_7YR_RT, 
                   NOTFIRSTGEN_RPY_7YR_RT, 
                   INC_PCT_LO, 
                   DEP_STAT_PCT_IND, 
                   DEP_INC_PCT_LO, 
                   IND_INC_PCT_LO, 
                   INC_PCT_M1, 
                   INC_PCT_M2, 
                   INC_PCT_H1, 
                   INC_PCT_H2, 
                   DEP_INC_PCT_M1, 
                   DEP_INC_PCT_M2, 
                   DEP_INC_PCT_H1, 
                   DEP_INC_PCT_H2, 
                   IND_INC_PCT_M1, 
                   IND_INC_PCT_M2, 
                   IND_INC_PCT_H1, 
                   IND_INC_PCT_H2, 
                   GRAD_DEBT_MDN, 
                   LO_INC_DEBT_MDN, 
                   MD_INC_DEBT_MDN, 
                   HI_INC_DEBT_MDN, 
                   DEP_DEBT_MDN, 
                   IND_DEBT_MDN, 
                   PELL_DEBT_MDN, 
                   NOPELL_DEBT_MDN, 
                   FEMALE_DEBT_MDN, 
                   MALE_DEBT_MDN, 
                   FIRSTGEN_DEBT_MDN, 
                   NOTFIRSTGEN_DEBT_MDN, 
                   GRAD_DEBT_MDN10YR, 
                   CUML_DEBT_N, 
                   CUML_DEBT_P90, 
                   CUML_DEBT_P75, 
                   CUML_DEBT_P25, 
                   CUML_DEBT_P10, 
                   FAMINC, 
                   MD_FAMINC, 
                   FAMINC_IND, 
                   LNFAMINC, 
                   LNFAMINC_IND, 
                   PCT_WHITE, 
                   PCT_BLACK, 
                   PCT_ASIAN, 
                   PCT_HISPANIC, 
                   MN_EARN_WNE_P10, 
                   MD_EARN_WNE_P10, 
                   PCT10_EARN_WNE_P10, 
                   PCT25_EARN_WNE_P10, 
                   PCT75_EARN_WNE_P10, 
                   PCT90_EARN_WNE_P10, 
                   SD_EARN_WNE_P10, 
                   GT_25K_P10, 
                   MN_EARN_WNE_INDEP0_P10, 
                   MN_EARN_WNE_INDEP1_P10, 
                   MN_EARN_WNE_MALE0_P10, 
                   MN_EARN_WNE_MALE1_P10, 
                   MN_EARN_WNE_P6, 
                   MD_EARN_WNE_P6, 
                   PCT10_EARN_WNE_P6, 
                   PCT25_EARN_WNE_P6, 
                   PCT75_EARN_WNE_P6, 
                   PCT90_EARN_WNE_P6, 
                   SD_EARN_WNE_P6, 
                   GT_25K_P6, 
                   MN_EARN_WNE_INDEP0_P6, 
                   MN_EARN_WNE_INDEP1_P6, 
                   MN_EARN_WNE_MALE0_P6, 
                   MN_EARN_WNE_MALE1_P6, 
                   MN_EARN_WNE_P7, 
                   SD_EARN_WNE_P7, 
                   GT_25K_P7, 
                   COUNT_NWNE_P8, 
                   COUNT_WNE_P8, 
                   MN_EARN_WNE_P8, 
                   MD_EARN_WNE_P8, 
                   PCT10_EARN_WNE_P8, 
                   PCT25_EARN_WNE_P8, 
                   PCT75_EARN_WNE_P8, 
                   PCT90_EARN_WNE_P8, 
                   SD_EARN_WNE_P8, 
                   GT_25K_P8, 
                   MN_EARN_WNE_P9, 
                   SD_EARN_WNE_P9, 
                   GT_25K_P9"
)

# -------------------------------------------------------------------------------------
# fix formatting
# -------------------------------------------------------------------------------------
shannon_names <- strsplit(shannon_names, ", \n")[[1]]
shannon_names <- stripWhitespace(shannon_names)
shannon_names[2:length(shannon_names)] <- gsub(" ", "", shannon_names[2:length(shannon_names)])
miscellaneous <- c("CONTROL", "NPT4_PUB", "NPT4_PRIV", "NUM4_PUB", "NUM4_PRIV", "COSTT4_P", "COSTT4_A")
shannon_names <- c(shannon_names, miscellaneous)


all_names <- c(jared_names,manny_names, shannon_names, nura_names)
all_names <- unique(all_names)

in_all_names <- which(colnames(dat) %in% all_names)

# -------------------------------------------------------------------------------------
# data frame that has all our selected column names
# -------------------------------------------------------------------------------------
dat <- dat[,in_all_names]

# =====================================================================================
# finding null and privacy counts: remove those that are too much
# =====================================================================================

# -------------------------------------------------------------------------------------
# functions to count NULL and PrivacySuppressed entries
# -------------------------------------------------------------------------------------
null_counts <- apply(dat, 2, function(x) sum(x=="NULL"))
privacy_counts <- apply(dat, 2, function(x) sum(x=="PrivacySuppressed"))
total_counts <- null_counts + privacy_counts

# -------------------------------------------------------------------------------------
# selecting variables that do not contain majority NULL/PrivacySuppressed values
# -------------------------------------------------------------------------------------
good_vars <- colnames(dat)[total_counts < 3500]; good_vars <- unique(good_vars)

# -------------------------------------------------------------------------------------
# keeping data with only 'good' vars
# -------------------------------------------------------------------------------------
dat <- dat[,good_vars]

# =====================================================================================
# append the RANK column
# =====================================================================================

load("../../data/ranked_universities.RData")
dat[,"RANKED"] <- rank_bool


# =====================================================================================
# append the RANK column
# =====================================================================================

write.csv(dat, "../../data/2014-15-clean-data.csv")



