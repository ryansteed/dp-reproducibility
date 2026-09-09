//Replication code for "The Political Economy of Municipal Pension Funding,"  Brinkman, Coen-Pirani, and Sieg, AEJ:Macro

//Results for all tables and figures can be replicated by running this code.  Two sections must be uncommented to produce tables
// D.1 and D.3 from the appendix.

clear

//import delimited "city_data_stata8.csv"

use city_data_stata8

//*********************************************

//DATA DESCRIPTION

//DATA FROM MUNNELL AND AUBRY

// uaal2012  total unfunded liabilities in 2012 ($ millions)
// uaal_rev   unfunded liabilities divied by own-source revenues X 100  (%)

//DATA FROM AUBRY (THIS DATA WAS EMAILED AND NOT FOUND IN THE 2016 BRIEF)

//assets   total assets in pension plan
//liabilities  total liabilities in pension plan

//DATA FROM CENSUS

// tot_own   total owner households  (count)
// tot_rent  total renter households   (count)
// own_xx_yy  total owners between the ages of xx and yy  (count)
// rent_xx_yy  total renters between the ages of xx and yy  (count)
// tot_hh       total housholds
// aggregate_hh_inc   total househould income yearly 2012 ($/yr)
// aggregate_house_value  aggregate value of housing 2012 ($)
// median_hh_inc   Median household income 2012 ($/yr) 
// median_house_value   Median value of house   ($)
// city_pop     population of the city in 2012
// pop_1980   population of the city in 1980
// pop_2000   population of the city in 2000
// city      city name
// land_area   land area of municipality in sq meters
// id and id2   geo identifiers from census


//**************************************************************************

//GENERATE VARIABLES


//extract state and place codes
 gen statea = substr(id, 10, 2)
 gen placea = substr(id, 12, 5)

gen rev2=uaal2012/uaal_rev*1000000     // revenues from munnell aubry ($)

gen liabilities_pop =liabilities/city_pop *1000000   //per capita liabilities



//Measures of Liabilities

gen uaal_pop=uaal2012/city_pop*1000000 // UAAL divided by population (2012)  ($)

gen uaal_income=uaal2012/(aggregate_hh_inc/100)*1000000  //UAAL  divided by total income in city

gen uaal_value=uaal2012/(aggregate_house_value/100)*1000000  // UAAL divided by total housing value in city



//CONTROLS

//Age and Ownership Variables

gen per_own=tot_own/tot_hh*100   //percentage of households who own thier home

gen hh_O35 = own_35_44+rent_35_44+own_45_54+own_55_59+own_60_64+own_65_74+own_75_84+own_85_+rent_65_74+rent_75_84+rent_85_+rent_55_59+rent_60_64+rent_45_54 //total households over 55
gen hh_O45 = own_45_54+own_55_59+own_60_64+own_65_74+own_75_84+own_85_+rent_65_74+rent_75_84+rent_85_+rent_55_59+rent_60_64+rent_45_54 //total households over 55
gen hh_O55 = own_55_59+own_60_64+own_65_74+own_75_84+own_85_+rent_65_74+rent_75_84+rent_85_+rent_55_59+rent_60_64 //total households over 55
gen hh_O65 = own_65_74+own_75_84+own_85_+rent_65_74+rent_75_84+rent_85_ //total households over 65

gen hh_U35 = tot_hh-hh_O35
gen hh_U45 = tot_hh-hh_O45
gen hh_U55 = tot_hh-hh_O55
gen hh_U65 = tot_hh-hh_O65

gen hh_own_O55 = own_55_59+own_60_64+own_65_74+own_75_84+own_85_ // count households over 55 and own
gen hh_own_O45 = own_45_54+own_55_59+own_60_64+own_65_74+own_75_84+own_85_ // count households over 45 and own
gen hh_own_O65 = own_65_74+own_75_84+own_85_ // count households over 65 and own
gen hh_own_O35 = own_35_44+own_45_54+own_55_59+own_60_64+own_65_74+own_75_84+own_85_ // count households over 45 and own

gen hh_rent_O65=rent_65_74+rent_75_84+rent_85_ //count households over 55 and rent
gen hh_rent_O55=rent_55_59+rent_60_64+rent_65_74+rent_75_84+rent_85_ //count households over 55 and rent
gen hh_rent_O45=rent_45_54+rent_55_59+rent_60_64+rent_65_74+rent_75_84+rent_85_ //count households over 55 and rent
gen hh_rent_O35=rent_35_44+rent_45_54+rent_55_59+rent_60_64+rent_65_74+rent_75_84+rent_85_ //count households over 55 and rent

gen hh_rent_U65=tot_rent-hh_rent_O65     //count renters under 55
gen hh_rent_U55=tot_rent-hh_rent_O55     //count renters under 55
gen hh_rent_U45=tot_rent-hh_rent_O45     //count renters under 55
gen hh_rent_U35=tot_rent-hh_rent_O35     //count renters under 55

gen hh_own_U55 = tot_own-hh_own_O55 //count households under 55 and own
gen hh_own_U45 = tot_own-hh_own_O45 //count households under 55 and own
gen hh_own_U65 = tot_own-hh_own_O65 //count households under 55 and own
gen hh_own_U35 = tot_own-hh_own_O35 //count households under 55 and own

gen per_U65_total=hh_U65/tot_hh*100    //households under 45 / total housholds *100
gen per_U55_total=hh_U55/tot_hh*100    //households under 55 / total housholds *100
gen per_U45_total=hh_U45/tot_hh*100    //households under 45 / total housholds *100
gen per_U35_total=hh_U35/tot_hh*100    //households under 45 / total housholds *100


gen per_own_U55_total = hh_own_U55/tot_hh*100  //owners under 55 / total households *100
gen per_own_U45_total = hh_own_U45/tot_hh*100  //owners under 45 / total households *100
gen per_own_U65_total = hh_own_U65/tot_hh*100  //owners under 65 / total households *100
gen per_own_U35_total = hh_own_U35/tot_hh*100  //owners under 65 / total households *100

gen per_rent_U65_total = hh_rent_U65/tot_hh*100
gen per_rent_U55_total = hh_rent_U55/tot_hh*100
gen per_rent_U45_total = hh_rent_U45/tot_hh*100
gen per_rent_U35_total = hh_rent_U35/tot_hh*100

gen per_own_O55_total = hh_own_O55/tot_hh*100      // owners over 55 / total households *100    

gen per_own_U55=hh_own_U55/tot_own*100          // owners over 55 / total owners *100



//Other Controls

gen pop_change2000 = (city_pop-pop_2000)/pop_2000     //  population change between 2000 and 2012

gen pop_change1980 = (city_pop-pop_1980)/pop_1980     // population change betewwn 1980 and 2012

gen ln_city_pop=ln(city_pop)             // log of city population 2012

tabulate region, gen(regd)      //create region dummies  (regd1 = NE, regd2 = MW, regd3 = S, regd4=W)

gen ln_per_own_O55=ln(per_own_O55)

gen per_hh_over_55 = hh_O55/tot_hh*100   //percentage households over 55

gen per_hh_U35 = hh_U35/tot_hh*100   //percentage households over 55
gen per_hh_U45 = hh_U45/tot_hh*100   //percentage households over 55
gen per_hh_U55 = hh_U55/tot_hh*100   //percentage households over 55
gen per_hh_U65 = hh_U65/tot_hh*100   //percentage households over 55

gen density=city_pop/land_area*2590000    //density in square miles
gen log_density = ln(density)    //ln density

gen inc000=median_hh_inc/1000   //  income in thousands
gen ln_med_inc= ln(median_hh_inc)   //ln median income

gen ln_median_house_value=ln(median_house_value)    //log house value

gen inc_val = median_hh_inc/median_house_value      //income to house value ratio

gen ln_density=ln(density)                 //log density 

gen val_inc = median_house_value/median_hh_inc    //value to income ratio


//RESULTS IN PAPER

//**********************************************************************

//PLOT (Figure 1)

twoway (scatter uaal_pop per_own_U55_total, mlabel(name_ab) xscale(range(10 60)) ytitle("UAAL per capita ($)") xtitle("%  households who own home, under 55 years old")) (lfit uaal_pop per_own_U55_total, legend(off)) 

//**********************************************************************

//SUMMARY STATS  (Table 1)

sum  uaal_pop uaal_income uaal_rev uaal_value per_own_U55_total  

//spearman uaal_pop uaal_income uaal_rev uaal_value, stats(rho p)

//pwcorr uaal_pop uaal_income uaal_rev uaal_value, sig

//**********************************************************************

// Funding regressions (Table 2)

 eststo: reg uaal_pop per_own_U55_total,robust
 eststo: reg uaal_pop per_own_U55_total ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust  
 
 eststo: reg uaal_income per_own_U55_total, robust
 eststo: reg uaal_income per_own_U55_total ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 
 
 eststo: reg uaal_rev per_own_U55_total, robust
 eststo: reg uaal_rev per_own_U55_total ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 
 
 eststo: reg uaal_value per_own_U55_total, robust
 eststo: reg uaal_value per_own_U55_total ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 
 
 estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
  //**********************************************************************
 
 //*Code for Table D.1 is found at the end of the file.
 
 //**********************************************************************
 
 //Robustness:  Age cutoffs and ownership (Table D.2)
 
 //owners
 reg uaal_pop per_own_U35_total ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 
 reg uaal_pop per_own_U45_total ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 
 reg uaal_pop per_own_U55_total ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 
 reg uaal_pop per_own_U65_total ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 
 
 //all households
 reg uaal_pop  per_hh_U35 ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 
 reg uaal_pop  per_hh_U45 ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 
 reg uaal_pop  per_hh_U55 ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 
 reg uaal_pop  per_hh_U65 ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 
 
 //renters

 reg uaal_pop  per_rent_U35_total ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 
 reg uaal_pop  per_rent_U45_total ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 
 reg uaal_pop  per_rent_U55_total ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 
 reg uaal_pop  per_rent_U65_total ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 

 //**********************************************************************
 
 //*This analysis drops some observations, so it is commented out.  To recover results of Table D.3 remove "//" from start of each line in this section. 
 
 ////Robustness:  Low-ownership cities (Table D.3)
 
 //drop if per_own<38
 
 //reg uaal_pop per_own_U55_total
 //reg uaal_pop per_own_U55_total ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 
 
 //reg uaal_income per_own_U55_total
 //reg uaal_income per_own_U55_total ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 

 //reg uaal_rev per_own
 //reg uaal_rev per_own ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 
 
 //reg uaal_value per_own_U55_total
 //reg uaal_value per_own_U55_total ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 

 ////**********************************************************************
 
 //LAGGED AGE VARIABLES
 
 ////This analysis drops some observations, so it is commented out.  To recover results of Table D.1 remove "//" from start of each line below 
 
 
 //drop if missing(statea)    //missing identifiers
 
 
 ////Merge data from file containing 1990 ownership
//merge 1:1  statea placea using "data1990"
//drop if _merge==1| _merge==2
//drop _merge

////*NAMES of variables  (information only - leave commented)
////rename esd001  own_15_24y90   //`"Owner occupied >> 15 to 24 years"'
////rename esd002  own_25_34y90  //`"Owner occupied >> 25 to 34 years"'
////rename esd003  own_35_44y90  //`"Owner occupied >> 35 to 44 years"'
////rename esd004  own_45_54y90  //`"Owner occupied >> 45 to 54 years"'
////rename esd005  own_55_64y90  //`"Owner occupied >> 55 to 64 years"'
////rename esd006  own_65_74y90  //`"Owner occupied >> 65 to 74 years"'
////rename esd007  own_75_y90  //`"Owner occupied >> 75 years and over"'
////rename esd008  rent_15_24y90  //`"Renter occupied >> 15 to 24 years"'
////rename esd009  rent_25_34y90  //`"Renter occupied >> 25 to 34 years"'
////rename esd010  rent_35_44y90  //`"Renter occupied >> 35 to 44 years"'
////rename esd011  rent_45_54y90  //`"Renter occupied >> 45 to 54 years"'
////rename esd012  rent_55_64y90  //`"Renter occupied >> 55 to 64 years"'
////rename esd013  rent_65_74y90 //`"Renter occupied >> 65 to 74 years"'
////rename esd014  rent_75_y90  //`"Renter occupied >> 75 years and over"'
 
//gen tot_owny90=esd001 + esd002 + esd003 + esd004 + esd005 + esd006 + esd007   //all owners
//gen tot_renty90=esd008 + esd009 + esd010 + esd011 + esd012 + esd013 + esd014    //all renters

//gen tot_hhy90 = tot_renty90+tot_owny90     ///all households


//gen hh_own_O55y90 = esd005 + esd006 + esd007 // count households over 55 and own
//gen hh_own_U55y90 = tot_owny90-hh_own_O55y90 //count households under 55 and own

//gen per_own_U55_totaly90 = hh_own_U55y90/tot_hhy90*100  //owners under 55 / total households *100

//gen per_owny90 = tot_owny90/tot_hhy90

 ////*********************************************************************

 ////lagged ownership (Table D.1)

 //reg uaal_pop per_own_U55_totaly90
 //reg uaal_pop per_own_U55_totaly90 ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 

 //reg uaal_income per_own_U55_totaly90
 //reg uaal_income per_own_U55_totaly90 ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 

 
 //reg uaal_rev per_own_U55_totaly90
 //reg uaal_rev per_own_U55_totaly90 ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 
 
 //reg uaal_value per_own_U55_totaly90
 //reg uaal_value per_own_U55_totaly90 ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 


