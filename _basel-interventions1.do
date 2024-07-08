/*
Generate treatment datasets

Input:
	- repMkt
	- sel_9Distr_137Local_List
Output:
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
label var sample_repMkt "indicator for randomly selected vendor to represent a locality, 1=Selected, 0=notSelected"

gen districtID = regionDistrictCode_j
label var districtID "District code/ ID -- unique"


tostring loccode, gen(loccodex) format(%17.0g)


order districtID districtName loccode loccodex ln vn vendor_id vDescribe sample_repMkt
keep districtID districtName loccode loccodex ln vn vendor_id vDescribe sample_repMkt
tab districtID
tab districtName

randtreat, generate(treatment) replace unequal(1/4 1/4 1/4 1/4) strata(districtID) misfits(wstrata) setseed(12345)
tab treatment, miss
tab districtID treatment
save "$dta_loc_repl/01_intermediate/ONLY_4TrtGroups_9dist", replace

