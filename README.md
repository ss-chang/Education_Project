# Education_Project

## Synopsis
 This project answer the following questions: 
 1. With respect to quality and cost of education, which universities are best-suited for minority students? 
 2. How do these universities compare to “elite” (globally top-ranked) universities? Do elite universities cater to the needs of minority students?



## File Structure  

Education_Projectf/  
+   README.md  
+   Makefile  
+   LICENSE  
+   session-info.txt  
+   .gitignore  
+   code/  
	+ README.md  
	+ functions/  
	+ scripts/  
		+ data-preprocess.R  	 
	+ tests/  
+   data/  
	+ README.md    
+   images/  
	+ README.md   
+   report/  
	+ report.pdf  
	+ report.Rmd  
	+ sections/  
		+ 00-abstract.Rmd  
		+ 01-introduction.Rmd  
		+ 02-data.Rmd  
		+ 03-methods.Rmd  
		+ 04-analysis.Rmd  
		+ 05-results.Rmd  
		+ 06-conclusions.Rmd  
   + slides/  

## Authors  

* Jared Wilber
* Nura Kawa
* Shannon Chang
* Manuel Horta

## Installation

[to do]


## Usage

[to do]

## Make commands  

[to do - below is from previous project]
 
.PHONY: all eda regression session tests report clean data   

eda:  
&nbsp;&nbsp;&nbsp;&nbsp;Rscript -e 'source("code/scripts/eda.R")'    

regression:  
&nbsp;&nbsp;&nbsp;&nbsp;	make ols  
&nbsp;&nbsp;&nbsp;&nbsp;	make ridge  
&nbsp;&nbsp;&nbsp;&nbsp;	make lasso  
&nbsp;&nbsp;&nbsp;&nbsp;	make pcr  
&nbsp;&nbsp;&nbsp;&nbsp;	make plsr  

tests:  
&nbsp;&nbsp;&nbsp;&nbsp;	Rscript -e 'source("code/tests/test-regressions.R")'  

session:   
&nbsp;&nbsp;&nbsp;&nbsp;	bash session.sh  
	

clean:  
&nbsp;&nbsp;&nbsp;&nbsp;	rm -f report/report.pdf  
	
data:  
&nbsp;&nbsp;&nbsp;&nbsp;	curl -o data/Credit.csv http://www-bcf.usc.edu/~gareth/ISL/Credit.csv  
	 
## Contributing

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
  
