//*Title: Regressional Analysis for Geographical Variations in Adapting to New Heart Allocation Policy *//
//*Authors: Julia Ran, William Parker*//
/*Part 1*/

clear
cd "C:\Users\julia\SRP\SRP\Codes\data_codes"
import delimited "C:\Users\julia\SRP\SRP\Codes\SAF SAS files\final_sample.csv"
do variable_coding

replace policy_factor = 0 if policy_factor ==1
replace policy_factor = 1 if policy_factor ==2

label define policy_factor_new 0 "Pre" 1 "Post" 
label values policy_factor policy_factor_new

gen except_high = cond((status == "Status 2" | status == "Status 1" | status_1a == "T" ) & treatment == "Exception", 1, 0)


tab except_high policy_factor, matcell(policy_matrix)

cap drop unadj_*
global unadj_pre = policy_matrix[2,1]/(policy_matrix[2,1] + policy_matrix[1,1])

global unadj_post = policy_matrix[2,2]/(policy_matrix[2,2] + policy_matrix[1,2])

melogit except_high policy_factor centered_age ib1.ci_factor ib1.egfr_factor ib2.pcwp_factor ib2.BMI_factor ib4.race_factor ib2.smoking_factor ib2.work_factor ib1.edu_factor ib1.diag_factor ib2.diab_factor ib3.fs_factor ib4.payor_factor|| ctr_cd: policy_factor, covariance(unstructured) or
estimates save exception_output, replace
matrix B = e(b) 

preserve
predict xb_predicted, fitted
predict xb_expected, xb
predict u1 u0, remeans reses(se_u1 se_u0)
export delimited ctr_cd policy_factor except_high u0 u1 xb_predicted xb_expected using "exception_output1.csv", replace


restore

cap program drop my_xtboot
program my_xtboot
	
	args iteration
	
	preserve
	
	*select random hospitals with replacement
	bsample, cluster(ctr_cd) idcluster(id)

	*select random patients with replacement within hospitals
	bsample, strata(id)
	
	melogit except_high policy_factor centered_age ib1.ci_factor ib1.egfr_factor  ib2.pcwp_factor ib2.BMI_factor ib4.race_factor ib2.smoking_factor ib2.work_factor ib1.edu_factor ib1.diag_factor ib2.diab_factor ib3.fs_factor ib4.payor_factor|| id: policy_factor, covariance(unstructured) from(B, skip)  iterate(15)

	* if the model converged, export the CMS adjusted rates
	if e(converged) == 1{
		
		predict p
		predict e, conditional(fixedonly)

		collapse (sum) p (sum) e, by(ctr_cd policy_factor) 

		cap drop o_e
		gen o_e = p/e

		cap drop adj_rate
		gen adjusted_rate = o_e*$unadj_pre if policy_factor == 0
		replace adjusted_rate = o_e*$unadj_post if policy_factor == 1
		
		export delimited ctr_cd policy_factor adjusted_rate using "C:\Users\julia\SRP\SRP\Codes\data_codes\bootstrap_exp/result_`iteration'.csv", replace
	}

	restore
end


set seed 1245465 
forvalues i = 1/10000{
	my_xtboot `i' 
	}