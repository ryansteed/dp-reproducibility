
*Change to desired directory:
cd "C:\Lundqvist\Grantseffects\AEJ_EconomicPolicy\Data"

use "finaldata.dta", clear

***

*Figure 1a

gen migrationgrant2=.
gen outmigration2=-popchange_10y
forvalues year=1996(1)2004 {
	sum migrationgrant if outmigration2<2 & year==`year'
	replace migrationgrant2=migrationgrant-r(mean) if year==`year'
	}
	
scatter migrationgrant2 outmigration2 if outmigration>-40 & outmigration<20 & year==1998, ///
xline(2) ytitle("Out-migration grants", size(large)) xtitle("Net out-migration", size(large)) title("Grants received", size(vlarge)) scheme(s1color)

*Figure 1b

gen marginalgrant=0
replace marginalgrant=1 if D==1

scatter marginalgrant outmigration2 if outmigration>-40 & outmigration<20 & year==1998, ///
xline(2) ytitle("Out-migration grants", size(large)) xtitle("Net out-migration", size(large)) title("Marginal increase in grants", size(vlarge)) scheme(s1color)

***

*Figure 3a

foreach var in admin child school elder social tech {
	gen pers_`var'_n=pers_`var'*pop/1000
	bysort year: egen aggr_pers_`var'=sum(pers_`var'_n)
	}
label var aggr_pers_admin "Administration"
label var aggr_pers_child "Child care"
label var aggr_pers_school "Schools"
label var aggr_pers_elder "Elderly care"
label var aggr_pers_social "Social welfare"
label var aggr_pers_tech "Technical services"
		
scatter aggr_pers_admin aggr_pers_child aggr_pers_school aggr_pers_elder aggr_pers_social aggr_pers_tech year, ///
connect(l l l l l l) lpattern(dash solid solid dash solid solid) msymbol(O D T S + X) scheme(s1color) ///
ytitle("Full-time equivalents", size(medlarge)) xtitle("Year", size(medlarge)) title("Publicly employed")

*Figure 3b

foreach var in child school elder social {
	gen pers_priv_`var'_n=pers_priv_`var'*pop/1000
	bysort year: egen aggr_pers_priv_`var'=sum(pers_priv_`var'_n)
}
	
foreach var in child elder social {
replace aggr_pers_priv_`var'=. if year<2002
}
label var aggr_pers_priv_child "Child care"
label var aggr_pers_priv_school "Schools"
label var aggr_pers_priv_elder "Elderly care"
label var aggr_pers_priv_social "Social welfare"
	
scatter aggr_pers_priv_child aggr_pers_priv_school aggr_pers_priv_elder aggr_pers_priv_social year, ///
connect(l l l l) lpattern(dash solid solid dash) msymbol(O D X S) scheme(s1color) ///
ytitle("Number employed", size(medlarge)) xtitle("Year", size(medlarge)) title("Privately employed")

***

*Figure 4 & Figure 5

*Choosing bins and bin size (see footnote 23)

*For the graphical analysis we focus on bandwidth h=10 (m>-8 & m<12) 
local bins_below 10
local bins_above 10
local bins_tot = `bins_below' + `bins_above' + 1
local bh = 1

*The kink at m=2
local k=2

generate assignment_binned = .

local b1 = `k'-`bins_below'*`bh'
 
forvalues i=2(1)`bins_tot' {
	local l = `i'-1
	local b`i' = `k'-(`bins_below'-`i'+1)*`bh'
	replace assignment_binned = `b`l'' + `bh'/2 if `b`l'' <= outmigration & outmigration < `b`i''
	// generate regression test dummies
	// dbin2...dbin30 are the dummies associated with bandwith h
	// ud2 ... ud30 are the dummies associated with the halfwidth
	// qdbin2...qdbin2 are the dummies associated with interacting dbin`i' with the assignment variable
	generate dbin`i' = `b`l'' <= outmigration & outmigration < `b`i''
	generate udbin`i' = `b`l'' + `bh'/2  <= outmigration & outmigration < `b`i''
	generate qbin`i' = dbin`i'*outmigration
		replace dbin`i'=dbin`i'*outmigration
	replace udbin`i'=udbin`i'*outmigration
	replace qbin`i'=qbin`i'*outmigration
	}

*Two tests for whether this bin size is rejected:
*1)
foreach outcome in costequalgrants pers_total pers_admin pers_child pers_school pers_elder pers_social pers_tech {
	xi: reg `outcome' dbin* udbin* i.year if assignment_binned~=., cluster(code)
	testparm udbin*
	local F`outcome' = r(F)
	local pv`outcome' = r(p)
	}
	
*2)
foreach outcome in costequalgrants pers_total pers_admin pers_child pers_school pers_elder pers_social pers_tech {
	xi: reg `outcome' dbin* qbin* i.year if assignment_binned~=., cluster(code)
	testparm qbin*
	local q_F`outcome' = r(F)
	local q_pv`outcome' = r(p)
	}

foreach outcome in costequalgrants pers_total pers_admin pers_child pers_school pers_elder pers_social pers_tech {
	*display "F`outcome' = `F`outcome''"
	display "pv`outcome' = `pv`outcome''"
	}	
foreach outcome in costequalgrants pers_total pers_admin pers_child pers_school pers_elder pers_social pers_tech {
	*display "q_F`outcome' = `q_F`outcome''"
	display "q_pv`outcome' = `q_pv`outcome''"
	}

	

*Figure 4

preserve

collapse (mean) costequalgrants ///
(median) outmigration forcing1 (count) nobs=costequalgrants, by(assignment_binned)
qui su nobs
local total = r(sum)
g dens = nobs / `total'
g obs = nobs


#delimit ;
scatter costequalgrants assignment_binned || 
qfit costequalgrants assignment_binned [fweight=nobs] if assignment_binned < 2 || 
qfit costequalgrants assignment_binned [fweight=nobs] if assignment_binned >= 2, lpattern(dash) ,
scheme(s1color) ytitle("Cost-equalizing grants", size(large)) xtitle("Net out-migration", size(large))
xlabel(-10(2)14)
xline(2)
legend(off)
;
#delimit cr

restore

*Figure 5

preserve

collapse (mean) pers* ///
(median) outmigration forcing1 (count) nobs=costequalgrants, by(assignment_binned)
qui su nobs
local total = r(sum)
g dens = nobs / `total'
g obs = nobs


*Total
#delimit ;
scatter pers_total assignment_binned || 
qfit pers_total assignment_binned [fweight=nobs] if assignment_binned < 2 || 
qfit pers_total assignment_binned [fweight=nobs] if assignment_binned >= 2, lpattern(dash) ,
scheme(s1color) ytitle("Personnel", size(large)) xtitle("Net out-migration", size(large)) title("Total", size(huge))
xlabel(-10(2)14)
xline(2)
legend(off)
;
#delimit cr

*Administration
#delimit ;
scatter pers_admin assignment_binned || 
qfit pers_admin assignment_binned [fweight=nobs] if assignment_binned < 2 || 
qfit pers_admin assignment_binned [fweight=nobs] if assignment_binned >= 2, lpattern(dash) ,
scheme(s1color) ytitle("Personnel", size(large)) xtitle("Net out-migration", size(large)) title("Administration", size(huge))
xlabel(-10(2)14)
xline(2)
legend(off)
;
#delimit cr

*Child care
#delimit ;
scatter pers_child assignment_binned || 
qfit pers_child assignment_binned [fweight=nobs] if assignment_binned < 2 || 
qfit pers_child assignment_binned [fweight=nobs] if assignment_binned >= 2, lpattern(dash) ,
scheme(s1color) ytitle("Personnel", size(large)) xtitle("Net out-migration", size(large)) title("Child care", size(huge))
xlabel(-10(2)14)
xline(2)
legend(off)
;
#delimit cr

*Schools
#delimit ;
scatter pers_school assignment_binned || 
qfit pers_school assignment_binned [fweight=nobs] if assignment_binned < 2 || 
qfit pers_school assignment_binned [fweight=nobs] if assignment_binned >= 2, lpattern(dash) ,
scheme(s1color) ytitle("Personnel", size(large)) xtitle("Net out-migration", size(large)) title("Schools", size(huge))
xlabel(-10(2)14)
xline(2)
legend(off)
;
#delimit cr

*Elderly care
#delimit ;
scatter pers_elder assignment_binned || 
qfit pers_elder assignment_binned [fweight=nobs] if assignment_binned < 2 || 
qfit pers_elder assignment_binned [fweight=nobs] if assignment_binned >= 2, lpattern(dash) ,
scheme(s1color) ytitle("Personnel", size(large)) xtitle("Net out-migration", size(large)) title("Elderly care", size(huge))
xlabel(-10(2)14)
xline(2)
legend(off)
;
#delimit cr

*Social wefare
#delimit ;
scatter pers_social assignment_binned || 
qfit pers_social assignment_binned [fweight=nobs] if assignment_binned < 2 || 
qfit pers_social assignment_binned [fweight=nobs] if assignment_binned >= 2, lpattern(dash) ,
scheme(s1color) ytitle("Personnel", size(large)) xtitle("Net out-migration", size(large)) title("Social welfare", size(huge))
xlabel(-10(2)14)
xline(2)
legend(off)
;
#delimit cr

*Technical services
#delimit ;
scatter pers_tech assignment_binned || 
qfit pers_tech assignment_binned [fweight=nobs] if assignment_binned < 2 || 
qfit pers_tech assignment_binned [fweight=nobs] if assignment_binned >= 2, lpattern(dash) ,
scheme(s1color) ytitle("Personnel", size(large)) xtitle("Net out-migration", size(large)) title("Technical services", size(huge))
xlabel(-10(2)14)
xline(2)
legend(off)
;
#delimit cr

restore

***

*Figure 6

preserve

collapse (mean) Dforcing1 forcing1 forcing2 forcing3 (count) nobs=costequalgrants, by(assignment_binned)
qui su nobs
g obs = nobs

label variable obs "Number of observations"

drop if obs<40
drop if obs>150

scatter obs assignment_binned, ///
xline(2) scheme(s1color) ytitle("Observations", size(medlarge)) xtitle("Net out-migration", size (medlarge))

*Econometric countepart to Figure 6 (see footnote 30)
reg obs Dforcing1 forcing1
reg obs Dforcing1 forcing1 forcing2
reg obs Dforcing1 forcing1 forcing2 forcing3

restore

***

*Figure 7

preserve

keep if year>=2002

collapse (mean) pers* ///
(median) outmigration forcing1 (count) nobs=costequalgrants, by(assignment_binned)
qui su nobs
local total = r(sum)
g dens = nobs / `total'
g obs = nobs

*Child care
#delimit ;
scatter pers_priv_child assignment_binned || 
qfit pers_priv_child assignment_binned [fweight=nobs] if assignment_binned < 2 || 
qfit pers_priv_child assignment_binned [fweight=nobs] if assignment_binned >= 2, lpattern(dash) ,
scheme(s1color) ytitle("Personnel", size(large)) xtitle("Net out-migration", size(large)) title("Child care", size(huge))
xlabel(-10(2)14)
xline(2)
legend(off)
;
#delimit cr

*Schools
#delimit ;
scatter pers_priv_school assignment_binned || 
qfit pers_priv_school assignment_binned [fweight=nobs] if assignment_binned < 2 || 
qfit pers_priv_school assignment_binned [fweight=nobs] if assignment_binned >= 2, lpattern(dash) ,
scheme(s1color) ytitle("Personnel", size(large)) xtitle("Net out-migration", size(large)) title("Schools", size(huge))
xlabel(-10(2)14)
xline(2)
legend(off)
;
#delimit cr

*Elderly care
#delimit ;
scatter pers_priv_elder assignment_binned || 
qfit pers_priv_elder assignment_binned [fweight=nobs] if assignment_binned < 2 || 
qfit pers_priv_elder assignment_binned [fweight=nobs] if assignment_binned >= 2, lpattern(dash) ,
scheme(s1color) ytitle("Personnel", size(large)) xtitle("Net out-migration", size(large)) title("Elderly care", size(huge))
xlabel(-10(2)14)
xline(2)
legend(off)
;
#delimit cr

*Social wefare
#delimit ;
scatter pers_priv_social assignment_binned || 
qfit pers_priv_social assignment_binned [fweight=nobs] if assignment_binned < 2 || 
qfit pers_priv_social assignment_binned [fweight=nobs] if assignment_binned >= 2, lpattern(dash) ,
scheme(s1color) ytitle("Personnel", size(large)) xtitle("Net out-migration", size(large)) title("Social welfare", size(huge))
xlabel(-10(2)14)
xline(2)
legend(off)
;
#delimit cr

restore

***




