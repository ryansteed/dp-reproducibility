* Do-file para generar la base que se utiliza para la Tabla XVII (Column 4)


* Variables independientes (inmigracion y demas)
{
cd "$rawdata"

* Empiezo con la base de extranjería para generar una colapsada a nivel de comuna y año
use immigration_Correciones, clear
* Tiro 2 observaciones que tienen mal el codigo
drop if comuna=="florida" & cod_com==8404
* Tiro 379 observaciones con cod_com==96
drop if cod_com==96

cd "$conf_intermed"
save immigration_collapse2, replace

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

cd "$conf_intermed"
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

cd "$conf_intermed"
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


** Junto con base de homicidios
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
merge 1:1 cod_com year using immigration_collapse2
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
save channels_OLS3_homicides, replace

}

