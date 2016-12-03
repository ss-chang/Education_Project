library(ggplot2)
library(glmnet)
library(tm)
library(dplyr)
library(XML)
library(httr)
library(shiny)


sink("../../session-info.txt")
'R version'
cat("Session Information")
print(sessionInfo())
devtools::session_info()
sink(NULL)