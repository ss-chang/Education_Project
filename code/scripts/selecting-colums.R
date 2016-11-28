# =====================================================================================
# title: selecting-columns.R
# author: Nura Kawa
# summary: select columns to use, get rid of those with too many nulls
# =====================================================================================


# =====================================================================================
# column selection: Nura
# =====================================================================================

# select your file
my_file <- "../MERGED2014_15_PP.csv"

# read in your file
dat <- read.csv(my_file, row.names = 1)

# nura's columns to look at: 1000 to 1500
nura_dat <- dat[,1000:1500]

# select columns with these names: 
pattern <- c("BLACK", "ASIAN", "PELL", "INCOME", "LO", "FIRSTGEN")

# select matches
matches <- unique(grep(paste(pattern,collapse="|"),
                       colnames(nura_dat),
                       value = TRUE))

# now remove things that you do not need
to_remove <- c("DEATH", "TRANS", "UNKN")#, "NOPELL", "NOLOAN", "NOTFIRSTGEN")                  


remove <- unique(grep(paste(to_remove,collapse="|"),
                       matches,
                       value = FALSE))

# finally, remove the unwanted columns
matches <- matches[-remove]           

nura_names <- matches
# keeping matched columns
#rm(nura_dat)
#dat <- dat[,matches]

print(dim(dat))

# =====================================================================================
# column selection: Jared
# =====================================================================================

jared_names <- "ICLEVEL,PREDDEG,CCBASIC,CCUGPROF,CCSIZSET,HBCU,PBI,ANNHI,TRIBAL,AANAPII,HSI,NANTI,AVGFACSAL,INEXPFTE,ADM_RATE,ADM_RATE_ALL,COSTT4_A,COSTT4_P,TUITIONFEE_IN,TUITIONFEE_OUT,TUITIONFEE_PROG,UGDS,UGDS_MEN,UGDS_WOMEN,UGDS_WHITE,UGDS_BLACK,UGDS_HISP,UGDS_ASIAN,UGDS_AIAN,UGDS_NHPI,UGDS_NRA,UGDS_UNKN,PPTUG_EF,PPTUG_EF2,INC_PCT_LO,INC_PCT_M1,INC_PCT_M2,INC_PCT_H1,INC_PCT_H2,RET_FT4,RET_PT4,PAR_ED_PCT_1STGEN,PAR_ED_PCT_MS,PAR_ED_PCT_HS,PAR_ED_PCT_PS,MARRIED,VETERAN,DEPENDENT,FIRST_GEN,FAMINC,MD_FAMINC,FAMINC_IND,PCT_WHITE,PCT_BLACK,PCT_ASIAN,PCT_HISPANIC,PCT_BORN_US,POVERTY_RATE,MEDIAN_HH_INC,UNEMP_RATE,PCTFLOAN,PCTPELL,DEBT_MDN,GRAD_DEBT_MDN,WDRAW_DEBT_MDN,LO_INC_DEBT_MDN,MD_INC_DEBT_MDN,HI_INC_DEBT_MDN,DEP_DEBT_MDN,IND_DEBT_MDN,PELL_DEBT_MDN,NOPELL_DEBT_MDN,GRAD_DEBT_MDN_SUPP,GRAD_DEBT_MDN10YR_SUPP,PCTFLOAN"

jared_names <- strsplit(jared_names, ",")[[1]]

# =====================================================================================
# column selection: Manny
# =====================================================================================

manny_names <- c(
  'INSTNM',
  'ï..UNITID',
  'CITY',
  'STABBR',
  'ZIP',
  'REGION',
  'LOCALE',
  'RELAFFIL',
  'ADM_RATE',
  'PCIP01',
  'PCIP03',
  'PCIP04',
  'PCIP05',
  'PCIP09',
  'PCIP10',
  'PCIP11',
  'PCIP12',
  'PCIP13',
  'PCIP14',
  'PCIP15',
  'PCIP16',
  'PCIP19',
  'PCIP22',
  'PCIP23',
  'PCIP24',
  'PCIP25',
  'PCIP26',
  'PCIP27',
  'PCIP29',
  'PCIP30',
  'PCIP31',
  'PCIP38',
  'PCIP39',
  'PCIP40',
  'PCIP41',
  'PCIP42',
  'PCIP43',
  'PCIP44',
  'PCIP45',
  'PCIP46',
  'PCIP47',
  'PCIP48',
  'PCIP49',
  'PCIP50',
  'PCIP51',
  'PCIP52',
  'PCIP54',
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


# =====================================================================================
# column selection: Shannon
# =====================================================================================

shannon <- read.csv("../shannon_variables.csv", row.names=1, stringsAsFactors = F)
shannon <- shannon$x

# =====================================================================================
# column selection: miscellaneous
# =====================================================================================

miscellaneous <- c("CONTROL", "NPT4_PUB", "NPT4_PRIV", "NUM4_PUB", "NUM4_PRIV", "COSTT4_P", "COSTT4_A")


shannon_names <- c(shannon, miscellaneous)
# =====================================================================================
# all columns!
# =====================================================================================


all_names <- c(jared_names,manny_names, shannon_names, nura_names)
all_names <- unique(all_names)

in_all_names <- which(colnames(dat) %in% all_names)
dat <- dat[,in_all_names]

dim(dat)

# finding null and privacy counts: remove those that are too much
null_counts <- apply(dat, 2, function(x) sum(x=="NULL"))
privacy_counts <- apply(dat, 2, function(x) sum(x=="PrivacySuppressed"))
total_counts <- null_counts + privacy_counts

# keep the ones that are good
good_vars <- colnames(dat)[total_counts < 3500]

good_vars <- unique(good_vars)


dat <- dat[,good_vars]

write.csv(dat, "data/2014-15-clean-data.csv")


source("rename_missing_schools.R")
