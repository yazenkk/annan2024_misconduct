


** Mkt_fieldData_census --------------------------------------------------------

local path "/Users/yazenkashlan/Library/CloudStorage/OneDrive-Personal/Documents/personal/Berk/03_Work/Francis/Replication"
use "`path'/data/01_intermediate/Mkt_fieldData_census.dta", clear
gen customer_id = custcode
order distcode loccode vendor customer_id
count if !mi(loccode) & !mi(vendor_id) & !mi(customer_id) // 1998
sum loccode vendor_id customer_id // 2054, 2054, 1998

// cf _all using "`path'/data_test/01_intermediate/Mkt_fieldData_census.dta", verbose

use "`path'/data_test/01_intermediate/Mkt_fieldData_census.dta", clear
count if !mi(ge01) & !mi(ge02) & !mi(ge04) // 1998
sum ge01 ge02 ge04 // 2052, 2052, 1998

// looks ok 1998 matches in both
// Just two extra locations in original (without customers)




** interventionsTomake_list_local ----------------------------------------------
local path "/Users/yazenkashlan/Library/CloudStorage/OneDrive-Personal/Documents/personal/Berk/03_Work/Francis/Replication"
use "`path'/data/01_intermediate/interventionsTomake_list_local.dta", clear
count if !mi(loccode) & !mi(vendor_id) & !mi(customer_id) // 990
sum loccode vendor_id customer_id // 990

// cf _all using "`path'/data_test/01_intermediate/Mkt_fieldData_census.dta", verbose

use "`path'/data_test/01_intermediate/interventionsTomake_list_local.dta", clear
count if !mi(ge01) & !mi(ge02) & !mi(ge04) // 1033
sum ge01 ge02 ge04 customer_id // 1033

// Not a good match. Why? Check upstream steps




** CustomersData ---------------------------------------------------------------
local path "/Users/yazenkashlan/Library/CloudStorage/OneDrive-Personal/Documents/personal/Berk/03_Work/Francis/Replication"
use "`path'/data/01_intermediate/CustomersData.dta", clear
count if !mi(customer2020_id) & !mi(clocality_name) & !mi(cdistrict_code) // 810
sum customer2020_id clocality_name cdistrict_code // 810

// cf _all using "`path'/data_test/01_intermediate/Mkt_fieldData_census.dta", verbose

use "`path'/data_test/00_raw_anon/Customer_corrected.dta", clear
count if !mi(ge01) & !mi(ge02) & !mi(ge04) // 810
sum ge01 ge02 ge04 customer_id // 810

// looks ok



** ONLY_4TrtGroups_9dist -------------------------------------------------------
local path "/Users/yazenkashlan/Library/CloudStorage/OneDrive-Personal/Documents/personal/Berk/03_Work/Francis/Replication"
use "`path'/data/01_intermediate/ONLY_4TrtGroups_9dist.dta", clear
count if !mi(districtID) & !mi(loccode) & !mi(vendor_id) & !mi(treatment) // 130
sum districtID loccode vendor_id treatment // 810

// cf _all using "`path'/data_test/01_intermediate/Mkt_fieldData_census.dta", verbose

use "`path'/data_test/01_intermediate/ONLY_4TrtGroups_9dist.dta", clear
count if !mi(ge01) & !mi(ge02) & !mi(ge03) & !mi(treatment) // 134
sum ge01 ge02 ge03 treatment // 134

// Oops the randomization is different.




** repMkt -------------------------------------------------------
local path "/Users/yazenkashlan/Library/CloudStorage/OneDrive-Personal/Documents/personal/Berk/03_Work/Francis/Replication"
use "`path'/data/01_intermediate/repMkt.dta", clear
count if !mi(loccode) & !mi(vendor_id) // 332
sum loccode vendor_id // 332

// cf _all using "`path'/data_test/01_intermediate/Mkt_fieldData_census.dta", verbose

use "`path'/data_test/01_intermediate/repMkt.dta", clear
count if !mi(ge02) & !mi(ge03) // 336
sum ge02 ge03 // 336

// yupp. the problem distorting the randomizatio is all the way back here.


