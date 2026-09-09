*------------------------------------------------------------------------------*
* 								Tabla A.12 (Col. 8)			  				   *
*------------------------------------------------------------------------------*
{

cd "$conf_final"
use homicides_IV_haiperven, clear

label variable deltaimm "$\Delta migr_{mt}$"

ivreg2 dl_homicidios1pc age hombre (deltaimm=deltaimm_instr), robust savefirst
mat f = e(first)
scalar F = round(f[4,1],.01)
scalar pRsq = round(f[3,1],.01)
qui estimates replay _ivreg2_deltaimm
scalar b_first = round(r(table)[1,1],.01)
scalar se_b_first = round(r(table)[2,1],.01)
local se_b_first= "(se_b_first)"
preserve 
use homicides_OLS, clear 
qui summ homicidios1pc
restore 
outreg2 using "${Tables}/Table_A12_homicides.tex", replace tex(frag) pdec(3) dec(2) adec(2) stats(coef se pval) paren(se) bracket(pval) keep(deltaimm) ctitle("Log Homicides, Rate, IV") addstat(Mean DV, `r(mean)',  "\$ \widehat{\Delta migr_{mt}} \$", b_first, "\hspace{1cm}", se_b_first, F-stat, F, "Part. \$ R^2 \$", pRsq) nocons label  nonotes nor2  

}
