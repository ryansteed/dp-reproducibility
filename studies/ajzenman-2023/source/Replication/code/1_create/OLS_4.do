* Do-file para generar la base que se utiliza para la Tabla XVII (Columns 1-3)


* Variables independientes (inmigracion y demas)
{
cd "$rawdata"

* Empiezo con la base de extranjería para generar una colapsada a nivel de comuna y año
use immigration_Correciones, clear
* Tiro 2 observaciones que tienen mal el codigo
drop if comuna=="florida" & cod_com==8404
* Tiro 379 observaciones con cod_com==96
drop if cod_com==96

cd "$intermed"
save immigration_collapse2, replace

* Usando solo las 101 comunas de ENUSC
cd "$rawdata"
use base_final_2008_2017, clear
cd "$intermed"
rename id_comuna15 cod_com
drop year
sort cod_com
quietly by cod_com: gen dup=cond(_N==1,0,_n)
drop if dup > 1
keep cod_com
merge 1:m cod_com using immigration_collapse2
keep if _merge==3
drop _merge

* Edad
gen year_born = real(substr(born, -4, 4))
*genero la edad aproximada que tenia la observacion al inmigrar a Chile
gen age=year - year_born
replace age = . if age>110
sum age, det
gen joven = (age<=29) if age!=.	// "Joven" lo definimos como <= 29 años que es la mediana
gen no_joven = (age>29) if age!=.

* Genero 
tab female, miss
gen mujer = (female==1)
gen hombre = (female==0)

* Grupos por edad y genero
gen mujer_joven = (mujer==1&joven==1)
gen hombre_joven = (hombre==1&joven==1)
gen mujer_nojoven = (mujer==1&no_joven==1)
gen hombre_nojoven = (hombre==1&no_joven==1)

sort cod_com year
collapse (sum) mujer_joven hombre_joven mujer_nojoven hombre_nojoven imm, by(cod_com year)

cd "$intermed"
save immigration_collapse2, replace


**** CENSO 2002 ****
* Se usa para generar stock inicial (t=0) y con los flujos posteriores te armas los stocks para los periodos que siguen
cd "$rawdata"
use PERSONA_comuna_distrito.dta, clear
* La variable Codigo tiene el codigo de comuna de la residencia actual para cada individuo
rename Codigo CodigoActual
* La variable P22B tiene la pregunta "comuna de origen", que tiene el codigo por pais para los inmigrantes residentes
rename P22B Codigo


* Mergeo el censo en funcion de la respuesta a "comuna de origen" con una base que tiene los codigos de las comunas utilizados. Todos los que nacieron fuera de las comunas de chile quedan con _merge==1
merge m:1 Codigo using COMUNAS
* Estas observaciones no sirven
drop if Codigo==99999
keep if _merge==1
drop _merge
*Todos los que me quedan aca son inmigrantes

* Edad
rename P19 age
replace age = . if age>110
sum age, det
gen joven = (age<=29) if age!=.	
gen no_joven = (age>29) if age!=.

* Genero 
rename P18 female
replace female=0 if female==2
tab female, miss
gen mujer = (female==1) if female!=.	
gen hombre = (female==0) if female!=.	

* Grupos por edad y genero
gen mujer_joven = (mujer==1&joven==1)
gen hombre_joven = (hombre==1&joven==1)
gen mujer_nojoven = (mujer==1&no_joven==1)
gen hombre_nojoven = (hombre==1&no_joven==1)


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
gen year=2002

sort cod_com year
collapse (sum) mujer_joven hombre_joven mujer_nojoven hombre_nojoven imm, by(cod_com year)

cd "$intermed"
save collapse2002_2, replace

append using immigration_collapse2

* Ahora saco stocks por año
sort cod_com year
foreach j in "mujer_joven" "hombre_joven" "mujer_nojoven" "hombre_nojoven" "imm"{
	bys cod_com: gen stock_`j'=sum(`j')
}

keep if year > 2007
drop if year==2018

save immigration_collapse2, replace

* Outcomes de base ENUSC
cd "$rawdata"
use base_final_2008_2017, clear
drop if year==2018
rename id_comuna15 cod_com

drop if cod_com==5106 | cod_com==5108 | cod_com==5505
drop if kish==0

merge m:1 cod_com using population
keep if _merge==3
drop _merge 

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

foreach var in  crime_rising pc_1 pc_2 pc_3 pc_4 pc_5 pc_6 pc_7 pc_8 pc_9 pc_10 pc_11 pc_12 pc_13 pc_14 pc_15 pc_16 pc_17 pc_18 pc_19 pc_20 del_problema1 del_problema2 del_problema3 del_afecta1 del_afecta2 del_afecta3 del_tend_pais del_tend_com del_tend_barrio del_calvida1 del_calvida2 del_calvida3 del_inseg1 del_inseg2 del_inseg3 del_inseg4 del_inseg5 del_vict del_arma vict_agreg vict_property vict_violent vict_roboviolent vict_robosorpr vict_roboviv vict_hurto vict_lesiones vict_robovehi vict_robo_desdevehi vict_delecon vict_car Index_Vivienda Index_Vecinos{
	bys cod_com year: egen bas_`var' =mean( `var') 
	replace  bas_`var'  = . if year !=2008
	sort cod_com year
	replace bas_`var' = bas_`var'[_n-1] if year !=2008 & cod_com[_n-1]==cod_com[_n]
}



cd "$intermed"
merge m:1 cod_com year using immigration_collapse2
keep if _merge==3
drop _merge

* Genero las variables de educacion que voy a usar en las regresiones
gen lnrate_stock_imm = ln( 10000*stock_imm/ population+1)
gen share_mujer_joven= (mujer_joven)/(mujer_joven+mujer_nojoven+hombre_joven+hombre_nojoven)
gen share_mujer_nojoven= (mujer_nojoven)/(mujer_joven+mujer_nojoven+hombre_joven+hombre_nojoven)
gen share_hombre_joven= (hombre_joven)/(mujer_joven+mujer_nojoven+hombre_joven+hombre_nojoven)
gen share_hombre_nojoven= (hombre_nojoven)/(mujer_joven+mujer_nojoven+hombre_joven+hombre_nojoven)

gen ln_rate_mujer_joven = share_mujer_joven*lnrate_stock_imm
gen ln_rate_mujer_nojoven = share_mujer_nojoven*lnrate_stock_imm
gen ln_rate_hombre_joven = share_hombre_joven*lnrate_stock_imm
gen ln_rate_hombre_nojoven = share_hombre_nojoven*lnrate_stock_imm

cd "$final"
save channels_OLS3, replace



}

