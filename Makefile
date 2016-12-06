# Declare phony target
.PHONY: data analysis apps scrape-rankings data-preprocessing rename-missing-schools lasso-rankings calculate-best-value eda report slides clean session xgboost-shiny-app pca-shiny-app

# all	
all: analysis report slides apps 





# Download our raw dataset
data : 
	cd $@; curl -LOk https://ed-public-download.apps.cloud.gov/downloads/CollegeScorecard_Raw_Data.zip
	cd $@; unzip CollegeScorecard_Raw_Data.zip
	cd $@; rm Crosswalks_20160908.zip 
	cd $@; rm MERGED1996_97_PP.csv
	cd $@; rm MERGED1997_98_PP.csv
	cd $@; rm MERGED1998_99_PP.csv 
	cd $@; rm MERGED1999_00_PP.csv
	cd $@; rm MERGED2000_01_PP.csv
	cd $@; rm MERGED2001_02_PP.csv
	cd $@; rm MERGED2002_03_PP.csv
	cd $@; rm MERGED2003_04_PP.csv
	cd $@; rm MERGED2004_05_PP.csv
	cd $@; rm MERGED2005_06_PP.csv 
	cd $@; rm MERGED2006_07_PP.csv 
	cd $@; rm MERGED2007_08_PP.csv
	cd $@; rm MERGED2008_09_PP.csv
	cd $@; rm MERGED2009_10_PP.csv
	cd $@; rm MERGED2010_11_PP.csv 
	cd $@; rm MERGED2011_12_PP.csv
	cd $@; rm MERGED2012_13_PP.csv 
	cd $@; rm MERGED2013_14_PP.csv 
	cd $@; rm CollegeScorecard_Raw_Data.zip 





analysis: 
	make scrape-rankings
	make data-preprocessing
	make lasso-rankings
	make calculate-best-value
	make eda
	make xgboost





# Scrape school ranking data from the Washington Post
scrape-rankings: 
	cd code/scripts; Rscript -e 'source("scrape-rankings.R")'

# Select columns relevant to our project objectives and append scraped Washinton Post data
data-preprocessing: 
	cd code/scripts; Rscript -e 'source("data-preprocessing.R")'

# Execute LASSO regression to identify variables of importance
lasso-rankings: 
	cd code/scripts; Rscript -e 'source("lasso-rankings.R")'

# Calculate best value scores for each school based on data from LASSO analysis and append to our dataset
calculate-best-value: 
	cd code/scripts; Rscript -e 'source("calculate-best-value.R")'

# Execute exploratory data analysis
eda:
	cd code/scripts; Rscript -e 'source("eda.R")'

# Execute XGBOOST analysis
xgboost: 
	cd code/scripts; Rscript -e 'source("xgboost.R")'





# Compile report.pdf file
report:
	cd $@; Rscript -e "library(knitr); knit2pdf('report.rnw', output = 'report.tex')"

# Generate slides.html file
slides:
	cd slides; pandoc slides.md -s -o slides.pdf

# Clean output file
clean:
	cd report; rm -f report.pdf
	cd report; rm -f report.aux
	cd report; rm -f report.log
	cd report; rm -f report.tex





# Generate session information text file
session:
	bash session.sh





apps:
	make xgboost-shiny-app
	make pca-shiny-app



# Deploy XGBOOST app
xgboost-shiny-app:
	cd shiny-apps; Rscript -e "library(methods); shiny::runApp('xgboost-shiny-app.R', launch.browser = TRUE)"
# Press Ctrl + C to stop the app from "listening"



# Deploy PCA app
pca-shiny-app:
	cd shiny-apps; Rscript -e "library(methods); shiny::runApp('pca-shiny-app.R', launch.browser = TRUE)"
# Press Ctrl + C to stop the app from "listening"