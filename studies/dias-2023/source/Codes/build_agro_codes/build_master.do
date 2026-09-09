********************************************************************************
*** BUILD: MAIN DATASET (MASTER)
***
*** Obs: We ignore some locations that were created and extinguished before 1996
*** or after 2010. We also ignore one small municipality called Pinto Bandeira, 
*** which only existed for two years as a separate municipality and does not affect
*** our analysis.
********************************************************************************

*** Preamble and path to files

set matsize 11000
set more off, perm

clear*
* Path: data - original data has to be in $pathfiles_data\Originais
global pathfiles_data ""
* Path: Census microdata
global pathfiles_censusdata ""
* Path: build do-files
global pathfiles_do ""
* Path: Choose directory where SIM microdata is located
global datasus ""

*********************** Build all the auxiliary datasets ***********************

* Census (need to adjust path where microdata is located for data_census.do)
* data_census.do uses Census microdata; since we do not provide the microdata,
* we comment the line below and provide the treated dataset in "$pathfiles_data/Workfiles"

* do "$pathfiles_do/data_census.do" //dta generated: data_census.dta
do "$pathfiles_do/data_censo2000.do"

* Glyphosate and Potential
do "$pathfiles_do/data_glyph_pot_subbasins.do" // generates data_glyph_pot_subbasins.dta

*

* Data by distance (potential and glyphosate)
do "$pathfiles_do/data_potential_distance.do"
do "$pathfiles_do/data_glyph_distance.do" // obs: needs data_glyph_pot_subbasins.dta & we have to define which glyphosate measure we are using inside the do file

* Water Quality
do "$pathfiles_do/data_water_quality.do"

* Soil Coverage
do "$pathfiles_do/data_soil_coverage_mapbiomas_v3.do"

* Rain
do "$pathfiles_do/data_rain_subbasins.do"

* Soil
do "$pathfiles_do/data_soil_subbasins.do"

* Water sources
do "$pathfiles_do/data_watersources.do"


* SIM (mortality) and SINASC (natality) data 
* All four below use Ministry of Health's microdata; since we do not provide them,
* we comment them below and provide the treated datasets in "$pathfiles_data/Workfiles"
*
* do "$pathfiles_do/SIM_build_all.do" //dta generated: SIM_year.dta
* do "$pathfiles_do/SINASC_build.do" //dta generated: SINASC_year.dta
* do "$pathfiles_do/SIM_build_bymonth.do" //dta generated: SIM_yearmonth.dta
* do "$pathfiles_do/SINASC_build_bymonth.do" //dta generated: SINASC_yearmonth_onlybirths.dta

********************************************************************************


******************* Merge and build final datasets datasets ********************


*** Merge auxiliary and original datasets	
do "$pathfiles_do/data_merge.do"

*** Generate Census spillovers data (for spillovers results, it's a separate dataset)
*** Obs: this do-file uses data_final.dta, created by data_merge.do above
do "$pathfiles_do/data_spillovers_censo.do"

*** Erase auxiliary datasets
erase "$pathfiles_data/Workfiles/data_censo2000.dta"
erase "$pathfiles_data/Workfiles/data_glyph_pot_subbasins.dta"
erase "$pathfiles_data/Workfiles/data_potential_distance.dta"
erase "$pathfiles_data/Workfiles/data_glyph_distance.dta"
erase "$pathfiles_data/Workfiles/data_water_quality.dta"
erase "$pathfiles_data/Workfiles/data_soil_coverage_mapbiomas_v3.dta"
erase "$pathfiles_data/Workfiles/data_rain_subbasins.dta"
erase "$pathfiles_data/Workfiles/data_soil_subbasins.dta"
erase "$pathfiles_data/Workfiles/data_watersources.dta"

*** Since we do not provide the raw microdata for these two files below, we are
*** not going to erase them
* erase "$pathfiles_data/Workfiles/data_census.dta"
* erase "$pathfiles_data/Workfiles/SIM_year.dta"
* erase "$pathfiles_data/Workfiles/SIM_yearmonth.dta"
* erase "$pathfiles_data/Workfiles/SINASC_year.dta"
* erase "$pathfiles_data/Workfiles/SINASC_yearmonth_onlybirths.dta"
