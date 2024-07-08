/*
Generate mkt_aiVendorBetter
Input: 
	- Mkt_fieldData_census
Output:
	- mkt_aiVendorBetter
*/

**Xavi - why spillovers?
*either (i) communication (v*-v, c*-c)? or (ii) shopping around (c*-v)?
*dependence on degree of AI?


use "$dta_loc_repl/01_intermediate/Mkt_fieldData_census", clear

**Asymmetric Tnformation Test**
bys loccode: egen mkt_m_corrects2 = mean(m_corrects)
bys loccode: egen mkt_c_corrects2 = mean(c_corrects)

bys loccode: egen mkt_c_fracAnyEduc = mean(cEducAny)
bys loccode: egen mkt_c_avgEducLevel = mean(cEduc)
gen primandlesssEduc = (cEduc<=2) if !missing(cEduc)
bys loccode: egen mkt_c_fracprimandlesssEduc = mean(primandlesssEduc)

bys loccode: keep if _n==1
bys loccode: gen mkt_aigap = mkt_m_corrects2-mkt_c_corrects2
bys loccode: gen mkt_aiVendorBetter = (mkt_m_corrects2>mkt_c_corrects2) if !missing(mkt_aigap)
gen ge02 = ln // locName
bys ge02: gen x=_N
rename locality_name locality_nameBase
keep mkt_aigap mkt_aiVendorBetter mkt_c_corrects2 mkt_m_corrects2 mkt_c_fracAnyEduc mkt_c_avgEducLevel mkt_c_fracprimandlesssEduc ge02 locality_nameBase ln x loccode


saveold "$dta_loc_repl/01_intermediate/mkt_aiVendorBetter.dta", replace
