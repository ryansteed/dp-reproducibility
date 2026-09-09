********************************************************************************
*** Build: Glyphosate and potential dataset
********************************************************************************

** Agricutural data from IBGE - PAM (Pesquisa Agricola Municipal)

* We start with the municipality information on total, temporary, corn, and soy planted areas. Data from PAM has all the municipalities that existed in 2010.

clear
import excel using "$pathfiles_data/Originais/corn_area_1996_2010.xlsx", allstring cellrange(B6:R5570)

drop if B==""

rename B codmun7
rename C name_mun

gen code_mun=substr(codmun7,1,6) 
destring code_mun, replace

local i=1996

foreach x in D E F G H I J K L M N O P Q R{

destring `x', force replace
replace `x'=0 if `x'==.
rename `x' area_corn`i'
local i=`i'+1

}

reshape long area_corn, i(code_mun name_mun) j(year)

tempfile areacorn
save `areacorn'


clear
import excel using "$pathfiles_data/Originais/area_temp_1996_2010.xlsx", allstring cellrange(B6:R5570)

drop if B==""

rename B codmun7
rename C name_mun

gen code_mun=substr(codmun7,1,6) 
destring code_mun, replace

local i=1996

foreach x in D E F G H I J K L M N O P Q R{

destring `x', force replace
replace `x'=0 if `x'==.
rename `x' area_temp`i'
local i=`i'+1

}

reshape long area_temp, i(code_mun name_mun) j(year)

tempfile areatemp
save `areatemp'

clear
import excel using "$pathfiles_data/Originais/soy_area_1996_2010.xlsx", allstring cellrange(B6:R5570)

drop if B==""

rename B codmun7
rename C name_mun

gen code_mun=substr(codmun7,1,6) 
destring code_mun, replace

local i=1996 // Obs: 1996 is actually 1995/1996 harvest

foreach x in D E F G H I J K L M N O P Q R{

destring `x', force replace
replace `x'=0 if `x'==.
rename `x' area_soy`i'
local i=`i'+1

}

reshape long area_soy, i(code_mun name_mun) j(year)

merge 1:1 code_mun year using `areacorn'
drop _merge
merge 1:1 code_mun year using `areatemp'
drop _merge

** Merge AMC codes
merge m:1 code_mun using "$pathfiles_data/Originais/amcs_br.dta"
quietly drop _merge


* Create State code from code_mun
gen code_uf=substr(string(code_mun),1,2)
destring code_uf, replace

// The data below is the same as area_mun_Ibge_2010.dta with municipality codes 
// adjusted to facilitate the merging (municipality codes have an extra digit 
// that is not necessary to uniquely identify municipalities and we're working
// with 6 digits).
merge m:1 code_mun using "$pathfiles_data/Originais/area_mun_Ibge_2010_adjusted.dta", keepusing(area_ibge_km2)
drop _merge

********************************************************************************
* Herbicide 


** Merge herbicide data
merge m:1 year using "$pathfiles_data/Originais/herb_tons_ai_culture.dta"
drop _merge

merge m:1 code_uf using "$pathfiles_data/Originais/glyphosate_herb_per_state_2009.dta", keepusing(pc_glyph_09 pc_herb_09)
drop _merge
merge m:1 code_uf year using "$pathfiles_data/Originais/herb_tons_ai_uf.dta", keepusing(herb_tons_ai_uf herb_tons_aiTotal)
drop _merge

label variable herb_tons_aiTotal "Total herbicide use in Brazil in each year (2000-2010), in tons of active ingredient"
label variable herb_tons_ai_uf "Herbicides used in municipality's state in each year (2000-2010), in tons of active ingredient"
label variable pc_glyph_09 "Proportion of glyphosate used in municipality's state in 2009"
label variable pc_herb_09 "Proportion of herbicides used in all cultures in municipality's state in 2009"

* Add glyphosate, national use, from IBAMA (imputing 2006-2008); data available at https://dadosabertos.ibama.gov.br/
* Linear interpolation
gen gly_national=.
replace gly_national=39515 if year==2000
replace gly_national=44467 if year==2001
replace gly_national=43691 if year==2002
replace gly_national=57614 if year==2003
replace gly_national=77068 if year==2004
replace gly_national=70954 if year==2005
replace gly_national=82836 if year==2006
replace gly_national=94719 if year==2007
replace gly_national=106602 if year==2008
replace gly_national=118485 if year==2009
replace gly_national=127586 if year==2010


* Using avg glyph/herb
gen gly_national2=.
replace gly_national2=39515 if year==2000
replace gly_national2=44467 if year==2001
replace gly_national2=43691 if year==2002
replace gly_national2=57614 if year==2003
replace gly_national2=77068 if year==2004
replace gly_national2=70954 if year==2005
replace gly_national2=81909 if year==2006
replace gly_national2=108791 if year==2007
replace gly_national2=107056 if year==2008
replace gly_national2=118485 if year==2009
replace gly_national2=127586 if year==2010

** Colapse by AMC-year
sort AMC
collapse (sum) area_soy area_corn area_temp area_amc_km2=area_ibge_km2 (firstnm) code_uf herb_* pc_glyph_09 pc_herb_09 gly_national gly_national2, by(AMC year)


********************************************************************************
* Handling Herbicide at AMC level + Merge with Basins + Merge with Soy Potential

** Percentage of AMC's soy planted area - state
gen pc_soy_uf=.
sort code_uf year
by code_uf year: egen aux=sum(area_soy)
replace pc_soy_uf=area_soy/aux
replace pc_soy_uf = 0 if aux==0 // We want pc_soy_uf to be 0, not missing
drop aux

** AMC's percentage of soy planted area within Brazil
gen pc_soy_br=.
sort year
by year: egen aux=sum(area_soy)
replace pc_soy_br = area_soy/aux
replace pc_soy_br = 0 if aux==0 // We want pc_soy_br to be 0, not missing
drop aux


*AMC's percentage of temporary crops planted area within Brazil
gen pc_temp_br=.
sort year
by year: egen aux=sum(area_temp)
replace pc_temp_br = area_temp/aux
replace pc_temp_br = 0 if aux==0 // We want pc_temp_br to be 0, not missing
drop aux


** Merge with ottobasin lvl 4 information - each observation in the resulting database is a pair AMC-ottobasin
** Ottobasins information is obtained from ANA and combined with AMC data using a GIS software
** Coordinate Reference System used was EPSG:29195 - SAD69 / UTM 25S. More information at https://epsg.io/29195-1877.
merge 1:m AMC year using "$pathfiles_data/Originais/amcs_subbasins.dta"
drop if _merge==1 // Islands of Ilhabela and Fernando de Noronha are discarded
drop _merge

** Destring area variables - areas in ha
destring a_amc_subbasin_ha, force replace
drop a_amc_ha
gen a_amc_ha = 100*area_amc_km2

** Soy and maize area in AMC-subbasin
rename area_soy area_soy_AMC
rename area_corn area_mze_AMC
rename area_temp area_temp_AMC

gen area_soy_AMC_subbasin = area_soy_AMC*(a_amc_subbasin_ha/a_amc_ha)
gen area_mze_AMC_subbasin = area_mze_AMC*(a_amc_subbasin_ha/a_amc_ha)
gen area_temp_AMC_subbasin = area_temp_AMC*(a_amc_subbasin_ha/a_amc_ha)


********************************************************************************
* Create instrument

/* For each AMC: our instrument the weighted average of soy potential of the other AMCs 
within the same subbasin (ottobasin lvl 4), weighted by their respective area. We use low potential before 2004, high onwards. 
If a AMC is located in more than one subbasin, we take the weighted average, 
with weights being the proportion of the AMC's area in each subbasin.*/

** Merge information of soy yield potential from FAO-GAEZ as in Bustos, Caprettini, and Ponticelli (2016)
merge m:1 AMC year using "$pathfiles_data/Originais/potential_soy_amc.dta"
drop if _merge==2 // Islands of Fernando de Noronha and Ilhabela
drop _merge

** Merge information of maize yield potential from FAO-GAEZ as in Bustos, Caprettini, and Ponticelli (2016)
merge m:1 AMC using "$pathfiles_data/Originais/potential_maize_amc.dta"
drop if _merge==2 // Islands of Fernando de Noronha and Ilhabela
drop _merge

** Our instrument is, for each municipality, the weighted average of other AMCs in the same subbasin, but UPSTREAM, weighted by area (low potential before 2004, high onwards);
** if a AMC is in more than one subbasin, we take the weighted average, with the weight being the proportion of AMC's area in each basin.

** We know if an area is upstream by the subbasin code: subbasin codes have 4 numbers; the first 3 numbers are the basin (ottobasin lvl 3) code and the last
** one indicates the position: the higher the last number, more upstream is the area

* First, let's take the info about basin and position
gen aux_basin=string(subbasin)
gen basin=substr(aux_basin,1,3)
gen position=substr(aux_basin,4,1)
drop aux_basin
replace position="0" if position=="" // Some ottobasins lvl 3 cannot be subdivided
destring basin position, replace

* Then, we take the product between the potential for each AMC (for both low and high) and the AMC-basin pair area
gen potential_l=a_amc_subbasin_ha*A_soy_l
gen potential_h=a_amc_subbasin_ha*A_soy_h

gen potential_mze_l=a_amc_subbasin_ha*A_mze_l
gen potential_mze_h=a_amc_subbasin_ha*A_mze_h

* We will finish the instrument construction along with the construction of herbicide exposure variable, in the loop



********************************************************************************
* Create herbicide exposure variable at the AMC level
/*
We will create three different variables by distributing the quantity of herbicides used in soy in Brazil. 
First, we distribute this quantity by state (we will do that in three different ways -- see below) and, after that, we distribute 
by municipality using the AMC's share of planted area with soy out of the total area of soy in the state.

We will distribute the herbicides used in soy in Brazil by state in the following ways:

1) Using the proportion of glyphosate used by each state in 2009
2) Using the proportion of herbicides used by each state in 2009
3) Using, for each year, the proportion of herbicides used by each state

*/

* First, we estimate herbicide use in each AMC-subbasin
gen glyph_soy_AMC_subbasin = pc_soy_uf*herb_tons_aiSoy*(pc_glyph_09)*(a_amc_subbasin_ha/a_amc_ha)
gen glyph_soy_AMC_subbasin2 = pc_soy_uf*herb_tons_aiSoy*(pc_herb_09)*(a_amc_subbasin_ha/a_amc_ha)
gen glyph_soy_AMC_subbasin3 = pc_soy_uf*herb_tons_aiSoy*(herb_tons_ai_uf/herb_tons_aiTotal)*(a_amc_subbasin_ha/a_amc_ha)

* Old measure
gen glyph_soy_AMC_subbasin4 = pc_soy_br * gly_national * (a_amc_subbasin_ha/a_amc_ha)
replace glyph_soy_AMC_subbasin4=0 if year<=2003

gen glyph_soy_AMC_subbasin5 = pc_soy_br * gly_national * (a_amc_subbasin_ha/a_amc_ha)
*gen glyph_soy_AMC_subbasin5 = pc_soy_uf * gly_national * (pc_glyph_09) * (a_amc_subbasin_ha/a_amc_ha)

* marginal glyph after 2003
gen aux = gly_national if year==2003
egen gly2003=mean(aux) //Here the AMCs and subbasins won't matter, since the value is constant in the crossection
gen d_glynational_wrt2003=gly_national-gly2003
drop aux gly2003

gen aux = gly_national2 if year==2003
egen gly2003_2=mean(aux) //Here the AMCs and subbasins won't matter, since the value is constant in the crossection
gen d_glynational2_wrt2003=gly_national2-gly2003_2
drop aux gly2003_2

gen glyph_soy_AMC_subbasin7 = .
replace glyph_soy_AMC_subbasin7 = pc_temp_br * gly_national * (a_amc_subbasin_ha/a_amc_ha) if year<=2003
gen aux=glyph_soy_AMC_subbasin7 if year==2003
bysort AMC basin position: egen glyph2003=mean(aux)
replace glyph_soy_AMC_subbasin7 = glyph2003 + pc_soy_br * d_glynational_wrt2003 * (a_amc_subbasin_ha/a_amc_ha) if year>=2004
drop aux glyph2003


* Alternate glyph measure like the last two, but =0 before 2003
gen glyph_soy_AMC_subbasin8 = 0
replace glyph_soy_AMC_subbasin8 = pc_soy_br * d_glynational_wrt2003 * (a_amc_subbasin_ha/a_amc_ha) if year>=2004

***
gen gesoy=.
replace gesoy = 0 if year==2000
replace gesoy = 0 if year==2001
replace gesoy = 0 if year==2002
replace gesoy = 0 if year==2003
replace gesoy = 19.1/56.3 if year==2004
replace gesoy = 26.6/54.3 if year==2005
replace gesoy = 27.9/49.9 if year==2006
replace gesoy = 35.8/54.4 if year==2007
replace gesoy = 35.1/54.1 if year==2008
replace gesoy = 40.0/56.6 if year==2009
replace gesoy = 44.0/62.7 if year==2010
***
gen glyph_soy_AMC_subbasin9 = pc_soy_br * gesoy * gly_national * (a_amc_subbasin_ha/a_amc_ha)

* Glyph measure using different estimated values
gen glyph_soy_AMC_subbasin10 = .
replace glyph_soy_AMC_subbasin10 = pc_temp_br * gly_national2 * (a_amc_subbasin_ha/a_amc_ha) if year<=2003
gen aux=glyph_soy_AMC_subbasin10 if year==2003
bysort AMC basin position: egen glyph2003=mean(aux)
replace glyph_soy_AMC_subbasin10 = glyph2003 + pc_soy_br * d_glynational2_wrt2003 * (a_amc_subbasin_ha/a_amc_ha) if year>=2004
drop aux glyph2003



* We will also calculate and keep the glyphosate variable per AMC (NOT AMC-subbasin)
gen glyph_soy_AMC_km2 = pc_soy_uf * herb_tons_aiSoy * (pc_glyph_09) / (a_amc_ha/100)
gen glyph_soy_AMC2_km2 = pc_soy_uf * herb_tons_aiSoy * (pc_herb_09) / (a_amc_ha/100)
gen glyph_soy_AMC3_km2 = pc_soy_uf * herb_tons_aiSoy * (herb_tons_ai_uf/herb_tons_aiTotal) / (a_amc_ha/100)

* Main measure
gen glyph_soy_AMC4_km2 = pc_soy_br * gly_national / (a_amc_ha/100)
replace glyph_soy_AMC4_km2 = 0 if year<=2003

gen glyph_soy_AMC5_km2 = pc_soy_uf * gly_national * pc_glyph_09 / (a_amc_ha/100)

gen glyph_soy_AMC7_km2 = pc_temp_br * gly_national / (a_amc_ha/100) if year<=2003
gen aux = glyph_soy_AMC7_km2 if year==2003
bysort AMC: egen glyph2003=mean(aux)
replace glyph_soy_AMC7_km2 = glyph2003 + pc_soy_br * d_glynational_wrt2003 / (a_amc_ha/100) if year>=2004
drop aux glyph2003



gen glyph_soy_AMC8_km2 = 0
replace glyph_soy_AMC8_km2 = pc_soy_br * d_glynational_wrt2003 / (a_amc_ha/100) if year>=2004


gen glyph_soy_AMC9_km2 = pc_soy_br * gesoy * gly_national / (a_amc_ha/100)


gen glyph_soy_AMC10_km2 = pc_soy_br * gly_national2 / (a_amc_ha/100)

* Now, we create the variable of herbicide exposure for each AMC in the same fashion as the potential variable:
* we sum the previous variable for every other AMC-subbasin in the same subbasin, and we will take the exposure as this
* variable per unit of area.

* Calculate sum of other AMC-subbasins estimated herbicide use and weight for proportion of AMC area in subbasin (to deal with the cases in which 
* a AMC is in more than one subbasin - we will take the weighted average when we collapse)
gen glyph_soy_subbasin_km2=.
gen glyph_soy_subbasin2_km2=.
gen glyph_soy_subbasin3_km2=.
gen glyph_soy_subbasin4_km2=.
gen glyph_soy_subbasin5_km2=.
gen glyph_soy_subbasin7_km2=.
gen glyph_soy_subbasin8_km2=.
gen glyph_soy_subbasin9_km2=.
gen glyph_soy_subbasin10_km2=.

gen glyph_soy_subbasin4=.

gen potential_subotto_h=.
gen potential_subotto_l=.
gen potential_mze_subotto_h=.
gen potential_mze_subotto_l=.

gen potential_subotto_h_unnorm=.
gen potential_subotto_l_unnorm=.

gen area_upstream_ha = .
gen area_downstream_ha = .


* Same variables as above, but considering glyphosate use downstream
gen glyph_soy_downstream_km2=.
gen glyph_soy_downstream2_km2=.
gen glyph_soy_downstream3_km2=.
gen glyph_soy_downstream4_km2=.
gen glyph_soy_downstream5_km2=.
gen glyph_soy_downstream7_km2=.
gen glyph_soy_downstream8_km2=.
gen glyph_soy_downstream9_km2=.
gen glyph_soy_downstream10_km2=.

gen potential_downstream_h=.
gen potential_downstream_l=.

gen potential_mze_downstream_h=.
gen potential_mze_downstream_l=.

* Soy and maize areas
gen area_soy_upstream=.
gen area_soy_downstream=.
gen area_mze_upstream=.
gen area_mze_downstream=.

******************
bysort AMC: egen max_pos=max(position)
******************

* Calculate variables upstream and downstream, remembering to exclude contribution of the parts of the same AMC upstream and downstream
foreach var of varlist area_soy_AMC_subbasin area_mze_AMC_subbasin potential_h potential_l potential_mze_h potential_mze_l glyph_soy_AMC_subbasin glyph_soy_AMC_subbasin2 glyph_soy_AMC_subbasin3 glyph_soy_AMC_subbasin4 glyph_soy_AMC_subbasin5 glyph_soy_AMC_subbasin7 glyph_soy_AMC_subbasin8 glyph_soy_AMC_subbasin9 glyph_soy_AMC_subbasin10 a_amc_subbasin_ha{

	forvalues sub=1/9{
		
		* Sum upstream
		egen `var'_up`sub' = total(cond(position>`sub',`var',0,0)), by(basin year)
		egen `var'_sameup`sub' = total(cond(position>`sub',`var',0,0)), by(AMC basin year)
		
		* Sum downstream
		egen `var'_down`sub' = total(cond(position<`sub',`var',0,0)), by(basin year)
		egen `var'_samed`sub' = total(cond(position<`sub',`var',0,0)), by(AMC basin year)
	}

}


* Find areas with no other AMCs upstream
forv sub=1/9{
	egen nonmissingtot_up`sub' = total(cond(position>`sub',1,0,0)), by(basin year)
	egen nonmissingsame_up`sub' = total(cond(position>`sub',1,0,0)), by(AMC basin year)
	gen nonmissing_up`sub' = nonmissingtot_up`sub' - nonmissingsame_up`sub'
}
gen nonmissing_up=.

* Calculate variables per area
forvalues sub=1/9{
	
		replace glyph_soy_subbasin_km2 = 100 * (a_amc_subbasin_ha/a_amc_ha) * (glyph_soy_AMC_subbasin_up`sub'-glyph_soy_AMC_subbasin_sameup`sub')/(a_amc_subbasin_ha_up`sub'-a_amc_subbasin_ha_sameup`sub') if(position==`sub')
		replace glyph_soy_subbasin2_km2 = 100 * (a_amc_subbasin_ha/a_amc_ha) * (glyph_soy_AMC_subbasin2_up`sub'-glyph_soy_AMC_subbasin2_sameup`sub')/(a_amc_subbasin_ha_up`sub'-a_amc_subbasin_ha_sameup`sub') if(position==`sub')
		replace glyph_soy_subbasin3_km2 = 100 * (a_amc_subbasin_ha/a_amc_ha) * (glyph_soy_AMC_subbasin3_up`sub'-glyph_soy_AMC_subbasin3_sameup`sub')/(a_amc_subbasin_ha_up`sub'-a_amc_subbasin_ha_sameup`sub') if(position==`sub')
		replace glyph_soy_subbasin4_km2 = 100 * (a_amc_subbasin_ha/a_amc_ha) * (glyph_soy_AMC_subbasin4_up`sub'-glyph_soy_AMC_subbasin4_sameup`sub')/(a_amc_subbasin_ha_up`sub'-a_amc_subbasin_ha_sameup`sub') if(position==`sub')
		replace glyph_soy_subbasin5_km2 = 100 * (a_amc_subbasin_ha/a_amc_ha) * (glyph_soy_AMC_subbasin5_up`sub'-glyph_soy_AMC_subbasin5_sameup`sub')/(a_amc_subbasin_ha_up`sub'-a_amc_subbasin_ha_sameup`sub') if(position==`sub')
		replace glyph_soy_subbasin7_km2 = 100 * (a_amc_subbasin_ha/a_amc_ha) * (glyph_soy_AMC_subbasin7_up`sub'-glyph_soy_AMC_subbasin7_sameup`sub')/(a_amc_subbasin_ha_up`sub'-a_amc_subbasin_ha_sameup`sub') if(position==`sub')
		replace glyph_soy_subbasin8_km2 = 100 * (a_amc_subbasin_ha/a_amc_ha) * (glyph_soy_AMC_subbasin8_up`sub'-glyph_soy_AMC_subbasin8_sameup`sub')/(a_amc_subbasin_ha_up`sub'-a_amc_subbasin_ha_sameup`sub') if(position==`sub')
		replace glyph_soy_subbasin9_km2 = 100 * (a_amc_subbasin_ha/a_amc_ha) * (glyph_soy_AMC_subbasin9_up`sub'-glyph_soy_AMC_subbasin9_sameup`sub')/(a_amc_subbasin_ha_up`sub'-a_amc_subbasin_ha_sameup`sub') if(position==`sub')
		replace glyph_soy_subbasin10_km2 = 100 * (a_amc_subbasin_ha/a_amc_ha) * (glyph_soy_AMC_subbasin10_up`sub'-glyph_soy_AMC_subbasin10_sameup`sub')/(a_amc_subbasin_ha_up`sub'-a_amc_subbasin_ha_sameup`sub') if(position==`sub')
	
		replace glyph_soy_subbasin4 = (a_amc_subbasin_ha/a_amc_ha) * (glyph_soy_AMC_subbasin4_up`sub'-glyph_soy_AMC_subbasin4_sameup`sub') if(position==`sub')
	
		replace glyph_soy_downstream_km2 = 100 * (a_amc_subbasin_ha/a_amc_ha) * (glyph_soy_AMC_subbasin_down`sub'-glyph_soy_AMC_subbasin_samed`sub')/(a_amc_subbasin_ha_down`sub'-a_amc_subbasin_ha_samed`sub') if(position==`sub')
		replace glyph_soy_downstream2_km2 = 100 * (a_amc_subbasin_ha/a_amc_ha) * (glyph_soy_AMC_subbasin2_down`sub'-glyph_soy_AMC_subbasin2_samed`sub')/(a_amc_subbasin_ha_down`sub'-a_amc_subbasin_ha_samed`sub') if(position==`sub')
		replace glyph_soy_downstream3_km2 = 100 * (a_amc_subbasin_ha/a_amc_ha) * (glyph_soy_AMC_subbasin3_down`sub'-glyph_soy_AMC_subbasin3_samed`sub')/(a_amc_subbasin_ha_down`sub'-a_amc_subbasin_ha_samed`sub') if(position==`sub')
		replace glyph_soy_downstream4_km2 = 100 * (a_amc_subbasin_ha/a_amc_ha) * (glyph_soy_AMC_subbasin4_down`sub'-glyph_soy_AMC_subbasin4_samed`sub')/(a_amc_subbasin_ha_down`sub'-a_amc_subbasin_ha_samed`sub') if(position==`sub')
		replace glyph_soy_downstream5_km2 = 100 * (a_amc_subbasin_ha/a_amc_ha) * (glyph_soy_AMC_subbasin5_down`sub'-glyph_soy_AMC_subbasin5_samed`sub')/(a_amc_subbasin_ha_down`sub'-a_amc_subbasin_ha_samed`sub') if(position==`sub')
		replace glyph_soy_downstream7_km2 = 100 * (a_amc_subbasin_ha/a_amc_ha) * (glyph_soy_AMC_subbasin7_down`sub'-glyph_soy_AMC_subbasin7_samed`sub')/(a_amc_subbasin_ha_down`sub'-a_amc_subbasin_ha_samed`sub') if(position==`sub')
		replace glyph_soy_downstream8_km2 = 100 * (a_amc_subbasin_ha/a_amc_ha) * (glyph_soy_AMC_subbasin8_down`sub'-glyph_soy_AMC_subbasin8_samed`sub')/(a_amc_subbasin_ha_down`sub'-a_amc_subbasin_ha_samed`sub') if(position==`sub')
		replace glyph_soy_downstream9_km2 = 100 * (a_amc_subbasin_ha/a_amc_ha) * (glyph_soy_AMC_subbasin9_down`sub'-glyph_soy_AMC_subbasin9_samed`sub')/(a_amc_subbasin_ha_down`sub'-a_amc_subbasin_ha_samed`sub') if(position==`sub')
		replace glyph_soy_downstream10_km2 = 100 * (a_amc_subbasin_ha/a_amc_ha) * (glyph_soy_AMC_subbasin10_down`sub'-glyph_soy_AMC_subbasin10_samed`sub')/(a_amc_subbasin_ha_down`sub'-a_amc_subbasin_ha_samed`sub') if(position==`sub')
		
		replace potential_subotto_h = (a_amc_subbasin_ha/a_amc_ha) * (potential_h_up`sub'-potential_h_sameup`sub')/(a_amc_subbasin_ha_up`sub'-a_amc_subbasin_ha_sameup`sub') if(position==`sub')
		replace potential_subotto_l =  (a_amc_subbasin_ha/a_amc_ha) * (potential_l_up`sub'-potential_l_sameup`sub')/(a_amc_subbasin_ha_up`sub'-a_amc_subbasin_ha_sameup`sub') if(position==`sub')
		replace potential_downstream_h = (a_amc_subbasin_ha/a_amc_ha) * (potential_h_down`sub'-potential_h_samed`sub')/(a_amc_subbasin_ha_down`sub'-a_amc_subbasin_ha_samed`sub') if(position==`sub')
		replace potential_downstream_l = (a_amc_subbasin_ha/a_amc_ha) * (potential_l_down`sub'-potential_l_samed`sub')/(a_amc_subbasin_ha_down`sub'-a_amc_subbasin_ha_samed`sub') if(position==`sub')
		
		replace potential_subotto_h_unnorm = (potential_h_up`sub'-potential_h_sameup`sub') if(position==`sub')
		replace potential_subotto_l_unnorm =  (potential_l_up`sub'-potential_l_sameup`sub') if(position==`sub')
		
		replace potential_mze_subotto_h = (a_amc_subbasin_ha/a_amc_ha) * (potential_mze_h_up`sub'-potential_mze_h_sameup`sub')/(a_amc_subbasin_ha_up`sub'-a_amc_subbasin_ha_sameup`sub') if(position==`sub')
		replace potential_mze_subotto_l =  (a_amc_subbasin_ha/a_amc_ha) * (potential_mze_l_up`sub'-potential_mze_l_sameup`sub')/(a_amc_subbasin_ha_up`sub'-a_amc_subbasin_ha_sameup`sub') if(position==`sub')
		replace potential_mze_downstream_h = (a_amc_subbasin_ha/a_amc_ha) * (potential_mze_h_down`sub'-potential_mze_h_samed`sub')/(a_amc_subbasin_ha_down`sub'-a_amc_subbasin_ha_samed`sub') if(position==`sub')
		replace potential_mze_downstream_l = (a_amc_subbasin_ha/a_amc_ha) * (potential_mze_l_down`sub'-potential_mze_l_samed`sub')/(a_amc_subbasin_ha_down`sub'-a_amc_subbasin_ha_samed`sub') if(position==`sub')
		
		replace area_soy_upstream = (a_amc_subbasin_ha/a_amc_ha) * (area_soy_AMC_subbasin_up`sub' - area_soy_AMC_subbasin_sameup`sub')/(a_amc_subbasin_ha_up`sub'-a_amc_subbasin_ha_sameup`sub') if(position==`sub')
		replace area_soy_downstream = (a_amc_subbasin_ha/a_amc_ha) * (area_soy_AMC_subbasin_down`sub' - area_soy_AMC_subbasin_samed`sub')/(a_amc_subbasin_ha_down`sub'-a_amc_subbasin_ha_samed`sub') if(position==`sub')
		
		replace area_mze_upstream = (a_amc_subbasin_ha/a_amc_ha) * (area_mze_AMC_subbasin_up`sub' - area_mze_AMC_subbasin_sameup`sub')/(a_amc_subbasin_ha_up`sub'-a_amc_subbasin_ha_sameup`sub') if(position==`sub')
		replace area_mze_downstream = (a_amc_subbasin_ha/a_amc_ha) * (area_mze_AMC_subbasin_down`sub' - area_mze_AMC_subbasin_samed`sub')/(a_amc_subbasin_ha_down`sub'-a_amc_subbasin_ha_samed`sub') if(position==`sub')

		replace nonmissing_up = nonmissing_up`sub' if(position==`sub')
		
		replace area_upstream_ha = (a_amc_subbasin_ha/a_amc_ha) * (a_amc_subbasin_ha_up`sub'-a_amc_subbasin_ha_sameup`sub') if(position==`sub')
		replace area_downstream_ha = (a_amc_subbasin_ha/a_amc_ha) * (a_amc_subbasin_ha_down`sub'-a_amc_subbasin_ha_samed`sub') if(position==`sub')
}

* If area==0 or position==0, the calculations above make them missing. Thus, we need to change these values to 0.
foreach var in glyph_soy_subbasin_km2 glyph_soy_subbasin2_km2 glyph_soy_subbasin3_km2 glyph_soy_subbasin4_km2 glyph_soy_subbasin5_km2 glyph_soy_subbasin7_km2 glyph_soy_subbasin8_km2 glyph_soy_subbasin9_km2 glyph_soy_subbasin10_km2 glyph_soy_subbasin4 ///
potential_subotto_h potential_subotto_l potential_downstream_h potential_downstream_l ///
glyph_soy_downstream_km2 glyph_soy_downstream2_km2 glyph_soy_downstream3_km2 glyph_soy_downstream4_km2 glyph_soy_downstream5_km2 glyph_soy_downstream7_km2 glyph_soy_downstream8_km2 glyph_soy_downstream9_km2 glyph_soy_downstream10_km2 {
	replace `var' = 0 if `var'==.
}

* We finish the instrument construction by using 2004 as the timing of the shift
gen potentialSubotto2004=potential_subotto_l
replace potentialSubotto2004=potential_subotto_h if year>=2004

gen potentialMze2004=potential_mze_subotto_l
replace potentialMze2004=potential_mze_subotto_h if year>=2004

gen potentialSubottoUnnorm2004=potential_subotto_l_unnorm
replace potentialSubottoUnnorm2004=potential_subotto_h_unnorm if year>=2004

* Same variables as above, but for use downstream
gen potentialDownstream2004=potential_downstream_l
replace potentialDownstream2004=potential_downstream_h if year>=2004

gen potentialMzeDownstream2004=potential_mze_downstream_l
replace potentialMzeDownstream2004=potential_mze_downstream_h if year>=2004


** Label variables
label var glyph_soy_subbasin_km2  "Herbicides considering position based on the share of glyphosate used by each state in 2009"
label var glyph_soy_subbasin2_km2 "Herbicides considering position using the proportion of herbicides used by each state in 2009"
label var glyph_soy_subbasin3_km2 "Herbicides considering position using, for each year, the proportion of herbicides used by each state"

label variable potentialSubotto2004 "Potential considering position inside basin, low for year<2004, high for year>=2004"

label var glyph_soy_downstream_km2  "Herbicides used downstream based on the share of glyphosate used by each state in 2009"
label var glyph_soy_downstream2_km2 "Herbicides used downstream using the proportion of herbicides used by each state in 2009"
label var glyph_soy_downstream3_km2 "Herbicides used downstream using, for each year, the proportion of herbicides used by each state"

label variable potentialDownstream2004 "Potential of downstream areas, low for year<2004, high for year>=2004"

* We will assign to each AMC the basin in which most of its area is located
bys AMC basin year: egen a_amc_basin_ha = sum(a_amc_subbasin_ha)
bys AMC year: egen max_amc_basin_area = max(a_amc_basin_ha)
gen aux_basin = basin if a_amc_basin_ha==max_amc_basin_area
bys AMC year: egen assigned_basin=mean(aux_basin)
drop aux_basin max_amc_basin_area

* For descriptive stats, we will maintain the position where most of the AMC's area is located
sort year AMC a_amc_subbasin_ha

* Collapse by AMC-year
collapse (sum) potentialMze2004 potentialMzeDownstream2004 potentialSubotto2004 potentialSubottoUnnorm2004 potentialDownstream2004 ///
glyph_soy_subbasin_km2 glyph_soy_subbasin2_km2 glyph_soy_subbasin3_km2 glyph_soy_subbasin4_km2 glyph_soy_subbasin5_km2 glyph_soy_subbasin7_km2 glyph_soy_subbasin8_km2 glyph_soy_subbasin9_km2 glyph_soy_subbasin10_km2 ///
glyph_soy_downstream_km2 glyph_soy_downstream2_km2 glyph_soy_downstream3_km2 glyph_soy_downstream4_km2 glyph_soy_downstream5_km2 glyph_soy_downstream7_km2 glyph_soy_downstream8_km2 glyph_soy_downstream9_km2 glyph_soy_downstream10_km2 ///
area_upstream_ha area_downstream_ha ///
area_soy_upstream area_soy_downstream area_mze_upstream area_mze_downstream ///
(first) area_amc_km2 a_amc_ha area_soy_AMC area_mze_AMC A_soy_h A_soy_l A_mze_h A_mze_l ///
glyph_soy_AMC_km2 glyph_soy_AMC2_km2 glyph_soy_AMC3_km2 glyph_soy_AMC4_km2 glyph_soy_AMC5_km2 glyph_soy_AMC7_km2 glyph_soy_AMC8_km2 glyph_soy_AMC9_km2 glyph_soy_AMC10_km2 ///
(lastnm) position max_pos assigned_basin ///
(max) nonmissing_up, by(AMC year)

gen potentialAMC2004=A_soy_l
replace potentialAMC2004=A_soy_h if year>=2004

gen potentialAMCUnnorm2004=A_soy_l*a_amc_ha
replace potentialAMCUnnorm2004=A_soy_h*a_amc_ha if year>=2004

gen potentialMzeAMC2004=A_mze_l
replace potentialMzeAMC2004=A_mze_h if year>=2004

gen s_areasoy = area_soy_AMC / (100*area_amc_km2)
gen s_areacorn = area_mze_AMC / (100*area_amc_km2)

rename assigned_basin basin

save "$pathfiles_data/Workfiles/data_glyph_pot_subbasins.dta", replace
