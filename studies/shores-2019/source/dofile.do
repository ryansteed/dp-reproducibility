/************************************************
 SET PATHS & GLOBALS
 ***********************************************/
* loc c "`c(username)'" 
glob dir1 "."
glob outT "."
glob outG "."
*glob date  `c(current_date)'
* cd ${dir}
glob covars0 ""
glob covars1 "unemployed_count2003 estab_count_priv_total2003 poppoorchild2003 percap_income2003"
*glob covars1 "laborforce2003 estab_count_priv_total2003 poppoorchild2003 percap_income2003"
*glob covars2 "laborforce2006 unemployed_count2006 estab_count_priv_total2006 poppoorchild2006 percap_income2006 blk2007 wht2007 hsp2007 frl2007 tot2007"
glob covars2   "unemployed_count2006 estab_count_priv_total2006 poppoorchild2006 percap_income2006 expD2004 expD2005 expD2006 expD2007"
glob covars3 "${covars1} ${covars2}"
glob covars4 "laborpre unemppre estabpre poorpre incpre"
glob covars5 "${covars3} ${covars4}"
glob covars6 "labor unemp estab poor inc" 
glob covars7 " totenrl  tchstu  ppexp_tot pctfrl pcthsp pctasn pctblk pctwht "
glob covars8 "rural town suburb urban"

/************************************************
 ACHIEVEMENT DATA PREP
 ***********************************************/
u "${dir1}/analysis_file.dta", clear
drop if fips=="11"
replace recrank = recrank/10
gen dummy = 1
encode fips, gen(fips_num)
*replace percap_income2006   = percap_income2006  * laborforce2006
replace wtmathwin = . if wtmath==.
replace wtelawin  = . if wtela==.
bys county: egen medenroll = median(totenrl)
gen medenrollwin = medenroll
sum medenroll,d
loc min = r(p1)
loc max = r(p99)
replace medenrollwin = `min' if medenrollwin<`min'
replace medenrollwin = `max' if medenrollwin>`max' & medenrollwin!=.

preserve
	keep countyid bartiktotemp2_cty fips
	duplicates drop
	loneway bartiktotemp2_cty fips
	di r(sd_w)/(r(sd_w)+r(sd_b))
restore
gen exposureN = .
replace exposureN = 0 if inlist(cohort,2010,2011,2012)
replace exposureN = 1 if inlist(cohort,2001,2009)
replace exposureN = 2 if inlist(cohort,2002,2003,2004,2005,2006,2007,2008)

gen yearcenN = .
replace yearcenN = 0 if inlist(year,2009,2010)
*replace yearcenN = 0 if inlist(year,2009,2010,2011)
loc i = 0
forval y = 2011/2015 {
*forval y = 2012/2015 {
	loc ++i
	replace yearcenN = `i' if year==`y'
	}
	ta yearcenN, gen(recov_)
gen yearcenN2 = 0 if inrange(year,2003,2012)
replace yearcenN2 = 1 if year==2013
replace yearcenN2 = 2 if year==2014
replace yearcenN2 = 3 if year==2015
gen reform = year>=2013

gen exposureND = exposureN>0
gen exposureNP0 = exposureN==0
gen exposureNP1 = exposureN==1
gen exposureNP2 = exposureN==2
foreach g in blk hsp wht  pov1 pov2 {
gen `g'med = inrange(`g'quar,3,4)
}
keep if inrange(cohort,2002,2011)
clonevar conumINT = countyid 
tempfile hold
save `hold'

preserve
	keep conumINT recquar
	rename recquar recquarSEDA
	duplicates drop
	gen sedaflag = 1
	tempfile sedaflat
	save `sedaflat'
restore

/************************************************
 REVENUES DATA PREP
 ************************************************/
*loc c "`c(username)'" 
glob dir "."
glob out "."
glob outT "."
glob outG "."
*glo date  `c(current_date)'

*cd ${dir}

u "${dir}/revenues_2003_2015.dta", clear
drop if inlist(fips,11,15)

gen per1 = inrange(year,2004,2008)
gen per2 = inrange(year,2009,2010)
gen per3 = inrange(year,2011,2013)
gen per4 = inrange(year,2014,2015)

merge m:1 conumINT using `sedaflat', gen(_seda)										// merge SEDA data (recquarSEDA)
keep if _seda==3																// keep if counties have achievement data 
reg lnexp lnins lncap exp ins cap  v33 i.year, cluster(conumINT)
keep if e(sample)
clonevar countyid = conumINT
tempfile finance
save `finance'

preserve
	keep exp conumINT year v33
	collapse (mean) exp [aw=v33], by(conumINT year)
	destring conumINT, gen(ivar)
	xtset ivar year
	tsfill , full
	bys ivar (year): ipolate exp year, gen(temp) epolate
	replace exp = temp if exp==. 
	bys ivar (year): carryforward conumINT, replace
	gen year2 = -1*year
	bys ivar (year2): carryforward conumINT, replace
	keep if inlist(year,2003,2004,2005,2006,2007,2008)
	keep exp conumINT year
	reshape wide exp, i(conumINT) j(year)
	gen exptrend = exp2008-exp2003
	forval y = 2004/2008 {
		loc x = `y'-1
		gen expD`y' = exp`y'-exp`x'
		}
	keep conumINT exptrend exp???? expD????
	tempfile prefinance
	save `prefinance'
restore

preserve																		// get non-missing finance sample to merge back to SEDA
	keep conumINT year
	duplicates drop
	tempfile f33
	save `f33'
restore

u `hold', clear																	// seda data 
merge m:1 conumINT year using `f33', gen(_f33)									// merge F33 data
keep if _f33==3																	// keep if counties have finance data
merge m:1 conumINT using `prefinance', nogen 									// merge prespending changes
tempfile seda
save `seda'

cap erase "${outT}/AERAOPEN_RR_${date}.xlsx"
cap erase "${outG}/AERAOPEN_RR_${date}.docx"
cap putdocx clear
putdocx begin, landscape		// saving graphs to word doc



/***************************************************
TABLES 
***************************************************/
/* TABLE 1: DESCRIPTIVE STATISTICS SCHOOL COVARS COVARS */
u `seda', clear
tempname memhold
tempfile results 
postfile `memhold' str30 depvar str30 statistic str10 pre0 str10 pre1 str10 pre2 str10 pre3 str10 pre4 using `results'

qui foreach v of glob covars7{
forval q = 1/4 {
	if "`v'"=="totenrl" loc wt 
	else loc wt [aw=totenrl]
	sum `v' if recq==`q'  `wt'
	loc mn`q' : di %3.2f r(mean)
	loc sd`q' : di %3.2f r(sd)
	unique countyid  if recq==`q'
	loc cty`q' : di %3.2f r(unique)
	}
	sum `v' `wt'
	loc mn0 : di % 3.2f r(mean)
	loc sd0 : di % 3.2f r(sd)
	loc n0 : di % 3.2f r(N)
	unique countyid 
	loc cty0 : di %3.2f r(unique)
	post `memhold' ("`v'") ("Mean") ("`mn0'") ("`mn1'") ("`mn2'")  ("`mn3'")  ("`mn4'") 
	post `memhold' ("`v'") ("(SD)") ("(`sd0')") ("(`sd1')")  ("(`sd2')")  ("(`sd3')")  ("(`sd4')") 
	}

qui foreach v of glob covars8 {
forval q = 1/4 {
	sum totgeo if recq==`q'
	loc denom = r(sum)
	sum `v' if recq==`q'  
	loc mn`q' : di %3.2f r(sum)/`denom'
	loc n`q' : di %3.2f r(N)

	}
	sum totgeo 
	loc denom = r(sum)
	sum `v' 
	loc mn0 : di % 3.2f r(sum)/`denom'
	loc sd0 : di % 3.2f r(sd)
	loc n0 : di % 3.2f r(N)

	
	post `memhold' ("`v'") ("Mean") ("`mn0'") ("`mn1'") ("`mn2'")  ("`mn3'")  ("`mn4'") 

	}
	post `memhold' ("All") ("Obs")  ("`n0'") ("`n1'")  ("`n2'")  ("`n3'")  ("`n4'")  
	post `memhold' ("All") ("Counties")  ("`cty0'") ("`cty1'")  ("`cty2'")  ("`cty3'")  ("`cty4'")  

preserve
	postclose `memhold'
	u `results', clear
	compress
	export excel "${outT}/AERAOPEN_RR_${date}.xlsx", sheet("Table 1") sheetreplace firstrow(varlabels)
restore

/* TABLE 2: DESCRIPTIVE STATISTICS ACHIEVEMENT */
u `seda', clear
tempname memhold
tempfile results 
postfile `memhold' str30 depvar str30 statistic str10 pre0 str10 pre1 str10 pre2 str10 pre3 str10 pre4 using `results'

qui foreach v in math ela{
forval q = 1/4 {
	sum mn_all`v' if recq==`q'  [aw=wt`v']
	loc mn`q' : di %3.2f r(mean)
	loc sd`q' : di %3.2f r(sd)
	loc n`q' : di %3.2f r(N)
	unique countyid  if recq==`q'
	loc cty`q' : di %3.2f r(unique)	
	}
	sum mn_all`v' [aw=wt`v']
	loc mn0 : di % 3.2f r(mean)
	loc sd0 : di % 3.2f r(sd)
	loc n0 : di % 3.2f r(N)
	unique countyid 
	loc cty0 : di %3.2f r(unique)

	post `memhold' ("`v'") ("Mean") ("`mn0'") ("`mn1'") ("`mn2'")  ("`mn3'")  ("`mn4'") 
	post `memhold' ("`v'") ("(SD)") ("(`sd0')") ("(`sd1')")  ("(`sd2')")  ("(`sd3')")  ("(`sd4')") 
	post `memhold' ("`v'") ("Obs")  ("`n0'") ("`n1'")  ("`n2'")  ("`n3'")  ("`n4'")  
	post `memhold' ("`v'") ("Counties")  ("`cty0'") ("`cty1'")  ("`cty2'")  ("`cty3'")  ("`cty4'")  	
	}

preserve
	postclose `memhold'
	u `results', clear
	compress
	export excel "${outT}/AERAOPEN_RR_${date}.xlsx", sheet("Table 2") sheetreplace firstrow(varlabels)
restore



/* TABLE 3 & TABLE A1: Estimated Annual Change in Total Expenditures */
u `finance', clear
gen per21 = inrange(year,2003,2008)
gen per22 = inrange(year,2008,2010)
gen per23 = inrange(year,2010,2013)
gen per24 = inrange(year,2013,2015)
replace year = year-2003

qui forval p = 1/4 {
foreach v in lnexp lnins lncap {
** DD \Delta log spending
	eststo DDlog`v'`p': reg `v'_D i.recquarSEDA if per`p'==1 [aw=v33], cluster(countyid)
** ITS log spending
	eststo ITSlog`v'`p': reg `v' i.recquarSEDA##c.year if per2`p'==1 [aw=v33], cluster(countyid)
	}
foreach v in exp ins cap {
** DD \Delta lev spending
	eststo DDlev`v'`p': reg `v'_D i.recquarSEDA if per`p'==1 [aw=v33], cluster(countyid)
** ITS spending
	eststo ITSlev`v'`p': reg `v' i.recquarSEDA##c.year if per2`p'==1 [aw=v33], cluster(countyid)
	
	}
}
# del ;
esttab DDlevexp? 
	using "${outT}/temp.xls", 
	label cells(b(star fmt(3)) se(par(`"="("'`")""') fmt(3))) 
	keep(DDDeltaRI2 DDDeltaRI3 DDDeltaRI4)
	rename(2.recquarSEDA DDDeltaRI2 3.recquarSEDA DDDeltaRI3 4.recquarSEDA DDDeltaRI4)    
	star(* 0.10 ** 0.05 *** .01)
	stardetach stats(N_clust N, fmt( 0 0)) replace tab
;
esttab ITSlevexp? 
	using "${outT}/temp.xls", 
	label cells(b(star fmt(3)) se(par(`"="("'`")""') fmt(3))) 
	keep(DDDeltaRI2 DDDeltaRI3 DDDeltaRI4)
	rename(2.recquarSEDA#c.year DDDeltaRI2 3.recquarSEDA#c.year DDDeltaRI3 4.recquarSEDA#c.year DDDeltaRI4)    
	star(* 0.10 ** 0.05 *** .01)
	stardetach stats(N_clust N, fmt( 0 0)) append tab
;
# del cr
preserve
	insheet using "${outT}/temp.xls", tab clear
	export excel using "${outT}/AERAOPEN_RR_${date}.xlsx", sheet("Table 3") sheetreplace firstrow(varl)
restore	
cap est clear

/* TABLE 4: Generated by Hand, Not Estimated */

/* TABLE 5: Estimated Changes in Student Achievement */
u `seda', clear
foreach s in math ela {
	* MODEL 1: DOSE-RESPONSE
	eststo `s'm1: reghdfe mn_all`s' i.recquar##c.exposureN [aw=wt`s'], abs(conum year##grade i.year#i.grade#c.(${covars2})) cluster(conum year##grade) 
	testparm 2.recquar#c.exposureN 3.recquar#c.exposureN 4.recquar#c.exposureN, equal
	estadd scalar txequal = `r(p)'
	
	* MODEL 2: DOSE-RESPONSE+RECOVERY
	eststo `s'm2: reghdfe mn_all`s' i.recquar##c.exposureN##c.yearcenN [aw=wt`s'], abs(conum year##grade i.year#i.grade#c.(${covars2})) cluster(conum  year##grade) 
	testparm 2.recquar#c.exposureN 3.recquar#c.exposureN 4.recquar#c.exposureN, equal
	estadd scalar txequal = `r(p)'
	testparm 2.recquar#c.exposureN#c.yearcenN 3.recquar#c.exposureN#c.yearcenN 4.recquar#c.exposureN#c.yearcenN, equal
	estadd scalar recequal = `r(p)'
	
	* MODEL 1: DOSE-RESPONSE + DICHOTOMOUS
	eststo `s'm3: reghdfe mn_all`s' i.recquar##c.exposureND [aw=wt`s'], abs(conum year##grade i.year#i.grade#c.(${covars2}), savefe) cluster(conum year##grade) residuals
	testparm 2.recquar#c.exposureND 3.recquar#c.exposureN 4.recquar#c.exposureND, equal
	estadd scalar txequal = `r(p)'
	
	* MODEL 2: DOSE-RESPONSE+RECOVERY + DICHOTOMOUS
	eststo `s'm4: reghdfe mn_all`s' i.recquar##c.exposureND##c.yearcenN [aw=wt`s'], abs(conum year##grade i.year#i.grade#c.(${covars2}), savefe) cluster(conum  year##grade) resid
	testparm 2.recquar#c.exposureND 3.recquar#c.exposureND 4.recquar#c.exposureND, equal
	estadd scalar txequal = `r(p)'
	testparm 2.recquar#c.exposureND#c.yearcenN 3.recquar#c.exposureND#c.yearcenN 4.recquar#c.exposureND#c.yearcenN, equal
	estadd scalar recequal = `r(p)'	
}	

*** EDITED by Donna
estout using "../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

# del ;
esttab mathm1 mathm2 elam1 elam2
	using "${outT}/temp.xls", 
	label cells(b(star fmt(3)) se(par(`"="("'`")""') fmt(3))) 
	keep(Q2Exposure Q3Exposure Q4Exposure Q2Recovery Q3Recovery Q4Recovery) 
	rename(2.recquar#c.exposureN Q2Exposure 3.recquar#c.exposureN Q3Exposure 4.recquar#c.exposureN Q4Exposure 2.recquar#c.exposureN#c.yearcenN Q2Recovery 3.recquar#c.exposureN#c.yearcenN Q3Recovery 4.recquar#c.exposureN#c.yearcenN Q4Recovery)    
	star(* 0.10 ** 0.05 *** .01)
	stardetach stats(N N_clust1 N_clust2 r2_a, fmt(3 3 0 0 0 3)) replace tab
;
# del cr
# del ;
esttab mathm3 mathm4 elam3 elam4
	using "${outT}/temp.xls", 
	label cells(b(star fmt(3)) se(par(`"="("'`")""') fmt(3))) 
	keep(Q2Exposure Q3Exposure Q4Exposure Q2Recovery Q3Recovery Q4Recovery) 
	rename(2.recquar#c.exposureND Q2Exposure 3.recquar#c.exposureND Q3Exposure 4.recquar#c.exposureND Q4Exposure 2.recquar#c.exposureND#c.yearcenN Q2Recovery 3.recquar#c.exposureND#c.yearcenN Q3Recovery 4.recquar#c.exposureND#c.yearcenN Q4Recovery)    
	star(* 0.10 ** 0.05 *** .01)
	stardetach stats(N N_clust1 N_clust2 r2_a, fmt(3 3 0 0 0 3)) append tab
;
# del cr
est clear
preserve
	insheet using "${outT}/temp.xls", tab clear
	export excel "${outT}/AERAOPEN_RR_${date}.xlsx", sheet("Table 5") sheetreplace firstrow(varlabels)
restore	

/*
/* TABLE A1: GENERATED ABOVE IN TABLE 3 CODE */

/* TABLE A2: GENERATED BY HAND, NOT ESTIMATED */

/* TABLE A3: GENERATED BY HAND, NOT ESTIMATED */

/* TABLE A4: SENSITIVITY, COHORTS */
cap est clear
qui foreach s in math ela {
forval c = 2002/2008 {
	* MODEL 2: DOSE-RESPONSE+RECOVERY
	eststo `s'm2`c': reghdfe mn_all`s' i.recquar##c.exposureN##c.yearcenN [aw=wt`s']  if cohort!=`c', abs(conum year##grade i.year#i.grade#c.(${covars2})) cluster(conum  year##grade) 
}	
}

# del ;
esttab mathm2????
	using "${outT}/temp.xls", 
	label cells(b(star fmt(3)) se(par(`"="("'`")""') fmt(3))) 
	keep(Q2Exposure Q3Exposure Q4Exposure Q2Recovery Q3Recovery Q4Recovery) 
	rename(2.recquar#c.exposureN Q2Exposure 3.recquar#c.exposureN Q3Exposure 4.recquar#c.exposureN Q4Exposure 2.recquar#c.exposureN#c.yearcenN Q2Recovery 3.recquar#c.exposureN#c.yearcenN Q3Recovery 4.recquar#c.exposureN#c.yearcenN Q4Recovery)    
	star(* 0.10 ** 0.05 *** .01)
	stardetach stats(N N_clust1 N_clust2 r2_a, fmt(3 3 0 0 0 3)) replace tab
;
# del cr
# del ;
esttab elam2????
	using "${outT}/temp.xls", 
	label cells(b(star fmt(3)) se(par(`"="("'`")""') fmt(3))) 
	keep(Q2Exposure Q3Exposure Q4Exposure Q2Recovery Q3Recovery Q4Recovery) 
	rename(2.recquar#c.exposureN Q2Exposure 3.recquar#c.exposureN Q3Exposure 4.recquar#c.exposureN Q4Exposure 2.recquar#c.exposureN#c.yearcenN Q2Recovery 3.recquar#c.exposureN#c.yearcenN Q3Recovery 4.recquar#c.exposureN#c.yearcenN Q4Recovery)    
	star(* 0.10 ** 0.05 *** .01)
	stardetach stats(N N_clust1 N_clust2 r2_a, fmt(3 3 0 0 0 3)) append tab
;
# del cr
est clear
preserve
	insheet using "${outT}/temp.xls", tab clear
	export excel "${outT}/AERAOPEN_RR_${date}.xlsx", sheet("Table 6") sheetreplace firstrow(varlabels)
restore	

/* TABLE A5: NON-RANDOM SORTING OF COMP VARS */
u `seda', clear
foreach g in blk wht hsp frl {

	* MODEL 2: DOSE-RESPONSE+RECOVERY
	eststo `g'm2: reghdfe pct`g' i.recquar##c.exposureN##c.yearcenN [aw=totenrl], abs(conum year##grade i.year#i.grade#c.(${covars2})) cluster(conum  year##grade) 
	testparm 2.recquar#c.exposureN 3.recquar#c.exposureN 4.recquar#c.exposureN, equal
	estadd scalar txequal = `r(p)'
	testparm 2.recquar#c.exposureN#c.yearcenN 3.recquar#c.exposureN#c.yearcenN 4.recquar#c.exposureN#c.yearcenN, equal
	estadd scalar recequal = `r(p)'
	sum pct`g' if e(sample)==1
	estadd scalar grpmn = `r(mean)'
	
}	

# del ;
esttab blkm2 hspm2 whtm2 frlm2
	using "${outT}/temp.xls", 
	label cells(b(star fmt(3)) se(par(`"="("'`")""') fmt(3))) 
	keep(Q2Exposure Q3Exposure Q4Exposure Q2Recovery Q3Recovery Q4Recovery) 
	rename(2.recquar#c.exposureN Q2Exposure 3.recquar#c.exposureN Q3Exposure 4.recquar#c.exposureN Q4Exposure 2.recquar#c.exposureN#c.yearcenN Q2Recovery 3.recquar#c.exposureN#c.yearcenN Q3Recovery 4.recquar#c.exposureN#c.yearcenN Q4Recovery)    
	star(* 0.10 ** 0.05 *** .01)
	stardetach stats(grpmn N N_clust1 N_clust2  r2_a, fmt(3 0 0 0 3)) replace tab
;
# del cr
est clear
preserve
	insheet using "${outT}/temp.xls", tab clear
	export excel "${outT}/AERAOPEN_RR_${date}.xlsx", sheet("Table 7") sheetreplace firstrow(varl)
restore	


/* TABLE A6 & A7: Estimated Changes in Student Achievement, by Poverty & Racial/Ethnic Comp. */
u `seda', clear
rename pctfrl pctpov1 
cap est clear
qui foreach s in math ela {
foreach g in blk hsp wht  pov1 {		// pov1: frl; pov2: saipe
forval q = 1/4{
	clonevar grpquar = `g'quar
	* MODEL 2: DOSE-RESPONSE+RECOVERY
	eststo `s'm2`g'`q': reghdfe mn_all`s' i.recquar##c.exposureND##c.yearcenN [aw=wt`s'] if grpquar==`q', abs(conum year##grade i.year#i.grade#c.(${covars2})) cluster(conum  year##grade) 
	sum pct`g' if grpquar==`q' & e(sample)==1
	estadd scalar grpmn = `r(mean)'
	drop grpquar
		}
	}	
}

# del ;
esttab mathm2pov11 mathm2pov12 mathm2pov13 mathm2pov14 elam2pov11 elam2pov12 elam2pov13 elam2pov14 
	using "${outT}/temp.xls", 
	label cells(b(star fmt(3)) se(par(`"="("'`")""') fmt(3))) 
	keep(Q2Exposure Q3Exposure Q4Exposure Q2Recovery Q3Recovery Q4Recovery) 
	rename(2.recquar#c.exposureND Q2Exposure 3.recquar#c.exposureND Q3Exposure 4.recquar#c.exposureND Q4Exposure 2.recquar#c.exposureND#c.yearcenN Q2Recovery 3.recquar#c.exposureND#c.yearcenN Q3Recovery 4.recquar#c.exposureND#c.yearcenN Q4Recovery)    
	star(* 0.10 ** 0.05 *** .01)
	stardetach stats(grpmn N_clust1 N , fmt(3 0 0 )) replace tab
;

esttab mathm2blk1 mathm2blk2 mathm2blk3 mathm2blk4 elam2blk1 elam2blk2 elam2blk3 elam2blk4 
	using "${outT}/temp.xls", 
	label cells(b(star fmt(3)) se(par(`"="("'`")""') fmt(3))) 
	keep(Q2Exposure Q3Exposure Q4Exposure Q2Recovery Q3Recovery Q4Recovery) 
	rename(2.recquar#c.exposureND Q2Exposure 3.recquar#c.exposureND Q3Exposure 4.recquar#c.exposureND Q4Exposure 2.recquar#c.exposureND#c.yearcenN Q2Recovery 3.recquar#c.exposureND#c.yearcenN Q3Recovery 4.recquar#c.exposureND#c.yearcenN Q4Recovery)    
	star(* 0.10 ** 0.05 *** .01)
	stardetach stats(grpmn N_clust1 N , fmt(3 0 0 )) append tab
;

esttab mathm2hsp1 mathm2hsp2 mathm2hsp3 mathm2hsp4 elam2hsp1 elam2hsp2 elam2hsp3 elam2hsp4 
	using "${outT}/temp.xls", 
	label cells(b(star fmt(3)) se(par(`"="("'`")""') fmt(3))) 
	keep(Q2Exposure Q3Exposure Q4Exposure Q2Recovery Q3Recovery Q4Recovery) 
	rename(2.recquar#c.exposureND Q2Exposure 3.recquar#c.exposureND Q3Exposure 4.recquar#c.exposureND Q4Exposure 2.recquar#c.exposureND#c.yearcenN Q2Recovery 3.recquar#c.exposureND#c.yearcenN Q3Recovery 4.recquar#c.exposureND#c.yearcenN Q4Recovery)    
	star(* 0.10 ** 0.05 *** .01)
	stardetach stats(grpmn N_clust1 N , fmt(3 0 0 )) append tab
;

esttab mathm2wht1 mathm2wht2 mathm2wht3 mathm2wht4 elam2wht1 elam2wht2 elam2wht3 elam2wht4 
	using "${outT}/temp.xls", 
	label cells(b(star fmt(3)) se(par(`"="("'`")""') fmt(3))) 
	keep(Q2Exposure Q3Exposure Q4Exposure Q2Recovery Q3Recovery Q4Recovery) 
	rename(2.recquar#c.exposureND Q2Exposure 3.recquar#c.exposureND Q3Exposure 4.recquar#c.exposureND Q4Exposure 2.recquar#c.exposureND#c.yearcenN Q2Recovery 3.recquar#c.exposureND#c.yearcenN Q3Recovery 4.recquar#c.exposureND#c.yearcenN Q4Recovery)    
	star(* 0.10 ** 0.05 *** .01)
	stardetach stats(grpmn N_clust1 N , fmt(3 0 0 )) append tab
;
# del cr

preserve
	insheet using "${outT}/temp.xls", tab clear
	export excel using "${outT}/AERAOPEN_RR_${date}.xlsx", sheet("Table A5") sheetreplace firstrow(varl)
restore	


/* TABLE B1: 2 WAY DIFF IN DIFF */
u `seda', clear
keep if inrange(cohort,2002,2011)
gen treat = recquar==4
keep if inlist(recquar,1,4)
tempname memhold
tempfile results
postfile `memhold' str20 subject exposed unexposed  firstdiff recquar using `results'

qui foreach s in math ela {
foreach q in 0 1 {
foreach e in 0 1 {
	reg mn_all`s' [aw=wt`s'] if treat==`q' & exposureND==`e'
	loc mn`e'`s' : di %4.3f _b[_cons]
	}
	reg mn_all`s' i.exposureND [aw=wt`s'] if treat==`q'
	loc mn`s' : di %4.3f _b[1.exposureND]
	post `memhold' ("`s'") (`mn1`s'') (`mn0`s'') (`mn`s'') (`q')
	}
	foreach e in 0 1 {
	reg mn_all`s' i.treat [aw=wt`s'] if  exposureND==`e'
	loc mn`e'`s' : di %4.3f _b[1.treat]
	}
	reg mn_all`s' i.treat##i.exposureND [aw=wt`s'] 
	loc mn`s' : di %4.3f _b[1.treat#1.exposureND]
	di "`mn`s''"
	post `memhold' ("`s'") (`mn1`s'') (`mn0`s'') (`mn`s'') (41)
	}
postclose `memhold' 
u `results', clear


/***************************************************
FIGURES 
***************************************************/

/* FIGURE 1: Total Expenditures by RI Quartile*/ 
u `finance', clear
tempname memhold
tempfile results 
postfile `memhold' str25 depvar str10 type beta se year quartile median using `results'
qui foreach v in lnexp lnins lncap exp ins cap {
forval y = 2003/2015 {
foreach q in 1 2 3 4 {
	sum `v' [aw=v33] if year==`y' & recquarSEDA==`q',d
	post `memhold' ("`v'") ("lev") (`r(mean)') (`r(sd)') (`y') (`q') (`r(p50)')
	
	sum `v'_bl [aw=v33] if year==`y' & recquarSEDA==`q',d
	post `memhold' ("`v'") ("bl") (`r(mean)') (`r(sd)') (`y') (`q')  (`r(p50)')
		}
	}
}
postclose `memhold'
preserve
	u `results', clear
	
*	set scheme s1color
	gen string = substr(string(year),-2,.)
	labmask year , val(string)
	replace beta = beta/1000 if type=="lev" & !inlist(depvar,"lnexp","lnins","lncap")
	
	tempfile hold
	save `hold'
	foreach v in exp cap ins lncap lnexp lnins {
	foreach t in lev bl {
	u `hold', clear
	keep if depvar=="`v'" & type=="`t'"
	# del ;
	graph tw 
		(line beta year if quartile==1, lc(gray) lp(dash))
		(line beta year if quartile==2, lc(black) lp(dash))
		(line beta year if quartile==3, lc(gray) lp(solid))
		(line beta year if quartile==4, lc(black) lp(solid))
		, 
		leg(order(1 "Rec Q1" 2 "Rec Q2" 3 "Rec Q3" 4 "Rec Q4")rows(1)symxsize(*1))
		xline(2008, lc(black)) 
		xlab(2003(1)2015, val)
		ylab(, angle(hori))
		ytitle("") xtitle("Spring Academic Year", size(medsmall)) title("")
		name(`v'_`t', replace) 
		;
	# del cr
		graph display, xsize(4.5) ysize(3.75)
		gr save "${outG}/fin`v'_`t'", asis replace
		gr export "${outG}/fin`v'_`t'.tif", replace as(tif)
	}
	}
	foreach v in lnexp exp {
		grc1leg `v'_lev `v'_bl, rows(1) imargin(vsmall) 
		graph display, xsize(9) ysize(4.5)
		gr save "${outG}/fin`v'_levbl", asis replace
		gr export "${outG}/fin`v'_levbl.tif", replace as(tif)
		putdocx paragraph, halign(center)
		putdocx text ("FIGURE 1 ${date}"), bold		
		putdocx image "${outG}/fin`v'_levbl.png"
		putdocx pagebreak
	}
	foreach v in lev bl {
		grc1leg lnins_`v' lncap_`v', rows(1) imargin(zero) 
		graph display, xsize(9) ysize(4.5)
		gr save "${outG}/finlninscap_`v'", asis replace
		gr export "${outG}/finlninscap_`v'.tif", replace as(tif)
		*putdocx paragraph, halign(center)
		*putdocx text ("log inst. cap. `v' ${date}"), bold
		*putdocx image "${outG}/finlninscap_`v'.png"
		*putdocx pagebreak
	}
	foreach v in lev bl {
		grc1leg ins_`v' cap_`v', rows(1) imargin(zero) 
		graph display, xsize(9) ysize(4.5)
		gr save "${outG}/fininscap_`v'", asis replace
		gr export "${outG}/fininscap_`v'.tif", replace as(tif)
		*putdocx paragraph, halign(center)
		*putdocx text ("inst. cap. `v' ${date}"), bold
		*putdocx image "${outG}/fininscap_`v'.png"
		*putdocx pagebreak
	}
	
	foreach v in exp lnexp ins lnins cap lncap {
	foreach t in lev bl {
		*putdocx paragraph, halign(center)
		*putdocx text ("`v' `t' ${date}"), bold
		*putdocx image "${outG}/fin`v'_`t'.png"
		*putdocx pagebreak
	}
	}
restore

/* FIGURE 2: RESIDUALIZED MATH AND ELA ACHIEVEMENT, BY RI */
graph set window fontface "Calibri light"
foreach s in ela math {
if "`s'"=="ela" loc title "ELA"
if "`s'"=="math" loc title "Math"
if "`s'"=="ela" loc ytitle ""
if "`s'"=="math" loc ytitle "Residualized Standard Deviation (SD) Units"
preserve
	reghdfe mn_all`s' [aw=wt`s'], abs(conum cohort )  residuals(mathresid)
	keep if inlist(recquar,1,4) & e(sample)==1
	foreach r in 1 4 {
		sum mathresid [aw=wt`s'] if inrange(year,2009,2010) & exposureND==1 & recquar==`r'
		loc pre`r' = `r(mean)'
	forval e = 0/1 {
		sum mathresid [aw=wt`s'] if inrange(year,2011,2015) & exposureND==`e' & recquar==`r'
		loc post`r'`e' = `r(mean)'
		}
	}
	collapse (mean) mathresid [aw=wt`s'] , by(recquar year exposureND)
	# del ; 
	graph tw 
		(connected mathresid year if recquar==1 & exposureND==1, color(gray) lw(medthick) lp(solid) ms(sh) msize(small)) 
		(connected mathresid year if recquar==4 & exposureND==1, color(black) lw(medthick) lp(solid) ms(sh) msize(small))
		(connected mathresid year if recquar==1 & exposureND==0, color(gray) lw(medthick) lp(dash) ms(Dh) msize(small)) 
		(connected mathresid year if recquar==4 & exposureND==0, color(black) lw(medthick) lp(dash) ms(Dh) msize(small))
		, 
		leg(order(1 "Rec Q1|Exposure=1" 2 "Rec Q4|Exposure=1"  3 "Rec Q1|Exposure=0" 4 "Rec Q4|Exposure=0" ))
		xlab(2009 "09" 2010 "10" 2011 "11" 2012 "12" 2013 "13" 2014 "14" 2015 "15") 
		ylab(, angle(hori))
		xtitle(Spring Academic Year) 
		ytitle("`ytitle'")
		title("`title'", ring(0) pos(10))
		name(`s', replace)
	;
	# del cr
restore
}
grc1leg math ela, rows(1) imargin(zero) name(stylized1, replace) ycommon
graph display, xsize(9) ysize(6.5)
gr export "${outG}/residach.tif", replace as(tif)

/* FIGURE 3: EVENT ANALYSIS DICHOTOMOUS RESULTS */
u `seda', clear
tempname memhold
tempfile results
postfile `memhold' str10 subject exposure quartile year beta se using `results'
foreach s in math ela {
	
	* MODEL 2: DOSE-RESPONSE+RECOVERY
	eststo `s'm2: reghdfe mn_all`s' i.recquar##c.exposureND##c.yearcenN [aw=wt`s'], abs(conum year##grade i.year#i.grade#c.(${covars2})) cluster(conum  year##grade) 
	forval q = 2/4 {
	forval y = 2009/2010{
		loc yr = `y'-2008
		lincom [(`q'.recquar#c.exposureND)] 
		post `memhold' ("`s'") (2) (`q') (`y')  (`r(estimate)') (`r(se)') 
			}
	forval y = 2011/2015 {
		loc yr = `y'-2010
		lincom [(`q'.recquar#c.exposureND)] + [(`q'.recquar#c.exposureND#c.yearcenN)*(`yr')]
		post `memhold' ("`s'") (2) (`q') (`y')  (`r(estimate)') (`r(se)') 			
			}
		}		
	}

postclose `memhold'
u `results', clear

gen hi = beta+1.96*se
gen lo = beta-1.96*se

gen string = substr(string(year),-2,.)
labmask year , val(string)

*putdocx begin, landscape		// saving graphs to word doc

foreach s in math ela {
if "`s'"=="math" loc title "Math"
if "`s'"=="ela"  loc title "ELA"
if "`s'"=="math" loc ytitle "Standard Deviation (SD) Units"
if "`s'"=="ela"  loc ytitle ""
# del ;
	graph tw 
		(line beta year if q==2 & sub=="`s'", lc(gs12)lp(solid))	
		(line beta year if q==3 & sub=="`s'", lc(gs6)lp(solid))
		(line beta year if q==4 & sub=="`s'", lc(black)lp(solid))		
		(rarea hi lo year if q==4 & sub=="`s'", lc(black%25) fc(black%25) lp(solid) lw(thin))
		,
		title("`title'", ring(0) pos(10)) 
		name(`s'ci, replace) 
		leg(order(1 "Rec Q2" 2 "Rec Q3" 3 "Rec Q4")rows(1)) 
		xtitle("") 
		xlab(2009(1)2015, val) 
		ysca(ra(-.1 .05))
		ylab(-.1(.05).05, angle(hori))
		yline(0, lc(black) lw(thin) lp(dash))
		plotregion(m(zero)) 
		;
# del cr

	graph display, xsize(9) ysize(6.5)
	gr save "${outG}/main`s'", asis replace
	gr export "${outG}/main`s'.tif", replace as(tif)
	*putdocx paragraph, halign(center)
	*putdocx text ("main effects: `s' ${date}"), bold
	*putdocx image "${outG}/main`s'.png"
	*putdocx pagebreak
	
# del ;
	graph tw 
		(line beta year if q==2 & sub=="`s'", lc(gs12)lp(solid))	
		(line beta year if q==3 & sub=="`s'", lc(gs6)lp(solid))
		(line beta year if q==4 & sub=="`s'", lc(black)lp(solid))		
		,
		title("`title'", ring(0) pos(10)) 
		ytitle("`ytitle'", size(medsmall)) 
		xtitle("Spring Academic Year", size(medsmall))		
		name(`s', replace) 
		leg(order(1 "Rec Q2" 2 "Rec Q3" 3 "Rec Q4")rows(1)) 
		xtitle("Spring Academic Year", size(medsmall)) 
		xlab(2009(1)2015, val) 
		ysca(ra(-.1 .05))
		ylab(-.1(.05).05, angle(hori))
		yline(0, lc(black) lw(thin) lp(dash))
		plotregion(m(zero)) 
		;
# del cr

	graph display, xsize(9) ysize(6.5)
	gr save "${outG}/main`s'noCI", asis replace
	gr export "${outG}/main`s'noCI.tif", replace as(tif)
*	putdocx paragraph, halign(center)
*	putdocx text ("FIGURE 2 ${date}"), bold	
*	putdocx image "${outG}/main`s'noCI.png"
*	putdocx pagebreak	
}
grc1leg math ela , rows(1) imargin(medsmall)  ycommon
graph display, xsize(9) ysize(6.5) 
gr export "${outG}/mainnoCI.tif", replace as(tif)
gr save "${outG}/main`s'noCI", asis replace

putdocx paragraph, halign(center)
putdocx text ("FIGURE 2 ${date}"), bold	
putdocx image "${outG}/main`s'noCI.png"
putdocx pagebreak	


/* FIGURE 4: COHORT/AGE HETEROGENEITY */
u `seda', clear
tempname memhold
tempfile results
postfile `memhold' str10 subject cohort quartile year beta se using `results'

foreach s in math ela {
forval c = 2002/2008 {	
	* MODEL 2: DOSE-RESPONSE+RECOVERY
	eststo `s'm2: reghdfe mn_all`s' i.recquar##c.exposureN##c.yearcenN if inlist(cohort,`c',2009,2010,2011) [aw=wt`s'], abs(conum year##grade i.year#i.grade#c.(${covars2})) cluster(conum  year##grade) 
	forval q = 2/4 {
	forval y = 2009/2010{
		loc yr = `y'-2008
		lincom [(`q'.recquar#c.exposureN)*2] 
		post `memhold' ("`s'") (`c') (`q') (`y')  (`r(estimate)') (`r(se)') 
			}
	forval y = 2011/2015 {
		loc yr = `y'-2010
		lincom [(`q'.recquar#c.exposureN)*2] + [(`q'.recquar#c.exposureN#c.yearcenN)*(`yr')]
		post `memhold' ("`s'") (`c') (`q') (`y')  (`r(estimate)') (`r(se)') 			
			}
		}		
	}
}
postclose `memhold'
u `results', clear

gen hi = beta+1.96*se
gen lo = beta-1.96*se
keep if year==2009 

foreach s in math ela {
if "`s'"=="math" loc title "Math"
if "`s'"=="ela"  loc title "ELA"
if "`s'"=="math" loc ytitle "Standard Deviation (SD) Units"
if "`s'"=="ela"  loc ytitle ""
# del ;
	graph tw 
		(scatter beta cohort if sub=="`s'" & q==4, color(black)lp(solid))	
		(rcap hi lo cohort if sub=="`s'" & q==4, color(black) lp(solid) lw(thin))
		,
		title("`title'", ring(0) pos(10)) 
		name(`s'new, replace) 
		leg(off) 
		xtitle("Cohort", size(medsmall))  ytitle("`ytitle'", size(medsmall))
		xlab(2002(1)2008) 
		ysca(ra(-.1 .05))
		ylab(-.1(.05).05, angle(hori))
		yline(0, lc(black) lw(thin) lp(dash))
		;
# del cr

	graph display, xsize(4.5) ysize(6.5)
	gr save "${outG}/cohort`s'", asis replace
	gr export "${outG}/cohort`s'.tif", replace as(tif)
	*putdocx paragraph, halign(center)
	*putdocx image "${outG}/cohort`s'.png"
	*putdocx pagebreak
} 
graph combine mathnew elanew, rows(1) imargin(small) ycommon
graph display, xsize(9) ysize(6.5)
gr save "${outG}/cohort", asis replace
gr export "${outG}/cohort.tif", replace as(tif)
putdocx paragraph, halign(center)
putdocx text ("FIGURE 3 `s' ${date}"), bold
putdocx image "${outG}/cohort.png"
putdocx pagebreak


/* FIGURES 5 & 6: MATH AND ELA HETEROGENEITY: SUBGROUP (QUARTILES)*/
u `seda', clear
tempname memhold
tempfile results
postfile `memhold'  str10 subject str10 group  groupquar recquar year beta se using `results'
cap est clear
qui foreach s in math ela {
foreach g in blk hsp wht  pov1 {		// pov1: frl; pov2: saipe
forval q = 1/4{
	* MODEL 1: DOSE-RESPONSE
	clonevar grpquar = `g'quar
	
	* MODEL 2: DOSE-RESPONSE+RECOVERY
	eststo `s'm2: reghdfe mn_all`s' i.recquar##c.exposureND##c.yearcenN [aw=wt`s'] if grpquar==`q', abs(conum year##grade i.year#i.grade#c.(${covars2})) cluster(conum  year##grade) 
	forval i = 2/4 {
	forval y = 2009/2010{
		loc yr = `y'-2008
		lincom [(`i'.recquar#c.exposureND)] 
		post `memhold' ("`s'") ("`g'") (`q') (`i') (`y')  (`r(estimate)') (`r(se)') 
			}
	forval y = 2011/2015 {
		loc yr = `y'-2010
		lincom [(`i'.recquar#c.exposureND)] + [(`i'.recquar#c.exposureND#c.yearcenN)*(`yr')]
		post `memhold' ("`s'") ("`g'") (`q') (`i') (`y')  (`r(estimate)') (`r(se)') 			
			}
		}		
	drop grpquar
		}
	}	
}


postclose `memhold'
u `results', clear
gen hi = beta+1.96*se
gen lo = beta-1.96*se

gen string = substr(string(year),-2,.)
labmask year , val(string)

save "${outT}/heteroresults_quar.dta", replace
u"${outT}/heteroresults_quar.dta" , clear

foreach q in quar {
	if "`q'"=="quar" loc max 4
	loc graph ""
	loc legend ""
	forval i = 1/`max' {
		if "`i'"=="1"  loc col gs12
		if "`i'"=="2" & "`max'"!="2" loc col gs8
		if "`i'"=="2" & "`max'"=="2" loc col black
		if "`i'"=="3" & "`max'"!="3" loc col gs8
		if "`i'"=="3" & "`max'"=="3" loc col black
		if "`i'"=="4" & "`max'"!="4" loc col gs8
		if "`i'"=="4" & "`max'"=="4" loc col black
		if "`i'"=="1" loc pat shortdash
		if "`i'"=="2" & "`max'"!="2" loc pat dash
		if "`i'"=="2" & "`max'"=="2" loc pat solid
		if "`i'"=="3" & "`max'"!="3" loc pat longdash
		if "`i'"=="3" & "`max'"=="3" loc pat solid
		if "`i'"=="4" loc pat solid		

	loc graph "`graph' (line beta year if recquar==4 & groupq==`i', lp(`pat') lc(`col'))"
	loc legend `" `legend'  `i' "Subgroup Q`i'" "'
	}
	di `"`legend'"'

	u "${outT}/heteroresults_`q'.dta", clear
	if "`q'"=="med" replace groupquar = groupquar + 1
	foreach s in math ela {
	if "`s'"=="math" loc subtitle "Math"
	if "`s'"=="ela"  loc subtitle "ELA"
	foreach g in wht blk hsp pov1 {
	if "`g'"=="wht" loc name "White"
	if "`g'"=="blk" loc name "Black"
	if "`g'"=="hsp" loc name "Hispanic"
	if "`g'"=="pov1" loc name "Poverty"
	if "`g'"=="pov2" loc name "Poverty"	
	if inlist("`g'","wht","hsp") loc ytitle "Standard Deviation (SD) Units"
	if inlist("`g'","blk","pov1") loc ytitle ""
	if inlist("`g'","wht","blk") loc xtitle ""
	if inlist("`g'","hsp","pov1") loc xtitle "Spring Academic Year"	
	preserve
		keep if subject=="`s'" & group=="`g'" 
		# del ;
		graph tw 
			`graph'
			, 
			title("`name'", ring(0) pos(10) size(medsmall))
			name(`s'`g'`q', replace) 
			yline(0, lc(black) lw(thin)) 
			xlab(2009(1)2015, val)  ylab(-.15 -.1 -.05 0 .05, angle(hori)) ysca(ra(-.15 .06))
			leg(order(`legend') rows(1) symxsize(*.5))   
			xtitle("`xtitle'", size(medsmall)) 
			ytitle("`ytitle'", size(medsmall)) 
			
			nodraw
			ylab(, angle(hori))
			;
		# del cr
	restore
	}
	grc1leg `s'wht`q' `s'blk`q' `s'hsp`q' `s'pov1`q' , rows(2) imargin(small) ycommon name(`s'`q', replace) 
	graph display, xsize(9) ysize(6.5)
	gr save "${outG}/hetero`s'`q'", asis replace
	gr export "${outG}/hetero`s'`q'.tif", replace as(tif)
	*putdocx paragraph, halign(center)
	*putdocx text ("FIGURE 4/5 `s' ${date}"), bold
	*putdocx image "${outG}/hetero`s'`q'.png"
	*putdocx pagebreak
	
	}
}
putdocx save "${outG}/AERAOPEN_RR_${date}.docx", replace
*/

