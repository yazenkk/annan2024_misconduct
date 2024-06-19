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

clear all


*cd "/Users/fa2316/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/data-Mgt/Stats?"
*cd "/Users/fa2316/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/data-Mgt/Stats?"
cd "/Users/niite/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/data-Mgt/Stats_(2)"
ls


*get mkt: gps?
*step 1?
use Mkt_fieldData_census, clear
keep if (_merge==3) //only Merchant-Customer pairs that merged right? b/c can't study just 1
drop _merge

keep ln loccode m1q0b m1q0a vendor_id c1q0a2 c1q0a1 custcode 
order ln loccode  m1q0b m1q0a vendor_id c1q0a2 c1q0a1 custcode //vendorxcustomer_gps: 130 locs, 337/331/335 vendors, 1921 customers 

/*
*step 2?
*bring in: repMkt ID + loc trt ID?
use repMkt, clear
tab sample_repMkt, miss
bys loccode: gen no_vendors=_N
sum no_vendors
*keep vn vendor_id no_vendors loccode ln Mkt

merge m:1 loccode ln using ONLY_4TrtGroups_9dist
gen Treated = "yes" 
replace Treated = "no" if treatment==0
keep vn vendor_id treatment sample_repMkt no_vendors loccodex loccode ln districtName districtID Treated
saveold RepMkt_TrtID_gps, ver(11) replace
*/
merge m:1 loccode ln vendor_id using RepMkt_TrtID_gps
keep if (no_vendors==3 | no_vendors==2)
**ln="OKORASE" pt; ln="OTERKPOLU" mr; ln="SUHYEN" joint; ln="AKIM SAGYIMASE" ctr
keep if (ln=="OKORASE" | ln=="OTERKPOLU" | ln=="SUHYEN" | ln=="AKIM SAGYIMASE")

gen trt_tagVendors = ""
replace trt_tagVendors="Ctr" if ln=="AKIM SAGYIMASE"

replace trt_tagVendors="Treated" if (ln=="OKORASE" & sample_repMkt==1)
replace trt_tagVendors="Untreated" if (ln=="OKORASE" & sample_repMkt==0) 

replace trt_tagVendors="Treated" if (ln=="OTERKPOLU" & sample_repMkt==1)
replace trt_tagVendors="Untreated" if (ln=="OTERKPOLU" & sample_repMkt==0) 

replace trt_tagVendors="Treated" if (ln=="SUHYEN" & sample_repMkt==1)
replace trt_tagVendors="Untreated" if (ln=="SUHYEN" & sample_repMkt==0) 

bys ln trt_tagVendors: replace trt_tagVendors="" if _n>1 


gen trt_tagCustomers = ""
replace trt_tagCustomers="Ctr" if ln=="AKIM SAGYIMASE"

replace trt_tagCustomers="Treated" if (ln=="OKORASE" & sample_repMkt==1)
replace trt_tagCustomers="Untreated" if (ln=="OKORASE" & sample_repMkt==0) 

replace trt_tagCustomers="Treated" if (ln=="OTERKPOLU" & sample_repMkt==1)
replace trt_tagCustomers="Untreated" if (ln=="OTERKPOLU" & sample_repMkt==0) 

replace trt_tagCustomers="Treated" if (ln=="SUHYEN" & sample_repMkt==1)
replace trt_tagCustomers="Untreated" if (ln=="SUHYEN" & sample_repMkt==0) 

keep districtName ln sample_repMkt trt_tag* treatment m1q0b m1q0a vendor_id c1q0a2 c1q0a1 custcode
saveold "vendorxcustomer_gps", ver(11) replace
outsheet using "vendorxcustomer_gps.xls", replace

*step 3?
*the rest in ArcGIS...
?
