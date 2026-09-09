* Do-file para generar la base que se utiliza para las Tablas I y A.1

cd "$rawdata"
* Cargo la base de extranjeria para quedarme con la cantidad de inmigrantes por comuna de los "paises de origen"
use immigration_Correciones, clear

* Tiro las observaciones con problemas que habia identificado antes (comuna mal asignada o missing)
drop if comuna=="florida" & cod_com==8404
drop if cod_com==96

* Con lo siguiente me queda una base de flujos de inmigrantes para el periodo 2005-2017
drop if year>2017
collapse (sum) imm*, by(cod_com year)
cd "$intermed"
save flujos_inmigracion_200817, replace


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
gen year=2002
keep cod_com comuna year imm

collapse (sum) imm, by(cod_com year)

cd "$intermed"
append using flujos_inmigracion_200817
save flujos_inmigracion_200817, replace

* Usando solo las 101 comunas de ENUSC
cd "$rawdata"
use base_final_2008_2017, clear
cd "$intermed"
rename id_comuna15 cod_com
drop year
sort cod_com
quietly by cod_com: gen dup=cond(_N==1,0,_n)
drop if dup > 1
drop dup
drop kish
keep cod_com
merge 1:m cod_com using flujos_inmigracion_200817
keep if _merge==3
drop _merge


* Como hay comunas en ciertos años que no reciben migrantes de determinada nacionalidad, la base no queda completa. 
xtset cod_com year
tsfill, full
replace imm=0 if imm==.
drop if year==2003|year==2004	// para estos anios no tenemos datos de flujos de inmigracion en ninguna comuna

save flujos_inmigracion_200817, replace

* Ahora saco stocks por año
sort cod_com year
bys cod_com: gen stock_imm=sum(imm)
drop if year<2008

* Agregamos la poblacion de 2010
merge m:1 cod_com using "$rawdata/population"
keep if _merge==3
drop _merge

* Immigrant Flow in per 100,000 inhabitants
gen imm_flow_rate = 100000*imm/population

egen id_com = group(cod_com)
sort id_com year
qui sum cod_com

forvalues t = 2008/2017{
gen imm_flow_rate`t' = .

	forvalues i = 1/101{
	qui sum imm_flow_rate if year==`t'&id_com==`i'
	replace imm_flow_rate`t'=`r(mean)' if id_com==`i'
	}

}

* Stock de migrantes cada 100 mil habitantes en 2008 
gen stock_imm08_rate=.
forvalues i = 1/101{
	qui sum stock_imm if year==2008&id_com==`i'
	replace stock_imm08_rate=100000*`r(mean)'/population if id_com==`i'
}
	
* Growth en stock de migrantes cada 100 mil habitantes 2017-2008 y growth en cantidad de migrantes 2017-2008
keep if year==2008|year==2017

bys cod_com: gen growth_imm_rate = 100*(100000/population)*(stock_imm-stock_imm[_n-1])/(stock_imm[_n-1])	// en porcentaje
bys cod_com: gen growth_imm_persons = stock_imm-stock_imm[_n-1]

* Growth en stock de migrantes 2017-2008 para luego armar cuartiles
bys cod_com: gen growth_imm = 100*(stock_imm-stock_imm[_n-1])/(stock_imm[_n-1])	// en porcentaje
keep if year==2017
xtile growth_imm_quartile=growth_imm,n(4)
sort growth_imm
cd "$final"
save TableI, replace

* Agrego proyeccion de la poblacion 2019 por parte del INE 
import excel "$rawdata/estimaciones-y-proyecciones-2002-2035-comunas.xlsx", sheet("Est. y Proy. de Pob. Comunal") firstrow clear
rename Comuna cod_com
replace cod_com=8401 if cod_com==16101	// comuna de chillan
replace cod_com=8416 if cod_com==16301	// comuna de san carlos
rename Poblacion2019 population2019
collapse (sum) population2019, by(cod_com)
merge 1:1 cod_com using TableI
keep if _merge==3
drop _merge
save TableI, replace
