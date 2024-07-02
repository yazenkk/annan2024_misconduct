/*
Gender: analyze
*/


use "$dta_loc_repl/01_intermediate/pct_female_Mktcensus", clear


**vary by gender?
gr tw (kdensity HHI if mfemale==0, lpattern(dash)) || (kdensity HHI if mfemale==1, lpattern(solid) xtitle("Herfindahl-Hirschman index: n (Males)=231, n (Females)=157") ytitle("Kdensity") legend(pos(3) col(1) stack label(1 "Males") label(2 "Females")))
gr export "$dta_loc/_project/hhibyGender.eps", replace

drop if missing(HHI)
drop if missing(mfemale)
cdfplot HHI, by(mfemale) opt1(lc(blue red)) xtitle("Herfindahl-Hirschman index: n (Males)=231, n (Females)=157") ytitle("CDF") legend(pos(3) col(1) stack label(1 "Males") label(2 "Females"))
*gr export "$dta_loc/_project/hhibyGender_cdf.eps", replace

reg HHI mfemale, r
reg HHI mfemale, cluster(loccode)

ksmirnov HHI, by(mfemale)
ksmirnov HHI, by(mfemale) exact //perhaps parts of distr? no power
