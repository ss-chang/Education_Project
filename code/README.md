#This folder contains the following folders and R scripts:

##scripts/ 


**scrape-rankings.R**

Description: Find schools from Washington Post school rankings data that we were not 
able to match with our dataset and rename schools that do exist in our 
main dataset, but were not matched because of slight differences in name
re-name schools where data was confused.  
This is the first script to be run.

**data-preprocessing.R**
     
Description: Selecting columns for use.  
This is the second script to be run. 
     
**lasso-rankings.R**
 
Description: LASSO analysis to determine which variables are important amongst our dataset.  
This is the third script to be run.  
     
**calculate-best-value.R**
Description: Calculate best value scores for each school based on data from LASSO analysis and append to our dataset.  
This is the fourth script to be run.  

**eda.R**
Description: Execute exploratory data analysis.  
This is the fifth script to be run. 
     
**xgboost.R**
Description: Execute XGBOOST analysis to further identify which of the variables selected through LASSO regression are most important to our objectives for minority students.  
This is the sixth script to be run. 


