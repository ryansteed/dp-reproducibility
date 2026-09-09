*------------------------------------------------------------------------------*
* 								Tabla A.9 (Column 2)		  				   *
*------------------------------------------------------------------------------*

{
cd "$final"
use enusc_IV, clear

* 2SLS - Cost-weighted sum of crimes (Aaron Chalfin and Justin McCrary)
replace vict_agreg_costweight = 100*vict_agreg_costweight
ivreg2 vict_agreg_costweight age hombre (deltaimm=deltaimm_instr), robust savefirst
scalar obs = e(N)
mat iv_vict_agreg_costweight=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]
estimates replay _ivreg2_deltaimm	// first stage regression
mat list e(first)
mat vict_agreg_costweight_1ststage=[r(table)[1,1], r(table)[2,1]]
mat vict_agreg_costweight_fstat=[e(first)[4,1]]
mat vict_agreg_costweight_r2part=[e(first)[3,1]]

* 2SLS - Cost-weighted sum of crimes, including Homicide (Aaron Chalfin and Justin McCrary)
merge 1:1 cod_com using "$conf_final/homicides_IV", keepus(deltahomicidios1)
drop _merge

gen vict_agreg_costweight2 = (270/963)*vict_agreg_costweight+(693/963)*100*(deltahomicidios1/population)	// Ahora, el costo total per capita ya no es mas 270, sino que es 963
ivreg2 vict_agreg_costweight2 age hombre (deltaimm=deltaimm_instr), robust savefirst
mat iv_vict_agreg_costweight2=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]
estimates replay _ivreg2_deltaimm	// first stage regression
mat list e(first)
mat vict_agreg_costweight2_1ststage=[r(table)[1,1], r(table)[2,1]]
mat vict_agreg_costweight2_fstat=[e(first)[4,1]]
mat vict_agreg_costweight2_r2part=[e(first)[3,1]]


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

merge 1:1 cod_com year using "$conf_final/homicides_OLS", keepus(homicidios1)
drop _merge

gen crimen_rate=crimenes/population*100000
gen vict_agreg_costweight2=100*((270/963)*vict_agreg_costweight+(693/963)*(homicidios1/population))
replace vict_agreg_costweight = 100*vict_agreg_costweight

* Mean DV and observations
mat meansDV = J(1,9,.)
mat observations = J(1,9,.)
local i = 1
foreach var in vict_agreg_costweight vict_agreg_costweight2 crimen_rate{
sum `var'
mat meansDV[1,`i']=`r(mean)'
mat observations[1,`i']= obs
local i = `i'+3
}

mat robust_crime = iv_vict_agreg_costweight, iv_vict_agreg_costweight2, iv_ln_crimenes_pop\meansDV\observations

frmttable using "$Tables\Table_A9.tex", tex frag replace statmat(robust_crime) substat(2) ctitles("", "Cost-weighted", "Cost-weighted", "Log of"\"", "Crimes Index", "Crimes Index", "Crime Rate"\"","","Including Homicides","") rtitles("$\Delta migr_{mt}$"\"" \"" \"Mean DV"\"" \"" \"Obs") sdec(2\2\3) a4

mat firststage = J(1,6,.)\vict_agreg_costweight_1ststage, vict_agreg_costweight2_1ststage, ln_crimenes_pop_1ststage
frmttable using "$Tables\Table_A9.tex", tex fr statmat(firststage) substat(1) rtitles("First Stage Regression" \ "" \ "\$ \widehat{\Delta migr_{mt}} \$" \ "") append replace sdec(2\2) a4

mat fstat =  vict_agreg_costweight_fstat , vict_agreg_costweight2_fstat, ln_crimenes_pop_fstat
frmttable using "$Tables\Table_A9.tex", tex fr statmat(fstat) substat(0) rtitles("F-Stat") append replace sdec(2) a4

mat r2part =  vict_agreg_costweight_r2part , vict_agreg_costweight2_r2part , ln_crimenes_pop_r2part
frmttable using "$Tables\Table_A9.tex", tex fr statmat(r2part) substat(0) rtitles("Part. R2") append replace sdec(2) a4

}