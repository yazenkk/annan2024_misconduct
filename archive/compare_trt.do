// compare 990 customers in my data and regular

use "$dta_loc_repl/01_intermediate/ONLY_4TrtGroups_9dist", clear
tab treat
isid ge02

preserve
	use "/Users/yazenkashlan/Library/CloudStorage/OneDrive-Personal/Documents/personal/Berk/03_Work/Francis/Replication/data/01_intermediate/ONLY_4TrtGroups_9dist", clear
	tab treat
	isid loccode

	tostring loccode, gen(ge02) format("%17.0f") // ge02
	replace ge02 = "0"+ge02 if strlen(ge02) == 12
	order ge*
	
	rename * *_orig
	rename ge*_orig ge*
	isid ge02
	
	tempfile orig_dta
	save 	`orig_dta'

restore

rename ge0* ge0*_anon
merge m:1 ge02_anon using "$dta_loc_repl/00_raw/crosswalk_ge012", keep (1 3) gen(_cross12)
order ge*
isid ge02
merge 1:1 ge02 using `orig_dta', gen(_morig)

** display
order treatment*
assert treatment == . if treatment_orig == .
assert treatment_orig == . if treatment == .

tab treatment treatment_orig // randomization does not match



