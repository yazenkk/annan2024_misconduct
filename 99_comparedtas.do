/*
Compare datasets
Date: 7/6/2024

*/
cap program drop cf_id 
program define cf_id
	syntax, dta(string) ///
			id(string) ///
			[drop(string)]
	
	qui {
	preserve
		use "`dta'", clear
		isid `id'
		sort `id'	
		if "`drop'" != "" drop `drop'
		tempfile compare_dta
		save 	`compare_dta'
	restore
	}
	
	cf _all using `compare_dta', verbose
end

** dtas
local private : dir "$dta_loc_repl/01_intermediate" files "*.dta"

foreach dta in `private' {
	dis "`dta'"

}

** stats? datasets
local dta "ofdrate_mktadminTransactData"  							// Looks good
 	use "$dta_loc_repl/01_intermediate/`dta'", clear 
	cf_id, dta("$dta_loc/data-Mgt/Stats?/`dta'.dta") id("ge01 ge02")
	
local dta "Mkt_census_xtics_+_interventions_localized"  			// mismatch
	use "$dta_loc/data-Mgt/Stats?/`dta'.dta", clear
 	use "$dta_loc_repl/01_intermediate/`dta'", clear 
	cf _all using "$dta_loc/data-Mgt/Stats?/`dta'.dta", verbose	
	/*  Stats? data has fewer vars and zeros instead of missings. 
		Not clear when it was generated.*/

** FINAL AUDIT DATA
cls
local dta "analyzed_EndlineAuditData"  								// Looks good
 	use "$dta_loc_repl/00_Raw/`dta'", clear 
	cf _all using "$dta_loc/FINAL AUDIT DATA/_Francis/`dta'.dta", verbose
	
local dta "mkt_aiVendorBetter"  									// Looks good
 	use "$dta_loc_repl/01_intermediate/`dta'", clear 
	isid loccode
	sort loccode
	cf_id, dta("$dta_loc/FINAL AUDIT DATA/_Francis/`dta'.dta") id("loccode")
	
local dta "ofdrate_mktAudit_endline"  								// Looks good. Original file doesn't drop duplicate vars
	cls
// 	use "$dta_loc/FINAL AUDIT DATA/_Francis/`dta'.dta", clear
 	use "$dta_loc_repl/01_intermediate/`dta'", clear 
	isid ge01 ge02 ge03
	sort ge01 ge02 ge03
// 	cf _all using "$dta_loc/FINAL AUDIT DATA/_Francis/`dta'.dta", verbose
	cf_id, dta("$dta_loc/FINAL AUDIT DATA/_Francis/`dta'.dta") ///
		   id("ge01 ge02 ge03") ///
		   drop(fd fdamt fYes_T fAmt_T sv_fAmt_T)




** FFPhone 2020
cls
local dta "Customer_+_Mktcensus_+_Interventions"  					// Looks good
	use "$dta_loc/FFPhone in 2020/`dta'.dta", clear
 	use "$dta_loc_repl/01_intermediate/`dta'", clear 
	local id customer_id distcode vendor loccode 
 	isid `id'
	sort `id' 
	cf_id, dta("$dta_loc/FFPhone in 2020/`dta'.dta") ///
	   id(`id') ///

local dta "CustomersData"  											// Looks good
 	use "$dta_loc_repl/01_intermediate/`dta'", clear 
	cf _all using "$dta_loc/FFPhone in 2020/`dta'.dta", verbose
	
local dta "MerchantsData"  											// Looks good
 	use "$dta_loc_repl/01_intermediate/`dta'", clear 
	cf _all using "$dta_loc/FFPhone in 2020/`dta'.dta", verbose

