
capture log close
macro drop _all
setdate
setdirectory

log using "Logs/6-construct-measures_${date}", replace text
********************************************************************************
*construct-measures_$date: constructs measures used in analysis
*Victoria Sosina (vsosina@stanford.edu)
di "Date: $date"
********************************************************************************
/*Handle missings, zeros, negatives; generate measures of interest; identify 
outliers; restrict sample; construct analytical measures. */
********************************************************************************

version 13
set linesize 82
set more off, perm

********************************************************************************
*OPEN FILE
********************************************************************************

use "Derived/5-merge_${date}.dta", clear

********************************************************************************
*REPLACE ZEROS AND NEGATIVES WITH MISSING
********************************************************************************
			
	*string variables
	ds, has(type string)
	local strings "`r(varlist)'"
	*numeric variables
	
	unab all: _all
	local numeric: list all - strings
	
	*check to see that any values are negative for the numeric variables
	foreach v of local numeric{
		qui count if `v' < 0 
		if r(N)>0{
			di as error "`v' is negative" _col(30) "`r(N)' values"
		}
		
		replace `v' = . if `v' < 0
	}
	/*if there are negative variables, it will display as error and replace
	negative values with missing */
	
	*check to see if string variables take on nonsensical characters 
	foreach v of local strings {
		qui count if `v'=="." |`v'=="00" |`v'=="M"|`v'=="N"
		if r(N)>0{
			di as error "`v' is ., 00, M, or N"
			exit 198
		}
	}
	/*if variables take on any of the listed characters, it will throw an 
	error and stop*/

********************************************************************************
*CORRECT REVENUE TOTALS
********************************************************************************
gen double REV_TOTALREV = rev_tfedrev + rev_tstrev + rev_tlocrev 

gen double RATIO_totalrev 	= rev_totalrev / REV_TOTALREV

label variable RATIO_totalrev 	"ratio of reported to generated total revenue"

su RATIO*

********************************************************************************
*CORRECT EXPENDITURES TOTALS
********************************************************************************
/*If the subcategories add up to within 5 to 10 percent of the total reported, 
then we will probably be fine using the raw data. If they are way off, try to 
scale to add up to the total First, scale the subcategories to equal the total 
reported, then scale the sub-subcategories to equal the subcategories. Worst 
case scenario - drop districts where the sums don't look great. Do districts 
have missing on revenue but not expenditures? And vice versa? */

gen double EXP_TOTEXP = rut_tcurelsc + rut_tnonelse + rut_tcapout + rut_l12 + ///
				 rut_m12 + rut_q11 + rut_i86 
/*though the NCES F33 documentation says that v91 and v92 are added in here, 
the Census F33 documentation does not include those items here. Since the 
Rutgers team got the F33 data from the Census, they must not be included in 
total expenditures. the items are listedn under the tcurinst heading, but do 
not appear to be summed to calculate tcurinst. (see "Documentation\Census F33\
2013-data-item-flags.pdf", p. 7. m12 not included in FY2002 (see "Documentation\
Census F33\school02doc.pdf", p. 7)*/

gen double RUT_TCURELSC = exp_tcurinst + rut_tcurssvc + rut_tcuroth

gen double RUT_TNONELSE = rut_v70 + rut_v75 + rut_v80 + rut_j98
replace RUT_TNONELSE = rut_v70 + rut_v75 + rut_v80 if year <= 1999
/*The Census F33 documentation includes J98 in NONELSEC while the NCES F33
documentation does not. See p. A-4 of "Documentation\NCES F33\
Documentation_F33_2013.pdf" and p. 8 of "Documentation\Census F33\
2013-data-item-flags.pdf"*/
//j98 missing in 1999

gen double RUT_TCAPOUT = rut_f12 + rut_g15 + rut_k09 + rut_k10 + rut_k11 + rut_j99
replace  RUT_TCAPOUT = rut_f12 + rut_g15 + rut_k09 + rut_k10 + rut_k11 ///
	if year <= 1999
/*The Census F33 documentation includes J99 in TCAPOUT while the NCES F33
documentation does not. See p. A-5 of "Documentation\NCES F33\
Documentation_F33_2013.pdf" and p. 8 of "Documentation\Census F33\
2013-data-item-flags.pdf"*/
//j99 missing in 1999

gen double EXP_TCURINST = rut_e13 + rut_j13 + rut_j12 + rut_j14
replace EXP_TCURINST = rut_e13 + rut_j13 + rut_j12 if year <= 1999
/*The Census F33 documentation includes J13, J12, and J14 in TCURINST while the 
NCES F33 documentation does not. See p. A-4 of "Documentation\NCES F33\
Documentation_F33_2013.pdf" and p. 7 of "Documentation\Census F33\
2013-data-item-flags.pdf"*/
//j14 missing in 1999

gen double RUT_TCURSSVC = exp_pupsup + rut_e07 + exp_genadmin + exp_schadmin + ///
					exp_opmain + rut_v45 + rut_v90 + rut_v85 + ///
					rut_j17 + rut_j07 + rut_j08 + rut_j09 + ///
					rut_j40 + rut_j45 + rut_j90 + rut_j11 + rut_j96
					
replace RUT_TCURSSVC = RUT_TCURSSVC + rut_j85 if year <= 2003

replace RUT_TCURSSVC = 	exp_pupsup + rut_e07 + exp_genadmin + exp_schadmin + ///
					exp_opmain + rut_v45 + rut_v90 + rut_v85 + ///
					rut_j17 + rut_j07 + rut_j08 + rut_j09 + ///
					rut_j40 + rut_j45 + rut_j90 + ///
					rut_j85 if year <= 1999
					
/*The Census F33 documentation includes J17, J07, J08, J09, J40, J45, J90, J11, ///
J96 in TCURSSV while the NCES F33 documentation does not. See p. A-4 of 
"Documentation\NCES F33\Documentation_F33_2013.pdf" and p. 7 of 
"Documentation\Census F33\2013-data-item-flags.pdf", J85 is included prior to 
2004 (see p. 8 of "Documentation\Census F33\survey-documentation-2003.pdf" */
//j11 & j96 missing in 1999
					
gen double RUT_TCUROTH = rut_e11 + rut_v60 + rut_v65 + rut_j10 + rut_j97
replace RUT_TCUROTH = rut_e11 + rut_v60 + rut_v65 + rut_j10 if year <= 1999

/*The Census F33 documentation includes J10 and J97 TCUROTH while the NCES F33 
documentation does not. See p. A-4 of "Documentation\NCES F33\
Documentation_F33_2013.pdf" and p. 8 of "Documentation\Census F33\
2013-data-item-flags.pdf"*/
//j97 missing in 1999


gen RATIO_totexp 	= exp_totexp 	/ EXP_TOTEXP
gen RATIO_tcurelsc 	= rut_tcurelsc 	/ RUT_TCURELSC
gen RATIO_tnonelse 	= rut_tnonelse 	/ RUT_TNONELSE
gen RATIO_tcapout 	= rut_tcapout 	/ RUT_TCAPOUT
gen RATIO_tcurinst 	= exp_tcurinst 	/ EXP_TCURINST
gen RATIO_tcurssvc 	= rut_tcurssvc	/ RUT_TCURSSVC
gen RATIO_tcuroth 	= rut_tcuroth 	/ RUT_TCUROTH

label variable RATIO_totexp 	"ratio of reported to generated total expenditures"
label variable RATIO_tcurelsc 	"ratio of reported to generated total current elementary/secondary expenditures"
label variable RATIO_tnonelse 	"ratio of reported to generated total non-elementary/secondary expenditures"
label variable RATIO_tcapout 	"ratio of reported to generated total capitaly outlay expenditures"
label variable RATIO_tcurinst 	"ratio of reported to generated total current expenditures - instruction"
label variable RATIO_tcurssvc 	"ratio of reported to generated total current expenditures - support services"
label variable RATIO_tcuroth 	"ratio of reported to generated total current expenditures - other elementary/secondary"

	*indicator for observations in 15yr sample 
	/*not quite the same as the sample restriction, but close - some of the 
	indicators for the sample restriction have not been created yet*/
	gen sample15yr = 1
	replace sample15yr = 0 if year < 1999 | year > 2013

	foreach v in drop_notstate drop_noop drop_vocspec drop_esa drop_jj ///
		drop_charter {
		
		replace sample15yr = 0 if `v'==1
	}

	replace sample15yr = 0 if Drop==1
	
*replace 2 erroneous observations
count if exp_totexp != EXP_TOTEXP & sample15yr == 1
if `r(N)'>2{
	di as error "exp_totexp ! = sum of subcategories for more than 2 cases - must explore"
	exit 198	
}

replace exp_totexp = EXP_TOTEXP if exp_totexp != EXP_TOTEXP & sample15yr == 1
replace RATIO_totexp = exp_totexp / EXP_TOTEXP

*summarize ratios
su RATIO* if sample15yr == 1
********************************************************************************
*GENERATE SHARE SPECED, ELL
********************************************************************************
/*Percent special education and ELL already exist in the Rutgers data. This 
section identifies errors & outliers. Errors are values over 1 for percent 
speced or percent ell. A district is defined as an outlier if (1) the percent ell 
or speced divided by the district standard deviation is < .5 * the 5th percentile
or > 1.5 * 95th percentile of the standardized % ell or speced in the district;
or (2) if the district SD divided by the district M is greater than 1.5 * 95th 
percentile of the coefficient of variation across all districts. */

*replace errors as missing
replace rut_perspeced = .e if rut_perspeced > 1 & !missing(rut_perspeced)
replace rut_perell = .e if rut_perell > 1 & !missing(rut_perell)

*identifying unreasonable year-to-year changes - speced*************************

	*sd and mean across districts
	egen SD = sd(rut_perspeced), by(leaid)
	egen M = mean(rut_perspeced), by(leaid)
	
	*standardized speced
	gen rut_perspeced_std = rut_perspeced/SD
	
	*5th and 95th percentiles of standardized speced
	egen p5 =  pctile(rut_perspeced_std), p(5) by(leaid)
	egen p95 =  pctile(rut_perspeced_std), p(95) by(leaid)

	*how many years does each district have non-missing values?
	egen N_rut_perspeced = count(rut_perspeced), by(leaid)
	label variable N_rut_perspeced "years of non-missing special education data"
	
	*outliers are  <.5 of 5th or > 1.5 of 95th pctile of standardized value
	gen rut_perspecedO = (rut_perspeced_std < .5 * p5 | 	///
						  rut_perspeced_std > 1.5 * p95) & 	///
						 !missing(rut_perspeced_std) 
						 
	egen N_rut_perspecedO = total(rut_perspecedO), by(leaid)
	
	*generate the coefficient of variation
	gen coefvar = SD/M
	
	*outliers are those with large coefficients of variation
	su coefvar, d
	replace rut_perspecedO = 1 if (coefvar > 1.5 * r(p95)) & ///
								  N_rut_perspecedO == 0 & !missing(coefvar)

	*cannot be an outlier if observed in only one year
	replace rut_perspecedO = 0 if N_rut_perspeced == 1
	
	replace rut_perspecedO = . if missing(rut_perspeced)
	label variable rut_perspecedO "district is an outlier for special education data"

	*number of years district is an outlier
	drop N_rut_perspecedO 
	egen N_rut_perspecedO = total(rut_perspecedO), by(leaid)
	label variable N_rut_perspeced "N years district is an outlier for special education data"
	
	*percent of non-missing years district is an outlier
	gen P_rut_perspecedO = N_rut_perspecedO / N_rut_perspeced
	label variable P_rut_perspecedO "% years district is an outlier for special education data"
	
	*indicator for whether a district was ever an outlier
	egen everO = total(rut_perspecedO), by(leaid)
	recode everO (0 = 0) (nonmissing = 1)
	replace everO = . if N_rut_perspeced == 0
	
	*get random sample of outliers for plotting
	preserve
		*keep districts that were an outlier at least once
		keep if everO == 1
		contract leaid
		drop _freq
		
		*assign each district a random number
		//set seed 303090 	// --> set seed for reproducibility
		egen id = group(leaid)
		qui su id
		gen u = runiformint(1,`r(max)')
		drop id 
		
		sort u 
		replace u = _n
		
		*save to merge onto main dataset
		tempfile t
		save `t', replace
	restore
	
	*merge on random district id
	merge m:1 leaid using `t', nogenerate
	
	*get leaids for 10 random districts
	levelsof leaid, local(leaid), if u >=1 & u <= 10
	
	*make a plot for 10 random districts
	local i = 0
	foreach l of local leaid{
		levelsof rut_name_ccdlea, local(name), if leaid=="`l'" & year == 2013
		local i = `i' + 1
				
		twoway  ///
		(scatter rut_perspeced year if rut_perspecedO==0 & leaid=="`l'") || ///
		(scatter rut_perspeced year if rut_perspecedO==1 & leaid=="`l'"), ///
		title(`name' "(`l')", size(small)) ///
		xlab(1992(2) 2015, angle(45) labsize(small)) xscale(range(1992 2015))  ///
		ylab(#10, angle(hori)) ///
		legend(order(1 "not an outlier" 2 "outlier")) ///
		name("check_speced_outliers_`l'", replace)
		
		graph save "Results/check_speced_outliers_`i'", replace
	}
		
	*drop intermediate variables
	drop SD M p5 p95 coefvar rut_perspeced_std everO u

	*create indicator for robustness checks
	gen Check_specedout = rut_perspecedO
	label variable Check_specedout "robustness check indicator - ouliers for special education"
	
*identifying unreasonable year-to-year changes - ell****************************

	*sd and mean across districts
	egen SD = sd(rut_perell), by(leaid)
	egen M = mean(rut_perell), by(leaid)

	*standardized ell
	gen rut_perell_std = rut_perell/SD
	
	*5th and 95th percentiles of standardized ell
	egen p5 =  pctile(rut_perell_std), p(5) by(leaid)
	egen p95 =  pctile(rut_perell_std), p(95) by(leaid)

	*how many years does each district have non-missing values?
	egen N_rut_perell = count(rut_perell), by(leaid)
	label variable N_rut_perell "years of non-missing ell data"
	
	*outliers are  <.5 of 5th or > 1.5 of 95th pctile of standardized value
	gen rut_perellO = (rut_perell_std < .5 * p5 | rut_perell_std > 1.5 * p95) & ///
						 !missing(rut_perell_std) 
	egen N_rut_perellO = total(rut_perellO), by(leaid)
	
	*generate the coefficient of variation
	gen coefvar = SD/M
	
	*outliers are those with large coefficients of variation
	su coefvar, d
	replace rut_perellO = 1 if (coefvar > 1.5 * r(p95)) & ///
								  N_rut_perellO == 0 & !missing(coefvar)

	*cannot be an outlier if observed in only one year
	replace rut_perellO = 0 if N_rut_perell == 1
	
	replace rut_perellO = . if missing(rut_perell)
	label variable rut_perellO "district is an outlier for ell data"

	*number of years district is an outlier
	drop N_rut_perellO 
	egen N_rut_perellO = total(rut_perellO), by(leaid)
	label variable N_rut_perell "N years district is an outlier for ell data"
	
	*percent of non-missing years district is an outlier
	gen P_rut_perellO = N_rut_perellO / N_rut_perell
	label variable P_rut_perellO "% years district is an outlier for ell data"
	
	*indicator for whether a district was ever an outlier
	egen everO = total(rut_perellO), by(leaid)
	recode everO (0 = 0) (nonmissing = 1)
	replace everO = . if N_rut_perell == 0
	
	*get random sample of outliers for plotting
	preserve
		*keep districts that were an outlier at least once
		keep if !missing(everO) & N_rut_perell > 1 & !missing(N_rut_perell)
		contract leaid
		drop _freq
		
		*assign each district a random number
		//set seed 303090 	// --> set seed for reproducibility
		egen id = group(leaid)
		qui su id
		gen u = runiformint(1,`r(max)')
		drop id 
		
		sort u 
		replace u = _n
		
		*save to merge onto main dataset
		tempfile t
		save `t', replace
	restore
	
	*merge on random district id
	merge m:1 leaid using `t', nogenerate
	
	*get leaids for 10 random districts
	levelsof leaid, local(leaid), if u >=1 & u <= 10
	
	*make a plot for 10 random districts
	local i = 0 
	foreach l of local leaid{
		levelsof rut_name_ccdlea, local(name), if leaid=="`l'" & year == 2013
		qui su rut_perell if leaid=="`l'"
		local i = `i' + 1
		
		twoway  ///
		(scatter rut_perell year if rut_perellO==0 & leaid=="`l'") || ///
		(scatter rut_perell year if rut_perellO==1 & leaid=="`l'"), ///
		title(`name' "(`l')", size(small)) ///
		xlab(1999(2) 2015, angle(45) labsize(small)) xscale(range(1999 2015))  ///
		ylab(#10, angle(hori))  yscale(range(0 `r(max)')) ///
		legend(order(1 "not an outlier" 2 "outlier")) ///
		name("check_ell_outliers_`l'", replace)
		
		graph save "Results/check_ell_outliers_`i'", replace
	}
		
	*drop intermediate variables
	drop SD M p5 p95 coefvar rut_perell_std everO u

	*create indicator for robustness checks
	gen Check_ellout = rut_perellO
	label variable Check_ellout "robustness check indicator - ouliers for ell"
	
	 window manage close graph _all
	
********************************************************************************
*GENERATE EXPENDITURE MEASURES
********************************************************************************
	*Instructional expenditures
	gen double exp_instr = exp_tcurinst + rut_e07 + rut_j07
	//current spending for instruction + instructional staff support + 
	// instructional staff support benefits
	
	*Administration expenditures
	gen double exp_admin = exp_genadmin + exp_schadmin + rut_v90 + rut_j90 + ///
		rut_j08 + rut_j09
	//gen admin, sch admin, business/central/other, state payments bus/cent/oth 
	// gen admin benefits, school admin benefits
	
	*Social support services
	gen double exp_social = exp_pupsup + rut_tnonelse + rut_j17
	//pupil support services, non-elementary/secondary services, pup sup benefits
	
	*Infrastructure
	gen double exp_infra = exp_opmain + rut_v45 + rut_tcapout + rut_j40 + rut_j45
	//operation & maintenance, transportation, capital outlay, op & main benefits,
	// transportation benefits
	
	*Other expenditures
	gen double exp_other = rut_tcuroth + rut_v85 + rut_l12 + rut_m12 + ///
		rut_q11 + rut_i86 + rut_j11 + rut_j96 
	
	replace exp_other = exp_other + rut_j85 if year <= 2003
	replace exp_other = rut_tcuroth + rut_v85 + rut_l12 + rut_m12 + ///
		rut_q11 + rut_i86 + rut_j85 if year <= 1999
	//total current expenditures - other elementary/secondary, non-specified 
	// support, food service, enterprise, other elem-sec, other state payments,
	// state payments for non-instruction non-benefits, payments to state gov,
	// payments to local gov, payments to other school systems, interest on debt
	
	//state payments for non-specified, retirement transfer for support 
	// services, state payments for non-benefits support services included in 
	// limited years
	
	gen double TOT = exp_instr + exp_admin + exp_social + exp_infra + exp_other
	gen R = TOT/exp_totexp 
	
	su R if sample15yr==1
	
	if r(min)!=1 | r(max)!=1{
		di as error "The categories do not add up to the total. This needs to be fixed"
		exit 198
	}	
	
	*drop intermediate variables
	drop TOT
	drop R
	
	*drop expenditure subcategories to avoid confusion
	drop exp_tcurinst rut_e07 rut_j07 exp_genadmin exp_schadmin rut_v90 rut_j90  ///
	 rut_j08 rut_j09 exp_pupsup rut_tnonelse rut_j17 exp_opmain rut_v45 ///
	 rut_tcapout rut_j40 rut_j45 rut_tcuroth rut_v85 rut_l12 rut_m12 rut_q11 ///
	 rut_i86 rut_j11 rut_j96 rut_j85
	 
	drop rut_e13 rut_j13 rut_j12 rut_tcurssvc rut_e11 rut_v60 rut_v65 rut_v70 ///
		rut_v75 rut_v80 rut_j10 rut_f12 rut_k09 rut_k10 rut_k11 rut_g15 ///
		rut_tcurelsc rut_v91 rut_v92 rut_j14 rut_j97 rut_j98 rut_j99
	
	*label variables
	label variable exp_instr	"instructional"
	label variable exp_admin	"administration"
	label variable exp_social	"social support services"
	label variable exp_infra	"infrastructure"
	label variable exp_other	"remaining expenses"
********************************************************************************
*GENERATE PPE ITEMS
********************************************************************************

foreach v of var rev_* exp_* {
	*generate
	gen double pp`v'1 = `v'/imp_member 
	gen double pp`v'2 = `v'/rut_member
	
	*label
	local lab: variable label `v'
	
	label variable pp`v'1 "Per pupil `lab' (imp_member)"
	label variable pp`v'2 "Per pupil `lab' (rut_member)"
}


********************************************************************************
*GENERATE PER FTE ITEMS
********************************************************************************

foreach v of var rev_* exp_* {
	*generate
	gen double pfte`v' = `v'/rut_tottch_ccdlea 
	
	*label
	local lab: variable label `v'
	
	label variable pfte`v' "Per FTE `lab' (rut_tottch_ccdlea)"
}

********************************************************************************
*STUDENT TEACHER RATIO
********************************************************************************
local Lab "Students per teacher (imp_member/rut_tottch_ccdlea)"

*version with all observations
gen stud_teach = imp_member / rut_tottch_ccdlea 
label variable stud_teach "`Lab'"

*version with no outliers
qui su stud_teach, d
gen stud_teach_nout = stud_teach if stud_teach >= (0.5 * `r(p1)') & ///
									stud_teach <= (1.5 * `r(p95)')
label variable stud_teach_nout "`Lab' (no outliers)"
********************************************************************************
*ADJUST PPE ITEMS USING CWI
********************************************************************************

foreach v of var rev_* exp_* {
	*generate
	gen double cwipp`v'1 = (pp`v'1/rut_cwi) * cwi_ecwi_S
	gen double cwipp`v'2 = (pp`v'2/rut_cwi) * cwi_ecwi_S
	
	*label
	local lab: variable label `v'
	
	label variable cwipp`v'1 "CWI-adjusted Per pupil `lab' (imp_member)"
	label variable cwipp`v'2 "CWI-adjusted Per pupil `lab' (rut_member)"
}

********************************************************************************
*GENERATE PPE PROPORTIONS BY EXPENDTIURE CATEGORY USING CWI WEIGHTED VERSIONS
********************************************************************************

foreach v of var exp_* {
	*generate
	gen double prop`v'1 = cwipp`v'1 / cwippexp_totexp1
	gen double prop`v'2 = cwipp`v'2 / cwippexp_totexp2
		
	*label
	local lab: variable label `v'
	
	label variable prop`v'1 "proportion of per pupil rev spend on `lab' (imp_member) (cwi wgt)"
	label variable prop`v'2 "proportion of per pupil rev spend on `lab' (rut_member) (cwi wgt)"
}

	
********************************************************************************
*IDENTIFY OUTLIERS
********************************************************************************
label define outlier ///
	0 "0. Not an outlier" ///
	1 "1. High outlier (> 1.5 * p95 of the district to state ratio)" ///
	2 "2. Low outlier (< .5 * p5 of the district to state ratio)"

*state average of pp total expenditures, weighted by imp_member
preserve
	collapse(mean) pprev_totalrev1 pprev_totalrev2 ///
				   ppexp_totexp1 ppexp_totexp2 [aw=imp_member], ///
				   by(year imp_fips)
		
	rename ppexp_totexp1 Sppexp_totexp1
	rename ppexp_totexp2 Sppexp_totexp2 

	rename pprev_totalrev1 Spprev_totalrev1
	rename pprev_totalrev2 Spprev_totalrev2
	
	tempfile t
	save `t', replace
restore

merge m:1 imp_fips year using `t', nogenerate

*ratio of district to state average
gen Rppexp_totexp1 = ppexp_totexp1/Sppexp_totexp1
gen Rppexp_totexp2 = ppexp_totexp2/Sppexp_totexp2

gen Rpprev_totalrev1 = pprev_totalrev1/Spprev_totalrev1
gen Rpprev_totalrev2 = pprev_totalrev2/Spprev_totalrev2

*5th percentile of ratio in a given year
egen p5Rppexp_totexp1 = pctile(Rppexp_totexp1), p(5) by(year)
egen p5Rppexp_totexp2 = pctile(Rppexp_totexp2), p(5) by(year)

egen p5Rpprev_totalrev1 = pctile(Rpprev_totalrev1), p(5) by(year)
egen p5Rpprev_totalrev2 = pctile(Rpprev_totalrev2), p(5) by(year)

*95th percentile of ratio in a given year
egen p95Rppexp_totexp1 = pctile(Rppexp_totexp1), p(95) by(year)
egen p95Rppexp_totexp2 = pctile(Rppexp_totexp2), p(95) by(year)

egen p95Rpprev_totalrev1 = pctile(Rpprev_totalrev1), p(95) by(year)
egen p95Rpprev_totalrev2 = pctile(Rpprev_totalrev2), p(95) by(year)

*create outlier indicator
gen Oppexp_totexp1 = 0
gen Oppexp_totexp2 = 0

gen Opprev_totalrev1 = 0
gen Opprev_totalrev2 = 0

	*high
	replace Oppexp_totexp1 = 1 if Rppexp_totexp1 > 1.5 * p95Rppexp_totexp1 ///
								  & !missing(Rppexp_totexp1)
	replace Oppexp_totexp2 = 1 if Rppexp_totexp2 > 1.5 * p95Rppexp_totexp2 ///
								  & !missing(Rppexp_totexp2)
								  
	replace Opprev_totalrev1 = 1 if Rpprev_totalrev1 > 1.5 * p95Rpprev_totalrev1 ///
									& !missing(Rpprev_totalrev1)
	replace Opprev_totalrev2 = 1 if Rpprev_totalrev2 > 1.5 * p95Rpprev_totalrev2 ///
									& !missing(Rpprev_totalrev2)
						

	*low
	replace Oppexp_totexp1 = 2 if Rppexp_totexp1 < 0.5 * p5Rppexp_totexp1 ///
								  & !missing(Rppexp_totexp1)
	replace Oppexp_totexp2 = 2 if Rppexp_totexp2 < 0.5 * p5Rppexp_totexp2 ///
								  & !missing(Rppexp_totexp2)
								  
	replace Opprev_totalrev1 = 2 if Rpprev_totalrev1 < 0.5 * p5Rpprev_totalrev1 ///
									& !missing(Rpprev_totalrev1)
	replace Opprev_totalrev2 = 2 if Rpprev_totalrev2 < 0.5 * p5Rpprev_totalrev2 ///
									& !missing(Rpprev_totalrev2)								  
								  
	*label outlier indicator
	local lab: variable label ppexp_totexp1
	label variable Oppexp_totexp1 "(outlier) `lab'"

	local lab: variable label ppexp_totexp2
	label variable Oppexp_totexp2 "(outlier) `lab'"

	
	local lab: variable label pprev_totalrev1
	label variable Opprev_totalrev1 "(outlier) `lab'"
	
	local lab: variable label pprev_totalrev2
	label variable Opprev_totalrev2 "(outlier) `lab'"
	
	*value labels
	label values Oppexp_totexp1 outlier
	label values Oppexp_totexp2 outlier

	label values Opprev_totalrev1 outlier
	label values Opprev_totalrev2 outlier
	
*drop intermediate variables
drop S* R* p5* p95*

********************************************************************************
*OTHER DESCRIPTIVE VARIABLES
********************************************************************************
		
	*ratio of ccd imp member to rutgers member**********************************
	gen desc_rmem = imp_member / rut_member
	label variable desc_rmem "Ratio of ccd imputed member to Rutger's member"
	
	gen desc_rmemhi = (desc_rmem < 0.95 | desc_rmem > 1.05) & !missing(desc_rmem)
	label variable desc_rmemhi "ccd imputed member > 5% different from Rutger's member"
	
	
	*states with fewer than 100,000 black or hispanic or less than 5%***********
	preserve
		collapse (sum) imp_totblack imp_totwhite imp_tothisp imp_member, ///
				  by (imp_fips year)
			
		gen desc_fewblack = (imp_totblack<100000 & ((imp_totblack/imp_member)<.05))
		gen desc_fewhisp= (imp_tothisp<100000 & ((imp_tothisp/imp_member)<.05))
		
		tempfile t
		save `t', replace
	restore
		
	merge m:1 imp_fips year using `t', keepusing(desc_*) nogenerate
	label variable desc_fewblack "state is < 100,000 or 5% black"
	label variable desc_fewhisp "state is < 100,000 or 5% hispanic"
	
	*small districts************************************************************
	gen desc_smalldis = imp_member < 100
	label variable desc_smalldis "District has < 100 students (imp_member)"
	
	*label the states***********************************************************
	label define imp_fips ///
		1 "1. Alabama"			2 "2. Alaska"			4 "4. Arizona"	///
		5 "5. Arkansas" 		6 "6. California"		8 "8. Colorado" ///
		9 "9. Connecticut"		10 "10. Delaware"		11 "11. D.C." ///
		12 "12. Florida" 		13 "13. Georgia"		15 "15. Hawaii" ///
		16 "16. Idaho"			17 "17. Illinois"		18 "18. Indiana" ///
		19 "19. Iowa"			20 "20. Kansas"			21 "21. Kentucky" ///
		22 "22. Louisiana"		23 "23. Maine"			24 "24. Maryland" ///
		25 "25. Massachusetts"	26 "26. Michigan"		27 "27. Minnesota" ///
		28 "28. Mississippi"	29 "29. Missouri"		30 "30. Montana" ///
		31 "31. Nebraska"		32 "32. Nevada"			33 "33. New Hampshire" /// 
		34 "34. New Jersey"		35 "35. New Mexico"		36 "36. New York" ///
		37 "37. North Carolina"	38 "38. North Dakota"	39 "39. Ohio" ///
		40 "40. Oklahoma"		41 "41. Oregon"			42 "42. Pennsylvania" ///
		44 "44. Rhode Island"	45 "45. South Carolina"	46 "46. South Dakota" ///
		47 "47. Tennessee"		48 "48. Texas"			49 "49. Utah" ///
		50 "50. Vermont"		51 "51. Virginia"		53 "53. Washington" ///
		54 "54. West Virginia"	55 "55. Wisconsin"		56 "56. Wyoming"

	label values imp_fips imp_fips
	
	*create region variable*****************************************************
	gen desc_reg = . 
	
	*south
	foreach i in 1 5 11 10 12 13 21 22 24 28 27 40 45 47 51 54{
		replace desc_reg = 1 if imp_fips==`i'
	}
	// AL, AR, DC, DE, FL, GA, KY, LA, MD, MS, NC, OK, SC, TN, VA, WV
	
	*south west
	foreach i in 4 35 48{
		replace desc_reg = 2 if imp_fips==`i'
	}
	//AZ, NM, TX
	
	*west
	foreach i in 2 6 8 15 16 30 32 41 49 53 56{
		replace desc_reg = 3 if imp_fips==`i'
	}
	//AK, CA, CO HI, ID, MT, NV, OR, UT, WA, WY
	
	*northeast
	foreach i in 9 25 23 33 34 36 42 44 50{
		replace desc_reg = 4 if imp_fips==`i'
	}
	//CT, MA, ME, NH, NJ, NY, PA, RI, VT
	
	*midwest
	foreach i in 19 17 18 20 26 27 29 38 31 39 46 55{
		replace desc_reg = 5 if imp_fips==`i'
	}
	//IA, IL, IN, KS, MI, MN, MO, ND, NE, OH, SD, WI
	
	*label region variable
	label def desc_reg 1 "South" 2 "Southwest" 3 "West" 4 "Northeast" 5 "Midwest"
	label values desc_reg desc_reg
	
	label variable desc_reg "Region"
		
	*urbanicity*****************************************************************
	gen urbanicity = ccd_ulocal if !missing(ccd_ulocal)
	replace urbanicity = ccd_local if !missing(ccd_local)
	
	recode urbanicity (1 2 11 12 13 = 1) (3 4 21 22 23 = 2) ///
		(5 6 21 31 32 33 7 8 41 42 43 = 3)
	
	tab urbanicity ccd_msc if year<2001, missing
	
	replace urbanicity = 1 if ccd_msc==1 & year<2001
	replace urbanicity = 2 if ccd_msc==2 & year<2001
	replace urbanicity = 3 if ccd_msc==3 & year<2001
	
	label define urbanicity 1 "1. city" 2 "2. suburb" 3 "3. other" 
	label values urbanicity urbanicity 
	
	rename urbanicity desc_urban
	
	*label contructed urbanicity variable
	label variable desc_urban "city, suburb, or other (constr ccd lea)"
	
	*create urbanicity indicators
	tab desc_urban, gen(urbanicity_)
	
	*label local codes**********************************************************
	label def ccd_local ///
		1 "1. large city" ///
		2 "2. mid-size city" ///
		3 "3. urban fringe of a large city" ///
		4 "4. urban fringe of a mid-size city" ///
		5 "5. large town" ///
		6 "6. small town" ///
		7 "7. rural, outside msa" ///
		8 "8. rural, inside msa"
		
	label values ccd_local ccd_local
	label variable ccd_local "locale code (ccd lea)"
	
	*label ulocal codes*********************************************************
	label def ccd_ulocal ///
		11 "11. city, large" ///
		12 "12. city, midsize" ///
		13 "13. city, small" ///
		21 "21. suburb, large" ///
		22 "22. suburb, midsize" ///
		23 "23. suburb, small" ///
		31 "31. town, fringe" ///
		32 "32. town, distant" ///
		33 "33. town, remote" ///
		41 "41. rural, fringe" ///
		42 "42. rural, distant" ///
		43 "43. rural, remote" 
	
	label values ccd_ulocal ccd_ulocal
	label variable ccd_ulocal "district urban-centric locale code (ccd lea)"

	*rounded count variables****************************************************
	gen nind = round(imp_totind)
	gen nasn = round(imp_totasian)
	gen nhsp = round(imp_tothisp)
	gen nblk = round(imp_totblack) 
	gen nwht = round(imp_totwhite)

	egen ntot = rsum(nblk nhsp nasn nwht nind)
	
	label variable nind "rounded N Native American (ccd imputed)"
	label variable nasn "rounded N asian (ccd imputed)"
	label variable nhsp	"rounded N hispanic (ccd imputed)"
	label variable nblk "rounded N black (ccd imputed)"
	label variable nwht "rounded N white (ccd imputed)"
	
	label variable ntot "rounded sum of all students (ccd imputed)"
	/*note this is NOT imp_member rounded, but rather the sum of the rounded
	subgroup Ns. imp_member rounded would give a different value */
	
	*percent white/asian********************************************************
	gen imp_perwhas = imp_perwhite + imp_perasian
	label variable imp_perwhas "% white or Asian (ccd imputed)"
	
	*child poverty based on saipe***********************************************
	gen desc_perpov = rut_persaipe
	
	label variable desc_perpov "SAIPE Pct. Poverty 5-17 yr olds"
	
	*create drop indicator for districts w/ 5-17 pop values of 0
	gen Drop_poverty = rut_pop517==0
	label variable Drop_poverty "Drop from analytical sample (no 5-17 year olds)"
		
	*number of schools per 1000 students
	gen p_sch = (imp_nsch / imp_member) * 1000
	label variable p_sch "number of school per 1000 students"
********************************************************************************
*INDICATORS NYC AGGREGATED VERSUS GEO DISTRICTS
********************************************************************************
	*nyc geographic district indicator
	local geodis ///
		3600076 3600077 3600078 3600079 3600081 3600083 3600084 3600085 ///
		3600086 3600087 3600088 3600090 3600091 3600119 3600092 3600094 ///
		3600095 3600096 3600120 3600151 3600152 3600153 3600121 3600098 ///
		3600122 3600099 3600123 3600100 3600101 3600102 3600103 3600097
		
	gen desc_nycgeo = 0
	foreach g of local geodis{
		replace desc_nycgeo = 1 if leaid=="`g'"
	}
	
	label variable desc_nycgeo "nyc geographic district observation"
	
	*nyc aggregated district indicator
	gen desc_nycagg = leaid=="3620580"
	
	label variable desc_nycagg "nyc aggregated district observation"
	
	
	
********************************************************************************
*INDICATORS FOR SAMPLE RESTRICTION
********************************************************************************

*check agreement between expenditure and revenue outliers
preserve
	keep Oppexp_totexp1 Opprev_totalrev1 Drop
	keep if Oppexp_totexp1 != Opprev_totalrev1 & Drop !=1
	contract Oppexp_totexp1 Opprev_totalrev1
	export excel using "Results/rev-exp-outlier-agreement_${date}", ///
		firstrow(variables) replace
restore 

*create indicator for outliers in total expenditures
gen drop_out = (Oppexp_totexp1 == 1   | Oppexp_totexp2 == 1 	| ///
				Oppexp_totexp1 == 2   | Oppexp_totexp2 == 2 	| ///
				Opprev_totalrev1 == 1 | Opprev_totalrev2 == 1 	| ///
				Opprev_totalrev1 == 2 | Opprev_totalrev2 == 2)   
label variable drop_out "Drop high and low total per pupil rev/exp outliers"
				
*update sample restriction indicator
replace Drop = 1 if drop_out==1

*create indicator for missing expenditure measure
gen drop_miss = 0

foreach v of var exp_* ppexp_* rev_* pprev_*{
	replace drop_miss = 1 if missing(`v')
}

label variable drop_miss "Drop observations missing rev/exp or pp rev/exp measures"

*update sample restriction indicator
replace Drop = 1 if drop_miss==1

********************************************************************************
*LOWER CASE LABELS
********************************************************************************
foreach v of var *{
	local lab: 	variable label `v'
	local lab = lower("`lab'")
	label variable `v' "`lab'"
}

********************************************************************************
*RESTRICT SAMPLE
********************************************************************************
save "Derived/temp.dta", replace
save "Derived/15_year_sample_district_all-obs_${date}.dta", replace

*Restrict for 15-year sample****************************************************
use "Derived/temp.dta", clear

	*how many charters have data?
	preserve
		drop if year < 1999 | year > 2013
		
		bys merge_rutimp: mdesc imp_fips
		/*the only observations missing the fips are the ones that were in
		rutgers but not the ccd imputed. these are all drop by the sample 
		restriction indicators anyway*/
		
		foreach v in drop_notstate drop_noop drop_vocspec drop_esa drop_jj ///
			drop_out{
			
			di _n
			di "*******************"
			local lab: variable label `v'
			
			di "`lab'"
			drop if `v'==1
			qui count
			di "N = " _col(10) `r(N)'
			
			}
		drop if Drop_poverty == 1 
		//drop if Drop == 1
		
		*expenditure data
		tabstat drop_charter exp_totexp, statistics(count) by(year), ///
			if drop_charter == 1, missing
		
		tabstat drop_charter exp_totexp, statistics(count) by(imp_fips), ///
			if drop_charter == 1, missing	
		
		*revenue data
		tabstat drop_charter rev_totalrev, statistics(count) by(year), ///
			if drop_charter == 1, missing
		
		tabstat drop_charter rev_totalrev, statistics(count) by(imp_fips), ///
			if drop_charter == 1, missing				
			
	restore	
	
	*do the 15-year restriction
	*sample restriction table comes from the following section
	di _n
	di "*******************"
	di "year <1999 | year > 2013"
	drop if year < 1999 | year > 2013
	qui count
	di "N = " _col(10) `r(N)'
	tab year
	
	foreach v in drop_notstate drop_noop drop_vocspec drop_esa drop_jj ///
		drop_charter drop_out drop_miss {
		
		di _n
		di "*******************"
		local lab: variable label `v'
		
		di "`lab'"
		tab year if `v'==1
		drop if `v'==1
		qui count
		di "N = " _col(10) `r(N)'
		
		}

	*Remaining exclusion rules not addressed above (I think it's just year)
	tab year if Drop==1
	drop if Drop == 1   
	qui count
	di "N = " _col(10) `r(N)'
	
	*Additional sample restrictions	
	tab year if Drop_poverty == 1
	drop if Drop_poverty == 1 //no 5-17 year olds according to SAIPE
	
	*final count by year
	tab year
	
	*display n
	qui count
	di "Total N = " _col(10) `r(N)'
	
	*Save 15 year sample
	gen cwi = "yes"
	
	*export some simple variables to check against external sources
	preserve
		keep if year == 2013
		gsort -imp_member
		gen district_size = _n
		
		keep district_size leaid rut_name_ccdlea imp_fips imp_member ///
		imp_perind imp_perasian imp_perhisp imp_perblack imp_perwhite ///
		imp_perflunch imp_perfrlunch

		export excel using "Results/districts-by-size_${date}", replace ///
			firstrow(variables)	
	restore
	
	save "Derived/15_year_sample_district_${date}", replace
	
********************************************************************************
*ROBUSTNESS CHECKS DATASETS
********************************************************************************
use "Derived/15_year_sample_district_${date}", replace

drop if Check_ellout == 1 | Check_specedout == 1

save "Derived/15_year_sample_district_NO-ELL-SPECED-OUT${date}", replace

//rm "Derived/temp.dta"

********************************************************************************
*END MATTER
********************************************************************************
capture log close

forvalues i = 1/10{
	rm "Results/check_ell_outliers_`i'.gph"	
	rm "Results/check_speced_outliers_`i'.gph"	
}


