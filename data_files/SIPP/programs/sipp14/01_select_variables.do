clear
set maxvar 10000
set more off
global rootdir ~/GitHub/usa_trends_contingent_work/data_files/SIPP
global output $rootdir/rawdata/sipp14

cd $output

use pu2014w4_v13.dta, clear

foreach i of num 1/4 {		
	use pu2014w`i'_v13.dta, clear

	rename tage age
	rename esex sex
	rename tehc_st state
	rename wpfinwgt weight /* person weight */
	rename swave wave
	rename spanel panel

	/* This code will drop the first three months of each wave, thus
	generating a SIPP dataset by person-wave, rather than by person-month. */	
	rename monthcode srefmon
	keep if srefmon == 4 | srefmon == 8 | srefmon == 12

	*Employment
	rename rmesr esr /* employment status */
	rename ejb1_scrnr paid_job_1 /* paid job during reference period */
	rename ejb2_scrnr paid_job_2 /* paid job during reference period */
	*rename emoonlit moonlit /* moonlighting - income from additional work */
	gen emp = 0 if esr>=1 & esr<=7
	replace emp = 1 if esr>=1 & esr<=5
	label var emp "Employed at least one week in a month"
	label define emp 1 "Employed at least one week in a month" 0 "In LF, not employed all month"

	gen temp_agency = 0 /* recode industry (ejbind), either first or second job */
	replace temp_agency = 1 if tjb1_ind == "7580" | tjb2_ind == "7580" /* 7580 Employment services */
	
	rename ejb1_jborse emp_type_1
	rename ejb2_jborse emp_type_2
	rename ejb1_conchk contingent_1 /* LF: Flag indicating other-work-arrange */
	rename ejb2_conchk contingent_2 /* LF: Flag indicating other-work-arrange */

	gen temp_work = 0
	replace temp_work = 1 if temp_agency == 1 | (contingent_1 == 1 & emp_type_1 == 3) | (contingent_2 == 1 & emp_type_2 == 3)

	*Education
	gen educ = 1 if eeduc <=38 & eeduc~=.
	replace educ = 2 if eeduc==39
	replace educ = 3 if eeduc>=40 & eeduc<=43
	replace educ = 4 if eeduc==44
	replace educ = 5 if eeduc>=45 & eeduc<=48
	drop eeduc
	label define educ ///
	1 "less than high school" ///
	2 "high school grad" ///
	3 "some college" ///
	4 "college degree" ///
	5 "post-college"
	label values educ educ

	*Race/ethnicity
	rename erace race1
	rename eorigin ethnic
	gen race = 1 if race1==1 & (ethnic<20 | ethnic>28)
	replace race = 2 if race1==2 & (ethnic<20 | ethnic>28)
	replace race = 3 if (ethnic>=20 & ethnic<=28)
	replace race = 4 if race1>2 & (ethnic<20 | ethnic>28) & race1~=.

	label define race_cepr 1 "White" 2 "Black" 3 "Hispanic" 4 "Other"
	label values race race_cepr

	keep ssuid pnum wave srefmon state age sex educ emp contingent* temp_agency weight paid_job* temp_work emp_type*
	
	sort  ssuid wave srefmon
	save sipp14w`i'_small.dta, replace
}

* Append
set more off
use sipp14w1_small.dta, clear
foreach i of num 2/4 {		
	append using sipp14w`i'_small.dta
}

*	sort ssuid eentaid epppnum
egen id = group(ssuid pnum)

order id wave srefmon
bys id: replace wave = _n

* Save
save sipp14_append.dta, replace

* Miscellaneous
use sipp14_append.dta, clear

keep if age >= 25 & age <= 54 
keep if emp != .

tabstat temp_work, by(wave)

bys id: gen count = _n
bys id: gen max = _N
sum max
keep if max == `r(max)'

tabstat temp_work, by(wave)

