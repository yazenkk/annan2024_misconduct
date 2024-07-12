/*
Prepare market data

	*
	**II. audit Trials?
	*Audit sample selection
	**representative? locality (subsumes district)
	*(We don't cluster --only 2x2 design-- to reject more often)

	[^refine original note]


Input:
	- Mkt_fieldData_census
Outpu:
	- repMkt 
	- repMkt_w_xtics
*/


use "$dta_loc_repl/01_intermediate/Mkt_fieldData_census", clear


**1: get representative Mkt (per locality)
keep if (_merge==3) //only Merchant-Customer pairs that merged right? b/c can't study just 1
drop _merge

**Get mkt summaries & restrictions?
bys ge02: gen CustPerLocal= _N
hist CustPerLocal //dis: tot no of cust per local
sum CustPerLocal // 1 to 47 with avg=20.8<21 customers

egen count_loccode=group(ge02)
tab count_loccode, miss //137-> 134 (115?) success

egen local_by_vendor = group(ge02 ge03)
tab local_by_vendor, miss //480-> 337 (315?) a drop
tab Mkt, miss //480-> 337 (315?) a drop

bys ge02: gen mktFip = group(ge03)

hist MktPerLocal //dis: tot no of Mkt(/merch) per local
sum MktPerLocal // 1 to 12 with avg=3.2<4 merchants
tab MktPerLocal

bys ge02 ge03: gen CustPer_w_Mkt = _N
hist CustPer_w_Mkt //dis: tot no of within-Cust per mkt
tab CustPer_w_Mkt



**get "rep market" per each locality?
preserve 
	bys ge03: keep if _n==1

	set seed 12345
	bys ge02: gen rand_num = uniform()
	bys ge02: gen x = _N
	by ge02 (rand_num), sort: gen sample_repMkt = _n==x
	tab sample_repMkt, miss

	*gen rand_num = uniform()
	*by loccode (rand_num), sort: gen sample_repMkt = _n==1
	*tab sample_repMkt, miss

	keep ln ge02 ge03 vn Mkt rand_num sample_repMkt* m1q9a m1q9b m1q0d worse_pov_FemaleV worse_incomeGp_FemaleV worse_incomeGp_FemaleV15 base_belief_overcharge ocbase_belief_overcharge fcbase_belief_overcharge mcbase_belief_overcharge under_bbelief under_bbelief_fc market_to_drop
	*keep ln loccode vendor_id vn cn Mkt rand_num sample_repMkt m1q9a c1q8a m1q9b c1q8b m1q0d c1q0b

	**more cleaning? 3 more drops...no info
	drop if market_to_drop == 1
	tab sample_repMkt, miss //130 loc or repMkts now...
	
		** bring in non-anonymized markets. What's the difference?
		rename ge0* ge0*_anon
		merge 1:1 ge03_anon using "$dta_loc_repl/00_raw/crosswalk_ge03", keep (1 3)
		merge 1:1 ge03 using "/Users/yazenkashlan/Library/CloudStorage/OneDrive-Personal/Documents/personal/Berk/03_Work/Francis/Replication/data_test/01_intermediate/repMkt"
		// CONTINUE HERE
		
	save "$dta_loc_repl/01_intermediate/repMkt", replace
restore

**QUEST: ***balance achieved -- DIFF from population?
merge m:1 ge02 ge03 using "$dta_loc_repl/01_intermediate/repMkt.dta"

** save
save "$dta_loc_repl/01_intermediate/repMkt_w_xtics", replace

