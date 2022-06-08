set more off
global rootdir ~/GitHub/usa_trends_contingent_work/data_files/SIPP
global output $rootdir/rawdata/sipp96

cd $output

use sipp96l1.dta, clear

foreach i of num 1/12 {		
	use sipp96l`i'.dta, clear

	
	/* This code will drop the first three months of each wave, thus
	generating a SIPP dataset by person-wave, rather than by person-month. */
	sort id wave srefmon
	egen seam_ = max(srefmon), by(id wave)
	sort id wave
	quietly by id wave: gen byte seam = seam_==srefmon
	label var seam "last month of wave"
	drop seam_
	keep if seam==1
	
	keep if srefmon == 4
	
	rename tage age
	rename esex sex
	rename tfipsst state
	rename wpfinwgt weight /* person weight */

	*Employment
	rename rmesr esr /* employment status */
	rename epdjbthn paid_job /* paid job during reference period */
	rename emoonlit moonlit /* moonlighting - income from additional work */
	gen emp = 0 if esr>=1 & esr<=7
	replace emp = 1 if esr>=1 & esr<=5
	label var emp "Employed at least one week in a month"
	label define emp 1 "Employed at least one week in a month" 0 "In LF, not employed all month"

	gen temp_agency = 0 /* recode industry (ejbind), either first or second job */
	replace temp_agency = 1 if ejbind1 == 731 | ejbind2 == 731
	
	rename ecflag contingent /* LF: Flag indicating other-work-arrange */

	gen temp_work = 0
	replace temp_work = 1 if temp_agency == 1 | contingent == 1 | moonlit == 1

	*Education
	gen educ = 1 if eeducate<=38 & eeducate~=.
	replace educ = 2 if eeducate==39
	replace educ = 3 if eeducate>=40 & eeducate<=43
	replace educ = 4 if eeducate==44
	replace educ = 5 if eeducate>=45 & eeducate<=48
	drop eeducate
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

	keep id wave srefmon ssuid epppnum state age sex educ emp contingent temp_agency weight paid_job moonlit temp_work
	
	sort id wave srefmon
	save sipp96l`i'_small.dta, replace
}

* Append
set more off
use sipp96l1_small.dta, clear
foreach i of num 2/12 {		
	append using sipp96l`i'_small.dta
	sort id wave srefmon
}

* Merge in longitudinal panel weight
merge m:1 ssuid epppnum using sipp01lwt, keepusing(lgtpnlwt)
keep if _m == 3

egen pid = group(id)
drop id
rename pid id

order id wave srefmon

* Save
save sipp96_append.dta, replace

* Miscellaneous
use sipp96_append.dta, clear

keep if age >= 25 & age <= 54 
keep if emp != .

tabstat temp_work, by(wave)

bys id: gen count = _n
bys id: gen max = _N

keep if max == 12

tabstat temp_work, by(wave)

tabstat temp_agency, by(wave)

tab wave contingent

tab wave moonlit
