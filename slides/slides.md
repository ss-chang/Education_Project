Education Project
========================================================
Shannon Chang - Economics with minor in English  
Jared Wilber - Gender and Women Studies   
Nura Kawa - Statistics  
Manuel Horta - Statistics  

December 8, 2016    

Problem Statement
========================================================
Our client is a non-profit NGO with an interest in minority success. Primarily, they'd like to identify schools that underserve minorities so that they can donate money to those schools to create more effective minority-targeting. They don't want their money to go to waste, so they'd like to target the best schools they can. We help in two ways:   

-First, we provide a method for identifying those schools which underserve minorities.   
-Second, we define a data-driven metric value metric that can be used to rank the schools.  

Introduction
========================================================
These data are provided through federal reporting from institutions, data on federal financial aid, and
tax information
To help the NGO, we'll need data. We're utilizing data from [college scorecard](https://collegescorecard.ed.gov/data/). This dataset provides federally reported information about the institutions. We'll utilize this data to help an NGO achieve the following objective: determine whether a given university underserves minorities. By underserves, we mean has less than the US median percentage of minorities enrolled. If yes, determine the value the school has. This value is created by us, and will be discussed in detail later.



========================================================
In this manner, the NGO can employ us in the following 2 ways:  

- Given a school, predict whether or not it will underserve or overserves minorities.   
- Given multiple minority serving schools, determine which should receive funding.   


We realize the first goal with our created metric.  
We realize the second goal with a gradient-boosted tree classifier. This classifier will take in some features and output a   binary label: whether or not a school underserves or adequately serves minorities  


Data
========================================================
As stated previously, the data is freely available at [college scorecard](https://collegescorecard.ed.gov/data/). The data contains multiple datasets, corresponding to different years.
Because of fluctuations regarding data completion (i.e. some datasets are more sparse than others), we opted to use the most recent dataset, as it was relatively dense. Furthermore, this dataset is more likely to reflect present day. The dataset lives in very high-dimensions (roughly 1,800 features), so our first order of business was to reduce dimensions. Data-reduction is important because it allows for more interpretable results,and it's crucial that our NGO understand our methods.

Data cont.
========================================================
We also took efforts to clean the data, such as imputing NA values and "PrivacySuppressed" values. We also removed columns which were over 50 percent sparse, as these are essentially useless.. This resulted in a much sparser dataset, but one that still had a couple hundred of features (about 500 to be exact). Further dimensionality-reduction efforts are discussed later, with particular emphasis given to interpretability.


Data cont.
========================================================
Because our goal is to identify minority serving schools, we need some feature to reflect minority enrollment. This metric was created as follows:

[ discuss minority metric]

To determine whether or not a school underserves or adequately serves minorities, we compared the above metric to the corresponding  percantage of minorities in the US, via data we found online from [insert legitimate source]

We also create a metric by which to rank universities. This is discussed in more detail in the analysis section.


Data cont.
========================================================


From a high-level, the entire data-munging is as follows:  

1. Hand-select important features from data. This yielded about 500 variables.  
2. Handle unruly data (e.g. NA values, NULL values, etc.)  
3. Create our own variables: minority, ranked, and bestvalue  
4. Subset data based on gradient boosted tree importance  


Conclusion
========================================================