/*
Anonymize raw datasets for Annan (2024) JPE
Date: 7/2/2024

*/

use "$dta_loc_repl/00_raw/_M_all_2_18.dta", replace 

// process

save "$dta_loc_repl/00_raw_anon/_M_all_2_18.dta", clear 


