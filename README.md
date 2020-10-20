# Geographic Variation in High-Priority Listing Status under the New Heart Allocation Policy
The data preparation and analysis code for Geographic Variation in High-Priority Listing Status under the New Heart Allocation Policy by Ran et al.

Data source was the Q1 2020 Scientific Registry of Transplant Recipients(SRTR) Standard Analysis Files (SAF), https://www.srtr.org/requesting-srtr-data/about-srtr-standard-analysis-files/

## Data Preparation
The data preparation file creates a dataset with information on initial listing status, treatment, hemodynamic measures, listing outcome (transplanted or not), other candidate characteristics, and transplant center characteristics for all adult, heart-only transplant candidates between Dec.2016 - Feb. 2020. 

## Data Analysis
Part 1 of data analysis file fits a mixed-effect logistic regression model to obtain Empirical Bayes estimates for the expected and observed probability of high-priority status listing at each transplant center. Case-mix adjustment and bootstrapping are applied according to the Center for Medicare and Medicaid Services methodology. 

Part 2 of data analysis fits three mixed-effect logisitic regression models to examine the confounding and/or modification by candidate characteristics and transplant center characteristics. 

Variable_Coding transforms explanatory variables to their appropriate form or analysis. 

## Data Presentation

"generate_table" is used to obtain all the statistics presented in Table 1.

"generate_figures_final" is used to generate all of the figures included in the body of the manuscript and the supplement. 

"results" and "rate_ratios" are used to generate statistics reported in the result section of the manuscript.

The statistical appendix contains detailed methodology.
