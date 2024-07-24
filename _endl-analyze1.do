/*
Appendix figures: B.8

*/


use "$dta_loc_repl/00_Raw_anon/analyzed_EndlineAuditData.dta", clear

** Figure B.8 ------------------------------------------------------------------
keep if trt==0 & _merge==3
*bys xv_locality xv_vendor: keep if _n==1
tab nq1
sum nq1, d //above median - preserve variance
gen reputeNo=(nq1<=3)
gen reputeYes=(nq1>3)
tab reputeNo
tab reputeYes
sum reputeNo reputeYes
ttesti 384 0.19 0.39 384 0.81 0.39 //pval=0.000

gr bar reputeNo reputeYes

graph hbar reputeNo reputeYes, bar(1, color(black)) bar(2, color(gs8)) nofill asyvars ///
 blabel(group, position(inside) format(%4.2f) box fcolor(white) lcolor(white)) ytitle("Market Reputation Important:  Share indicating no vs yes", size(small)) blabel(bar) ///
 legend(pos(7) row(1) stack label(1 "Reputation important=No") label(2 "Reputation important=Yes"))
gr export "$output_loc/reputation_important_graph.eps", replace
