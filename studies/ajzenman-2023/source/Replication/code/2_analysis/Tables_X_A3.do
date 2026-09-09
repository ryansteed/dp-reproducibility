*------------------------------------------------------------------------------*
* 							Tables X, A3      			 	 		  	       *
*------------------------------------------------------------------------------*
{
cd "$conf_final"
use homicides_IV, clear

* Labels
label variable deltaimm "$\Delta migr_{mt}$"
label variable dl_homicidios1pc "Log Homicide, Rate, ,"
label variable intmargin_homicidios1 "Homicide, Intensive, Margin,"
label variable extmargin_homicidios1c "Homicide, Extensive, Margin,"
label variable dl_homicidios_chilenos1pc "Log Homicide Rate, (with Chilean, Victim)"
label variable dl_homicidios_nchilenos1pc "Log Homicide Rate, (with Foreigner, Victim)"
label variable dl_homicidios_chilenos2pc "Log Homicide Chilean, (Committed by, Foreigner)"
label variable dl_homicidios_nchilenos2pc "Log Homicide Rate, (Committed by, Foreigner)"
label variable dhomicidios1pc "Homicide, Rate ,"
label variable dhomicidios_chilenos1pc " Homicide Rate, (with Chilean, Victim)"
label variable dhomicidios_nchilenos1pc " Homicide Rate, (with Foreigner, Victim)"
label variable dhomicidios_chilenos2pc "Homicide Rate, (Committed by, Chilean)"
label variable dhomicidios_nchilenos2pc "Homicide Rate, (Committed by, Foreigner)"

* Table XI: Difference Regressions: Homicides (in logs)
local replace "replace"
foreach outcome in dl_homicidios1pc intmargin_homicidios1 extmargin_homicidios1c dl_homicidios_chilenos2pc dl_homicidios_nchilenos2pc{
	reg `outcome' deltaimm age hombre, robust 
	outreg2 using "${Tables}/Table_X.tex", `replace' tex(frag) pdec(3) dec(2) stats(coef se pval) paren(se) bracket(pval) keep(deltaimm) ctitle(`: variable label `outcome'',OLS) nocons label nonotes nor2 
	ivreg2 `outcome' age hombre (deltaimm=deltaimm_instr), robust savefirst
	mat f = e(first)
	scalar F = round(f[4,1],.01)
	scalar pRsq = round(f[3,1],.01)
	qui estimates replay _ivreg2_deltaimm
	scalar b_first = round(r(table)[1,1],.01)
	scalar se_b_first = round(r(table)[2,1],.01)
	local se_b_first= "(se_b_first)"
	outreg2 using "${Tables}/Table_X.tex", append tex(frag) pdec(3) dec(2) stats(coef se pval) paren(se) bracket(pval) keep(deltaimm) ctitle(`: variable label `outcome'',IV) addstat("\$ \widehat{\Delta migr_{mt}} \$", b_first, "\hspace{1cm}", se_b_first, F-stat, F, "Part. \$ R^2 \$", pRsq) nocons label nonotes nor2  
	local replace "append" 
}

* Table A.3: Difference Regressions: Homicides (in levels)
local replace "replace"
foreach outcome in homicidios1pc homicidios_chilenos2pc homicidios_nchilenos2pc{
	reg d`outcome' deltaimm age hombre, robust 
	preserve 
	use homicides_OLS, clear
	qui summ `outcome'	
	restore
	outreg2 using "${Tables}/Table_A3.tex", `replace' tex(frag) pdec(3) dec(2) adec(2) stats(coef se pval) paren(se) bracket(pval) keep(deltaimm) ctitle(`: variable label d`outcome'',OLS) addstat(Mean DV, `r(mean)')  nocons label nonotes nor2 
	ivreg2 d`outcome' age hombre (deltaimm=deltaimm_instr), robust savefirst
	mat f = e(first)
	scalar F = round(f[4,1],.01)
	scalar pRsq = round(f[3,1],.01)
	qui estimates replay _ivreg2_deltaimm
	scalar b_first = round(r(table)[1,1],.01)
	scalar se_b_first = round(r(table)[2,1],.01)
	local se_b_first= "(se_b_first)"
	preserve 
	use homicides_OLS, clear
	qui summ `outcome'	
	restore
	outreg2 using "${Tables}/Table_A3.tex", append tex(frag) pdec(3) dec(2) adec(2) stats(coef se pval) paren(se) bracket(pval) keep(deltaimm) ctitle(`: variable label d`outcome'',IV) addstat(Mean DV, `r(mean)',  "\$ \widehat{\Delta migr_{mt}} \$", b_first, "\hspace{1cm}", se_b_first, F-stat, F, "Part. \$ R^2 \$", pRsq) nocons label nonotes nor2  
	local replace "append" 
}

}