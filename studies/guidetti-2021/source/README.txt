Name/contact information: Bruna Guidetti (guidetti@umich.edu)

Datasets: main_data, munic_beds and census 
Date of data collection: 2017

File name: main_data.dta
Description: Data on hospitalization rate per district associated with the closest monitor that measures air pollution and metheorological variables
Sources: Hospital Information System of the Brazilian Unified National Health System, 2015-2018
	 Environmental Agency of Sao Paulo State (CETESB) (2015-2018)
	 Brazilian Geocoded Census (2010)
	 Brazilian National Registry of Health Establishments (2014)
Date of creation: 2019
Restrictions: the raw data is publicly available
Unit of observation: district-day (2015-2017)
Variables:
   monitor: monitor id
   latitude: latitude of the monitor
   longitude: longitude of the monitor
   district: district id
   date_str: date in string format (YYYY-MM-DD)
   date: date in numeric format
   dow: day of the week (0: Sunday; 6: Saturday)
   month: month of the year
   year: year
   population: number of children between 1 and 5
   hrate_resp: hospitalization rate caused by respiratory diseases 
   hrate_pneu: hospitalization rate caused by pneumonia
   hrate_asthma: hospitalization rate caused by asthma
   hrate_influ: hospitalization rate caused by influenza
   hrate_append: hospitalization rate caused by appendicitis 
   hrate_epilep: hospitalization rate caused by epilepsy
   hrate_phimo: hospitalization rate caused by phimosis
   hrate_bonefrac: hospitalization rate caused by bone fracture (shoulder and arm)
   pm: particulate matter with diameters less than or equal to 10 micrometers (in 10 micrograms per cubic meter)
   temp: temperature (in degree Celsius)
   humid: humidity (in %)
   ws: wind speed (in meters per second) in the day of the admission
   ws_1: wind speed measured in the day before the admission
   temp2: temperature squared
   humid2: humidity squared
   temphumit: temperature times humidity
   high_ped_beds: dummy indicating whether the pediatric beds per children population available is greater than the weighted median (weight = population)
   pm_high_ped_beds: pm times high_ped_beds
   ws_high_ped_beds: ws times high_ped_beds
   ws1_high_ped_beds: ws_1 times high_ped_beds
   

File name: munic_beds.dta
Description: Data on pediatric beds per municipality of the Sao Paulo Metropolitan Area
Date of creation: 2019
Sources: Brazilian National Registry of Health Establishments (2014)
	 Brazilian Geocoded Census (2010)	 
Restrictions: the raw data is publicly available
Unit of observation: municipalities in 2014
Variables:
   munic_id: municipality id
   population: population of children between 1 and 5
   pediatric: number of pediatric beds


Dataset: Census
Description: shapefile of Sao Paulo Metropolitan Area
Date of creation: version available in 2017 at "Centros de Estudos da Metropole"
Sources: "Centros de Estudos da Metropole"
Restrictions: the raw data is publicly available
Unit of observation (.DBF file): census tract
Variables (this is a raw dataset):
   ID: polygon id
   AREA: area of the polygon
   CODSETOR: census tract id
   COD_GR: greater area id
   NOM_GR: greater area name
   COD_UF: state id
   NOM_UF: state name
   COD_ME: mesoregion id
   NOM_ME: mesoregion name
   COD_MI: microregion id
   NOM_MI: microregion name
   COD_MR: metropolitan area id
   NOM_MR: metropolitan area name
   COD_MU: municipality id
   NOM_MU: municipality name
   COD_DI: district id
   NOM_DI: district name
   COD_SD: subdistrict id
   NOM_SD: subdistrict name
   COD_BA: neighbor id
   NOM_BA: beighbor name
   SITUA1: subclassifications of urban and rural
   SITUA2: urban or rural
   TIPO: whether the sector is a sub-normal settlement ("N": no; "S": yes)


Scripts: reg.do and maps.R

Script name: reg.do
Description: code for the regressions
Software: Stata (2016)
Packages: ivreghdfe, reghdfe, esttab
Inputs: main_data.dta
Outputs: table1, table2, table1 - appendix and table2 - appendix 
Instruction: Replace the "add the path here" by the filepath

Script name: maps.R
Description: code for the maps
Software: R (version 4.0.3)
Packages: they are listed in the beginning of the script and will automatically install
Inputs: main_data.dta, munic_beds.dta and Cesus
Outputs: map_district (pdf and png) and map_beds (pdf and png). These are input for maps (pdf and png), which is the Figure 1 in the manuscript.
Instruction: Replace the "add the path here" by the filepath

Note: the outputs will be saved in the filepath
