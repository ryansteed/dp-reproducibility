* Do-file para generar la base que se utiliza para la Tabla A.10 (Column 8)


*IV - baseline, permisos y visas
* Genero la variable endogena y el instrumento
{
cd "$rawdata"
* Cargo la base de extranjeria para quedarme con la cantidad de inmigrantes por comuna de los "paises de origen"
use immigration_Correciones, clear

* Tiro las observaciones con problemas que habia identificado antes (comuna mal asignada o missing)
drop if comuna=="florida" & cod_com==8404
drop if cod_com==96
* Cambio los nombres para que sean mas faciles de manejar
replace cat_pais="eeuu" if cat_pais=="estados unidos"
foreach country in "haiti" "peru" "colombia" "venezuela" "bolivia" "argentina" "ecuador" "espana" "china" "brasil"{
	replace cat_pais=substr("`country'",1,3) if cat_pais=="`country'"
}
* Ordeno y colapso la base por comuna y por año
sort cod_com year
* Genero las dummies de inmigracion por los paises
foreach country in  "col" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra"{
	gen imm_`country'=(cat_pais=="`country'")
}

gen imm_haiperven=(cat_pais=="hai"|cat_pais=="per"|cat_pais=="ven")

* Gente con permiso: residencia permanente
gen imm_permiso=(doc=="pd")
* Gente con visa: residencia temporaria o sujeta a contrato
gen imm_visa=(doc=="visa")

collapse (sum) imm*, by(cod_com year)
cd "$conf_intermed"
save ImmigrationOrigen_permisos_haiperven, replace

* Genero los stocks de inmigrantes para cada comuna y cada año
* Primero genero stocks de inmigrantes en 2002 con la base del censo y despues le hago un append a la base actual
* -------------------------------------------------------------------------
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
keep if _merge==1	// Queda de esta forma una base de inmigrantes
*groups Codigo, order(h)
* Resultados: 
* 20020 "estados unidos"
* 20004 "argentina"
* 20010 "bolivia"
* 20014 "colombia"
* 20018 "ecuador"
* 20042 "peru"
* 20052 "venezuela"
* 40014 "espana"
* 30011 "china"
* 20011 "brasil"
* 40002 "alemania"
* 40025 "italia"
* 20027 "haiti"

* Ahora tiro todas las otras cosas que no necesito

* Me quedo con los inmigrantes de los paises que quiero	
keep if Codigo==20020 | Codigo==20004 | Codigo==20010 | Codigo==20014 | Codigo==20018 | Codigo==20042 | Codigo==20052 | Codigo==40014 | Codigo==30011 | Codigo==20011 | Codigo==40002 | Codigo==40025 | Codigo==20027

* Variables que no tengan que ver con pais de origen o residencia en chile
keep P22A Codigo P22C P23A P23B P24A P24B CodigoActual comuna
* Ahora tengo que averiguar cuantos de los nacidos en otro pais residen en chile o no
rename Codigo P22B
rename P23B Codigo
merge m:1 Codigo using COMUNAS

drop if _merge==2 	// Son 4 observaciones, supongo que hay 4 comunas en las que no habia ningun inmigrante de los paises de arriba
drop if _merge==1 	// 7662 observaciones que reportaron no nacer en chile y residir en algun pais del extranjero (su respuesta a P23A no fue ninguna comuna chilena)

rename Codigo P23B
rename CodigoActual cod_com
gen imm=1
tostring P22B, gen(strP22B)
rename strP22B cat_pais
replace cat_pais="eeuu" if cat_pais=="20020"
replace cat_pais="arg" if cat_pais=="20004"
replace cat_pais="bol" if cat_pais=="20010"
replace cat_pais="col" if cat_pais=="20014"
replace cat_pais="ecu" if cat_pais=="20018"
replace cat_pais="per" if cat_pais=="20042"
replace cat_pais="ven" if cat_pais=="20052"
replace cat_pais="esp" if cat_pais=="40014"
replace cat_pais="chi" if cat_pais=="30011"
replace cat_pais="bra" if cat_pais=="20011"
replace cat_pais="ale" if cat_pais=="40002"
replace cat_pais="ita" if cat_pais=="40025"
replace cat_pais="hai" if cat_pais=="20027"

gen year=2002
keep cat_pais cod_com comuna year imm

foreach country in "eeuu" "arg" "bol" "col" "ecu" "chi" "bra" "ale" "ita" "esp" {
	gen imm_`country'=(cat_pais=="`country'")
}

gen imm_haiperven=(cat_pais=="hai"|cat_pais=="per"|cat_pais=="ven")

collapse (sum) imm*, by(cod_com year)
cd "$conf_intermed"
save CensoInmigr2002_haiperven, replace
gen imm_permiso=imm
gen imm_visa=imm

append using ImmigrationOrigen_permisos_haiperven

* Ahora saco stocks por año
sort cod_com year
bys cod_com: gen stock_imm=sum(imm)
foreach country in "eeuu" "arg" "bol" "col" "ecu" "haiperven" "chi" "bra" "ale" "ita" "esp" "permiso" "visa"{
	bys cod_com: gen `country'=sum(imm_`country')
}
* Ahora me quedan stocks. Cambio los nombres de las variables para que corra el codigo de abajo (que estaba armado para las variables flujo)
rename imm immflujo
rename stock_imm imm
foreach pais in "eeuu" "arg" "bol" "col" "ecu" "haiperven" "chi" "bra" "ale" "ita" "esp" "permiso" "visa"{
	rename imm_`pais' `pais'flujo
	rename `pais' imm_`pais'
}


* Tiro los años que no quiero para la diferencia relevante (para la variable del total de inmigrantes)
keep if year==2017 | year==2008
* Como hay comunas en ciertos años que no tienen migrantes de determinada nacionalidad, la base no queda completa. Usamos una base con la totalidad de las comunas, con los años 2010 y 2017, para cada país de origen para completar la base.
save ImmigrationOrigen_permisos_haiperven, replace
cd "$rawdata"
import excel using Cod_com, firstrow clear
drop country_origin
sort cod_com year
quietly by cod_com year: gen dup=cond(_N==1,0,_n)
drop if dup > 1
drop dup
replace year=2008 if year==2010
cd "$conf_intermed"
save Cod_com, replace
use ImmigrationOrigen_permisos_haiperven, clear
merge 1:1 cod_com year using Cod_com
drop _merge
sort cod_com year

replace imm=0 if imm==.
foreach country in "haiperven" "col" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra" "permiso" "visa"{
	replace imm_`country'=0 if imm_`country'==.
}
save ImmigrationOrigen_permisos_haiperven, replace

* Vamos por las variables endogenas
keep cod_com year imm imm_permiso imm_visa
save FinalBase_permisos_haiperven, replace
use population, clear
merge 1:m cod_com using FinalBase_permisos_haiperven
drop if _merge==1	// no necesario
drop _merge
sort cod_com year

* Genero las tasas de DeltaIMM con la poblacion
foreach j in "" "_permiso" "_visa"{
	replace imm`j'=imm`j'*100000/population
}
sort cod_com year
* Ahora solo pongo la inmigracion dividida en permisos y visas en logaritmos, la otra va sin logs /*(no me queda claro a que se refiere con esto)*/
foreach j in "" "_permiso" "_visa"{
	//gen lndelta_imm`j'=ln(imm`j'+1)
	gen lndelta_imm`j'=ln(imm`j'*1000+1)
	bysort cod_com (year) : gen deltaimm`j' = lndelta_imm`j' - lndelta_imm`j'[_n-1]
}

* Ahora si, me queda lo que queria: una base cross-section para 2017 con cod_com year y deltaimm
drop if year!=2017
keep comuna cod_com year population deltaimm*

save FinalBase_permisos_haiperven, replace

* Sigo con la base de la UN. Altere la base desde el excel dejando todas las celdas con "." en blanco para que no lea las variables como strings
* Esta base esta en stocks
cd "$rawdata"
import excel UN_MigrantStock.xlsx, sheet(Hoja1) firstrow clear

* Tiro los años pre-2005
drop if year<2005

* Dejamos como países de origen los 11 países definidos anteriormente
keep country_destination year Haiti Argentina Bolivia China Colombia Ecuador Peru Spain UnitedStatesofAmerica Venezuela Brazil
* solo latam (EXCEPTO CHILE)
keep if country_destination=="Argentina" | country_destination=="Bolivia (Plurinational State of)" | country_destination=="Brazil" | country_destination=="Colombia" | country_destination=="Costa Rica" | country_destination=="Cuba" | country_destination=="Ecuador" | country_destination=="El Salvador" | country_destination=="Guatemala" | country_destination=="Honduras" | country_destination=="Mexico" | country_destination=="Nicaragua" | country_destination=="Panama" | country_destination=="Paraguay" | country_destination=="Peru" | country_destination=="Puerto Rico" | country_destination=="Dominican Republic" | country_destination=="Uruguay" | country_destination=="Venezuela (Bolivarian Republic of)"

sort country_destination year
collapse (sum) Haiti Argentina Bolivia China Colombia Ecuador Peru Spain UnitedStatesofAmerica Venezuela Brazil, by(year)

rename UnitedStatesofAmerica eeuu
rename Spain esp
rename *, lower
foreach var in haiti argentina bolivia china colombia ecuador peru venezuela brazil{
	local newname=substr("`var'",1,3)
	rename `var' `newname'
}

* Para expresarlo en logaritmos y quedarme solo con 2010 y 2017. Esto nos deja las variables ln(IMM_{t}^{n})
sort year
foreach country in "col" "bol" "arg" "ecu" "chi" "eeuu" "esp" "bra"{
	gen ln_orig_`country'=ln(`country')
	drop `country'
}
gen ln_orig_haiperven=ln(hai+per+ven)
drop hai per ven

* Tiro los años que no sean 2010 o 2017 y calculo la diferencia de los logaritmos. Esto me deja con Deltaln(IMM_{t}^{n})
keep if year==2010 | year==2017

foreach country in "haiperven" "col" "bol" "arg" "ecu" "chi" "eeuu" "esp" "bra"{
	gen delta_ln_orig_`country' = ln_orig_`country' - ln_orig_`country'[_n-1]
 	drop ln_orig_`country'
}
drop if year==2010
* Esta base tiene la variable que voy a sumar a lo largo de los 11 paises para construir el instrumento (ponderada por los shares de inmigrantes)
cd "$conf_intermed"
save DeltaImmigrationSupply_permisos_haiperven, replace

* Calculo los shares (theta_{m,t-1}^{n}) para 2008 (y pongo year=2017 para que despues me quede todo en una base cross-section). primero calculo los stocks pertinentes sumando los inmigrantes del censo 2002
cd "$rawdata"
use immigration_Correciones, clear
drop if comuna=="florida" & cod_com==8404
drop if cod_com==96
replace cat_pais="eeuu" if cat_pais=="estados unidos"
replace cat_pais="repdom" if cat_pais=="republica dominicana"
foreach country in "haiti" "peru" "colombia" "venezuela" "bolivia" "argentina" "ecuador" "espana" "china" "brasil" "paraguay" "mexico"{
	replace cat_pais=substr("`country'",1,3) if cat_pais=="`country'"
}
foreach country in "col" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra"{
	gen imm_`country'=(cat_pais=="`country'")
	gen imm_`country'_permiso=(cat_pais=="`country'" & doc=="pd")
	gen imm_`country'_visa=(cat_pais=="`country'" & doc=="visa")
}

gen imm_haiperven =(cat_pais=="hai"|cat_pais=="per"|cat_pais=="ven")
gen imm_haiperven_permiso=(cat_pais=="hai" & doc=="pd"|cat_pais=="per" & doc=="pd"|cat_pais=="ven" & doc=="pd")
gen imm_haiperven_visa=(cat_pais=="hai" & doc=="visa"|cat_pais=="per" & doc=="visa"|cat_pais=="ven" & doc=="visa")

sort cod_com year
gen imm_permiso=(doc=="pd")
gen imm_visa=(doc=="visa")
collapse (sum) imm*, by(cod_com year)
rename imm_* *
rename permiso imm_permiso
rename visa imm_visa
cd "$conf_intermed"
save ImmigrationStocks_permisos_haiperven, replace

* Abro la base del censo que habia creado antes y la junto con la de inmigracion por año para generar stocks
use CensoInmigr2002_haiperven, clear

foreach pais in "haiperven" "eeuu" "arg" "bol" "col" "ecu" "chi" "bra" "ale" "ita" "esp" {
	rename imm_`pais' `pais'
	gen `pais'_permiso=`pais'
	gen `pais'_visa=`pais'
}

gen imm_permiso=imm
gen imm_visa=imm
append using ImmigrationStocks_permisos_haiperven

* Para sumar inmigracion por año y tener stocks
sort cod_com year
bys cod_com: gen stock_imm=sum(imm)
bys cod_com: gen stock_imm_permiso=sum(imm_permiso)
bys cod_com: gen stock_imm_visa=sum(imm_visa)

foreach country in "haiperven" "col" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra"{
	bys cod_com: gen imm_`country'=sum(`country')
	bys cod_com: gen imm_`country'_permiso=sum(`country'_permiso)
	bys cod_com: gen imm_`country'_visa=sum(`country'_visa)
	drop `country' `country'_permiso `country'_visa
}
drop if year!=2008
save ImmigrationStocks_permisos_haiperven, replace

* Como hay comunas en ciertos años que no tienen migrantes de determinada nacionalidad, la base no queda completa. Usamos una base con la totalidad de las comunas, con los años 2008 y 2017, para cada país de origen para completar la base.
cd "$rawdata"
import excel using Cod_com, firstrow clear
drop country_origin
sort cod_com year
quietly by cod_com year: gen dup=cond(_N==1,0,_n)
drop if dup > 1
drop dup
drop if year!=2010
replace year=2008 if year==2010
cd "$conf_intermed"
save Cod_com2, replace
use ImmigrationStocks_permisos_haiperven, clear
merge 1:1 cod_com year using Cod_com2
drop _merge
sort cod_com year
replace stock_imm=0 if stock_imm==.
replace stock_imm_permiso=0 if stock_imm_permiso==.
replace stock_imm_visa=0 if stock_imm_visa==.

foreach country in "haiperven" "col" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra"{
	replace imm_`country'=0 if imm_`country'==.
	replace imm_`country'_permiso=0 if imm_`country'_permiso==.
	replace imm_`country'_visa=0 if imm_`country'_visa==.

}
save ImmigrationStocks_permisos_haiperven, replace
* Ahora me quedo con los stocks de 2008 y calculo los shares
drop if year!=2008
replace year=2017 if year==2008

foreach country in "haiperven" "col" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra"{
	gen share2008_`country'=(imm_`country')/stock_imm
	gen share2008_`country'_permiso=(imm_`country'_permiso)/stock_imm_permiso
	gen share2008_`country'_visa=(imm_`country'_visa)/stock_imm_visa
	replace share2008_`country'=0 if share2008_`country'==.
	replace share2008_`country'_permiso=0 if share2008_`country'_permiso==.
	replace share2008_`country'_visa=0 if share2008_`country'_visa==.
}
keep cod_com year share2008_*

sort cod_com year
merge 1:1 cod_com year using FinalBase_permisos_haiperven		// base que contiene las variables endogenas
keep if _merge==3
drop _merge

merge m:1 year using DeltaImmigrationSupply_permisos_haiperven
* Merge perfecto
drop _merge

* Ahora solo falta construir el instrumento para cada comuna de 2017 con las variables que estan en la base
foreach country in "haiperven" "col" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra"{
	foreach j in "" "_permiso" "_visa"{
		gen imm_com_`country'`j'=share2008_`country'`j'*delta_ln_orig_`country'
		drop share2008_`country'`j'
	}
	drop delta_ln_orig_`country'
}
* Genero el instrumento y ya tengo el lado izquierdo de la regresion. Falta crimen
foreach j in "_permiso" "_visa"{
	egen deltaimm_instr`j'=rowtotal(imm_com_*`j')
}
egen deltaimm_instr=rowtotal(imm_com_haiperven imm_com_col imm_com_bol imm_com_arg imm_com_ecu imm_com_eeuu imm_com_esp imm_com_chi imm_com_bra)
drop imm_com_*

** Se agregan regiones que faltaban (tendran missing values en la variable endogena y en el instrumento)
save FinalBase_permisos_haiperven, replace
cd "$rawdata"
import excel com_region, sheet(Com_Region) firstrow clear
destring region, replace
cd "$conf_intermed"
merge 1:1 cod_com using FinalBase_permisos_haiperven		
drop _merge
save FinalBase_permisos_haiperven, replace

* Usando solo las 101 comunas de ENUSC
cd "$rawdata"
use base_final_2008_2017, clear
cd "$conf_intermed"
rename id_comuna15 cod_com
drop year
sort cod_com
quietly by cod_com: gen dup=cond(_N==1,0,_n)
drop if dup > 1
drop dup
drop kish
merge 1:1 cod_com using FinalBase_permisos_haiperven
keep if _merge==3
drop _merge

save FinalBase101_permisos_haiperven, replace
***************************************************
* Controles de la casen2006:
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
foreach var in hombre age ypc esc{
	replace `var'=`var'*expc
}
* Colapsando la suma de expc a nivel comuna voy a tener el denominador para calcular los % de cada variable
collapse (sum) hombre age ypc expc, by(cod_com)
* Genero las tasas:
foreach var in hombre age ypc{
	replace `var'=`var'/expc
}
gen year=2017
* Le faltan comunas
cd "$conf_intermed"
save controlesCASEN, replace
/*
merge 1:1 cod_com using FinalBase
keep if _merge==3
drop _merge
save FinalBase_2, replace
*/

* Para quedarme con las 101 de ENUSC
cd "$rawdata"
use base_final_2008_2017, clear
cd "$conf_intermed"
rename id_comuna15 cod_com
drop year
sort cod_com
quietly by cod_com: gen dup=cond(_N==1,0,_n)
drop if dup > 1
drop dup
collapse (mean) kish, by(cod_com)
drop kish
merge 1:1 cod_com using controlesCASEN
keep if _merge==3
drop _merge
*save controlesCASEN101, replace
merge 1:1 cod_com using FinalBase101_permisos_haiperven
keep if _merge==3
* Tiro todo lo que no vaya a usar como control o instrumento
drop _merge
save FinalBase101_permisos2_haiperven, replace
********************************************************
}


* Generamos las variables dependientes (outcomes homicidios de la base de carabineros)
{
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
keep if year==2008|year==2017		// Se puede verificar que el panel esta balanceado. Hay data para 320 comunas
cd "$conf_intermed"
save homicidios_victimas_cead_2008and2017, replace 


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
keep if year==2008|year==2017		// Se puede verificar que el panel esta balanceado. Hay data para 320 comunas
cd "$conf_intermed"
save homicidios_victimarios_cead_2008and2017, replace 

* Junto base de victimas y victimarios
merge 1:1 comuna year using homicidios_victimas_cead_2008and2017
drop _merge

* Corrijo variable comuna para hacer el merge con base que contiene a las poblaciones de 2010 y 2017
replace comuna="aisen" if comuna=="Aysén"
replace comuna="calera" if comuna=="La Calera"
replace comuna="marchihue" if comuna=="Marchigüe"
replace comuna="el olivar" if comuna=="Olivar" 
replace comuna = ustrlower( ustrregexra( ustrnormalize( comuna, "nfd" ) , "/p{Mark}", "" )  )
save homicidios_cead_2008and2017, replace 


* Abrimos base de poblacion (usamos la poblacion del 2010 como la del 2008 ya que no hay datos para este anio) y luego hacemos el merge con la base de outcomes de crimen
use "$rawdata/population", clear
merge 1:m comuna using homicidios_cead_2008and2017
keep if _merge==3
drop _merge

** Genero variables per capita (tasa de crimen)
rename population pop
foreach j in homicidios1 homicidios_chilenos1 homicidios_nchilenos1 homicidios2 homicidios_chilenos2 homicidios_nchilenos2{
	gen log_`j'=log(`j'+1)
	gen `j'pc = `j'*100000/pop
	gen log_`j'pc=ln(`j'pc+1)
}

save homicidios_cead_2008and2017, replace

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
merge 1:m cod_com using homicidios_cead_2008and2017
keep if _merge==3
drop _merge

* Generamos las variables dependientes de interes en diferencias
foreach j in homicidios1 homicidios_chilenos1 homicidios_nchilenos1 homicidios2 homicidios_chilenos2 homicidios_nchilenos2{
	sort cod_com year
	bysort cod_com : gen delta`j' =  `j' - `j'[_n-1]
	bysort cod_com : gen dlog_`j' = log_`j' - log_`j'[_n-1]
	
	bysort cod_com : gen d`j'pc =  `j'pc -  `j'pc[_n-1]
	bysort cod_com : gen dl_`j'pc = log_`j'pc - log_`j'pc[_n-1]		
	
}

keep if year==2017


save diffhomicidios_cead_2017, replace


** Merge con base de datos que contiene el instrumento, la variable endogena y los controles
cd "$conf_intermed"
u diffhomicidios_cead_2017, clear
merge 1:1 cod_com using FinalBase101_permisos2_haiperven
keep if _merge==3
drop _merge


keep year cod_com pop population hombre age delta* dlog* d* dl_* 

cd "$conf_final"
save homicides_IV_haiperven, replace
}

