/*
Anonymize raw datasets for Annan (2024) JPE
Date: 7/2/2024

*/

** dtas
local private : dir "$dta_loc_repl/00_raw" files "*.dta"

foreach dta in `private' {
	dis "`dta'"
	use "$dta_loc_repl/00_raw/`dta'", clear 

	// process

	save "$dta_loc_repl/00_raw_anon/`dta'", replace
}


* xlsx
import excel "$dta_loc_repl/00_raw/organized_surveys_cVENDORS_xlsx.xlsx", ///
	sheet("JPEr_control_rep_vendors_survey") firstrow clear

// process

save "$dta_loc_repl/00_raw_anon/organized_surveys_cVENDORS_xlsx", replace

import excel "$dta_loc_repl/00_raw/organized_surveys_MANAGERS.xlsx", ///
	sheet("Sheet0") firstrow clear

// process

save "$dta_loc_repl/00_raw_anon/organized_surveys_MANAGERS", replace
