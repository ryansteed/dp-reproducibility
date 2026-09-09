use "../data/basic_cps_IPUMS_lfp_by_group.dta", clear

sort statefips year
merge m:1 statefips year using "../data/state_year_panel_dataset.dta", keepusing(stateusps division)
keep if _merge==1|_merge==3
drop _merge

**sample selection (1)
keep if year>=1992 & year<=2007
drop if statefips==11

cap drop texas
gen texas=statefips==48
cap drop post1997
gen post1997=year>=1998
cap drop post2003
gen post2003=year>=2004
gen texas_post1997=texas*post1997
gen texas_post2003=texas*post2003
gen post1997to2003=year>=1998 & year<=2003
gen texas_post1997to2003=texas*post1997to2003
**pre dummy excluding 1997
gen pre=year<1997
gen texas_pre=texas*pre
egen t=group(year)
gen t2=t^2
gen t3=t^3
gen t4=t^4
egen groupstatefips=group(statefips)
egen groupstateusps=group(stateusps)

char year[omit] 1997
char statefips[omit] 1
char division[omit] 1
**char groupstateusps[omit] 1

xi i.statefips i.year i.division*i.year i.agegrp3cat i.race4cat i.educ4cat 

cap label drop texas
label define texas 0 "Rest of US" 1 "Texas"
label val texas texas

**label var texas_post "Texas X Post 1997"
label var texas_post1997 "Texas X Post 1997"
label var texas_post2003 "Texas X Post 2003"
label var texas_post1997to2003 "Texas X 1997-2003"

replace inlf=inlf*100
rename inlf lfpr
label var lfpr "LFPR"

numlabel, remove
labmask statefips, val(stateusps)

version 17
**uses residualized policy variable after a regression to get its CI
cap program drop contab_with_weights_simple
program contab_with_weights_simple, rclass
syntax varlist(max=1)
local depvar `e(depvar)'
di "Dependent Variable is: " "`depvar'"
local xvars: colfullnames e(b)
**di "`xvars'"
local cons _cons
local xvars: list xvars-cons 
**di "`xvars'"
local xvars: list xvars-varlist
di "Independent Variables are: " "`xvars'"
**now residualize
reg `depvar' `xvars' [w=weight_all], r cluster(statefips)
cap drop `depvar'_tilde
predict `depvar'_tilde, res

reg `varlist' `xvars' [w=weight_all], r cluster(statefips)
cap drop `varlist'_tilde
predict `varlist'_tilde, res

**conly and taber standard errors start
reg `depvar'_tilde `varlist'_tilde [w=weight_all], r cluster(statefips)

/* create indicator for the statefips where policy changed (Texas==1)*/
matrix b=_b[`varlist'_tilde]

**quietly {
/* predict residuals from regression */
cap drop eta
predict eta, res 
replace eta=eta+_b[`varlist'_tilde]*`varlist'

/* create d tilde variable*/
cap drop djttexas
bysort year: egen djttexas=wtmean(`varlist') if texas==1, weight(weight_all)
cap drop sdjt
bysort year: egen sdjt=sum(djttexas) 
cap drop ndjt
bysort year: egen ndjt=count(djttexas) 
cap drop djt
gen djt=sdjt/ndjt
cap drop meandjt
bysort statefips: egen meandjt=wtmean(djt), weight(weight_all)
cap drop dtil
g dtil=djt-meandjt

/* obtain difference in differences coefficient*/
reg eta dtil [w=weight_all] if texas==1,noc
matrix alpha=e(b)


/* simulations*/
cap drop k 
cap drop stmax
sum statefips
g k=r(min)
g stmax=r(max)
while k<=stmax {
		capture {
		reg eta dtil [w=weight_all] if statefips==k & texas!=1, noc
		matrix alpha=alpha\e(b)
	}
		replace k=k+1
	} 
matrix asim=alpha[2...,1]
matrix alpha=alpha[1,1]

/* Confidence intervals */
cap drop alpha*
svmat alpha 
cap drop asim*
svmat asim

cap drop ind
g byte ind=1
bysort ind: egen alpha=sum(alpha1)
cap drop alpha1 ind eta djttexas sdjt ndjt djt meandjt dtil k stmax
cap drop ci
g ci=alpha-asim
**}

/* form confidence intervals */
local numst=51
local i025=floor(0.025*(`numst'-1))
local i975=ceil(0.975*(`numst'-1))
local i05=floor(0.050*(`numst'-1))
local i95=ceil(0.950*(`numst'-1))

quietly sum alpha
display as text "Difference in Differences coefficient=" as result _newline(2) r(mean)

sort asim
quietly sum ci if _n==`i025'|_n==`i975'
return scal cip025=r(min)
return scal cip975=r(max)
display as text "95% Confidence interval=" as result _newline(2) r(min) _col(15) r(max)
quietly sum ci if _n==`i05'|_n==`i95'
return scal cip05=r(min)
return scal cip95=r(max) 
display as text "90% Confidence interval=" as result _newline(2) r(min) _col(15) r(max)

drop *_tilde

end

global expl female child married _Iagegrp* _Ieduc4cat* _Irace4cat* 

**Not staggered-HEL and HEL+HELOC

estimates clear

preserve

keep if !female

qui reg lfpr _Istatefips* _Iyear* _IdivXyea* $expl texas_post1997to2003 texas_post2003 [w=weight_all], robust cluster(statefips)
global cmdline `e(cmdline)'
contab_with_weights_simple texas_post1997to2003
global cip05_texas_post1997to2003=r(cip05)
global cip95_texas_post1997to2003=r(cip95)
qui $cmdline
contab_with_weights_simple texas_post2003
global cip05_texas_post2003=r(cip05)
global cip95_texas_post2003=r(cip95)
eststo: $cmdline
estadd scal cip05_texas_post1997to2003=$cip05_texas_post1997to2003
estadd scal cip95_texas_post1997to2003=$cip95_texas_post1997to2003
estadd scal cip05_texas_post2003=$cip05_texas_post2003
estadd scal cip95_texas_post2003=$cip95_texas_post2003

restore

preserve

keep if female

qui reg lfpr _Istatefips* _Iyear* _IdivXyea* $expl texas_post1997to2003 texas_post2003 [w=weight_all], robust cluster(statefips)
global cmdline `e(cmdline)'
contab_with_weights_simple texas_post1997to2003
global cip05_texas_post1997to2003=r(cip05)
global cip95_texas_post1997to2003=r(cip95)
qui $cmdline
contab_with_weights_simple texas_post2003
global cip05_texas_post2003=r(cip05)
global cip95_texas_post2003=r(cip95)
eststo: $cmdline
estadd scal cip05_texas_post1997to2003=$cip05_texas_post1997to2003
estadd scal cip95_texas_post1997to2003=$cip95_texas_post1997to2003
estadd scal cip05_texas_post2003=$cip05_texas_post2003
estadd scal cip95_texas_post2003=$cip95_texas_post2003

restore

preserve

keep if agegrp3cat==2

qui reg lfpr _Istatefips* _Iyear* _IdivXyea* $expl texas_post1997to2003 texas_post2003 [w=weight_all], robust cluster(statefips)
global cmdline `e(cmdline)'
contab_with_weights_simple texas_post1997to2003
global cip05_texas_post1997to2003=r(cip05)
global cip95_texas_post1997to2003=r(cip95)
qui $cmdline
contab_with_weights_simple texas_post2003
global cip05_texas_post2003=r(cip05)
global cip95_texas_post2003=r(cip95)
eststo: $cmdline
estadd scal cip05_texas_post1997to2003=$cip05_texas_post1997to2003
estadd scal cip95_texas_post1997to2003=$cip95_texas_post1997to2003
estadd scal cip05_texas_post2003=$cip05_texas_post2003
estadd scal cip95_texas_post2003=$cip95_texas_post2003

restore

preserve

keep if agegrp3cat==3

qui reg lfpr _Istatefips* _Iyear* _IdivXyea* $expl texas_post1997to2003 texas_post2003 [w=weight_all], robust cluster(statefips)
global cmdline `e(cmdline)'
contab_with_weights_simple texas_post1997to2003
global cip05_texas_post1997to2003=r(cip05)
global cip95_texas_post1997to2003=r(cip95)
qui $cmdline
contab_with_weights_simple texas_post2003
global cip05_texas_post2003=r(cip05)
global cip95_texas_post2003=r(cip95)
eststo: $cmdline
estadd scal cip05_texas_post1997to2003=$cip05_texas_post1997to2003
estadd scal cip95_texas_post1997to2003=$cip95_texas_post1997to2003
estadd scal cip05_texas_post2003=$cip05_texas_post2003
estadd scal cip95_texas_post2003=$cip95_texas_post2003

restore

preserve

keep if educ4cat<=2

qui reg lfpr _Istatefips* _Iyear* _IdivXyea* $expl texas_post1997to2003 texas_post2003 [w=weight_all], robust cluster(statefips)
global cmdline `e(cmdline)'
contab_with_weights_simple texas_post1997to2003
global cip05_texas_post1997to2003=r(cip05)
global cip95_texas_post1997to2003=r(cip95)
qui $cmdline
contab_with_weights_simple texas_post2003
global cip05_texas_post2003=r(cip05)
global cip95_texas_post2003=r(cip95)
eststo: $cmdline
estadd scal cip05_texas_post1997to2003=$cip05_texas_post1997to2003
estadd scal cip95_texas_post1997to2003=$cip95_texas_post1997to2003
estadd scal cip05_texas_post2003=$cip05_texas_post2003
estadd scal cip95_texas_post2003=$cip95_texas_post2003

restore

preserve

keep if educ4cat>=3

qui reg lfpr _Istatefips* _Iyear* _IdivXyea* $expl texas_post1997to2003 texas_post2003 [w=weight_all], robust cluster(statefips)
global cmdline `e(cmdline)'
contab_with_weights_simple texas_post1997to2003
global cip05_texas_post1997to2003=r(cip05)
global cip95_texas_post1997to2003=r(cip95)
qui $cmdline
contab_with_weights_simple texas_post2003
global cip05_texas_post2003=r(cip05)
global cip95_texas_post2003=r(cip95)
eststo: $cmdline
estadd scal cip05_texas_post1997to2003=$cip05_texas_post1997to2003
estadd scal cip95_texas_post1997to2003=$cip95_texas_post1997to2003
estadd scal cip05_texas_post2003=$cip05_texas_post2003
estadd scal cip95_texas_post2003=$cip95_texas_post2003

restore

**AEJ RR Comment: Explore heterogeneity by race
gen white=race4cat==1
gen black=race4cat==2
gen hispanic=race4cat==3
gen other_race=race4cat==4

preserve

keep if white

qui reg lfpr _Istatefips* _Iyear* _IdivXyea* $expl texas_post1997to2003 texas_post2003 [w=weight_all], robust cluster(statefips)
global cmdline `e(cmdline)'
contab_with_weights_simple texas_post1997to2003
global cip05_texas_post1997to2003=r(cip05)
global cip95_texas_post1997to2003=r(cip95)
qui $cmdline
contab_with_weights_simple texas_post2003
global cip05_texas_post2003=r(cip05)
global cip95_texas_post2003=r(cip95)
eststo: $cmdline
estadd scal cip05_texas_post1997to2003=$cip05_texas_post1997to2003
estadd scal cip95_texas_post1997to2003=$cip95_texas_post1997to2003
estadd scal cip05_texas_post2003=$cip05_texas_post2003
estadd scal cip95_texas_post2003=$cip95_texas_post2003

restore

preserve

**keep if !white
keep if (black|hispanic)

qui reg lfpr _Istatefips* _Iyear* _IdivXyea* $expl texas_post1997to2003 texas_post2003 [w=weight_all], robust cluster(statefips)
global cmdline `e(cmdline)'
contab_with_weights_simple texas_post1997to2003
global cip05_texas_post1997to2003=r(cip05)
global cip95_texas_post1997to2003=r(cip95)
qui $cmdline
contab_with_weights_simple texas_post2003
global cip05_texas_post2003=r(cip05)
global cip95_texas_post2003=r(cip95)
eststo: $cmdline
estadd scal cip05_texas_post1997to2003=$cip05_texas_post1997to2003
estadd scal cip95_texas_post1997to2003=$cip95_texas_post1997to2003
estadd scal cip05_texas_post2003=$cip05_texas_post2003
estadd scal cip95_texas_post2003=$cip95_texas_post2003

restore

esttab using "$resultsdir\Table 4.rtf", replace title("Table 4: Difference in Differences Estimates of Home Equity Access on LFPR") keep(texas_post1997to2003 texas_post2003) order(texas_post1997to2003 texas_post2003) mtitles("Male" "Female" "Prime-Age" "Age-55+" "No-College" "Any-College" "White" "Non-White")  nocons b(%7.3f) se(%7.3f) nonotes starlevels(* 0.10 ** 0.05) label  sfmt(%12.3f)  scalars("r2_a AdjR-Sq" "cip05_texas_post1997to2003 cip05_texas_post1997to2003" "cip95_texas_post1997to2003 cip95_texas_post1997to2003" "cip05_texas_post2003 cip05_texas_post2003" "cip95_texas_post2003 cip95_texas_post2003") indicate("State Fixed Effects=_Istatefips*" "Year Fixed Effects=_Iyear*" "Demographic Controls=${expl}" "Division X Year Effects=_IdivXyea*" /*"State X Quadratic Trend=_IstaXt2_*"*/) 