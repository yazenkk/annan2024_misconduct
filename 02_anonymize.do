/*
Anonymize raw datasets for Annan (2024) JPE
Date: 7/2/2024

*/

** Initialize
pause on 

** Define program to loop through variable list and replace obs with "PII"
capture program drop anonymize
program define anonymize
	syntax, [anon_list(string) loud(string)]

	ds `anon_list', has(type string)
	if "`r(varlist)'" != ""{
		foreach var of varlist `r(varlist)' {
			replace `var' = "PII" if `var' != ""
		}
	}
	ds `anon_list', has(type numeric)
	if "`r(varlist)'" != "" {
		foreach var of varlist `r(varlist)' {
			dis as error "`var'"
			gen  `var'_str = string(`var')
			replace `var'_str = "PII" if `var'_str != ""
			drop `var'
			rename `var'_str `var'				
		}	
	}
end





** Handle dtas
local private : dir "$dta_loc_repl/00_raw" files "*.dta"

foreach dta in `private' {
	dis "`dta'"
	use "$dta_loc_repl/00_raw/`dta'", clear 
	
	if 		"`dta'" == "sel_9Distr_137Local_List.dta" 	local anon_list districtName localityName
	else if "`dta'" == "_CM_all_2_18.dta" 				local anon_list c1q0a1 c1q0a2 c1q0a3 c1q0b c1q4a c1q8a c1q8b locality_name cn c3q2 c7q2
	else if "`dta'" == "_M_all_2_18.dta"	 			local anon_list m1q0a m1q0b m1q0c m1q0d m1q9a m1q9b ln m5q2 // vn 
	else if "`dta'" == "analyzed_EndlineAuditData.dta" 	local anon_list *gps* m1q0a m1q0b m1q0c c1q0a1 c1q0a2 c1q0a3 login ge03 nq5 districtName ln vn vDescribe cn *Phone* m1q0d m1q9a m1q9b c1q8a c1q8b m5q2 c7q2 locality_name c1q0b	
	else if "`dta'" == "Customer.dta" 					local anon_list ccaller_id ccaller_name custphone customer_name clocality_name cdistrict_name
	else if "`dta'" == "FFaudit.dta" 					local anon_list *gps* ge03
	else if "`dta'" == "interventionsTomake_list_local.dta" local anon_list districtName ln vn vDescribe cn cDescribe *Phone* 
	else if "`dta'" == "Merchant.dta" 					local anon_list caller_id caller_name1 vendorphone vendor_name locality_name1 district_name
	else local anon_list
	
	if "`dta'" == "_M_all_2_18.dta" {
		** generate unique vendor ID
		tostring loccode, gen(loccode_str) format("%17.0f")
		tostring vendor, gen(vendor_str) format("%17.0f")
		replace vendor_str = "0"+vendor_str if strlen(vendor_str) == 1
		gen vn_id =  loccode_str+vendor_str, after(vn)
		rename vn vn_pii
		rename vn_id vn
		replace vn_pii = "PII"
	}

	
// 	dis "`anon_list'"
// 	qui anonymize, anon_list("`anon_list'") 
	
	save "$dta_loc_repl/00_raw_anon/`dta'", replace
}


* Handle xlsx: FU data 1
import excel "$dta_loc_repl/00_raw/organized_surveys_cVENDORS_xlsx.xlsx", ///
	sheet("JPEr_control_rep_vendors_survey") firstrow clear
// qui anonymize, anon_list(districtName ln vn vDescribe *Phone*) 
save "$dta_loc_repl/00_raw_anon/organized_surveys_cVENDORS_xlsx", replace

* Handle xlsx: FU data 2
import excel "$dta_loc_repl/00_raw/organized_surveys_MANAGERS.xlsx", ///
	sheet("Sheet0") firstrow clear
// qui anonymize, anon_list(IPAddress LocationLatitude LocationLongitude Q0) 
save "$dta_loc_repl/00_raw_anon/organized_surveys_MANAGERS", replace

* Handle xlsx: treatments
use "$dta_loc_repl/00_raw/Treatments_4gps_9dist", clear
// qui anonymize, anon_list(localityName districtName) 
save "$dta_loc_repl/00_raw_anon/Treatments_4gps_9dist", replace


