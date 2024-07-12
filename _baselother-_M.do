/*
Merchants data

Source: _basel-repMkt.do (moving PII step backward, used to drop markets)
Input:
	- _M_all_2_18
Output:
	- _M_all_2_18_corrected
*/



use "$dta_loc_repl/00_raw/_M_all_2_18.dta", clear

gen market_to_drop = (m1q0d=="" | m1q0d=="PABI" | m1q0d=="XXX" | vn=="XXXXXX")
tab market_to_drop

saveold "$dta_loc_repl/00_raw/_M_all_2_18_corrected.dta", replace
