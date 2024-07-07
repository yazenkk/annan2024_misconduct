/*JPE2023-Annan
**y = Misconduct*

Outline:
	- Main results
	- Spillovers
	- Heterogeneity: Vendor Competition & Gender

Input:
	- FINAL AUDIT DATA/_Francis/analyzed_EndlineAuditData.dta
	- data-Mgt/Stats?/Mkt_census_xtics_+_interventions_localized.dta
	- data-Mgt/Stats?/adminTransactData
	- data-Mgt/Stats?/InterventionsLocalitiesList.dta
	
	- FINAL AUDIT DATA/_Francis/analyzed_EndlineAuditData.dta
	- data-Mgt/Stats?/pct_female_MktcensusStar
	- sampling?/Treatments_4gps_9dist
	
	- FINAL AUDIT DATA/_Francis/analyzed_EndlineAuditData.dta
	- FINAL AUDIT DATA/_Francis/mkt_aiVendorBetter.dta
	
Output:
	- data-Mgt/Stats?/InterventionsLocalitiesList.dta

*/
use "$dta_loc_repl/01_intermediate/analyzed_EndlineAuditData.dta", clear

/*
*(1) voxdev blogpost
bys trt: sum fd
quietly eststo Control: mean fd if trt==0
quietly eststo Treatment: mean fd if trt==1
coefplot Control Treatment, vertical xlabel("") xtitle(Misconduct indicator) ytitle(Mean) recast(bar) barwidth(0.25) fcolor(*.5) ciopts(recast(rcap)) citop citype(logit) level(95) graphregion(color(white)) ylab(,nogrid)
gr export /Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/_project/_xREPUTATION/slides/results/gr_misconduct.eps, replace
gr save /Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/_project/_xREPUTATION/slides/results/gr_misconduct, replace

gr combine ///
"/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/_project/_xREPUTATION/slides/results/gr_misconduct.gph" ///
"/Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/_project/_xREPUTATION/slides/results/gr_conduct_perceptions.gph"
gr export /Users/fannan/Dropbox/research_projs/fraud-monitors/_rGroup-finfraud/_project/_xREPUTATION/slides/results/gr_misconduct_plus_perceptions.eps, replace
*/


/*
adudropouts/ attrition?
bys xv_localityy xv_vendorr: keep if _merge==3 & _n==1 //129 out of 130 rep vendors reached: attrition of just 0.8%
tab treatment //ctr 31, pt 31, mr 32, joint 34< 35
*/


*ADD ff TO Balance Table  - AUDIT + SHOCK OUTCOMES
use "$dta_loc_repl/01_intermediate/Mkt_census_xtics_+_interventions_localized.dta", clear
gen ge01 = districtName
keep intervention  locality_name ge01
bys ge01 locality_name: keep if _n==1
saveold "$dta_loc_repl/01_intermediate/InterventionsLocalitiesList.dta", replace

use "$dta_loc_repl/01_intermediate/adminTransactData", clear
merge m:1 ge01 locality_name using "$dta_loc_repl/01_intermediate/InterventionsLocalitiesList.dta", generate(_merge_bal)
gen trt=0
replace trt=1 if intervention=="PriceTransparency, PT"
replace trt=2 if intervention=="MKtMonitoring, MM"
replace trt=3 if intervention=="joint: PT+MM"

egen strataFE = group(ge01)
*reg fYes_T strataFE i.trt  if _merge==3, cluster(ge02)
replace sv_fAmt_T =0 if fYes_T==0
reg sv_fAmt_T i.strataFE i.trt if _merge==3, cluster(ge02)

gen udeath_t0=(c6q1a==1) 
gen urevenue_t0=(c6q1b==1)
gen usickness_t0=(c6q1c==1)
gen uweather_t0=(c6q1d==1) 
gen uprices_t0=(c6q1e==1)
gen ushocks_t0=(c6q1f==1)
gen ushocks_exp_t0 = (udeath_t0==1 | urevenue_t0==1 | usickness_t0==1 | uweather_t0==1 | uprices_t0==1 | ushocks_t0==1)
*reg ushocks_exp_t0 strataFE i.trt if _merge==3, r



** Table 2 (? confirm) ---------------------------------------------------------------------
*Main Results: DIRECT EFFECTS*
gen ihs_fdamt = asinh(fdamt) //NOTE: fdamt recoded as 0 if fd=0 (if no overcharging occurs), so, no material diff b/n (ii) fdamt and (iii) ihs_fdamt
egen xbar = mean(trt)
egen ybar = mean(fdamt)
sum fd fdamt ihs_fdamt if trt==0 
sum fd fdamt ihs_fdamt if trt==0 & _merge==1

egen uniqueVendorID=group(ge01 ge02 ge03) //NOTE: uniqueVendorID = xv_locality, throughout

*y = trt + distXtrXdateFes + y_base + x_all6 + e*
reg fd i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt, r cluster(uniqueVendorID) level(95) //only rep vendors
reg fd i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt2 trt3 trt4, r cluster(uniqueVendorID) level(95) //only rep vendors
test _b[trt2]=_b[trt4]
test _b[trt3]=_b[trt4]
test _b[trt2]=_b[trt3]
test _b[trt2] + _b[trt3] =_b[trt4]

reg fdamt i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt, r cluster(uniqueVendorID) level(95) //only rep vendors
reg fdamt i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt2 trt3 trt4, r cluster(uniqueVendorID) level(95) //rep vendors
test _b[trt2]=_b[trt4]
test _b[trt3]=_b[trt4]
test _b[trt2]=_b[trt3]
test _b[trt2] + _b[trt3] =_b[trt4]

reg ihs_fdamt i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt, r cluster(uniqueVendorID) level(95) //only rep vendors
nlcom _b[trt]*xbar*((sqrt(ybar^2+1))/ybar)
**interpret, ihs: pos and signif => the implied elasticity=0.752
reg ihs_fdamt i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt2 trt3 trt4, r cluster(uniqueVendorID) level(95) //only rep vendors
test _b[trt2]=_b[trt4]
test _b[trt3]=_b[trt4]
test _b[trt2]=_b[trt3]
test _b[trt2] + _b[trt3] =_b[trt4]



** Table 7 (? confirm) ---------------------------------------------------------------------
*SPILLOVERS - untreated vendors: note: no baseline X-s here (we only tracked them at endline)
egen uniqueLocalityID=group(ge01 ge02) //NOTE: uniqueVendorID = xv_locality, throughout
sum fd fdamt ihs_fdamt if trt==0 & _merge==1
/*
*to get the same n=411, adjust the ff (or just leave n=405, yield similar results):
replace trt2=1 if missing(trt2) & trt==1
replace trt3=1 if missing(trt3) & trt==1
replace trt4=1 if missing(trt4) & trt==1
*/
reg fd i.distXtrXdateFes trt if _merge==1, r cluster(uniqueLocalityID) level(95) //spillover (non-rep vendors)
reg fd i.distXtrXdateFes trt2 trt3 trt4 if _merge==1, r cluster(uniqueLocalityID) level(95) //spillover (non-rep vendors)
test _b[trt2]=_b[trt4]
test _b[trt3]=_b[trt4]
test _b[trt2]=_b[trt3]
test _b[trt2] + _b[trt3] =_b[trt4]

reg fdamt i.distXtrXdateFes trt if _merge==1, r cluster(uniqueLocalityID) level(95) //spillover (non-rep vendors)
reg fdamt i.distXtrXdateFes trt2 trt3 trt4 if _merge==1, r cluster(xv_locality) level(95) //spillover (non-rep vendors)
test _b[trt2]=_b[trt4]
test _b[trt3]=_b[trt4]
test _b[trt2]=_b[trt3]
test _b[trt2] + _b[trt3] =_b[trt4]
	
/*
reg ihs_fdamt i.distXtrXdateFes trt if _merge==1, r cluster(uniqueLocalityID) level(95) 
nlcom _b[trt]*xbar*((sqrt(ybar^2+1))/ybar)
**interpret, ihs: pos and signif => the implied elasticity=0.709
leebounds ihs_fdamt trt, level(95) cieffect tight() 
reg ihs_fdamt i.distXtrXdateFes trt2 trt3 trt4 if _merge==1, r cluster(uniqueLocalityID) level(95)
test _b[trt2]=_b[trt4]
test _b[trt3]=_b[trt4]
test _b[trt2]=_b[trt3]
test _b[trt2] + _b[trt3] =_b[trt4]
*/





*Robustness checks [DIRECT EFFECTS] - Inference, Multiple Testing, Attrition, LASSO Estimation
*REPRESENTATIVE VENDOR
*POOLED
*wild cluster bootstrap, pval
reg fd i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt, r cluster(uniqueVendorID) level(95)
boottest trt, rep($bootstrap_reps) level(95) nogr
reg fdamt i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt, r cluster(uniqueVendorID) level(95)
boottest trt, rep($bootstrap_reps) level(95) nogr
reg ihs_fdamt i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt, r cluster(uniqueVendorID) level(95)
boottest trt, rep($bootstrap_reps) level(95) nogr
*randomization inf: permuntation test, pval
ritest trt _b[trt], reps($bootstrap_reps) cluster(uniqueVendorID) strata(districtID) seed(546): reg fd i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt
ritest trt _b[trt], reps($bootstrap_reps) cluster(uniqueVendorID) strata(districtID) seed(546): reg fdamt i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt
ritest trt _b[trt], reps($bootstrap_reps) cluster(uniqueVendorID) strata(districtID) seed(546): reg ihs_fdamt i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt
*mht: implement Romano-Wolf (2005) procedure, pval: *[allows for arbitrary dependence and corrects for familywise error rate (FWER) (see: Clarke, Romano, and Wolf (2020))]**
rwolf fd fdamt ihs_fdamt, indepvar(trt trt2 trt3 trt4) reps($bootstrap_reps) seed(124) controls(i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1) //family (misconduct: 0/1, amount)
*attrition bounds
leebounds fd trt, level(95) cieffect tight() 
leebounds fdamt trt, level(95) cieffect tight() 
leebounds ihs_fdamt trt, level(95) cieffect tight() 

*SEPARATE*
*wild cluster bootstrap, pval
reg fd i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt2 trt3 trt4, r cluster(uniqueVendorID) level(95)
boottest trt2, rep($bootstrap_reps) level(95) nogr
boottest trt3, rep($bootstrap_reps) level(95) nogr
boottest trt4, rep($bootstrap_reps) level(95) nogr
reg fdamt i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt2 trt3 trt4, r cluster(uniqueVendorID) level(95)
boottest trt2, rep($bootstrap_reps) level(95) nogr
boottest trt3, rep($bootstrap_reps) level(95) nogr
boottest trt4, rep($bootstrap_reps) level(95) nogr
reg ihs_fdamt i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt2 trt3 trt4, r cluster(uniqueVendorID) level(95)
boottest trt2, rep($bootstrap_reps) level(95) nogr
boottest trt3, rep($bootstrap_reps) level(95) nogr
boottest trt4, rep($bootstrap_reps) level(95) nogr
*randomization inf: permutation test, pval
ritest trt2 trt3 trt4 _b[trt2] _b[trt3] _b[trt4], reps($bootstrap_reps) cluster(uniqueVendorID) strata(districtID) seed(546): reg fd i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt2 trt3 trt4
ritest trt2 trt3 trt4 _b[trt2] _b[trt3] _b[trt4], reps($bootstrap_reps) cluster(uniqueVendorID) strata(districtID) seed(546): reg fdamt i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt2 trt3 trt4
ritest trt2 trt3 trt4 _b[trt2] _b[trt3] _b[trt4], reps($bootstrap_reps) cluster(uniqueVendorID) strata(districtID) seed(546): reg ihs_fdamt i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt2 trt3 trt4
*mht: implement Romano-Wolf (2005) procedure, pval
rwolf fd fdamt ihs_fdamt, indepvar(trt2 trt3 trt4) reps($bootstrap_reps) seed(124) controls(i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1) //family (misconduct: 0/1, amount)
*attrition bounds
leebounds fd trt2, level(95) cieffect tight() 
leebounds fd trt3, level(95) cieffect tight() 
leebounds fd trt4, level(95) cieffect tight() 

leebounds fdamt trt2, level(95) cieffect tight() 
leebounds fdamt trt3, level(95) cieffect tight() 
leebounds fdamt trt4, level(95) cieffect tight() 

leebounds ihs_fdamt trt2, level(95) cieffect tight() 
leebounds ihs_fdamt trt3, level(95) cieffect tight() 
leebounds ihs_fdamt trt4, level(95) cieffect tight() 





*Robustness checks [SPILLOVER EFFECTS] - Inference, Multiple Testing, Attrition, LASSO Estimation
*UNTREATED VENDORS
*preserve
*POOLED
keep if _merge==1
*wild cluster bootstrap, pval
reg fd i.distXtrXdateFes trt, r cluster(uniqueLocalityID) level(95)
boottest trt, rep($bootstrap_reps) level(95) nogr
reg fdamt i.distXtrXdateFes trt, r cluster(uniqueLocalityID) level(95)
boottest trt, rep($bootstrap_reps) level(95) nogr
*randomization inf: permutation test, pval
ritest trt _b[trt], reps($bootstrap_reps) cluster(uniqueLocalityID) strata(districtID) seed(546): reg fd i.distXtrXdateFes trt
ritest trt _b[trt], reps($bootstrap_reps) cluster(uniqueLocalityID) strata(districtID) seed(546): reg fdamt i.distXtrXdateFes trt
*mht: implement Romano-Wolf (2005) procedure, pval
rwolf fd fdamt ihs_fdamt, indepvar(trt trt2 trt3 trt4) reps($bootstrap_reps) seed(124) controls(i.distXtrXdateFes) //family (misconduct: 0/1, amount)
*attrition bounds-lee
leebounds fd trt, level(95) cieffect tight() 
leebounds fdamt trt, level(95) cieffect tight() 
*attrition bounds-Behajel et al: denote "all obs selected" or Not applicable here (no phone calls or repeat visits allowed)
*restore

*SEPARATE
keep if _merge==1
*wild cluster bootstrap, pval
reg fd i.distXtrXdateFes trt2 trt3 trt4, r cluster(uniqueLocalityID) level(95)
boottest trt2, rep($bootstrap_reps) level(95) nogr seed(15465)
boottest trt3, rep($bootstrap_reps) level(95) nogr seed(15465)
boottest trt4, rep($bootstrap_reps) level(95) nogr seed(15465)
reg fdamt i.distXtrXdateFes trt2 trt3 trt4, r cluster(uniqueLocalityID) level(95)
boottest trt2, rep($bootstrap_reps) level(95) nogr seed(15465)
boottest trt3, rep($bootstrap_reps) level(95) nogr seed(15465)
boottest trt4, rep($bootstrap_reps) level(95) nogr seed(15465)
*randomization inf: permutation test, pval
ritest trt2 trt3 trt4 _b[trt2] _b[trt3] _b[trt4], reps($bootstrap_reps) cluster(uniqueLocalityID) strata(districtID) seed(546): reg fd i.distXtrXdateFes trt2 trt3 trt4
ritest trt2 trt3 trt4 _b[trt2] _b[trt3] _b[trt4], reps($bootstrap_reps) cluster(uniqueLocalityID) strata(districtID) seed(546): reg fdamt i.distXtrXdateFes trt2 trt3 trt4
*mht: implement Romano-Wolf (2005) procedure, pval
rwolf fd fdamt ihs_fdamt, indepvar(trt trt2 trt3 trt4) reps($bootstrap_reps) seed(124) controls(i.distXtrXdateFes) //family (misconduct: 0/1, amount)

*attrition bounds-lee
**1. [Lee Bounds]**
foreach x of varlist trt2 trt3 trt4 {
	leebounds fd `x', level(95) cieffect tight() 
}
*
foreach x of varlist trt2 trt3 trt4 {
	leebounds fdamt `x', level(95) cieffect tight() 
}
*
**2. [Behajel et al. Bounds]**
*denote as "all obs selected" or Not applicable here (no phone calls or repeat visits allowed)




** (1) Heterogeneity: Vendor Competition & Gender
*Result: much effects on programs in more competitive local markets (as measure by -HHI)
use "$dta_loc_repl/01_intermediate/analyzed_EndlineAuditData.dta", clear
egen uniqueVendorID=group(ge01 ge02 ge03) //NOTE: uniqueVendorID = xv_locality, throughout

drop _merge
merge m:m ge01 ge02 ge03 using "$dta_loc_repl/01_intermediate/pct_female_MktcensusStar"
**NOTE: loccodee = correct, loccode=incorrect
*br loccodex loccode loccodee
drop _merge
*districtName localityName localityCode
gen double localityCode_j = loccodee 
merge m:m localityCode_j using "$dta_loc_repl/01_intermediate/Treatments_4gps_9dist"

*COMPETITION
*br loccodee localityCode_j loccode
gen comp=-HH
gen high_comp=(comp>=0.50)
gen e_comp=MktPerLocal/populationTotal
sum e_comp, d
gen high_e_comp=e_comp>=.0008718
pwcorr e_comp comp MktPerLocal, sig
sum HHI comp, d

**trim to minimize extreme influences**
reg fd i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt comp c.trt#c.comp if HHI<1 & HHI>0, r cluster(uniqueVendorID) level(95) // simple interaction
reg fdamt i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt comp c.trt#c.comp if HHI<1 & HHI>0, r cluster(uniqueVendorID) level(95) // simple interaction

reg fd i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt2 trt3 trt4 comp c.trt2#c.comp c.trt3#c.comp c.trt4#c.comp if HHI<1 & HHI>0, r cluster(uniqueVendorID) level(95) // interaction
reg fdamt i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt2 trt3 trt4 comp c.trt2#c.comp c.trt3#c.comp c.trt4#c.comp if HHI<1 & HHI>0, r cluster(uniqueVendorID) level(95) // interaction


**GENDER
reg fd i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 c.trt vfemale c.vfemale#c.trt, r cluster(xv_locality) level(95)
reg fdamt i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 c.trt vfemale c.vfemale#c.trt, r cluster(xv_locality) level(95)

reg fd i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt2 trt3 trt4 vfemale c.trt2#c.vfemale c.trt3#c.vfemale c.trt4#c.vfemale, r cluster(xv_locality) level(95)
reg fdamt i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt2 trt3 trt4 vfemale c.trt2#c.vfemale c.trt3#c.vfemale c.trt4#c.vfemale, r cluster(xv_locality) level(95)




** (2) Heterogeneity: Illiteracy + Bundled stores
use "$dta_loc_repl/01_intermediate/analyzed_EndlineAuditData.dta", clear
drop _merge
merge m:m ge02 using "$dta_loc_repl/01_intermediate/mkt_aiVendorBetter.dta"
keep if _merge==3

gen bundle=(m3q1==2) if !missing(m3q1) //bundle shops
gen bundlek=(ffaq13==1) if !missing(ffaq13)
gen vIncorrects = (m_corrects==0) //illiterate vendors
gen cIncorrects = (c_corrects==0) //illiterate vendors
gen vIncorrectsxFemale= (m_corrects==0 & mfemale==1) //illiterate female vendors
gen busInexperience = (m2q1b<12) //inexperienced vendors

*note: doesnt matter sv_fAmt_T / fYes_T
gen mkt_c_corrects2No=1-mkt_c_corrects2
gen mkt_c_fracAnyEducNo=1-mkt_c_fracAnyEduc
pwcorr mkt_c_fracprimandlesssEduc mkt_c_fracAnyEducNo mkt_c_corrects2No,sig //positively corrected: incorrectness & less/no formal educ

gen sv_fAmt_T0 = sv_fAmt_T
replace sv_fAmt_T0=0 if fYes_T==0

** Table C.13 ------------------------------------------------------------------
*CUSTOMERS - base Illiteracy effects
reg fd i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt  c.trt#c.mkt_c_fracAnyEducNo mkt_c_fracAnyEducNo, r cluster(xv_locality) level(95)
reg fdamt i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt c.trt#c.mkt_c_fracAnyEducNo mkt_c_fracAnyEducNo, r cluster(xv_locality) level(95)

reg fd i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt2  c.trt2#c.mkt_c_fracAnyEducNo trt3 c.trt3#c.mkt_c_fracAnyEducNo trt4 c.trt4#c.mkt_c_fracAnyEducNo mkt_c_fracAnyEducNo, r cluster(xv_locality) level(95)
reg fdamt i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a i.m3q1 trt2 c.trt2#c.mkt_c_fracAnyEducNo trt3 c.trt3#c.mkt_c_fracAnyEducNo trt4 c.trt4#c.mkt_c_fracAnyEducNo mkt_c_fracAnyEducNo, r cluster(xv_locality) level(95)


*VENDORS - base bundling effects
reg fd i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a trt c.trt#c.bundle bundle, r cluster(xv_locality) level(95)
reg fdamt i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a trt c.trt#c.bundle bundle, r cluster(xv_locality) level(95)

reg fd i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a trt2 c.trt2#c.bundle trt3 c.trt3#c.bundle trt4 c.trt4#c.bundle bundle, r cluster(xv_locality) level(95)
reg fdamt i.distXtrXdateFes fYes_T mage mmarried makan mselfemployed m2q1a  trt2 c.trt2#c.bundle trt3 c.trt3#c.bundle trt4 c.trt4#c.bundle bundle, r cluster(xv_locality) level(95)























