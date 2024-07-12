// same random numbers generated in different loop iterations 
// as long as uniform() step includes order within the main category
foreach i in 1 2 {
	clear
	set obs 5
	gen id = _n
	set seed 12345
	gen ge02 = uniform() < 0.5
	set seed 12345
	bys ge02: gen rand_num_`i' = uniform()
// 	bys ge02 (id): gen rand_num_`i' = uniform()
	sort ge02 id
	
	tempfile file`i'
	save	`file`i''
}
use `file1'
merge 1:1 id using `file2'
	sort ge02 id
// assert rand_num_1 == rand_num_2
