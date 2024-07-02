/*
Prepare data by gender

[Change path of sampling? data]

*/


**Mkt census: Get percent of femal vendors per locality; competition measure=hhi?
use "$dta_loc_repl/01_intermediate/Mkt_fieldData_census", clear
gen double localityCode_j=loccode
drop _merge
merge m:1 localityCode_j using "$dta_loc/sampling?/sel_9Distr_137Local_List"
keep if _merge==3

**all vendors per locality =137 all here**
bys districtName loccode vendor_id: keep if _n==1

**%of Female v's? Say, at least 3 vendors in locality
bys loccode: egen pct_female = mean(mfemale)
bys loccode: replace pct_female = pct_female*100

bys loccode: gen sN =_N
replace pct_female=. if sN <2
twoway histogram pct_female, frac ytitle("Fraction of localities") xtitle("% Female vendors per locality")
*gr export "$dta_loc/_project/pct_female_hist.eps", replace


**Competition, hhi
gen dailyTotMoney2=m2q4b //can use monthly sale: m1q8--correlates very well? 
bys loccode: egen double sumdSales = sum(dailyTotMoney2)
bys loccode: gen double shsqrd = (dailyTotMoney2/sumdSales)^2 
bys loccode: egen double HHI=sum(shsqrd)
*hist HHI //clean later? yes. drop missings etc..

ge ge01 =districtName
gen ge02 =localityName 
gen ge03 =vn
gen double loccodee= loccode

keep pct_female HHI mfemale loccode loccodee sN ge01 ge02 ge03  
keep pct_female HHI mfemale loccode sN
*bys loccode: keep if _n==1

saveold "$dta_loc_repl/01_intermediate/pct_female_Mktcensus", replace
saveold "$dta_loc_repl/01_intermediate/pct_female_MktcensusStar", replace
