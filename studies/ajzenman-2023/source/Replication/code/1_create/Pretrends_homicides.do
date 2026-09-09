* Do-file para generar la base que se utiliza para la Figura VI


*Population 
{ 
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
}


*Controles CASEN 

* 2 0 0 0 ----------------------------------------------
{
cd "$rawdata"
*Le faltan comunas
import excel Comunas.xlsx, firstrow clear
keep casen03 CódigoComunadesde2010
*Calera==La Calera // Coyahaique==Coihaique
*las comunas 6106,6110,6112,6114,6116,6207,6210,
*FALTAN LAS COMUNAS 6104 6109 6203 6302 6303 6305 6306 EN LA BASE DE NOMBRES DE COMUNAS
*La variable casen03 fue extraida a mano del manual de usuario casen 2003, esos codigos no estan citados en ninguna otra fuente segun lo que pude encontrar y son distintos a los de cualqueir año del documento historico de los codigos de las comunas (y usa los mismos codigos para disintas comunas...)
rename casen03 comu
drop if comu==.
merge 1:n comu using casen2000
keep if _merge==3
rename CódigoComunadesde2010 cod_com
drop _merge

* Me quedo solo con los jefes de hogar (todas las variables categoricas van a estar en % de jefes de hogar - ej % de jfes de hogar desempleado, % de jefes de hogar que pertenecen a un grupo indigena, educacion promedio de los jefes de hogar, etc)
keep if pco1==1

* Género
gen hombre=(sexo==1)
* Controles de edad
gen age=edad
* Controles de ingreso
gen ypc=ytotaj/numper
replace ypc=ypc*1000
* El factor de expansion es expc
foreach var in hombre age ypc{
	replace `var'=`var'*expc
}
* Colapsando la suma de expc a nivel comuna voy a tener el denominador para calcular los % de cada variable
collapse (sum) hombre age ypc esc expc, by(cod_com)
* Genero las tasas:
foreach var in hombre age ypc{
	replace `var'=`var'/expc
}

cd "$conf_intermed"
save controlesCASEN00, replace
}


* 2 0 0 3 ----------------------------------------------
{
* Le faltan comunas
cd "$rawdata"

import excel Comunas.xlsx, firstrow clear
keep casen03 CódigoComunadesde2010
rename casen03 comu
drop if comu==.
merge 1:n comu using casen2003
keep if _merge==3
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
save controlesCASEN03, replace
}


* 2 0 0 6 ----------------------------------------------
{
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

cd "$conf_intermed"
save controlesCASEN06, replace
}


*Percepción y victimización a nivel comunal	

* 2 0 0 3 -------------------------------------------------
{
cd "$rawdata"
import excel Comunas.xlsx, firstrow clear
keep CódigoComunahasta1999 CódigoComunadesde2010
rename CódigoComunahasta1999 comuna
drop if comuna=="507" | comuna=="445"  | comuna==""/*Está mal definido y no hay nadie de esa comuna en casen */ 
destring comuna, replace
merge 1:n comuna using ENUSC03
keep if _merge==3
drop comuna
rename CódigoComunadesde2010 cod_com
drop _merge

gen year=2003 
rename *, lower

*VARIABLES DE PERCEPCIÓN
*Variables de control
gen ismale=(sexo==1)
gen trabaja=(ocupa<=6)

*Delincuencia como primera preocupación
gen del_problema1=(p4_1==8) if p4_1<80
*Delincuencia como segunda preocupacion
gen del_problema2=(p4_2==8) if p4_2<80
*Delincuencia como primera o segunda preocupacion
gen del_problema3=(p4_1==8 | p4_2==8) if p4_1<80 & p4_2<80

* del_afecta 1 2 y 3 no se pueden armar por diferencias en la encuesta

*Opina que la delincuencia a nivel País aumentó
gen del_tend_pais=(p6==1) if p6 < 80
*Opina que la delincuencia a nivel Comuna aumentó
gen del_tend_com=(p8==1) if  p8< 80
*Opina que la delincuencia a nivel Barrio aumentó
gen del_tend_barrio=(p9==1) if p9 < 80
*Opina que delincuencia afecta su calidad de vida "Mucho"
gen del_calvida1=(p5_8==1) if p5_8 < 80
*Opina que delincuencia afecta su calidad de vida "Bastante"
gen del_calvida2=(p5_8==2) if p5_8 < 80
*Opina que delincuencia afecta su calidad de vida "Mucho" o "Bastante"
gen del_calvida3=(p5_8==1 | p5_8==2) if p5_8<80

*Se siente muy inseguro caminando cuando ya esta oscuro
gen del_inseg1=(p15==4 | p15 ==3) if p15 < 80
*Se siente muy inseguro solo en su casa cuando ya esta oscuro (CAMBIO: SIENTE QUE SU CASA ES INSEGURA, NO DISCRIMINA POR SOLO O DE NOCHE)
gen del_inseg2=(p13_1==1 | p13_1 ==2) if p13_1 < 80
*Se siente muy inseguro esperando el transporte cuando ya esta oscuro(CAMBIO: SIENTE QUE LOS PARADEROS DE LOCOMOCION COLECTIVA EN SU BARRIO ES INSEGURA, NO DISCRIMINA POR SOLO O DE NOCHE)
gen del_inseg3=(p14_10==1 | p14_10 ==2) if p14_10 < 80
*Se siente muy inseguro caminando, esperando el transporte o solo en su casa cuando ya esta oscuro
gen del_inseg4=(del_inseg1==1 | del_inseg2==1 | del_inseg3==1) if  (p15<80 & p13_1<80 & p14_10<80 )
*Se siente inseguro haciendo las 3 cosas
gen del_inseg5=(del_inseg1==1 &  del_inseg2==1 & del_inseg3==1) if (p15<80 & p13_1<80 & p14_10<80 )


*Cree que será víctima de un delito en los próximos 12 meses
gen del_vict=(p11==1) if p11 < 80
*Tenencia de arma de fuego
gen del_arma=(p22==1) if p22 < 80


*VARIABLES DE VICTIMIZACION
*El informante o alguien de su familia fue asaltado con violencia, (+AMENAZA O INTIMIDACIÓN)
gen vict_roboviolent=(p69==1) if p69<80
*El informante o alguien de su familia sufrio robo por sorpresa
gen vict_robosorpr=(p57==1) if p57<80
*El informante o alguien de su familia sufrio robo en su vivienda
gen vict_roboviv=(p48==1) if p48<80
*El informante o alguien de su familia sufrio hurto
gen vict_hurto=(p84==1) if p84<80
*El informante o alguien de su familia fue victima de lesiones (sin robo)
gen vict_lesiones=(p95==1) if p95<80
*El informante o alguien de su familia sufrio robo de vehiculo
gen vict_robovehi=(p27==1) if p27<80
*El informante o alguien de su familia sufrio robo de articulos dejados en el vehiculo
gen vict_robo_desdevehi=(p38==1) if p38<80
*El informante o alguien de su familia fue victima delitos de connotacion economica (estafas y similares)
gen vict_delecon=(p106==1) if p106<80

*Las variables de victimizacion agregadas. Rowmean ignora los missing values
gen vict_agreg=(vict_roboviolent==1|vict_robosorpr==1|vict_roboviv==1|vict_hurto==1|vict_lesiones==1|vict_robovehi==1)
label var vict_agreg "Crimen total: variable que toma valor 1 si el individuo sufrio ALGUN crimen, 0 sino"
*victimizacion en crimenes a la propiedad (sin violencia, segun marca la guia de la encuesta)
egen vict_property=rowmean(vict_delecon vict_robo_desdevehi vict_robovehi vict_hurto vict_robosorpr vict_roboviv)
*victimizacion en crimenes que involucran violencia. robo con fuerza en vivienda parece que incluye tanto robos sin uso de violencia o intimidacion como con violencia asi que no estoy seguro de en cual incluirlo
egen vict_violent=rowmean(vict_roboviolent vict_lesiones) 

gen crime_rising = del_tend_pais==1 | del_tend_com == 1 | del_tend_barrio ==1

* Componentes principales para grupos de categorías (del do file ENUSC_N):
*pc 1 al 5, y 16 al 19 no se pueden armar porque faltan las del_afecta 
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

foreach v of varlist pc_6 pc_7 pc_8 pc_9 pc_10 pc_11 pc_12 pc_13 pc_14 pc_15{
    qui summ `v'
    replace `v' = (`v' - r(min)) / (r(max) - r(min))
}

rename fcom_h fact_hog
*Colapso la base a nivel de comuna y año usando los promedios, esto ya me da las rates para cada variable
sort cod_com year
collapse (mean) del* vict_* crime_rising ismale trabaja fact_hog pc_*, by(cod_com year)

cd "$conf_intermed"
merge n:1 cod_com using controlesCASEN06
keep if _merge==3
save pre03, replace
}


* 2 0 0 5 ----------------------------------------------
{
cd "$rawdata"
import excel Comunas.xlsx, firstrow clear
keep CódigoComunahasta1999 CódigoComunadesde2010
rename CódigoComunahasta1999 comuna
drop if comuna=="507" | comuna=="445"  | comuna==""/*Está mal definido y no hay nadie de esa comuna en casen */ 
destring comuna, replace
merge 1:n comuna using ENUSC05
keep if _merge==3
drop comuna
rename CódigoComunadesde2010 cod_com
drop _merge

gen year=2005 /*Comparo cuestionario 2003 con cuestionario 2008 */
rename *, lower

*VARIABLES DE PERCEPCIÓN
*Variables de control
gen ismale=(sexo==1)
gen trabaja=(ocupa<=6) if ocupa<9 

*Delincuencia como primera preocupación
gen del_problema1=(p4_1==8) if p4_1<80
*Delincuencia como segunda preocupacion
gen del_problema2=(p4_2==8) if p4_2<80
*Delincuencia como primera o segunda preocupacion
gen del_problema3=(p4_1==8 | p4_2==8) if p4_1<80 & p4_2<80

* del_afecta 1 2 y 3 no se pueden armar por diferencias en la encuesta

*Opina que la delincuencia a nivel País aumentó
gen del_tend_pais=(p6==1) if p6 < 80
*Opina que la delincuencia a nivel Comuna aumentó
gen del_tend_com=(p8==1) if  p8< 80
*Opina que la delincuencia a nivel Barrio aumentó
gen del_tend_barrio=(p9==1) if p9 < 80

*Opina que delincuencia afecta su calidad de vida "Mucho"
gen del_calvida1=(p5_8==1) if p5_8 < 80
*Opina que delincuencia afecta su calidad de vida "Bastante"
gen del_calvida2=(p5_8==2) if p5_8 < 80
*Opina que delincuencia afecta su calidad de vida "Mucho" o "Bastante"
gen del_calvida3=(p5_8==1 | p5_8==2) if p5_8<80

*Se siente muy inseguro caminando cuando ya esta oscuro
gen del_inseg1=(p15==4 | p15 ==3) if p15 < 80

*Se siente muy inseguro solo en su casa cuando ya esta oscuro (CAMBIO: CONSIDERA QUE SU CASA ES INSEGURA)
gen del_inseg2=(p13_1==1 | p13_1==2) if p13_1 < 80
*Se siente muy inseguro esperando el transporte cuando ya esta oscuro(CAMBIO: CONSIDERA QUE LOS PARADEROS DE LOCOMOCIÓN COLECTIVA SON INSEGUROS)
gen del_inseg3=(p14_10==1 | p14_10==2) if p14_10 < 80
*Se siente muy inseguro caminando, esperando el transporte o solo en su casa cuando ya esta oscuro
gen del_inseg4=(del_inseg1==1| del_inseg2==1|del_inseg3==1) if (p15<80 & p13_1<80 & p14_10<80 )
*Se siente inseguro haciendo las 3 cosas
gen del_inseg5=(del_inseg1==1 &  del_inseg2==1 & del_inseg3==1) if (p15<80 & p13_1<80 & p14_10<80 )

*Cree que será víctima de un delito en los próximos 12 meses
gen del_vict=(p11==1) if p11 < 80
*Tenencia de arma de fuego
gen del_arma=(p22==1) if p22 < 80

*VARIABLES DE VICTIMIZACION
*El informante o alguien de su familia fue asaltado con violencia
gen vict_roboviolent=(p71==1) if p71<80
*El informante o alguien de su familia sufrio robo por sorpresa
gen vict_robosorpr=(p59==1) if p59<80
*El informante o alguien de su familia sufrio robo en su vivienda
gen vict_roboviv=(p50==1) if p50<80
*El informante o alguien de su familia sufrio hurto
gen vict_hurto=(p86==1) if p86<80
*El informante o alguien de su familia fue victima de lesiones (sin robo)
gen vict_lesiones=(p97==1) if p97<80
*El informante o alguien de su familia sufrio robo de vehiculo
gen vict_robovehi=(p29==1) if p29<80
*El informante o alguien de su familia sufrio robo de articulos dejados en el vehiculo
gen vict_robo_desdevehi=(p40==1) if p40<80
*El informante o alguien de su familia fue victima delitos de connotacion economica (estafas y similares)
gen vict_delecon=(p108==1) if p108<80

*Las variables de victimizacion agregadas. Rowmean ignora los missing values
gen vict_agreg=(vict_roboviolent==1|vict_robosorpr==1|vict_roboviv==1|vict_hurto==1|vict_lesiones==1|vict_robovehi==1)
label var vict_agreg "Crimen total: variable que toma valor 1 si el individuo sufrio ALGUN crimen, 0 sino"
*victimizacion en crimenes a la propiedad (sin violencia, segun marca la guia de la encuesta)
egen vict_property=rowmean(vict_delecon vict_robo_desdevehi vict_robovehi vict_hurto vict_robosorpr vict_roboviv)
*victimizacion en crimenes que involucran violencia. robo con fuerza en vivienda parece que incluye tanto robos sin uso de violencia o intimidacion como con violencia asi que no estoy seguro de en cual incluirlo
egen vict_violent=rowmean(vict_roboviolent vict_lesiones) 

gen crime_rising = del_tend_pais==1 | del_tend_com == 1 | del_tend_barrio ==1

* Componentes principales para grupos de categorías (del do file ENUSC_N):
*pc 1 al 5, y 16 al 19 no se pueden armar porque faltan las del_afecta 

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



foreach v of varlist pc_6 pc_7 pc_8 pc_9 pc_10 pc_11 pc_12 pc_13 pc_14 pc_15{
    qui summ `v'
    replace `v' = (`v' - r(min)) / (r(max) - r(min))
}



rename fcom_h fact_hog
*Colapso la base a nivel de comuna y año usando los promedios, esto ya me da las rates para cada variable
sort cod_com year
collapse (mean) del* vict_* crime_rising ismale trabaja fact_hog pc_*, by(cod_com year)

cd "$conf_intermed"
merge n:1 cod_com using controlesCASEN06
keep if _merge==3
drop _merge
save pre05, replace
}


* 2 0 0 6 ----------------------------------------------
{
cd "$rawdata"
import excel Comunas.xlsx, firstrow clear
keep CódigoComunahasta1999 CódigoComunadesde2010
rename CódigoComunahasta1999 comuna
drop if comuna=="507" | comuna=="445"  | comuna==""/*Está mal definido y no hay nadie de esa comuna en casen */ 
replace comuna="454" if comuna=="453"
destring comuna, replace
merge 1:n comuna using ENUSC06
keep if _merge==3
drop comuna
rename CódigoComunadesde2010 cod_com
drop _merge

gen year=2006 
rename *, lower

drop if infor==. /* equivalente a lkish */
*VARIABLES DE PERCEPCIÓN
*Variables de control
gen ismale=(sexo==1)
gen trabaja=(situacio==1) if situacio<80 


*Delincuencia como primera preocupación
gen del_problema1=(p2_1==8) if p2_1<80
*Delincuencia como segunda preocupacion
gen del_problema2=(p2_2==8) if p2_2<80
*Delincuencia como primera o segunda preocupacion
gen del_problema3=(p2_1==8 | p2_2==8) if p2_1<80 & p2_2<80

* del_afecta 1 2 y 3 no se pueden armar por diferencias en la encuesta

*Opina que la delincuencia a nivel País aumentó
gen del_tend_pais=(p4_1==1) if p4_1 < 80
*Opina que la delincuencia a nivel Comuna aumentó
gen del_tend_com=(p4_2==1) if  p4_2 < 80
*Opina que la delincuencia a nivel Barrio aumentó
gen del_tend_barrio=(p4_3==1) if  p4_3 < 80

*Mismo que lo anterior, no es EXACTAMENTE la misma pregunta pero por una palabra
*Opina que delincuencia afecta su calidad de vida "Mucho"
gen del_calvida1=(p3_8==1) if p3_8< 80
*Opina que delincuencia afecta su calidad de vida "Bastante"
gen del_calvida2=(p3_8==2) if p3_8< 80
*Opina que delincuencia afecta su calidad de vida "Mucho" o "Bastante"
gen del_calvida3=(p3_8==1 | p3_8==2) if p3_8<80 

*Se siente muy inseguro caminando cuando ya esta oscuro
gen del_inseg1=(p10==4 | p10==3) if p10< 80

*Se siente muy inseguro solo en su casa cuando ya esta oscuro(CAMBIO: CONSIDERA QUE SU CASA ES INSEGURA, NO DISCRIMINA SI ESTA SOLO O DE NOCHE)
gen del_inseg2=(p8_1==1 | p8_1==2) if p8_1 < 80
*Se siente muy inseguro esperando el transporte cuando ya esta oscuro
gen del_inseg3=( p9_10==1 |  p9_10 ==2) if  p9_10 < 80
*Se siente muy inseguro caminando, esperando el transporte o solo en su casa cuando ya esta oscuro
gen del_inseg4=(del_inseg1==1 | del_inseg2==1| del_inseg3==1) if (p10<80 & p8_1<80 &  p9_10<80 )
*Se siente inseguro haciendo las 3 cosas
gen del_inseg5=(del_inseg1==1 &  del_inseg2==1 & del_inseg3==1) if (p10<80 & p8_1<80 &  p9_10<80 )

*Cree que será víctima de un delito en los próximos 12 meses
gen del_vict=(p6==1) if p6 < 80
*Tenencia de arma de fuego
gen del_arma=(p17==1) if p17 < 80

*VARIABLES DE VICTIMIZACION

*El informante o alguien de su familia fue asaltado con violencia
gen vict_roboviolent=(p63_1==1) if p63_1<80
*El informante o alguien de su familia sufrio robo por sorpresa
gen vict_robosorpr=(p52_1==1) if p52_1<80
*El informante o alguien de su familia sufrio robo en su vivienda
gen vict_roboviv=(p44_1==1) if p44_1<80
*El informante o alguien de su familia sufrio hurto
gen vict_hurto=(p77_1==1) if p77_1<80
*El informante o alguien de su familia fue victima de lesiones (sin robo)
gen vict_lesiones=(p87_1==1) if p87_1<80
*El informante o alguien de su familia sufrio robo de vehiculo
gen vict_robovehi=(p25_1==1) if p25_1<80
*El informante o alguien de su familia sufrio robo de articulos dejados en el vehiculo
gen vict_robo_desdevehi=(p35_1==1) if p35_1<80
*El informante o alguien de su familia fue victima delitos de connotacion economica (estafas y similares)
gen vict_delecon=(p97_1==1) if p97_1<80

*Las variables de victimizacion agregadas. Rowmean ignora los missing values
gen vict_agreg=(vict_roboviolent==1|vict_robosorpr==1|vict_roboviv==1|vict_hurto==1|vict_lesiones==1|vict_robovehi==1)
label var vict_agreg "Crimen total: variable que toma valor 1 si el individuo sufrio ALGUN crimen, 0 sino"
*victimizacion en crimenes a la propiedad (sin violencia, segun marca la guia de la encuesta)
egen vict_property=rowmean(vict_delecon vict_robo_desdevehi vict_robovehi vict_hurto vict_robosorpr vict_roboviv)
*victimizacion en crimenes que involucran violencia. robo con fuerza en vivienda parece que incluye tanto robos sin uso de violencia o intimidacion como con violencia asi que no estoy seguro de en cual incluirlo
egen vict_violent=rowmean(vict_roboviolent vict_lesiones) 

gen crime_rising = del_tend_pais==1 | del_tend_com == 1 | del_tend_barrio ==1

* Componentes principales para grupos de categorías (del do file ENUSC_N):
*pc 1 al 5, y 16 al 19 no se pueden armar porque faltan las del_afecta 
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


foreach v of varlist  pc_6 pc_7 pc_8 pc_9 pc_10 pc_11 pc_12 pc_13 pc_14 pc_15{
    qui summ `v'
    replace `v' = (`v' - r(min)) / (r(max) - r(min))
}

rename fcom_h fact_hog
*Colapso la base a nivel de comuna y año usando los promedios, esto ya me da las rates para cada variable
sort cod_com year
collapse (mean) del* vict_* crime_rising ismale trabaja fact_hog pc_*, by(cod_com year)

cd "$conf_intermed"
merge n:1 cod_com using controlesCASEN06
keep if _merge==3
drop _merge
save pre06, replace

}


*S H A R E S      I M M --------------------------------
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
foreach country in "hai" "per" "col" "ven" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra"{
	gen imm_`country'=(cat_pais=="`country'")
}
collapse (sum) imm*, by(cod_com year)
cd "$conf_intermed"
save ImmigrationOrigen, replace

* Genero los stocks de inmigrantes para cada comuna y cada año
* Primero genero stocks de inmigrantes en 2002 con la base del censo y despues le hago un append a la base actual
* -------------------------------------------------------------------------
* CENSO 2002

cd "$rawdata"
*Base de datos inmigrantes en censo 2002
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
* No inmigrantes de los paises que quiero
keep if Codigo==20020 | Codigo==20004 | Codigo==20010 | Codigo==20014 | Codigo==20018 | Codigo==20042 | Codigo==20052 | Codigo==40014 | Codigo==30011 | Codigo==20011 | Codigo==40002 | Codigo==40025 | Codigo==20027
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

foreach country in "eeuu" "arg" "bol" "col" "ecu" "per" "ven" "chi" "bra" "ale" "ita" "esp" "hai"{
	gen imm_`country'=(cat_pais=="`country'")
}

collapse (sum) imm*, by(cod_com year)
cd "$conf_intermed"
save CensoInmigr2002, replace

append using ImmigrationOrigen
* Ahora saco stocks por año
sort cod_com year
bys cod_com: gen stock_imm=sum(imm)
foreach country in "eeuu" "arg" "bol" "col" "ecu" "per" "ven" "chi" "bra" "ale" "ita" "esp" "hai"{
	bys cod_com: gen `country'=sum(imm_`country')
}
* Ahora me quedan stocks. Cambio los nombres de las variables para que corra el codigo de abajo (que estaba armado para las variables flujo)
rename imm immflujo
rename stock_imm imm
foreach pais in "eeuu" "arg" "bol" "col" "ecu" "per" "ven" "chi" "bra" "ale" "ita" "esp" "hai"{
	rename imm_`pais' `pais'flujo
	rename `pais' imm_`pais'
}

* Tiro los años que no quiero para la diferencia relevante (para la variable del total de inmigrantes)
keep if year==2017 | year==2008
* Como hay comunas en ciertos años que no tienen migrantes de determinada nacionalidad, la base no queda completa. Usamos una base con la totalidad de las comunas, con los años 2010 y 2017, para cada país de origen para completar la base.
save ImmigrationOrigen, replace

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
use ImmigrationOrigen, clear
merge 1:1 cod_com year using Cod_com
drop _merge
sort cod_com year

replace imm=0 if imm==.
foreach country in "hai" "per" "col" "ven" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra"{
	replace imm_`country'=0 if imm_`country'==.
}
save ImmigrationOrigen, replace

* Vamos por la variable endogena
keep cod_com year imm
save FinalBase, replace
use population, clear
merge 1:m cod_com using FinalBase
drop if _merge==1
drop _merge
sort cod_com year

* Genero las tasas de DeltaIMM con la poblacion
replace imm=imm*100000/population

* Para generar la variable relevante: deltaimm_{m,2017}=imm_{m,2017}-imm_{m,2008}=ln(deltaIMM_{m,2017})-ln(deltaIMM_{m,2008}). sumo 1 para que los 0's no generen problemas
gen lndelta_imm=ln(imm*1000+1)
bysort cod_com (year) : gen deltaimm = lndelta_imm - lndelta_imm[_n-1]

* Ahora si, me queda lo que queria: una base cross-section para 2017 con cod_com year y deltaimm
drop if year!=2017
keep comuna cod_com year population deltaimm

save FinalBase, replace

* Sigo con la base de la UN. Altere la base desde el excel dejando todas las celdas con "." en blanco para que no lea las variables como strings
* Esta base esta en stocks
cd "$rawdata"
import excel UN_MigrantStock.xlsx, sheet(Hoja1) firstrow clear

* Tiro los años pre-2005
drop if year<2005

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

* Para expresarlo en logaritmos y quedarme solo con 2010 y 2017. Esto nos deja las variables ln(IMM_{t}^{n})
sort year
foreach country in "hai" "per" "col" "ven" "bol" "arg" "ecu" "chi" "eeuu" "esp" "bra"{
	gen ln_orig_`country'=ln(`country')
	drop `country'
}

* Tiro los años que no sean 2010 o 2017 y calculo la diferencia de los logaritmos. Esto me deja con Deltaln(IMM_{t}^{n})
keep if year==2010 | year==2017
*foreach country in "per" "col" "ven" "bol" "hai" "arg" "ecu" "eeuu" "chi" "bra" "repdom" "par" "mex"{
foreach country in "hai" "per" "col" "ven" "bol" "arg" "ecu" "chi" "eeuu" "esp" "bra"{
	gen delta_ln_orig_`country' = ln_orig_`country' - ln_orig_`country'[_n-1]
	drop ln_orig_`country'
}
drop if year==2010
* Esta base tiene la variable que voy a sumar a lo largo de los 10 paises para construir el instrumento (ponderada por los shares de inmigrantes)
cd "$conf_intermed"
save DeltaImmigrationSupply, replace

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
foreach country in "hai" "per" "col" "ven" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra"{
	gen imm_`country'=(cat_pais=="`country'")
}
sort cod_com year
collapse (sum) imm*, by(cod_com year)
rename imm_* *
cd "$conf_intermed"
save ImmigrationStocks, replace

* Abro la base del censo que habia creado antes y la junto con la de inmigracion por año para generar stocks
use CensoInmigr2002, clear

foreach pais in "eeuu" "arg" "bol" "col" "ecu" "per" "ven" "chi" "bra" "ale" "ita" "esp" "hai"{
	rename imm_`pais' `pais'
}

append using ImmigrationStocks
sort cod_com year
* Para sumar inmigracion por año y tener stocks
sort cod_com year
bys cod_com: gen stock_imm=sum(imm)
foreach country in "hai" "per" "col" "ven" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra"{
	bys cod_com: gen imm_`country'=sum(`country')
	drop `country'
}
drop if year!=2008
save ImmigrationStocks, replace

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
save Cod_com, replace
use ImmigrationStocks, clear
merge 1:1 cod_com year using Cod_com
drop _merge
sort cod_com year
replace stock_imm=0 if stock_imm==.
foreach country in "hai" "per" "col" "ven" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra"{
	replace imm_`country'=0 if imm_`country'==.
}
save ImmigrationStocks, replace
* Ahora me quedo con los stocks de 2008 y calculo los shares
drop if year!=2008
replace year=2017 if year==2008
*foreach country in "per" "col" "ven" "bol" "hai" "arg" "ecu" "eeuu" "esp" "chi" "bra" "repdom" "par" "mex"{
foreach country in "hai" "per" "col" "ven" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra"{
	gen share2008_`country'=(imm_`country')/stock_imm
	replace share2008_`country'=0 if share2008_`country'==.
}
keep cod_com year share2008_*

sort cod_com year
merge 1:1 cod_com year using FinalBase
keep if _merge==3
drop _merge

merge m:1 year using DeltaImmigrationSupply
* Merge perfecto
drop _merge

* Ahora solo falta construir el instrumento para cada comuna de 2017 con las variables que estan en la base
foreach country in "hai" "per" "col" "ven" "bol" "arg" "ecu" "eeuu" "esp" "chi" "bra"{
	rename share2008_`country' share_`country'
	gen imm_com_`country'=share_`country'*delta_ln_orig_`country'
	rename delta_ln_orig_`country' delta_`country'
	}

* Genero el instrumento y ya tengo el lado izquierdo de la regresion. Falta crimen
egen deltaimm_instr=rowtotal(imm_com_*)
drop imm_com_*

cd "$conf_intermed"
save ImmigrationStockstest, replace
}


*HOMICIDIOS
{
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

* Agrego poblacion
replace comuna="aisen" if comuna=="Aysén"
replace comuna="calera" if comuna=="La Calera"
replace comuna="marchihue" if comuna=="Marchigüe"
replace comuna="el olivar" if comuna=="Olivar" 
replace comuna = ustrlower( ustrregexra( ustrnormalize( comuna, "nfd" ) , "/p{Mark}", "" )  )
merge m:1 comuna using "$rawdata/population"
keep if _merge==3
drop _merge

** Genero variables per capita (tasa de crimen)
foreach j in homicidios1 homicidios_chilenos1 homicidios_nchilenos1{
	gen `j'pc = `j'*100000/pop
}

** Restrinjo a los anios para los cuales voy a tomar las diferencias
preserve
keep if year==2008|year==2017		

sort cod_com year
foreach var in homicidios1pc homicidios_chilenos1pc homicidios_nchilenos1pc{
	bysort cod_com : gen delta`var' = `var' - `var'[_n-1]
	sort cod_com year
}

* Reemplazo las variables originales por el valor de la variable en diferencias
foreach var in homicidios1pc homicidios_chilenos1pc homicidios_nchilenos1pc{
	replace `var'=delta`var' if year==2017
}
cd "$conf_intermed"
save homicidios_200817, replace 
restore 

keep if year==2005|year==2006|year==2007
append using homicidios_200817

save homicidios_200517, replace

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
merge 1:m cod_com using homicidios_200517
keep if _merge==3
drop _merge
save homicidios_200517, replace

}

*----------------------------------------------------*
* 						Test 2					   	 *
*----------------------------------------------------*
{
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
collapse (mean) kish, by(cod_com)
drop kish
merge 1:1 cod_com using FinalBase
keep if _merge==3
drop _merge

save FinalBase101, replace

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
merge 1:1 cod_com using controlesCASEN06
keep if _merge==3
drop _merge
*save controlesCASEN101, replace
merge 1:1 cod_com using FinalBase101
keep if _merge==3
* Tiro todo lo que no vaya a usar como control o instrumento
drop _merge
save FinalBase101_2, replace

cd "$rawdata"
use base_final_2008_2017, clear
keep if year==2008 | year==2017
rename id_comuna15 cod_com
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
egen vict_property=rowmean(vict_delecon vict_robo_desdevehi vict_robovehi vict_hurto vict_robosorpr vict_roboviv)
*victimizacion en crimenes que involucran violencia. robo con fuerza en vivienda parece que incluye tanto robos sin uso de violencia o intimidacion como con violencia asi que no estoy seguro de en cual incluirlo
egen vict_violent=rowmean(vict_roboviolent vict_lesiones) 

gen crime_rising = del_tend_pais==1 | del_tend_com == 1 | del_tend_barrio ==1

keep if kish==1

* Componentes principales para grupos de categorías (del do file ENUSC_N):
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

keep if kish==1

*Colapso la base a nivel de comuna y año usando los promedios, esto ya me da las rates para cada variable
sort cod_com year
*collapse (mean) del* vict_* crime_rising ismale trabaja [aw=fact_hog], by(cod_com year)
collapse (mean) del* vict_* crime_rising ismale trabaja fact_hog pc_* Index_*, by(cod_com year)

* Ahora genero las diferencias
* Para las variables de percepcion:
foreach var in  del_problema1 del_problema2 del_problema3 del_afecta1 del_afecta2 del_afecta3 crime_rising del_tend_pais del_tend_com del_tend_barrio del_calvida1 del_calvida2 del_calvida3 del_inseg1 del_inseg2 del_inseg3 del_inseg4 del_inseg5 del_vict del_arma vict_agreg vict_property vict_violent vict_roboviolent vict_robosorpr vict_roboviv vict_hurto vict_lesiones vict_robovehi vict_robo_desdevehi vict_delecon pc_19 pc_20 Index_Vivienda Index_Vecinos  pc_6{
	bysort cod_com : gen delta`var' = `var' - `var'[_n-1]
	sort cod_com year
}

* Reemplazo las variables originales por el valor de la variable en diferencias
foreach var in  del_problema1 del_problema2 del_problema3 del_afecta1 del_afecta2 del_afecta3 crime_rising del_tend_pais del_tend_com del_tend_barrio del_calvida1 del_calvida2 del_calvida3 del_inseg1 del_inseg2 del_inseg3 del_inseg4 del_inseg5 del_vict del_arma vict_agreg vict_property vict_violent vict_roboviolent vict_robosorpr vict_roboviv vict_hurto vict_lesiones vict_robovehi vict_robo_desdevehi vict_delecon pc_19 pc_20 Index_Vivienda Index_Vecinos pc_6{
	replace `var'=delta`var' if year==2017
}


cd "$conf_intermed"
merge n:1 cod_com using FinalBase101_2
keep if _merge==3
drop _merge

append using pre03
append using pre05
append using pre06
drop _merge

merge 1:1 year cod_com using homicidios_200517, keepus(homicidios1pc)
drop _merge

merge n:1 cod_com using ImmigrationStockstest
sort year cod_com
keep if _merge==3
label variable vict_agreg "Total crime"
label variable vict_property "Property crime"
label variable vict_violent "Violent crime"
label variable vict_roboviolent "Robbery"
label variable vict_robosorpr "Larceny"
label variable vict_roboviv "Burglary"
label variable vict_hurto "Theft"
label variable vict_lesiones "Assault"
label variable vict_robovehi "MV Theft"
label variable vict_robo_desdevehi "Robo desde vehiculo victimization rate"
label variable vict_delecon "Economic crime"
label variable del_problema1 "Crime as 1st concern"
label variable del_problema2 "Crime as 2nd concern"
label variable del_problema3 "Crime as 1st or 2nd concern"
label variable del_tend_pais "Crime is rising (country)"
label variable del_tend_com "Crime is rising (municipality)"
label variable del_tend_barrio "Crime is rising (neighborhood)"
label variable del_calvida1 "Crime affecting quality of life"
label variable del_calvida2 "Crime affecting quality of life"
label variable del_calvida3 "Crime affecting quality of life"
label variable del_inseg1 "Feeling unsafe"
label variable del_inseg2 "Feeling unsafe"
label variable del_inseg3 "Feeling unsafe"
label variable del_inseg4 "Feeling unsafe"
label variable del_inseg5 "Feeling unsafe"
label variable del_vict "Will be a victim"
label variable del_arma "Owns a weapon"
label variable pc_6 "Principal component summary index" /*"Index 6- Personal Concerns about Crime"*/
label variable pc_7 "Principal component summary index" /*"Index 7- Personal Concerns about Crime"*/
label variable pc_8 "Principal component summary index" /*"Index 8- Personal Concerns about Crime"*/
label variable pc_9 "Principal component summary index" /*"Index 9- Personal Concerns about Crime"*/
label variable pc_10 "Principal component summary index" /*"Index 10- Personal Concerns about Crime"*/
label variable pc_11 "Principal component summary index" /*"Index 11- Personal Concerns about Crime"*/
label variable pc_12 "Principal component summary index" /*"Index 12- Personal Concerns about Crime"*/
label variable pc_13 "Principal component summary index" /*"Index 13- Personal Concerns about Crime"*/
label variable pc_14 "Principal component summary index" /*"Index 14- Personal Concerns about Crime"*/
label variable pc_15"Principal component summary index" /* "Index 15- Personal Concerns about Crime"*/

cd "$conf_final"

save pretrendsfinalbase_homicides, replace
}

