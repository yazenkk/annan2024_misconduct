/*
Analyze baseline data

Input:
	- 01_intermediate/Mkt_fieldData_census
	
Output:
	- Figure B.9
*/



**Trust level for performing money transactions?
use "$dta_loc_repl/01_intermediate/Mkt_fieldData_census", clear

graph hbar trustNo trustYes, bar(1, color(black)) bar(2, color(gs8)) nofill asyvars ///
 blabel(group, position(inside) format(%4.2f) box fcolor(white) lcolor(white)) ytitle("Trust in Transacting:  Share indicating no vs yes", size(small)) blabel(bar) ///
 legend(pos(7) row(1) stack label(1 "Trust=No") label(2 "Trust=Yes"))
gr export "$output_loc/trust_transacting_graph.eps", replace



