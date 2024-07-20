

use "$dta_loc_repl/02_final/Customer_+_Mktcensus_+_Interventions.dta", clear
**1. base up-biased beliefs about misconduct
replace text_ge01 = . if cdistrict_name == ""
replace text_ge02 = . if clocality_name == ""
// replace ge03 = . if vn == ""
drop _merge

*bring in audit objective misconduct data
merge m:1 text_ge01 text_ge02 using "$dta_loc_repl/01_intermediate/ofdrate_mktadminTransactData.dta"



	use "$dta_loc_repl/01_intermediate/CustomersData.dta", clear
	gen districtName = cdistrict_name 
	gen ln = clocality_name
	gen districtID= cdistrict_code 
	tostring customer2020_id, gen(_customer2020_id) format(%17.0g) //convert double to string

	gen _localityid= substr(_customer2020_id,1,12)
	gen _customerid= substr(_customer2020_id,-3,.)
	destring _localityid _customerid, gen(loccode customer_id) //create matches with census data

	merge m:m loccode customer_id using "$dta_loc_repl/01_intermediate/Mkt_census_xtics_+_interventions_localized.dta"
	**1. base up-biased beliefs about misconduct
	gen ge01 =cdistrict_name 
	gen ge02 =clocality_name 
	gen ge03 =vn
	drop _merge

	*bring in audit objective misconduct data
	merge m:1 ge01 ge02 using "$dta_loc_repl/01_intermediate/ofdrate_mktadminTransactData.dta"



** -----------------------------------------------------------------------------
** ofdrate_mktadminTransactData
use "/Users/yazenkashlan/Library/CloudStorage/OneDrive-Personal/Documents/personal/Berk/03_Work/Francis/Replication/data/01_intermediate/ofdrate_mktadminTransactData.dta", clear
count if fdH0_t0 != . // 106

use "$dta_loc_repl/01_intermediate/ofdrate_mktadminTransactData.dta", clear
count if fdH0_t0 != . // 105
isid text_ge01 text_ge02 
rename (text_ge01 text_ge02) (text_ge01_anon text_ge02_anon) 
merge 1:1 text_ge01_anon text_ge02_anon using "$dta_loc_repl/00_raw/crosswalk_text_ge012", keep(1 3) nogen
rename (text_ge01 text_ge02) (ge01 ge02)
merge 1:1 ge01 ge02 using "/Users/yazenkashlan/Library/CloudStorage/OneDrive-Personal/Documents/personal/Berk/03_Work/Francis/Replication/data/01_intermediate/ofdrate_mktadminTransactData.dta"
sort ge01 ge02

/*
locality not anonymized in ffaudits?
ge01	ge02
East Akim	ADADIENTEM

Anon:
3 			8
*/


** -----------------------------------------------------------------------------
** repMkt_w_xtics
use "/Users/yazenkashlan/Library/CloudStorage/OneDrive-Personal/Documents/personal/Berk/03_Work/Francis/Replication/data/01_intermediate/repMkt_w_xtics.dta", clear
sum vendor loccode // 1921
use "$dta_loc_repl/01_intermediate/repMkt_w_xtics.dta", clear
sum *ge0* // 1921


** -----------------------------------------------------------------------------
** FFaudit
use "/Users/yazenkashlan/Library/CloudStorage/OneDrive-Personal/Documents/personal/Berk/03_Work/Francis/Replication/data/00_raw_anon/FFaudit.dta", clear
sum ffaudits_id ffaq3 // 129
use "$dta_loc_repl/00_raw_anon/FFaudit.dta", clear
sum *ge0* // 129


