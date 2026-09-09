*------------------------------------------------------------------------------*
* 								Table A5 (Columns 1-3)	 	 		  	   *
*------------------------------------------------------------------------------*
{

cd "$final"
use enusc_IV, clear 

label variable deltaimm "$\Delta migr_{mt}$"
label variable vict_agreg "Total, Crime"
label variable pc_19 "Concerns Summary, Index"
label variable pc_20 "Reactions Summary, Index"

foreach var in vict_agreg pc_19 pc_20 {
replace `var'=100*`var'
}

local replace "replace"
foreach outcome in vict_agreg pc_19 pc_20 {
	
	weakiv ivreg2 `outcome' age hombre (deltaimm=deltaimm_instr), robust savefirst level(95) arlevel(95) estadd
	local AR_CI=e(ar_cset)
	local AR_CI=subinstr("`AR_CI'", " ", "",.)
	local AR_CI=subinstr("`AR_CI'", ",", " ; ",.)
	di "`AR_CI'"
	mat f = e(first)
	scalar F = f[4,1]
	scalar pRsq = f[3,1]
	
	preserve 
	use enusc_OLS, clear
	replace `outcome'=100*`outcome'
	qui summ `outcome'
	restore
	
	outreg2 using "${Tables}/Table_A5.tex", `replace' tex(fragment) pdec(3) dec(2) adec(2) ctitle(`: variable label `outcome'') nocons keep(deltaimm) addstat(First stage F stat, F, Partial R sq, pRsq, Mean DV, `r(mean)') addtext(AR CI, `AR_CI') label  nonotes nor2
	local replace "append"

}


}