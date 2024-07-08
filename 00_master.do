/*
Master file for _annan_MRIxrev01_May.21.2023.pdf
Date: 6/20/2024

*/

** Initialize
clear all
set graphics off
set seed 100001 // from scripts: demand, revenues
global bootstrap_reps 100


** set globals
if c(username) == "yazenkashlan" {
	global dta_loc 		"/Users/yazenkashlan/Dropbox/_rGroup-finfraud"
	global dta_loc_repl "/Users/yazenkashlan/Library/CloudStorage/OneDrive-Personal/Documents/personal/Berk/03_Work/Francis/Replication/data"
	global do_loc 		"/Users/yazenkashlan/Documents/GitHub/annan2024_misconduct"
	global output_loc 	"/Users/yazenkashlan/Documents/GitHub/annan2024_misconduct/output"
}
if c(username) == "______" {
	global dta_loc "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud"
	global do_loc "" // enter do file location
}
if c(username) == "______" {
	global dta_loc "/Users/fa2316/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud"
	global do_loc "" // enter do file location
}


** install programs
// do "$do_loc/01_programs"
do "$do_loc/02_anonymize"

** raw data prep
do "$do_loc/_baselother-sampling" 		// generate Treatments_4gps_9dist


** baseline data prep
do "$do_loc/_basel-Commands_Test_goodstuff"
do "$do_loc/_basel-gender"
do "$do_loc/_basel-repMkt"

** treatment assigmnent
do "$do_loc/_basel-interventions1" 		// generate ONLY_4TrtGroups_9dist
do "$do_loc/_basel-interventions2" 		// generate interventionsTomake_list_local

** Merchants and customers data
do "$do_loc/_baselother-customer" 		// generate CustomersData data
do "$do_loc/_baselother-merchant" 		// generate MerchantsData data

** combine
do "$do_loc/_basel2-adminTransactData" 	// generate adminTransactData and ofdrate_mktadminTransactData
do "$do_loc/_basel2-combine" 			// combine int + mkt census
do "$do_loc/_basel2-combine2" 			// combine int + mkt census + customer (commented out sqreg and gen. item=y)
do "$do_loc/_basel2-mkt_ai" 		 	// generate mkt_aiVendorBetter
do "$do_loc/_baselother-FinalAuditData" // generate ofdrate_mktAudit_endline

version 10
do "$do_loc/_followups-organized_surveys"
version 18

** Main analysis
do "$do_loc/Beliefs_Mar.19.2023.do"
do "$do_loc/Demand_Mar.19.2023.do"
do "$do_loc/Misconduct_Mar.19.2023.do"
do "$do_loc/Revenues_Mar.19.2023.do"
do "$do_loc/Shocks_Mar.19.2023.do"


