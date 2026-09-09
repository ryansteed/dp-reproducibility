// Crea base consolidada ENUSC

cd "$rawdata/ENUSC"

forvalues i=2008/2017 {
	use `i', clear
	cap drop year
	gen year=`i'
	save "`i'_updated.dta", replace
	clear
}

forvalues i=2015/2017{
use `i'_updated
replace P24a_2_1 = 1 if (P24a_3_1==1)
drop P24a_3_1

ren P24a_4_1 P24a_3_1
ren P24a_5_1 P24a_4_1
ren P24a_6_1 P24a_5_1
ren P24a_7_1 P24a_6_1
ren P24a_8_1 P24a_7_1
ren P24a_9_1 P24a_8_1
ren P24a_10_1 P24a_9_1

save `i'_updated, replace
clear
}



*define locales con el listado de variables homologables para cada año. Cada lista debe tener el mismo largo y orden.

local var_2008 "num_linea num_hogar id_vivienda kish id_comuna15 region15 fact_pers fact_hog parentesco edad sexo curso nivel termino estudia empleo pe1_1_1 pe1_1_2 pe2_1_1 pe2_1_2 pe3_1_1 pe3_2_1 pe3_3_1 pe6_1_1 pe12_1_1 pe12_1_2 pe10_1_1 pe10_2_1 pe10_3_1 pe13_1_1 pe17_1_1 a1_1_1 a1_1_1_N_Veces a2_1_1 a3_1_1 a3_1_1_N_Veces b1_1_1 b1_1_1_N_Veces b2_1_1	b3_1_1 b3_1_1_N_Veces c1_1_1 c1_1_1_N_Veces c2_1_1 d1_1_1 d1_1_1_N_Veces d2_1_1 d3_1_1 d3_1_1_N_Veces e1_1_1 e1_1_1_N_Veces e2_1_1 e3_1_1 e3_1_1_N_Veces g1_1_1 g1_1_1_N_Veces g2_1_1 h1_1_1	h1_1_1_N_Veces h2_1_1 i1_1_1 i1_1_1_N_Veces i2_1_1 P155_1_1 P155_2_1 P155_3_1 P155_4_1 P155_5_1  P155_6_1 P155_7_1 P155_8_1 P155_9_1 P156_1_1 P156_2_1 P156_3_1 P156_4_1 P156_5_1  P156_6_1 P156_7_1 P156_8_1 P156_9_1 "

local var_2009 "num_linea num_hogar id_vivienda kish id_comuna15 region15 fact_pers fact_hog parentesco edad sexo curso nivel termino estudia empleo pe1_1_1 pe1_1_2 pe2_1_1 pe2_1_2 pe3_1_1 pe3_2_1 pe3_3_1 pe6_1_1 pe12_1_1 pe12_1_2 pe10_1_1 pe10_2_1 pe10_3_1 pe13_1_1 pe17_1_1 a1_1_1 a1_1_1_N_Veces a2_1_1 a3_1_1 a3_1_1_N_Veces b1_1_1 b1_1_1_N_Veces b2_1_1	b3_1_1 b3_1_1_N_Veces c1_1_1 c1_1_1_N_Veces c2_1_1 d1_1_1 d1_1_1_N_Veces d2_1_1 d3_1_1 d3_1_1_N_Veces e1_1_1 e1_1_1_N_Veces e2_1_1 e3_1_1 e3_1_1_N_Veces g1_1_1 g1_1_1_N_Veces g2_1_1 h1_1_1	h1_1_1_N_Veces h2_1_1 i1_1_1 i1_1_1_N_Veces i2_1_1 P154_1_1 P154_2_1 P154_3_1 P154_4_1 P154_5_1  P154_6_1 P154_7_1 P154_8_1 P154_9_1 P155_1_1 P155_2_1 P155_3_1 P155_4_1 P155_5_1  P155_6_1 P155_7_1 P155_8_1 P155_9_1 "

local var_2010 "num_linea num_hogar ID_Vivienda kish id_comuna15 region15 fact_pers fact_hog parentesco edad sexo curso nivel termino estudia empleo pe1_1_1 pe1_1_2 pe2_1_1 pe2_1_2 pe3_1_1 pe3_2_1 pe3_3_1 pe6_1_1 pe12_1_1 pe12_1_2 pe10_1_1 pe10_2_1 pe10_3_1 pe13_1_1 pe17_1_1 a1_1_1 a1_1_1_N_Veces a2_1_1 a3_1_1 a3_1_1_N_Veces b1_1_1 b1_1_1_N_Veces b2_1_1	b3_1_1 b3_1_1_N_Veces c1_1_1 c1_1_1_N_Veces c2_1_1 d1_1_1 d1_1_1_N_Veces d2_1_1 d3_1_1 d3_1_1_N_Veces e1_1_1 e1_1_1_N_Veces e2_1_1 e3_1_1 e3_1_1_N_Veces g1_1_1 g1_1_1_N_Veces g2_1_1 h1_1_1	h1_1_1_N_Veces h2_1_1 i1_1_1 i1_1_1_N_Veces i2_1_1 P163_1_1 P163_2_1 P163_3_1 P163_4_1 P163_5_1  P163_6_1 P163_7_1 P163_8_1 P163_9_1 P164_1_1 P164_2_1 P164_3_1 P164_4_1 P164_5_1  P164_6_1 P164_7_1 P164_8_1 P164_9_1 "

local var_2011 "num_linea num_hogar id_vivienda kish id_comuna15 region15 fact_pers fact_hog parentesco edad sexo curso nivel termino estudia empleo pe1_1_1 pe1_1_2 pe2_1_1 pe2_1_2 pe3_1_1 pe3_2_1 pe3_3_1 pe6_1_1 pe12_1_1 pe12_1_2 pe10_1_1 pe10_2_1 pe10_3_1 pe13_1_1 pe17_1_1 a1_1_1 a1_1_1_N_Veces a2_1_1 a3_1_1 a3_1_1_N_Veces b1_1_1 b1_1_1_N_Veces b2_1_1	b3_1_1 b3_1_1_N_Veces c1_1_1 c1_1_1_N_Veces c2_1_1 d1_1_1 d1_1_1_N_Veces d2_1_1 d3_1_1 d3_1_1_N_Veces e1_1_1 e1_1_1_N_Veces e2_1_1 e3_1_1 e3_1_1_N_Veces g1_1_1 g1_1_1_N_Veces g2_1_1 h1_1_1	h1_1_1_N_Veces h2_1_1 i1_1_1 i1_1_1_N_Veces i2_1_1 P74_1_1 P74_2_1 P74_3_1 P74_4_1 P74_5_1  P74_6_1 P74_7_1 P74_8_1 P74_9_1 P75_1_1 P75_2_1 P75_3_1 P75_4_1 P75_5_1  P75_6_1 P75_7_1 P75_8_1 P75_9_1 "

local var_2012 "num_linea num_hogar id_vivienda kish id_comuna15 region15 fact_pers fact_hog parentesco edad sexo curso nivel termino estudia empleo pe1_1_1 pe1_1_2 pe2_1_1 pe2_1_2 pe3_1_1 pe3_2_1 pe3_3_1 pe6_1_1 pe12_1_1 pe12_1_2 pe10_1_1 pe10_2_1 pe10_3_1 pe13_1_1 pe17_1_1 a1_1_1 a1_1_1_N_Veces a2_1_1 a3_1_1 a3_1_1_N_Veces b1_1_1 b1_1_1_N_Veces b2_1_1	b3_1_1 b3_1_1_N_Veces c1_1_1 c1_1_1_N_Veces c2_1_1 d1_1_1 d1_1_1_N_Veces d2_1_1 d3_1_1 d3_1_1_N_Veces e1_1_1 e1_1_1_N_Veces e2_1_1 e3_1_1 e3_1_1_N_Veces g1_1_1 g1_1_1_N_Veces g2_1_1 h1_1_1	h1_1_1_N_Veces h2_1_1 i1_1_1 i1_1_1_N_Veces i2_1_1 P74_1_1 P74_2_1 P74_3_1 P74_4_1 P74_5_1  P74_6_1 P74_7_1 P74_8_1 P74_9_1 P75_1_1 P75_2_1 P75_3_1 P75_4_1 P75_5_1  P75_6_1 P75_7_1 P75_8_1 P75_9_1 "

local var_2013 "num_linea num_hogar id_vivienda kish id_comuna15 region15 fact_pers fact_hog parentesco edad sexo curso nivel termino estudia empleo pe1_1_1 pe1_1_2 pe2_1_1 pe2_1_2 pe3_1_1 pe3_2_1 pe3_3_1 pe6_1_1 pe12_1_1 pe12_1_2 pe10_1_1 pe10_2_1 pe10_3_1 pe13_1_1 pe17_1_1 a1_1_1 a1_1_1_N_Veces a2_1_1 a3_1_1 a3_1_1_N_Veces b1_1_1 b1_1_1_N_Veces b2_1_1	b3_1_1 b3_1_1_N_Veces c1_1_1 c1_1_1_N_Veces c2_1_1 d1_1_1 d1_1_1_N_Veces d2_1_1 d3_1_1 d3_1_1_N_Veces e1_1_1 e1_1_1_N_Veces e2_1_1 e3_1_1 e3_1_1_N_Veces g1_1_1 g1_1_1_N_Veces g2_1_1 h1_1_1	h1_1_1_N_Veces h2_1_1 i1_1_1 i1_1_1_N_Veces i2_1_1 P74_1_1 P74_2_1 P74_3_1 P74_4_1 P74_5_1  P74_6_1 P74_7_1 P74_8_1 P74_9_1 P75_1_1 P75_2_1 P75_3_1 P75_4_1 P75_5_1  P75_6_1 P75_7_1 P75_8_1 P75_9_1 "

local var_2014 "num_linea num_hogar id_vivienda kish id_comuna15 region15 fact_pers fact_hog parentesco edad sexo curso nivel termino estudia empleo pe1_1_1 pe1_1_2 pe2_1_1 pe2_1_2 pe3_1_1 pe3_2_1 pe3_3_1 pe6_1_1 pe12_1_1 pe12_1_2 pe10_1_1 pe10_2_1 pe10_3_1 pe13_1_1 pe17_1_1 a1_1_1 a1_1_1_N_Veces a2_1_1 a3_1_1 a3_1_1_N_Veces b1_1_1 b1_1_1_N_Veces b2_1_1	b3_1_1 b3_1_1_N_Veces c1_1_1 c1_1_1_N_Veces c2_1_1 d1_1_1 d1_1_1_N_Veces d2_1_1 d3_1_1 d3_1_1_N_Veces e1_1_1 e1_1_1_N_Veces e2_1_1 e3_1_1 e3_1_1_N_Veces g1_1_1 g1_1_1_N_Veces g2_1_1 h1_1_1	h1_1_1_N_Veces h2_1_1 i1_1_1 i1_1_1_N_Veces i2_1_1 P74_1_1 P74_2_1 P74_3_1 P74_4_1 P74_5_1  P74_6_1 P74_7_1 P74_8_1 P74_9_1 P75_1_1 P75_2_1 P75_3_1 P75_4_1 P75_5_1  P75_6_1 P75_7_1 P75_8_1 P75_9_1 "

local var_2015 "num_linea num_hogar id_vivienda kish id_comuna15 region15 fact_pers fact_hog parentesco edad sexo curso nivel termino estudia empleo pe1_1_1 pe1_1_2 pe2_1_1 pe2_1_2 pe3_1_1 pe3_2_1 pe3_3_1 pe6_1_1 pe12_1_1 pe12_1_2 pe10_1_1 pe10_2_1 pe10_3_1 pe13_1_1 pe17_1_1 a1_1_1 a1_1_1_N_Veces a2_1_1 a3_1_1 a3_1_1_N_Veces b1_1_1 b1_1_1_N_Veces b2_1_1	b3_1_1 b3_1_1_N_Veces c1_1_1 c1_1_1_N_Veces c2_1_1 d1_1_1 d1_1_1_N_Veces d2_1_1 d3_1_1 d3_1_1_N_Veces e1_1_1 e1_1_1_N_Veces e2_1_1 e3_1_1 e3_1_1_N_Veces g1_1_1 g1_1_1_N_Veces g2_1_1 h1_1_1	h1_1_1_N_Veces h2_1_1 i1_1_1 i1_1_1_N_Veces i2_1_1 P24a_1_1 P24a_2_1 P24a_3_1 P24a_4_1 P24a_5_1  P24a_6_1 P24a_7_1 P24a_8_1 P24a_9_1 P25a_1_1 P25a_2_1 P25a_3_1 P25a_4_1 P25a_5_1  P25a_6_1 P25a_7_1 P25a_8_1 P25a_9_1 "

local var_2016 "num_linea num_hogar id_vivienda kish id_comuna15 region15 fact_pers fact_hog parentesco edad sexo curso nivel termino estudia empleo pe1_1_1 pe1_1_2 pe2_1_1 pe2_1_2 pe3_1_1 pe3_2_1 pe3_3_1 pe6_1_1 pe12_1_1 pe12_1_2 pe10_1_1 pe10_2_1 pe10_3_1 pe13_1_1 pe17_1_1 a1_1_1 a1_1_1_N_Veces a2_1_1 a3_1_1 a3_1_1_N_Veces b1_1_1 b1_1_1_N_Veces b2_1_1	b3_1_1 b3_1_1_N_Veces c1_1_1 c1_1_1_N_Veces c2_1_1 d1_1_1 d1_1_1_N_Veces d2_1_1 d3_1_1 d3_1_1_N_Veces e1_1_1 e1_1_1_N_Veces e2_1_1 e3_1_1 e3_1_1_N_Veces g1_1_1 g1_1_1_N_Veces g2_1_1 h1_1_1	h1_1_1_N_Veces h2_1_1 i1_1_1 i1_1_1_N_Veces i2_1_1 P24a_1_1 P24a_2_1 P24a_3_1 P24a_4_1 P24a_5_1  P24a_6_1 P24a_7_1 P24a_8_1 P24a_9_1 P25a_1_1 P25a_2_1 P25a_3_1 P25a_4_1 P25a_5_1  P25a_6_1 P25a_7_1 P25a_8_1 P25a_9_1 "

local var_2017 "num_linea num_hogar id_vivienda kish id_comuna15 region15 fact_pers fact_hog parentesco edad sexo curso nivel termino estudia empleo pe1_1_1 pe1_1_2 pe2_1_1 pe2_1_2 pe3_1_1 pe3_2_1 pe3_3_1 pe6_1_1 pe12_1_1 pe12_1_2 pe10_1_1 pe10_2_1 pe10_3_1 pe13_1_1 pe17_1_1 a1_1_1 a1_1_1_N_Veces a2_1_1 a3_1_1 a3_1_1_N_Veces b1_1_1 b1_1_1_N_Veces b2_1_1	b3_1_1 b3_1_1_N_Veces c1_1_1 c1_1_1_N_Veces c2_1_1 d1_1_1 d1_1_1_N_Veces d2_1_1 d3_1_1 d3_1_1_N_Veces e1_1_1 e1_1_1_N_Veces e2_1_1 e3_1_1 e3_1_1_N_Veces g1_1_1 g1_1_1_N_Veces g2_1_1 h1_1_1	h1_1_1_N_Veces h2_1_1 i1_1_1 i1_1_1_N_Veces i2_1_1 P24a_1_1 P24a_2_1 P24a_3_1 P24a_4_1 P24a_5_1  P24a_6_1 P24a_7_1 P24a_8_1 P24a_9_1 P25a_1_1 P25a_2_1 P25a_3_1 P25a_4_1 P25a_5_1  P25a_6_1 P25a_7_1 P25a_8_1 P25a_9_1 "

local var_final "num_linea num_hogar id_vivienda kish id_comuna15 region15 fact_pers fact_hog parentesco edad sexo curso nivel termino estudia empleo pe1_1_1 pe1_1_2 pe2_1_1 pe2_1_2 pe3_1_1 pe3_2_1 pe3_3_1 pe6_1_1 pe12_1_1 pe12_1_2 pe10_1_1 pe10_2_1 pe10_3_1 pe13_1_1 pe17_1_1 a1_1_1 a1_1_1_N_Veces a2_1_1 a3_1_1 a3_1_1_N_Veces b1_1_1 b1_1_1_N_Veces b2_1_1	b3_1_1 b3_1_1_N_Veces c1_1_1 c1_1_1_N_Veces c2_1_1 d1_1_1 d1_1_1_N_Veces d2_1_1 d3_1_1 d3_1_1_N_Veces e1_1_1 e1_1_1_N_Veces e2_1_1 e3_1_1 e3_1_1_N_Veces g1_1_1 g1_1_1_N_Veces g2_1_1 h1_1_1	h1_1_1_N_Veces h2_1_1 i1_1_1 i1_1_1_N_Veces i2_1_1 vivienda_perro vivienda_alarma vivenda_camara vivienda_rejas vivienda_cerco_elec vivienda_muro_no_elec vivenda_cadena vivienda_construccion vivienda_sensores vecinos_numero vecinos_vigilancia vecinos_alarma vecinos_persona vecinos_sistema vecinos_control vecinos_coordinar vecinos_agentes vecinos_acuerdo"



* El loop que viene cambia el nombre de las variables homologables de cada base por el nombre asignado en la base final (ver excel)


forvalues j=2008/2017{
	use `j'_updated, clear
	local n_variable : word count `var_`j''
	display `n_variable'

	forval i=1/`n_variable' {
		local this_var `: word `i' of `var_`j'''
		local this_varfinal `:word `i' of `var_final''
		rename `this_var' `this_varfinal'
		save `j'_updated, replace
		}
}
clear


* genera base final

use 2017_updated
keep year id_hogar `var_final'
save base_final, replace
clear

forvalues i=2008/2016 {
	use base_final
	append using `i'_updated, keep (year id_hogar `var_final')
	save base_final, replace
	erase `i'_updated.dta
}

append using 2017_updated, keep (year id_hogar `var_final')
erase 2017_updated.dta
save base_final, replace	
	
replace fact_pers=. if kish==0
replace fact_hog=. if kish==0
	
	

	
*Crea Provincia de Marga Marga en 2008 y 2009
replace id_comuna15=5801 if id_comuna15==5106
replace id_comuna15=5802 if id_comuna15==5505
replace id_comuna15=5804 if id_comuna15==5108

	
sort year id_comuna15	
order year id_comuna15 region15 id_hogar id_vivienda kish num_linea num_hogar parentesco
format %13.0g id_hogar
label variable id_comuna15 "Comuna"
duplicates drop


cd ".."
save base_final_2008_2017, replace
cd "../.."	