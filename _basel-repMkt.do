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
bys loccode: gen CustPerLocal= _N
hist CustPerLocal //dis: tot no of cust per local
sum CustPerLocal // 1 to 47 with avg=20.8<21 customers

egen count_loccode=group(loccode)
tab count_loccode, miss //137-> 134 (115?) success

egen local_by_vendor = group(loccode vendor_id)
tab local_by_vendor, miss //480-> 337 (315?) a drop
tab Mkt, miss //480-> 337 (315?) a drop

bys loccode: gen mktFip = group(vendor_id)

hist MktPerLocal //dis: tot no of Mkt(/merch) per local
sum MktPerLocal // 1 to 12 with avg=3.2<4 merchants
tab MktPerLocal

bys loccode vendor_id: gen CustPer_w_Mkt = _N
hist CustPer_w_Mkt //dis: tot no of within-Cust per mkt
tab CustPer_w_Mkt



**get "rep market" per each locality?
preserve 
	bys loccode vendor_id: keep if _n==1

	set seed 12345
	bys loccode: gen rand_num = uniform()
	bys loccode: gen x = _N
	by loccode (rand_num), sort: gen sample_repMkt = _n==x
	tab sample_repMkt, miss

	*gen rand_num = uniform()
	*by loccode (rand_num), sort: gen sample_repMkt = _n==1
	*tab sample_repMkt, miss

	keep ln loccode vendor_id vn Mkt rand_num sample_repMkt* m1q9a m1q9b m1q0d worse_pov_FemaleV worse_incomeGp_FemaleV worse_incomeGp_FemaleV15 base_belief_overcharge ocbase_belief_overcharge fcbase_belief_overcharge mcbase_belief_overcharge under_bbelief under_bbelief_fc
	*keep ln loccode vendor_id vn cn Mkt rand_num sample_repMkt m1q9a c1q8a m1q9b c1q8b m1q0d c1q0b

	**more cleaning? 3 more drops...no info
	drop if (m1q0d=="")
	drop if (m1q0d=="PABI" | m1q0d=="XXX" | vn=="XXXXXX")
	tab sample_repMkt, miss //130 loc or repMkts now...
	save "$dta_loc_repl/01_intermediate/repMkt", replace
restore

**QUEST: ***balance achieved -- DIFF from population?
merge m:1 loccode vendor_id using "$dta_loc_repl/01_intermediate/repMkt.dta"

** save
save "$dta_loc_repl/01_intermediate/repMkt_w_xtics", replace

