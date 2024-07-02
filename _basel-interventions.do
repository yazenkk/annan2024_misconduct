/*
Interventions

Input:
	- 
	
Output:
	- 
	
[Confirm: do we need this for later analysis]
*/




**ONLY: dta for office-Officers: intervention seeders/planters
**launch to: only repVendors + only nearby-local? [all-global?] customers?
use repMkt.dta, clear
keep if sample_repMkt==1
keep loccode vendor_id 
merge 1:m loccode vendor_id using  "_CM_all_2_18.dta"
*merge 1:m loccode using  "_CM_all_2_18.dta"
keep if _merge==3

bys loccode vendor_id: gen x=_N
tab x

**let's check? very good...
*bys loccode vendor_id: keep if _n==1
*br
keep loccode vendor_id custcode cn c1q0b c1q8a c1q8b
saveold ONLY_repMkt, replace


use ONLY_4TrtGroups_9dist, clear
merge 1:m loccode vendor_id using ONLY_repMkt.dta
bys loccode vendor: gen xx=_N
tab xx //1-25 customers; only nearby customers that surround repMkt (not all in locality possibly)
sum xx
tab treatment //ctr=185c, pt=272, mr=257, joint=276

**label vendor side??
label var vendor_id "vendor ID - unique only within locality"
label var vn "vendor name"

**label customer side??
gen customer_id = custcode
label var customer_id "customer ID - unique only within locality"
label var cn "customer name, nearby"
gen cDescribe = c1q0b
label var cDescribe "Describe location -- customer nearby"
gen double cPhone1=c1q8a
label var cPhone1 "Phone number -- primary, customer nearby"
gen double cPhone2=c1q8b
label var cPhone2 "Phone number -- secondary, customer nearby"

**get things in strings for CAPI
*tostring loccode, gen(loccodex) format(%17.0g)

*tostring vPhone1, gen(vPhone1x) format(%17.0g)
*tostring vPhone1, gen(vPhone1xx) format(%010.0f)
*tostring vPhone2, gen(vPhone2x) format(%17.0g)
*tostring vPhone2, gen(vPhone2xx) format(%010.0f)

tostring cPhone1, gen(cPhone1x) format(%17.0g)
tostring cPhone1, gen(cPhone1xx) format(%010.0f)
tostring cPhone2, gen(cPhone2x) format(%17.0g)
tostring cPhone2, gen(cPhone2xx) format(%010.0f)

order districtID districtName loccode loccodex ln ///
vn vendor_id vDescribe vPhone1 vPhone1x vPhone1xx vPhone2 vPhone2x vPhone2xx ///
cn customer_id cDescribe cPhone1 cPhone1x cPhone1xx cPhone2 cPhone2x cPhone2xx treatment

gen intervention =""
replace intervention="Control" if treatment==0
replace intervention="PriceTransparency, PT" if treatment==1
replace intervention="MKtMonitoring, MM" if treatment==2
replace intervention="joint: PT+MM" if treatment==3
label var intervention "intervention or treatment type to implement"

keep districtID districtName loccode loccodex ln ///
vn vendor_id vDescribe vPhone1 vPhone1x vPhone1xx vPhone2 vPhone2x vPhone2xx ///
cn customer_id cDescribe cPhone1 cPhone1x cPhone1xx cPhone2 cPhone2x cPhone2xx treatment intervention 

**last adjustment
replace vn="or ask Sammy on-0243289914" if (districtName=="Asuogyaman" & ln=="OSIABURA")
replace vPhone1x="or ask Sammy on-0243289914" if (districtName=="Asuogyaman" & ln=="OSIABURA")
replace vDescribe="1st vendoor on left around where the town starts from Atempoku coming" if (districtName=="Asuogyaman" & ln=="OSIABURA")

drop if treatment==0
*bys loccode: keep if _n==1

*saveold interventionsTomake_list_local, replace
saveold interventionsTomake_list_local_onlyTs, replace
outsheet using interventionsTomake_list_local_onlyTs.xls, replace
*saveold interventionsTomake_list_global, replace
*outsheet using interventionsTomake_list_global.xls, replace

*********************
**modifications? Sammy...
keep if ln=="ANYINASIN" // vlocation: (oposite presby church)* // YK: zero observations
*****************
******************


/*
**balance tests II? July 4, 2020
use Mkt_fieldData_sample_repMkt, clear
merge m:m loccode vendor_id using "interventionsTomake_list_local"
keep if _merge==3

use interventionsTomake_list_local, clear
gen trt0vsall = (treatment !=0)
*br districtName regionDistrictCode_j localityName localityCode_j treatment Trt* trt*

**Supply side: merchants...?
reg mfemale i.treatment, cluster(loccode)
reg makan i.treatment, cluster(loccode)
reg mmarried i.treatment, cluster(loccode)
reg mage i.treatment, cluster(loccode)
reg mEducAny i.treatment, cluster(loccode)
reg mselfemployed i.treatment, cluster(loccode)
*reg mselfIncome i.treatment, cluster(loccode) //fine but too many already
reg mbusTrained i.treatment, cluster(loccode)

**poverty?
reg m4q1 i.treatment, cluster(loccode)
*reg m4q2 i.treatment, cluster(loccode)
reg m4q3 i.treatment, cluster(loccode)
reg m4q4 i.treatment, cluster(loccode)
reg m4q5 i.treatment, cluster(loccode)
*reg m4q6 i.treatment, cluster(loccode)
*reg m4q7 i.treatment, cluster(loccode)
*reg m4q8 i.treatment, cluster(loccode)
reg m4q9 i.treatment, cluster(loccode)
reg m4q10 i.treatment, cluster(loccode)
reg m_pov_likelihood i.treatment, cluster(loccode) //just report this index?


*reg dailyNobCustomers i.treatment, cluster(loccode) //fine but too many already
*reg CustPer_w_Mkt i.treatment, cluster(loccode) //fine but too many already
reg dailyTotMoney i.treatment, cluster(loccode)
reg dailyNobCustomers_nonM i.treatment, cluster(loccode)
reg dailyTotMoney_nonM i.treatment, cluster(loccode)

**joint, exclude main Y
reg trt0vsall mfemale mmarried makan mage mEducAny mselfemployed mselfIncome mbusTrained, cluster(loccode)
test mfemale mmarried makan mage mEducAny mselfemployed mselfIncome mbusTrained

probit trt0vsall mfemale mmarried makan mage mEducAny mselfemployed mselfIncome mbusTrained, cluster(loccode)
test mfemale mmarried makan mage mEducAny mselfemployed mselfIncome mbusTrained




**Demand side: customers...?
reg cfemale i.treatment, cluster(loccode)
reg cakan i.treatment, cluster(loccode)
reg cmarried i.treatment, cluster(loccode)
reg cage i.treatment, cluster(loccode)
reg cEducAny i.treatment, cluster(loccode)
reg cselfemployed i.treatment, cluster(loccode)
*reg cselfIncome i.treatment, cluster(loccode) //fine but too manay already
reg cMMoneyregistered i.treatment, cluster(loccode)

**poverty?
reg c2q1 i.treatment, cluster(loccode)
*reg c2q2 i.treatment, cluster(loccode)
reg c2q3 i.treatment, cluster(loccode)
reg c2q4 i.treatment, cluster(loccode)
reg c2q5 i.treatment, cluster(loccode)
*reg c2q6 i.treatment, cluster(loccode)
*reg c2q7 i.treatment, cluster(loccode)
*reg c2q8 i.treatment, cluster(loccode)
reg c2q9 i.treatment, cluster(loccode)
reg c2q10 i.treatment, cluster(loccode)
reg c_pov_likelihood i.treatment, cluster(loccode) //just report this index?
**achieved strong balance on Trt vs Ctr...


reg cfAttempts i.treatment, cluster(loccode)
reg _Xcfraud i.treatment, cluster(loccode)


reg distToBank i.treatment, cluster(loccode)
reg distToMMoney i.treatment, cluster(loccode)


reg wklyTotUseVol i.treatment, cluster(loccode)
reg wklyNobUsage_nonM i.treatment, cluster(loccode)
reg wklyTotUseVol_nonM i.treatment, cluster(loccode)

reg likelyborrowMMoney i.treatment, cluster(loccode)
reg likelysaveMMoney i.treatment, cluster(loccode)


**joint, exclude main Y?
reg trt0vsall cfemale cmarried cakan cage cEducAny cselfemployed cselfIncome cMMoneyregistered, cluster(loccode)
test cfemale cmarried cakan cage cEducAny cselfemployed cselfIncome cMMoneyregistered
probit trt0vsall cfemale cakan cmarried cage cEducAny cselfemployed cselfIncome cMMoneyregistered, cluster(loccode)
test cfemale cmarried cakan cage cEducAny cselfemployed cselfIncome cMMoneyregistered

*/





**I: Get locality vendor list roster--only Ts**
use interventionsTomake_list_local_onlyTs, clear
bys loccode: keep if _n==1 //Trt localities=98
keep loccodex
saveold junk_interventionsTomake_list_local_onlyTs, replace

use Mkt_fieldData_census, clear
gen double localityCode_j=loccode
drop _merge
merge m:1 localityCode_j using "$dta_loc/sampling?/sel_9Distr_137Local_List"
keep if _merge==3

label var vendor_id "vendor ID - unique only within locality"
gen vDescribe = m1q0d
label var vDescribe "Describe location -- vendor"
gen double vPhone1=m1q9a
label var vPhone1 "Phone number -- primary"
gen double vPhone2=m1q9b
label var vPhone2 "Phone number -- secondary"

gen districtID = regionDistrictCode_j
label var districtID "District code/ ID -- unique"

tostring loccode, gen(loccodex) format(%17.0g)
tostring vPhone1, gen(vPhone1x) format(%17.0g)
tostring vPhone1, gen(vPhone1xx) format(%010.0f)

tostring vPhone2, gen(vPhone2x) format(%17.0g)
tostring vPhone2, gen(vPhone2xx) format(%010.0f)

order districtID districtName loccode loccodex ln vn vendor_id vDescribe vPhone1 vPhone1x vPhone1xx vPhone2 vPhone2x vPhone2xx 
keep districtID districtName loccode loccodex ln vn vendor_id vDescribe vPhone1 vPhone1x vPhone1xx vPhone2 vPhone2x vPhone2xx 
tab districtID
tab districtName

**all vendors per locality =137 all here**
bys districtName loccode vendor_id: keep if _n==1

**keep only 98 Trt localities for experimenters?
merge m:1 loccodex using "junk_interventionsTomake_list_local_onlyTs"
keep if _merge==3
drop _merge

order districtName ln loccodex vn vendor_id vDescribe vPhone1xx 
keep districtName ln loccodex vn vendor_id vDescribe vPhone1xx
sort districtName loccodex

egen vMask=group(loccodex)
*tab vMask
saveold vendorsRoster_by_locality_T98, replace
outsheet using vendorsRoster_by_locality_T98.xls, replace

forval v = 1/98{
	use vendorsRoster_by_locality_T98, clear
	keep if vMask==`v'
	local loccodex =loccodex
	drop vMask
outsheet using "$dta_loc/data-Mgt/Stats?/vendorsRoster_by_locality_T98/_`v'_vList_`loccodex'.xls", replace
}
***



**II: Get locality vendor list roster--only Control villages**
use interventionsTomake_list_local, replace
bys loccode: keep if _n==1 //Trt localities=98 + Control = 130?
keep if treatment==0 //only Controls=32?
keep loccodex
saveold junk_interventionsTomake_list_local_onlyCtrl, replace

use Mkt_fieldData_census, clear
gen double localityCode_j=loccode
drop _merge
merge m:1 localityCode_j using "$dta_loc/sampling?/sel_9Distr_137Local_List"
keep if _merge==3

label var vendor_id "vendor ID - unique only within locality"
gen vDescribe = m1q0d
label var vDescribe "Describe location -- vendor"
gen double vPhone1=m1q9a
label var vPhone1 "Phone number -- primary"
gen double vPhone2=m1q9b
label var vPhone2 "Phone number -- secondary"

gen districtID = regionDistrictCode_j
label var districtID "District code/ ID -- unique"

tostring loccode, gen(loccodex) format(%17.0g)
tostring vPhone1, gen(vPhone1x) format(%17.0g)
tostring vPhone1, gen(vPhone1xx) format(%010.0f)

tostring vPhone2, gen(vPhone2x) format(%17.0g)
tostring vPhone2, gen(vPhone2xx) format(%010.0f)

order districtID districtName loccode loccodex ln vn vendor_id vDescribe vPhone1 vPhone1x vPhone1xx vPhone2 vPhone2x vPhone2xx 
keep districtID districtName loccode loccodex ln vn vendor_id vDescribe vPhone1 vPhone1x vPhone1xx vPhone2 vPhone2x vPhone2xx 
tab districtID
tab districtName

**all vendors per locality =137 all here**
bys districtName loccode vendor_id: keep if _n==1

**keep only 32 Ctrl localities for experimenters?
merge m:1 loccodex using "junk_interventionsTomake_list_local_onlyCtrl"
keep if _merge==3
drop _merge

order districtName ln loccodex vn vendor_id vDescribe vPhone1xx 
keep districtName ln loccodex vn vendor_id vDescribe vPhone1xx
sort districtName loccodex

egen vMask=group(loccodex)
*tab vMask
saveold vendorsRoster_by_locality_Ctrl32, replace
outsheet using vendorsRoster_by_locality_Ctrl32.xls, replace

forval v = 1/32{
	use vendorsRoster_by_locality_Ctrl32, clear
	keep if vMask==`v'
	local loccodex =loccodex
	drop vMask
outsheet using "$dta_loc/data-Mgt/Stats?/vendorsRoster_by_locality_Ctrl32/_`v'_ctrl_vList_`loccodex'.xls", replace
}
***
**Ctrl: local customers list to get just "fin-family network"
use interventionsTomake_list_local, replace
keep if treatment==0 //only Controls=32?
drop vn vendor_id vDescribe vPhone1 vPhone1x vPhone1xx vPhone2 vPhone2x vPhone2xx
gen login=" "
gen date =" "
gen c_lastVisit_vendor_id = " "
gen amount_transacted_ghc = " "
gen related_1Blood_2Friend_3NotAtAll = " " //enter 1=by blood: relative/family, 2=just friend, 3=not related in any way

saveold junk_interventionsTomake_list_local_onlyCtrl_+questions, replace
outsheet using "$dta_loc/data-Mgt/Stats?/junk_interventionsTomake_list_local_onlyCtrl_+questions.xls", replace


