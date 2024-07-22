/*
Tables B.1, B.2, B.8

*/

use "$dta_loc_repl/01_intermediate/repMkt_w_xtics", clear
**Supply: merchant side
**2a merchant xtics?
**mfemale?
sum mfemale
local n = r(N)
display `n'
local mean = r(mean)
display `mean'
local sd = r(sd)
display `sd'
sum mfemale if sample_repMkt==1
local nS = r(N)
display `nS'
local meanS = r(mean)
display `meanS'
local sdS = r(sd)
display `sdS'
ttesti `n' `mean' `sd' `nS' `meanS' `sdS'

**makan?
sum makan
local n = r(N)
display `n'
local mean = r(mean)
display `mean'
local sd = r(sd)
display `sd'
sum makan if sample_repMkt==1
local nS = r(N)
display `nS'
local meanS = r(mean)
display `meanS'
local sdS = r(sd)
display `sdS'
ttesti `n' `mean' `sd' `nS' `meanS' `sdS'

**mage?
sum mage
local n = r(N)
display `n'
local mean = r(mean)
display `mean'
local sd = r(sd)
display `sd'
sum mage if sample_repMkt==1
local nS = r(N)
display `nS'
local meanS = r(mean)
display `meanS'
local sdS = r(sd)
display `sdS'
ttesti `n' `mean' `sd' `nS' `meanS' `sdS'

**mEducAny?
sum mEducAny
local n = r(N)
display `n'
local mean = r(mean)
display `mean'
local sd = r(sd)
display `sd'
sum mEducAny if sample_repMkt==1
local nS = r(N)
display `nS'
local meanS = r(mean)
display `meanS'
local sdS = r(sd)
display `sdS'
ttesti `n' `mean' `sd' `nS' `meanS' `sdS'
**etc...

** Table B.1 -------------------------------------------------------------------
**Supply: select vendor xtics? married out...
reg mfemale sample_repMkt, cluster(loccode)
reg mmarried sample_repMkt, cluster(loccode)
reg makan sample_repMkt, cluster(loccode)
reg mage sample_repMkt, cluster(loccode)
reg mEducAny sample_repMkt, cluster(loccode)
reg mselfemployed sample_repMkt, cluster(loccode)
reg mselfIncome sample_repMkt, cluster(loccode)
reg mbusTrained sample_repMkt, cluster(loccode)

**poverty?
reg m4q1 sample_repMkt, cluster(loccode)
reg m4q2 sample_repMkt, cluster(loccode)
reg m4q3 sample_repMkt, cluster(loccode)
reg m4q4 sample_repMkt, cluster(loccode)
reg m4q5 sample_repMkt, cluster(loccode)
reg m4q6 sample_repMkt, cluster(loccode)
reg m4q7 sample_repMkt, cluster(loccode)
reg m4q8 sample_repMkt, cluster(loccode)
reg m4q9 sample_repMkt, cluster(loccode)
reg m4q10 sample_repMkt, cluster(loccode)


**2b transactions/ mkt size?
*reg dailyNobCustomers sample_repMkt
reg dailyTotMoney sample_repMkt
reg dailyNobCustomers_nonM sample_repMkt
reg dailyTotMoney_nonM sample_repMkt

**joint, exclude main Y?
reg sample_repMkt mfemale mmarried makan mage mEducAny mselfemployed mselfIncome mbusTrained, cluster(loccode)
test mfemale mmarried makan mage mEducAny mselfemployed mselfIncome mbusTrained
probit sample_repMkt mfemale mmarried makan mage mEducAny mselfemployed mselfIncome mbusTrained, cluster(loccode)
test mfemale mmarried makan mage mEducAny mselfemployed mselfIncome mbusTrained


** Table B.2 -------------------------------------------------------------------
*3a Demand: customer xtics, same mkt?
** xtics? married out...
reg cfemale sample_repMkt, cluster(loccode)
reg cmarried sample_repMkt, cluster(loccode)
reg cakan sample_repMkt, cluster(loccode)
reg cage sample_repMkt, cluster(loccode)
reg cEducAny sample_repMkt, cluster(loccode)
reg cselfemployed sample_repMkt, cluster(loccode)
reg cselfIncome sample_repMkt, cluster(loccode)
reg cMMoneyregistered sample_repMkt, cluster(loccode)


**poverty?
reg c2q1 sample_repMkt, cluster(loccode)
reg c2q2 sample_repMkt, cluster(loccode)
reg c2q3 sample_repMkt, cluster(loccode)
reg c2q4 sample_repMkt, cluster(loccode)
reg c2q5 sample_repMkt, cluster(loccode)
reg c2q6 sample_repMkt, cluster(loccode)
reg c2q7 sample_repMkt, cluster(loccode)
reg c2q8 sample_repMkt, cluster(loccode)
reg c2q9 sample_repMkt, cluster(loccode)
reg c2q10 sample_repMkt, cluster(loccode)

**fraud?
reg cfAttempts sample_repMkt, cluster(loccode)
reg _Xcfraud sample_repMkt, cluster(loccode)

*3b mkt, transactions?
gen distToBank= c3q3a 
gen walkTimeBank= c3q3b 
gen bankUser = (c3q4==1)
replace bankUser=. if missing(c3q4)

gen distTopostOffice = c3q7a
gen walkTimepostOffice = c3q7b
gen postOffUser=(c3q8==1)
replace postOffUser=. if missing(c3q8)

gen distToMMoney= c4q2a
gen walkTimeMMoney= c4q2b
gen MMoneyUser=(c4q3==1)
replace MMoneyUser=. if missing(c4q3)

reg distToBank sample_repMkt, cluster(loccode)
reg distToMMoney sample_repMkt, cluster(loccode)

*reg wklyNobUsage sample_repMkt, cluster(loccode)
reg wklyTotUseVol sample_repMkt, cluster(loccode)
reg wklyNobUsage_nonM sample_repMkt, cluster(loccode)
reg wklyTotUseVol_nonM sample_repMkt, cluster(loccode)

*3c borrow + save behavior?
gen likelyborrowMMoney =c5q1
gen likelysaveMMoney =c5q5
reg likelyborrowMMoney sample_repMkt, cluster(loccode)
reg likelysaveMMoney sample_repMkt, cluster(loccode)
/* 
reg wklyNobBorrow sample_repMkt, cluster(loccode)
reg wklyTotBorrowVol sample_repMkt, cluster(loccode)
reg wklyNobSave sample_repMkt, cluster(loccode)
reg wklyTotSaveVol sample_repMkt, cluster(loccode)
*/
**joint, exclude main Y?
reg sample_repMkt cfemale cmarried cakan cage cEducAny cselfemployed cselfIncome cMMoneyregistered, cluster(loccode)
test cfemale cmarried cakan cage cEducAny cselfemployed cselfIncome cMMoneyregistered
probit sample_repMkt cfemale cakan cmarried cage cEducAny cselfemployed cselfIncome cMMoneyregistered, cluster(loccode)
test cfemale cmarried cakan cage cEducAny cselfemployed cselfIncome cMMoneyregistered


** Table B.8 -------------------------------------------------------------------
**summary statistics? paper 1
**Vendors
gen mhhsizeabove5=(m4q1<13)
replace mhhsizeabove5=. if missing(m4q1)
gen mhhhenglish=(m4q3==5)
replace mhhhenglish=. if missing(m4q3)
gen mwallcement=(m4q4==5)
replace mwallcement=. if missing(m4q4)
gen mhastoilet =(m4q5 >0)
replace mhastoilet=. if missing(m4q5)
gen mhasphones=(m4q9>0)
replace mhasphones=. if missing(m4q9)
gen mhasbicyle=(m4q10>0)
replace mhasbicyle=. if missing(m4q10)

gen mbusexperience = m2q1a
replace mbusexperience= m2q1b/12 if mbusexperience==0
gen motherbus=(m3q1==1)
replace motherbus=. if missing(m3q1)


tabstat mfemale mselfemployed mselfIncome mmarried makan mage mEducAny mbusTrained ///
	mhhsizeabove5 mhhhenglish mwallcement mhastoilet mhasphones mhasbicyle ///
	mbusexperience motherbus dailyTotMoney dailyNobCustomers_nonM dailyTotMoney_nonM ///
	, by("") stat(mean sd) col(stat) long
 
tabstat mselfemployed mselfIncome mmarried makan mage mEducAny mbusTrained ///
	mhhsizeabove5 mhhhenglish mwallcement mhastoilet mhasphones mhasbicyle ///
	mbusexperience motherbus dailyTotMoney dailyNobCustomers_nonM dailyTotMoney_nonM ///
	, by(mfemale) stat(mean sd) col(stat) long
**Customers
gen chhsizeabove5=(c2q1<13)
replace chhsizeabove5=. if missing(c2q1)
gen chhhenglish=(c2q3==5)
replace chhhenglish=. if missing(c2q3)
gen cwallcement=(c2q4==5)
replace cwallcement=. if missing(m4q4)
gen chastoilet =(c2q5 >0)
replace chastoilet=. if missing(c2q5)
gen chasphones=(c2q9>0)
replace chasphones=. if missing(c2q9)
gen chasbicyle=(c2q10>0)
replace chasbicyle=. if missing(c2q10)

tabstat cfemale cselfemployed cselfIncome cmarried cakan cage cEducAny cMMoneyregistered ///
	chhsizeabove5 chhhenglish cwallcement chastoilet chasphones chasbicyle ///
	distToBank distTopostOffice distToMMoney bankUser postOffUser MMoneyUser ///
	wklyTotUseVol wklyNobUsage_nonM wklyTotUseVol_nonM ///
	likelyborrowMMoney likelysaveMMoney ///
	cfAttempts _Xcfraud ///
	, by("") stat(mean sd) col(stat) long
**Fraud-overcharged?
tab c4q17, miss

*keep if sample_repMkt==1
keep if _merge==3
drop _merge

* save
saveold "$dta_loc_repl/01_intermediate/Mkt_fieldData_sample_repMkt", replace




sum cfAttempts _clocalpFraud 
**seanHiggins-descriptive: gender differences? n=1921. Nothing!
reg cfAttempts cfemale, cluster(loccode)
reg _Xcfraud cfemale, cluster(loccode)

reg cfAttempts cfemale, cluster(loccode)
reg _clocalpFraud cfemale, cluster(loccode)
reg cfAccountUse cfemale, cluster(loccode)
reg everOvercharged cfemale, cluster(loccode)


sum cfAttempts cfAccountUse cfCallers cfIncorrects

**xbase correlates of fraud
reg cfAttempts cfemale cakan cmarried cage cEducAny cselfemployed cselfIncome cMMoneyregistered, cluster(loccode)

gen f1 = (c5q7a==1) if !missing(c5q7a) 
replace f1=. if c5q7a ==3
gen f2 = (c5q7b==1) if !missing(c5q7b)
replace f1=. if c5q7b ==3
gen f3 = (c5q7c==1) if !missing(c5q7c) 
replace f1=. if c5q7c ==3
gen f =(f1==1 | f2==1 | f3==1)

reg f1 cfemale cakan cmarried cage cEducAny cselfemployed cselfIncome cMMoneyregistered wklyTotUseVol wklyNobUsage_nonM wklyTotUseVol_nonM, cluster(loccode)
reg f2 cfemale cakan cmarried cage cEducAny cselfemployed cselfIncome cMMoneyregistered wklyTotUseVol wklyNobUsage_nonM wklyTotUseVol_nonM, cluster(loccode)
reg f3 cfemale cakan cmarried cage cEducAny cselfemployed cselfIncome cMMoneyregistered wklyTotUseVol wklyNobUsage_nonM wklyTotUseVol_nonM, cluster(loccode)
reg f cfemale cakan cmarried cage cEducAny cselfemployed cselfIncome cMMoneyregistered wklyTotUseVol wklyNobUsage_nonM wklyTotUseVol_nonM, cluster(loccode)


gen iHave=(c4q17==1) if !missing(c4q17)
gen iThink=(c8q3==1) if !missing(c8q3)
gen i =(iHave==1 | iThink==1)
reg iHave cfemale, cluster(loccode)
reg iThink cfemale, cluster(loccode)

sum i cfAttempts _clocalpFraud c8q3

egen localFE=group(loccode)
pdslasso i cfemale (i.localFE cakan cmarried cage cEducAny cselfemployed cselfIncome cMMoneyregistered wklyTotUseVol wklyNobUsage_nonM wklyTotUseVol_nonM), ///
    partial(i.localFE) ///
    cluster(localFE) ///
    rlasso

