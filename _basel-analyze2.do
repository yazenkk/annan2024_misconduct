/*

*Title: balancing gender goals: evaluating the impacts of gender and competition on m-money
*0. In devpg ctrs: M-Money has the potential to lift people out of poverty, particularly women (Suri & Jack SC 2016)
* Women and minorities have higher rates of poverty than men...so maximizing m-money's impacts 
*A # of factors underlie these disparities; but one problem is perhaps the lack of gender balance/ diversity in vendorshop
**Facts #1: Vendors -- women hold large pop shares yet:
*descriptive evid that (rural financial) market disproportionately more male vendors: 60 vs 40
*Feature similar to finance in developed ctr settings, which are more male dominated 

**Facts #2: Customers -- descriptive evid of gender gaps in adoption or usage
**We don't cluster the SEs to reject the null (of no-diff) more often
**M-Money

[Simplify header and trim notes at the end]

Input: 
	- Mkt_fieldData_census
Output:
	- regressions
*/

use "$dta_loc_repl/01_intermediate/Mkt_fieldData_census", clear

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
 
areg cMMoneyregistered cfemale, absorb(ge02)
areg useEverWeek cfemale, absorb(ge02)
areg useTimesWeek cfemale, absorb(ge02) 
areg useVolWeek cfemale, absorb(ge02)

areg cMMoneyregistered c.cfemale##c.cmarried, absorb(ge02)
areg useEverWeek c.cfemale##c.cmarried, absorb(ge02)
areg useTimesWeek c.cfemale##c.cmarried, absorb(ge02) 
areg useVolWeek c.cfemale##c.cmarried, absorb(ge02)
**females customers sig less likely to use (extensive 4pp + intensive GHS100) yet similar account ownserhip of M-Money
**Could? may be driven by gender imbalance in vendorship (fewer female vendors), incl other factors
**competition in vendorship won't address this per se if gender is not balanced
**seeing more women vendors provides useful market info, promotes communication and then more trust-building (new tech)

**only-F vs only-M vs only-Mix
bys ge02: egen pct_female = mean(mfemale)
bys ge02: replace pct_female = pct_female*100

hist pct_female, disc
bys ge02: gen onlyMalev = (pct_female==0)
bys ge02: gen onlyFemalev = (pct_female==100)
bys ge02: gen onlyMix = (pct_female>0 & pct_female<100)

areg useVolWeek c.cfemale##c.cmarried, absorb(ge02)
areg useVolWeek c.cfemale##c.cmarried if onlyMalev==1, absorb(ge02)
areg useVolWeek c.cfemale##c.cmarried if onlyFemalev==1, absorb(ge02)
areg useVolWeek c.cfemale##c.cmarried if onlyMix==1, absorb(ge02)



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
