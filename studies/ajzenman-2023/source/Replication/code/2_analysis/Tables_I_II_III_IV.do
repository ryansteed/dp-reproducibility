*------------------------------------------------------------------------------*
* 							Tables I, II, III, IV	 	 		  	   *
*------------------------------------------------------------------------------*
{
cd "$final"
use enusc_OLS, clear
* Labels
label variable lnrate_stock_imm "Log Imm Rate"
label variable del_problema3 "Crime as a, 1st or 2nd, Concern,"
label variable del_afecta3 "Crime as, Impacting, Pers.Life,"
label variable del_calvida3 "Crime, Affecting, Qual-Life,"
label variable del_inseg5 "Feeling, Unsafe, ,"
label variable del_vict "Will be, Victim, ,"
label variable pc_19 "Principal, Component, Summary, Index (PCI)"
label variable del_tend_barrio "Crime is, rising at,Village"
label variable del_tend_com "Crime is, rising at,Munic"
label variable del_tend_pais "Crime is, rising at,Country"
label variable Index_Vivienda "Investment, in Home, Security,"
label variable Index_Vecinos "Neighbors, Security, System,"
label variable del_arma "Owns, Weapon, ,"
label variable pc_20 "Principal, Component, Summary, Index (PCI)"
label variable vict_agreg "Total"
label variable vict_roboviolent "Robbery"
label variable vict_robosorpr "Larceny"
label variable vict_roboviv "Burglary"
label variable vict_hurto "Theft"
label variable vict_lesiones "Assault"
label variable vict_robovehi "MV Theft"

* Table I: Crime Perceptions

local replace "replace"
foreach var in del_problema3 del_afecta3 del_calvida3 del_inseg5 del_vict pc_19{
	replace `var' = 100*`var'
	areg `var' lnrate_stock_imm i.year  edad ismale, absorb(cod_com) vce(cluster cod_com)
	qui summ `var'
	outreg2 using "${Tables}/Table_I.tex", `replace' tex(frag) pdec(3) dec(2) stats(coef se pval) paren(se) bracket(pval) keep(lnrate_stock_imm) ctitle(`: variable label `var'') addstat(Mean DV, `r(mean)') nocons label nonotes 
	local replace "append"
}

* Table II: Crime Trend

local replace "replace"
foreach var in del_tend_barrio del_tend_com del_tend_pais{
	replace `var' = 100*`var'
	areg `var' lnrate_stock_imm i.year  edad ismale, absorb(cod_com) vce(cluster cod_com)
	qui summ `var'
	outreg2 using "${Tables}/Table_II.tex", `replace' tex(frag) pdec(3) dec(2) stats(coef se pval) paren(se) bracket(pval) keep(lnrate_stock_imm) ctitle(`: variable label `var'') addstat(Mean DV, `r(mean)') nocons label nonotes 
	local replace "append"
}

* Table III: Behavioral Reactions

local replace "replace"
foreach var in Index_Vivienda Index_Vecinos del_arma pc_20{
	replace `var' = 100*`var'
	areg `var' lnrate_stock_imm i.year  edad ismale, absorb(cod_com) vce(cluster cod_com)
	qui summ `var'
	outreg2 using "${Tables}/Table_III.tex", `replace' tex(frag) pdec(3) dec(2) stats(coef se pval) paren(se) bracket(pval) keep(lnrate_stock_imm) ctitle(`: variable label `var'') addstat(Mean DV, `r(mean)') nocons label nonotes 
	local replace "append"
}

* Table IV: Victimization

local replace "replace"
foreach var in vict_hurto vict_robosorpr vict_robovehi vict_roboviv vict_lesiones vict_roboviolent vict_agreg{
	replace `var' = 100*`var'
	areg `var' lnrate_stock_imm i.year  edad ismale, absorb(cod_com) vce(cluster cod_com)
	qui summ `var'
	outreg2 using "${Tables}/Table_IV.tex", `replace' tex(frag) pdec(3) dec(2) stats(coef se pval) paren(se) bracket(pval) keep(lnrate_stock_imm) ctitle(`: variable label `var'') addstat(Mean DV, `r(mean)') nocons label nonotes 
	local replace "append"
}


}
