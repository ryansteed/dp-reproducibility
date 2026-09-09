*------------------------------------------------------------------------------*
* 					Table XI, XII, XIII and A16 (Column 4)			  		   *
*------------------------------------------------------------------------------*

*-----------------------------------------------------------*
* 			Table XIV. Explorations of Channels	 	  		*
*-----------------------------------------------------------*
{

cd "$conf_final"
use channels_OLS_homicides, clear

* Controls with missing values
gen d_miss = (age==.|hombre==.)
replace age=0 if age==.
replace hombre=0 if hombre==.

qui summ homicidios1pc
local DVmean=r(mean)


* Table  Education
qui areg log_homicidios1pc ln_rate_basico ln_rate_comp_basico i.year age hombre d_miss, absorb(cod_com) vce(cluster cod_com)
mat education_homicidios=[e(b)[1,1], sqrt(e(V)[1,1]), r(table)[4,1] \ e(b)[1,2], sqrt(e(V)[2,2]),r(table)[4,2] \ e(N), ., . \ e(r2), ., . \ `DVmean', ., .]


* Table Ethnic Distance - Panel A - Chile
qui areg log_homicidios1pc lnrate_stock_imm imm_highdistance high_distance i.year age hombre d_miss, absorb(cod_com) vce(cluster cod_com)
scalar p1=r(table)[4,1]
scalar p2=r(table)[4,2] 
qui lincom lnrate_stock_imm + imm_highdistance
mat etnia_homicidios=[e(b)[1,1], sqrt(e(V)[1,1]), p1 \ e(b)[1,2], sqrt(e(V)[2,2]), p2 \ r(estimate), r(se), r(p) \ e(N), ., . \ e(r2), ., . \ `DVmean', ., .]


* Table Media
qui areg log_homicidios1pc lnrate_stock_imm i.year age hombre d_miss if above_medianMED==0, absorb(cod_com) vce(cluster cod_com)
mat media1homicidios=[e(b)[1,1], sqrt(e(V)[1,1]), r(table)[4,1] \ e(N), ., . \ e(r2), ., . \ `DVmean', ., .]

qui areg log_homicidios1pc lnrate_stock_imm i.year age hombre d_miss if above_medianMED==1, absorb(cod_com) vce(cluster cod_com)
mat media2homicidios=[e(b)[1,1], sqrt(e(V)[1,1]), r(table)[4,1] \ e(N), ., . \ e(r2), ., . \ `DVmean', ., .]


* Tables XI and XIII
mat education = education_homicidios
frmttable using "$Tables\Table_XI_homicides.tex", tex fr statmat(education) substat(2) ctitles("", "Log Homicide" \ "", "Rate") rtitles("Log Imm Rate (Low Skilled)" \ ""\ "" \ "Log Imm Rate (High Skilled)" \ "" \ "" \ "Observations" \ ""\ "" \ "R-squared" \ ""\ "" \ "Mean DV") replace sdec(2\2\3\2\2\3\0\0\0\2\2\2\2\2\2) a4

mat media = media1homicidios,media2homicidios
frmttable using "$Tables\Table_XIII_homicides.tex", tex fr statmat(media) substat(2) ctitles("", "Log Homicide" \ "", "Rate"\"", "Low", "High"\"", "Media","Media") rtitles("Log Imm Rate" \ ""\ "" \ "Observations" \ ""\ "" \ "R-squared" \ ""\ "" \ "Mean DV" \ "") replace sdec(2\2\3\0\0\0\2\2\2\2\2\2) a4


* Table XII - Ethnic Distance - Panel B - Europe
use channels_OLS2_homicides, clear
* Controls with missing values
gen d_miss = (age==.|hombre==.)
replace age=0 if age==.
replace hombre=0 if hombre==.

qui summ homicidios1pc
local DVmean=r(mean)

qui areg log_homicidios1pc lnrate_stock_imm imm_highdistance high_distance i.year age hombre d_miss, absorb(cod_com) vce(cluster cod_com)
scalar p1=r(table)[4,1]
scalar p2=r(table)[4,2]
qui lincom lnrate_stock_imm + imm_highdistance
mat etnia2_homicidios=[e(b)[1,1], sqrt(e(V)[1,1]), p1 \ e(b)[1,2], sqrt(e(V)[2,2]), p2 \ r(estimate), r(se), r(p) \ e(N), ., . \ e(r2), ., . \ `DVmean', ., .]


* Table XII
mat etnia = J(1,3,.)\etnia_homicidios\J(1,3,.)\etnia2_homicidios
frmttable using "$Tables\Table_XII_homicides.tex", tex fr statmat(etnia) substat(2) ctitles("", "Log Homicide" \ "", "Rate") rtitles("Panel A: Ethnic Distance - Chile"\""\""\"(a) = Log Imm Rate (Low Distance)" \ ""\ "" \"(b) = Log Imm Rate*High Distance"  \""\ "" \ "(a) + (b) = Log Imm Rate (High Distance)"  \ ""\ "" \"Observations" \ ""\ ""  \ "R-squared" \ ""\ "" \ "Mean DV"\""\ "" \"Panel B: Ethnic Distance - Europe"\""\""\"(a) = Log Imm Rate (Low Distance)" \ ""\ "" \"(b) = Log Imm Rate*High Distance"  \""\ "" \ "(a) + (b) = Log Imm Rate (High Distance)"  \ ""\ "" \"Observations" \ ""\ ""  \ "R-squared" \ ""\ "" \ "Mean DV"   ) replace sdec(0\0\0\2\2\3\2\2\3\2\2\3\0\0\0\2\2\2\2\2\2\0\0\0\2\2\3\2\2\3\2\2\3\0\0\0\2\2\2\2\2\2) a4


* Table A16 - Demographic Composition 
use channels_OLS3_homicides, clear

* Controls with missing values
gen d_miss = (age==.|hombre==.)
replace age=0 if age==.
replace hombre=0 if hombre==.

qui summ homicidios1pc
local DVmean=r(mean)
qui areg log_homicidios1pc ln_rate_mujer_joven ln_rate_mujer_nojoven ln_rate_hombre_joven ln_rate_hombre_nojoven i.year age hombre d_miss, absorb(cod_com) vce(cluster cod_com)
mat gender_age_homicidios=[e(b)[1,1], sqrt(e(V)[1,1]), r(table)[4,1] \ e(b)[1,2], sqrt(e(V)[2,2]), r(table)[4,2] \ e(b)[1,3], sqrt(e(V)[3,3]), r(table)[4,3] \ e(b)[1,4], sqrt(e(V)[4,4]), r(table)[4,4] \ e(N), ., . \ e(r2), . , .\ `DVmean', ., .]


mat gender_age = gender_age_homicidios
frmttable using "$Tables\Table_A16_homicides.tex", tex fr statmat(gender_age) substat(2) ctitles("", "Log Homicide" \ "", "Rate")  rtitles("Log Imm Rate (young women)" \ "" \ "" \"Log Imm Rate (non-young women)" \ "" \"" \"Log Imm Rate (young men)" \ "" \ "" \"Log Imm Rate (non-young men)" \ "" \"" \"Observations" \ "" \ "" \"R-squared" \ "" \ "" \"Mean DV" ) replace sdec(2\2\3\2\2\3\2\2\3\2\2\3\0\0\0\2\0\0\2) a4

}