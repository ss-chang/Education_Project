# Education_Project

## Synopsis
 This project answer the following questions: 
 1. With respect to quality and cost of education, which universities are best-suited for minority students? 
 2. How do these universities compare to “elite” (globally top-ranked) universities? Do elite universities cater to the needs of minority students?

## License:
<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.


## File Structure  

Education_Project/  
+   README.md  
+   Makefile  
+   LICENSE  
+   session-info.txt  
+	session.sh  
+	session-info.R    
+   .gitignore  
+   code/  
	+ README.md  
	+ scripts/  
		+ calculate-best-value.R   
		+ data-preprocessing.R  
		+ xgboost-script.R  
		+ lasso-rankings.R 
		+ eda.R  
		+ scrape-rankings.R  
+   data/  
	+ README.md  
	+ 2014-15-clean-data.csv  
	+ MERGED2014_15_PP.csv  
	+ complete-data.csv  
	+ lasso-coeffs.RData  
	+ lasso-ranked-coeffs.RData  
	+ ranked-universities.RData  
	+ weights.RData  
	+ top-ten.RData  
	+ xgb-model.RData  
+   images/  
	+ README.md  
	+ eda/  
		+ autoplot.pdf    
		+ autoplot.png    
		+ boxplots-minority-percentage-by-value-quartiles.pdf  
		+ boxplots-minority-percentage-by-value-quartiles.png  
		+ boxplots-school-value-minority-Count-per-region.pdf  
		+ boxplots-school-value-minority-Count-per-region.png  
		+ corrplot-eda.pdf  
		+ corrplot-eda.png  
		+ feature-plot.pdf  
		+ feature-plot.png  
		+ ggdendrogram.pdf  
		+ ggdendrogram.png  
		+ hist-above-median-minorities.pdf  
		+ hist-above-median-minorities.png  
		+ hist-best-value.pdf  
		+ hist-best-value.png  
		+ hist-quality-index.pdf  
		+ hist-quality-index.png  
		+ pca-enrollment-rate-minority.pdf  
		+ pca-enrollment-rate-minority.png  
		+ pca-quality.pdf  
		+ pca-quality.png  
		+ phylo-fan.pdf  
		+ phylo-fan.png  
		+ phylo-unrooted.pdf  
		+ phylo-unrooted.png  
		+ scree-plot.pdf  
		+ scree-plot.png  
		+ tsne-above-median-minorities.pdf  
		+ tsne-above-median-minorities.png  
		+ tsne-quality-index.pdf  
		+ tsne-quality-index.png  
	+ pca/  
		+ feature-plot.pdf  
		+ feature-plot.png  
		+ pca-enrollment-rate-minority.pdf  
		+ pca-enrollment-rate-minority.png  
		+ pca-best-value.pdf  
		+ pca-best-value.png  
		+ scree-plot.pdf  
		+ scree-plot.png  
		+ tsne-above-median-minorities.pdf  
		+ tsne-above-median-minorities.png  
		+ tsne-best-value.pdf  
		+ tsne-best-value.png  
	+ xgboost/  
		+ best-features.pdf  
		+ best-features.png  
		+ best-features-cumsum.pdf  
		+ best-features-cumsum.png  
		+ feature-importance.pdf  
		+ feature-importance.png  
		+ optimized-feature-importance.pdf  
		+ optimized-feature-importance.png  	
+   report/  
	+ report.pdf  
	+ report.rnw
	+ report.aux

+ slides/  
	+ slides.md
	+ slides.pdf
	+ slides.Rpres

## Authors  

* Jared Wilber
* Nura Kawa
* Shannon Chang
* Manuel Horta

## Installation  

* Use a computer with R and bash installed  
* Clone this repository into your directory of choice  


## Usage  

* Check the session-info.txt file to make sure you have the relevant packages  
* Run the Makefile as you see fit to re-implement what you want  

## Make commands  

#####Declare phony target
.PHONY: data analysis apps scrape-rankings data-preprocessing rename-missing-schools lasso-rankings calculate-best-value eda report slides clean session xgboost-shiny-app pca-shiny-app  
   
#####all	 
all: analysis report slides apps  
  
  
  
  
  
#####Download our raw dataset  
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





#####Scrape school ranking data from the Washington Post   
scrape-rankings:    
	cd code/scripts; Rscript -e 'source("scrape-rankings.R")'  
    
#####Select columns relevant to our project objectives and append scraped Washinton Post data  
data-preprocessing:   
	cd code/scripts; Rscript -e 'source("data-preprocessing.R")'  
  
#####Execute LASSO regression to identify variables of importance  
lasso-rankings:   
	cd code/scripts; Rscript -e 'source("lasso-rankings.R")'  
  
#####Calculate best value scores for each school based on data from LASSO analysis and append to our dataset  
calculate-best-value:   
	cd code/scripts; Rscript -e 'source("calculate-best-value.R")'  
  
#####Execute exploratory data analysis  
eda:
	cd code/scripts; Rscript -e 'source("eda.R")'  
  
#####Execute XGBOOST analysis  
xgboost:   
	cd code/scripts; Rscript -e 'source("xgboost.R")'  
   
    
   
  
  
#####Compile report.pdf file
report:
	cd $@; Rscript -e "library(knitr); knit2pdf('report.rnw', output = 'report.tex')"
  
#####Generate slides.html file  
slides:  
	cd slides; pandoc slides.md -s -o slides.pdf  
   
#####Clean output file  
clean:   
	cd report; rm -f report.pdf  
	cd report; rm -f report.aux  
	cd report; rm -f report.log  
	cd report; rm -f report.tex  
  
  
  
  
  
#####Generate session information text file
session:  
	bash session.sh  
  
  
  
  
  
apps:  
	make xgboost-shiny-app  
	make pca-shiny-app  
  

  
#####Deploy XGBOOST app  
xgboost-shiny-app:  
	cd shiny-apps; Rscript -e "library(methods); shiny::runApp('xgboost-shiny-app.R', launch.browser = TRUE)"  
#####Press Ctrl + C to stop the app from "listening"  
  
  
  
#####Deploy PCA app  
pca-shiny-app:  
	cd shiny-apps; Rscript -e "library(methods); shiny::runApp('pca-shiny-app.R', launch.browser = TRUE)"  
# Press Ctrl + C to stop the app from "listening"    
	 
##Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D


## License

#### Software License

MIT (see License file)

#### Creative Commons License

The following license is for all media.   
<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.  
  
