/*
Combine baseline and raw datasets

Source: Commands_Test_f_evaluation.do
Input: 
	- Mkt_fieldData_census
	- interventionsTomake_list_local
Output:
	- Mkt_census_xtics_+_interventions_localized
*/


**I--Mkt Census xtics + Interventions (localized)?
use "$dta_loc_repl/01_intermediate/Mkt_fieldData_census", clear
drop _merge
gen customer_id = custcode
merge m:1 loccode vendor_id customer_id using "$dta_loc_repl/01_intermediate/interventionsTomake_list_local" //customers match subsumes vednors//
keep if _merge==3
drop _merge
save "$dta_loc_repl/01_intermediate/Mkt_census_xtics_+_interventions_localized", replace


