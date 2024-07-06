/*
Merchants data

Source: Commands_Test_f_evaluation_vendors.do
Input:
	- Merchant
Output:
	- MerchantsData
*/



use "$dta_loc_repl/00_raw_anon/Merchant.dta", clear
**Kwamina's data adjustments? fix data quality issues I
replace v1a2 = 300 if date_of_interview == 10052020
replace v1a2 = 800 if (date_of_interview == 14052020 & vendorphone=="phone")
replace v1a2 = 100 if (date_of_interview == 14052020 & vendorphone=="246962718")
replace v1a2 = 950 if (date_of_interview == 14052020 & vendorphone=="559765100")
replace v1a2 = 120 if (date_of_interview == 14052020 & vendorphone=="207536369")
replace v1a2 = 1000 if (date_of_interview == 14052020 & vendorphone=="559761235/509109967")
replace v1a2 = 900 if (date_of_interview == 14052020 & vendorphone=="570359118/570359118")
replace v1a2=round(v1a2/1.35)
*or
*drop if date_of_interview == 10052020
**drop if date_of_interview == 11052020
*drop if date_of_interview == 14052020 
**Kwamina's data adjustments? fix data quality issues I
replace v1b2 = 1500 if date_of_interview == 29042020
replace v1b2 = 80 if date_of_interview == 30042020
replace v1b2 = 50 if v1b2==3000 & date_of_interview == 23042020

replace v1b2 = 30 if (date_of_interview == 2052020)

replace v1b2 = 1500 if (date_of_interview == 15052020)
replace v1b2 = 1800 if (date_of_interview == 22042020)

replace v1b2 = round(v1b2/1.35)
saveold "$dta_loc_repl/01_intermediate/MerchantsData.dta", replace
