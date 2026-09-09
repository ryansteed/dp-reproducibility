* Do-file para generar la base que se utiliza para las tablas I, II, III, IV, y V, y figura VII (Panels a and c) 


*Controles CASEN para el panel

* 2 0 0 6 ----------------------------------------------

cd "$rawdata"
*** Edited by Annie
import excel Divisi├│n-Pol├нtico-Administrativa-y-Servicios-de-Salud-Hist├│rico.xls, firstrow clear
keep CódigoComunadesde2000 CódigoComunadesde2010
rename CódigoComunadesde2000 comuna
merge 1:n comuna using casen2006
keep if _merge==3
drop comuna
rename CódigoComunadesde2010 cod_com
drop _merge

* Me quedo solo con los jefes de hogar (todas las variables categoricas van a estar en % de jefes de hogar - ej % de jfes de hogar desempleado, % de jefes de hogar que pertenecen a un grupo indigena, educacion promedio de los jefes de hogar, etc)
keep if pco1==1

* Género
gen hombre=(sexo==1)
* Controles de edad
gen age=edad
* Controles de ingreso
gen ypc=ytothaj/numper
replace ypc=ypc*1000
* El factor de expansion es expc
foreach var in hombre age ypc{
	replace `var'=`var'*expc
}
* Colapsando la suma de expc a nivel comuna voy a tener el denominador para calcular los % de cada variable
collapse (sum) hombre age ypc expc, by(cod_com)
* Genero las tasas:
foreach var in hombre age ypc{
	replace `var'=`var'/expc
}
* Le faltan comunas
cd "$intermed"
save controlesCASEN06, replace

* 2 0 0 9 ----------------------------------------------

cd "$rawdata"

import excel Divisi├│n-Pol├нtico-Administrativa-y-Servicios-de-Salud-Hist├│rico.xls, firstrow clear
keep CódigoComunadesde2008 CódigoComunadesde2010
rename CódigoComunadesde2008 comuna
merge 1:n comuna using casen2009
keep if _merge==3
drop comuna
rename CódigoComunadesde2010 cod_com
drop _merge

* Me quedo solo con los jefes de hogar (todas las variables categoricas van a estar en % de jefes de hogar - ej % de jfes de hogar desempleado, % de jefes de hogar que pertenecen a un grupo indigena, educacion promedio de los jefes de hogar, etc)
keep if pco1==1

* Género
gen hombre=(sexo==1)
* Controles de edad
gen age=edad
* Controles de ingreso
gen ypc=ytothaj/numper
replace ypc=ypc*1000

* El factor de expansion es expc
foreach var in hombre age ypc{
	replace `var'=`var'*expc
}
* Colapsando la suma de expc a nivel comuna voy a tener el denominador para calcular los % de cada variable
collapse (sum) hombre age ypc expc, by(cod_com)
* Genero las tasas:
foreach var in hombre age ypc{
	replace `var'=`var'/expc
}

cd "$intermed"
save controlesCASEN09, replace


* 2 0 1 1 ----------------------------------------------

cd "$rawdata"
*import spss  using "C:/Users/USUARIO/Documents/Asistente/Migration Chile/ADU_Franco/Do_Franco/Resultados Junio/Bases de datos/casen2011_octubre2011_enero2012_principal_08032013spss.sav", clear
*save casen2011, replace
import excel Divisi├│n-Pol├нtico-Administrativa-y-Servicios-de-Salud-Hist├│rico.xls, firstrow clear
keep CódigoComunadesde2010
rename CódigoComunadesde2010 comuna
merge 1:n comuna using casen2011
rename comuna cod_com
keep if _merge==3
drop _merge

* Me quedo solo con los jefes de hogar (todas las variables categoricas van a estar en % de jefes de hogar - ej % de jfes de hogar desempleado, % de jefes de hogar que pertenecen a un grupo indigena, educacion promedio de los jefes de hogar, etc)
keep if pco1==1
rename expc_full expc 
rename expr_full expr 

* Género
gen hombre=(sexo==1)
* Controles de edad
gen age=edad
* Controles de ingreso
gen ypc=ytothaj/numper
replace ypc=ypc*1000

* El factor de expansion es expc
foreach var in hombre age ypc{
	replace `var'=`var'*expc
}
* Colapsando la suma de expc a nivel comuna voy a tener el denominador para calcular los % de cada variable
collapse (sum) hombre age ypc expc, by(cod_com)
* Genero las tasas:
foreach var in hombre age ypc{
	replace `var'=`var'/expc
}

cd "$intermed"
save controlesCASEN11, replace


* 2 0 1 3 ----------------------------------------------

cd "$rawdata"
import excel Divisi├│n-Pol├нtico-Administrativa-y-Servicios-de-Salud-Hist├│rico.xls, firstrow clear
keep CódigoComunadesde2010
rename CódigoComunadesde2010 comuna
merge 1:n comuna using casen2013
rename comuna cod_com
keep if _merge==3
drop _merge

* Me quedo solo con los jefes de hogar (todas las variables categoricas van a estar en % de jefes de hogar - ej % de jfes de hogar desempleado, % de jefes de hogar que pertenecen a un grupo indigena, educacion promedio de los jefes de hogar, etc)
keep if pco1==1

* Género
gen hombre=(sexo==1)
* Controles de edad
gen age=edad
* Controles de ingreso
gen ypc=ytotcorh/numper
replace ypc=ypc*1000

* El factor de expansion es expc
foreach var in hombre age ypc{
	replace `var'=`var'*expc
}
* Colapsando la suma de expc a nivel comuna voy a tener el denominador para calcular los % de cada variable
collapse (sum) hombre age ypc expc, by(cod_com)
* Genero las tasas:
foreach var in hombre age ypc{
	replace `var'=`var'/expc
}
cd "$intermed"
save controlesCASEN13, replace


* 2 0 1 5 ----------------------------------------------

cd "$rawdata"
import excel Divisi├│n-Pol├нtico-Administrativa-y-Servicios-de-Salud-Hist├│rico.xls, firstrow clear
keep CódigoComunadesde2010
rename CódigoComunadesde2010 comuna
merge 1:n comuna using casen2015
rename comuna cod_com
keep if _merge==3
drop _merge

* Me quedo solo con los jefes de hogar (todas las variables categoricas van a estar en % de jefes de hogar - ej % de jfes de hogar desempleado, % de jefes de hogar que pertenecen a un grupo indigena, educacion promedio de los jefes de hogar, etc)
keep if pco1==1

* Género
gen hombre=(sexo==1)
* Controles de edad
gen age=edad
* Controles de ingreso
gen ypc=ytotcorh/numper
replace ypc=ypc*1000

* El factor de expansion es expc
foreach var in hombre age ypc{
	replace `var'=`var'*expc
}
* Colapsando la suma de expc a nivel comuna voy a tener el denominador para calcular los % de cada variable
collapse (sum) hombre age ypc expc, by(cod_com)
* Genero las tasas:
foreach var in hombre age ypc{
	replace `var'=`var'/expc
}
cd "$intermed"
save controlesCASEN15, replace


* 2 0 1 7 ----------------------------------------------
/*
*Con estas lineas resuelvo el problema del codigo de las comunas ñuble, que cambio y arruinaba el merge (tiraba 20 comunas de mas)
import excel Divisi├│n-Pol├нtico-Administrativa-y-Servicios-de-Salud-Hist├│rico.xls, firstrow clear
keep CódigoComunadesde2010
rename CódigoComunadesde2010 comuna
merge 1:n comuna using casen2017
keep if _merge==2
keep comuna
quietly bys comuna: gen dup=cond(_N==1,0,_n)
drop if dup > 1
drop dup
* Lista de comunas que cambiaron de codigo entre 2010 y 2017 - ñuble paso a ser una region independiente
save comunasNUBLE, replace
use casen2017, clear
quietly bys comuna: gen dup=cond(_N==1,0,_n)
drop if dup > 1
drop dup
keep if comuna==16101 | comuna==16102 | comuna==16103 | comuna==16104 | comuna==16105 | comuna==16106 | comuna==16107 | comuna==16108 | comuna==16109 | comuna==16201 | comuna==16202 | comuna==16203 | comuna==16204 | comuna==16205 | comuna==16206 | comuna==16207 | comuna==16301 | comuna==16302 | comuna==16303 | comuna==16304 | comuna==16305
keep comuna
*Para guardarlas con nombre
save comunasNUBLE, replace
*/
cd "$rawdata"
import excel Divisi├│n-Pol├нtico-Administrativa-y-Servicios-de-Salud-Hist├│rico.xls, firstrow clear
keep CódigoComunadesde2010
rename CódigoComunadesde2010 comuna

*Pongo los nuevos codigos, que cambiaron
replace comuna=16101 if comuna==8401
replace comuna=16102 if comuna==8402
replace comuna=16103 if comuna==8406
replace comuna=16104 if comuna==8407
replace comuna=16105 if comuna==8410
replace comuna=16106 if comuna==8411
replace comuna=16107 if comuna==8413
replace comuna=16108 if comuna==8418
replace comuna=16109 if comuna==8421
replace comuna=16201 if comuna==8414
replace comuna=16202 if comuna==8403
replace comuna=16203 if comuna==8404
replace comuna=16204 if comuna==8408
replace comuna=16205 if comuna==8412
replace comuna=16206 if comuna==8415
replace comuna=16207 if comuna==8420
replace comuna=16301 if comuna==8416
replace comuna=16302 if comuna==8405
replace comuna=16303 if comuna==8409
replace comuna=16304 if comuna==8417
replace comuna=16305 if comuna==8419

merge 1:n comuna using casen2017
rename comuna cod_com
keep if _merge==3
drop _merge
*Vuelvo a los viejos codigos para cuando arme el panel
replace cod_com=8401 if cod_com==16101
replace cod_com=8402 if cod_com==16102
replace cod_com=8406 if cod_com==16103
replace cod_com=8407 if cod_com==16104
replace cod_com=8410 if cod_com==16105
replace cod_com=8411 if cod_com==16106
replace cod_com=8413 if cod_com==16107
replace cod_com=8418 if cod_com==16108
replace cod_com=8421 if cod_com==16109
replace cod_com=8414 if cod_com==16201
replace cod_com=8403 if cod_com==16202
replace cod_com=8404 if cod_com==16203
replace cod_com=8408 if cod_com==16204
replace cod_com=8412 if cod_com==16205
replace cod_com=8415 if cod_com==16206
replace cod_com=8420 if cod_com==16207
replace cod_com=8416 if cod_com==16301
replace cod_com=8405 if cod_com==16302
replace cod_com=8409 if cod_com==16303
replace cod_com=8417 if cod_com==16304
replace cod_com=8419 if cod_com==16305

drop ypc  /*CASEN 17 VIENE CON LA VARIABLE ARMADA, LA CAMBIO POR LAS DUDAS PARA SER CONSISTENTE CON LA CONSTRUCCION DE LA VARIABLE */

* Me quedo solo con los jefes de hogar (todas las variables categoricas van a estar en % de jefes de hogar - ej % de jfes de hogar desempleado, % de jefes de hogar que pertenecen a un grupo indigena, educacion promedio de los jefes de hogar, etc)
keep if pco1==1

* Género
gen hombre=(sexo==1)
* Controles de edad
gen age=edad
* Controles de ingreso
gen ypc=ytotcorh/numper
replace ypc=ypc*1000

* El factor de expansion es expc
foreach var in hombre age ypc{
	replace `var'=`var'*expc
}
* Colapsando la suma de expc a nivel comuna voy a tener el denominador para calcular los % de cada variable
collapse (sum) hombre age ypc expc, by(cod_com)
* Genero las tasas:
foreach var in hombre age ypc{
	replace `var'=`var'/expc
}

cd "$intermed"
save controlesCASEN17, replace


*Junto las casen por años
cd "$intermed"
use controlesCASEN06, clear
gen year=2006
append using controlesCASEN06
replace year=2007 if year==.
append using controlesCASEN06
replace year=2008 if year==.
append using controlesCASEN09
replace year=2009 if year==.
append using controlesCASEN09
replace year=2010 if year==.
append using controlesCASEN11
replace year=2011 if year==.
append using controlesCASEN11
replace year=2012 if year==.
append using controlesCASEN13
replace year=2013 if year==.
append using controlesCASEN13
replace year=2014 if year==.
append using controlesCASEN15
replace year=2015 if year==.
append using controlesCASEN15
replace year=2016 if year==.
append using controlesCASEN17
replace year=2017 if year==.
append using controlesCASEN17
replace year=2018 if year==.

save controlesCASEN06_17, replace


*OLS - baseline, permisos y visas

cd "$rawdata"

* Empiezo con la base de extranjería para generar una colapsada a nivel de comuna y año
use immigration_Correciones, clear
* Tiro 2 observaciones que tienen mal el codigo
drop if comuna=="florida" & cod_com==8404
* Tiro 379 observaciones con cod_com==96
drop if cod_com==96
* Gente con permiso: residencia permanente
gen imm_permiso=(doc=="pd")
* Gente con visa: residencia temporaria o sujeta a contrato
gen imm_visa=(doc=="visa")

sort cod_com year
collapse (sum) imm*, by(cod_com year)

cd "$intermed"
save immigration_tablaOLS, replace

cd "$rawdata"
use PERSONA_comuna_distrito.dta, clear
rename Codigo CodigoActual
* Todos los que nacieron fuera de las comunas de chile quedan con _merge==1
rename P22B Codigo
merge m:1 Codigo using COMUNAS
* Estas observaciones no sirven
drop if Codigo==99999
* Con este comando y los Cuadros 2.1 y 2.2 (p111) del documento "Censo 2002 Chile con Cuestionario" encuentro los codigos para los paises que quiero (comparo numeros, dan iguales)
keep if _merge==1
*groups Codigo, order(h)
* Resultados: 
* 20027 "haiti"

*Todos los que me quedan aca son inmigrantes

* Ahora tiro todas las otras cosas que no necesito
* Variables que no tengan que ver con pais de origen o residencia en chile
keep P22A Codigo P22C P23A P23B P24A P24B CodigoActual comuna
* Ahora tengo que averiguar cuantos de los nacidos en otro pais residen en chile o no
rename Codigo P22B
rename P23B Codigo
merge m:1 Codigo using COMUNAS

drop if _merge==2
* Son 4 observaciones, supongo que hay 4 comunas en las que no habia ningun inmigrante de los paises de arriba
drop if _merge==1
* 7662 observaciones que reportaron no nacer en chile y residir en algun pais del extranjero (su respuesta a P23A no fue ninguna comuna chilena)

rename Codigo P23B
rename CodigoActual cod_com
gen imm=1
gen imm_permiso=1
gen imm_visa=1
gen year=2002
keep cod_com comuna year imm*

collapse (sum) imm*, by(cod_com year)
cd "$intermed"
save collapse2002, replace

append using immigration_tablaOLS

* Ahora saco stocks por año para las 3 variables
sort cod_com year
foreach j in "" "_permiso" "_visa"{
	bys cod_com: gen stock_imm`j'=sum(imm`j')
}

keep if year > 2007
drop if year==2018
save immigration_tablaOLS, replace

*Genero una base casi identica a la anterior pero que tenga 2009
*Necesito ademas usar la base de crimen porque solo en es estan los codigos por region que voy a usar
cd "$rawdata"
use population_2010, clear
gen comuna=lower(COMUNA)
replace comuna=subinstr(comuna,"Ñ","n",.)
sort comuna
drop COMUNA
replace comuna="san jose de maipo" if comuna=="san jose  de maipo"
replace comuna="ollague" if comuna=="ollagüe"
replace comuna="hijuelas" if comuna=="hijuela"
replace comuna="el olivar" if comuna=="olivar"
replace comuna="o'higgins" if comuna=="o´higgins"
replace comuna="aisen" if comuna=="aysen"
cd "$intermed"
save population, replace

cd "$rawdata"
use cod_com, clear
cd "$intermed"
merge 1:1 comuna using population
drop _merge NombreComuna
cd "$rawdata"
merge 1:1 cod_com using cod_reg
cd "$intermed"
drop _merge
save population, replace
*Para encontrar las comunas que no estan en la base de inmigracion y ponerle 0 en los flujos y los stocks de inmigrantes (asumo que no estan en el panel porque no tuvieron inmigracion)
gen year=2008
foreach year in 2009 2010 2011 2012 2013 2014 2015 2016 2017{
	expand 2 if year==2008, generate(newv)
	replace year=`year' if newv==1
	drop newv
}
sort cod_com year

merge 1:1 cod_com year using immigration_tablaOLS
mvencode imm* stock* if _merge==1, mv(0)
drop _merge

* Genero rate y log rate de inmigracion para visas y permisos
foreach var in stock_imm stock_imm_permiso stock_imm_visa{
	gen rate_`var'=`var'*10000/population
	gen lnrate_`var'=ln(rate_`var'+1)
}

* Esta base tiene inmigracion, poblacion por comuna y año, codigos de comuna y region y nombre de comuna 
save immigration_tablaOLS, replace

cd "$rawdata"
use base_final_2008_2017, clear
drop if year==2018
rename id_comuna15 cod_com
cd "$intermed"

merge m:1 cod_com year using immigration_tablaOLS
drop if cod_com==5106 | cod_com==5108 | cod_com==5505
drop if _merge==2
drop _merge
drop if kish==0
*VARIABLES DE PERCEPCIÓN
*Variables de control
gen ismale=(sexo==1)
gen trabaja=(empleo==1)
*Delincuencia como primera preocupación
gen del_problema1=(pe1_1_1==8) if kish==1 & pe1_1_1<80
*Delincuencia como segunda preocupacion
gen del_problema2=(pe1_1_2==8) if kish==1 & pe1_1_2<80
*Delincuencia como primera o segunda preocupacion
gen del_problema3=(pe1_1_1==8 | pe1_1_2==8) if kish==1 & (pe1_1_1<80 & pe1_1_2<80)
*Delincuencia como el primer problema que afecta personalmente
gen del_afecta1=(pe2_1_1==8) if kish==1 & pe2_1_1 <80
*Delincuencia como el segundo problema que afecta personalmente
gen del_afecta2=(pe2_1_2==8) if kish==1 & pe2_1_2 < 80
*Delincuencia entre los 2 primeros problemas que afectan personalmente
gen del_afecta3=(pe2_1_1==8 | pe2_1_2==8) if kish==1 & (pe2_1_1<80 & pe2_1_2<80)
*Opina que la delincuencia a nivel País aumentó
gen del_tend_pais=(pe3_1_1==1) if kish==1 & pe3_1_1 < 80
*Opina que la delincuencia a nivel Comuna aumentó
gen del_tend_com=(pe3_2_1==1) if kish==1 & pe3_2_1 < 80
*Opina que la delincuencia a nivel Barrio aumentó
gen del_tend_barrio=(pe3_3_1==1) if kish==1 & pe3_3_1 < 80
*Opina que delincuencia afecta su calidad de vida "Mucho"
gen del_calvida1=(pe6_1_1==1) if kish==1 & pe6_1_1 < 80
*Opina que delincuencia afecta su calidad de vida "Bastante"
gen del_calvida2=(pe6_1_1==2) if kish==1 & pe6_1_1 < 80
*Opina que delincuencia afecta su calidad de vida "Mucho" o "Bastante"
gen del_calvida3=(pe6_1_1==1 | pe6_1_1==2) if kish==1 & (pe6_1_1<80 & pe6_1_1<80)
*Se siente muy inseguro caminando cuando ya esta oscuro
gen del_inseg1=(pe10_1_1==1 | pe10_1_1 ==2) if kish==1 & pe10_1_1 < 80
*Se siente muy inseguro solo en su casa cuando ya esta oscuro
gen del_inseg2=(pe10_2_1==1 | pe10_2_1 ==2) if kish==1 & pe10_2_1 < 80
*Se siente muy inseguro esperando el transporte cuando ya esta oscuro
gen del_inseg3=(pe10_3_1==1 | pe10_3_1 ==2) if kish==1 & pe10_3_1 < 80
*Se siente muy inseguro caminando, esperando el transporte o solo en su casa cuando ya esta oscuro
gen del_inseg4=(del_inseg1==1 | pe10_1_1 ==2 | del_inseg2==1 | pe10_2_1 ==2 | del_inseg3==1 | pe10_3_1 ==2) if kish==1 & (pe10_1_1<80 & pe10_2_1<80 & pe10_3_1<80 )
*Se siente inseguro haciendo las 3 cosas
gen del_inseg5=(del_inseg1==1 &  del_inseg2==1 & del_inseg3==1) if kish==1 & (pe10_1_1<80 & pe10_2_1<80 & pe10_3_1<80 )
*Cree que será víctima de un delito en los próximos 12 meses
gen del_vict=(pe13_1_1==1) if kish==1 & pe13_1_1 < 80
*Tenencia de arma de fuego
gen del_arma=(pe17_1_1==1) if kish==1 & pe17_1_1 < 80

gen viv_1=(vivienda_perro==1) if vivienda_perro!=. & vivienda_perro<80
gen viv_2=(vivienda_alarma==1) if vivienda_alarma!=. & vivienda_alarma<80
gen viv_3=(vivenda_camara==1) if vivenda_camara!=. & vivenda_camara<80
gen viv_4=(vivienda_rejas==1) if vivienda_rejas!=. & vivienda_rejas<80
gen viv_5=(vivienda_cerco_elec==1) if vivienda_cerco_elec!=. & vivienda_cerco_elec<80
gen viv_6=(vivienda_muro_no_elec==1) if vivienda_muro_no_elec!=. & vivienda_muro_no_elec<80
gen viv_7=(vivenda_cadena==1) if vivenda_cadena!=. & vivenda_cadena<80
gen viv_8=(vivienda_construccion==1) if vivienda_construccion!=. & vivienda_construccion<80
gen viv_9=(vivienda_sensores==1) if vivienda_sensores!=. & vivienda_sensores<80

gen vec_1=(vecinos_numero==1) if vecinos_numero!=. & vecinos_numero<80
gen vec_2=(vecinos_vigilancia==1) if vecinos_vigilancia!=. & vecinos_vigilancia<80
gen vec_3=(vecinos_alarma==1) if vecinos_alarma!=. & vecinos_alarma<80
gen vec_4=(vecinos_persona==1) if vecinos_persona!=. & vecinos_persona<80
gen vec_5=(vecinos_sistema==1) if vecinos_sistema!=. & vecinos_sistema<80
gen vec_6=(vecinos_control==1) if vecinos_control!=. & vecinos_control<80
gen vec_7=(vivienda_construccion==1) if vivienda_construccion!=. & vivienda_construccion<80
gen vec_8=(vecinos_agentes==1) if vecinos_agentes!=. & vivienda_construccion<80
gen vec_9=(vecinos_acuerdo==1) if vecinos_acuerdo!=. & vecinos_acuerdo<80

 
egen Index_Vivienda = rowmean(viv_*)
egen Index_Vecinos = rowmean(vec_*)

*VARIABLES DE VICTIMIZACION

*El informante o alguien de su familia fue asaltado con violencia
gen vict_roboviolent=(a1_1_1==1) if kish==1 & a1_1_1<80
*El informante o alguien de su familia sufrio robo por sorpresa
gen vict_robosorpr=(b1_1_1==1) if kish==1 & b1_1_1<80
*El informante o alguien de su familia sufrio robo en su vivienda
gen vict_roboviv=(c1_1_1==1) if kish==1 & c1_1_1<80
*El informante o alguien de su familia sufrio hurto
gen vict_hurto=(d1_1_1==1) if kish==1 & d1_1_1<80
*El informante o alguien de su familia fue victima de lesiones (sin robo)
gen vict_lesiones=(e1_1_1==1) if kish==1 & e1_1_1<80
*El informante o alguien de su familia sufrio robo de vehiculo
gen vict_robovehi=(g1_1_1==1) if kish==1 & g1_1_1<80
*El informante o alguien de su familia sufrio robo de articulos dejados en el vehiculo
gen vict_robo_desdevehi=(h1_1_1==1) if kish==1 & h1_1_1<80
*El informante o alguien de su familia fue victima delitos de connotacion economica (estafas y similares)
gen vict_delecon=(i1_1_1==1) if kish==1 & i1_1_1<80

replace vict_robo_desdevehi= 0 if vict_robo_desdevehi ==.
replace vict_robovehi= 0 if vict_robovehi ==.

gen vict_car = (vict_robovehi==1 | vict_robovehi ==1)



*Las variables de victimizacion agregadas. Rowmean ignora los missing values
gen vict_agreg=(vict_roboviolent==1|vict_robosorpr==1|vict_roboviv==1|vict_hurto==1|vict_lesiones==1|vict_robovehi==1)
label var vict_agreg "Crimen total: variable que toma valor 1 si el individuo sufrio ALGUN crimen, 0 sino"
*victimizacion en crimenes a la propiedad (sin violencia, segun marca la guia de la encuesta)
egen vict_property=rowmean(vict_car vict_car vict_hurto vict_robosorpr vict_roboviv)
*victimizacion en crimenes que involucran violencia. robo con fuerza en vivienda parece que incluye tanto robos sin uso de violencia o intimidacion como con violencia asi que no estoy seguro de en cual incluirlo
egen vict_violent=rowmean(vict_roboviolent vict_lesiones) 

pca del_problema1 del_afecta1 del_calvida1 del_inseg5 
predict pc_1, score
pca del_problema3 del_afecta3 del_calvida1 del_inseg5 
predict pc_2, score
pca del_problema1 del_afecta1 del_calvida1 del_inseg5 del_arma
predict pc_3, score
pca del_problema3 del_afecta3 del_calvida3 del_inseg4 del_arma
predict pc_4, score
pca del_problema1 del_afecta1 del_calvida1 
predict pc_5, score
pca del_tend_pais del_tend_com del_tend_barrio 
predict pc_6, score
pca del_inseg1 del_inseg2 del_inseg3
predict pc_7, score
pca del_vict del_arma 
predict pc_8, score
pca del_inseg1 del_inseg2 del_inseg3 del_vict del_arma 
predict pc_9, score
pca del_inseg4 del_vict del_arma 
predict pc_10, score
pca del_inseg4 del_arma 
predict pc_11, score
pca del_inseg4 del_vict 
predict pc_12, score
pca del_inseg5 del_vict del_arma
predict pc_13, score
pca del_inseg5 del_arma
predict pc_14, score
pca del_inseg5 del_vict 
predict pc_15, score
pca del_problema1 del_afecta1 del_calvida1 del_inseg5 del_vict
predict pc_16, score
pca del_problema3 del_afecta3 del_calvida1 del_inseg5 del_vict
predict pc_17, score
pca del_problema3 del_afecta3 del_calvida3 del_inseg5
predict pc_18, score
pca del_problema3 del_afecta3 del_calvida3 del_inseg5 del_vict
predict pc_19, score

pca Index_Ve Index_Vi del_arma
predict pc_20, score

foreach v of varlist pc_1 pc_2 pc_3 pc_4 pc_5 pc_6 pc_7 pc_8 pc_9 pc_10 pc_11 pc_12 pc_13 pc_14 pc_15 pc_16 pc_17 pc_18 pc_19 pc_20{
    qui summ `v'
    replace `v' = (`v' - r(min)) / (r(max) - r(min))
}


gen crime_rising = del_tend_pais==1 | del_tend_com == 1 | del_tend_barrio ==1

* Genero variable para luego colapsar la data SUMANDO la cantidad de crimenes que sufrio cada individuo
egen crimenes=rowtotal(a3_1_1_N_Veces b3_1_1_N_Veces c1_1_1_N_Veces d3_1_1_N_Veces e3_1_1_N_Veces g1_1_1_N_Veces)
label var crimenes "Cantidad de crimenes que sufrio el individuo"

* Cost-weighted sum of crimes (Aaron Chalfin and Justin McCrary)
gen vict_agreg_costweight=(36*vict_roboviolent+12*vict_robosorpr+12*vict_hurto+21*vict_roboviv+163*vict_lesiones+26*vict_robovehi)/270

*Agrego los controles de CASEN 2006
merge n:1 cod_com year using controlesCASEN06_17.dta
keep if _merge==3
drop _merge

foreach var in  crime_rising pc_1 pc_2 pc_3 pc_4 pc_5 pc_6 pc_7 pc_8 pc_9 pc_10 pc_11 pc_12 pc_13 pc_14 pc_15 pc_16 pc_17 pc_18 pc_19 pc_20 del_problema1 del_problema2 del_problema3 del_afecta1 del_afecta2 del_afecta3 del_tend_pais del_tend_com del_tend_barrio del_calvida1 del_calvida2 del_calvida3 del_inseg1 del_inseg2 del_inseg3 del_inseg4 del_inseg5 del_vict del_arma vict_agreg vict_property vict_violent vict_roboviolent vict_robosorpr vict_roboviv vict_hurto vict_lesiones vict_robovehi vict_robo_desdevehi vict_delecon vict_car Index_Vivienda Index_Vecinos{
	bys cod_com year: egen bas_`var' =mean( `var') 
	replace  bas_`var'  = . if year !=2008
	sort cod_com year
	replace bas_`var' = bas_`var'[_n-1] if year !=2008 & cod_com[_n-1]==cod_com[_n]
}

keep if year > 2007

cd "$final"
save enusc_OLS, replace



