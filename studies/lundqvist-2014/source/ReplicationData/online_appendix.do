
*Change to desired directory:
cd "C:\Lundqvist\Grantseffects\AEJ_EconomicPolicy\Data"

use "finaldata.dta", clear

***

*Table 1: First-stage estimates when controlling for pre-determined covariates

local controls pop partpop06 partpop7_15 partpop80_ partforeign 

forvalues p=1/3 {

xi: reg costequalgrants Dforcing1 forcing1-forcing`p' `controls' i.year, cluster(code)
xi: reg costequalgrants Dforcing1 forcing1-forcing`p' `controls' i.year if h15==1, cluster(code)
}

xi: reg costequalgrants Dforcing1 forcing1 `controls' i.year if h10==1, cluster(code)
xi: reg costequalgrants Dforcing1 forcing1 `controls' i.year if h5==1, cluster(code)


***

*Table 2: First-stage estimates when controlling for municipality fixed effects

xtset code year
sort code year

forvalues p=1/3 {

xi: xtreg costequalgrants Dforcing1 forcing1-forcing`p' i.year, cluster(code) fe
xi: xtreg costequalgrants Dforcing1 forcing1-forcing`p' i.year if h15==1, cluster(code) fe
}

xi: xtreg costequalgrants Dforcing1 forcing1 i.year if h10==1, cluster(code) fe 
xi: xtreg costequalgrants Dforcing1 forcing1 i.year if h5==1, cluster(code) fe

***

*Table 3: Second-stage estimates when controlling for municipality fixed effects
	
foreach outcome in pers_total pers_admin pers_child pers_school pers_elder pers_social pers_tech {

forvalues p=1/3 {
xi: xtivreg2 `outcome' (costequalgrants = Dforcing1) forcing1-forcing`p' i.year, cluster(code) fe
icomp
local AIC`outcome'_full_`p'=r(AIC)
xi: xtivreg2 `outcome' (costequalgrants = Dforcing1) forcing1-forcing`p' i.year if h15==1, cluster(code) fe
icomp
local AIC`outcome'_h15_`p'=r(AIC)
}

xi: xtivreg2 `outcome' (costequalgrants = Dforcing1) forcing1 i.year if h10==1, cluster(code) fe
xi: xtivreg2 `outcome' (costequalgrants = Dforcing1) forcing1 i.year if h5==1, cluster(code) fe

}

*Preferred polynomial = lowest AIC:
foreach outcome in pers_total pers_admin pers_child pers_school pers_elder pers_social pers_tech {
	forvalues p=1/3 {
		display "Full sample, AIC`outcome'_`p'=`AIC`outcome'_full_`p''"
		}
	forvalues p=1/3 {
		display "h=15, AIC`outcome'_`p'=`AIC`outcome'_h15_`p''"
		}
	}
	
***

*Table 4: First-stage estimates with the shorter panel (only years 2002--04)

forvalues p=1/3 {

xi: reg costequalgrants Dforcing1 forcing1-forcing`p' i.year if year>=2002, cluster(code)
xi: reg costequalgrants Dforcing1 forcing1-forcing`p' i.year if h15==1 & year>=2002, cluster(code)
}

xi: reg costequalgrants Dforcing1 forcing1 i.year if h10==1 & year>=2002, cluster(code)
xi: reg costequalgrants Dforcing1 forcing1 i.year if h5==1 & year>=2002, cluster(code)

***

*Table 5: Effects of grants on municipal personnel using the shorter panel (only years 2002--04)
		
foreach outcome in pers_total pers_admin pers_child pers_school pers_elder pers_social pers_tech {

xi: ivreg2 `outcome' (costequalgrants = Dforcing1) forcing1 i.year if year>=2002, cluster(code)
xi: ivreg2 `outcome' (costequalgrants = Dforcing1) forcing1 i.year if h15==1 & year>=2002, cluster(code)
xi: ivreg2 `outcome' (costequalgrants = Dforcing1) forcing1 i.year if h10==1 & year>=2002, cluster(code)

}

***

*Table 6: Effects of grants on personnel in the local public welfare sector employed by a non-profit or for-profit private firm

*foreach outcome in pers_priv_child pers_priv_school pers_priv_elder pers_priv_social {
foreach outcome in pers_priv_child  {

xi: ivreg2 `outcome' (costequalgrants = Dforcing1) forcing1 i.year if year>=2002, cluster(code)

xi: ivreg2 `outcome' (costequalgrants = Dforcing1) forcing1 i.year if h15==1 & year>=2002, cluster(code)

xi: ivreg2 `outcome' (costequalgrants = Dforcing1) forcing1 i.year if h10==1 & year>=2002, cluster(code)

}

***

*Table 7: Effects of grants on private school personnel
	
foreach outcome in pers_priv_school {

forvalues p=1/3 {
xi: ivreg2 `outcome' (costequalgrants = Dforcing1) forcing1-forcing`p' i.year, cluster(code)
icomp
local AIC`outcome'_full_`p'=r(AIC)
xi: ivreg2 `outcome' (costequalgrants = Dforcing1) forcing1-forcing`p' i.year if h15==1, cluster(code)
icomp
local AIC`outcome'_h15_`p'=r(AIC)
}

xi: ivreg2 `outcome' (costequalgrants = Dforcing1) forcing1 i.year if h10==1, cluster(code)
xi: ivreg2 `outcome' (costequalgrants = Dforcing1) forcing1 i.year if h5==1, cluster(code)

}

*Preferred polynomial = lowest AIC:
foreach outcome in pers_priv_school {
	forvalues p=1/3 {
		display "Full sample, AIC`outcome'_`p'=`AIC`outcome'_full_`p''"
		}
	forvalues p=1/3 {
		display "h=15, AIC`outcome'_`p'=`AIC`outcome'_h15_`p''"
		}
	}

***









