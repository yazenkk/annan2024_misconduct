/*
Customers data

Source: Commands_Test_f_evaluation_vendors.do
Input:
	- Customer
Output:
	- CustomersData
*/


use "$dta_loc_repl/00_raw/Customer.dta", clear

**Kwamena data - fix data quality issues
replace c1a1 = . if date_of_interview == 11052020
replace c1a2 = . if date_of_interview == 11052020
replace c1b1 = . if date_of_interview == 11052020
replace c1b2 = . if date_of_interview == 11052020
replace c3 = . if date_of_interview == 11052020
replace c2 = . if date_of_interview == 11052020
**or simply use line 27
**drop if date_of_interview == 10052020
*drop if date_of_interview == 11052020
**drop if date_of_interview == 14052020

**dishonesty?
replace c8b = 95 if date_of_interview == 26042020
replace c8a = 2 if date_of_interview == 26042020
*replace c8a = 2 if date_of_interview == 14052020 //new?

replace c8b = 100-c8b
replace c8a = 1 if c8b <10

clonevar c8ai = c8a
replace c8a=1 if c8ai==2
replace c8a=2 if c8ai==1
clonevar c4i = c4
replace c4=1 if c4i==2
replace c4=2 if c4i==1
drop c8ai c4i
saveold "$dta_loc_repl/00_raw/Customer_corrected.dta", replace
