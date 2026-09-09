*------------------------------------------------------------------------------*
* 						Tablas A.6, A.7 and A.8 (Panel A)			  		   *
*------------------------------------------------------------------------------*

{
cd "$final"
use enusc_IV, clear

replace deltalevel=deltalevel/100000

foreach var in del_problema3 del_afecta3 del_calvida3 del_inseg5 del_vict pc_19 del_tend_barrio del_tend_com del_tend_pais Index_Vivienda Index_Vecinos del_arma pc_20 vict_agreg vict_roboviolent vict_robosorpr vict_roboviv vict_hurto vict_lesiones vict_robovehi{
	replace `var'=100*`var'
}

* Crime Perceptions

foreach w in fact_pers{

local j = 0
foreach var in del_problema3 del_afecta3 del_calvida3 del_inseg5 del_vict pc_19{
	
	local j = 1+`j'
	ivreg2 `var' age hombre (deltaimm=deltaimm_instr), robust savefirst
	mat crime_percep_`j'=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]
	
	local j = 1+`j'
	ivreg2 `var' age hombre (deltaimm=deltaimm_instr) [aw=`w'], robust savefirst
	mat crime_percep_`j'=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]
	
	local j = 1+`j'
	ivreg2 `var' age hombre (deltalevel=deltaimm_instr), robust savefirst
	mat crime_percep_`j'=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]
	
	local j = 1+`j'
	ivreg2 `var' age hombre (deltalevel=deltaimm_instr) [aw=`w'], robust savefirst
	mat crime_percep_`j'=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]

}

mat crime_percep = crime_percep_1,crime_percep_2,crime_percep_3,crime_percep_4\crime_percep_5,crime_percep_6,crime_percep_7,crime_percep_8\crime_percep_9,crime_percep_10, crime_percep_11,crime_percep_12\crime_percep_13,crime_percep_14,crime_percep_15,crime_percep_16\crime_percep_17,crime_percep_18,crime_percep_19,crime_percep_20\crime_percep_21,crime_percep_22,crime_percep_23,crime_percep_24


* Crime Trend

local j = 0
foreach var in del_tend_barrio del_tend_com del_tend_pais{
	
	local j = 1+`j'
	ivreg2 `var' age hombre (deltaimm=deltaimm_instr), robust savefirst
	mat crime_trend_`j'=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]
	global F1 = e(first)[4,1]
	global r1 = e(first)[3,1]
	global n1 = e(N)
	
	local j = 1+`j'
	ivreg2 `var' age hombre (deltaimm=deltaimm_instr) [aw=`w'], robust savefirst
	mat crime_trend_`j'=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]
	global F2 = e(first)[4,1]
	global r2 = e(first)[3,1]
	global n2 = e(N)
	
	local j = 1+`j'
	ivreg2 `var' age hombre (deltalevel=deltaimm_instr), robust savefirst
	mat crime_trend_`j'=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]
	global F3 = e(first)[4,1]
	global r3 = e(first)[3,1]
	global n3 = e(N)
	
	local j = 1+`j'
	ivreg2 `var' age hombre (deltalevel=deltaimm_instr) [aw=`w'], robust savefirst
	mat crime_trend_`j'=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]
	global F4 = e(first)[4,1]
	global r4 = e(first)[3,1]
	global n4 = e(N)	
}

mat crime_trend = crime_trend_1,crime_trend_2,crime_trend_3,crime_trend_4\crime_trend_5,crime_trend_6,crime_trend_7,crime_trend_8\crime_trend_9,crime_trend_10, crime_trend_11,crime_trend_12
mat F`w' = [$F1 , $r1 , $n1 ,$F2 , $r2 , $n2 ,$F3 , $r3 , $n3 ,$F4 , $r4 , $n4]

* Table A.4: Perceptions Outcomes
mat crime_perception = J(1,12,.)\crime_percep\J(1,12,.)\crime_trend\J(1,12,.)\F`w'

frmttable using "$Tables\Table_A6.tex", tex frag replace statmat(crime_perception) substat(2) ctitles("", "Logs", "Logs","Levels" , "Levels"\"", "Unweighted", "Weighted", "Unweighted" , "Weighted ") rtitles(""\"Panel A: Crime-related Personal Concerns"\""\"Crime as a 1st or 2nd Concern" \ "" \ "" \ "Crime as Impacting Pers. Life"\ "" \ "" \ "Crime affecting Qual. Life"\ "" \ ""\ "Feeling unsafe"\ "" \ ""\ "Will be victim"\ "" \ ""\ "Principal Component Summary Index (PCI)"\ "" \ ""\""\"Panel B: Beliefs about Crime Trends"\""\ "Crime is rising at: village"\ "" \ "" \ "Crime is rising at: munic."\ "" \ "" \ "Crime is rising at: country"\"" \ ""\""\""\""\"First stage F-stat"\"Part. R \textsuperscript{2}"\"Observations") sdec(0\0\0\2\2\3\2\2\3\2\2\3\2\2\3\2\2\3\2\2\3\0\0\0\2\2\3\2\2\3\2\2\3) a4

}


* Behavioral Reactions
foreach w in fact_pers{

local j = 0
foreach var in Index_Vivienda Index_Vecinos del_arma pc_20{
	
	local j = 1+`j'
	ivreg2 `var' age hombre (deltaimm=deltaimm_instr), robust savefirst
	mat behavioral_react_`j'=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]
	
	local j = 1+`j'
	ivreg2 `var' age hombre (deltaimm=deltaimm_instr) [aw=`w'], robust savefirst
	mat behavioral_react_`j'=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]
	
	local j = 1+`j'
	ivreg2 `var' age hombre (deltalevel=deltaimm_instr), robust savefirst
	mat behavioral_react_`j'=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]
	
	local j = 1+`j'
	ivreg2 `var' age hombre (deltalevel=deltaimm_instr) [aw=`w'], robust savefirst
	mat behavioral_react_`j'=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]

}



mat behavioral_react = behavioral_react_1,behavioral_react_2,behavioral_react_3,behavioral_react_4\behavioral_react_5,behavioral_react_6,behavioral_react_7,behavioral_react_8\behavioral_react_9,behavioral_react_10, behavioral_react_11,behavioral_react_12\behavioral_react_13,behavioral_react_14,behavioral_react_15,behavioral_react_16


* Table A.5: Reaction Outcomes
mat behavioral_react =J(1,12,.)\behavioral_react\J(1,12,.)\F`w'
frmttable using "$Tables\Table_A7.tex", tex frag replace statmat(behavioral_react) substat(2) ctitles("", "Logs", "Logs","Levels" , "Levels"\"", "Unweighted", "Weighted", "Unweighted" , "Weighted ") rtitles(""\"Panel A: Crime-preventive Behavioral Reactions"\""\"Investment in Home Security"\ "" \ ""\ "Neighbors Security System"\ "" \ ""\ "Owns a Weapon"\ "" \ ""\ "Principal Component Summary Index (PCI)"\"" \ ""\""\""\""\"First stage F-stat"\"Part. R \textsuperscript{2}"\"Observations") sdec(0\0\0\2\2\3\2\2\3\2\2\3\2\2\3) a4

}


* Victimization
foreach w in fact_pers{

local j = 0
foreach var in  vict_roboviolent vict_robosorpr vict_roboviv vict_hurto vict_lesiones vict_robovehi vict_agreg{
	
	local j = 1+`j'
	ivreg2 `var' age hombre (deltaimm=deltaimm_instr), robust savefirst
	mat victimization_`j'=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]
	
	local j = 1+`j'
	ivreg2 `var' age hombre (deltaimm=deltaimm_instr) [aw=`w'], robust savefirst
	mat victimization_`j'=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]
	
	local j = 1+`j'
	ivreg2 `var' age hombre (deltalevel=deltaimm_instr), robust savefirst
	mat victimization_`j'=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]
	
	local j = 1+`j'
	ivreg2 `var' age hombre (deltalevel=deltaimm_instr) [aw=`w'], robust savefirst
	mat victimization_`j'=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]

}

mat victimization = victimization_1,victimization_2,victimization_3,victimization_4\victimization_5,victimization_6,victimization_7,victimization_8\victimization_9,victimization_10, victimization_11,victimization_12\victimization_13,victimization_14,victimization_15,victimization_16\victimization_17,victimization_18,victimization_19,victimization_20\victimization_21,victimization_22,victimization_23,victimization_24\victimization_25,victimization_26,victimization_27,victimization_28


* Table A.6 - Panel A: Victimization

mat crime_victimization = J(1,12,.)\victimization\J(1,12,.)\F`w'\J(1,12,.)

frmttable using "$Tables\Table_A8_PanelA.tex", tex frag replace statmat(crime_victimization) substat(2) ctitles("", "Logs", "Logs","Levels" , "Levels"\"", "Unweighted", "Weighted", "Unweighted" , "Weighted ") rtitles(""\"Panel A: Victimization"\ "" \ ""\ "Robbery"\ "" \ ""\ "Larceny"\ "" \ ""\ "Burglary"\ "" \ ""\ "Theft"\ "" \ ""\ "Assault"\ "" \ ""\ "MV Theft"\""\""\ "Total"\"" \ ""\""\""\"First stage F-stat"\"Part. R \textsuperscript{2}"\"Observations") sdec(0\0\0\2\2\3\2\2\3\2\2\3\2\2\3\2\2\3\2\2\3\2\2\3\0\0\0\2\2\2\0\2\2\2\2\3\2) a4
}

}
