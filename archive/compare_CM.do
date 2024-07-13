// compare 990 customers in my data and regular

use "$dta_loc_repl/00_raw_anon/_CM_all_2_18", clear
tab vendor_id
merge m:1 ge03 using "$dta_loc_repl/01_intermediate/ONLY_4TrtGroups_9dist", gen(_mtreat)
tab treat
isid ge04
// use "$dta_loc_repl/01_intermediate/ONLY_4TrtGroups_9dist", clear
// tab treat

preserve
	use "/Users/yazenkashlan/Library/CloudStorage/OneDrive-Personal/Documents/personal/Berk/03_Work/Francis/Replication/data_test/00_raw/_CM_all_2_18", clear
	merge m:1 loccode vendor_id using "/Users/yazenkashlan/Library/CloudStorage/OneDrive-Personal/Documents/personal/Berk/03_Work/Francis/Replication/data/01_intermediate/ONLY_4TrtGroups_9dist", gen(_mtreat)
// 	tab vendor_id
// 	tab treat
// 	use "/Users/yazenkashlan/Library/CloudStorage/OneDrive-Personal/Documents/personal/Berk/03_Work/Francis/Replication/data/01_intermediate/ONLY_4TrtGroups_9dist", clear
// 	tab treat

	tostring loccode, gen(ge02) format("%17.0f") // ge02
	replace ge02 = "0"+ge02 if strlen(ge02) == 12
	tostring vendor_id, gen(vendor_str) format("%17.0f") // ge03
	replace vendor_str = "0"+vendor_str if strlen(vendor_str) == 1
	gen ge03 =  ge02+"0"+vendor_str
	tostring custcode, gen(custcode_str) format("%17.0f") // ge04
	replace custcode_str = "0"+custcode_str if strlen(custcode_str) == 1
	replace custcode_str = "0"+custcode_str if strlen(custcode_str) == 2
	gen ge04 = ge02+custcode_str
	order ge*
	
	rename * *_orig
	rename ge*_orig ge*
	isid ge04
	
	tempfile orig_dta
	save 	`orig_dta'

restore

rename ge0* ge0*_anon
merge m:1 ge03_anon using "$dta_loc_repl/00_raw/crosswalk_ge03", keep (1 3) gen(_cross3)
merge m:1 ge04_anon using "$dta_loc_repl/00_raw/crosswalk_ge04", keep (1 3) gen(_cross4)
order ge*
isid ge04
merge 1:1 ge04 using `orig_dta', gen(_morig)

** display
order treatment*
assert treatment == . if treatment_orig == .
assert treatment_orig == . if treatment == .

tab treatment treatment_orig // randomization does not match



