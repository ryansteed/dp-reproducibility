*------------------------------------------------------------------------------*
* 						Tablas A.10, A.11, A.12 (Cols. 1-7)	  				   *
*------------------------------------------------------------------------------*
{

cd "$final"
use enusc_IV_haiperven, clear

* Labels
label variable deltaimm "$\Delta migr_{mt}$"

label variable Index_Vivienda "Investment, in Home, Security, Index"
label variable Index_Vecinos "Neighbors, Security, System, Index"
label variable del_arma "Owns, a Weapon, , "
label variable pc_20 "Reactions, Summary, Index,"

label variable del_problema3 "Crime as a, 1st or 2nd, Concern,"
label variable del_afecta3 "Crime as, Impacting, Pers.Life,"
label variable del_calvida3 "Crime, Affecting, Qual-Life,"
label variable del_inseg5 "Feeling, Unsafe, ,"
label variable del_vict "Will be, Victim, ,"
label variable pc_19 "Concerns, Summary, Index,"
label variable del_tend_barrio "Crime, is rising, (neigh.),"
label variable del_tend_com "Crime, is rising, (munic.),"
label variable del_tend_pais "Crime, is rising, (country),"

label variable vict_roboviolent "Robbery,"
label variable vict_robosorpr "Larceny,"
label variable vict_roboviv "Burglary,"
label variable vict_hurto "Theft,"
label variable vict_lesiones "Assault,"
label variable vict_robovehi "MV Theft,"
label variable vict_agreg "Total, Crime"

* Difference Regressions


* Table A.10
local replace "replace"
foreach outcome in del_problema3 del_afecta3 del_calvida3 del_inseg5 del_vict pc_19 del_tend_barrio del_tend_com del_tend_pais{
	replace `outcome' = 100*`outcome'
	ivreg2 `outcome' age hombre (deltaimm=deltaimm_instr), robust savefirst
	mat f = e(first)
	scalar F = round(f[4,1],.01)
	scalar pRsq = round(f[3,1],.01)
	qui estimates replay _ivreg2_deltaimm
	scalar b_first = round(r(table)[1,1],.01)
	scalar se_b_first = round(r(table)[2,1],.01)
	local se_b_first= "(se_b_first)"
	preserve 
	use enusc_OLS, clear
	replace `outcome' = 100*`outcome'
	qui summ `outcome'
	restore
	outreg2 using "${Tables}/Table_A10.tex", `replace' tex(frag) pdec(3) dec(2) adec(2) stats(coef se pval) paren(se) bracket(pval) keep(deltaimm) ctitle(`: variable label `outcome'',IV) addstat(Mean DV, `r(mean)',  "\$ \widehat{\Delta migr_{mt}} \$", b_first, "\hspace{1cm}", se_b_first, F-stat, F, "Part. \$ R^2 \$", pRsq) nocons label  nonotes nor2  
	local replace "append" 
}

* Table A.11
local replace "replace"
foreach outcome in Index_Vivienda Index_Vecinos del_arma pc_20{
	replace `outcome' = 100*`outcome'
	ivreg2 `outcome' age hombre (deltaimm=deltaimm_instr), robust savefirst
	mat f = e(first)
	scalar F = round(f[4,1],.01)
	scalar pRsq = round(f[3,1],.01)
	qui estimates replay _ivreg2_deltaimm
	scalar b_first = round(r(table)[1,1],.01)
	scalar se_b_first = round(r(table)[2,1],.01)
	local se_b_first= "(se_b_first)"
	preserve 
	use enusc_OLS, clear
	replace `outcome' = 100*`outcome'
	qui summ `outcome'
	restore
	outreg2 using "${Tables}/Table_A11.tex", `replace' tex(frag) pdec(3) dec(2) adec(2) stats(coef se pval) paren(se) bracket(pval) keep(deltaimm) ctitle(`: variable label `outcome'',IV) addstat(Mean DV, `r(mean)',  "\$ \widehat{\Delta migr_{mt}} \$", b_first, "\hspace{1cm}", se_b_first, F-stat, F, "Part. \$ R^2 \$", pRsq) nocons label  nonotes nor2  
	local replace "append" 
}

* Table A.12
local replace "replace"
foreach outcome in vict_hurto vict_robosorpr vict_robovehi vict_roboviv vict_lesiones vict_roboviolent vict_agreg{
	replace `outcome' = 100*`outcome'
	ivreg2 `outcome' age hombre (deltaimm=deltaimm_instr), robust savefirst
	mat f = e(first)
	scalar F = round(f[4,1],.01)
	scalar pRsq = round(f[3,1],.01)
	qui estimates replay _ivreg2_deltaimm
	scalar b_first = round(r(table)[1,1],.01)
	scalar se_b_first = round(r(table)[2,1],.01)
	local se_b_first= "(se_b_first)"
	preserve 
	use enusc_OLS, clear
	replace `outcome' = 100*`outcome'
	qui summ `outcome'
	restore
	outreg2 using "${Tables}/Table_A12.tex", `replace' tex(frag) pdec(3) dec(2) adec(2) stats(coef se pval) paren(se) bracket(pval) keep(deltaimm) ctitle(`: variable label `outcome'',IV) addstat(Mean DV, `r(mean)',  "\$ \widehat{\Delta migr_{mt}} \$", b_first, "\hspace{1cm}", se_b_first, F-stat, F, "Part. \$ R^2 \$", pRsq) nocons label  nonotes nor2  
	local replace "append" 
}

}
