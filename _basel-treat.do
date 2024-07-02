/*
Randomization

[Confirm: how much of this do we need in the repl package?]

*/


/*
**ONLY: dta for field-Auditors: the 130 repMkts?
use repMkt, clear
tab sample_repMkt, miss
keep if sample_repMkt==1

gen double localityCode_j=loccode

merge 1:1 localityCode_j using "$dta_loc/sampling?/sel_9Distr_137Local_List"
keep if _merge==3

label var vendor_id "vendor ID - unique only within locality"
gen vDescribe = m1q0d
label var vDescribe "Describe location -- vendor"
gen double vPhone1=m1q9a
label var vPhone1 "Phone number -- primary"
gen double vPhone2=m1q9b
label var vPhone2 "Phone number -- secondary"
label var sample_repMkt "indicator for randomly selected vendor to represent a locality, 1=Selected, 0=notSelected"

gen districtID = regionDistrictCode_j
label var districtID "District code/ ID -- unique"


tostring loccode, gen(loccodex) format(%17.0g)
tostring vPhone1, gen(vPhone1x) format(%17.0g)
tostring vPhone1, gen(vPhone1xx) format(%010.0f)

tostring vPhone2, gen(vPhone2x) format(%17.0g)
tostring vPhone2, gen(vPhone2xx) format(%010.0f)

order districtID districtName loccode loccodex ln vn vendor_id vDescribe vPhone1 vPhone1x vPhone1xx vPhone2 vPhone2x vPhone2xx sample_repMkt
keep districtID districtName loccode loccodex ln vn vendor_id vDescribe vPhone1 vPhone1x vPhone1xx vPhone2 vPhone2x vPhone2xx sample_repMkt
tab districtID
tab districtName

saveold AuditsTomake_list, replace
outsheet using AuditsTomake_list.xls, replace
*/



/*
**Becky -- risk attitudes: 1/3rd of 130 rep vendor? 
**let's sample from where gap is "coming from" vs "not"
use AuditsTomake_list, clear
gen distName= districtName
tab distName
keep if (distName == "Lower Manya Krobo" | distName == "Yilo Krobo") | (distName == "Suhum Municipal" | distName == "New Juaben Municipal")

saveold AuditsTomake_list, replace
outsheet using AuditsTomake_list.xls, replace
*/


**audit list 2: july 31 2020?
use repMkt, clear
tab sample_repMkt, miss
bys loccode: gen no_vendors=_N
bys loccode: gen newMkt = _n==1 if no_vendors>1
gen sample_repMktII = sample_repMkt
replace sample_repMktII=newMkt if (no_vendors>1 & sample_repMkt==0)
keep if sample_repMktII==1

gen double localityCode_j=loccode

merge m:1 localityCode_j using "$dta_loc/sampling?/sel_9Distr_137Local_List"
keep if _merge==3
drop _merge

label var vendor_id "vendor ID - unique only within locality"
gen vDescribe = m1q0d
label var vDescribe "Describe location -- vendor"
gen double vPhone1=m1q9a
label var vPhone1 "Phone number -- primary"
gen double vPhone2=m1q9b
label var vPhone2 "Phone number -- secondary"
label var sample_repMkt "indicator for randomly selected vendor to represent a locality, 1=Selected, 0=notSelected"
label var sample_repMktII "indicator for randomly selected vendor to represent a locality-end, 1=endSelected, 0=endnotSelected"

gen districtID = regionDistrictCode_j
label var districtID "District code/ ID -- unique"


tostring loccode, gen(loccodex) format(%17.0g)
tostring vPhone1, gen(vPhone1x) format(%17.0g)
tostring vPhone1, gen(vPhone1xx) format(%010.0f)

tostring vPhone2, gen(vPhone2x) format(%17.0g)
tostring vPhone2, gen(vPhone2xx) format(%010.0f)

*order districtID districtName loccode loccodex ln vn vendor_id vDescribe vPhone1 vPhone1x vPhone1xx vPhone2 vPhone2x vPhone2xx sample_repMkt sample_repMktII
*keep districtID districtName loccodex ln vn vendor_id vDescribe vPhone1x vPhone1xx vPhone2x vPhone2xx sample_repMkt sample_repMktII
tab districtID
tab districtName

**for Treated="yes" remind them prior to...
merge m:1 loccodex using ONLY_4TrtGroups_9dist
gen Treated = "yes" 
replace Treated = "no" if treatment==0

keep districtID districtName loccodex ln vn vendor_id vDescribe vPhone1x vPhone1xx vPhone2 vPhone2x vPhone2xx Treated treatment
order districtID districtName loccodex ln vn vendor_id vDescribe vPhone1x vPhone1xx vPhone2 vPhone2x vPhone2xx Treated treatment

saveold end_AuditsTomake_list, replace
outsheet using end_AuditsTomake_list.xls, replace

use end_AuditsTomake_list, clear
 
/*
**III. 2X2 randomization for interventions
**representative? district (bring in)?
*use "$dta_loc/sampling?/sel_9Distr_137Local_List", clear
*randtreat, generate(treatment) replace unequal(1/4 1/4 1/4 1/4) strata(regionDistrictCode_j) misfits(wstrata) setseed(12345)
*tab treatment, miss
*tab regionDistrictCode_j treatment

*gen double loccode=localityCode_j
*merge 1:m loccode using "Mkt_fieldData_sample_repMkt"
*keep if _merge==3
*keep if sample_repMkt==1

use AuditsTomake_list, clear
randtreat, generate(treatment) replace unequal(1/4 1/4 1/4 1/4) strata(districtID) misfits(wstrata) setseed(12345)
tab treatment, miss
tab districtID treatment
save ONLY_4TrtGroups_9dist, replace
**maps: show ctrl-Trt units are apart...

**get all data together again? merge by locals
merge 1:m loccode using "Mkt_fieldData_sample_repMkt"

keep if _merge==3

keep if sample_repMkt==1
drop sample_repMkt

tab treatment, miss
tab districtID treatment
sort districtID loccode treatment
br districtID loccode ln treatment
saveold "Mkt_fieldData_sample_hfreq_4TrtGroups_9dist", replace


**pre-intervention balance and validity of trts?
tab treatment, gen(Trt)

*order districtName regionDistrictCode_j localityName localityCode_j
*sort regionDistrictCode_j localityCode_j
*br districtName regionDistrictCode_j localityName localityCode_j treatment Trt*

gen trt01 = .
replace trt01 = 0 if treatment==0
replace trt01 = 1 if treatment==1

gen trt02 = .
replace trt02 = 0 if treatment==0
replace trt02 = 1 if treatment==2

gen trt03 = .
replace trt03 = 0 if treatment==0
replace trt03 = 1 if treatment==3


gen trt0vsall = (treatment !=0)
*br districtName regionDistrictCode_j localityName localityCode_j treatment Trt* trt*

**Supply side: merchants...?
reg dailyNobCustomers i.treatment, cluster(loccode)
reg CustPer_w_Mkt i.treatment, cluster(loccode)
reg dailyTotMoney i.treatment, cluster(loccode)
reg dailyNobCustomers_nonM i.treatment, cluster(loccode)
reg dailyTotMoney_nonM i.treatment, cluster(loccode)

reg mfemale i.treatment, cluster(loccode)
reg makan i.treatment, cluster(loccode)
reg mmarried i.treatment, cluster(loccode)
reg mage i.treatment, cluster(loccode)
reg mEducAny i.treatment, cluster(loccode)
reg mselfemployed i.treatment, cluster(loccode)
reg mselfIncome i.treatment, cluster(loccode)
reg mbusTrained i.treatment, cluster(loccode)
reg m_pov_likelihood i.treatment, cluster(loccode)
**poverty?
reg m4q1 i.treatment, cluster(loccode)
reg m4q2 i.treatment, cluster(loccode)
reg m4q3 i.treatment, cluster(loccode)
reg m4q4 i.treatment, cluster(loccode)
reg m4q5 i.treatment, cluster(loccode)
reg m4q6 i.treatment, cluster(loccode)
reg m4q7 i.treatment, cluster(loccode)
reg m4q8 i.treatment, cluster(loccode)
reg m4q9 i.treatment, cluster(loccode)
reg m4q10 i.treatment, cluster(loccode)


**Demand side: customers...?
reg cfAttempts i.treatment, cluster(loccode)
reg _Xcfraud i.treatment, cluster(loccode)

reg wklyNobUsage i.treatment, cluster(loccode)
reg wklyTotUseVol i.treatment, cluster(loccode)
reg wklyNobUsage_nonM i.treatment, cluster(loccode)
reg wklyTotUseVol_nonM i.treatment, cluster(loccode)

reg wklyNobBorrow i.treatment, cluster(loccode)
reg wklyTotBorrowVol i.treatment, cluster(loccode)
reg wklyNobSave i.treatment, cluster(loccode)
reg wklyTotSaveVol i.treatment, cluster(loccode)

reg cfemale i.treatment, cluster(loccode)
reg cakan i.treatment, cluster(loccode)
reg cmarried i.treatment, cluster(loccode)
reg cage i.treatment, cluster(loccode)
reg cEducAny i.treatment, cluster(loccode)
reg cselfemployed i.treatment, cluster(loccode)
reg cselfIncome i.treatment, cluster(loccode)
reg cMMoneyregistered i.treatment, cluster(loccode)
reg c_pov_likelihood i.treatment, cluster(loccode)
**poverty?
reg c2q1 i.treatment, cluster(loccode)
reg c2q2 i.treatment, cluster(loccode)
reg c2q3 i.treatment, cluster(loccode)
reg c2q4 i.treatment, cluster(loccode)
reg c2q5 i.treatment, cluster(loccode)
reg c2q6 i.treatment, cluster(loccode)
reg c2q7 i.treatment, cluster(loccode)
reg c2q8 i.treatment, cluster(loccode)
reg c2q9 i.treatment, cluster(loccode)
reg c2q10 i.treatment, cluster(loccode)
**achieved strong balance on Trt vs Ctr...


***or Try
forval t=1/3{
reg dailyNobCustomers trt0`t'
reg CustPer_w_Mkt trt0`t'
reg dailyTotMoney trt0`t'
reg dailyNobCustomers_nonM trt0`t'
reg dailyTotMoney_nonM trt0`t'

reg mfemale trt0`t'
reg makan trt0`t'
reg mmarried trt0`t'
reg mage trt0`t'
reg mEducAny trt0`t'
reg mselfemployed trt0`t'
reg mselfIncome trt0`t'
reg mbusTrained trt0`t'
reg m_pov_likelihood trt0`t'

reg trt0`t' mfemale makan mmarried mage mEducAny mselfemployed mselfIncome mbusTrained m_pov_likelihood, cluster(loccode)
}


**supply/vendor side?
**merchant: transactions?
forval t=1/4{
reg dailyNobCustomers Trt`t', cluster(loccode)
reg CustPer_w_Mkt Trt`t', cluster(loccode)
reg dailyTotMoney Trt`t', cluster(loccode)
reg dailyNobCustomers_nonM Trt`t', cluster(loccode)
reg dailyTotMoney_nonM Trt`t', cluster(loccode)
}

**merchant: xtics?
forval t=1/4{
reg mfemale Trt`t'
reg makan Trt`t'
reg mmarried Trt`t'
reg mage Trt`t'
reg mEducAny Trt`t'
reg mselfemployed Trt`t'
reg mselfIncome Trt`t'
reg mbusTrained Trt`t'
reg m_pov_likelihood Trt`t'
}

**joint test:exlude Y's?
forval t=1/4{
reg Trt`t' mfemale makan mmarried mage mEducAny mselfemployed mselfIncome mbusTrained
}



**demand/consumer side
**customer: fraud?
forval t=1/4{
reg cfAttempts Trt`t'
reg _Xcfraud Trt`t'
}

**cutomer: transactions
forval t=1/4{
reg wklyNobUsage Trt`t'
reg wklyTotUseVol Trt`t'
reg wklyNobUsage_nonM Trt`t'
reg wklyTotUseVol_nonM Trt`t'
}

**customer: borrow + save behavior?
forval t=1/4{
reg wklyNobBorrow Trt`t'
reg wklyTotBorrowVol Trt`t'
reg wklyNobSave Trt`t'
reg wklyTotSaveVol Trt`t'
}

**customer: xtics?
forval t=1/4{
reg cfemale Trt`t'
reg cakan Trt`t'
reg cmarried Trt`t'
reg cage Trt`t'
reg cEducAny Trt`t'
reg cselfemployed Trt`t'
reg cselfIncome Trt`t'
reg cMMoneyregistered Trt`t'
reg c_pov_likelihood Trt`t'
}
**joint test:exlude Y's?
forval t=1/4{
reg Trt`t' cfemale cakan cmarried cage cEducAny cselfemployed cselfIncome
}
**OK. Much balance achieved...

**update dta
drop _merge
saveold "Mkt_fieldData_sample_hfreq_4TrtGroups_9dist", replace

*log close
*/
