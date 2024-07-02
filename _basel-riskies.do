/*
Riskies

Input:
	- repMkt
Output:
	- riskiesTomake_list

*/



**Riskies: short phone surveys, vendors n=50?
use "$dta_loc_repl/01_intermediate/repMkt", clear
tab sample_repMkt, miss
keep if sample_repMkt==0

gen double localityCode_j=loccode
merge m:1 localityCode_j using "$dta_loc/sampling?/sel_9Distr_137Local_List"
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
**get distr level rep 35 vendors?
randtreat, generate(riskies) replace unequal(1/4 1/4 1/4 1/4) strata(districtID) misfits(wstrata) setseed(12345)
tab riskies, miss
tab districtID riskies

keep if riskies==0
keep districtID districtName loccode loccodex ln vn vendor_id vDescribe vPhone1 vPhone1x vPhone1xx vPhone2 vPhone2x vPhone2xx sample_repMkt riskies
order districtName ln vn vDescribe vPhone1xx vPhone2xx
tab districtID
tab districtName

saveold "$dta_loc_repl/01_intermediate/riskiesTomake_list", replace
