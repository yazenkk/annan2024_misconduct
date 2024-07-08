/*

Source: sampling?/sampling?9
 
Input:
	- er-gazetteer
	- 00_raw/er-reg-district-codes
Output: 
	- 00_raw/Treatments_4gps_9dist
	- 00_raw/sel_9Distr_137Local_List
*/


**Get gazetteer-er data 
import excel "$dta_loc_repl/00_Raw/er-gazetteer.xlsx", sheet("Sheet1") firstrow clear

**
**9 districts? with following parameter...137 Mkts
keep if (regionDistrictCode=="0513" | regionDistrictCode=="0508" | regionDistrictCode=="0506" ///
	| regionDistrictCode=="0504" | regionDistrictCode=="0507" | regionDistrictCode=="0503" ///
	| regionDistrictCode=="0509" | regionDistrictCode=="0505" | regionDistrictCode=="0510")

** Nine districts
*13=e Akim
*08=yilo Krobo
*06=Akwapim north
*04=suhum municipal ?
*07=n juaben municipal
*03=w Akim municipal
*09=lower Manya Krobo
*05=Nsawam adoagyir municipal
*10=Asuogyaman


***use all [=9] districts? with following parameters...410 [=137] Mkts
** pop?
sum populationTotal
keep if (populationTotal>=1000 & populationTotal<=20000)
sum populationTotal, d //mean=3900, median=2300 ppl as of 2018
gen _Track=1



*browse
sort regionDistrictCode populationTotal

destring regionDistrictCode, gen(regionDistrictCode_j) 
list regionDistrictCode_j in 1/5

destring localityCode, gen(localityCode_j) 
list localityCode_j in 1/5

tempfile junk_er3_9
save 	`junk_er3_9'


**let's add disrict names?
import excel "$dta_loc_repl/00_Raw/er-reg-district-codes.xlsx", sheet("Sheet1") firstrow clear
rename RegDistCode regionDistrictCode
rename District districtName

merge 1:m regionDistrictCode using `junk_er3_9'
sort regionDistrictCode populationTotal

order districtName regionDistrictCode regionDistrictCode_j localityName localityCode localityCode_j
drop _merge

keep if _Track==1

**randomize into 4 groups 2X2 design (strata=district)...
gen geo_dist = regionDistrictCode_j
*xtile pop_quarts = populationTotal, nq(2)
egen strata = group(geo_dist)

set seed 123456
gen rand_num = uniform()
bysort strata: egen ordering = rank(rand_num)
gen group = ""
bysort strata: replace group = "C" if ordering <= _N/4 
forvalues i = 1/3 {
	bysort strata: replace group = "T`i'" if ordering <= (`i'+1)*_N/4 & ordering > `i'*_N/4 
}
***
tab group, miss

**JUST use "randtreat" command (deals with misfits..)
randtreat, generate(treatment) replace unequal(1/4 1/4 1/4 1/4) strata(geo_dist) misfits(wstrata) setseed(123456)
tab treatment, miss
save "$dta_loc_repl/00_raw/Treatments_4gps_9dist", replace


**store our selected 137 district-locality pairs list only
keep districtName regionDistrictCode_j localityName localityCode_j
saveold "$dta_loc_repl/00_raw/sel_9Distr_137Local_List", replace
