/*
JPE control vendors

Input:
	- ONLY_4TrtGroups_9dist
Output:
	- JPEr_control_rep_vVendors_survey
	- JPEr_control_ALL_vVendors_survey

[Confirm: do we need this in the replication?]

*/


*JPE REVISION SEP 6 2022
*survey 32 control rep-vendors 
cd "$dta_loc/data-Mgt/Stats?"
use ONLY_4TrtGroups_9dist, clear
keep if treatment==0 //control rep-vendors
saveold JPEr_control_rep_vVendors_survey, replace
outsheet using JPEr_control_rep_vVendors_survey.xls, replace

*SEP 11 2022
use vendorsRoster_by_locality_Ctrl32, clear
merge m:1 ln loccodex districtName vn vendor_id using JPEr_control_rep_vVendors_survey
bys districtName ln vn: drop if _n>1
sort _merge
keep districtID districtName loccode loccodex ln vn vendor_id vDescribe vPhone1 vPhone1x vPhone1xx vPhone2 vPhone2x vPhone2xx treatment
outsheet using JPEr_control_ALL_vVendors_survey.xls, replace
