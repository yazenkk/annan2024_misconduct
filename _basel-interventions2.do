/*
Interventions

Input:
	- repMkt
	
Output:
	- 
	
[Confirm: do we need this for later analysis]
*/




**ONLY: dta for office-Officers: intervention seeders/planters
**launch to: only repVendors + only nearby-local? [all-global?] customers?
use "$dta_loc_repl/01_intermediate/repMkt.dta", clear
keep if sample_repMkt==1
keep loccode vendor_id 
merge 1:m loccode vendor_id using  "$dta_loc_repl/00_raw_anon/_CM_all_2_18.dta"
*merge 1:m loccode using  "_CM_all_2_18.dta"
keep if _merge==3

bys loccode vendor_id: gen x=_N
tab x

**let's check? very good...
*bys loccode vendor_id: keep if _n==1
*br
keep loccode vendor_id custcode cn c1q0b c1q8a c1q8b
saveold "$dta_loc_repl/01_intermediate/ONLY_repMkt", replace


use "$dta_loc_repl/01_intermediate/ONLY_4TrtGroups_9dist", clear
merge 1:m loccode vendor_id using "$dta_loc_repl/01_intermediate/ONLY_repMkt"
bys loccode vendor: gen xx=_N
tab xx //1-25 customers; only nearby customers that surround repMkt (not all in locality possibly)
sum xx
tab treatment //ctr=185c, pt=272, mr=257, joint=276

**label vendor side??
label var vendor_id "vendor ID - unique only within locality"
label var vn "vendor name"

**label customer side??
gen customer_id = custcode
label var customer_id "customer ID - unique only within locality"
label var cn "customer name, nearby"
gen cDescribe = c1q0b
label var cDescribe "Describe location -- customer nearby"
gen double cPhone1=c1q8a
label var cPhone1 "Phone number -- primary, customer nearby"
gen double cPhone2=c1q8b
label var cPhone2 "Phone number -- secondary, customer nearby"

**get things in strings for CAPI
*tostring loccode, gen(loccodex) format(%17.0g)

*tostring vPhone1, gen(vPhone1x) format(%17.0g)
*tostring vPhone1, gen(vPhone1xx) format(%010.0f)
*tostring vPhone2, gen(vPhone2x) format(%17.0g)
*tostring vPhone2, gen(vPhone2xx) format(%010.0f)

tostring cPhone1, gen(cPhone1x) format(%17.0g)
tostring cPhone1, gen(cPhone1xx) format(%010.0f)
tostring cPhone2, gen(cPhone2x) format(%17.0g)
tostring cPhone2, gen(cPhone2xx) format(%010.0f)

order districtID districtName loccode loccodex ln ///
	vn vendor_id vDescribe vPhone1 vPhone1x vPhone1xx vPhone2 vPhone2x vPhone2xx ///
	cn customer_id cDescribe cPhone1 cPhone1x cPhone1xx cPhone2 cPhone2x cPhone2xx treatment

gen intervention =""
replace intervention="Control" if treatment==0
replace intervention="PriceTransparency, PT" if treatment==1
replace intervention="MKtMonitoring, MM" if treatment==2
replace intervention="joint: PT+MM" if treatment==3
label var intervention "intervention or treatment type to implement"

keep districtID districtName loccode loccodex ln ///
	vn vendor_id vDescribe vPhone1 vPhone1x vPhone1xx vPhone2 vPhone2x vPhone2xx ///
	cn customer_id cDescribe cPhone1 cPhone1x cPhone1xx cPhone2 cPhone2x cPhone2xx treatment intervention 

**last adjustment
replace vn="or ask Sammy on-0243289914" if (districtName=="Asuogyaman" & ln=="OSIABURA")
replace vPhone1x="or ask Sammy on-0243289914" if (districtName=="Asuogyaman" & ln=="OSIABURA")
replace vDescribe="1st vendoor on left around where the town starts from Atempoku coming" if (districtName=="Asuogyaman" & ln=="OSIABURA")

saveold "$dta_loc_repl/01_intermediate/interventionsTomake_list_local", replace

