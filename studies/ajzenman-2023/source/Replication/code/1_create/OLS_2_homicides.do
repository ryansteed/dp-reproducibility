* Do-file para generar la base que se utiliza para las Tablas XIV (Column 4), XV (Panel A, Column 4) and XVI (Column 4)

* Variables independientes (inmigracion y demas)
{
cd "$rawdata"

* Empiezo con la base de extranjería para generar una colapsada a nivel de comuna y año
use immigration_Correciones, clear
* Tiro 2 observaciones que tienen mal el codigo
drop if comuna=="florida" & cod_com==8404
* Tiro 379 observaciones con cod_com==96
drop if cod_com==96

*para dividir por grupo etareo
gen year_born = real(substr(born, -4, 4))
*genero la edad aproximada que tenia la observacion al inmigrar a Chile
gen age= year - year_born
*hay 795453 observaciones que no tienen fecha de nacimiento
tab year if age==.
replace age=-1 if age==.

tab estudios
* Dummies por grupo de estudio
gen est_prebasico=(estudios=="prebasico")
gen est_basico=(estudios=="basico")
gen est_medio=(estudios=="medio")
gen est_tecnico=(estudios=="tecnico")
gen est_univers=(estudios=="universitario")
* Esta categoria es la mas grande lejos, es la mitad de la base. Les queda missing en años de educacion
gen est_nodice=(estudios=="no informa" | estudios=="no indica")
gen est_nada=(estudios=="ninguno")

* 	Genero las dummies anteriores para +18 y +23 para calcular los ños promedio de educacion en esos grupos
foreach edad in 18 23{
	foreach j in "_prebasico" "_basico" "_medio" "_tecnico" "_univers" "_nada" "_nodice"{
	gen post`edad'est`j'=(est`j'==1 & age>`edad')
	}
}

// * Años de educacion ESTO YA NO VA, HAGO LOS AÑOS PROMEDIO DE EDUCACION SOBRE STOCKS
// gen years_educ=1 if est_prebasico==1
// replace years_educ=6 if est_basico==1
// replace years_educ=12 if est_medio==1
// replace years_educ=13 if est_tecnico==1
// replace years_educ=16 if est_univers==1
// replace years_educ=0 if est_nada==1
// * Esta variable la genero para generar despues el promedio de years_educ por comuna y año
// gen years_educN=(years_educ!=.)

* Dummies por haiti o haiti + colombia
gen imm_haiti=(cat_pais=="haiti")
gen imm_haiti_colom=(cat_pais=="haiti" | cat_pais=="colombia")
* Sus complementos
gen imm_NOhaiti=(cat_pais!="haiti")
gen imm_NOhaiti_colom=(imm_haiti_colom==0)

sort cod_com year
collapse (sum) imm* est_* post*, by(cod_com year)

// * Aca me queda el promedio de años de educ para los que respondieron
// replace years_educ=years_educ/years_educN
// * IMPORTANTE: aca imputo 0 en años promedio de educacion para comunas-año que no tenian a nadie que hubiera respondido las preguntas sobre estudios. No se si es lo mejor. Son 423. Se concentran entre 2005 y 2007, despues hay 17 mas en 2008 y de ahi en adelante son como mucho 6 por año
// * Para verlo bien:
// tab year if years_educ==.
// replace years_educ=0 if years_educ==.

cd "$conf_intermed"
save immigration_collapse, replace

cd "$rawdata"
use PERSONA_comuna_distrito.dta, clear
* La variable Codigo tiene el codigo de comuna de la residencia actual para cada individuo
rename Codigo CodigoActual
* La variable P22B tiene la pregunta "comuna de origen", que tiene el codigo por pais para los inmigrantes residentes
rename P22B Codigo
* Acá replico la segunda columna del cuadro 4.2 del documento "Censo 2002 Chile con Cuestionario" para ver qué valores de P26A (educacion) se corresponden con los que use arriba para educacion
tab P26A if P19>4
* La pregunta es ¿cuál es el último nivel que aprobo en la enseñanza formal? y los resultados son:
// 1 Nunca asistio
// 2 Pre-basica
// 3 Especial Diferencial
// 4 Basica
// 5 Media comun
// 6 Humanidades
// 7 Media comercial
// 8 Media industrial
// 9 Media agricola
// 10 Media maritima
// 11 Normal
// 12 Tecnica femenina
// 13 Centro de formacion tecnica
// 14 Instituto profesional
// 15 Universitaria

* Genero las variables de educacion correspondientes. IMPORTANTE: CHEQUEAR QUE HAYA AGRUPADO BIEN LAS CATEGORIAS. que hago con educacion especial? y normal? por ahora  mando a basico y a medio respectivamente
* Dummies por grupo de estudio
gen est_prebasico=(P26A==2)
gen est_basico=(P26A==3 | P26A==4)
gen est_medio=(P26A==5 | P26A==6 | P26A==7 | P26A==8 | P26A==9 | P26A==10 | P26A==11)
gen est_tecnico=(P26A==12 | P26A==13 | P26A==14)
gen est_univers=(P26A==15)
gen est_nada=(P26A==1)
gen est_nodice=(P26A==.)

// * Años de educacion (podria definirla mas precisa porque la variable 26B indica el ultimo año cursado del ultimo nivel que hayan hecho, pero por ahora lo hago consistente a lo anterior)
// gen years_educ=1 if est_prebasico==1
// replace years_educ=6 if est_basico==1
// replace years_educ=12 if est_medio==1
// replace years_educ=13 if est_tecnico==1
// replace years_educ=16 if est_univers==1
// replace years_educ=0 if est_nada==1
// * Esta variable la genero para generar despues el promedio de years_educ por comuna y año
// gen years_educN=(years_educ!=.)

* Mergeo el censo en funcion de la respuesta a "comuna de origen" con una base que tiene los codigos de las comunas utilizados. Todos los que nacieron fuera de las comunas de chile quedan con _merge==1
merge m:1 Codigo using COMUNAS
* Estas observaciones no sirven
drop if Codigo==99999
* Con este comando y los Cuadros 2.1 y 2.2 (p111) del documento "Censo 2002 Chile con Cuestionario" encuentro los codigos para los paises que quiero (comparo numeros, dan iguales)
keep if _merge==1
*groups Codigo, order(h)
* Resultados: 
* 20027 "haiti"
* 20014 "colombia"

*Todos los que me quedan aca son inmigrantes
replace P19=-1 if P19==.
* Genero las dummies anteriores para +18 y +23 para calcular los años promedio de educacion en esos grupos
foreach edad in 18 23{
	foreach j in "_prebasico" "_basico" "_medio" "_tecnico" "_univers" "_nada" "_nodice"{
	gen post`edad'est`j'=(est`j'==1 & P19>`edad')
	}
}

* Ahora tiro todas las otras cosas que no necesito
* Variables que no tengan que ver con pais de origen o residencia en chile
keep P22A Codigo P22C P23A P23B P24A P24B CodigoActual comuna est_* post*
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
replace cat_pais="hai" if cat_pais=="20027"
replace cat_pais="col" if cat_pais=="20014"

gen imm_haiti=(cat_pais=="haiti")
gen imm_haiti_colom=(cat_pais=="haiti" | cat_pais=="colombia")
* Sus complementos
gen imm_NOhaiti=(cat_pais!="haiti")
gen imm_NOhaiti_colom=(imm_haiti_colom==0)

gen year=2002

sort cod_com year
collapse (sum) imm* est_* post*, by(cod_com year)

cd "$conf_intermed"
save collapse2002, replace

append using immigration_collapse

* Ahora saco stocks por año
sort cod_com year
* Para los inmigrantes por origen
foreach j in "" "_haiti" "_haiti_colom" "_NOhaiti" "_NOhaiti_colom"{
	bys cod_com: gen stock_imm`j'=sum(imm`j')
}
* Para inmigrantes por grupo educativo
foreach j in "_prebasico" "_basico" "_medio" "_tecnico" "_univers" "_nada" "_nodice"{
	bys cod_com: gen stock_est`j'=sum(est`j')
}
* Para inmigrantes por grupo educativo +18 y +23
foreach j in "_prebasico" "_basico" "_medio" "_tecnico" "_univers" "_nada" "_nodice"{
	foreach edad in 18 23{
		bys cod_com: gen stock_post`edad'est`j'=sum(post`edad'est`j')
	}
}

* Calculo 3 tipos de años promedio de educacion: para todos los inmigrantes, para los +18 y para los +23. Esto para flujos y para stocks (quedan 6 variables)
* Para todos en stocks
gen STOCKS_years_ed_inmigr=(1*stock_est_prebasico + 6*stock_est_basico + 12*stock_est_medio + 13*stock_est_tecnico + 16*stock_est_univers)
replace STOCKS_years_ed_inmigr = STOCKS_years_ed_inmigr/(stock_est_nada + stock_est_prebasico + stock_est_basico + stock_est_medio + stock_est_tecnico + stock_est_univers)
replace STOCKS_years_ed_inmigr=0 if STOCKS_years_ed_inmigr==.
* Para todos en flujos
gen FLUJOS_years_ed_inmigr=(1*est_prebasico + 6*est_basico + 12*est_medio + 13*est_tecnico + 16*est_univers)
replace FLUJOS_years_ed_inmigr = FLUJOS_years_ed_inmigr/(est_nada + est_prebasico + est_basico + est_medio + est_tecnico + est_univers)
replace FLUJOS_years_ed_inmigr=0 if FLUJOS_years_ed_inmigr==.

* Por grupo etario:
local STOCKS "stock_"
local FLUJOS ""
foreach edad in 18 23{
	foreach type in STOCKS FLUJOS{
		gen `type'_post`edad'_years_ed_inmigr=(1*``type''post`edad'est_prebasico + 6*``type''post`edad'est_basico + 12*``type''post`edad'est_medio + 13*``type''post`edad'est_tecnico + 16*``type''post`edad'est_univers)
		replace `type'_post`edad'_years_ed_inmigr = `type'_post`edad'_years_ed_inmigr/(``type''post`edad'est_nada + ``type''post`edad'est_prebasico + ``type''post`edad'est_basico + ``type''post`edad'est_medio + ``type''post`edad'est_tecnico + ``type''post`edad'est_univers)
		replace `type'_post`edad'_years_ed_inmigr=0 if `type'_post`edad'_years_ed_inmigr==.
		
	}
}


keep if year > 2007
drop if year==2018
save immigration_collapse, replace

*Genero una base de poblacion con poblacion por comuna + codigo comuna para hacer el merge
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

* A las comunas que existen pero no estaban en la base de inmigracion (asumo que porque no habian recibido inmigrantes en los años correspondientes) les imputo 0 en todas las variables del tipo # de inmigrantes. NO SE QUE HACER CON AÑOS PROMEDIO DE EDUCACION
merge 1:1 cod_com year using immigration_collapse
mvencode imm* stock_* est_* if _merge==1, mv(0)
drop _merge

* Cambio los nombres de las variables para que quede claro cuales son flujos y cuales stocks:
foreach j in "" "_haiti" "_haiti_colom" "_NOhaiti" "_NOhaiti_colom"{
	rename imm`j' flujo_imm`j'
}
foreach j in "_prebasico" "_basico" "_medio" "_tecnico" "_univers" "_nada" "_nodice"{
	rename est`j' flujo_est`j'
}


* Genero rates de inmigracion y de stock de inmigrantes para haitianos
foreach j in "" "_haiti" "_haiti_colom" "_NOhaiti" "_NOhaiti_colom"{
	gen rate_flujo_imm`j'=flujo_imm`j'/population
	gen rate_stock_imm`j'=stock_imm`j'/population
}

* Genero proporcion de inmigrantes en cada grupo de estudios para flujos y stocks
foreach j in "_prebasico" "_basico" "_medio" "_tecnico" "_univers" "_nada" "_nodice"{
	gen prop_flujo_est`j'=flujo_est`j'/flujo_imm
	replace prop_flujo_est`j'=0 if prop_flujo_est`j'==.
	gen prop_stock_est`j'=stock_est`j'/stock_imm
	replace prop_stock_est`j'=0 if prop_stock_est`j'==.
}


save immigration_collapse, replace

}

* Genero la base de inmigracion a nivel individual donde cada inmigrante va ponderado por la distancia genetica (normalizada) a la poblacion de chile
{
cd "$rawdata"
* Ahora voy a la base de distancia genetica y me quedo con la distancia entre chile y esos 30 paises
use bilateral_replic, clear
keep if country_1=="Chile" | country_2=="Chile"
keep country_1 country_2 new_gendist_weighted
replace country_2=country_1 if country_2=="Chile"
drop country_1
replace country_2=lower(country_2)
rename country_2 cat_pais
* Normalizo la variable
summ new_gendist_weighted
gen distancia=(new_gendist_weighted - `r(min)')/(`r(max)' - `r(min)')

* Cambio uno por uno los nombres que hacen falta (estan in ingles y los necesito en español). El proceso: ir haciendo merges con la base de inmigracion y concentrarme en las observaciones que no matcheaban. Todos los paises que estan en ambas bases estan con los nombres correctos para que matcheen, despues hay como 50 y pico paises aca que no estan en la base de migrantes (y entre 10 y 13 paises de migrantes que no estan en esta base)
replace cat_pais="francia" if cat_pais=="france"
replace cat_pais="federacion de rusia" if cat_pais=="russian federation"
replace cat_pais="grecia" if cat_pais=="greece"
replace cat_pais="brasil" if cat_pais=="brazil"
replace cat_pais="islandia" if cat_pais=="iceland"
replace cat_pais="hungria" if cat_pais=="hungary"
replace cat_pais="belgica" if cat_pais=="belgium"
replace cat_pais="dinamarca" if cat_pais=="denmark"
replace cat_pais="uk" if cat_pais=="united kingdom"
replace cat_pais="turquia" if cat_pais=="turkey"
replace cat_pais="irlanda" if cat_pais=="ireland"
replace cat_pais="finlandia" if cat_pais=="finland"
replace cat_pais="taiwan-china" if cat_pais=="taiwan"
replace cat_pais="filipinas" if cat_pais=="philippines"
replace cat_pais="etiopia" if cat_pais=="ethiopia"
replace cat_pais="sierra leona" if cat_pais=="sierra leone"
replace cat_pais="tailandia" if cat_pais=="thailand"
replace cat_pais="argelia" if cat_pais=="algeria"
replace cat_pais="suecia" if cat_pais=="sweden"
replace cat_pais="tunez" if cat_pais=="tunisia"
replace cat_pais="lituania" if cat_pais=="lithuania"
replace cat_pais="ucrania" if cat_pais=="ukraine"
replace cat_pais="suiza" if cat_pais=="switzerland"
replace cat_pais="eslovaquia" if cat_pais=="slovakia"
replace cat_pais="malasia" if cat_pais=="malaysia"
replace cat_pais="eslovenia" if cat_pais=="slovenia"
replace cat_pais="noruega" if cat_pais=="norway"
replace cat_pais="jordania" if cat_pais=="jordan"
replace cat_pais="kazajstan republica" if cat_pais=="kazakhstan"
replace cat_pais="irak" if cat_pais=="iraq"
replace cat_pais="egipto, republica arabe de" if cat_pais=="egypt"
replace cat_pais="rumania" if cat_pais=="romania"
replace cat_pais="afganistan" if cat_pais=="afghanistan"
replace cat_pais="letonia" if cat_pais=="latvia"
replace cat_pais="macedonia (fyrom)" if cat_pais=="macedonia"
replace cat_pais="republica dominicana" if cat_pais=="dominican republic"
replace cat_pais="mauricio" if cat_pais=="mauritius"
replace cat_pais="congo, republica democratica" if cat_pais=="congo"
replace cat_pais="nueva zelandia" if cat_pais=="new zealand"
replace cat_pais="libano" if cat_pais=="lebanon"
replace cat_pais="belice" if cat_pais=="belize"
replace cat_pais="luxemburgo" if cat_pais=="luxembourg"
replace cat_pais="kirguistan" if cat_pais=="kyrgyzstan"
replace cat_pais="singapur" if cat_pais=="singapore"
replace cat_pais="polonia" if cat_pais=="poland"
replace cat_pais="japon" if cat_pais=="japan"
replace cat_pais="sudafrica republica de" if cat_pais=="south africa"
replace cat_pais="republica de guyana" if cat_pais=="guyana"
replace cat_pais="marruecos" if cat_pais=="morocco"
replace cat_pais="costa de marfil" if cat_pais=="cote d'ivoire"
replace cat_pais="republica checa" if cat_pais=="czech republic"
replace cat_pais="italia" if cat_pais=="italy"
replace cat_pais="alemania" if cat_pais=="germany"
replace cat_pais="trinidad y tobago" if cat_pais=="trinidad and tobago"
replace cat_pais="siria" if cat_pais=="syria"
replace cat_pais="camerun" if cat_pais=="cameroon"
replace cat_pais="paises bajos" if cat_pais=="netherlands"
replace cat_pais="republica de bielorrusia" if cat_pais=="belarus"
replace cat_pais="san vicente y las granadinas" if cat_pais=="st. vincent"
replace cat_pais="chipre" if cat_pais=="cyprus"
replace cat_pais="republica popular democratica de corea" if cat_pais=="korea,dem.rep."
replace cat_pais="estados unidos" if cat_pais=="u.s.a"
replace cat_pais="croacia" if cat_pais=="croatia"
replace cat_pais="espana" if cat_pais=="spain"
* Hasta aca estan matcheados todos los paises posibles que estan en ambas bases. Quedan unos cuantos que estan en la base de inmigracion pero no en la de distancias, a esos les imputo la distancia promedio.

cd "$conf_intermed"
save distancias_por_pais, replace

* Agarro la base de inmigrantes
cd "$rawdata"
use immigration_Correciones, clear
*Conteo - estos son inmigrantes cuyo pais no esta en la base anterior
// count if cat_pais=="republica de corea" | cat_pais=="canada" | cat_pais=="congo (brazzaville)" | cat_pais=="serbia y montenegro" | cat_pais=="yugoslavia" | cat_pais=="bosnia y herzegovina" | cat_pais=="andorra" | cat_pais=="togo" | cat_pais=="tanzania republica unida" | cat_pais=="apatrida" | cat_pais=="chile" | cat_pais=="otros" | cat_pais=="palestina" 

drop if comuna=="florida" & cod_com==8404
drop if cod_com==96
drop if year==2018

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

cd "$conf_intermed"
save immigration_etnia, replace

* Agarro el censo. Aca voy a tener qu identificar los paises que pueda (la variable pais de origen esta codificada y no tengo los codigos, asi que replico tablas de los resultados del censo y me voy fijando qué pais representa cada codigo mirando los documentos oficiales)
cd "$rawdata"
use PERSONA_comuna_distrito.dta, clear
* La variable Codigo tiene el codigo de comuna de la residencia actual para cada individuo
rename Codigo CodigoActual
* La variable P22B tiene la pregunta "comuna de origen", que tiene el codigo por pais para los inmigrantes residentes
rename P22B Codigo
* La mergeo con la base de las comunas y me quedo con los que no hagan match
merge m:1 Codigo using COMUNAS
* Estas observaciones no sirven
drop if Codigo==99999
* Con este comando y los Cuadros 2.1 y 2.2 (p111) del documento "Censo 2002 Chile con Cuestionario" voy encontrando los codigos para los paises (comparo numeros, dan iguales). PROBLEMA: LAS TABLAS DEL CENSO AGRUPAN A VARIOS PAISES COMO "OTROS" Y SON IMPOSIBLES DE IDENTIFICAR.
keep if _merge==1
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


* Voy tirando los tabs por region. El match no es perfecto: muchos paises no pueden ser identificados porque paises con pocos migrantes son tratados como "otros" en los resultados del censo 2002. 
groups Codigo if Codigo<30000, order(h)
tostring Codigo, gen(strCodigo)
rename strCodigo cat_pais

* Africa
groups Codigo if Codigo<20000 & Codigo>10000, order(h)

replace cat_pais="egipto, republica arabe de" if cat_pais=="10013"
replace cat_pais="argelia" if cat_pais=="10002"

* America del sur, del norte, del centro:
groups Codigo if Codigo<30000 & Codigo>20000, order(h)

replace cat_pais="argentina" if cat_pais=="20004"
replace cat_pais="peru" if cat_pais=="20042"
replace cat_pais="bolivia" if cat_pais=="20010"
replace cat_pais="ecuador" if cat_pais=="20018"
replace cat_pais="estados unidos" if cat_pais=="20020"
replace cat_pais="brasil" if cat_pais=="20011"
replace cat_pais="venezuela" if cat_pais=="20052"
replace cat_pais="colombia" if cat_pais=="20014"
replace cat_pais="cuba" if cat_pais=="20016"
replace cat_pais="uruguay" if cat_pais=="20051"
replace cat_pais="canada" if cat_pais=="20012"
replace cat_pais="mexico" if cat_pais=="20037"
replace cat_pais="paraguay" if cat_pais=="20041"
replace cat_pais="panama" if cat_pais=="20040"
replace cat_pais="costa rica" if cat_pais=="20015"
replace cat_pais="republica dominicana" if cat_pais=="20044"
replace cat_pais="honduras" if cat_pais=="20028"
replace cat_pais="nicaragua" if cat_pais=="20039"
replace cat_pais="el salvador" if cat_pais=="20019"
replace cat_pais="guatemala" if cat_pais=="20024"
replace cat_pais="puerto rico" if cat_pais=="20043"
replace cat_pais="haiti" if cat_pais=="20027"

* Asia
groups Codigo if Codigo<40000 & Codigo>30000, order(h)

replace cat_pais="china" if cat_pais=="30011"
replace cat_pais="republica de corea" if cat_pais=="30037"
replace cat_pais="japon" if cat_pais=="30021"
replace cat_pais="taiwan-china" if cat_pais=="30044"
replace cat_pais="palestina" if cat_pais=="30035"
replace cat_pais="federacion de rusia" if cat_pais=="30039"
replace cat_pais="india" if cat_pais=="30016"
replace cat_pais="israel" if cat_pais=="30020"
replace cat_pais="siria" if cat_pais=="30041"
replace cat_pais="turquia" if cat_pais=="30047"
replace cat_pais="libano" if cat_pais=="30027"
replace cat_pais="arabia saudita" if cat_pais=="30002"
replace cat_pais="jordania" if cat_pais=="30022"
replace cat_pais="hong kong" if cat_pais=="30015"
replace cat_pais="republica popular democratica de corea" if cat_pais=="30038"

* Europa
groups Codigo if Codigo<50000 & Codigo>40000, order(h)

replace cat_pais="espana" if cat_pais=="40014"
replace cat_pais="alemania" if cat_pais=="40002"
replace cat_pais="italia" if cat_pais=="40025"
replace cat_pais="francia" if cat_pais=="40017"
replace cat_pais="uk" if cat_pais=="40036"
replace cat_pais="suecia" if cat_pais=="40041"
replace cat_pais="belgica" if cat_pais=="40005"
replace cat_pais="paises bajos" if cat_pais=="40020"
replace cat_pais="austria" if cat_pais=="40004"
replace cat_pais="polonia" if cat_pais=="40034"
replace cat_pais="yugoslavia" if cat_pais=="40045"
replace cat_pais="croacia" if cat_pais=="40010"
replace cat_pais="rumania" if cat_pais=="40039"
replace cat_pais="noruega" if cat_pais=="40033"
replace cat_pais="hungria" if cat_pais=="40021"
replace cat_pais="portugal" if cat_pais=="40035"
replace cat_pais="dinamarca" if cat_pais=="40011"
replace cat_pais="grecia" if cat_pais=="40019"
replace cat_pais="republica checa" if cat_pais=="40037"
replace cat_pais="finlandia" if cat_pais=="40016"

* Oceania
groups Codigo if Codigo<60000 & Codigo>50000, order(h)
replace cat_pais="australia" if cat_pais=="50002"


* Variables que no tengan que ver con pais de origen o residencia en chile
keep age P22A Codigo P22C P23A P23B P24A P24B CodigoActual comuna cat_pais
* Ahora tengo que averiguar cuantos de los nacidos en otro pais residen en chile o no
rename Codigo P22B
rename P23B Codigo
merge m:1 Codigo using COMUNAS

drop if _merge==2
* Son 4 observaciones, supongo que hay 4 comunas en las que no habia ningun inmigrante de los paises de arriba
drop if _merge==1
* 46076 transeuntes, 184464 inmigrantes residentes, como indica el documento oficial
drop _merge

gen year=2002
gen imm=1

* NO TIRAR, IMPUTAR LA MEDIA EN VEZ DE ESO
drop if cat_pais=="arabia saudita" | cat_pais=="puerto rico"
rename CodigoActual cod_com

cd "$conf_intermed"

save censo_etnias, replace

* Para chequear cuantos inmigrantes de 2002 quedan sin pais identificado (despues, el set de inmigrantes que queda sin valor en distancia de 2002 es mas grande, porque hay varios paises que no estan en la base de etnias). Quedan con valor = 1 en la variable "otros"
cd "$conf_intermed"
use censo_etnias, clear
sort cat_pais
quietly by cat_pais: gen dup=cond(_N==1,0,_n)
drop if dup > 1
drop dup cod_com
merge 1:m cat_pais using immigration_etnia
keep if _merge==1
rename _merge otros
keep otros cat_pais
merge 1:m cat_pais using censo_etnias
drop _merge


append using immigration_etnia
sort cod_com year
save immigration_etnia, replace


merge m:1 cat_pais using distancias_por_pais
drop if _merge==2
drop _merge
* Los inmigrantes de paises que no estaban en la base de distancias son imputados la distancia promedio
summ distancia
mvencode distancia if distancia==., mv(`r(mean)')

keep cat_pais year cod_com distancia comuna imm mujer_joven hombre_joven mujer_nojoven hombre_nojoven new_gendist_weighted
save immigration_etnia, replace

}

* Agrego las variables de inmigracion ponderadas por etnia
{

cd "$conf_intermed"
use immigration_etnia, clear

* La variable distancia esta normalizada ((x-min)/(max-min)), la uso para ponderar las sumas de inmigrantes por comuna.
* Colapso a nivel comuna año
rename distancia flujo_imm_etnia
collapse (sum) flujo_imm_etnia, by(cod_com year)
* Genero stocks
sort cod_com year
* Para los inmigrantes por origen
bys cod_com: gen stock_imm_etnia=sum(flujo_imm_etnia)
keep if year>2007

merge 1:1 cod_com year using immigration_collapse
* Como siempre, faltan comunas en la base de inmigracion para coms en las que no hubo inmigracion para algunos años. Imputo 0's. 243 observaciones comuina-año
mvencode flujo_imm_etnia stock_imm_etnia if _merge==2, mv(0)
drop _merge

* Genero rates de inmigracion y de stock de inmigrantes para haitianos
foreach j in "flujo_" "stock_"{
	gen rate_`j'imm_etnia=`j'imm_etnia/population
}


save immigration_collapse, replace

}


* Agrego la base de medios
{
cd "$rawdata"
use countTS, clear
* La preparo para el merge con la base de poblacion, que tiene los codigos comuna
rename COMUNAPLANTA comuna
replace comuna=lower(comuna)
replace comuna=subinstr(comuna,"Ñ","n",.)
replace comuna="llaillay" if comuna=="llay llay"
replace comuna="alto biobio" if comuna=="alto bio bio"
replace comuna="paiguano" if comuna=="paihuano"
replace comuna="el olivar" if comuna=="olivar"
replace comuna="marchihue" if comuna=="marchigue"
replace comuna="ollague" if comuna=="ollagÜe"
replace comuna="treguaco" if comuna=="trehuaco"
drop if comuna=="aisen"
replace comuna="aisen" if comuna=="aysen"

cd "$conf_intermed"
merge 1:1 comuna using population
* Las observaciones que quedan con merge=1 son ciudades que estaban en la base de medios. No son comunas asi que las tiro
drop if _merge==1
* Las observaciones que quedan con merge=2 son comunas que existen pero no estan en la base de medios. Asumo que es que no tienen nada y les imputo un 0
mvencode TS* if _merge==2, mv(0)
drop _merge

* Variable para AM + FM
gen TS_AM_FM=TS_AM+TS_FM
* Genero los rates por poblacion
foreach var in AM FM AM_FM all{
	gen rate`var'=TS_`var'/population
}

* Merge con la base de inmigracion
merge 1:m cod_com using immigration_collapse
drop _merge
sort cod_com year
save immigration_collapse, replace
}

* Agrego la variable de distancia etnica por comuna
{
cd "$rawdata"
* Armo el ranking para ver los top 30 paises de origen entre inmigrantes de chile que hayan entrado entre 2008 y 2017
use immigration_Correciones, clear
keep if year>2007 & year<2018
collapse(sum) imm, by(cat_pais)
gsort -imm
* Top 30 paises:
// peru
// colombia
// bolivia
// venezuela
// haiti
// argentina
// ecuador
// espana
// estados unidos
// china
// republica dominicana
// brasil
// mexico
// paraguay
// cuba
// uruguay
// francia
// alemania
// italia
// republica de corea
// uk
// canada
// india
// federacion de rusia
// portugal
// australia
// el salvador
// panama
// japon
// honduras
* NO ESTA CANADA EN LA BASE DE DISTANCIA GENETICA ASI QUE PONGO EL PAIS 31 EN SU LUGAR:
// costa rica
cd "$rawdata"
* Ahora voy a la base de distancia genetica y me quedo con la distancia entre chile y esos 30 paises
use bilateral_replic, clear
keep if country_1=="Chile" | country_2=="Chile"
keep country_1 country_2 new_gendist_weighted
replace country_2=country_1 if country_2=="Chile"
drop country_1
replace country_2=lower(country_2)
keep if country_2=="peru" | country_2=="colombia" | country_2=="bolivia" | country_2=="venezuela" | country_2=="haiti" | country_2=="argentina" | country_2=="ecuador" | country_2=="spain" | country_2=="u.s.a" | country_2=="china" | country_2=="dominican republic" | country_2=="brazil" | country_2=="mexico" | country_2=="paraguay" | country_2=="cuba" | country_2=="uruguay" | country_2=="france" | country_2=="germany" | country_2=="italy" | country_2=="korea,dem.rep." | country_2=="united kingdom" | country_2=="india" | country_2=="russian federation" | country_2=="portugal" | country_2=="australia" | country_2=="el salvador" | country_2=="panama" | country_2=="japan" | country_2=="honduras" | country_2=="costa rica"

replace country_2=substr(country_2,1,3)
replace country_2="eeuu" if country_2=="u.s"
replace country_2="repdom" if country_2=="dom"
replace country_2="ale" if country_2=="ger"
replace country_2="cor" if country_2=="kor"
replace country_2="uk" if country_2=="uni"
replace country_2="salv" if country_2=="el "
replace country_2="c_rica" if country_2=="cos"
replace country_2="esp" if country_2=="spa"

rename new_gendist_weighted distancia_
gen year=2008
reshape wide distancia, i(year) j(country_2) string

* Para despues matchear sin problemas usando el año
foreach year in 2009 2010 2011 2012 2013 2014 2015 2016 2017{
	expand 2 if year==2008, generate(newv)
	replace year=`year' if newv==1
	drop newv
}

cd "$conf_intermed"
save distancias_etnic, replace

* Ahora armo los stocks para cada uno de esos paises para cada comuna-año
cd "$rawdata"
use immigration_Correciones, clear
drop if comuna=="florida" & cod_com==8404
drop if cod_com==96
drop if year==2018
replace cat_pais="dominicana" if cat_pais=="republica dominicana"
replace cat_pais="cor" if cat_pais=="republica de corea"
replace cat_pais=substr(cat_pais,1,3)
replace cat_pais="eeuu" if cat_pais=="est"
replace cat_pais="repdom" if cat_pais=="dom"
replace cat_pais="rus" if cat_pais=="fed"
replace cat_pais="salv" if cat_pais=="el "
replace cat_pais="c_rica" if cat_pais=="cos"

keep if cat_pais=="per" | cat_pais=="col" | cat_pais=="bol" | cat_pais=="ven" | cat_pais=="hai" | cat_pais=="arg" | cat_pais=="ecu" | cat_pais=="esp" | cat_pais=="eeuu" | cat_pais=="repdom" | cat_pais=="chi" | cat_pais=="bra" | cat_pais=="mex" | cat_pais=="par" | cat_pais=="cub" | cat_pais=="uru" | cat_pais=="fra" | cat_pais=="ale" | cat_pais=="ita" | cat_pais=="cor" | cat_pais=="uk" | cat_pais=="ind" | cat_pais=="rus" | cat_pais=="por" | cat_pais=="aus" | cat_pais=="salv" | cat_pais=="pan" | cat_pais=="jap" | cat_pais=="hon" | cat_pais=="c_rica"

foreach country in "per" "col" "bol" "ven" "hai" "arg" "ecu" "esp" "eeuu" "repdom" "chi" "bra" "mex" "par" "cub" "uru" "fra" "ale" "ita" "cor" "uk" "ind" "rus" "por" "aus" "salv" "pan" "jap" "hon" "c_rica"{
	gen imm_`country'=(cat_pais=="`country'")
}

collapse (sum) imm*, by(cod_com year)
cd "$conf_intermed"
save stocks_imm, replace
* Le meto el censo y despues calculo, para cada comuna en cada año, el stock total de inmigrantes de los 30 paises de arriba + el stock de cada pais individual

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
* 20044 "repdom"
* 20037 "mexico"
* 20041 "paraguay"
* 20016 "cuba"
* 20051 "uruguay"
* 40017 "francia"
* 30037 "corea"
* 40036 "uk"
* 30016 "india"
* 30039 "rusia"
* 40035 "portugal"
* 50002 "australia"
* 20019 "el salvador"
* 20040 "panama"
* 30021 "japon"
* 20028 "honduras"
* 20015 "costa rica"

* Ahora tiro todas las otras cosas que no necesito
* No inmigrantes de los paises que quiero
keep if Codigo==20020 | Codigo==20004 | Codigo==20010 | Codigo==20014 | Codigo==20018 | Codigo==20042 | Codigo==20052 | Codigo==40014 | Codigo==30011 | Codigo==20011 | Codigo==40002 | Codigo==40025 | Codigo==20027 | Codigo==20044 | Codigo==20037  | Codigo==20041 | Codigo==20016 | Codigo==20051 | Codigo==40017  | Codigo==30037  | Codigo==40036  | Codigo==30016  | Codigo==30039  | Codigo==40035  | Codigo==50002  | Codigo==20019  | Codigo==20040  | Codigo==30021  | Codigo==20028  | Codigo==20015
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
replace cat_pais="repdom" if cat_pais=="20044"
replace cat_pais="mex" if cat_pais=="20037"
replace cat_pais="par" if cat_pais=="20041"
replace cat_pais="cub" if cat_pais=="20016"
replace cat_pais="uru" if cat_pais=="20051"
replace cat_pais="fra" if cat_pais=="40017"
replace cat_pais="cor" if cat_pais=="30037"
replace cat_pais="uk" if cat_pais=="40036"
replace cat_pais="ind" if cat_pais=="30016"
replace cat_pais="rus" if cat_pais=="30039"
replace cat_pais="por" if cat_pais=="40035"
replace cat_pais="aus" if cat_pais=="50002"
replace cat_pais="salv" if cat_pais=="20019"
replace cat_pais="pan" if cat_pais=="20040"
replace cat_pais="jap" if cat_pais=="30021"
replace cat_pais="hon" if cat_pais=="20028"
replace cat_pais="c_rica" if cat_pais=="20015"

gen year=2002
keep cat_pais cod_com comuna year imm

foreach country in "per" "col" "bol" "ven" "hai" "arg" "ecu" "esp" "eeuu" "repdom" "chi" "bra" "mex" "par" "cub" "uru" "fra" "ale" "ita" "cor" "uk" "ind" "rus" "por" "aus" "salv" "pan" "jap" "hon" "c_rica"{
	gen imm_`country'=(cat_pais=="`country'")
}

collapse (sum) imm*, by(cod_com year)
cd "$conf_intermed"
save stocks_2002, replace

append using stocks_imm

sort cod_com year
* Ahora saco stocks por año
bys cod_com: gen stock_imm=sum(imm)
foreach country in "per" "col" "bol" "ven" "hai" "arg" "ecu" "esp" "eeuu" "repdom" "chi" "bra" "mex" "par" "cub" "uru" "fra" "ale" "ita" "cor" "uk" "ind" "rus" "por" "aus" "salv" "pan" "jap" "hon" "c_rica"{
	bys cod_com: gen stock_`country'=sum(imm_`country')
}
keep if  year>2007
drop if year==2018
save stocks_imm, replace
use population, clear
gen year=2008
foreach year in 2009 2010 2011 2012 2013 2014 2015 2016 2017{
	expand 2 if year==2008, generate(newv)
	replace year=`year' if newv==1
	drop newv
}
sort cod_com year
merge 1:1 cod_com year using stocks_imm
* Va 0 en todas las imm para las comunas que no estaban en la base de inmigracion
mvencode imm* stock* if _merge==1, mv(0)
drop _merge
* Me quedo solo con los stocks
drop imm*
merge m:1 year using distancias_etnic
drop _merge
sort cod_com year
* Genero el indice por pais-comuna-año y despues los sumo por comuna-año
foreach country in "per" "col" "bol" "ven" "hai" "arg" "ecu" "esp" "eeuu" "repdom" "chi" "bra" "mex" "par" "cub" "uru" "fra" "ale" "ita" "cor" "uk" "ind" "rus" "por" "aus" "salv" "pan" "jap" "hon" "c_rica"{
	gen index_`country'=(stock_`country' * distancia_`country')/stock_imm
	replace index_`country'=0 if index_`country'==.
}

egen mean_distance=rowtotal(index_*)
drop index_* stock_* distancia_*

save distance_index, replace

merge 1:1 cod_com year using immigration_collapse
drop _merge
save immigration_collapse, replace

}

* Agrego controles CASEN para el panel
{
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

foreach age in 18 23{
	gen esc_post`age'=esc if edad>`age'
}

* Creo variable de años de educacion definida IGUAL que para la base de inmigrantes (escalonada por nivel educativo)
* Años de educacion
* prebasico
gen years_educ=1 if e8t==1
* preparatoria, basico y ed especial
replace years_educ=6 if e8t==2 | e8t==3 | e8t==4
* media (humanidades, media cientifico humanista, yecnica comercial industrial o normalista y media tecnica profesional )
replace years_educ=12 if e8t==5 | e8t==6 | e8t==7 | e8t==8
* tecnico (centro de formacion tecnica incompleta o completa o isntituto profesional completo o incompleto)
replace years_educ=13 if e8t==9 | e8t==10 | e8t==11 | e8t==12
* universitaria completa o incompleta o posgrado
replace years_educ=16 if e8t==13 | e8t==14 | e8t==15
* nada
replace years_educ=0 if e8t==16

foreach age in 18 23{
	gen post_`age'years_ed_nativos=years_educ if edad>`age'
}

replace expc=round(expc)
* Colapsando la suma de expc a nivel comuna voy a tener el denominador para calcular los % de cada variable
collapse (mean) hombre age ypc expc years_educ esc* post* [fw=expc], by(cod_com)

* Le faltan comunas
cd "$conf_intermed"
save controlesCASEN06, replace
* Le meto años promedio de educacion sin usar ponderadores
cd "$rawdata"
import excel División-Político-Administrativa-y-Servicios-de-Salud-Histórico.xls, firstrow clear
keep CódigoComunadesde2000 CódigoComunadesde2010
rename CódigoComunadesde2000 comuna
merge 1:n comuna using casen2006
keep if _merge==3
drop comuna
rename CódigoComunadesde2010 cod_com
drop _merge
keep if pco1==1
gen NWyears_educ=1 if e8t==1
replace NWyears_educ=6 if e8t==2 | e8t==3 | e8t==4
replace NWyears_educ=12 if e8t==5 | e8t==6 | e8t==7 | e8t==8
replace NWyears_educ=13 if e8t==9 | e8t==10 | e8t==11 | e8t==12
replace NWyears_educ=16 if e8t==13 | e8t==14 | e8t==15
replace NWyears_educ=0 if e8t==16
rename esc NWesc
foreach age in 18 23{
	gen NWpost_`age'years_ed_nativos=NWyears_educ if edad>`age'
	gen NWesc_post`age'=NWesc if edad>`age'
}

collapse (mean) NWyears_educ NWesc* NWpost*, by(cod_com)
cd "$conf_intermed"
merge 1:1 cod_com using controlesCASEN06
drop _merge
save controlesCASEN06, replace

}
* 2 0 0 9 ----------------------------------------------
{
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

* Creo variable de años de educacion definida IGUAL que para la base de inmigrantes (escalonada por nivel educativo)
* Años de educacion
* prebasico
gen years_educ=1 if e7t==1
* preparatoria, basico y ed especial
replace years_educ=6 if e7t==2 | e7t==3 | e7t==4
* media (humanidades, media cientifico humanista, yecnica comercial industrial o normalista y media tecnica profesional )
replace years_educ=12 if e7t==5 | e7t==6 | e7t==7 | e7t==8
* tecnico (centro de formacion tecnica incompleta o completa o isntituto profesional completo o incompleto)
replace years_educ=13 if e7t==9 | e7t==10 | e7t==11 | e7t==12
* universitaria completa o incompleta o posgrado
replace years_educ=16 if e7t==13 | e7t==14 | e7t==15
* nada
replace years_educ=0 if e7t==16

foreach age in 18 23{
	gen post_`age'years_ed_nativos=years_educ if edad>`age'
	gen esc_post`age'=esc if edad>`age'
}

replace expc=round(expc)
* Colapsando la suma de expc a nivel comuna voy a tener el denominador para calcular los % de cada variable
collapse (mean) hombre age ypc expc years_educ esc* post* [fw=expc], by(cod_com)

cd "$conf_intermed"
save controlesCASEN09, replace
*Meto años de educ promedio sin usar ponderadores
cd "$rawdata"
import excel División-Político-Administrativa-y-Servicios-de-Salud-Histórico.xls, firstrow clear
keep CódigoComunadesde2008 CódigoComunadesde2010
rename CódigoComunadesde2008 comuna
merge 1:n comuna using casen2009
keep if _merge==3
drop comuna
rename CódigoComunadesde2010 cod_com
drop _merge
keep if pco1==1
gen NWyears_educ=1 if e7t==1
replace NWyears_educ=6 if e7t==2 | e7t==3 | e7t==4
replace NWyears_educ=12 if e7t==5 | e7t==6 | e7t==7 | e7t==8
replace NWyears_educ=13 if e7t==9 | e7t==10 | e7t==11 | e7t==12
replace NWyears_educ=16 if e7t==13 | e7t==14 | e7t==15
replace NWyears_educ=0 if e7t==16
rename esc NWesc
foreach age in 18 23{
	gen NWpost_`age'years_ed_nativos=NWyears_educ if edad>`age'
	gen NWesc_post`age'=NWesc if edad>`age'
}

collapse (mean) NWyears_educ NWesc* NWpost*, by(cod_com)
cd "$conf_intermed"
merge 1:1 cod_com using controlesCASEN09
drop _merge
save controlesCASEN09, replace
}

* 2 0 1 1 ----------------------------------------------
{
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

* Creo variable de años de educacion definida IGUAL que para la base de inmigrantes (escalonada por nivel educativo)
* Años de educacion
* prebasico (jardin de infantes, kinder)
gen years_educ=1 if e6a==2 | e6a==3
* preparatoria, basico y ed especial
replace years_educ=6 if e6a==4 | e6a==5 | e6a==6
* media (humanidades, media cientifico humanista, yecnica comercial industrial o normalista y media tecnica profesional )
replace years_educ=12 if e6a==7 | e6a==8 | e6a==9 | e6a==10
* tecnico (tecnico nivel superior)
replace years_educ=13 if e6a==11
* universitaria completa o incompleta o posgrado
replace years_educ=16 if e6a==12 | e6a==13
* nada
replace years_educ=0 if e6a==1

foreach age in 18 23{
	gen post_`age'years_ed_nativos=years_educ if edad>`age'
	gen esc_post`age'=esc if edad>`age'
}

replace expc=round(expc)
* Colapsando la suma de expc a nivel comuna voy a tener el denominador para calcular los % de cada variable
collapse (mean) hombre age ypc expc years_educ esc* post* [fw=expc], by(cod_com)

cd "$conf_intermed"
save controlesCASEN11, replace
* educ promedio sin ponderadores
cd "$rawdata"
import excel División-Político-Administrativa-y-Servicios-de-Salud-Histórico.xls, firstrow clear
keep CódigoComunadesde2010
rename CódigoComunadesde2010 comuna
merge 1:n comuna using casen2011
rename comuna cod_com
keep if _merge==3
drop _merge
keep if pco1==1
gen NWyears_educ=1 if e6a==2 | e6a==3
replace NWyears_educ=6 if e6a==4 | e6a==5 | e6a==6
replace NWyears_educ=12 if e6a==7 | e6a==8 | e6a==9 | e6a==10
replace NWyears_educ=13 if e6a==11
replace NWyears_educ=16 if e6a==12 | e6a==13
replace NWyears_educ=0 if e6a==1
rename esc NWesc
foreach age in 18 23{
	gen NWpost_`age'years_ed_nativos=NWyears_educ if edad>`age'
	gen NWesc_post`age'=NWesc if edad>`age'
}
collapse (mean) NWyears_educ NWesc* NWpost*, by(cod_com)
cd "$conf_intermed"
merge 1:1 cod_com using controlesCASEN11
drop _merge
save controlesCASEN11, replace

}

* 2 0 1 3 ----------------------------------------------
{
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

* Creo variable de años de educacion definida IGUAL que para la base de inmigrantes (escalonada por nivel educativo)
* Años de educacion
* prebasico (jardin de infantes, kinder)
gen years_educ=1 if e6a==2 | e6a==3
* preparatoria, basico y ed especial
replace years_educ=6 if e6a==4 | e6a==5 | e6a==6
* media (humanidades, media cientifico humanista, yecnica comercial industrial o normalista y media tecnica profesional )
replace years_educ=12 if e6a==7 | e6a==8 | e6a==9 | e6a==10
* tecnico (tecnico nivel superior)
replace years_educ=13 if e6a==11
* universitaria completa o incompleta o posgrado
replace years_educ=16 if e6a==12 | e6a==13
* nada
replace years_educ=0 if e6a==1

foreach age in 18 23{
	gen post_`age'years_ed_nativos=years_educ if edad>`age'
	gen esc_post`age'=esc if edad>`age'
}

replace expc=round(expc)
* Colapsando la suma de expc a nivel comuna voy a tener el denominador para calcular los % de cada variable
collapse (mean) hombre age ypc expc years_educ esc* post* [fw=expc], by(cod_com)

cd "$conf_intermed"
save controlesCASEN13, replace
*educ promedio sin ponderadores
cd "$rawdata"
import excel División-Político-Administrativa-y-Servicios-de-Salud-Histórico.xls, firstrow clear
keep CódigoComunadesde2010
rename CódigoComunadesde2010 comuna
merge 1:n comuna using casen2013
rename comuna cod_com
keep if _merge==3
drop _merge
keep if pco1==1
gen NWyears_educ=1 if e6a==2 | e6a==3
replace NWyears_educ=6 if e6a==4 | e6a==5 | e6a==6
replace NWyears_educ=12 if e6a==7 | e6a==8 | e6a==9 | e6a==10
replace NWyears_educ=13 if e6a==11
replace NWyears_educ=16 if e6a==12 | e6a==13
replace NWyears_educ=0 if e6a==1
rename esc NWesc
foreach age in 18 23{
	gen NWpost_`age'years_ed_nativos=NWyears_educ if edad>`age'
	gen NWesc_post`age'=NWesc if edad>`age'
}
collapse (mean) NWyears_educ NWesc* NWpost*, by(cod_com)
cd "$conf_intermed"
merge 1:1 cod_com using controlesCASEN13
drop _merge
save controlesCASEN13, replace

}

* 2 0 1 5 ----------------------------------------------
{
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

* Creo variable de años de educacion definida IGUAL que para la base de inmigrantes (escalonada por nivel educativo)
* Años de educacion
* prebasico (jardin de infantes, kinder)
gen years_educ=1 if e6a==2 | e6a==3 | e6a==4
* preparatoria, basico y ed especial
replace years_educ=6 if e6a==5 | e6a==6 | e6a==7
* media (humanidades, media cientifico humanista, yecnica comercial industrial o normalista y media tecnica profesional )
replace years_educ=12 if e6a==8 | e6a==9 | e6a==10 | e6a==11
* tecnico (tecnico nivel superior)
replace years_educ=13 if e6a==12 | e6a==13
* universitaria completa o incompleta o posgrado
replace years_educ=16 if e6a==14 | e6a==15 | e6a==16 | e6a==17
* nada
replace years_educ=0 if e6a==1

foreach age in 18 23{
	gen post_`age'years_ed_nativos=years_educ if edad>`age'
	gen esc_post`age'=esc if edad>`age'
}

replace expr=round(expr)
* Colapsando la suma de expc a nivel comuna voy a tener el denominador para calcular los % de cada variable
collapse (mean) hombre age ypc expc years_educ esc* post* [fw=expr], by(cod_com)

cd "$conf_intermed"
save controlesCASEN15, replace
*no weights
cd "$rawdata"
import excel División-Político-Administrativa-y-Servicios-de-Salud-Histórico.xls, firstrow clear
keep CódigoComunadesde2010
rename CódigoComunadesde2010 comuna
merge 1:n comuna using casen2015
rename comuna cod_com
keep if _merge==3
drop _merge
keep if pco1==1
gen NWyears_educ=1 if e6a==2 | e6a==3 | e6a==4
replace NWyears_educ=6 if e6a==5 | e6a==6 | e6a==7
replace NWyears_educ=12 if e6a==8 | e6a==9 | e6a==10 | e6a==11
replace NWyears_educ=13 if e6a==12 | e6a==13
replace NWyears_educ=16 if e6a==14 | e6a==15 | e6a==16 | e6a==17
replace NWyears_educ=0 if e6a==1
rename esc NWesc
foreach age in 18 23{
	gen NWpost_`age'years_ed_nativos=NWyears_educ if edad>`age'
	gen NWesc_post`age'=NWesc if edad>`age'
}
collapse (mean) NWyears_educ NWesc* NWpost*, by(cod_com)
cd "$conf_intermed"
merge 1:1 cod_com using controlesCASEN15
drop _merge
save controlesCASEN15, replace

}

* 2 0 1 7 ----------------------------------------------
{
cd "$rawdata"
// *Con estas lineas resuelvo el problema del codigo de las comunas ñuble, que cambio y arruinaba el merge (tiraba 20 comunas de mas)
// import excel División-Político-Administrativa-y-Servicios-de-Salud-Histórico.xls, firstrow clear
// keep CódigoComunadesde2010
// rename CódigoComunadesde2010 comuna
// merge 1:n comuna using casen2017
// keep if _merge==2
// keep comuna
// quietly bys comuna: gen dup=cond(_N==1,0,_n)
// drop if dup > 1
// drop dup
// * Lista de comunas que cambiaron de codigo entre 2010 y 2017 - ñuble paso a ser una region independiente
// save comunasNUBLE, replace
// use casen2017, clear
// quietly bys comuna: gen dup=cond(_N==1,0,_n)
// drop if dup > 1
// drop dup
// keep if comuna==16101 | comuna==16102 | comuna==16103 | comuna==16104 | comuna==16105 | comuna==16106 | comuna==16107 | comuna==16108 | comuna==16109 | comuna==16201 | comuna==16202 | comuna==16203 | comuna==16204 | comuna==16205 | comuna==16206 | comuna==16207 | comuna==16301 | comuna==16302 | comuna==16303 | comuna==16304 | comuna==16305
// keep comuna
// *Para guardarlas con nombre
// save comunasNUBLE, replace

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

* Creo variable de años de educacion definida IGUAL que para la base de inmigrantes (escalonada por nivel educativo)
* Años de educacion
* prebasico (jardin de infantes, kinder)
gen years_educ=1 if e6a==2 | e6a==3 | e6a==4
* preparatoria, basico y ed especial
replace years_educ=6 if e6a==5 | e6a==6 | e6a==7
* media (humanidades, media cientifico humanista, yecnica comercial industrial o normalista y media tecnica profesional )
replace years_educ=12 if e6a==8 | e6a==9 | e6a==10 | e6a==11
* tecnico (tecnico nivel superior)
replace years_educ=13 if e6a==12 | e6a==13
* universitaria completa o incompleta o posgrado
replace years_educ=16 if e6a==14 | e6a==15 | e6a==16 | e6a==17
* nada
replace years_educ=0 if e6a==1

foreach age in 18 23{
	gen post_`age'years_ed_nativos=years_educ if edad>`age'
	gen esc_post`age'=esc if edad>`age'
}

replace expc=round(expc)
* Colapsando la suma de expc a nivel comuna voy a tener el denominador para calcular los % de cada variable
collapse (mean) hombre age ypc expc years_educ esc* post* [fw=expc], by(cod_com)

cd "$conf_intermed"
save controlesCASEN17, replace
*educ promedio sin weights
cd "$rawdata"
import excel División-Político-Administrativa-y-Servicios-de-Salud-Histórico.xls, firstrow clear
keep CódigoComunadesde2010
rename CódigoComunadesde2010 comuna
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

gen NWyears_educ=1 if e6a==2 | e6a==3 | e6a==4
replace NWyears_educ=6 if e6a==5 | e6a==6 | e6a==7
replace NWyears_educ=12 if e6a==8 | e6a==9 | e6a==10 | e6a==11
replace NWyears_educ=13 if e6a==12 | e6a==13
replace NWyears_educ=16 if e6a==14 | e6a==15 | e6a==16 | e6a==17
replace NWyears_educ=0 if e6a==1
rename esc NWesc
foreach age in 18 23{
	gen NWpost_`age'years_ed_nativos=NWyears_educ if edad>`age'
	gen NWesc_post`age'=NWesc if edad>`age'
}
collapse (mean) NWyears_educ NWesc* NWpost*, by(cod_com)
cd "$conf_intermed"
merge 1:1 cod_com using controlesCASEN17
drop _merge
save controlesCASEN17, replace
}

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

sort cod_com year
rename years_educ years_ed_nativos
rename NWyears_educ NWyears_ed_nativos

save controlesCASEN06-17, replace
/*
use "C:/Users/USUARIO/Documents/Asistente/Migration Chile/ADU_Franco/Do_Franco/Versión May 2020/OLS & IV/Bases de datos - Originales y derivadas/FinalBase101_2.dta", clear
keep cod_com 
save com101ENUSC, replace 
use controlesCASEN06-17, clear
merge n:1 cod_com using com101ENUSC
keep if _merge==3
drop _merge
save controlesCASEN06-17_101, replace*/
}

cd "$conf_intermed"
use immigration_collapse, clear
* Pongo logs en las variables que necesitan:
foreach var in rate_flujo_imm_etnia rate_stock_imm_etnia rate_flujo_imm rate_stock_imm rate_flujo_imm_haiti rate_stock_imm_haiti rate_flujo_imm_haiti_colom rate_stock_imm_haiti_colom rate_flujo_imm_NOhaiti rate_stock_imm_NOhaiti rate_flujo_imm_NOhaiti_colom rate_stock_imm_NOhaiti_colom{
	replace `var'=`var'*10000
	gen ln`var'=ln(`var'+1)
}

merge 1:1 cod_com year using controlesCASEN06-17
drop if year<2008
drop if year==2018
drop _merge
save immigration_collapseCASEN, replace



** Ahora quiero una base similar pero a nivel comunas que contenga el outcome de homicidios
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


* Restrinjo a los anios para los cuales voy a tomar las diferencias
keep if year>2007&year<2018		


* Corrijo variable comuna para hacer el merge con base que contiene a las poblaciones de 2010 
replace comuna="aisen" if comuna=="Aysén"
replace comuna="calera" if comuna=="La Calera"
replace comuna="marchihue" if comuna=="Marchigüe"
replace comuna="el olivar" if comuna=="Olivar" 
replace comuna = ustrlower( ustrregexra( ustrnormalize( comuna, "nfd" ) , "/p{Mark}", "" )  )
save homicidios_cead_200817, replace 



* Abrimos base de poblacion y luego hacemos el merge con la base de outcomes de crimen
merge m:1 comuna using "$rawdata/population"
keep if _merge==3
drop _merge

** Genero variables per capita (tasa de crimen)
foreach j in homicidios1 {
	gen log_`j'=log(`j'+1)
	gen `j'pc = `j'*100000/pop
	gen log_`j'pc=ln(`j'pc+1)
}

cd "$conf_intermed"
merge 1:1 cod_com year using immigration_collapse
keep if _merge==3
drop _merge
save immigration_collapse, replace

* Usando solo las 101 comunas de ENUSC
cd "$rawdata"
use base_final_2008_2017, clear
cd "$conf_intermed"
rename id_comuna15 cod_com
drop year
sort cod_com
quietly by cod_com: gen dup=cond(_N==1,0,_n)
drop if dup > 1
keep cod_com
merge 1:m cod_com using immigration_collapse
keep if _merge==3
drop _merge

* Genero las variables de educacion que voy a usar en las regresiones
gen lnrate_stock_imm = ln( 10000*stock_imm/ population+1)
gen share_basico= (stock_est_nada + stock_est_prebasico + stock_est_basico)/(stock_est_basico + stock_est_prebasico + stock_est_nada+stock_est_medio+ stock_est_tecnico + stock_est_univers)
gen ln_rate_basico = share_basico*lnrate_stock_imm
gen ln_rate_comp_basico = (1 - share_basico)*lnrate_stock_imm

* La dummy por mediana de medios
qui summ rateall, detail
gen above_medianMED=(rateall>`r(p50)')

* La dummy por etnia
qui summ mean_distance, detail
gen high_distance=(mean_distance>`r(p50)')
gen imm_highdistance=lnrate_stock_imm*high_distance


*Agrego los controles de CASEN 2006
merge 1:1 cod_com year using controlesCASEN06_17.dta
keep if _merge==3
drop _merge

foreach var in  homicidios1  homicidios1pc log_homicidios1pc {
	bys cod_com year: egen bas_`var' =mean( `var') 
	replace  bas_`var'  = . if year !=2008
	sort cod_com year
	replace bas_`var' = bas_`var'[_n-1] if year !=2008 & cod_com[_n-1]==cod_com[_n]
}

cd "$conf_final"
save channels_OLS_homicides, replace