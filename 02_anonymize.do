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

// 	pause  
	ds `anon_list', has(type string)
	if "`r(varlist)'" != "" {
// 		dis "anonymize strings"
// 		pause  
		foreach var of varlist `r(varlist)' {
			dis as error "String: `var'"
			replace `var' = "PII" if `var' != ""
		}
	}
	ds `anon_list', has(type numeric)
	if "`r(varlist)'" != "" {
// 		dis "anonymize numerics"
// 		pause  
		foreach var of varlist `r(varlist)' {
			dis as error "Numeric: `var'"
			gen  `var'_str = string(`var')
			replace `var'_str = "PII" if `var'_str != ""
			drop `var'
			rename `var'_str `var'				
		}	
	}
	
end





** Handle dtas
local private_1 : dir "$dta_loc_repl/00_raw" files "_*.dta"
local exclude1 _M_all_2_18.dta
local private_1 : list private_1 - exclude1
local private_2 : dir "$dta_loc_repl/00_raw" files "*.dta"
local private_2 : list private_2 - private_1
local exclude2 crosswalk_ge012.dta crosswalk_ge03.dta crosswalk_ge04.dta ///
			   Merchant.dta Customer.dta _M_all_2_18.dta
local private_2 : list private_2 - exclude2
dis `"`private_1'"'
dis `"`private_2'"'

foreach dta in `private_1' `private_2' {
	dis "`dta'"
	use "$dta_loc_repl/00_raw/`dta'", clear 
	
	if 		"`dta'" == "sel_9Distr_137Local_List.dta" 	local anon_list districtName localityName //
	else if "`dta'" == "_CM_all_2_18.dta" 				local anon_list c1q0a1 c1q0a2 c1q0a3 c1q0b c1q4a c1q8a c1q8b cn c3q2 c7q2 locality_name // loccode																		
	else if "`dta'" == "_M_all_2_18_corrected.dta"	 	local anon_list m1q0a m1q0b m1q0c m1q0d m1q9a m1q9b m5q2 ln vn // loccode 
	else if "`dta'" == "analyzed_EndlineAuditData.dta" 	local anon_list *gps* m1q0a m1q0b m1q0c c1q0a1 c1q0a2 c1q0a3 login nq5 districtName ln vn vDescribe /// 
																		cn *Phone* m1q0d m1q9a m1q9b c1q8a c1q8b m5q2 c7q2 locality_name c1q0b ///
																		xv_vendor xv_vendorr vendor_id /// districtID loccode loccodex ffaudits_id xvID xv_locality xv_localityy
																		universalid
	else if "`dta'" == "Customer_corrected.dta" 		local anon_list ccaller_id ccaller_name custphone customer_name clocality_name cdistrict_name customer2020_id
	else if "`dta'" == "FFaudit.dta" 					local anon_list *gps* /// ge01_orig ge02_orig ge03_orig
																		ffaudits_id
	else if "`dta'" == "interventionsTomake_list_local.dta" local anon_list districtName ln vn vDescribe cn cDescribe *Phone* loccode loccodex
	else if "`dta'" == "Merchant_corrected.dta" 		local anon_list caller_id caller_name1 vendorphone vendor_name locality_name1 district_name
	else if "`dta'" == "Treatments_4gps_9dist.dta" 		local anon_list localityName districtName regionDistrictCode localityCode geo_dist
	else local anon_list
	
	
	** convert id variables to ge*
	if "`dta'" == "_M_all_2_18_corrected.dta" {
		tostring loccode, gen(ge02) format("%17.0f") // ge02
		replace ge02 = "0"+ge02 if strlen(ge02) == 12
		tostring vendor, gen(vendor_str) format("%17.0f") // ge03
		replace vendor_str = "0"+vendor_str if strlen(vendor_str) == 1
		gen ge03 =  ge02+"0"+vendor_str, after(vendor) 
		gen test = strlen(ge03)
		gen ge01 = substr(ge02, 1, 4) // ge01
		order ge01 ge02 ge03
		assert strlen(ge01) == 4 & strlen(ge02) == 13 & strlen(ge03) == 16 
		
		** get ge01 and ge02 from sampling data
		preserve
			rename loccode localityCode_j
			merge m:1 localityCode_j using "$dta_loc_repl/00_raw/sel_9Distr_137Local_List.dta"
			rename (regionDistrictCode_j localityCode_j) (ge01_new ge02_new)
			
			rename ge03 ge03_new // for merge with analyzed_EndlineAuditData
			keep ge01_new ge02_new ge03_new vn
			order ge01_new ge02_new ge03_new vn
			duplicates drop
			drop if vn == ""
			
			tempfile vendor_crosswalk
			save 	`vendor_crosswalk'
		restore 
		
		gen text_ge02 = ln // to be anonymized later		
		gen text_ge03 = vn // to be anonymized later		
		
	}
	if "`dta'" == "_CM_all_2_18.dta" {
		tostring loccode, gen(ge02) format("%17.0f") // ge02
		replace ge02 = "0"+ge02 if strlen(ge02) == 12
		tostring vendor_id, gen(vendor_str) format("%17.0f") // ge03
		replace vendor_str = "0"+vendor_str if strlen(vendor_str) == 1
		gen ge03 =  ge02+"0"+vendor_str
		tostring custcode, gen(custcode_str) format("%17.0f") // ge04
		replace custcode_str = "0"+custcode_str if strlen(custcode_str) == 1
		replace custcode_str = "0"+custcode_str if strlen(custcode_str) == 2
		gen ge04 = ge02+custcode_str
		gen ge01 = substr(ge02, 1, 4) // ge01
		order ge01 ge02 ge03 ge04
		assert strlen(ge01) == 4 & strlen(ge02) == 13 & strlen(ge03) == 16 & strlen(ge04) == 16 
		
	}
	if "`dta'" == "analyzed_EndlineAuditData.dta" {
			assert vendor==vendor_id
			drop vendor
			rename ge* text_ge* // text versions
			order ffaudits_id xvID vendor_id loccode loccodex xv_locality xv_localityy distcode districtID districtName 
			tostring loccode, gen(loccode_str) format("%15.0f") // ge02?
			drop loccode loccode_str // problematic
			assert loccodex == xv_locality 
			drop xv_locality
			format ffaudits_id %15.0f
			tostring ffaudits_id, gen(ge03_wrong) format("%17.0f") // ge03
			assert ge03 == xvID
			drop xvID xv_locality
			rename loccodex ge02
			rename (districtID) (ge01) // ge01
			tostring ge01, replace 
			
			tostring vendor_id, gen(vendor_str) format("%17.0f") // ge03
			replace vendor_str = "0"+vendor_str if strlen(vendor_str) == 1
			gen ge03 =  ge02+"0"+vendor_str, after(vendor_str) 
			
			replace ge03 = "0"+ge03 if strlen(ge03) == 15
			replace ge02 = "0"+ge02 if strlen(ge02) == 12
			replace ge01 = "0"+ge01 if strlen(ge01) == 3
			order ge01 ge02 ge03
			drop ffaudits_id ge03_wrong
			
// 		** bring in ge0* from _M*.dta above
// 		merge m:1 vn using `vendor_crosswalk', gen(_mmap3) keep(1 3) // ge01/2/3
// 		rename (ge01 ge02 ge03) (ge01_orig ge02_orig ge03_orig)
// 		rename (ge01_new ge02_new ge03_new) (ge01 ge02 ge03)
// 		tostring ge01 ge02, replace format("%17.0f")
// 		replace ge02 = "0"+ge02 if strlen(ge02) == 12
// 		replace ge01 = "0"+ge01 if strlen(ge01) == 3
// 		order ge01 ge02 ge03
	}
	if "`dta'" == "Merchant_corrected.dta" {
		tostring merchant2020_id, gen(ge03) format("%17.0f") // ge03
		rename (district_code) (ge01) // ge01
		tostring ge01, replace 
		gen ge02 = substr(ge03, 1, strlen(ge03)-2) // ge02
		assert substr(ge02, -1, .) == "0"
		replace ge02 = substr(ge02, 1, strlen(ge02)-1) // drop last digit
		replace ge03 = "0"+ge03 if strlen(ge03) == 15
		replace ge02 = "0"+ge02 if strlen(ge02) == 12
		replace ge01 = "0"+ge01 if strlen(ge01) == 3
		order ge01 ge02 ge03
		drop merchant2020_id
	}
	if "`dta'" == "Customer_corrected.dta" {
		rename (cdistrict_code) (ge01) // ge01
		tostring ge01, replace
		tostring customer2020_id, gen(ge04) format("%17.0f") // ge04 (customer 3-digit)
		gen ge02 = substr(ge04, 1, strlen(ge04)-2) // ge02
		** assert substr(ge02, -1, .) == "0" // only true for merchants
		replace ge02 = substr(ge02, 1, strlen(ge02)-1) // drop last digit
		replace ge04 = "0"+ge04 if strlen(ge04) == 15
		replace ge02 = "0"+ge02 if strlen(ge02) == 12
		replace ge01 = "0"+ge01 if strlen(ge01) == 3
		order ge01 ge02 ge04
		
		gen text_ge01 = cdistrict_name // to be anonymized later
		gen text_ge02 = clocality_name // to be anonymized later
		
	}
	if "`dta'" == "interventionsTomake_list_local.dta" {
		tostring loccode, gen(ge02) format("%17.0f") // ge02
		replace ge02 = "0"+ge02 if strlen(ge02) == 12
		tostring vendor_id, gen(vendor_str) format("%17.0f") // ge03
		replace vendor_str = "0"+vendor_str if strlen(vendor_str) == 1
		gen ge03 =  ge02+"0"+vendor_str 
		tostring customer_id, gen(custcode_str) format("%17.0f") // ge04
		replace custcode_str = "0"+custcode_str if strlen(custcode_str) == 1
		replace custcode_str = "0"+custcode_str if strlen(custcode_str) == 2
		gen ge04 = ge02+custcode_str
		rename (districtID) (ge01) // ge01
		tostring ge01, replace
		replace ge01 = "0"+ge01 if strlen(ge01) == 3
		order ge01 ge02 ge03 ge04
	}
	if "`dta'" == "FFaudit.dta" {
		rename (ge01 ge02 ge03) (ge01_orig ge02_orig ge03_orig)
		tostring ffaudits_id, gen(ge02) format("%17.0f") // ge02
		replace ge02 = "0"+ge02 if strlen(ge02) == 12
		gen ge01 = substr(ge02, 1, 4) // ge01
		tostring ffaq3, gen(vendor_str) format("%17.0f") // ge03
		replace vendor_str = "0"+vendor_str if strlen(vendor_str) == 1
		gen ge03 =  ge02+"0"+vendor_str, after(vendor_str) 
		
		order ge01 ge02 ge03
		
		// one vendor has name "0"
		rename (ge01_orig ge02_orig ge03_orig) (text_ge01 text_ge02 text_ge03)
	}
	if "`dta'" == "Treatments_4gps_9dist.dta" {
		tostring regionDistrictCode_j, gen(ge01) format("%17.0f") // ge01
		tostring localityCode_j, gen(ge02) format("%17.0f") // ge02
		replace ge02 = "0"+ge02 if strlen(ge02) == 12
		replace ge01 = "0"+ge01 if strlen(ge01) == 3
		order ge01 ge02
	}
	if "`dta'" == "sel_9Distr_137Local_List.dta" {
		tostring localityCode_j, gen(ge02) format("%17.0f") // ge02
		tostring regionDistrictCode_j, gen(ge01) format("%17.0f") // ge01
		replace ge02 = "0"+ge02 if strlen(ge02) == 12
		replace ge01 = "0"+ge01 if strlen(ge01) == 3
		order ge01 ge02
		gen districtID = regionDistrictCode_j // for sampling in interventions1.do
		drop localityCode_j regionDistrictCode_j
		
		gen text_ge01 = strtrim(districtName) // to be anonymized later
		gen text_ge02 = localityName // to be anonymized later
	}

	** obfuscate loccode
	capture list loccode
	if _rc == 0 {
		if "`dta'" == "analyzed_EndlineAuditData.dta" pause
		format loccode %12.0f
		gen double sample_loccode = loccode - 6000000000
		format sample_loccode %12.0f
		order loccode sample_loccode
		preserve
			keep sample_loccode loccode
			duplicates drop
			isid sample_loccode 
			isid loccode
		restore
		drop loccode
		rename sample_loccode loccode_sampling
	}

	** obfuscate districtID
	capture list districtID
	if _rc == 0 {
		format districtID %12.0f
		gen double sample_districtID = districtID - 250
		format sample_districtID %12.0f
		order districtID sample_districtID
		preserve
			keep sample_districtID districtID
			duplicates drop
			isid sample_districtID 
			isid districtID
		restore
		drop districtID
		rename sample_districtID districtID_sampling
	}

	
	cap label var ge01 "District code (4-digit)"
	cap label var ge02 "Locality code (12-digit)"
	cap label var ge03 "Vendor/merchant code (3-digit)"
	cap label var ge04 "Customer code (3-digit)"

	local anon_varct : list sizeof anon_list
	if `anon_varct' != 0 qui anonymize, anon_list(`anon_list')

	save "$dta_loc_repl/00_raw_anon/`dta'", replace
}

* Handle xlsx: FU data 1
import excel "$dta_loc_repl/00_raw/organized_surveys_cVENDORS_xlsx.xlsx", ///
	sheet("JPEr_control_rep_vendors_survey") firstrow clear
tostring loccodex, gen(ge02) format("%17.0f") // ge02
gen ge01 = substr(ge02, 1, 3) // ge01
tostring ge01, replace
order ge01 ge02 
// vn and ge03 not used and seems messy (OSIEM not in vn in other dtas)
qui anonymize, anon_list(districtName ln vn vDescribe *Phone*)
save "$dta_loc_repl/00_raw_anon/organized_surveys_cVENDORS_xlsx", replace


* Handle xlsx: FU data 2
import excel "$dta_loc_repl/00_raw/organized_surveys_MANAGERS.xlsx", ///
	sheet("Sheet0") firstrow clear
qui anonymize, anon_list(IPAddress LocationLatitude LocationLongitude Q0) 
save "$dta_loc_repl/00_raw_anon/organized_surveys_MANAGERS", replace


** -----------------------------------------------------------------------------
** Create map between ge0* and anonymized versions of these

** Find which datasets have largest number of groups
cls
local anonymized : dir "$dta_loc_repl/00_raw_anon" files "*.dta"
foreach dta in `anonymized' {
	use "$dta_loc_repl/00_raw_anon/`dta'", clear 
	cap list ge04
	if _rc == 0 {
		preserve
			keep ge04
			duplicates drop 
// 			pause
// 			sort ge04
			dis "---------------begin"
			dis "`dta'"
			dis _N
			dis "---------------end"
		restore		
	}
}

** program to anonymize the categories
capture program drop anonymize_ge0x
program define anonymize_ge0x
	syntax, var(string)
	
// 	** randomly sort categorical variable
// 	cap drop rand
// 	set seed $myseed
// 	gen rand = runiform(), after(`var')
// 	byso `var' (rand) : gen rand_grp = rand[1]
// 	order rand_grp, after(rand)
// 	sort rand_grp rand
//	
// 	** generate rank
// 	egen `var'_anon = rank(rand_grp), track
// 	order `var'_anon, after(`var')
// 	tostring `var'_anon, gen(`var'_anon2)
// 	encode `var'_anon2, gen(`var'_anon3)
// 	label drop `var'_anon3
// 	drop `var'_anon `var'_anon2
// 	rename `var'_anon3 `var'_anon
// 	order `var'_anon, after(`var')
// 	drop rand*
	
	encode `var', gen(`var'_anon)
	label drop `var'_anon
	
end



** anonymize ge01 and ge02
use "$dta_loc_repl/00_raw_anon/_CM_all_2_18", clear
anonymize_ge0x, var(ge01)
anonymize_ge0x, var(ge02)
sort ge01 ge02
keep ge01* ge02*
duplicates drop
save "$dta_loc_repl/00_raw/crosswalk_ge012", replace

** anonymize ge03
use "$dta_loc_repl/00_raw_anon/_M_all_2_18_corrected", clear
anonymize_ge0x, var(ge03)
sort ge03
keep ge0*
duplicates drop
save "$dta_loc_repl/00_raw/crosswalk_ge03", replace

** anonymize ge04
use "$dta_loc_repl/00_raw_anon/_CM_all_2_18", clear
anonymize_ge0x, var(ge04)
sort ge04
keep ge0*
duplicates drop
save "$dta_loc_repl/00_raw/crosswalk_ge04", replace





** -----------------------------------------------------------------------------
** replace ge0x with anonymized version
local anonymized : dir "$dta_loc_repl/00_raw_anon" files "*.dta"
foreach dta in `anonymized' {
	use "$dta_loc_repl/00_raw_anon/`dta'", clear 
	local obs = `=_N'

// 	if "`dta'" == "Treatments_4gps_9dist.dta" pause
		
	cap list ge01 
	if _rc == 0 {
		merge m:1 ge01 ge02 using "$dta_loc_repl/00_raw/crosswalk_ge012", gen(_mge012) keep(1 3)
	}
	cap list ge03 
	if _rc == 0 {
		merge m:1 ge01 ge02 ge03 using "$dta_loc_repl/00_raw/crosswalk_ge03", gen(_mge03) keep(1 3)
	}
	cap list ge04
	if _rc == 0 {
		merge m:1 ge01 ge02 ge04 using "$dta_loc_repl/00_raw/crosswalk_ge04", gen(_mge04) keep(1 3)
	}
	cap order ge*
	assert `=_N' == `obs'
	
	cap drop ge01 
	cap drop ge02 
	cap drop ge03
	cap drop ge04
	cap rename ge0*_anon ge0*
	save "$dta_loc_repl/00_raw_anon/`dta'", replace
}



** -----------------------------------------------------------------------------
** Create map between text_ge0* and anonymized versions of these


** anonymize ge01 and ge02
use "$dta_loc_repl/00_raw_anon/sel_9Distr_137Local_List", clear
anonymize_ge0x, var(text_ge01)
anonymize_ge0x, var(text_ge02)
sort text_ge01 text_ge02
keep text_ge01* text_ge02*
duplicates drop
save "$dta_loc_repl/00_raw/crosswalk_text_ge012", replace

** anonymize ge03
use "$dta_loc_repl/00_raw_anon/_M_all_2_18_corrected", clear
anonymize_ge0x, var(text_ge03)
sort text_ge03
keep text_ge0*
duplicates drop
save "$dta_loc_repl/00_raw/crosswalk_text_ge03", replace


** -----------------------------------------------------------------------------
** replace ge0x with anonymized version
use "$dta_loc_repl/00_raw_anon/sel_9Distr_137Local_List", clear
	merge m:1 text_ge01 text_ge02 using "$dta_loc_repl/00_raw/crosswalk_text_ge012", gen(_mtextge012) keep(1 3)
	cap drop text_ge01 
	cap drop text_ge02 
	cap drop text_ge03 
	cap rename text_ge0*_anon text_ge0*
save "$dta_loc_repl/00_raw_anon/sel_9Distr_137Local_List", replace

use "$dta_loc_repl/00_raw_anon/_M_all_2_18_corrected", clear
	merge m:m text_ge02 using "$dta_loc_repl/00_raw/crosswalk_text_ge012", gen(_mtextge012) keep(1 3)
	merge m:1 text_ge03 using "$dta_loc_repl/00_raw/crosswalk_text_ge03", gen(_mtextge03) keep(1 3)
	cap drop text_ge01 
	cap drop text_ge02 
	cap drop text_ge03 
	cap rename text_ge0*_anon text_ge0*
save "$dta_loc_repl/00_raw_anon/_M_all_2_18_corrected", replace

use "$dta_loc_repl/00_raw_anon/analyzed_EndlineAuditData", clear
	merge m:1 text_ge01 text_ge02 using "$dta_loc_repl/00_raw/crosswalk_text_ge012", gen(_mtextge012) keep(1 3)
	merge m:1 text_ge03 using "$dta_loc_repl/00_raw/crosswalk_text_ge03", gen(_mtextge03) keep(1 3)
	cap drop text_ge01 
	cap drop text_ge02 
	cap drop text_ge03 
	cap rename text_ge0*_anon text_ge0*
save "$dta_loc_repl/00_raw_anon/analyzed_EndlineAuditData", replace

use "$dta_loc_repl/00_raw_anon/Customer_corrected", clear
	merge m:1 text_ge01 text_ge02 using "$dta_loc_repl/00_raw/crosswalk_text_ge012", gen(_mtextge012) keep(1 3)
	cap drop text_ge01 
	cap drop text_ge02 
	cap drop text_ge03 
	cap rename text_ge0*_anon text_ge0*
save "$dta_loc_repl/00_raw_anon/Customer_corrected", replace


use "$dta_loc_repl/00_raw_anon/FFaudit", clear
	merge m:1 text_ge01 text_ge02 using "$dta_loc_repl/00_raw/crosswalk_text_ge012", gen(_mtextge012) keep(1 3)
	cap drop text_ge01 
	cap drop text_ge02 
	cap drop text_ge03 
	cap rename text_ge0*_anon text_ge0*
save "$dta_loc_repl/00_raw_anon/FFaudit", replace

