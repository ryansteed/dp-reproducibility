* Do-file para generar la base que se utiliza para la Tabla XII (Panel B.1-B.3)


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

cd "$intermed"
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
cd "$intermed"
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
cd "$intermed"
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
merge 1:1 year using "$intermed/years"
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

cd "$intermed"
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

cd "$intermed"
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
cd "$intermed"
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
cd "$rawdata"
use base_final_2008_2017, clear
drop if year==2018
rename id_comuna15 cod_com
cd "$intermed"

merge m:1 cod_com year using IV_panel
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
sort cod_com year
save "$final/IV_panel", replace

}

