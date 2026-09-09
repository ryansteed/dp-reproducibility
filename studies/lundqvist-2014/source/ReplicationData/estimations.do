
*Change to desired directory:
cd "."

use "finaldata.dta", clear

***

*Table 1: Sumary statistics for main variables

sum pers_total pers_admin pers_child pers_school pers_elder pers_social pers_tech costequalgrants migrationgrant outmigration pop partpop06 partpop7_15 partpop80_ partforeign

***

*Table 2: First-stage estimates

forvalues p=1/3 {

xi: reg costequalgrants Dforcing1 forcing1-forcing`p' i.year, cluster(code)
xi: reg costequalgrants Dforcing1 forcing1-forcing`p' i.year if h15==1, cluster(code)
}

xi: reg costequalgrants Dforcing1 forcing1 i.year if h10==1, cluster(code)
xi: reg costequalgrants Dforcing1 forcing1 i.year if h5==1, cluster(code)

***

*Table 3: Effects of grants on municipal personnel (2SLS estimates)
		
foreach outcome in pers_total pers_admin pers_child pers_school pers_elder pers_social pers_tech {

forvalues p=1/3 {
eststo `outcome'`p': xi: ivreg2 `outcome' (costequalgrants = Dforcing1) forcing1-forcing`p' i.year, cluster(code)
icomp
local AIC`outcome'_full_`p'=r(AIC)
xi: ivreg2 `outcome' (costequalgrants = Dforcing1) forcing1-forcing`p' i.year if h15==1, cluster(code)
icomp
local AIC`outcome'_h15_`p'=r(AIC)
}

xi: ivreg2 `outcome' (costequalgrants = Dforcing1) forcing1 i.year if h10==1, cluster(code)
xi: ivreg2 `outcome' (costequalgrants = Dforcing1) forcing1 i.year if h5==1, cluster(code)

}
*** EDITED by Donna
estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

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

*Table 4: Effects evaluated at hypothetical wage costs

sum expshare*

xi: ivreg2 exp_total (costequalgrants = Dforcing1) forcing1 i.year, cluster(code)
xi: ivreg2 exp_total (costequalgrants = Dforcing1) forcing1-forcing3 i.year if h15==1, cluster(code)
xi: ivreg2 exp_total (costequalgrants = Dforcing1) forcing1 i.year if h10==1, cluster(code)
xi: ivreg2 exp_total (costequalgrants = Dforcing1) forcing1 i.year if h5==1, cluster(code)

xi: ivreg2 exp_admin (costequalgrants = Dforcing1) forcing1-forcing2 i.year, cluster(code)
xi: ivreg2 exp_admin (costequalgrants = Dforcing1) forcing1 i.year if h15==1, cluster(code)
xi: ivreg2 exp_admin (costequalgrants = Dforcing1) forcing1 i.year if h10==1, cluster(code)
xi: ivreg2 exp_admin (costequalgrants = Dforcing1) forcing1 i.year if h5==1, cluster(code)

xi: ivreg2 exp_child (costequalgrants = Dforcing1) forcing1-forcing2 i.year, cluster(code)
xi: ivreg2 exp_child (costequalgrants = Dforcing1) forcing1 i.year if h15==1, cluster(code)
xi: ivreg2 exp_child (costequalgrants = Dforcing1) forcing1 i.year if h10==1, cluster(code)
xi: ivreg2 exp_child (costequalgrants = Dforcing1) forcing1 i.year if h5==1, cluster(code)

xi: ivreg2 exp_school (costequalgrants = Dforcing1) forcing1 i.year, cluster(code)
xi: ivreg2 exp_school (costequalgrants = Dforcing1) forcing1 i.year if h15==1, cluster(code)
xi: ivreg2 exp_school (costequalgrants = Dforcing1) forcing1 i.year if h10==1, cluster(code)
xi: ivreg2 exp_school (costequalgrants = Dforcing1) forcing1 i.year if h5==1, cluster(code)

xi: ivreg2 exp_elder (costequalgrants = Dforcing1) forcing1 i.year, cluster(code)
xi: ivreg2 exp_elder (costequalgrants = Dforcing1) forcing1 i.year if h15==1, cluster(code)
xi: ivreg2 exp_elder (costequalgrants = Dforcing1) forcing1 i.year if h10==1, cluster(code)
xi: ivreg2 exp_elder (costequalgrants = Dforcing1) forcing1 i.year if h5==1, cluster(code)

xi: ivreg2 exp_social (costequalgrants = Dforcing1) forcing1 i.year, cluster(code)
xi: ivreg2 exp_social (costequalgrants = Dforcing1) forcing1-forcing3 i.year if h15==1, cluster(code)
xi: ivreg2 exp_social (costequalgrants = Dforcing1) forcing1 i.year if h10==1, cluster(code)
xi: ivreg2 exp_social (costequalgrants = Dforcing1) forcing1 i.year if h5==1, cluster(code)

xi: ivreg2 exp_tech (costequalgrants = Dforcing1) forcing1-forcing3 i.year, cluster(code)
xi: ivreg2 exp_tech (costequalgrants = Dforcing1) forcing1-forcing2 i.year if h15==1, cluster(code)
xi: ivreg2 exp_tech (costequalgrants = Dforcing1) forcing1 i.year if h10==1, cluster(code)
xi: ivreg2 exp_tech (costequalgrants = Dforcing1) forcing1 i.year if h5==1, cluster(code)

***

*Table 5: Effects when controlling for pre-determined covariates

local controls pop partpop06 partpop7_15 partpop80_ partforeign 

xi: ivreg2 pers_total (costequalgrants = Dforcing1) forcing1 `controls' i.year, cluster(code)
xi: ivreg2 pers_total (costequalgrants = Dforcing1) forcing1-forcing3 `controls' i.year if h15==1, cluster(code)
xi: ivreg2 pers_total (costequalgrants = Dforcing1) forcing1 `controls' i.year if h10==1, cluster(code)
xi: ivreg2 pers_total (costequalgrants = Dforcing1) forcing1 `controls' i.year if h5==1, cluster(code)

xi: ivreg2 pers_admin (costequalgrants = Dforcing1) forcing1-forcing2 `controls' i.year, cluster(code)
xi: ivreg2 pers_admin (costequalgrants = Dforcing1) forcing1 `controls' i.year if h15==1, cluster(code)
xi: ivreg2 pers_admin (costequalgrants = Dforcing1) forcing1 `controls' i.year if h10==1, cluster(code)
xi: ivreg2 pers_admin (costequalgrants = Dforcing1) forcing1 `controls' i.year if h5==1, cluster(code)

xi: ivreg2 pers_child (costequalgrants = Dforcing1) forcing1-forcing2 `controls' i.year, cluster(code)
xi: ivreg2 pers_child (costequalgrants = Dforcing1) forcing1 `controls' i.year if h15==1, cluster(code)
xi: ivreg2 pers_child (costequalgrants = Dforcing1) forcing1 `controls' i.year if h10==1, cluster(code)
xi: ivreg2 pers_child (costequalgrants = Dforcing1) forcing1 `controls' i.year if h5==1, cluster(code)

xi: ivreg2 pers_school (costequalgrants = Dforcing1) forcing1 `controls' i.year, cluster(code)
xi: ivreg2 pers_school (costequalgrants = Dforcing1) forcing1 `controls' i.year if h15==1, cluster(code)
xi: ivreg2 pers_school (costequalgrants = Dforcing1) forcing1 `controls' i.year if h10==1, cluster(code)
xi: ivreg2 pers_school (costequalgrants = Dforcing1) forcing1 `controls' i.year if h5==1, cluster(code)

xi: ivreg2 pers_elder (costequalgrants = Dforcing1) forcing1 `controls' i.year, cluster(code)
xi: ivreg2 pers_elder (costequalgrants = Dforcing1) forcing1 `controls' i.year if h15==1, cluster(code)
xi: ivreg2 pers_elder (costequalgrants = Dforcing1) forcing1 `controls' i.year if h10==1, cluster(code)
xi: ivreg2 pers_elder (costequalgrants = Dforcing1) forcing1 `controls' i.year if h5==1, cluster(code)

xi: ivreg2 pers_social (costequalgrants = Dforcing1) forcing1 `controls' i.year, cluster(code)
xi: ivreg2 pers_social (costequalgrants = Dforcing1) forcing1-forcing3 `controls' i.year if h15==1, cluster(code)
xi: ivreg2 pers_social (costequalgrants = Dforcing1) forcing1 `controls' i.year if h10==1, cluster(code)
xi: ivreg2 pers_social (costequalgrants = Dforcing1) forcing1 `controls' i.year if h5==1, cluster(code)

xi: ivreg2 pers_tech (costequalgrants = Dforcing1) forcing1-forcing3 `controls' i.year, cluster(code)
xi: ivreg2 pers_tech (costequalgrants = Dforcing1) forcing1-forcing2 `controls' i.year if h15==1, cluster(code)
xi: ivreg2 pers_tech (costequalgrants = Dforcing1) forcing1 `controls' i.year if h10==1, cluster(code)
xi: ivreg2 pers_tech (costequalgrants = Dforcing1) forcing1 `controls' i.year if h5==1, cluster(code)

***

*Table 6: Effects on different types of bureaucrats
		
foreach outcome in pers_assistants pers_officials {

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
foreach outcome in pers_assistants pers_officials {
	forvalues p=1/3 {
		display "Full sample, AIC`outcome'_`p'=`AIC`outcome'_full_`p''"
		}
	forvalues p=1/3 {
		display "h=15, AIC`outcome'_`p'=`AIC`outcome'_h15_`p''"
		}
	}

***
