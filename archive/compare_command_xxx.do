*Customers?
**************
***************
clear all
set seed 100001

*use "/Users/fa2316/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/FFPhone in 2020/Customer.dta", clear
use "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/FFPhone in 2020/Customer.dta", clear

*hist c1a2
*hist c1b2
gen districtName = cdistrict_name 
gen ln = clocality_name
gen districtID= cdistrict_code 
tostring customer2020_id, gen(_customer2020_id) format(%17.0g) //convert double to string

gen _localityid= substr(_customer2020_id,1,12)
gen _customerid= substr(_customer2020_id,-3,.)
destring _localityid _customerid, gen(loccode customer_id) //create matches with census data

*merge m:m loccode customer_id using "/Users/fa2316/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/data-Mgt/Stats?/Mkt_census_xtics_+_interventions_localized.dta"
merge m:m loccode customer_id using "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/data-Mgt/Stats?/Mkt_census_xtics_+_interventions_localized.dta"

*keep if _merge ==3
*drop if _n>950

*drop if date_of_interview == 10052020
drop if date_of_interview == 11052020
*drop if date_of_interview == 14052020


tab intervention
gen trtment = (intervention != "Control")

gen trtment_mm =.
replace trtment_mm=1 if (intervention == "MKtMonitoring, MM")
replace trtment_mm=0 if (intervention == "Control")

gen trtment_pt=.
replace trtment_pt=1 if (intervention == "PriceTransparency, PT")
replace trtment_pt=0 if (intervention == "Control")

gen trtment_mmpt=.
replace trtment_mmpt=1 if (intervention == "joint: PT+MM")
replace trtment_mmpt=0 if (intervention == "Control")

gen trt=0
replace trt=1 if intervention=="PriceTransparency, PT"
replace trt=2 if intervention=="MKtMonitoring, MM"
replace trt=3 if intervention=="joint: PT+MM"

sum trt*
egen xloc =group(loccodex)
*tab xloc


*distplot c0a //customers answer quicker than vendors/business (as expected)


*
**Validy: Attrition?
**(1) differential attrition/ drop outs?
tab _merge
gen dropouts = (_merge==2)
ciplot dropouts, by(trtment) title("differential attrition?")
ciplot dropouts, by(trt) title("differential attrition?")
bys trtment: sum dropouts 
dis 0.23-0.18 //control has 5pp higher attrition, responserate for treatment=0.82=82% 
tab dropouts if trtment==0
tab dropouts if trtment==1
**so trim 0.05/0.82 = 6.1% of treatment group
**764 responses, so triming 46 customers
/*
gen item= y if trtment==1
gen iranklo_a =rank(item) if trtment==1, unique
gen iranklo_b =rank(-item) if trtment==1, unique
gen yupper= y
replace yupper=. if trtment==1 & iranklo_a<=46
gen ylower= y
replace ylower=. if trtment==1 & iranklo_b<=46
areg ylower trtment, a(districtID) robust
areg yupper trtment, a(districtID) robust
*/


bys trt: sum dropouts 


**(2) balanced?
*3a Demand: customer xtics, same mkt?
** xtics? married out...
reg cfemale dropouts, cluster(loccode)
reg cmarried dropouts, cluster(loccode)
reg cakan dropouts, cluster(loccode)
reg cage dropouts, cluster(loccode)
reg cEducAny dropouts, cluster(loccode)
reg cselfemployed dropouts, cluster(loccode)
reg cselfIncome dropouts, cluster(loccode)
reg cMMoneyregistered dropouts, cluster(loccode)

**migrate?
gen migrateDesire= (c7q1==1)
gen migratein1yr = (c7q3 <3)
gen migratepermanent = (c7q4 ==2)
factor migrateDesire migratein1yr migratepermanent
predict migrate_score_c
reg migrateDesire dropouts, cluster(loccode)
reg migratein1yr dropouts, cluster(loccode)
reg migratepermanent dropouts, cluster(loccode)
reg migrate_score_c dropouts, cluster(loccode)


**poverty?
reg c2q1 dropouts, cluster(loccode)
reg c2q2 dropouts, cluster(loccode)
reg c2q3 dropouts, cluster(loccode)
reg c2q4 dropouts, cluster(loccode)
reg c2q5 dropouts, cluster(loccode)
reg c2q6 dropouts, cluster(loccode)
reg c2q7 dropouts, cluster(loccode)
reg c2q8 dropouts, cluster(loccode)
reg c2q9 dropouts, cluster(loccode)
reg c2q10 dropouts, cluster(loccode)
reg c_pov_likelihood dropouts, cluster(loccode)

**fraud?
reg cfAttempts dropouts, cluster(loccode)
reg _Xcfraud dropouts, cluster(loccode)

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

reg distToBank dropouts, cluster(loccode)
reg distToMMoney dropouts, cluster(loccode)

*reg wklyNobUsage dropouts, cluster(loccode)
reg wklyTotUseVol dropouts, cluster(loccode)
reg wklyNobUsage_nonM dropouts, cluster(loccode)
reg wklyTotUseVol_nonM dropouts, cluster(loccode)
**get distribution effects-main? which bound is more likely?
sqreg wklyTotUseVol dropouts, q(.25 .5 .75)


*3c borrow + save behavior?
gen likelyborrowMMoney =c5q1
gen likelysaveMMoney =c5q5
reg likelyborrowMMoney dropouts, cluster(loccode)
reg likelysaveMMoney dropouts, cluster(loccode)
**get distribution effects-main? which bound is more likely?
sqreg likelysaveMMoney dropouts, q(.25 .5 .75)

/* 
reg wklyNobBorrow dropouts, cluster(loccode)
reg wklyTotBorrowVol dropouts, cluster(loccode)
reg wklyNobSave dropouts, cluster(loccode)
reg wklyTotSaveVol dropouts, cluster(loccode)
*/
**joint, exclude main Y?
reg dropouts cfemale cmarried cakan cage cEducAny cselfemployed cselfIncome cMMoneyregistered, cluster(loccode)
test cfemale cmarried cakan cage cEducAny cselfemployed cselfIncome cMMoneyregistered
probit dropouts cfemale cakan cmarried cage cEducAny cselfemployed cselfIncome cMMoneyregistered, cluster(loccode)
test cfemale cmarried cakan cage cEducAny cselfemployed cselfIncome cMMoneyregistered


**Validity? Triming/bounds and Weighting exercises?





**measurements...
gen mmUser_t1 = (c1a1 > 0) if _merge==3
gen mmUser_t0=(c4q3==1)
replace mmUser_t0=. if missing(c4q3)

gen mmtotnob_t1 = c1a1
gen mmtotnob_t0 = c4q11a
replace mmtotnob_t0=. if missing(c4q11a)

gen log_mmtotamt_t1 = log(c1a2+1)
gen mmtotamt_t0 = c4q11b
replace mmtotamt_t0=. if missing(c4q11b)

gen mmtotamt_t1 = c1a2



gen nonmmUser_t1 = (c1b1 > 0) if _merge==3
gen nonmmUser_t0=(c4q18a > 0)
replace nonmmUser_t0=. if missing(c4q18a)

gen nonmmtotnob_t1 = c1b1
gen nonmmtotnob_t0 = c4q18a
replace nonmmtotnob_t0=. if missing(c4q18a)

gen log_nonmmtotamt_t1 = log(c1b2+1)
gen nonmmtotamt_t0 = c4q18b
replace nonmmtotamt_t0=. if missing(c4q18b)


/**per capita?
gen pc_c1a = c1a2/c1a1
gen pc_wklyTotUseVol=wklyTotUseVol/wklyNobUsage
gen pc_c1b = c1b2/c1b1
gen pc_wklyTotUseVol_nonM=wklyTotUseVol_nonM/wklyNobUsage_nonM
*/

gen save_t1 =(c3>2) if _merge==3
gen save_t0 =(c4q5==1)
replace save_t0=. if missing(c4q5)

gen indebt_t1 =(c2>2) if _merge==3
gen indebt_t0 =(c5q1>2)
replace indebt_t0=. if missing(c5q1)


*tab districtID, gen(districtID)
egen locfes = group(loccode)
*tab locfes, gen(locfes)

*save "/Users/fa2316/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/FFPhone in 2020/Customer_+_Mktcensus_+_Interventions.dta", replace  //good? yes
*use "/Users/fa2316/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/FFPhone in 2020/Customer_+_Mktcensus_+_Interventions.dta", clear
