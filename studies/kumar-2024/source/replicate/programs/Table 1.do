use "H:\radar\k1smg02_k1ank00\mort_data_Feb2019\state_year_cashout_HEL_HELOC_loan_origination_data.dta", clear

merge 1:1 stateusps year using "data\state_year_panel_dataset.dta"
tab _merge
keep if _merge==3
drop _merge

rename loan_count_* lc* 
rename tot_amount_* amt*
rename lc_fst_refi_cout lccashout
rename tot_amt_fst_refi_cout amtcashout

**convert amounts to real
**We were using deflated nominal GDP in RESTAT vesrion
foreach x of varlist amthel amtheloc amtcashout {
gen r`x'=`x'/(cpiu/cpiu2007)
}

foreach x of varlist lchel lcheloc lccashout amthel amtheloc amtcashout ramthel ramtheloc ramtcashout {
gen ln`x'=ln(`x')
}

gen ownhomenum=beapop*(ownhome/100)

foreach x of varlist lchel lcheloc lccashout amthel amtheloc amtcashout ramthel ramtheloc ramtcashout {
gen pc`x'=`x'/(ownhomenum)
gen lnpc`x'=ln(pc`x')
}

cap drop test
egen test=wtmean(pcramthel) if !texas & year<=2000, weight(ownhomenum)
cap drop test2
egen test2=mean(test)
cap drop diff
gen diff=pcramthel-test2 if texas
tsline diff if year<=2000, xline(1997)

cap drop test
egen test=wtmean(pcramtcashout) if !texas & year<=2000, weight(ownhomenum)
cap drop test2
egen test2=mean(test)
cap drop diff
gen diff=pcramtcashout-test2 if texas
tsline diff if year<=2000, xline(1997)

cap drop test
egen test=wtmean(pcramtheloc) if !texas & year>=2000, weight(ownhomenum)
cap drop test2
egen test2=mean(test)
cap drop diff
gen diff=pcramtheloc-test2 if texas
tsline diff if year>=2000, xline(2003)


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
reg `depvar' `xvars' [w=ownhomenum]
cap drop `depvar'_tilde
predict `depvar'_tilde, res

reg `varlist' `xvars' [w=ownhomenum]
cap drop `varlist'_tilde
predict `varlist'_tilde, res

**conly and taber standard errors start
reg `depvar'_tilde `varlist'_tilde [w=ownhomenum], cluster(statefips)
scal diff_and_diff=_b[`varlist'_tilde]
cap drop alpha
gen alpha=_b[`varlist'_tilde]

/**check (1)*/
**alternatively we can also run a regression with DD variable included
**activate this line and deactivate the previous line for checking
qui reg `depvar'_tilde `varlist'_tilde [w=ownhomenum], r cluster(statefips)
di "Difference in differnces estimate  " diff_and_diff
di "Confirm equality of diff-in-diff estimate using residuals " _b[`varlist'_tilde]
/**/

**deactivate this if using check(2) below and make sure that check(1) is active
**this is exactly the procedure described in Conly-Taber RESTAT page XXX, but with weights 
reg `depvar'_tilde [w=ownhomenum], robust cluster(statefips)


**get the residuals for the control states only
cap drop etatilde
predict etatilde if texas==0, res
sum etatilde, det

**note that this exactly the same variable as djtga in conley and taber. 
**It's simply used to replicate the Texas policy variable for each state
cap drop djptexas
bysort year: egen djptexas=wtmean(`varlist') if texas==1, weight(beapop)

cap drop djt
bysort year: egen djt=sum(djptexas)
cap drop meandjt 
bysort statefips: egen meandjt=wtmean(djt), weight(beapop)

cap drop dtil
gen dtil=djt-meandjt

**the following is just to replicated weighted estimates
cap drop wt
gen wt=sqrt(beapop)

cap drop num
bys statefips: egen num=sum(dtil*wt*etatilde*wt)
cap drop den
bys statefips: egen den=sum((dtil*wt)^2)
cap drop asim
**note that we need the following only for control states
gen asim=num/den  if texas==0
sum asim, det

**note that the 5th and 95th percentiles of asim form 90% acceptance region for the diff-in-diff coefficent alpha
**if alpha minus the hypothesized value (0) does not fall with this 90% acceptance region, then the null can be rejected

cap drop ci
**note that alpha and asim are constant across states 
**so generate it only for one observation in each state
bys statefips (year): gen ci=alpha-asim if _n==_N
**diff and diff
di "Difference in differnces estimate  " diff_and_diff
**90% CI

_pctile ci, p(5,95)
return list
return scal cip05=r(r1)
return scal cip95=r(r2)

_pctile ci, p(2.5,97.5)
return list
return scal cip025=r(r1)
return scal cip975=r(r2)

drop *_tilde

/*
**get CIs excatly as per conley and taber make a vector of ci with deimension=number of states and then find the percentiles
local numst=50
local i025=floor(0.025*(`numst'-1))
local i975=ceil(0.975*(`numst'-1))
local i05=floor(0.050*(`numst'-1))
local i95=ceil(0.950*(`numst'-1))

return scal ci025=`i025'
return scal ci975=`i975'
return scal ci05=`i05'
return scal ci95=`i95'
*/
****end of conley taber

end


**for Core Baseline DID restrict sample to 1992-2007
**sample selection (2)
keep if year>=1992 & year<=2007

cap drop groupstatefips
egen groupstatefips=group(statefips)
cap drop groupstateusps
egen groupstateusps=group(stateusps)


char year[omit] 1997
char statefips[omit] 1
char division[omit] 1
char groupstateusps[omit] 1

cap drop t
gen t=year-1994
cap drop t2
gen t2=t^2

xi i.statefips i.year i.year*texas i.statefips*t i.statefips*t2 i.groupstateusps*t i.division*i.year i.region*i.year

**prime age65plus white black hisp married female child hhchild fsize hsdrop hsgrad somecol college postcollege collegeplus
global expl1 L1lnrahem L1sttaxr L1lnhpifhfa
**older specification
**global expl2 age female married child white collegeplus
**newer specification
global expl2 age female married child white black hsgrad collegeplus
global expl $expl1 $expl2 _IstaXt_* _IdivXyea*

**we are yet to try any regressions

**simple estimates without Conley-Taber
estimates clear
eststo: reg lnlccashout _Istatefips* _Iyear* $expl2 texas_post1997 if year<=2000 [w=ownhomenum], robust cluster(statefips)
eststo: reg lnlchel _Istatefips* _Iyear* $expl2 texas_post1997  if year<=2000 [w=ownhomenum], robust cluster(statefips)
eststo: reg lnlcheloc _Istatefips* _Iyear* $expl2 texas_post2003  if year>2000 [w=ownhomenum], robust cluster(statefips)
eststo: reg lnpcramtcashout _Istatefips* _Iyear* $expl2 texas_post1997 if year<=2000 [w=ownhomenum], robust cluster(statefips)
eststo: reg lnpcramthel _Istatefips* _Iyear* $expl2 texas_post1997  if year<=2000  [w=ownhomenum], robust cluster(statefips)
eststo: reg lnpcramtheloc _Istatefips* _Iyear* $expl2 texas_post2003  if year>2000 [w=ownhomenum], robust cluster(statefips)
esttab using "$resultsdir\first_stage_evidence.rtf", replace title("Table AXXX: Impact of Texas Home Equity Amendments on Loan Origination") keep(texas_post1997 texas_post2003) order(texas_post1997 texas_post2003) nocons b(%7.3f) se(%7.3f) nonotes starlevels(* 0.10 ** 0.05) label  sfmt(%12.3f) /*nomtitles*/ scalars("r2_a AdjR-Sq") indicate("State Fixed Effects=_Istatefips*" "Year Fixed Effects=_Iyear*" "Demographics=$expl2") 


**estimates with conley and Taber
estimates clear
preserve 
keep if year<=2000
reg lnlccashout _Istatefips* _Iyear* $expl2 texas_post1997 [w=ownhomenum], robust cluster(statefips)
global cmdline `e(cmdline)'
contab_with_weights_simple texas_post1997
global cip05_texas_post1997=r(cip05)
global cip95_texas_post1997=r(cip95)
eststo: $cmdline
estadd scal cip05_texas_post1997=$cip05_texas_post1997
estadd scal cip95_texas_post1997=$cip95_texas_post1997
restore

preserve
keep if year<=2000
reg lnlchel _Istatefips* _Iyear* $expl2 texas_post1997 [w=ownhomenum], robust cluster(statefips)
global cmdline `e(cmdline)'
contab_with_weights_simple texas_post1997
global cip05_texas_post1997=r(cip05)
global cip95_texas_post1997=r(cip95)
eststo: $cmdline
estadd scal cip05_texas_post1997=$cip05_texas_post1997
estadd scal cip95_texas_post1997=$cip95_texas_post1997
restore

preserve
keep if year >2000
reg lnlcheloc _Istatefips* _Iyear* $expl2 texas_post2003 [w=ownhomenum], robust cluster(statefips)
global cmdline `e(cmdline)'
contab_with_weights_simple texas_post2003
global cip05_texas_post2003=r(cip05)
global cip95_texas_post2003=r(cip95)
eststo: $cmdline
estadd scal cip05_texas_post2003=$cip05_texas_post2003
estadd scal cip95_texas_post2003=$cip95_texas_post2003
restore

preserve
keep if year<=2000
reg lnpcramtcashout _Istatefips* _Iyear* $expl2 texas_post1997 [w=ownhomenum], robust cluster(statefips)
global cmdline `e(cmdline)'
contab_with_weights_simple texas_post1997
global cip05_texas_post1997=r(cip05)
global cip95_texas_post1997=r(cip95)
eststo: $cmdline
estadd scal cip05_texas_post1997=$cip05_texas_post1997
estadd scal cip95_texas_post1997=$cip95_texas_post1997
restore

preserve
keep if year<=2000
reg lnpcramthel _Istatefips* _Iyear* $expl2 texas_post1997  [w=ownhomenum], robust cluster(statefips)
global cmdline `e(cmdline)'
contab_with_weights_simple texas_post1997
global cip05_texas_post1997=r(cip05)
global cip95_texas_post1997=r(cip95)
eststo: $cmdline
estadd scal cip05_texas_post1997=$cip05_texas_post1997
estadd scal cip95_texas_post1997=$cip95_texas_post1997
restore

preserve
keep if year>2000
reg lnpcramtheloc _Istatefips* _Iyear* $expl2 texas_post2003  [w=ownhomenum], robust cluster(statefips)
global cmdline `e(cmdline)'
contab_with_weights_simple texas_post2003
global cip05_texas_post2003=r(cip05)
global cip95_texas_post2003=r(cip95)
eststo: $cmdline
estadd scal cip05_texas_post2003=$cip05_texas_post2003
estadd scal cip95_texas_post2003=$cip95_texas_post2003
restore

esttab using "$resultsdir\Table 1.rtf", replace title("Table 1: Impact of Texas Home Equity Amendments on Loan Origination") keep(texas_post1997 texas_post2003) order(texas_post1997 texas_post2003) nocons b(%7.3f) se(%7.3f) nonotes starlevels(* 0.10 ** 0.05) label  sfmt(%12.3f) /*nomtitles*/ scalars("r2_a AdjR-Sq" "cip05_texas_post1997 cip05_texas_post1997" "cip95_texas_post1997 cip95_texas_post1997" "cip05_texas_post2003 cip05_texas_post2003" "cip95_texas_post2003 cip95_texas_post2003") indicate("State Fixed Effects=_Istatefips*" "Year Fixed Effects=_Iyear*" "Demographics=$expl2") 