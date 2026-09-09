*------------------------------------------------------------------------------*
* 					Table XI, XII, XIII and A16 (Columns 1-3)		  		   *
*------------------------------------------------------------------------------*




cd "$final"
use channels_OLS, clear

* Genero la matriz
foreach outcome in vict_agreg pc_19 pc_20{
	replace `outcome'=100*`outcome'
	qui summ `outcome'
	local DVmean=r(mean)
	
	
	* Table XI - Education
	qui areg `outcome' ln_rate_basico ln_rate_comp_basico i.year edad ismale i.year#c.bas_`outcome', absorb(cod_com) vce(cluster cod_com)
	mat education_`outcome'=[e(b)[1,1], sqrt(e(V)[1,1]), r(table)[4,1] \ e(b)[1,2], sqrt(e(V)[2,2]),r(table)[4,2] \ e(N), ., . \ e(r2), ., . \ `DVmean', ., .]
	
	
	* Table XII - Ethnic Distance - Panel A - Chile
	qui areg `outcome' lnrate_stock_imm imm_highdistance high_distance i.year edad ismale i.year#c.bas_`outcome', absorb(cod_com) vce(cluster cod_com)
	scalar p1=r(table)[4,1]
	scalar p2=r(table)[4,2] 
	qui lincom lnrate_stock_imm + imm_highdistance
	mat etnia_`outcome'=[e(b)[1,1], sqrt(e(V)[1,1]), p1 \ e(b)[1,2], sqrt(e(V)[2,2]), p2 \ r(estimate), r(se), r(p) \ e(N), ., . \ e(r2), ., . \ `DVmean', ., .]
	
	
	* Table XIII - Media
	qui areg `outcome' lnrate_stock_imm i.year edad ismale i.year#c.bas_`outcome' if above_medianMED==0, absorb(cod_com) vce(cluster cod_com)
	mat media1`outcome'=[e(b)[1,1], sqrt(e(V)[1,1]), r(table)[4,1] \ e(N), ., .\ e(r2), ., .\ `DVmean', ., .]

	eststo: areg `outcome' lnrate_stock_imm i.year edad ismale i.year#c.bas_`outcome' if above_medianMED==1, absorb(cod_com) vce(cluster cod_com)
	mat media2`outcome'=[e(b)[1,1], sqrt(e(V)[1,1]), r(table)[4,1] \ e(N), ., . \ e(r2), ., . \ `DVmean', ., .]
	
}
estout * using "../../../../results/table3.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace


* Tables XI and XIII
mat education = education_pc_19,education_pc_20,education_vict_agreg
frmttable using "../../$Tables\Table_XI.tex", tex fr statmat(education) substat(2) ctitles("", "Crime-related", "Crime-prev.", "Total" \ "", "Concerns", "Behavioral", "Crime"\"","","Reactions","") rtitles("Log Imm Rate (Low Skilled)" \ ""\ "" \ "Log Imm Rate (High Skilled)" \ "" \ "" \ "Observations" \ ""\ "" \ "R-squared" \ ""\ "" \ "Mean DV") replace sdec(2\2\3\2\2\3\0\0\0\2\2\2\2\2\2) a4

mat media = media1pc_19,media2pc_19,media1pc_20,media2pc_20,media1vict_agreg,media2vict_agreg
frmttable using "../../$Tables\Table_XIII.tex", tex fr statmat(media) substat(2) ctitles("", "Crime-related", "", "Crime-prev.", "", "Total", "" \ "", "Concerns", "", "Behavioral","", "Crime"\"","","","Reactions","",""\"", "Low", "High","Low", "High","Low", "High"\"", "Media","Media","Media","Media","Media","Media") rtitles("Log Imm Rate" \ ""\ "" \ "Observations" \ ""\ "" \ "R-squared" \ ""\ "" \ "Mean DV" \ "") replace sdec(2\2\3\0\0\0\2\2\2\2\2\2) a4


* Table XII - Ethnic Distance - Panel B - Europe
use channels_OLS2, clear

* Genero la matriz
foreach outcome in vict_agreg pc_19 pc_20{
	replace `outcome'=100*`outcome'
	qui summ `outcome'
	local DVmean=r(mean) 
	
	* Etnias
	qui areg `outcome' lnrate_stock_imm imm_highdistance high_distance i.year edad ismale, absorb(cod_com) vce(cluster cod_com)
	scalar p1=r(table)[4,1]
	scalar p2=r(table)[4,2]  
	qui lincom lnrate_stock_imm + imm_highdistance
	mat etnia2_`outcome'=[e(b)[1,1], sqrt(e(V)[1,1]), p1 \ e(b)[1,2], sqrt(e(V)[2,2]), p2 \ r(estimate), r(se), r(p) \ e(N), ., . \ e(r2), ., . \ `DVmean', ., .]
		
}


* Table XV
mat etnia = J(1,9,.)\etnia_pc_19,etnia_pc_20,etnia_vict_agreg\J(1,9,.)\etnia2_pc_19,etnia2_pc_20,etnia2_vict_agreg
frmttable using "../../$Tables\Table_XII.tex", tex fr statmat(etnia) substat(2) ctitles("", "Crime-related", "Crime-prev.",  "Total"\ "", "Concerns",  "Behavioral", "Crime"\"","","Reactions","") rtitles("Panel A: Ethnic Distance - Chile"\""\""\"(a) = Log Imm Rate (Low Distance)" \ ""\ "" \"(b) = Log Imm Rate*High Distance"  \""\ "" \ "(a) + (b) = Log Imm Rate (High Distance)"  \ ""\ "" \"Observations" \ ""\ ""  \ "R-squared" \ ""\ "" \ "Mean DV"\""\ "" \"Panel B: Ethnic Distance - Europe"\""\""\"(a) = Log Imm Rate (Low Distance)" \ ""\ "" \"(b) = Log Imm Rate*High Distance"  \""\ "" \ "(a) + (b) = Log Imm Rate (High Distance)"  \ ""\ "" \"Observations" \ ""\ ""  \ "R-squared" \ ""\ "" \ "Mean DV"   ) replace sdec(0\0\0\2\2\3\2\2\3\2\2\3\0\0\0\2\2\2\2\2\2\0\0\0\2\2\3\2\2\3\2\2\3\0\0\0\2\2\2\2\2\2) a4


* Table A16 - Demographic Composition 

use channels_OLS3, clear

foreach outcome in vict_agreg pc_19 pc_20{
	replace `outcome'=100*`outcome'
	qui summ `outcome'
	local DVmean=r(mean)
	
	qui areg `outcome' ln_rate_mujer_joven ln_rate_mujer_nojoven ln_rate_hombre_joven ln_rate_hombre_nojoven i.year edad ismale i.year#c.bas_`outcome', absorb(cod_com) vce(cluster cod_com)
	mat gender_age_`outcome'=[e(b)[1,1], sqrt(e(V)[1,1]), r(table)[4,1] \ e(b)[1,2], sqrt(e(V)[2,2]), r(table)[4,2] \ e(b)[1,3], sqrt(e(V)[3,3]), r(table)[4,3] \ e(b)[1,4], sqrt(e(V)[4,4]), r(table)[4,4] \ e(N), ., . \ e(r2), . , .\ `DVmean', ., .]
	
}


mat gender_age = gender_age_pc_19,gender_age_pc_20,gender_age_vict_agreg
frmttable using "../../$Tables\Table_A16.tex", tex fr statmat(gender_age) substat(2) ctitles("", "Crime-related", "Crime-prev.", "Total Crime"\ "", "Concerns", "Behavioral ", ""\"","","Reactions","","")  rtitles("Log Imm Rate (young women)" \ "" \ "" \"Log Imm Rate (non-young women)" \ "" \"" \"Log Imm Rate (young men)" \ "" \ "" \"Log Imm Rate (non-young men)" \ "" \"" \"Observations" \ "" \ "" \"R-squared" \ "" \ "" \"Mean DV" ) replace sdec(2\2\3\2\2\3\2\2\3\2\2\3\0\0\0\2\0\0\2) a4

cd "../.."