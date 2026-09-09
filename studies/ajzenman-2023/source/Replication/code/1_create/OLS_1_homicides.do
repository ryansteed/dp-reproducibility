* Do-file para generar la base que se utiliza para las tablas I, VI y A.2, y figura VII (Panel b)



*Controles CASEN para el panel
{
* 2 0 0 6 ----------------------------------------------

cd "$rawdata"
import excel División-Político-Administrativa-y-Servicios-de-Salud-Histórico.xls, firstrow clear
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
cd "$conf_intermed"
save controlesCASEN06, replace

* 2 0 0 9 ----------------------------------------------

cd "$rawdata"

import excel División-Político-Administrativa-y-Servicios-de-Salud-Histórico.xls, firstrow clear
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

cd "$conf_intermed"
save controlesCASEN09, replace


* 2 0 1 1 ----------------------------------------------

cd "$rawdata"
*import spss  using "C:/Users/USUARIO/Documents/Asistente/Migration Chile/ADU_Franco/Do_Franco/Resultados Junio/Bases de datos/casen2011_octubre2011_enero2012_principal_08032013spss.sav", clear
*save casen2011, replace
import excel División-Político-Administrativa-y-Servicios-de-Salud-Histórico.xls, firstrow clear
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

cd "$conf_intermed"
save controlesCASEN11, replace


* 2 0 1 3 ----------------------------------------------

cd "$rawdata"
import excel División-Político-Administrativa-y-Servicios-de-Salud-Histórico.xls, firstrow clear
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
cd "$conf_intermed"
save controlesCASEN13, replace


* 2 0 1 5 ----------------------------------------------

cd "$rawdata"
import excel División-Político-Administrativa-y-Servicios-de-Salud-Histórico.xls, firstrow clear
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
cd "$conf_intermed"
save controlesCASEN15, replace


* 2 0 1 7 ----------------------------------------------
/*
*Con estas lineas resuelvo el problema del codigo de las comunas ñuble, que cambio y arruinaba el merge (tiraba 20 comunas de mas)
import excel División-Político-Administrativa-y-Servicios-de-Salud-Histórico.xls, firstrow clear
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
import excel División-Político-Administrativa-y-Servicios-de-Salud-Histórico.xls, firstrow clear
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

cd "$conf_intermed"
save controlesCASEN17, replace


*Junto las casen por años
cd "$conf_intermed"
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
}

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

cd "$conf_intermed"
save immigration_tablaOLS, replace

* CENSO 2002
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
/* no aparece este numero. Si comparo con el codigo IV_1, en este no se eliminan los paises que luego se usan para crear el instrumento*/

rename Codigo P23B
rename CodigoActual cod_com
gen imm=1
gen imm_permiso=1
gen imm_visa=1
gen year=2002
keep cod_com comuna year imm*

collapse (sum) imm*, by(cod_com year)
cd "$conf_intermed"
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
cd "$conf_intermed"
save population, replace

cd "$rawdata"
use cod_com, clear
cd "$conf_intermed"
merge 1:1 comuna using population
drop _merge NombreComuna
cd "$rawdata"
merge 1:1 cod_com using cod_reg
cd "$conf_intermed"
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
	gen rate_`var'=`var'*100000/population	
	gen lnrate_`var'=ln(rate_`var'+1)
}

* Esta base tiene inmigracion, poblacion por comuna y año, codigos de comuna y region y nombre de comuna 
save immigration_tablaOLS, replace



* Generamos base de datos que contiene los outcomes de homicidios

***** Victimas *****
cd "$conf_rawdata"
import excel "Nacionalidad participantes homicidios.xlsx", sheet("Víctimas") cellrange(C12:T794) firstrow clear

label var ComunaParte ""
label var Nacionalidad ""

foreach var of varlist * {
    local label : variable label `var'
    if ("`label'" != "") {
        local oldnames `oldnames' `var'
        local newnames `newnames' year_`label'
    }
}

rename (`oldnames')(`newnames')

* Wide to Long Format
reshape long year_, i(ComunaParte Nacionalidad ) j(year)
rename year_ homicidios_victimas
rename ComunaParte comuna

* Creo variables de homicidios: total, chilenos y extranjeros
gen homicidios1=homicidios_victimas if Nacionalidad=="Total Comuna"
gen homicidios_chilenos1=homicidios_victimas if Nacionalidad=="Chilena"
gen homicidios_nchilenos1=homicidios_victimas if (Nacionalidad!="Total Comuna"&Nacionalidad!="Chilena"&Nacionalidad!="No indica"&Nacionalidad!="Sin información")

collapse (sum) homicidios1 homicidios_chilenos1 homicidios_nchilenos1, by( comuna year)

save homicidios_victimas_cead, replace

* Restrinjo a los anios para los cuales voy a tomar las diferencias
keep if year>2007&year<2018		
cd "$conf_intermed"
save homicidios_victimas_cead_200817, replace 


***** Victimarios *****
cd "$conf_rawdata"
import excel "Nacionalidad participantes homicidios.xlsx", sheet("Victimarios") cellrange(C12:T723) firstrow clear
label var ComunaParte ""
label var Nacionalidad ""

foreach var of varlist * {
    local label : variable label `var'
    if ("`label'" != "") {
        local oldnamesb `oldnamesb' `var'
        local newnamesb `newnamesb' year_`label'
    }
}

rename (`oldnamesb')(`newnamesb')

* Wide to Long Format
reshape long year_, i(ComunaParte Nacionalidad ) j(year)
rename year_ homicidios_victimarios
rename ComunaParte comuna

* Creo variables de homicidios: total, chilenos y extranjeros
gen homicidios2=homicidios_victimarios if Nacionalidad=="Total comuna"
gen homicidios_chilenos2=homicidios_victimarios if Nacionalidad=="Chilena"
gen homicidios_nchilenos2=homicidios_victimarios if (Nacionalidad!="Total comuna"&Nacionalidad!="Chilena"&Nacionalidad!="No indica"&Nacionalidad!="Sin información")

collapse (sum) homicidios2 homicidios_chilenos2 homicidios_nchilenos2, by( comuna year)

save homicidios_victimarios_cead, replace

* Restrinjo a los anios para los cuales voy a tomar las diferencias
keep if year>2007&year<2018		
cd "$conf_intermed"
save homicidios_victimarios_cead_200817, replace 

* Junto base de victimas y victimarios
merge 1:1 comuna year using homicidios_victimas_cead_200817
drop _merge

* Corrijo variable comuna para hacer el merge con base que contiene a las poblaciones de 2010 
replace comuna="aisen" if comuna=="Aysén"
replace comuna="calera" if comuna=="La Calera"
replace comuna="marchihue" if comuna=="Marchigüe"
replace comuna="el olivar" if comuna=="Olivar" 
replace comuna = ustrlower( ustrregexra( ustrnormalize( comuna, "nfd" ) , "/p{Mark}", "" )  )
save homicidios_cead_200817, replace 


* Abrimos base de poblacion y luego hacemos el merge con la base de outcomes de crimen
use "$rawdata/population", clear
merge 1:m comuna using homicidios_cead_200817
keep if _merge==3
drop _merge

** Genero variables per capita (tasa de crimen)
foreach j in homicidios1 homicidios_chilenos1 homicidios_nchilenos1 homicidios2 homicidios_chilenos2 homicidios_nchilenos2{
	gen log_`j'=log(`j'+1)
	gen `j'pc = `j'*100000/pop
	gen log_`j'pc=ln(`j'pc+1)
}

xtset cod_com year
foreach j in homicidios1 homicidios_chilenos1 homicidios_nchilenos1 homicidios2 homicidios_chilenos2 homicidios_nchilenos2{
* Variable de extensive margin
gen extmargin_`j' = (`j'>0&L.`j'==0) if year!=2008

* Variable de intensive margin
gen intmargin`j' = (`j'-L.`j'>0) if year!=2008

}

save homicidios_cead_200817, replace

** Para quedarme con las 101 comunas de ENUSC
cd "$rawdata"
use base_final_2008_2017, clear
rename id_comuna15 cod_com
drop year
sort cod_com
quietly by cod_com: gen dup=cond(_N==1,0,_n)
drop if dup > 1
drop dup
collapse (mean) kish, by(cod_com)
drop kish

cd "$conf_intermed"
merge 1:m cod_com using homicidios_cead_200817
keep if _merge==3
drop _merge

save ols_homicidios_cead_200817, replace

** Merge con base que tiene el principal regresor de inmigracion
merge m:1 cod_com year using immigration_tablaOLS
keep if _merge==3
drop _merge

*Agrego los controles de CASEN 2006
merge 1:1 cod_com year using controlesCASEN06_17.dta
keep if _merge==3
drop _merge

foreach var in  homicidios1 homicidios_chilenos1 homicidios_nchilenos1 homicidios2 homicidios_chilenos2 homicidios_nchilenos2 homicidios1pc homicidios_chilenos1pc homicidios_nchilenos1pc homicidios2pc homicidios_chilenos2pc homicidios_nchilenos2pc log_homicidios1pc log_homicidios_chilenos1pc log_homicidios_nchilenos1pc log_homicidios2pc log_homicidios_chilenos2pc log_homicidios_nchilenos2pc{
	bys cod_com year: egen bas_`var' =mean( `var') 
	replace  bas_`var'  = . if year !=2008
	sort cod_com year
	replace bas_`var' = bas_`var'[_n-1] if year !=2008 & cod_com[_n-1]==cod_com[_n]
}

cd "$conf_final"
save homicides_OLS, replace


