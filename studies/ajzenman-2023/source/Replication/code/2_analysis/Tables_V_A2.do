*------------------------------------------------------------------------------*
* 							Tables V and A.2				 	 		  	   *
*------------------------------------------------------------------------------*
{
cd "$conf_final"
use homicides_OLS, clear

* Labels
label variable lnrate_stock_imm "Log Imm Rate"
label variable log_homicidios1pc "Log Homicide, Rate, ,"
label variable intmarginhomicidios1 "Homicide, Intensive, Margin,"
label variable extmargin_homicidios1 "Homicide, Extensive, Margin,"
label variable log_homicidios_chilenos1pc "Log Homicide Rate, (with Chilean, Victim),"
label variable log_homicidios_nchilenos1pc "Log Homicide Rate, (with Foreigner, Victim),"
label variable log_homicidios_chilenos2pc "Log Homicide Rate, (Committed by, Chilean),"
label variable log_homicidios_nchilenos2pc "Log Homicide Rate, (Committed by, Foreigner),"
label variable homicidios1pc "Homicide, Rate ,"
label variable homicidios_chilenos1pc " Homicide Rate, (with Chilean, Victim)"
label variable homicidios_nchilenos1pc " Homicide Rate, (with Foreigner, Victim)"
label variable homicidios_chilenos2pc "Homicide Rate, (Committed by, Chilean)"
label variable homicidios_nchilenos2pc "Homicide Rate, (Committed by, Foreigner)"



* Controls with missing values
gen d_miss = (age==.|hombre==.)
replace age=0 if age==.
replace hombre=0 if hombre==.


* Table V: Homicides (in Logs)
local replace "replace"
foreach var in log_homicidios1pc intmarginhomicidios1 extmargin_homicidios1 log_homicidios_chilenos2pc log_homicidios_nchilenos2pc{
	areg `var' lnrate_stock_imm i.year age hombre d_miss, absorb(cod_com) vce(cluster cod_com)
	outreg2 using "${Tables}/Table_V.tex", `replace' tex(frag) pdec(3) dec(2) stats(coef se pval) paren(se) bracket(pval) keep(lnrate_stock_imm) ctitle(`: variable label `var'') nocons label nonotes 
	local replace "append"
}
* Means of dependent variables
sum homicidios1pc intmarginhomicidios1 extmargin_homicidios1 homicidios_chilenos2pc homicidios_nchilenos2pc


* Table A.2: Homicides (in levels)
local replace "replace"
foreach var in homicidios1pc homicidios_chilenos2pc homicidios_nchilenos2pc{
	areg `var' lnrate_stock_imm i.year age hombre d_miss, absorb(cod_com) vce(cluster cod_com)
	qui summ `var'
	outreg2 using "${Tables}/Table_A2.tex", `replace' tex(frag) pdec(3) dec(2) adec(2) stats(coef se pval) paren(se) bracket(pval) keep(lnrate_stock_imm) ctitle(`: variable label `var'') addstat(Mean DV, `r(mean)') nocons label nonotes 
	local replace "append"
}

}