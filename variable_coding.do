/*variable coding*/
drop if policy=="NA"
egen policy_factor= group(policy), label


gen status_num = . 
replace status_num = 1 if status == "Status 1"
replace status_num = 2 if status == "Status 2"
replace status_num = 3 if status == "Status 3"
replace status_num = 4 if status == "Status 4"
replace status_num = 6 if status =="Status 6"

drop if missing(status_num)

gen s1 =.
gen s2 =.
gen s3 =.
gen s4 =.
gen s6 =.

replace s1 = 1 if status_num ==1
replace s1 = 0 if missing(s1)

replace s2 = 1 if status_num ==2
replace s2 = 0 if missing(s2)

replace s3 = 1 if status_num ==3 
replace s3 = 0  if missing(s3)

replace s4 = 1 if status_num ==4
replace s4 = 0 if missing(s4)

replace s6 = 1 if status_num ==6
replace s6 = 0 if missing(s6)

gen high_status = .
replace high_status = 1 if status_num == 1 | status_num==2
replace high_status = 0 if status_num>2
gen policy_high_status = policy_factor*high_status

/*generate candidate level variables*/

*mean-center any linear variables - age

summarize age, meanonly
gen centered_age= age - r(mean)

*since there are missing 534 people missing ardiac index, we'll catergorize it, with missing being in a category by itself
destring cardiac_index, replace ignore(`"NA"')
xtile ci_quartile = cardiac_index, n(4)
egen ci_level = group(ci_quartile)
gen ci = ""
replace ci = "1" if ci_level == 1
replace ci = "2" if ci_level ==2
replace ci = "3" if ci_level ==3
replace ci = "4" if ci_level ==4
replace ci = "5" if missing(ci_level)
tab ci, m
egen ci_factor = group(ci) /*ci_factor =5 for missing values*/
label define ci 1 "1st quartile" 2 "2nd quartile" 3 "3rd quartile" 4 "4th quartile" 5 "missing"
label values ci_factor ci

tab ci_factor, m

*since there are 72 people missing egfr, we'll categorize it as well, with missing in its own category

destring egfr, replace ignore(`"NA"')
xtile egfr_quartile = egfr, n(4)
gen eGFR = ""
replace eGFR = "1" if egfr_quartile ==1
replace eGFR = "2" if egfr_quartile ==2
replace eGFR = "3" if egfr_quartile ==3 
replace eGFR = "4" if egfr_quartile ==4
replace eGFR = "5" if missing(egfr_quartile)
egen egfr_factor = group(eGFR) /*egfr_factor = 5 for missing values*/
label define egfr 1 "1st quartile" 2 "2nd quartile" 3 "3rd quartile" 4 "4th quartile" 5 "missing"
label values egfr_factor egfr

tab egfr_factor

*749 people missing pcwp, treat pcwp as quartiles. ib2
destring pcwp, replace ignore(`"NA"')
xtile pcwp_quartile = pcwp, n(4)
gen PCWP = ""
replace PCWP = "1" if pcwp_quartile ==1
replace PCWP = "2" if pcwp_quartile ==2
replace PCWP = "3" if pcwp_quartile ==3 
replace PCWP = "4" if pcwp_quartile ==4
replace PCWP = "5" if missing(pcwp_quartile)
egen pcwp_factor = group(PCWP) /*pcwp_factor = 5 for missing values*/
tab pcwp_factor
label define pcwp 1 "1st quartile" 2 "2nd quartile" 3 "3rd quartile" 4 "4th quartile" 5 "missing"
label values pcwp_factor pcwp

* 57 missing bmi, treat bmi as quartiles, ib2
destring bmi, replace ignore(`"NA"')
xtile bmi_quartile=bmi,n(4)
gen BMI = ""
replace BMI = "1" if bmi_quartile ==1
replace BMI = "2" if bmi_quartile ==2
replace BMI = "3" if bmi_quartile ==3 
replace BMI = "4" if bmi_quartile ==4
replace BMI = "5" if missing(bmi_quartile)
egen BMI_factor = group(BMI) /*pcwp_factor = 5 for missing values*/
label define bmi 1 "1st quartile" 2 "2nd quartile" 3 "3rd quartile" 4 "4th quartile" 5 "missing"
label values BMI_factor bmi

/*race ib4, white is most prevalent*/
egen race_factor= group(race), label 
rename female sex
replace sex = 2 if sex==1
replace sex = 1 if sex==0

/*sex, ib1 male*/
label define sex 1 "male" 2 "female"
label values sex sex

/*blood type, ib4 type o*/
egen blood_type_factor = group(blood_type), label

*42 people missing smoking history, ib2, no prior smoking history
egen smoking_factor = group(history_of_smoking), label
tab smoking_factor

*working status, 223 people missing working, ib2 not working
egen work_factor = group(working), label
tab work_factor

* educational status, ib1 college
egen edu_factor = group(education_status), label

* diagnosis, ib1, dialated cardiomyopathy
egen diag_factor = group(diagnosis), label

* diabetes, 49 people with unknown diabetes status, ib2 non-diabetic
egen diab_factor = group(diabetes), label

*333 with unknown functional status, ib3 severe impairment
egen fs_factor = group(functional_status), label

*payor, ib2 medicare
egen payor_factor = group(payor), label