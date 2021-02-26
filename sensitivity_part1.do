clear
cd "C:\Users\julia\SRP\SRP\Codes\data_codes"
import delimited "C:\Users\julia\SRP\SRP\Codes\SAF SAS files\final_sample_half.csv"
do variable_coding

replace policy_factor = 0 if policy_factor ==1
replace policy_factor = 1 if policy_factor ==2


label define policy_factor_new 0 "Pre" 1 "Post" 
label values policy_factor policy_factor_new

tab high_status policy_factor, matcell(policy_matrix)

drop if half == "2"

melogit high_status policy_factor ib1.WGT_factor ib1.HGT_factor centered_age ib4.race_factor ib2.smoking_factor ib2.work_factor ib1.edu_factor ib2.BMI_factor ib1.blood_type_factor ib1.diag_factor ib1.egfr_factor ib2.diab_factor ib3.fs_factor ib1.ci_factor ib2.pcwp_factor  ib4.payor_factor|| ctr_cd: policy_factor, covariance(unstructured) or

clear
cd "C:\Users\julia\SRP\SRP\Codes\data_codes"
import delimited "C:\Users\julia\SRP\SRP\Codes\SAF SAS files\final_sample_half.csv"
do variable_coding

replace policy_factor = 0 if policy_factor ==1
replace policy_factor = 1 if policy_factor ==2


label define policy_factor_new 0 "Pre" 1 "Post" 
label values policy_factor policy_factor_new

tab high_status policy_factor, matcell(policy_matrix)

drop if half == "2"

melogit high_status policy_factor ib1.WGT_factor ib1.HGT_factor centered_age ib4.race_factor ib2.smoking_factor ib2.work_factor ib1.edu_factor ib2.BMI_factor ib1.blood_type_factor ib1.diag_factor ib1.egfr_factor ib2.diab_factor ib3.fs_factor ib1.ci_factor ib2.pcwp_factor  ib4.payor_factor|| ctr_cd: policy_factor, covariance(unstructured) or

