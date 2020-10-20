//*Title: Regressional Analysis for Geographical Variations in Adapting to New Heart Allocation Policy *//
//*Authors: Julia Ran, William Parker*//
/*Part 2*/
*put empty model, candidate model, and policyXcompetition models side by side

*0. Data preparation
clear
cd "C:\Users\julia\Google Drive\Pritzker\SRP\Codes\data_codes"
import delimited "C:\Users\julia\Google Drive\Pritzker\SRP\Codes\SAF SAS files\final_sample.csv"
do variable_coding
replace policy_factor = 0 if policy_factor ==1
replace policy_factor = 1 if policy_factor ==2

label define policy_factor_new 0 "Pre" 1 "Post" 
label values policy_factor policy_factor_new

*mixed effect poisson mean test
bysort policy_factor ctr_cd: gen count = _N

mepoisson count policy_factor || ctr_cd: 

mepoisson count policy_factor || ctr_cd: , vce(robust)
**3. Use transplant volume as a transplant center characteristic (ctr_tx_vol, ctr_s1_tx_prop, ctr_s2_tx_prop)

*1. Empty model
meologit high_status policy_factor || ctr_cd: policy_factor, covariance(unstructured) 
outreg2 using myfile1, replace
estimates store m1, title(Model 1)
regsave using results1, tstat pval ci replace
use results1, replace
asdoc list, save(Table_1.doc) title(Model 1. Multilevel logistic regression results for outcome of high-priority status listing with only policy variable) replace

*2. Candidate model
clear
cd "C:\Users\julia\Google Drive\Pritzker\SRP\Codes\data_codes"
import delimited "C:\Users\julia\Google Drive\Pritzker\SRP\Codes\SAF SAS files\final_sample.csv"
do variable_coding
replace policy_factor = 0 if policy_factor ==1
replace policy_factor = 1 if policy_factor ==2

label define policy_factor_new 0 "Pre" 1 "Post" 
label values policy_factor policy_factor_new

melogit high_status policy_factor ib1.WGT_factor ib1.HGT_factor centered_age ib4.race_factor ib2.smoking_factor ib2.work_factor ib1.edu_factor ib2.BMI_factor ib1.blood_type_factor ib1.diag_factor ib1.egfr_factor ib2.diab_factor ib3.fs_factor ib1.ci_factor ib2.pcwp_factor  ib4.payor_factor|| ctr_cd: policy_factor, covariance(unstructured) 
regsave using results2, tstat pval ci replace
use results2, replace
asdoc list, save(Table_1.doc) title(Model 2. Multilevel logistic regression results for outcome of high-priority status listing with policy period variable and candidate level variables) append

estimates store m2, title(Model 2)


*3. Policy and OPO-level Variable - Proportion of Transplant in Status 1A (quartiles), total TX volume, and >3 opos in a center

**3.1 proportion TX in Status 1A
clear
cd "C:\Users\julia\Google Drive\Pritzker\SRP\Codes\data_codes"
import delimited "C:\Users\julia\Google Drive\Pritzker\SRP\Codes\SAF SAS files\final_sample.csv"
do variable_coding
replace policy_factor = 0 if policy_factor ==1
replace policy_factor = 1 if policy_factor ==2

label define policy_factor_new 0 "Pre" 1 "Post" 
label values policy_factor policy_factor_new

egen s1a_factor = group(status_1a)
replace s1a_factor = 0 if s1a_factor ==1 /*pre-policy candidate listed in NOT status 1a*/
replace s1a_factor = 1 if s1a_factor ==2 /*pre-policy candidate listed in status 1a*/

egen tx_factor = group(transplanted)
replace tx_factor = 0 if tx_factor ==1 /*not transplanted*/
replace tx_factor =1 if tx_factor ==2 /*transplanted*/

gen tx_s1a = .
replace tx_s1a = 1 if tx_factor ==1 & s1a_factor ==1
replace tx_s1a = 0 if missing(tx_s1a)

egen N_s1a = sum(s1a_factor), by(ctr_cd policy_factor) /*number of status 1a at each center*/
egen N_tx_s1a = sum(tx_s1a), by(ctr_cd policy_factor) /*number of transplanted status 1a at each center*/

egen N_opo_s1a = sum(s1a_factor), by(served_opo_cd policy_factor) /*number of status 1a at each center*/
egen N_opo_tx_s1a = sum(tx_s1a), by(served_opo_cd policy_factor) /*number of transplanted status 1a at each center*/

gen prop_tx_s1a_opo = N_opo_tx_s1a/N_opo_s1a
egen prop_tx_s1a1_opo = max(prop_tx_s1a_opo), by(served_opo_cd)
summarize prop_tx_s1a1_opo if prop_tx_s1a1 !=0


xtile tx_s1a_opo_quartile = prop_tx_s1a1_opo, n(4)
egen tx_s1a_quartile_f_opo= group(tx_s1a_opo_quartile)
gen tx_s1a_opo_q2 = .
gen tx_s1a_opo_q3 = .
gen tx_s1a_opo_q4 = .

replace tx_s1a_opo_q2 = 1 if tx_s1a_quartile_f_opo ==2
replace tx_s1a_opo_q2 = 0 if missing(tx_s1a_opo_q2)

replace tx_s1a_opo_q3 = 1 if tx_s1a_quartile_f_opo ==3
replace tx_s1a_opo_q3 = 0 if missing(tx_s1a_opo_q3)

replace tx_s1a_opo_q4 = 1 if tx_s1a_quartile_f_opo ==4
replace tx_s1a_opo_q4 = 0 if missing(tx_s1a_opo_q4)

gen pol_opo_q2 = policy_factor*tx_s1a_opo_q2
gen pol_opo_q3 = policy_factor*tx_s1a_opo_q3
gen pol_opo_q4 = policy_factor*tx_s1a_opo_q4

**3.1 tx volume at each center*/

by ctr_cd policy_factor, sort: generate tolist = (_n==1)

egen ctr_tx_vol = sum(tx_factor), by(ctr_cd policy_factor)
summarize ctr_tx_vol, meanonly
gen ctr_tx_vol_c= ctr_tx_vol - r(mean) /*centering tx volume, time dependent*/

gen ctr_tx_vol1 = ctr_tx_vol 
replace ctr_tx_vol1 = . if policy_factor ==1
egen ctr_tx_vol2 = max(ctr_tx_vol1), by(ctr_cd) /*pre-policy transplant volume*/

summarize ctr_tx_vol2, meanonly
gen ctr_tx_vol_pre_c= ctr_tx_vol2 - r(mean) /*centered pre-policy volume*/

gen ctr_tx_vol3 = ctr_tx_vol 
replace ctr_tx_vol3 = . if policy_factor ==0
egen ctr_tx_vol4 = max(ctr_tx_vol3), by(ctr_cd) /*post-policy transplant volume*/

summarize ctr_tx_vol4, meanonly
gen ctr_tx_vol_post_c= ctr_tx_vol4 - r(mean) /*centered pre-policy volume*/

gen pol_tx_pre = policy_factor * ctr_tx_vol_pre_c


***3.1.1 change in transplant volume between policy periods
gen delta_tx  = ctr_tx_vol4 - ctr_tx_vol2

list ctr_cd ctr_tx_vol4 ctr_tx_vol2 delta_tx if tolist

**3.2 number of ctr in OPO-level
gen comp = .
replace comp = 1 if ctr_ct_in_opo>=3
replace comp = 0 if ctr_ct_in_opo<3
gen pol_comp = policy_factor*comp


melogit high_status policy_factor ib1.WGT_factor ib1.HGT_factor pol_opo_q2 pol_opo_q3 pol_opo_q4 ctr_tx_vol_c delta_tx pol_tx_pre pol_comp centered_age ib4.race_factor ib2.smoking_factor ib2.work_factor ib1.edu_factor ib2.BMI_factor ib1.blood_type_factor ib1.diag_factor ib1.egfr_factor ib2.diab_factor ib3.fs_factor ib1.ci_factor ib2.pcwp_factor  ib4.payor_factor|| ctr_cd: policy_factor, covariance(unstructured)


estimates store m3, title(Model 3)
lincom policy_factor + pol_opo_q2, or
estadd scalar skal2 r(estimate)

lincom policy_factor + pol_opo_q3, or
estadd scalar skal3 r(estimate)

lincom policy_factor + pol_opo_q4, or
estadd scalar skal4 r(estimate)

lincom policy_factor + pol_tx_pre, or
estadd scalar pol_tx_com r(estimate)

lincom policy_factor + pol_comp, or
estadd scalar pol_comp_com r(estimate)


regsave using results3, tstat pval ci replace
use results3, replace
asdoc list, save(Table_1.doc) append title(Model 3. Multilevel logistic regression results for outcome of high-priority status listing with policy period variable, candidate level variables, and transplant center level variables)

	 