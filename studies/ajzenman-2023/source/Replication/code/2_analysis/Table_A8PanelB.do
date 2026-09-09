*------------------------------------------------------------------------------*
* 								Tabla A.8 (Panel B)			  				   *
*------------------------------------------------------------------------------*

{
* Homicides
cd "$conf_final"
use homicides_IV, clear

replace deltalevel=deltalevel/100000

local j = 1
ivreg2 dl_homicidios1pc age hombre (deltaimm=deltaimm_instr), robust savefirst
mat murder_`j'=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]
global F1b = e(first)[4,1]
global r1b = e(first)[3,1]
global n1b = e(N)

local j = 1+`j'
ivreg2 dl_homicidios1pc age hombre (deltaimm=deltaimm_instr) [aw=population], robust savefirst
mat murder_`j'=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]
global F2b = e(first)[4,1]
global r2b = e(first)[3,1]
global n2b = e(N)

local j = 1+`j'
ivreg2 dl_homicidios1pc age hombre (deltalevel=deltaimm_instr), robust savefirst
mat murder_`j'=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]
global F3b = e(first)[4,1]
global r3b = e(first)[3,1]
global n3b = e(N)

local j = 1+`j'
ivreg2 dl_homicidios1pc age hombre (deltalevel=deltaimm_instr) [aw=population], robust savefirst
mat murder_`j'=[e(b)[1,1], sqrt(e(V)[1,1]), 2*(1-normal(abs(e(b)[1,1]/sqrt(e(V)[1,1]))))]
global F4b = e(first)[4,1]
global r4b = e(first)[3,1]
global n4b = e(N)
	
mat murder = murder_1,murder_2,murder_3,murder_4
mat Fb = [$F1b , $r1b , $n1b ,$F2b , $r2b , $n2b ,$F3b , $r3b , $n3b ,$F4b , $r4b , $n4b]


* Table: Outcomes de Crimenes

mat crime_victimization = J(1,12,.)\murder\J(1,12,.)\Fb

frmttable using "$Tables\Table_A8_PanelB.tex", tex frag replace statmat(crime_victimization) substat(2) ctitles("", "Logs", "Logs","Levels" , "Levels"\"", "Unweighted", "Weighted", "Unweighted" , "Weighted ") rtitles(""\"Panel B: Homicide"\"" \"Homicide"\"" \ ""\""\""\""\"First stage F-stat"\"Part. R \textsuperscript{2}"\"Observations") sdec(0\0\0\2\2\2\0\2\2\2\2\3\2) a4

}

