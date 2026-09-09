clear
*** EDIT by Donna
global 	DATA 	"../2_data"

/*==============================================================================
	STEP 1	GENERATE THE STATE FILES OF UNEMPLOYMENT RATES: 2001-2010
==============================================================================*/

	foreach ST in 	 al ak az ar ca co ct de dc fl ///
					 ga hi id il ind ia ks ky la me ///
					 md ma mi mn ms mo mt ne nv nh ///
					 nj nm ny nc nd oh ok or pa ri ///
					 sc sd tn tx ut vt va wa wv wi ///
					 wy		{

	quietly import delimited $DATA/BLS_LAU_MonthlyUnemploymentRates_/_`ST'.txt
		
	destring value, replace
	
	keep if year>=2001 & year<=2012

		gen st_fips		= substr(series_id, 6,  2)
			destring st_fips, replace
			
			label var st_fips "State FIPS Code [2-Digit]"
			
		gen datatype  	= substr(series_id, 1,  5)
		gen valuetype 	= substr(series_id, 19, 2) 

	keep if datatype =="LASST" & valuetype=="03"
	
	gen month = .
		replace month = 1 	if period=="M01"
		replace month = 2 	if period=="M02"
		replace month = 3 	if period=="M03"
		replace month = 4 	if period=="M04"
		replace month = 5 	if period=="M05"
		replace month = 6 	if period=="M06"
		replace month = 7 	if period=="M07"
		replace month = 8 	if period=="M08"
		replace month = 9 	if period=="M09"
		replace month = 10 	if period=="M10"
		replace month = 11 	if period=="M11"
		replace month = 12	if period=="M12"

	drop series_id  period  footnote_codes
	
	rename value st_unempl_rt
		label var st_unempl_rt "State Monthly Unemployment Rate"
			destring st_unempl_rt, replace
	
	quietly save $DATA/BLS_LAU_MonthlyUnemploymentRates_\_`ST'_MonthlyUnemploymentRate2001_2010.dta , replace

	clear
	}

*STOP
	
/*==============================================================================
	STEP 2	GENERATE SINGLE FILE OF UNEMPLOYMENT RATES W/ ALL STATES : 2001-2010
==============================================================================*/
		
		use  $DATA/BLS_LAU_MonthlyUnemploymentRates_\_al_MonthlyUnemploymentRate2001_2010.dta , clear
		 
		 	foreach ST in 	ak az ar ca co ct de dc fl ///
							ga hi id il ind ia ks ky la me ///
							md ma mi mn ms mo mt ne nv nh ///
							nj nm ny nc nd oh ok or pa ri ///
							sc sd tn tx ut vt va wa wv wi ///
							wy		{
							 
		 quietly append using $DATA/BLS_LAU_MonthlyUnemploymentRates_\_`ST'_MonthlyUnemploymentRate2001_2010.dta , force

				}
		
		save $DATA/AllStates_MonthlyUnemploymentRate2001_2010.dta , replace
		
		clear
		
/*==============================================================================
	STEP 3	USING JULY UNEMPLOYMENT RATE AS ANNUAL W/ ALL STATES : 2001-2010
==============================================================================*/
		
	use $DATA/AllStates_MonthlyUnemploymentRate2001_2010.dta , clear
			
		bysort st_fip year : egen ann_unempl = mean(st_unempl_rt)
				
			label var ann_unempl "State Unemployment Rate [Averaged for Annual]"
		keep if month == 7 /*July*/
		drop month				
				
		save $DATA/AllStates_JulyAnnualUnemploymentRate2001_2010.dta , replace
	clear
		
/*
			
	Merging variables: year month st_fip

	CITATION:
			Title:		Local Area Unemployment Statistics
			Author:		Bureau of Labor Statistics. 
			Publisher:	U.S. Department of Labor.
			URL:		https://www.bls.gov/lau/lausad.htm#flat
						https://download.bls.gov/pub/time.series/la/
			Date acc:	August 19, 2017
			Last upd:	August 18, 2017
			
