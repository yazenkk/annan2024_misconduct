/*
Title: R3-JPE: LOCALITY_SPECIFIC MAPS
Note: maps generated in ArcGIS

Input:
	Data:
	- data-Mgt/Stats_(2)/
		- Mkt_fieldData_census
		- RepMkt_TrtID_gps
Output:
	- vendorxcustomer_gps.xls
*/

*get mkt: gps?
*step 1?
use "$dta_loc_repl/01_intermediate/Mkt_fieldData_census", clear
keep if (_merge==3) //only Merchant-Customer pairs that merged right? b/c can't study just 1
drop _merge

keep  ge02 ln loccode m1q0b m1q0a ge03 vendor_id c1q0a2 c1q0a1 custcode 
order ge02 ln loccode  m1q0b m1q0a ge03 vendor_id c1q0a2 c1q0a1 custcode //vendorxcustomer_gps: 130 locs, 337/331/335 vendors, 1921 customers 


*step 2?
*bring in: repMkt ID + loc trt ID?
preserve
	use "$dta_loc_repl/01_intermediate/repMkt", clear
	tab sample_repMkt, miss
	bys ge02: gen no_vendors=_N
	sum no_vendors
	*keep vn vendor_id no_vendors loccode ln Mkt
	merge m:1 ge02 using "$dta_loc_repl/01_intermediate/ONLY_4TrtGroups_9dist", gen(_mtrt)
	gen Treated = "yes" 
	replace Treated = "no" if treatment==0
	
	keep ge03 vn treatment sample_repMkt no_vendors /// vendor_id 
		 ge02 loccode ln districtName districtID Treated // loccodex
	
	tempfile RepMkt_TrtID_gps
	save	`RepMkt_TrtID_gps'
restore

merge m:1 ge02 ge03 using `RepMkt_TrtID_gps'
keep if (no_vendors==3 | no_vendors==2)
keep if inlist(ge02, 134, 14, 50, 63)

gen trt_tagVendors = ""
replace trt_tagVendors="Ctr" if ge02==134

replace trt_tagVendors="Treated" if (ge02==14 & sample_repMkt==1)
replace trt_tagVendors="Untreated" if (ge02==14 & sample_repMkt==0) 

replace trt_tagVendors="Treated" if (ge02==50 & sample_repMkt==1)
replace trt_tagVendors="Untreated" if (ge02==50 & sample_repMkt==0) 

replace trt_tagVendors="Treated" if (ge02==63 & sample_repMkt==1)
replace trt_tagVendors="Untreated" if (ge02==63 & sample_repMkt==0) 

bys ln trt_tagVendors: replace trt_tagVendors="" if _n>1 


gen trt_tagCustomers = ""
replace trt_tagCustomers="Ctr" if ge02==134

replace trt_tagCustomers="Treated" if (ge02==14 & sample_repMkt==1)
replace trt_tagCustomers="Untreated" if (ge02==14 & sample_repMkt==0) 

replace trt_tagCustomers="Treated" if (ge02==50 & sample_repMkt==1)
replace trt_tagCustomers="Untreated" if (ge02==50 & sample_repMkt==0) 

replace trt_tagCustomers="Treated" if (ge02==63 & sample_repMkt==1)
replace trt_tagCustomers="Untreated" if (ge02==63 & sample_repMkt==0) 

keep districtName ge02 sample_repMkt trt_tag* treatment m1q0b m1q0a ge03 c1q0a2 c1q0a1 custcode
saveold "$dta_loc_repl/01_intermediate/vendorxcustomer_gps", ver(11) replace
outsheet using "$dta_loc_repl/01_intermediate/vendorxcustomer_gps.xls", replace

*step 3?
*the rest in ArcGIS...

