/*
JPE2023-Annan
y = shocks mitigation: financial resilience*
Phone Surveys + Intensive Tracking: April 2020+

Input:
	- FFPhone in 2020/CustomersData.dta
	- data-Mgt/Stats?/Mkt_census_xtics_+_interventions_localized.dta
Output:
	- NA
*/

***************
use "$dta_loc/FFPhone in 2020/CustomersData.dta", clear
gen districtName = cdistrict_name 
gen ln = clocality_name
gen districtID= cdistrict_code 
tostring customer2020_id, gen(_customer2020_id) format(%17.0g) //convert double to string

gen _localityid= substr(_customer2020_id,1,12)
gen _customerid= substr(_customer2020_id,-3,.)
destring _localityid _customerid, gen(loccode customer_id) //create matches with census data

merge m:m loccode customer_id using "$dta_loc/data-Mgt/Stats?/Mkt_census_xtics_+_interventions_localized.dta"


**attrition stats: numbers
tab _merge
tab intervention
gen dropouts = (_merge==2)
tab intervention if dropouts==0
*get mean=% and SD=%?
gen ins=(dropouts==0)
tabstat ins, stat(mean sd n) by(intervention)
tabstat dropouts, stat(mean sd n) by(intervention)

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

*Attrition - Test for Significance by Treatment Program
gen trt_pool = (trt !=0)
sum dropouts if trt_pool==0
reg dropouts trt_pool, cluster(loccodex)
reg dropouts i.trt, cluster(loccodex)

*distplot c0a, saving("distplot_ccalls", replace) //customers answer quicker than vendors/business (as expected)
*hist c0a, percent xtitle("Customers: Number of phone call times before answering survey")
*gr export "/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/FFPhone in 2020/_impact-evaluation/customer_calltimeS.eps", replace

**differential attrition/ drop outs?
tab _merge
bys trtment: sum dropouts 
dis 0.23-0.18 //control has 5pp higher attrition, responserate for treatment=0.82=82% 
tab dropouts if trtment==0
tab dropouts if trtment==1
**so trim 0.05/0.82 = 6.1% of treatment group
**764 responses, so triming 46 customers

bys trt: sum dropouts 


****************
**Measurements**
****************
gen mmUser_t1 = (c1a1 > 0) if _merge==3
gen mmUser_t0=(c4q3==1)
replace mmUser_t0=. if missing(c4q3)

gen mmtotnob_t1 = c1a1
gen mmtotnob_t0 = c4q11a

gen log_mmtotamt_t1 = log(c1a2+1) if !missing(c1a2)
gen log_mmtotamt_t0=log(c4q11b+1) if !missing(c4q11b)

gen mmtotamt_t1 = c1a2
gen mmtotamt_t0 = c4q11b
*hist mmtotamt_t1, discrete

gen nonmmUser_t1 = (c1b1 > 0) if _merge==3
gen nonmmUser_t0=(c4q18a > 0)
replace nonmmUser_t0=. if missing(c4q18a)

gen nonmmtotnob_t1 = c1b1
gen nonmmtotnob_t0 = c4q18a

*gen log_nonmmtotamt_t1 = log(c1b2+1) if !missing(c1b2)
*gen log_nonmmtotamt_t0 = log(c4q18b+1) if !missing(c4q18b)

gen nonmmtotamt_t1 = c1b2
gen nonmmtotamt_t0 = c4q18b

gen save_t1 =(c3>2) if _merge==3
gen save_t0 =(c4q5==1)
replace save_t0=. if missing(c4q5)

gen indebt_t1 =(c2>2) if _merge==3
gen indebt_t0 =(c5q1>2)
replace indebt_t0=. if missing(c5q1)

egen locfes = group(loccode)
tab locfes, gen(locfes)

/*
gen ihs_mmtotamt_t1 = asinh(mmtotamt_t1)
gen ihs_mmtotamt_t0 = asinh(mmtotamt_t0)
factor ihs_mmtotamt_t1 mmUser_t1 save_t1
predict score_MMoneyDd_t1
factor ihs_mmtotamt_t0 mmUser_t0 save_t0
predict score_MMoneyDd_t0
*/


**unmitigated shocks?
gen udeath=(c21a==1) if _merge==3
gen urevenue=(c21b==1) if _merge==3
gen usickness=(c21c==1) if _merge==3
gen uweather=(c21d==1) if _merge==3
gen uprices=(c21e==1) if _merge==3
gen ushocks=(c21f==1) if _merge==3

gen udeath_t0=(c6q1a==1) 
gen urevenue_t0=(c6q1b==1)
gen usickness_t0=(c6q1c==1)
gen uweather_t0=(c6q1d==1) 
gen uprices_t0=(c6q1e==1)
gen ushocks_t0=(c6q1f==1)

gen ushocks_exp_t1 = (udeath==1 | urevenue==1 | usickness==1 | uweather==1 | uprices==1 | ushocks==1)  if _merge==3
gen ushocks_exp_t0 = (udeath_t0==1 | urevenue_t0==1 | usickness_t0==1 | uweather_t0==1 | uprices_t0==1 | ushocks_t0==1) if _merge==3

gen health_t1=(usickness==1 | ushocks==1) if _merge==3
gen revenue_t1=(urevenue==1 | ushocks==1) if _merge==3
gen hhexpense_t1= (ushocks==1) if _merge==3


**midterm: poverty effects?
**poverty rate, by locality etc? 100% Nat. Pov
gen c_pov_likelihood_t0=c_pov_likelihood if _merge==3
egen c_rScore_t1 = rowtotal(c11 - c20) if _merge==3
gen c_pov_likelihood_t1 = 91.4 if (c_rScore_t1>=0 & c_rScore_t1<=9)
replace c_pov_likelihood_t1 =75.9 if (c_rScore_t1>=10 & c_rScore_t1<=14)
replace c_pov_likelihood_t1 =66.8 if (c_rScore_t1>=15 & c_rScore_t1<=19)
replace c_pov_likelihood_t1 =63.8 if (c_rScore_t1>=20 & c_rScore_t1<=24)
replace c_pov_likelihood_t1 =53.3 if (c_rScore_t1>=25 & c_rScore_t1<=29)
replace c_pov_likelihood_t1 =40.2 if (c_rScore_t1>=30 & c_rScore_t1<=34)
replace c_pov_likelihood_t1 =29.0 if (c_rScore_t1>=35 & c_rScore_t1<=39)
replace c_pov_likelihood_t1 =19.6 if (c_rScore_t1>=40 & c_rScore_t1<=44)
replace c_pov_likelihood_t1 =11.7 if (c_rScore_t1>=45 & c_rScore_t1<=49)
replace c_pov_likelihood_t1 =7.2 if (c_rScore_t1>=50 & c_rScore_t1<=54)
replace c_pov_likelihood_t1 =4.3 if (c_rScore_t1>=55 & c_rScore_t1<=59)
replace c_pov_likelihood_t1 =2.2 if (c_rScore_t1>=60 & c_rScore_t1<=64)
replace c_pov_likelihood_t1 =1.1 if (c_rScore_t1>=65 & c_rScore_t1<=69)
replace c_pov_likelihood_t1 =0.8 if (c_rScore_t1>=70 & c_rScore_t1<=74)
replace c_pov_likelihood_t1 =0.3 if (c_rScore_t1>=75 & c_rScore_t1<=79)
replace c_pov_likelihood_t1 =0.0 if (c_rScore_t1>=80 & c_rScore_t1<=100)
sum c_pov_likelihood_t0 c_pov_likelihood_t1


** Table 9+10 ---------------------------------------------------------------------
sum ushocks_exp_t1 revenue_t1 health_t1 hhexpense_t1 c_pov_likelihood_t1 if trtment==0
regress ushocks_exp_t1 ushocks_exp_t0 i.districtID cfemale cage cmarried cakan cselfemployed cEducAny cselfIncome trtment if _merge==3, cluster(loccodex) level(95)
regress revenue_t1 urevenue_t0 i.districtID cfemale cage cmarried cakan cselfemployed cEducAny cselfIncome trtment if _merge==3, cluster(loccodex) level(95)
regress health_t1 usickness_t0 i.districtID cfemale cage cmarried cakan cselfemployed cEducAny cselfIncome trtment if _merge==3, cluster(loccodex) level(95)
regress hhexpense_t1 ushocks_t0 i.districtID cfemale cage cmarried cakan cselfemployed cEducAny cselfIncome trtment if _merge==3, cluster(loccodex) level(95)
regress c_pov_likelihood_t1 c_pov_likelihood_t0 i.districtID cfemale cage cmarried cakan cselfemployed cEducAny cselfIncome trtment if _merge==3, cluster(loccodex) level(95)


tab trt, gen(trt)
regress ushocks_exp_t1 ushocks_exp_t0 i.districtID cfemale cage cmarried cakan cselfemployed cEducAny cselfIncome trt2 trt3 trt4 if _merge==3, cluster(loccodex) level(95)
test _b[trt2]=_b[trt4]
test _b[trt3]=_b[trt4]
test _b[trt2]=_b[trt3]
test _b[trt2] + _b[trt3] =_b[trt4]
regress revenue_t1 urevenue_t0 i.districtID cfemale cage cmarried cakan cselfemployed cEducAny cselfIncome trt2 trt3 trt4 if _merge==3, cluster(loccodex) level(95)
test _b[trt2]=_b[trt4]
test _b[trt3]=_b[trt4]
test _b[trt2]=_b[trt3]
test _b[trt2] + _b[trt3] =_b[trt4]
regress health_t1 usickness_t0 i.districtID cfemale cage cmarried cakan cselfemployed cEducAny cselfIncome trt2 trt3 trt4 if _merge==3, cluster(loccodex) level(95)
test _b[trt2]=_b[trt4]
test _b[trt3]=_b[trt4]
test _b[trt2]=_b[trt3]
test _b[trt2] + _b[trt3] =_b[trt4]
regress hhexpense_t1 ushocks_t0 i.districtID cfemale cage cmarried cakan cselfemployed cEducAny cselfIncome trt2 trt3 trt4 if _merge==3, cluster(loccodex) level(95)
test _b[trt2]=_b[trt4]
test _b[trt3]=_b[trt4]
test _b[trt2]=_b[trt3]
test _b[trt2] + _b[trt3] =_b[trt4]
regress c_pov_likelihood_t1 c_pov_likelihood_t0 i.districtID cfemale cage cmarried cakan cselfemployed cEducAny cselfIncome trt2 trt3 trt4 if _merge==3, cluster(loccodex) level(95)
test _b[trt2]=_b[trt4]
test _b[trt3]=_b[trt4]
test _b[trt2]=_b[trt3]
test _b[trt2] + _b[trt3] =_b[trt4]

?
** Table C10 ---------------------------------------------------------------------
*Robustness checks - Inference, Multiple Testing, Attrition, LASSO Estimation
*POOLED
***wild cluster bootstrap, pval
reg ushocks_exp_t1 ushocks_exp_t0 i.districtID cfemale cage cmarried cakan cselfemployed cEducAny cselfIncome trtment if _merge==3, cluster(loccode) level(95)
boottest trt, rep(1000) level(95) nogr seed(15465)
**randomization inf: permuntation test, pval
ritest trtment _b[trtment], reps(1000) cluster(loccode) strata(districtID) seed(546): reg ushocks_exp_t1 ushocks_exp_t0 i.districtID cfemale cage cmarried cakan cselfemployed cEducAny cselfIncome trtment
**mht: implement Romano-Wolf (2005) procedure, pval
rwolf ushocks_exp_t1 revenue_t1 health_t1 hhexpense_t1 c_pov_likelihood_t1, indepvar(trtment trt2 trt3 trt4) reps(1000) seed(124) controls(i.districtID cfemale cage cmarried cakan cselfemployed cEducAny cselfIncome) //family (all 4 0-1 shocks, poverty %)
**attrition bounds
**1. [Lee Bounds]**
leebounds ushocks_exp_t1 trtment, level(95) cieffect tight()
**2. [Behajel et al. Bounds]**
gen attempts= c0a
bys trtment: tab attempts
**with 3 or less phone /contact attempts: ctr has 92% response rate, trt has 95% response rate
**use number of attempts - "effort" to rank & bound te
**so trim (95-92)/95 =3% of trt group, x 667= 20 customers out
**Simply trim as follows:
foreach x of varlist ushocks_exp_t1 {
preserve
display "`x'"
gen itemA= `x' if trtment==1 & attempts<=3 
egen iranklo_Aa =rank(itemA) if trtment==1, unique //from above
egen iranklo_Ab =rank(-itemA) if trtment==1, unique //from below
gen yupperA= `x'
replace yupperA=. if (trtment==1 & iranklo_Aa<=20) | (trtment==1 & attempts>3) //trim differences within 3 attempts and cut off all above 3-attempts
gen ylowerA= `x'
replace ylowerA=. if (trtment==1 & iranklo_Ab<=20) | (trtment==1 & attempts>3)
reg ylowerA  trtment, r
reg yupperA trtment, r
restore
		} 
*

*SEPARATE
***wild cluster bootstrap, pval
reg ushocks_exp_t1 ushocks_exp_t0 i.districtID cfemale cage cmarried cakan cselfemployed cEducAny cselfIncome trt2 trt3 trt4 if _merge==3, cluster(loccode) level(95)
boottest trt2, rep(1000) level(95) nogr seed(15465)
boottest trt3, rep(1000) level(95) nogr seed(15465)
boottest trt4, rep(1000) level(95) nogr seed(15465)
**randomization inf: permuntation test, pval
ritest trt2 trt3 trt4 _b[trt2] _b[trt3] _b[trt4], reps(1000) cluster(loccode) strata(districtID) seed(546): reg ushocks_exp_t1 ushocks_exp_t0 i.districtID cfemale cage cmarried cakan cselfemployed cEducAny cselfIncome trt2 trt3 trt4
**mht: implement Romano-Wolf (2005) procedure, pval
rwolf ushocks_exp_t1 revenue_t1 health_t1 hhexpense_t1 c_pov_likelihood_t1, indepvar(trt2 trt3 trt4) reps(1000) seed(124) controls(i.districtID cfemale cage cmarried cakan cselfemployed cEducAny cselfIncome) //family (all 4 0-1 shocks, poverty %)
**attrition bounds
**1. [Lee Bounds]**
foreach x of varlist trt2 trt3 trt4 {
leebounds ushocks_exp_t1 `x', level(95) cieffect tight() 
		}
*
/* dropped to save table space
**2. [Behajel et al. Bounds]**
foreach x of varlist ushocks_exp_t1 {
preserve
display "`x'"
gen itemA= `x' if trt2==1 & attempts<=3 
egen iranklo_Aa =rank(itemA) if trt2==1, unique //from above
egen iranklo_Ab =rank(-itemA) if trt2==1, unique //from below
gen yupperA= `x'
replace yupperA=. if (trt2==1 & iranklo_Aa<=20) | (trt2==1 & attempts>3) //trim differences within 3 attempts and cut off all above 3-attempts
gen ylowerA= `x'
replace ylowerA=. if (trt2==1 & iranklo_Ab<=20) | (trt2==1 & attempts>3)
reg ylowerA  trt2, r
reg yupperA trt2, r
restore
		}
*
foreach x of varlist ushocks_exp_t1 {
preserve
display "`x'"
gen itemA= `x' if trt3==1 & attempts<=3 
egen iranklo_Aa =rank(itemA) if trt3==1, unique //from above
egen iranklo_Ab =rank(-itemA) if trt3==1, unique //from below
gen yupperA= `x'
replace yupperA=. if (trt3==1 & iranklo_Aa<=20) | (trt3==1 & attempts>3) //trim differences within 3 attempts and cut off all above 3-attempts
gen ylowerA= `x'
replace ylowerA=. if (trt3==1 & iranklo_Ab<=20) | (trt3==1 & attempts>3)
reg ylowerA  trt3, r
reg yupperA trt3, r
restore
		}
*

foreach x of varlist ushocks_exp_t1 {
preserve
display "`x'"
gen itemA= `x' if trt4==1 & attempts<=3 
egen iranklo_Aa =rank(itemA) if trt4==1, unique //from above
egen iranklo_Ab =rank(-itemA) if trt4==1, unique //from below
gen yupperA= `x'
replace yupperA=. if (trt4==1 & iranklo_Aa<=20) | (trt4==1 & attempts>3) //trim differences within 3 attempts and cut off all above 3-attempts
gen ylowerA= `x'
replace ylowerA=. if (trt4==1 & iranklo_Ab<=20) | (trt4==1 & attempts>3)
reg ylowerA  trt4, r
reg yupperA trt4, r
restore
		}
*/
*















