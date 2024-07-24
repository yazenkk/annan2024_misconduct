/*
Appendix material: 
	- Figure B.6
	- Table B.9
*/



use "$dta_loc_repl/01_intermediate/adminTransactData", clear



** Figure B.6 ------------------------------------------------------------------
ciplot fYes_T, level(90) by(tranType) xlabel(, angle(55) labsize(small)) yline(0, lp(dash)) xline(22 30, lp(dash) lc(black)) ytitle("Probability (Misconduct)", size(small)) xtitle("Transaction Group") note("")
gr export "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/_project/misconduct_yesB.eps", replace
ciplot sv_fAmt_T, level(90) by(tranType) xlabel(, angle(55) labsize(small)) yline(0, lp(dash)) xline(22 30, lp(dash) lc(black)) ytitle("Amount-misconduct (GHS)", size(small)) xtitle("Transaction Group") note("")
gr export "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/_project/misconduct_amtB.eps", replace



** Figure B.9 ------------------------------------------------------------------
tabstat fYes_T sv_fAmt_T, by(transactK) stat(mean sd) col(stat) long
tabstat fYes_T sv_fAmt_T, by(tranType) stat(mean sd) col(stat) long
