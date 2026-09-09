*------------------------------------------------------------------------------*
* 							Tabla A.9 (Columns 1 and 3)		  				   *
*------------------------------------------------------------------------------*

{
cd "$final"
use enusc_IV, clear

* 2SLS - Cost-weighted sum of crimes (Aaron Chalfin and Justin McCrary)
replace vict_agreg_costweight = 100*vict_agreg_costweight
ivreg2 vict_agreg_costweight age hombre (deltaimm=deltaimm_instr), robust savefirst
mat iv_vict_agreg_costweight=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]
estimates replay _ivreg2_deltaimm	// first stage regression
mat list e(first)
mat vict_agreg_costweight_1ststage=[r(table)[1,1], r(table)[2,1]]
mat vict_agreg_costweight_fstat=[e(first)[4,1]]
mat vict_agreg_costweight_r2part=[e(first)[3,1]]

* 2SLS - Suma de Crimenes a nivel comuna
ivreg2 ln_crimenes_pop age hombre (deltaimm=deltaimm_instr), robust savefirst
mat iv_ln_crimenes_pop=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]
estimates replay _ivreg2_deltaimm	// first stage regression
mat list e(first)
mat ln_crimenes_pop_1ststage=[r(table)[1,1], r(table)[2,1]]
mat ln_crimenes_pop_fstat=[e(first)[4,1]]
mat ln_crimenes_pop_r2part=[e(first)[3,1]]

* Compute Mean DV en niveles
use enusc_OLS, clear
collapse (sum) crimenes (mean) vict_agreg_costweight, by(cod_com year)
merge m:1 cod_com using "$rawdata/population"
keep if _merge==3
drop _merge

gen crimen_rate=crimenes/population*100000
replace vict_agreg_costweight = 100*vict_agreg_costweight

mat meansDV = J(1,6,.)
local i = 1
foreach var in vict_agreg_costweight crimen_rate{
sum `var'
mat meansDV[1,`i']=`r(mean)'
local i = `i'+3
}

mat robust_crime = iv_vict_agreg_costweight, iv_ln_crimenes_pop\meansDV

*frmttable using "$Tables\Table_A7_Cols1and3.tex", tex frag replace statmat(robust_crime) substat(2) ctitles("", "Cost-weighted", "Log of"\"", "Crimes Index", "Crime Rate") rtitles("$\Delta migr_{mt}$"\"" \"" \"Mean DV") sdec(2\2\3) a4

*mat firststage = J(1,4,.)\vict_agreg_costweight_1ststage, ln_crimenes_pop_1ststage
*frmttable using "$Tables\Table_A7_Cols1and3.tex", tex fr statmat(firststage) substat(1) rtitles("First Stage Regression" \ "" \ "\$ \widehat{\Delta migr_{mt}} \$" \ "") append replace sdec(2\2) a4

*mat fstat =  vict_agreg_costweight_fstat , ln_crimenes_pop_fstat
*frmttable using "$Tables\Table_A7_Cols1and3.tex", tex fr statmat(fstat) substat(0) rtitles("F-Stat") append replace sdec(2) a4

*mat r2part =  vict_agreg_costweight_r2part , ln_crimenes_pop_r2part
*frmttable using "$Tables\Table_A7_Cols1and3.tex", tex fr statmat(r2part) substat(0) rtitles("Part. R2") append replace sdec(2) a4
}