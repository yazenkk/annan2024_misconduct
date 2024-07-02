/*
Generate treatment datasets

Input:
	- repMkt
	- sel_9Distr_137Local_List
Output:
	- AuditsTomake_list
	- ONLY_4TrtGroups_9dist
*/


**ONLY: dta for field-Auditors: the 130 repMkts?
use "$dta_loc_repl/01_intermediate/repMkt", clear
tab sample_repMkt, miss
keep if sample_repMkt==1

gen double localityCode_j=loccode

merge 1:1 localityCode_j using "$dta_loc_repl/00_raw_anon/sel_9Distr_137Local_List"
keep if _merge==3

label var vendor_id "vendor ID - unique only within locality"
gen vDescribe = m1q0d
label var vDescribe "Describe location -- vendor"
gen double vPhone1=m1q9a
label var vPhone1 "Phone number -- primary"
gen double vPhone2=m1q9b
label var vPhone2 "Phone number -- secondary"
label var sample_repMkt "indicator for randomly selected vendor to represent a locality, 1=Selected, 0=notSelected"

gen districtID = regionDistrictCode_j
label var districtID "District code/ ID -- unique"


tostring loccode, gen(loccodex) format(%17.0g)
tostring vPhone1, gen(vPhone1x) format(%17.0g)
tostring vPhone1, gen(vPhone1xx) format(%010.0f)

tostring vPhone2, gen(vPhone2x) format(%17.0g)
tostring vPhone2, gen(vPhone2xx) format(%010.0f)

order districtID districtName loccode loccodex ln vn vendor_id vDescribe vPhone1 vPhone1x vPhone1xx vPhone2 vPhone2x vPhone2xx sample_repMkt
keep districtID districtName loccode loccodex ln vn vendor_id vDescribe vPhone1 vPhone1x vPhone1xx vPhone2 vPhone2x vPhone2xx sample_repMkt
tab districtID
tab districtName

saveold "$dta_loc_repl/01_intermediate/AuditsTomake_list", replace




/*
**Becky -- risk attitudes: 1/3rd of 130 rep vendor? 
**let's sample from where gap is "coming from" vs "not"
use AuditsTomake_list, clear
gen distName= districtName
tab distName
keep if (distName == "Lower Manya Krobo" | distName == "Yilo Krobo") | (distName == "Suhum Municipal" | distName == "New Juaben Municipal")

saveold AuditsTomake_list, replace
outsheet using AuditsTomake_list.xls, replace
*/


use "$dta_loc_repl/01_intermediate/AuditsTomake_list", clear
randtreat, generate(treatment) replace unequal(1/4 1/4 1/4 1/4) strata(districtID) misfits(wstrata) setseed(12345)
tab treatment, miss
tab districtID treatment
save "$dta_loc_repl/01_intermediate/ONLY_4TrtGroups_9dist", replace

