* Do-file para generar la base que se utiliza para la Tabla XV (Panel B, Columns 1-3)



*** Ahora voy a la base de distancia genetica 
{
cd "$rawdata"
use bilateral_replic, clear
des weurope_1 eeurope_1 weurope_2 eeurope_2

** Grupo de 37 paises europeos. Le computo a cada pais la distancia genetica no a Chile sino al promedio de paises de Europa 
keep if weurope_1==1&weurope_2==1|weurope_1==1&eeurope_2==1|eeurope_1==1&weurope_2==1|eeurope_1==1&eeurope_2==1
 
* En la base hay 37 paises europeos. Con lo siguiente chequeo que estoy condicionando correctamente en el paso anterior para tener en la muestra restringida todas las combinaciones posibles entre paises europeos 
local i = 0
forvalues j = 1/36{
local i = `j' + `i'
}
disp `i'

* Reemplazo nombres extensos 
replace country_1="Czech" if country_1=="Czech Republic" 
replace country_2="Czech" if country_2=="Czech Republic" 
replace country_1="Russia" if country_1=="Russian Federation" 
replace country_2="Russia" if country_2=="Russian Federation" 
replace country_1="Marino" if country_1=="San Marino" 
replace country_2="Marino" if country_2=="San Marino" 
replace country_1="UK" if country_1=="United Kingdom"
replace country_2="UK" if country_2=="United Kingdom"

* Genero base para paises europeos arrancando con Austria (esto es asi porque solo aparece en country_1, mientras que para los restantes paises hay que tener mayor cuidado en el procedimiento porque tambien aparecen en country_2)
cd "$intermed"

preserve 
keep if country_1=="Austria" | country_2=="Austria"
replace country_1=country_2 if country_2=="Austria"
collapse (mean) new_gendist_weighted, by(country_1)
save distancias_europa_por_pais_europeo, replace
restore

* Completo la base de paises europeos con los restantes 36 paises
levelsof country_2, local(countries)  
foreach c of local countries{
disp "`c'"
preserve 
keep if country_1=="`c'" | country_2=="`c'"
replace country_1=country_2 if country_2=="`c'"
collapse (mean) new_gendist_weighted, by(country_1)
append using distancias_europa_por_pais_europeo
save distancias_europa_por_pais_europeo, replace
restore

}


** Grupo de 137 paises no europeos. Le computo a cada pais la distancia genetica no a Chile sino al promedio de paises de Europa
cd "$rawdata"
use bilateral_replic, clear

keep if weurope_1==0&eeurope_1==0&weurope_2==1|weurope_1==0&eeurope_1==0&eeurope_2==1|weurope_1==1&weurope_2==0&eeurope_2==0|eeurope_1==1&weurope_2==0&eeurope_2==0
keep country_1 country_2 new_gendist_weighted weurope_1 eeurope_1 weurope_2 eeurope_2
replace country_1=country_2 if weurope_1==1|eeurope_1==1
sort country_1

collapse (mean) new_gendist_weighted, by(country_1)
cd "$intermed"
save distancias_europa_por_pais_no_europeo, replace


** Junto bases de paises europeos y no europeos
append using distancias_europa_por_pais_europeo

replace country_1=lower(country_1)
rename country_1 cat_pais

* Normalizo la variable
summ new_gendist_weighted
gen distancia=(new_gendist_weighted - `r(min)')/(`r(max)' - `r(min)')

* Cambio uno por uno los nombres que hacen falta (estan in ingles y los necesito en español). El proceso: ir haciendo merges con la base de inmigracion y concentrarme en las observaciones que no matcheaban. Todos los paises que estan en ambas bases estan con los nombres correctos para que matcheen, despues hay como 50 y pico paises aca que no estan en la base de migrantes (y entre 10 y 13 paises de migrantes que no estan en esta base)
replace cat_pais="francia" if cat_pais=="france"
replace cat_pais="federacion de rusia" if cat_pais=="russia"
replace cat_pais="grecia" if cat_pais=="greece"
replace cat_pais="brasil" if cat_pais=="brazil"
replace cat_pais="islandia" if cat_pais=="iceland"
replace cat_pais="hungria" if cat_pais=="hungary"
replace cat_pais="belgica" if cat_pais=="belgium"
replace cat_pais="dinamarca" if cat_pais=="denmark"
replace cat_pais="uk" if cat_pais=="uk"
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
replace cat_pais="republica checa" if cat_pais=="czech"
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
save distancias_por_pais_2, replace


*** Ahora, voy por la base de inmigrantes
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

cd "$intermed"
save immigration_etnia_2, replace

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

cd "$intermed"

save censo_etnias_2, replace

* Para chequear cuantos inmigrantes de 2002 quedan sin pais identificado (despues, el set de inmigrantes que queda sin valor en distancia de 2002 es mas grande, porque hay varios paises que no estan en la base de etnias). Quedan con valor = 1 en la variable "otros"
cd "$intermed"
use censo_etnias_2, clear
sort cat_pais
quietly by cat_pais: gen dup=cond(_N==1,0,_n)
drop if dup > 1
drop dup cod_com
merge 1:m cat_pais using immigration_etnia_2
keep if _merge==1
rename _merge otros
keep otros cat_pais
merge 1:m cat_pais using censo_etnias_2
drop _merge


append using immigration_etnia_2
sort cod_com year
save immigration_etnia_2, replace


merge m:1 cat_pais using distancias_por_pais_2
drop if _merge==2
drop _merge
* Los inmigrantes de paises que no estaban en la base de distancias son imputados la distancia promedio
summ distancia
mvencode distancia if distancia==., mv(`r(mean)')

keep cat_pais year cod_com distancia comuna imm mujer_joven hombre_joven mujer_nojoven hombre_nojoven new_gendist_weighted
save immigration_etnia_2, replace
}


*** Variables independientes (inmigracion y demas)
{
cd "$rawdata"

* Empiezo con la base de extranjería para generar una colapsada a nivel de comuna y año
use immigration_Correciones, clear
* Tiro 2 observaciones que tienen mal el codigo
drop if comuna=="florida" & cod_com==8404
* Tiro 379 observaciones con cod_com==96
drop if cod_com==96

sort cod_com year
collapse (sum) imm*, by(cod_com year)

cd "$intermed"
save immigration_collapse_2, replace

** Continuo con el censo 2002 para generar el stock inicial de migrantes
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
* Con este comando y los Cuadros 2.1 y 2.2 (p111) del documento "Censo 2002 Chile con Cuestionario" encuentro los codigos para los paises que quiero (comparo numeros, dan iguales)
keep if _merge==1
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
tostring P22B, gen(strP22B)
rename strP22B cat_pais
replace cat_pais="hai" if cat_pais=="20027"
replace cat_pais="col" if cat_pais=="20014"

gen year=2002

sort cod_com year
collapse (sum) imm*, by(cod_com year)

cd "$intermed"
save collapse2002_2, replace

append using immigration_collapse_2

* Ahora saco stocks por año
sort cod_com year
bys cod_com: gen stock_imm=sum(imm)

keep if year > 2007
drop if year==2018
save immigration_collapse_2, replace

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

* A las comunas que existen pero no estaban en la base de inmigracion (asumo que porque no habian recibido inmigrantes en los años correspondientes) les imputo 0 en todas las variables del tipo # de inmigrantes. 
merge 1:1 cod_com year using immigration_collapse_2
mvencode imm* stock_* if _merge==1, mv(0)
drop _merge

* Cambio los nombres de las variables para que quede claro cuales son flujos y cuales stocks:
rename imm flujo_imm

* Genero rates de inmigracion y de stock de inmigrantes 
gen rate_flujo_imm=flujo_imm/population
gen rate_stock_imm=stock_imm/population


save immigration_collapse_2, replace

}

*** Agrego las variables de inmigracion ponderadas por etnia
{

cd "$intermed"
use immigration_etnia_2, clear

* La variable distancia esta normalizada ((x-min)/(max-min)), la uso para ponderar las sumas de inmigrantes por comuna.
* Colapso a nivel comuna año
rename distancia flujo_imm_etnia
collapse (sum) imm flujo_imm_etnia, by(cod_com year)
* Genero stocks
sort cod_com year
* Para los inmigrantes por origen
bys cod_com: gen stock_imm=sum(imm)
bys cod_com: gen stock_imm_etnia=sum(flujo_imm_etnia)
keep if year>2007

merge 1:1 cod_com year using immigration_collapse_2
drop _merge

* Genero rates de inmigracion y de stock de inmigrantes 
foreach j in "flujo_" "stock_"{
	gen rate_`j'imm_etnia=`j'imm_etnia/population
}

save immigration_collapse_2, replace

}


*** Agrego la variable de distancia etnica por comuna
{
cd "$rawdata"
* Armo el ranking para ver los top 30 paises de origen entre inmigrantes de chile que hayan entrado entre 2008 y 2017
use immigration_Correciones, clear
keep if year>2007 & year<2018
collapse (sum) imm, by(cat_pais)
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
cd "$intermed"
* Ahora voy a la base de distancia genetica y me quedo con la distancia entre el promedio de Europa y esos 30 paises
use distancias_por_pais_2, clear

keep if cat_pais=="peru" | cat_pais=="colombia" | cat_pais=="bolivia" | cat_pais=="venezuela" | cat_pais=="haiti" | cat_pais=="argentina" | cat_pais=="ecuador" | cat_pais=="espana" | cat_pais=="estados unidos" | cat_pais=="china" | cat_pais=="republica dominicana" | cat_pais=="brasil" | cat_pais=="mexico" | cat_pais=="paraguay" | cat_pais=="cuba" | cat_pais=="uruguay" | cat_pais=="francia" | cat_pais=="alemania" | cat_pais=="italia" | cat_pais=="republica popular democratica de corea" | cat_pais=="uk" | cat_pais=="india" | cat_pais=="federacion de rusia" | cat_pais=="portugal" | cat_pais=="australia" | cat_pais=="el salvador" | cat_pais=="panama" | cat_pais=="japon" | cat_pais=="honduras" | cat_pais=="costa rica"

replace cat_pais="korea" if cat_pais=="republica popular democratica de corea"
replace cat_pais=substr(cat_pais,1,3)
replace cat_pais="eeuu" if cat_pais=="est"
replace cat_pais="repdom" if cat_pais=="rep"
replace cat_pais="cor" if cat_pais=="kor"
replace cat_pais="salv" if cat_pais=="el "
replace cat_pais="c_rica" if cat_pais=="cos"
replace cat_pais="rus" if cat_pais=="fed"

drop distancia
rename new_gendist_weighted distancia_
gen year=2008
reshape wide distancia, i(year) j(cat_pais) string

* Para despues matchear sin problemas usando el año
foreach year in 2009 2010 2011 2012 2013 2014 2015 2016 2017{
	expand 2 if year==2008, generate(newv)
	replace year=`year' if newv==1
	drop newv
}

cd "$intermed"
save distancias_etnic_2, replace

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
cd "$intermed"
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
cd "$intermed"
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
merge m:1 year using distancias_etnic_2
drop _merge
sort cod_com year
* Genero el indice por pais-comuna-año y despues los sumo por comuna-año
foreach country in "per" "col" "bol" "ven" "hai" "arg" "ecu" "esp" "eeuu" "repdom" "chi" "bra" "mex" "par" "cub" "uru" "fra" "ale" "ita" "cor" "uk" "ind" "rus" "por" "aus" "salv" "pan" "jap" "hon" "c_rica"{
	gen index_`country'=(stock_`country' * distancia_`country')/stock_imm
	replace index_`country'=0 if index_`country'==.
}

egen mean_distance=rowtotal(index_*)
drop index_* stock_* distancia_*

save distance_index_2, replace

merge 1:1 cod_com year using immigration_collapse_2
drop _merge
save immigration_collapse_2, replace

}


*** Agrego controles CASEN para el panel
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
cd "$intermed"
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
cd "$intermed"
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

cd "$intermed"
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
cd "$intermed"
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

cd "$intermed"
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
cd "$intermed"
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

cd "$intermed"
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
cd "$intermed"
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

cd "$intermed"
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
cd "$intermed"
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

cd "$intermed"
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
cd "$intermed"
merge 1:1 cod_com using controlesCASEN17
drop _merge
save controlesCASEN17, replace
}

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

cd "$intermed"
use immigration_collapse_2, clear
* Pongo logs en las variables que necesitan:
foreach var in rate_flujo_imm_etnia rate_stock_imm_etnia rate_flujo_imm rate_stock_imm{
	replace `var'=`var'*10000
	gen ln`var'=ln(`var'+1)
}

merge 1:1 cod_com year using controlesCASEN06-17
drop if year<2008
drop if year==2018
drop _merge
save immigration_collapse_2CASEN, replace

* Variables dependientes (outcomes de enusc). Esta a nivel individual, igual que el panel OLS de los main results

{
cd "$rawdata"
use base_final_2008_2017, clear
drop if year==2018
rename id_comuna15 cod_com
cd "$intermed"

merge m:1 cod_com year using immigration_collapse_2CASEN
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




foreach var in  crime_rising pc_1 pc_2 pc_3 pc_4 pc_5 pc_6 pc_7 pc_8 pc_9 pc_10 pc_11 pc_12 pc_13 pc_14 pc_15 pc_16 pc_17 pc_18 pc_19 pc_20 del_problema1 del_problema2 del_problema3 del_afecta1 del_afecta2 del_afecta3 del_tend_pais del_tend_com del_tend_barrio del_calvida1 del_calvida2 del_calvida3 del_inseg1 del_inseg2 del_inseg3 del_inseg4 del_inseg5 del_vict del_arma vict_agreg vict_property vict_violent vict_roboviolent vict_robosorpr vict_roboviv vict_hurto vict_lesiones vict_robovehi vict_robo_desdevehi vict_delecon vict_car Index_Vivienda Index_Vecinos{
	bys cod_com year: egen bas_`var' =mean( `var') 
	replace  bas_`var'  = . if year !=2008
	sort cod_com year
	replace bas_`var' = bas_`var'[_n-1] if year !=2008 & cod_com[_n-1]==cod_com[_n]
}

keep if year > 2007

save channels_OLS2, replace

}


* Genero la dummy por etnia que voy a usar en las regresiones
qui summ mean_distance, detail
gen high_distance=(mean_distance>`r(p50)')
gen imm_highdistance=lnrate_stock_imm*high_distance

cd "$final"
save channels_OLS2, replace



