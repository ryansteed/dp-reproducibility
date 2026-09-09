* Do-file para generar la base que se utiliza para la Tabla XII (Panel B.4)


*Variable endogena por año - comuna (la misma que para OLS)
{
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
save IV_panel, replace

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
cd "$conf_intermed"
save collapse2002, replace

append using IV_panel

* Ahora saco stocks por año para las 3 variables
sort cod_com year
foreach j in "" "_permiso" "_visa"{
	bys cod_com: gen stock_imm`j'=sum(imm`j')
}

keep if year > 2007
drop if year==2018
save IV_panel, replace

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

merge 1:1 cod_com year using IV_panel
mvencode imm* stock* if _merge==1, mv(0)
drop _merge

* Genero rate y log rate de inmigracion para visas y permisos
foreach var in stock_imm stock_imm_permiso stock_imm_visa{
	gen rate_`var'=`var'*10000/population
	gen lnrate_`var'=ln(rate_`var'+1)
}


* Esta base tiene inmigracion, poblacion por comuna y año, codigos de comuna y region y nombre de comuna 
save IV_panel, replace
}

* Ahora genero el instrumento. 
{

* Empiezo con la base de la UN. Altere la base desde el excel dejando todas las celdas con "." en blanco para que no lea las variables como strings
* Primero genero una base de datos con los años para que sea facil correr el comando para interpolar
clear 
set obs 27
gen year=1990
forvalues i=2/27{
	replace year = year + `i' if _n==`i'
}
cd "$conf_intermed"
save years, replace
* Esta base esta en stocks
cd "$rawdata"
import excel UN_MigrantStock.xlsx, sheet(Hoja1) firstrow clear

* Dejamos como países de origen los 10 países definidos anteriormente
keep country_destination year Haiti Argentina Bolivia China Colombia Ecuador Peru Spain UnitedStatesofAmerica Venezuela Brazil
* solo latam
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

sort year
merge 1:1 year using "$conf_intermed/years"
sort year
drop _merge

* Interpolo los años faltantes ()
foreach country in "hai" "per" "col" "ven" "bol" "arg" "ecu" "chi" "eeuu" "esp" "bra"{
	ipolate `country' year, generate(ipol_`country')
}

keep year ipol_*

* Para expresarlo en logaritmos y quedarme solo con 2010 y 2017. Esto nos deja las variables ln(IMM_{t}^{n})
sort year
foreach country in "hai" "per" "col" "ven" "bol" "arg" "ecu" "chi" "eeuu" "esp" "bra"{
	gen ln_orig_`country'=ln(ipol_`country')
	drop ipol_`country'
}

* Tiro los años pre-2008
drop if year<2008
keep year ln_orig*

cd "$conf_intermed"
merge 1:m year using IV_panel
drop _merge
sort cod_com year
save IV_panel, replace

* Calculo los shares (theta_{m,t-1}^{n}) para 2008. primero calculo los stocks pertinentes sumando los inmigrantes del censo 2002
cd "$rawdata"
use immigration_Correciones, clear
drop if comuna=="florida" & cod_com==8404
drop if cod_com==96
replace cat_pais="eeuu" if cat_pais=="estados unidos"
replace cat_pais="repdom" if cat_pais=="republica dominicana"
foreach country in "haiti" "peru" "colombia" "venezuela" "bolivia" "argentina" "ecuador" "espana" "china" "brasil" "paraguay" "mexico"{
	replace cat_pais=substr("`country'",1,3) if cat_pais=="`country'"
}
foreach country in "hai" "per" "col" "ven" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra"{
	gen imm_`country'=(cat_pais=="`country'")
	gen imm_`country'_permiso=(cat_pais=="`country'" & doc=="pd")
	gen imm_`country'_visa=(cat_pais=="`country'" & doc=="visa")
}

sort cod_com year
gen imm_permiso=(doc=="pd")
gen imm_visa=(doc=="visa")

collapse (sum) imm*, by(cod_com year)
rename imm_* *
rename permiso imm_permiso
rename visa imm_visa

cd "$conf_intermed"
save ImmigrationStocks_permisos, replace

* Abro la base del censo que habia creado antes y la junto con la de inmigracion por año para generar stocks
use CensoInmigr2002, clear

foreach pais in "eeuu" "arg" "bol" "col" "ecu" "per" "ven" "chi" "bra" "ale" "ita" "esp" "hai"{
	rename imm_`pais' `pais'
	gen `pais'_permiso=`pais'
	gen `pais'_visa=`pais'
}
gen imm_permiso=imm
gen imm_visa=imm

append using ImmigrationStocks_permisos
sort cod_com year
* Para sumar inmigracion por año y tener stocks
sort cod_com year
bys cod_com: gen stock_imm=sum(imm)
bys cod_com: gen stock_imm_permiso=sum(imm_permiso)
bys cod_com: gen stock_imm_visa=sum(imm_visa)

foreach country in "hai" "per" "col" "ven" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra"{
	bys cod_com: gen imm_`country'=sum(`country')
	bys cod_com: gen imm_`country'_permiso=sum(`country'_permiso)
	bys cod_com: gen imm_`country'_visa=sum(`country'_visa)
	drop `country' `country'_permiso `country'_visa
}
drop if year!=2008
save ImmigrationStocks_permisos, replace

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
use ImmigrationStocks_permisos, clear
merge 1:1 cod_com year using Cod_com2
drop _merge
sort cod_com year
replace stock_imm=0 if stock_imm==.
replace stock_imm_permiso=0 if stock_imm_permiso==.
replace stock_imm_visa=0 if stock_imm_visa==.

foreach country in "hai" "per" "col" "ven" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra"{
	replace imm_`country'=0 if imm_`country'==.
	replace imm_`country'_permiso=0 if imm_`country'_permiso==.
	replace imm_`country'_visa=0 if imm_`country'_visa==.

}
save ImmigrationStocks_permisos, replace
* Ahora tengo los stocks de 2008 y calculo los shares
drop year
*foreach country in "per" "col" "ven" "bol" "hai" "arg" "ecu" "eeuu" "esp" "chi" "bra" "repdom" "par" "mex"{
foreach country in "hai" "per" "col" "ven" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra"{
	gen share2008_`country'=(imm_`country')/stock_imm
	gen share2008_`country'_permiso=(imm_`country'_permiso)/stock_imm_permiso
	gen share2008_`country'_visa=(imm_`country'_visa)/stock_imm_visa
	replace share2008_`country'=0 if share2008_`country'==.
	replace share2008_`country'_permiso=0 if share2008_`country'_permiso==.
	replace share2008_`country'_visa=0 if share2008_`country'_visa==.
}

keep cod_com share2008_*

sort cod_com

merge 1:m cod_com using IV_panel
drop _merge
sort cod_com year

* Ahora genero el instrumento para cada año-comuna (el share de 2008 de cada pais de origen en esa comuna * el stock de inmigrantes de origen de los 11 paises en los paises de destino seleccionados)

* Ahora solo falta construir el instrumento para cada comuna de 2017 con las variables que estan en la base
foreach country in "hai" "per" "col" "ven" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra"{
	foreach j in "" "_permiso" "_visa"{
		gen imm_com_`country'`j'=share2008_`country'`j'*ln_orig_`country'
		
	}
	
}



// foreach country in "hai" "per" "col" "ven" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra"{
// 	gen imm_com_`country'=share2008_`country'*ln_orig_`country'
// 	drop share2008_`country'
// 	drop ln_orig_`country'
// }
* Genero el instrumento y ya tengo el lado izquierdo de la regresion. Falta crimen
foreach j in "_permiso" "_visa"{
	egen imm_instr`j'=rowtotal(imm_com_*`j')
}
egen imm_instr=rowtotal(imm_com_hai imm_com_per imm_com_col imm_com_ven imm_com_bol imm_com_arg imm_com_ecu imm_com_eeuu imm_com_esp imm_com_chi imm_com_bra)
drop imm_com_*

save IV_panel, replace
}

* Sumo las variables dependientes
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
drop if cod_com==5106 | cod_com==5108 | cod_com==5505
drop if kish==0
gen ismale=(sexo==1)
collapse (mean) edad ismale, by(cod_com year)

cd "$conf_intermed"
merge 1:1 cod_com year using homicidios_cead_200817
keep if _merge==3
drop _merge

save ols_homicidios_cead_200817, replace


merge 1:1 cod_com year using IV_panel
keep if _merge==3
drop _merge

*Agrego los controles de CASEN 2006
merge m:1 cod_com year using controlesCASEN06_17.dta
keep if _merge==3
drop _merge

foreach var in  homicidios1 homicidios_chilenos1 homicidios_nchilenos1{
	bys cod_com year: egen bas_`var' =mean( `var') 
	replace  bas_`var'  = . if year !=2008
	sort cod_com year
	replace bas_`var' = bas_`var'[_n-1] if year !=2008 & cod_com[_n-1]==cod_com[_n]
}

keep if year > 2007
sort cod_com year
save "$conf_final/IV_panel_homicides", replace

}

