


** Mkt_fieldData_census --------------------------------------------------------

local path "/Users/yazenkashlan/Library/CloudStorage/OneDrive-Personal/Documents/personal/Berk/03_Work/Francis/Replication"
use "`path'/data/01_intermediate/Mkt_fieldData_census.dta", clear
gen customer_id = custcode
count if !mi(loccode) & !mi(vendor_id) & !mi(customer_id)
sum loccode vendor_id customer_id // 2054, 2054, 1998

// cf _all using "`path'/data_test/01_intermediate/Mkt_fieldData_census.dta", verbose

use "`path'/data_test/01_intermediate/Mkt_fieldData_census.dta", clear
count if !mi(ge01) & !mi(ge02) & !mi(ge04)
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

// looks ok 1998 matches in both
// Just two extra locations in original (without customers)







