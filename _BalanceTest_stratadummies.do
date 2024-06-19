clear all
cd "/Users/fa2316/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/data-Mgt/Stats?"

***ADD STRATA DUMMIES R3 (JPE)***

**Balance Tests II (program assignments): JULY 4 2020 = APR 3 2023
use Mkt_fieldData_sample_repMkt, clear
merge m:m loccode vendor_id using "interventionsTomake_list_local"
keep if _merge==3

*use interventionsTomake_list_local, clear
gen trt0vsall = (treatment !=0)
*br districtName regionDistrictCode_j localityName localityCode_j treatment Trt* trt*

***ADD STRATA DUMMIES R3 (JPE)***
egen strataFE = group(districtName)

**Supply side: merchants...?
reg mfemale i.strataFE i.treatment, cluster(loccode)
reg mmarried i.strataFE i.treatment, cluster(loccode)
reg makan i.strataFE i.treatment, cluster(loccode)
reg mage i.strataFE i.treatment, cluster(loccode)
reg mEducAny i.strataFE i.treatment, cluster(loccode)
reg mselfemployed i.strataFE i.treatment, cluster(loccode)
*reg mselfIncome i.treatment, cluster(loccode) //fine but too many already
reg mbusTrained i.strataFE i.treatment, cluster(loccode)

**poverty?
reg m4q3 i.strataFE i.treatment, cluster(loccode)
reg m4q4 i.strataFE i.treatment, cluster(loccode)
reg m4q5 i.strataFE i.treatment, cluster(loccode)
reg m4q9 strataFE i.treatment, cluster(loccode)
reg m4q10 i.strataFE i.treatment, cluster(loccode)
reg m_pov_likelihood i.strataFE i.treatment, cluster(loccode) //just report this index?


*reg dailyNobCustomers i.treatment, cluster(loccode) //fine but too many already
*reg CustPer_w_Mkt strataFE i.treatment, cluster(loccode) //fine but too many already
reg dailyTotMoney i.strataFE i.treatment, cluster(loccode)
reg dailyNobCustomers_nonM i.strataFE i.treatment, cluster(loccode)
reg dailyTotMoney_nonM i.strataFE i.treatment, cluster(loccode)

**joint, exclude main Y
reg trt0vsall mfemale mmarried makan mage mEducAny mselfemployed mselfIncome mbusTrained, cluster(loccode)
test mfemale mmarried makan mage mEducAny mselfemployed mselfIncome mbusTrained

probit trt0vsall mfemale mmarried makan mage mEducAny mselfemployed mselfIncome mbusTrained, cluster(loccode)
test mfemale mmarried makan mage mEducAny mselfemployed mselfIncome mbusTrained




**Demand side: customers...?
reg cfemale i.strataFE i.treatment, cluster(loccode)
reg cmarried i.strataFE i.treatment, cluster(loccode)
reg cakan i.strataFE i.treatment, cluster(loccode)
reg cage i.strataFE i.treatment, cluster(loccode)
reg cEducAny i.strataFE i.treatment, cluster(loccode)
reg cselfemployed i.strataFE i.treatment, cluster(loccode)
*reg cselfIncome i.strataFE i.treatment, cluster(loccode) //fine but too manay already
reg cMMoneyregistered i.strataFE i.treatment, cluster(loccode)

**poverty?
reg c2q3 i.strataFE i.treatment, cluster(loccode)
reg c2q4 i.strataFE i.treatment, cluster(loccode)
reg c2q5 i.strataFE i.treatment, cluster(loccode)
reg c2q9 i.strataFE i.treatment, cluster(loccode)
reg c2q10 i.strataFE i.treatment, cluster(loccode)
reg c_pov_likelihood i.strataFE i.treatment, cluster(loccode) //just report this index?
**achieved strong balance on Trt vs Ctr...


reg cfAttempts i.strataFE i.treatment, cluster(loccode)
reg _Xcfraud i.strataFE i.treatment, cluster(loccode)


reg distToBank i.strataFE i.treatment, cluster(loccode)
reg distToMMoney i.strataFE i.treatment, cluster(loccode)


reg wklyTotUseVol i.strataFE i.treatment, cluster(loccode)
reg wklyNobUsage_nonM i.strataFE i.treatment, cluster(loccode)
reg wklyTotUseVol_nonM i.strataFE i.treatment, cluster(loccode)

reg likelyborrowMMoney i.strataFE i.treatment, cluster(loccode)
reg likelysaveMMoney i.strataFE i.treatment, cluster(loccode)


**joint, exclude main Y?
reg trt0vsall cfemale cmarried cakan cage cEducAny cselfemployed cselfIncome cMMoneyregistered, cluster(loccode)
test cfemale cmarried cakan cage cEducAny cselfemployed cselfIncome cMMoneyregistered
probit trt0vsall cfemale cakan cmarried cage cEducAny cselfemployed cselfIncome cMMoneyregistered, cluster(loccode)
test cfemale cmarried cakan cage cEducAny cselfemployed cselfIncome cMMoneyregistered






