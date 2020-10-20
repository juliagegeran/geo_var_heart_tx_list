import delimited "final_sample.csv", clear
do variable_coding

gen time = 1



gen pol = cond(policy == "Dec 2018 - Feb 2020 (Post-policy)", 1, 0)


gen ecmo = cond(treatment == "ECMO", 1, 0)
ir ecmo pol time


gen good_iabp = cond(status == "Status 2" & treatment == "IABP", 1, 0)

ir good_iabp pol time


gen except_high = cond((status == "Status 2" | status == "Status 1" ) & treatment == "Exception", 1, 0)
replace except_high = 1 if policy_factor == 1 & treatment == "Exception" & status_num < 4

ir except_high pol time 
