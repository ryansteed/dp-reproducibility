*------------------------------------------------------------------------------*
* 								Table A5 (Column 4)		 	 		  	   *
*------------------------------------------------------------------------------*
{

cd "$conf_final"
use homicides_IV, clear 

label variable deltaimm "$\Delta migr_{mt}$"
label variable dl_homicidios1pc "Log Homicide, Rate"


local replace "replace"
foreach outcome in dl_homicidios1pc{
	
	weakiv ivreg2 `outcome' age hombre (deltaimm=deltaimm_instr), robust savefirst level(95) arlevel(95) estadd
	local AR_CI=e(ar_cset)
	local AR_CI=subinstr("`AR_CI'", " ", "",.)
	local AR_CI=subinstr("`AR_CI'", ",", " ; ",.)
	di "`AR_CI'"
	mat f = e(first)
	scalar F = f[4,1]
	scalar pRsq = f[3,1]

	preserve 
	use homicides_OLS, clear
	qui summ homicidios1pc
	restore
	
	outreg2 using "${Tables}/Table_A5_homicides.tex", `replace' tex(fragment) pdec(3) dec(2) adec(2) ctitle(`: variable label `outcome'') nocons keep(deltaimm) addstat(First stage F stat, F, Partial R sq, pRsq, Mean DV, `r(mean)') addtext(AR CI, `AR_CI') label  nonotes nor2
	local replace "append"

}


}