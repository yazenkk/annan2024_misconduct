/*
Title: 

Input:
	- data-Mgt/Stats?/_M1.dta
	- data-Mgt/Stats?/_CM1.dta
	- data-Mgt/Exported Raw Data - Live/CusData/CM1.dta
	- data-Mgt/Exported Raw Data - Live/CusData/CM`k'.dta
	- data-Mgt/Exported Raw Data - Live/Merchant/M1.dta
	- data-Mgt/Exported Raw Data - Live/Merchant/M`k'.dta
	- sampling?/sel_9Distr_137Local_List
	
Output:
	Data:
		- _CM_all_2_18.dta
		- _M_all_2_18.dta
		- Mkt_fieldData.dta/csv
		- Mkt_fieldData_census.dta
		- repMkt
		- repMkt_w_xtics
		- end_AuditsTomake_list.xls
		- ONLY_repMkt
		- ONLY_4TrtGroups_9dist
		- interventionsTomake_list_local_onlyTs
		- junk_interventionsTomake_list_local_onlyTs
		- data-Mgt/Stats?/vendorsRoster_by_locality_T98/_`v'_vList_`loccodex'.xls
		- data-Mgt/Stats?/vendorsRoster_by_locality_Ctrl32/_`v'_ctrl_vList_`loccodex'.xls
		- data-Mgt/Stats?/junk_interventionsTomake_list_local_onlyCtrl_+questions.xls
		- riskiesTomake_list
		- JPEr_control_rep_vVendors_survey.xls
		- JPEr_control_ALL_vVendors_survey.xls
		
	Graphs:
		- FFPhone in 2020/_impact-evaluation/ai_customerVsvendor_graph.eps
		- FFPhone in 2020/_impact-evaluation/mispercep_misconduct_graph.eps
		- _dailyNobCustomers.eps
		- _dailyTotMoney.eps
		- _dailyNobCustomers_NonM.eps
		- _dailyTotMoney_nonM.eps
		- _wklyNobUsage.eps
		- _wklyTotUseVol.eps
		- _wklyNobUsage_nonM.eps
		- _wklyTotUseVol_nonM.eps
		- _xdevsKdensStr.eps
		- _xdevsKdensAsy.eps
		- FFPhone in 2020/_impact-evaluation/trust_transacting_graph.eps
		- _project/pct_female_hist.eps
		- _project/hhibyGender.eps
		- _project/hhibyGender_cdf.eps
	
*/
clear all


cd "/Users/fa2316/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/data-Mgt/Stats?"

****
*log using "_rGroup-finfraud-base.log", replace
*Merchants?
use "_M1.dta", clear
gen y_coord = m1q0a
gen x_coord = m1q0b

sort loccode vendor vn
*browse loccode ln vendor vn interviewer
tab interviewer

gen locality_name= ln
gen vendor_id= vendor
gen interviewer =interviewer_v

egen check =group(loccode locality_name vendor_id interviewer)
tab check
egen check2 =group(loccode vendor_id interviewer)
tab check2
egen check3 =group(loccode vendor_id)
tab check3
**let's keep 2 or 3

merge 1:m loccode vendor_id using  "_CM1.dta"
keep if _merge==3
egen Mkt = group(loccode vendor_id)
tab Mkt
*br loccode locality_name vendor_id custcode Mkt

** # of localities & # of customers per mkt
egen cnoofLocalities = group(loccode)
bys Mkt: gen cnoofCustPerMkt = _N

sum cnoofLocalities
sum cnoofCustPerMkt

browse

**some summaries
gen cfemale=(c1q1==2)
gen cakan =(c1q2==1)
gen cmarried=(c1q3==1)
gen cage =c1q4
gen cEducAny =(c1q5>1)
gen cselfemployed =(c1q6==1)
gen cselfIncome =c1q7
gen cMMoneyregistered=(c1q9==1)


gen mfemale=(m1q1==2)
gen makan =(m1q2==1)
gen mmarried=(m1q3==1)
gen mage =m1q4
gen mEducAny =(m1q5>1)
gen mselfemployed =(m1q6==1)
gen mselfIncome =m1q7
sum cfemale mfemale cakan makan cmarried mmarried cage mage cEducAny mEducAny cselfemployed mselfemployed cselfIncome mselfIncome cMMoneyregistered



**Get all together?
**Customers: 8 sections?
use "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/data-Mgt/Exported Raw Data - Live/CusData/CM1.dta", clear
forval k =2/8 {
	merge 1:1 distcode loccode custcode using "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/data-Mgt/Exported Raw Data - Live/CusData/CM`k'.dta"
	drop _merge
	}
save "_CM_all_2_18.dta", replace
outsheet using _CM_all_2_18.csv, replace

tab vendor_id, miss


**Merchants: 6 sections?
use "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/data-Mgt/Exported Raw Data - Live/Merchant/M1.dta", clear
forval k =2/6 {
	merge 1:1 distcode loccode vendor using "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/data-Mgt/Exported Raw Data - Live/Merchant/M`k'.dta"
	drop _merge
	}
/*
**SammY: admin data
keep vendor loccode m1q0d m1q9a m1q9b vn ln
rename vendor vendor_id
merge m:m loccode using "interventionsTomake_list_local_AssocData"
keep if _merge==3
drop _merge
merge m:1 loccode vendor_id using "interventionsTomake_list_local_AssocData"
gen rep = (_merge==3)
rename m1q0d describe_location
rename m1q9a phone1
rename m1q9b phone2
rename vn vendor_name
rename ln locality_name
tostring phone1, gen(phone1x) format(%17.0g)
tostring phone1, gen(phone1xx) format(%010.0f)
tostring phone2, gen(phone2x) format(%17.0g)
tostring phone2, gen(phone2xx) format(%010.0f)

outsheet using _vendors_all_AssocData.csv, replace
outsheet using _vendors_all_AssocData.xls, replace

/*
use interventionsTomake_list_local, clear
bys loccode: keep if _n==1
keep loccode vn ln vendor_id treatment
save interventionsTomake_list_local_AssocData, replace
*/

*/

save "_M_all_2_18.dta", replace
outsheet using _M_all_2_18.csv, replace



*TROUBLE FOR VENDORS UP?
use "_M_all_2_18 copy.dta", clear


tab vendor, miss

**number M per local?
bys loccode: gen MktPerLocal = _N
hist MktPerLocal
sum MktPerLocal // 1 to 12 with avg=5 merchants

**Next, add customers?
gen locality_name= ln
gen vendor_id= vendor
gen interviewer =interviewer_v

merge 1:m distcode loccode vendor_id using  "_CM_all_2_18.dta"


/*
**sanity checka & officers corrections
drop if _merge==3
keep distcode loccode gps_taken m1q0a m1q0b m1q0c m1q0d m1q9a m1q9b interviewer_v supervisor_v vn vendor_id custcode cn c1q8a c1q8b c1q0a1 c1q0a2 c1q0a3 c1q0b locality_name interviewer _merge
outsheet using "SanityChecks_Mismatches.csv", replace
*/



*keep if (_merge==3)
egen Mkt = group(loccode vendor_id)
tab Mkt

*br loccode locality_name vendor_id custcode Mkt

** # of localities & # of customers per mkt
egen cnoofLocalities = group(loccode)
bys Mkt: gen cnoofCustPerMkt = _N

sum cnoofLocalities
sum cnoofCustPerMkt

save Mkt_fieldData, replace
outsheet using Mkt_fieldData.csv, replace

**summaries
**get customers
gen cfemale=(c1q1==2)
replace cfemale=. if missing(c1q1)

gen cakan =(c1q2==1)
replace cakan=. if missing(c1q2)

gen cmarried=(c1q3==1)
replace cmarried=. if missing(c1q3)

gen cage =c1q4
replace cage=. if missing(c1q4)

gen cEducAny =(c1q5>1)
replace cEducAny=. if missing(c1q5)

gen cEduc =c1q5
replace cEduc=. if missing(c1q5)

gen cselfemployed =(c1q6==1)
replace cselfemployed=. if missing(c1q6)

gen cselfIncome =c1q7
replace cselfIncome=. if missing(c1q7)

gen cMMoneyregistered=(c1q9==1)
replace cMMoneyregistered=. if missing(c1q9)


**get merchants
gen mfemale=(m1q1==2)
replace mfemale=. if missing(m1q1)

gen makan =(m1q2==1)
replace makan=. if missing(m1q2)

gen mmarried=(m1q3==1)
replace mmarried=. if missing(m1q3)

gen mage =m1q4
replace mage=. if missing(m1q4)

gen mEducAny =(m1q5>3)
replace mEducAny=. if missing(m1q5)

gen mEduc =m1q5
replace mEduc=. if missing(m1q5)

gen mselfemployed =(m1q6==1)
replace mselfemployed=. if missing(m1q6)

gen mselfIncome =m1q7
replace mselfIncome=. if missing(m1q7)

gen mbusTrained = (m2q2==1)
replace mbusTrained=. if missing(m2q2)

**females?
tab mfemale
*joint business structure?
tab m3q1


**Fraud: Measure I
gen cfAttempts =(c5q7a==1 | c5q7b==1 | c5q7c==1)
replace cfAttempts=. if missing(c5q7a)
replace cfAttempts=. if missing(c5q7b)
replace cfAttempts=. if missing(c5q7c)

gen cfAccountUse =(c5q7a==1)
replace cfAccountUse=. if missing(c5q7a)

gen cfCallers =(c5q7b==1)
replace cfAccountUse=. if missing(c5q7b)

gen cfIncorrects =(c5q7c==1)
replace cfIncorrects=. if missing(c5q7c)

sum cfAttempts cfAccountUse cfCallers cfIncorrects

**xbase correlates of fraud
reg cfAttempts cfemale cakan cmarried cage cEducAny cselfemployed cselfIncome cMMoneyregistered, cluster(loccode)



**Knowledge discrepancies & perceived Mkt structure/ fraud evidence?
*Knowledge test?
**Customers?
**c8q1b=c200 vs c8q2=c1200
gen c_chargeC200 = c8q1b

replace c_chargeC200=. if (c_chargeC200==0 | c_chargeC200>=99)
br c_chargeC200

*replace c_chargeC200=. if (c_chargeC200==0 | c_chargeC200==99)
*hist c_chargeC200, xline(2, lwidth(vthick) lcolor(blue)) fcolor(none) title("Knowledge Test: Customers, MTN Charge for GHC200") ///
* xtitle("Discrepancy in stated charges for GHC200") text(2 2 "Correct charge--in blue", place(e))

gen c_x200=c_chargeC200-2
*hist c_x200

gen c_chargeC1200 = c8q2
replace c_chargeC1200=. if (c_chargeC1200==0 | c_chargeC1200>=99)
*replace c_chargeC1200=. if (c_chargeC1200==0 | c_chargeC1200==99)
*hist c_chargeC1200, xline(10, lwidth(vthick) lcolor(blue)) fcolor(none) title("Knowledge Test: Customers, MTN Charge for GHC1200") ///
* xtitle("Discrepancy in stated charges for GHC1200") text(0.15 10 "Correct charge--in blue", place(e))

gen c_x1200=c_chargeC1200-10
*hist c_x1200

gen c_deviations = c_x200
replace c_deviations= c_x1200 if missing(c_deviations)
hist c_deviations

**gender difference in customer knowledge?
reg c_deviations cfemale

*drop if missing(c_deviations)
*drop if missing(cfemale)
cdfplot c_deviations, by(cfemale) opt1(lc(blue red)) xtitle("Knowledge Tests: n (Males)=231, n (Females)=157") ytitle("CDF") legend(pos(3) col(1) stack label(1 "Males") label(2 "Females"))
hist c_deviations, by(cfemale)

gen c_correctsI=(c_deviations==0) 
gen c_corrects=(c_deviations==0)  if !missing(c_deviations)
bys cfemale: sum c_corrects
bys loccode cfemale: egen fq_cc_corrects = mean(c_corrects) 
cdfplot fq_cc_corrects if !missing(cfemale), by(cfemale) opt1(lc(blue red)) xtitle("Knowledge Tests: n (Males)=743, n (Females)=1,253") ytitle("CDF") legend(pos(3) col(1) stack label(1 "Males") label(2 "Females"))

regress c_corrects cfemale
regress fq_cc_corrects cfemale
**42%(c-females) vs 48%(c-males) accuracy



**Merchants?
gen m_chargeC200 = m6q1b
replace m_chargeC200=. if (m_chargeC200==0 | m_chargeC200>=99)
*replace m_chargeC200=. if (m_chargeC200==0 | m_chargeC200==99)
*hist m_chargeC200, xline(2, lwidth(vthick) lcolor(blue)) fcolor(none) title("Knowledge Test: Merchants, MTN Charge for GHC200") ///
* xtitle("Discrepancy in stated charges for GHC200") text(2 2 "Correct charge--in blue", place(e))

gen m_x200=m_chargeC200-2
*hist m_x200

gen m_chargeC1200 = m6q2
replace m_chargeC1200=. if (m_chargeC1200==0 | m_chargeC1200>=99)
*replace m_chargeC1200=. if (m_chargeC1200==0 | m_chargeC1200==99)
*hist m_chargeC1200, xline(2, lwidth(vthick) lcolor(blue)) fcolor(none) title("Knowledge Test: Merchants, MTN Charge for GHC1200") ///
* xtitle("Discrepancy in stated charges for GHC1200") text(2 10 "Correct charge--in blue", place(e))

gen m_x1200=m_chargeC1200-10
*hist m_x1200 if m_x1200<20

gen m_deviations = m_x200
replace m_deviations= m_x1200 if missing(m_deviations)
hist m_deviations

regress m_deviations mfemale


**Testing AI?
*drop if (c_x200>200 | c_x1200>200 | m_x200>200 | m_x1200>200 )
*drop if (c_deviations>200 | m_deviations>200)

twoway (hist c_x200 if c_x200<200, color(green)) ///
(hist m_x200 if m_x200<200, fcolor(green) color(blue)), legend(order(1 "Customers" 2 "Merchants" ))
graph export _x200.eps, replace
*sum c_x200 m_x200 //variability?


twoway (hist c_x1200 if c_x1200<200, color(green)) ///
(hist m_x1200 if m_x1200<200, fcolor(grey) color(blue)), legend(order(1 "Customers" 2 "Merchants" ))
graph export _x1200.eps, replace
*sum c_x1200 m_x1200 //variability?

*replace _asymLocally1200=. if (c_x1200<-800 | c_x1200>800)
twoway (hist c_deviations if c_deviations<200, color(green)) ///
(hist m_deviations if m_deviations<200, fcolor(grey) color(blue)), legend(order(1 "Customers" 2 "Merchants" )) title("Knowledge Tests:") subtitle("Deviations from Correct Transactional Charges") note("NOTE: Customers are 52.3% of the time Incorrect. Merchants are 33.1% of the time Incorrect")
graph export _xdevs.eps, replace
*sum c_deviations m_deviations //variability?


**incorrections Counts...
count if (c_deviations==0 & c_deviations<200)
count if (!missing(c_deviations) & c_deviations<200)
dis "Wrong crate is, custormers: =" (1-(897/1836))*100 "%"

count if (m_deviations==0 & m_deviations<200)
count if (!missing(m_deviations) & m_deviations<200)
dis "Wrong mrate is, merchants: =" (1-(1225/1886))*100 "%"

**incorrectness: 51% vs 35%



**by Gender?
gen m_correctsI=(m_deviations==0)
gen m_corrects=(m_deviations==0) if !missing(m_deviations)

bys mfemale: sum m_corrects
regress m_corrects mfemale
regress m_corrects mfemale, cluster(loccode)
**59(m-females) vs (m-males)70 accuracy
**graphically?
bys loccode mfemale: egen fq_mm_corrects = mean(m_corrects)
cdfplot fq_mm_corrects if !missing(cfemale), by(cfemale) opt1(lc(blue red)) xtitle("Knowledge Tests: n (Males)=743, n (Females)=1,253") ytitle("CDF") legend(pos(3) col(1) stack label(1 "Males") label(2 "Females"))

**ttests
ttest c_deviations == m_deviations, unpaired


**Asymmetric Tnformation Test**
bys loccode: egen mkt_m_corrects = mean(m_corrects)
bys loccode: egen mkt_c_corrects = mean(c_corrects)


bys loccode vendor_id: gen nobvendors=_N
bys loccode: gen nobcustomers=_N

sum mkt_c_corrects, d
sum mkt_m_corrects if (mkt_m_corrects > 0), d
*Means: c=48 vs v=73
*Median: c=42 vs v=79
**Trim: zero vendor knowledge in a whole locality is sugestive of potential vendor misconduct, so drop those
distplot mkt_c_corrects mkt_m_corrects if (mkt_m_corrects > 0), xline(0.48, lp(solid) lw(vthin)) text(0.8 0.38 "Customers: Overall share", size(vsmall)) xline(0.73, lp(dash) lw(vthin)) lp(solid dash) text(0.1 0.82 "Vendors: Overall share", size(vsmall))  xtitle("Share with correct answers") ytitle("Cumulative Probability") legend(pos(7) row(1) stack label(1 "Customers") label(2 "Vendors"))
gr export "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/FFPhone in 2020/_impact-evaluation/ai_customerVsvendor_graph.eps", replace
**NOTE: Trimmed to exlude unrealistic zero vendor knowlege at the mkt level
 
 
 
 
 
 
 
**Misperceived beliefs about Misconduct?
gen cat="true" if _n==1
gen misconduct=0.22 if cat=="true"
gen n=663 if cat=="true"
gen sd=0.41 if cat=="true"

/* 
replace cat="subjective" if _n==2
replace misconduct=0.19 if cat=="subjective"
replace sd=0.41 if cat=="subjective"
replace n=1921 if cat=="subjective"
*/
replace cat="subjective" if _n==2
replace misconduct=0.59 if cat=="subjective"
replace sd=0.49 if cat=="subjective"
replace n=1921 if cat=="subjective"

gen se=sd/sqrt(n) 
gen upper = misconduct + se
gen lower = misconduct - se 

generate himiscon90 = misconduct + invttail(n-1,0.05)*(sd / sqrt(n))
generate lowmiscon90 = misconduct - invttail(n-1,0.05)*(sd / sqrt(n))
graph twoway (bar meanwrite race) (rcap hiwrite lowrite race), by(ses)

gen catt=(cat=="true") if !missing(cat)

graph hbar misconduct, over(cat, sort(1)) bar(1, color(black)) bar(2, color(gs8)) nofill asyvars ///
 blabel(group, position(inside) format(%4.2f) box fcolor(white) lcolor(white)) ytitle("Misconduct Incidence: Share of transactions overcharged", size(small)) blabel(bar) ///
 legend(pos(7) row(1) stack label(1 "Perceived misconduct") label(2 "Objective (true) misconduct"))
gr export "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/FFPhone in 2020/_impact-evaluation/mispercep_misconduct_graph.eps", replace

*ttesti 663 0.22 0.41 1921 0.19 0.40
ttesti 663 0.22 0.41 1921 0.59 0.49



  
**Correlates of incorrectness: Merchants vs Customers
gen _dVc=(c_deviations !=0)
gen _dVm=(m_deviations !=0)
reg _dVc cfemale cakan cmarried cage cEduc cMMoneyregistered cselfemployed cselfIncome
reg _dVm mfemale makan mmarried mage mEduc mbusTrained cselfemployed cselfIncome

*********************************************
preserve
keep c_deviations m_deviations
gen id=_n 
save deviations, replace

use deviations, clear
keep id c_deviations
gen group=0
gen deviations=c_deviations
save c_deviations, replace

use deviations, clear
keep id m_deviations
gen group=1
gen deviations=m_deviations
save m_deviations, replace

append using c_deviations
ksmirnov deviations, by(group) //strong nonparametric rejection 1% level...

restore
**********************************************

**Fraud: Measure II
gen c_localpFraudi = (c4q17==1)
replace c_localpFraudi=. if missing(c4q1)

gen c_localpFraudii = (c8q3==1)
replace c_localpFraudii=. if missing(c8q3)

gen _clocalpFraud=(c_localpFraudi==1 |c_localpFraudii==1)
replace _clocalpFraud=. if missing(c_localpFraudi)
replace _clocalpFraud=. if missing(c_localpFraudii)

gen everOvercharged=c_localpFraudi
gen thinkOvercharging=c_localpFraudii
sum everOvercharged thinkOvercharging _clocalpFraud


**Mkt structure?
gen c_badReportSys = (c8q4==2)
replace c_badReportSys=. if missing(c8q4)

gen c_dontTrustSys = (c8q5==2)
replace c_dontTrustSys=. if missing(c8q5)

gen c_badMktStructure=(c_badReportSys==1 |c_dontTrustSys==1)
replace c_badMktStructure=. if missing(c_badReportSys)
replace c_badMktStructure=. if missing(c_dontTrustSys)

sum c_badMktStructure c_badReportSys c_dontTrustSys
*hist c_localpFraud, title("Custmers: Perceived overcharge / fraud")
*hist c_badMktStructure, discrete fraction gap(5) fcolor(grey) color(blue) title("Customers: bad Mkt structure to report fraud") 



***************************
**asy info vs mkt str
gen _cfraud=(cfAttempts==1 | _clocalpFraud==1)
replace _cfraud=. if missing(cfAttempts)
replace _cfraud=. if missing(_clocalpFraud)

gen _Xcfraud=(cfAccountUse==1 | everOvercharged==1)
replace _Xcfraud=. if missing(cfAccountUse)
replace _Xcfraud=. if missing(everOvercharged)


gen _asymLocally200 = (c_x200 !=0)  
replace _asymLocally200=. if missing(c_x200) 

gen _asymLocally1200 = (c_x1200 !=0) 
replace _asymLocally1200=. if (c_x1200<-800 | c_x1200>800)
replace _asymLocally1200=. if missing(c_x1200)  

gen _asymLocally = (_asymLocally200==1 | _asymLocally1200 ==1)
replace _asymLocally=. if missing(_asymLocally200)
replace _asymLocally=. if missing(_asymLocally1200)


**Testing...
reg cfAttempts c_badMktStructure _asymLocally, cluster(loccode)
reg _Xcfraud c_badMktStructure _asymLocally, cluster(loccode)


**Ia. MMoney sales?
gen dailyNobCustomers=m2q4a
gen dailyTotMoney=m2q4b
hist dailyNobCustomers, title(Merchants: dailyNobCustomers)
graph export _dailyNobCustomers.eps, replace
hist dailyTotMoney, title(Merchants: dailyTotMoney)
graph export _dailyTotMoney.eps, replace

**Ib. nonMMoney sales?
gen dailyNobCustomers_nonM =m3q3a1 
gen dailyTotMoney_nonM =m3q3a2
hist dailyNobCustomers_nonM, title(Merchants: dailyNobCustomers_nonM)
graph export _dailyNobCustomers_NonM.eps, replace
hist dailyTotMoney_nonM, title(Merchants: dailyTotMoney_nonM)
graph export _dailyTotMoney_nonM.eps, replace


**IIa. Take-up & MMoney adoption decisions?
gen wklyNobUsage=c4q11a
gen wklyTotUseVol=c4q11b
hist wklyNobUsage, title(Customers: wklyNobUsage)
graph export _wklyNobUsage.eps, replace
hist wklyTotUseVol, title(Customers: wklyTotUseVol)
graph export _wklyTotUseVol.eps, replace


**IIb. Take-up & NonMMoney adoption decisions?
gen wklyNobUsage_nonM=c4q18a
gen wklyTotUseVol_nonM=c4q18b
hist wklyNobUsage_nonM, title(Customers: wklyNobUsage_nonM)
graph export _wklyNobUsage_nonM.eps, replace
hist wklyTotUseVol_nonM, title(Customers: wklyTotUseVol_nonM)
graph export _wklyTotUseVol_nonM.eps, replace


*IIc. borrow + save behavior?
gen wklyNobBorrow=c5q2a
gen wklyTotBorrowVol=c5q2b
gen wklyNobSave=c5q6a
gen wklyTotSaveVol=c5q6b
sum wklyNobBorrow wklyTotBorrowVol wklyNobSave wklyTotSaveVol



**Graphical evidence
bys Mkt: egen _MktFraudI=mean(cfAttempts)
bys Mkt: egen _MktFraudII=mean(_Xcfraud)

bys Mkt: egen _MktbadStr=mean(c_badMktStructure)
bys Mkt: egen _MktAsym=mean(_asymLocally)

*scatter?
tw (sc _MktFraudI _MktbadStr, jitter(1) xtitle("Market: fraction indicating bad structure") ///
ytitle("Market: Fraction experiencing attempt fraud")) ///
(lfit _MktFraudI _MktbadStr if _MktbadStr<=0.5, lcolor(black) lwidth(thick)) ///
(lfit _MktFraudI _MktbadStr if _MktbadStr>=0.5, lcolor(black) lwidth(thick))

tw (sc _MktFraudI _MktAsym, jitter(1) xtitle("Market: fraction incorrect transactional knowledge") ///
ytitle("Market: Fraction experiencing attempt fraud")) ///
(lfit _MktFraudI _MktAsym if _MktAsym<=0.5, lcolor(black) lwidth(thick)) ///
(lfit _MktFraudI _MktAsym if _MktAsym>=0.5, lcolor(black) lwidth(thick))

*kdensity?
tw (kdensity _MktFraudI if _MktbadStr==0, lcolor(black) xtitle("Market: Attempted fraud rate")) ///
(kdensity _MktFraudI if _MktbadStr==1, lcolor(blue) ytitle("Probability") legend(label(1 "Bad Mkt structure=No") label(2 "Bad Mkt structure=Yes")))
graph export _xdevsKdensStr.eps, replace

tw (kdensity _MktFraudI if _MktAsym==0, lcolor(black) xtitle("Market:  Attempted fraud rate")) ///
(kdensity _MktFraudI if _MktAsym==1, lcolor(blue) ytitle("Probability") legend(label(1 "Incorrect knowledge=No") label(2 "Incorrect knowledge=Yes")))
graph export _xdevsKdensAsy.eps, replace


**III. Selection in fraud? any evidence of discrimination, gender?
reg cfAttempts cfemale cakan cmarried cage cEducAny cMMoneyregistered, cluster(loccode)
reg _Xcfraud cfemale cakan cmarried cage cEducAny cMMoneyregistered, cluster(loccode)

**gen mismatches [& sortingX]?
bys Mkt: gen mismatch_Mktfemale=(cfemale != mfemale)
bys Mkt: gen mismatch_Mktakan=(cakan != makan)
bys Mkt: gen _MktEducHighM=(cEducAny < mEducAny)

reg cfAttempts mismatch_Mktfemale mismatch_Mktakan cmarried cage _MktEducHighM cMMoneyregistered, cluster(loccode)
reg _Xcfraud mismatch_Mktfemale mismatch_Mktakan cmarried cage _MktEducHighM cMMoneyregistered, cluster(loccode)


**poverty rate, by locality etc? 100% Nat. Pov
egen c_rScore = rowtotal(c2q1 - c2q10)
egen m_rScore = rowtotal(m4q1 - m4q10) 

//customers
gen c_pov_likelihood = 91.4 if (c_rScore>=0 & c_rScore<=9)
replace c_pov_likelihood =75.9 if (c_rScore>=10 & c_rScore<=14)
replace c_pov_likelihood =66.8 if (c_rScore>=15 & c_rScore<=19)
replace c_pov_likelihood =63.8 if (c_rScore>=20 & c_rScore<=24)
replace c_pov_likelihood =53.3 if (c_rScore>=25 & c_rScore<=29)
replace c_pov_likelihood =40.2 if (c_rScore>=30 & c_rScore<=34)
replace c_pov_likelihood =29.0 if (c_rScore>=35 & c_rScore<=39)
replace c_pov_likelihood =19.6 if (c_rScore>=40 & c_rScore<=44)
replace c_pov_likelihood =11.7 if (c_rScore>=45 & c_rScore<=49)
replace c_pov_likelihood =7.2 if (c_rScore>=50 & c_rScore<=54)
replace c_pov_likelihood =4.3 if (c_rScore>=55 & c_rScore<=59)
replace c_pov_likelihood =2.2 if (c_rScore>=60 & c_rScore<=64)
replace c_pov_likelihood =1.1 if (c_rScore>=65 & c_rScore<=69)
replace c_pov_likelihood =0.8 if (c_rScore>=70 & c_rScore<=74)
replace c_pov_likelihood =0.3 if (c_rScore>=75 & c_rScore<=79)
replace c_pov_likelihood =0.0 if (c_rScore>=80 & c_rScore<=100)

//merchants
gen m_pov_likelihood = 91.4 if (m_rScore>=0 & m_rScore<=9)
replace m_pov_likelihood =75.9 if (m_rScore>=10 & m_rScore<=14)
replace m_pov_likelihood =66.8 if (m_rScore>=15 & m_rScore<=19)
replace m_pov_likelihood =63.8 if (m_rScore>=20 & m_rScore<=24)
replace m_pov_likelihood =53.3 if (m_rScore>=25 & m_rScore<=29)
replace m_pov_likelihood =40.2 if (m_rScore>=30 & m_rScore<=34)
replace m_pov_likelihood =29.0 if (m_rScore>=35 & m_rScore<=39)
replace m_pov_likelihood =19.6 if (m_rScore>=40 & m_rScore<=44)
replace m_pov_likelihood =11.7 if (m_rScore>=45 & m_rScore<=49)
replace m_pov_likelihood =7.2 if (m_rScore>=50 & m_rScore<=54)
replace m_pov_likelihood =4.3 if (m_rScore>=55 & m_rScore<=59)
replace m_pov_likelihood =2.2 if (m_rScore>=60 & m_rScore<=64)
replace m_pov_likelihood =1.1 if (m_rScore>=65 & m_rScore<=69)
replace m_pov_likelihood =0.8 if (m_rScore>=70 & m_rScore<=74)
replace m_pov_likelihood =0.3 if (m_rScore>=75 & m_rScore<=79)
replace m_pov_likelihood =0.0 if (m_rScore>=80 & m_rScore<=100)


sum c_pov_likelihood m_pov_likelihood //13.9% vs 10.7% need weight? quasi-Census...
bys loccode: sum c_pov_likelihood m_pov_likelihood


*ssc install _gwtmean, replace
bys loccode: gen Nf=_N if mfemale==1
bys loccode: gen Nm=_N if mfemale==0


**income brackets: 1->2
gen income_group= c1q7
hist income_group
bys loccode: egen vincome_group=mean(income_group) 
bys loccode: egen vincome_groupf=mean(income_group) if mfemale==1
bys loccode: egen vincome_groupm=mean(income_group) if mfemale==0

bys loccode: gen worse_incomeGp_FemaleV =(vincome_groupf < vincome_groupm)
bys loccode: gen worse_incomeGp_FemaleV15 =(vincome_groupf < 1.5*vincome_groupm) //to increase sample a bit, SEs later
sum vincome_group vincome_groupf vincome_groupm worse_incomeGp_FemaleV worse_incomeGp_FemaleV15


**indicator for loc where female-v-Poverty > male-v-Poverty
bys loccode: egen vpov_rate=mean(m_pov_likelihood) 
bys loccode: egen vpov_ratef=mean(m_pov_likelihood) if mfemale==1
bys loccode: egen vpov_ratem=mean(m_pov_likelihood) if mfemale==0

bys loccode: gen worse_pov_FemaleV =(vpov_ratef > vpov_ratem)
sum vpov_rate vpov_ratef vpov_ratem worse_pov_FemaleV

*vpov_rate vpov_betterf


**baseline beliefs about misconduct?

gen base_belief_overcharge = (c8q3==1)
hist base_belief_overcharge
sum base_belief_overcharge
bys loccode: egen ocbase_belief_overcharge=mean(base_belief_overcharge) 
bys loccode: egen fcbase_belief_overcharge=mean(base_belief_overcharge) if cfemale==1
bys loccode: egen mcbase_belief_overcharge=mean(base_belief_overcharge) if cfemale==0

hist ocbase_belief_overcharge
hist fcbase_belief_overcharge
hist mcbase_belief_overcharge


sum ocbase_belief_overcharge, d
bys loccode: gen under_bbelief = (ocbase_belief_overcharge < 0.388) //less than overall median belief
tab under_bbelief

bys loccode: gen under_bbelief_fc = (fcbase_belief_overcharge < mcbase_belief_overcharge)
tab under_bbelief_fc


** any selection/discrimination in fraud?
*bys Mkt: gen _Mktpov_HighM =(m_pov_likelihood > c_pov_likelihood)

/*
reg cfAttempts _Mktpov_LowM mismatch_Mktfemale mismatch_Mktakan cmarried cage _MktEducHighM cMMoneyregistered, cluster(loccode)
reg _Xcfraud _Mktpov_LowM mismatch_Mktfemale mismatch_Mktakan cmarried cage _MktEducHighM cMMoneyregistered, cluster(loccode)
*/

**Get unique vender (aka Mkt) ID?
egen universalid = concat(loccode vendor_id)

br distcode loccode vendor_id universalid Mkt
saveold Mkt_fieldData_census, replace

/*
**constraints / needs space?
bys loccode vendor_id: keep if _n==1
tab m2q11
*/


**Trust level for performing money transactions?
use Mkt_fieldData_census, clear
sum c8q6, d //above median - preserve variance
gen trustNo=(c8q6<=3)
gen trustYes=(c8q6>3)
tab trustNo 
tab trustYes
sum trustNo trustYes
ttesti 1275 0.62 0.48 779 0.37 0.48 //pval=0.000

gr bar trustNo trustYes

graph hbar trustNo trustYes, bar(1, color(black)) bar(2, color(gs8)) nofill asyvars ///
 blabel(group, position(inside) format(%4.2f) box fcolor(white) lcolor(white)) ytitle("Trust in Transacting:  Share indicating no vs yes", size(small)) blabel(bar) ///
 legend(pos(7) row(1) stack label(1 "Trust=No") label(2 "Trust=Yes"))
gr export "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/FFPhone in 2020/_impact-evaluation/trust_transacting_graph.eps", replace







use Mkt_fieldData_census, clear
**Title: balancing gender goals: evaluating the impacts of gender and competition on m-money
*0. In devpg ctrs: M-Money has the potential to lift people out of poverty, particularly women (Suri & Jack SC 2016)
* Women and minorities have higher rates of poverty than men...so maximizing m-money's impacts 
*A # of factors underlie these disparities; but one problem is perhaps the lack of gender balance/ diversity in vendorshop
**Facts #1: Vendors -- women hold large pop shares yet:
*descriptive evid that (rural financial) market disproportionately more male vendors: 60 vs 40
*Feature similar to finance in developed ctr settings, which are more male dominated 

**Facts #2: Customers -- descriptive evid of gender gaps in adoption or usage
**We don't cluster the SEs to reject the null (of no-diff) more often
**M-Money
gen useTimesWeek = c4q11a
replace useTimesWeek=. if useTimesWeek==99
gen useEverWeek=(useTimesWeek>0)
gen useVolWeek = c4q11b
replace useVolWeek=. if useVolWeek==99

sum useTimesWeek useEverWeek useVolWeek if useVolWeek<4000
sum useTimesWeek useEverWeek useVolWeek if useVolWeek


reg cMMoneyregistered cfemale
reg useEverWeek cfemale
reg useTimesWeek cfemale
reg useVolWeek cfemale
 
areg cMMoneyregistered cfemale, absorb(loccode)
areg useEverWeek cfemale, absorb(loccode)
areg useTimesWeek cfemale, absorb(loccode) 
areg useVolWeek cfemale, absorb(loccode)

areg cMMoneyregistered c.cfemale##c.cmarried, absorb(loccode)
areg useEverWeek c.cfemale##c.cmarried, absorb(loccode)
areg useTimesWeek c.cfemale##c.cmarried, absorb(loccode) 
areg useVolWeek c.cfemale##c.cmarried, absorb(loccode)
**females customers sig less likely to use (extensive 4pp + intensive GHS100) yet similar account ownserhip of M-Money
**Could? may be driven by gender imbalance in vendorship (fewer female vendors), incl other factors
**competition in vendorship won't address this per se if gender is not balanced
**seeing more women vendors provides useful market info, promotes communication and then more trust-building (new tech)

**only-F vs only-M vs only-Mix
bys loccode: egen pct_female = mean(mfemale)
bys loccode: replace pct_female = pct_female*100

hist pct_female, disc
bys loccode: gen onlyMalev = (pct_female==0)
bys loccode: gen onlyFemalev = (pct_female==100)
bys loccode: gen onlyMix = (pct_female>0 & pct_female<100)

areg useVolWeek c.cfemale##c.cmarried, absorb(loccode)
areg useVolWeek c.cfemale##c.cmarried if onlyMalev==1, absorb(loccode)
areg useVolWeek c.cfemale##c.cmarried if onlyFemalev==1, absorb(loccode)
areg useVolWeek c.cfemale##c.cmarried if onlyMix==1, absorb(loccode)



**Design I: competition arm (jobs: M+W) versus gender arm (jobs: W)
**To cleanly separate gender effect from compitition and examine effects of both on customers/users gender gaps in adoption

**Since females are poorer, suggest interventions not only balances vendorship (their empwment etc) 
**but will maximize M-Money impacts and facilitate equal dividends across the spectrum

**OTHER Outcomes...
**business (e.g., how incumbents respond: volumes, misconduct, diversification/specialization) 
**and customers: communication(TTime, discussions about other businesses)+Trust(Elicit), poverty in LT**

**Design II:
**Arm 1 (give unconditional money to transact: Wc -> Fv) versus 
**Arm 2 (give unconditional money to transact: Wc -> Mv)
*transact as much you want up to T given
*only restriction is go to a woman or not 
**Transaction Detail Records: amount transacted, timespan, other relevant discussions, selection picture: man vs woman vendor?



*
**II. audit Trials?
*Audit sample selection
**representative? locality (subsumes district)
*(We don't cluster --only 2x2 design-- to reject more often)

use Mkt_fieldData_census, clear
**1: get representative Mkt (per locality)
keep if (_merge==3) //only Merchant-Customer pairs that merged right? b/c can't study just 1
drop _merge


**Get mkt summaries & restrictions?
bys loccode: gen CustPerLocal= _N
*keep if CustPerLocal>=5
hist CustPerLocal //dis: tot no of cust per local
sum CustPerLocal // 1 to 47 with avg=20.8<21 customers

egen count_loccode=group(loccode)
tab count_loccode, miss //137-> 134 (115?) success

egen local_by_vendor = group(loccode vendor_id)
tab local_by_vendor, miss //480-> 337 (315?) a drop
tab Mkt, miss //480-> 337 (315?) a drop

bys loccode: gen mktFip = group(vendor_id)

*bys loccode: gen MktPerLocal = _N
hist MktPerLocal //dis: tot no of Mkt(/merch) per local
sum MktPerLocal // 1 to 12 with avg=3.2<4 merchants
tab MktPerLocal

bys loccode vendor_id: gen CustPer_w_Mkt = _N
hist CustPer_w_Mkt //dis: tot no of within-Cust per mkt
tab CustPer_w_Mkt



**get "rep market" per each locality?
preserve 
bys loccode vendor_id: keep if _n==1
br loccode vendor_id Mkt

set seed 12345
bys loccode: gen rand_num = uniform()
bys loccode: gen x = _N
by loccode (rand_num), sort: gen sample_repMkt = _n==x
tab sample_repMkt, miss

*gen rand_num = uniform()
*by loccode (rand_num), sort: gen sample_repMkt = _n==1
*tab sample_repMkt, miss

keep ln loccode vendor_id vn Mkt rand_num sample_repMkt* m1q9a m1q9b m1q0d worse_pov_FemaleV worse_incomeGp_FemaleV worse_incomeGp_FemaleV15 base_belief_overcharge ocbase_belief_overcharge fcbase_belief_overcharge mcbase_belief_overcharge under_bbelief under_bbelief_fc
*keep ln loccode vendor_id vn cn Mkt rand_num sample_repMkt m1q9a c1q8a m1q9b c1q8b m1q0d c1q0b
br

**more cleaning? 3 more drops...no info
drop if (m1q0d=="")
drop if (m1q0d=="PABI" | m1q0d=="XXX" | vn=="XXXXXX")
tab sample_repMkt, miss //130 loc or repMkts now...
*br if (m1q0d=="" | m1q0d=="PABI" | m1q0d=="XXX" | vn=="XXXXXX")
save repMkt, replace
restore



**QUEST: ***balance achieved -- DIFF from population?
merge m:1 loccode vendor_id using "repMkt.dta"
save repMkt_w_xtics, replace



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
saveold Mkt_fieldData_sample_repMkt, replace

*/

sum cfAttempts _clocalpFraud 
**seanHiggins-descriptive: gender differences? n=1921. Nothing!
reg cfAttempts cfemale, cluster(loccode)
reg _Xcfraud cfemale, cluster(loccode)

reg cfAttempts cfemale, cluster(loccode)
reg _clocalpFraud cfemale, cluster(loccode)
reg cfAccountUse cfemale, cluster(loccode)
reg everOvercharged cfemale, cluster(loccode)



gen cfAttempts =(c5q7a==1 | c5q7b==1 | c5q7c==1)
replace cfAttempts=. if missing(c5q7a)
replace cfAttempts=. if missing(c5q7b)
replace cfAttempts=. if missing(c5q7c)

gen cfAccountUse =(c5q7a==1)
replace cfAccountUse=. if missing(c5q7a)

gen cfCallers =(c5q7b==1)
replace cfAccountUse=. if missing(c5q7b)

gen cfIncorrects =(c5q7c==1)
replace cfIncorrects=. if missing(c5q7c)

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




/*
**ONLY: dta for field-Auditors: the 130 repMkts?
use repMkt, clear
tab sample_repMkt, miss
keep if sample_repMkt==1

gen double localityCode_j=loccode

merge 1:1 localityCode_j using "/Users/fa2316/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/sampling?/sel_9Distr_137Local_List"
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

merge m:1 localityCode_j using "/Users/fa2316/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/sampling?/sel_9Distr_137Local_List"
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
*use "/Users/fa2316/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/sampling?/sel_9Distr_137Local_List", clear
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
keep if ln=="ANYINASIN" vlocation: (oposite presby church)*
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
merge m:1 localityCode_j using "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/sampling?/sel_9Distr_137Local_List"
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
outsheet using "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/data-Mgt/Stats?/vendorsRoster_by_locality_T98/_`v'_vList_`loccodex'.xls", replace
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
merge m:1 localityCode_j using "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/sampling?/sel_9Distr_137Local_List"
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
outsheet using "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/data-Mgt/Stats?/vendorsRoster_by_locality_Ctrl32/_`v'_ctrl_vList_`loccodex'.xls", replace
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
outsheet using "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/data-Mgt/Stats?/junk_interventionsTomake_list_local_onlyCtrl_+questions.xls", replace





**Mkt census: Get percent of femal vendors per locality; competition measure=hhi?
use Mkt_fieldData_census, clear
gen double localityCode_j=loccode
drop _merge
merge m:1 localityCode_j using "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/sampling?/sel_9Distr_137Local_List"
keep if _merge==3

**all vendors per locality =137 all here**
bys districtName loccode vendor_id: keep if _n==1

**%of Female v's? Say, at least 3 vendors in locality
bys loccode: egen pct_female = mean(mfemale)
bys loccode: replace pct_female = pct_female*100

bys loccode: gen sN =_N
replace pct_female=. if sN <2
twoway histogram pct_female, frac ytitle("Fraction of localities") xtitle("% Female vendors per locality")
gr export "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/_project/pct_female_hist.eps", replace


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

saveold pct_female_Mktcensus, replace
saveold pct_female_MktcensusStar, replace


**vary by gender?
gr tw (kdensity HHI if mfemale==0, lpattern(dash)) || (kdensity HHI if mfemale==1, lpattern(solid) xtitle("Herfindahl-Hirschman index: n (Males)=231, n (Females)=157") ytitle("Kdensity") legend(pos(3) col(1) stack label(1 "Males") label(2 "Females")))
gr export "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/_project/hhibyGender.eps", replace

drop if missing(HHI)
drop if missing(mfemale)
cdfplot HHI, by(mfemale) opt1(lc(blue red)) xtitle("Herfindahl-Hirschman index: n (Males)=231, n (Females)=157") ytitle("CDF") legend(pos(3) col(1) stack label(1 "Males") label(2 "Females"))
gr export "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/_project/hhibyGender_cdf.eps", replace

reg HHI mfemale, r
reg HHI mfemale, cluster(loccode)

ksmirnov HHI, by(mfemale)
ksmirnov HHI, by(mfemale) exact //perhaps parts of distr? no power



**Riskies: short phone surveys, vendors n=50?
use repMkt, clear
tab sample_repMkt, miss
keep if sample_repMkt==0

gen double localityCode_j=loccode
merge m:1 localityCode_j using "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/sampling?/sel_9Distr_137Local_List"
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
**get distr level rep 35 vendors?
randtreat, generate(riskies) replace unequal(1/4 1/4 1/4 1/4) strata(districtID) misfits(wstrata) setseed(12345)
tab riskies, miss
tab districtID riskies

keep if riskies==0
keep districtID districtName loccode loccodex ln vn vendor_id vDescribe vPhone1 vPhone1x vPhone1xx vPhone2 vPhone2x vPhone2xx sample_repMkt riskies
order districtName ln vn vDescribe vPhone1xx vPhone2xx
tab districtID
tab districtName

saveold riskiesTomake_list, replace
outsheet using riskiesTomake_list.xls, replace
*/



/* JUNK
use "Mkt_fieldData_sample_hfreq_4TrtGroups_9dist", clear

bys loccode vendor: gen xx=_N
tab x //1-25 customers; only nearby customers that surround repMkt (not all in locality possibly)

**vendor side??
*gen districtID = regionDistrictCode_j
*label var districtID "District code/ ID -- unique"
*label var loccode "Locality code/ ID -- unique"

label var vendor_id "vendor ID - unique only within locality"
label var vn "vendor name"
*gen vDescribe = m1q0d
*label var vDescribe "Describe location -- vendor"
*gen double vPhone1=m1q9a
*label var vPhone1 "Phone number -- primary"
*gen double vPhone2=m1q9b
*label var vPhone2 "Phone number -- secondary"

**customer side??
gen customer_id = custcode
label var customer_id "customer ID - unique only within locality"
label var cn "customer name, nearby"
gen cDescribe = c1q0b
label var cDescribe "Describe location -- customer nearby"
gen double cPhone1=c1q8a
label var cPhone1 "Phone number -- primary, customer nearby"
gen double cPhone2=c1q8b
label var cPhone2 "Phone number -- secondary, customer nearby"

order districtID districtName loccode ln ///
vn vendor_id vDescribe vPhone1 vPhone2 ///
cn customer_id cDescribe cPhone1 cPhone2 treatment

gen intervention =""
replace intervention="Control" if treatment==0
replace intervention="PriceTransparency, PT" if treatment==1
replace intervention="MKtMonitoring, MM" if treatment==2
replace intervention="joint: PT+MM" if treatment==3
label var intervention "intervention or treatment type to implement"

keep districtID districtName loccode ln ///
vn vendor_id vDescribe vPhone1 vPhone2 ///
cn customer_id cDescribe cPhone1 cPhone2 intervention 

saveold interventionsTomake_list, replace
outsheet using interventionsTomake_list.xls, replace

*/


*JPE REVISION SEP 6 2022
*survey 32 control rep-vendors 
cd "/Users/fa2316/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/data-Mgt/Stats?"
use ONLY_4TrtGroups_9dist, clear
keep if treatment==0 //control rep-vendors
saveold JPEr_control_rep_vVendors_survey, replace
outsheet using JPEr_control_rep_vVendors_survey.xls, replace

*SEP 11 2022
use vendorsRoster_by_locality_Ctrl32, clear
merge m:1 ln loccodex districtName vn vendor_id using JPEr_control_rep_vVendors_survey
bys districtName ln vn: drop if _n>1
sort _merge
keep districtID districtName loccode loccodex ln vn vendor_id vDescribe vPhone1 vPhone1x vPhone1xx vPhone2 vPhone2x vPhone2xx treatment
outsheet using JPEr_control_ALL_vVendors_survey.xls, replace





