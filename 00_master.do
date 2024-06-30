/*
Master file for _annan_MRIxrev01_May.21.2023.pdf
Date: 6/20/2024

*/


** set globals
if c(username) == "yazenkashlan" {
	global dta_loc "/Users/yazenkashlan/Dropbox/_rGroup-finfraud"
	global do_loc "/Users/yazenkashlan/Documents/GitHub/annan2024_misconduct"
}
if c(username) == "______" {
	global dta_loc "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud"
	global do_loc "" // enter do file location
}
if c(username) == "______" {
	global dta_loc "/Users/fa2316/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud"
	global do_loc "" // enter do file location
}


set seed 100001 // from scripts: demand, revenues


** install programs
do "$do_loc/01_programs"
