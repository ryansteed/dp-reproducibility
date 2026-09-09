* This program does the state-level cross-section regressions used in Boulware/Kuttner
* "Labor Market Conditions and Discrimination: Is There a Link?"
* Created on 1/9/2019

* Data sources:
*    Discrimination charges are from the EEOC Enforcement and Litigation statistics
*       https://www.eeoc.gov/eeoc/statistics/enforcement/
*    Unemployment rates and labor force figures are from the BLS Local Area 
*    Employment Statistics
*       https://www.bls.gov/lau/ex14tables.htm
*    Occupational data are from the EEOC's Job Patterns for Minorities and Women 
*    in Private Industry report
*       https://www.eeoc.gov/eeoc/statistics/employment/jobpat-eeo1/index.cfm

clear
use "bk-cross-section-data"
log using cross-section-replication.log, replace
set linesize 132

gen race_rate = race/(lf7+ lf13)  

gen wht_lf_share = lf4/lf1
gen blk_lf_share = lf7/lf1
gen hisp_lf_share = lf13/lf1

* generate "blue collar" employment shares

gen blkm_tot  = BLKM1+BLKM1_2+BLKM2+BLKM3+BLKM4+BLKM5+BLKM6+BLKM7+BLKM8+BLKM9
gen blkf_tot  = BLKF1+BLKF1_2+BLKF2+BLKF3+BLKF4+BLKF5+BLKF6+BLKF7+BLKF8+BLKF9
gen blk_blue  = BLKM5+BLKM6+BLKM7+BLKM8+BLKM9+BLKF5+BLKF6+BLKF7+BLKF8+BLKF9
gen blk_blue_shr = blk_blue/(blkm_tot + blkf_tot)

gen hspm_tot  = HISPM1+HISPM1_2+HISPM2+HISPM3+HISPM4+HISPM5+HISPM6+HISPM7+HISPM8+HISPM9
gen hspf_tot  = HISPF1+HISPF1_2+HISPF2+HISPF3+HISPF4+HISPF5+HISPF6+HISPF7+HISPF8+HISPF9
gen hsp_blue  = HISPM5+HISPM6+HISPM7+HISPM8+HISPM9+HISPF5+HISPF6+HISPF7+HISPF8+HISPF9
gen hsp_blue_shr = hsp_blue/(hspm_tot + hspf_tot)

gen whm_tot  = WHM1+WHM1_2+WHM2+WHM3+WHM4+WHM5+WHM6+WHM7+WHM8+WHM9
gen whf_tot  = WHF1+WHF1_2+WHF2+WHF3+WHF4+WHF5+WHF6+WHF7+WHF8+WHF9
gen wh_blue  = WHM5+WHM6+WHM7+WHM8+WHM9+WHF5+WHF6+WHF7+WHF8+WHF9
gen wh_blue_shr = wh_blue/(whm_tot + whf_tot)

gen blue_share = (blk_blue + wh_blue + hsp_blue)/(blkm_tot + blkf_tot + /// 
                  whm_tot + whf_tot + hspm_tot + hspf_tot)
                  
* Turn panel into a cross section                  

collapse (mean) wht_lf_share blk_lf_share hisp_lf_share ///
       race race_rate /// 
       punemp1 punemp4 punemp7 punemp13 blk_blue_shr wh_blue_shr hsp_blue_shr ///
	   blue_share, by(state)
	   
* Generate confederate dummy

gen confederate = (state == "Georgia") | (state == "Texas") | (state == "Florida") | ///
                      (state == "Louisiana") | (state == "South Carolina") | ///
					  (state == "Alabama") | (state == "Mississippi") | (state == "Virginia") | ///
					  (state == "Arkansas") | (state == "Tennessee") | (state == "North Carolina")
					  
label variable race "Number of race-based discrimination charges"
label variable blue_share "Share of blue collar workers"
label variable blk_blue_shr "Black blue collar share"
label variable wh_blue_shr "White blue collar share"
label variable hsp_blue_shr "Hispanic blue collar share"
label variable race_rate "claims/1000"
label variable hisp_lf_share "Hispanic share in labor force"
label variable blk_lf_share "Black share in labor force"
label variable wht_lf_share "White share in labor force"
label variable punemp1 "Overall unemployment rate"
label variable punemp4 "White unemployment rate"
label variable punemp7 "Black unemployment rate"
label variable punemp13 "Hispanic unemployment rate"
label variable confederate "Confederate dummy"

format %3.2f wht_lf_share blk_lf_share hisp_lf_share 
format %3.2f blk_blue_shr wh_blue_shr hsp_blue_shr blue_share 
format %3.2f punemp1 punemp4 punemp7 punemp13 race_rate
format %5.1f race
					  
summarize race race_rate ///
          punemp1 punemp4 punemp7 punemp13 ///
          wht_lf_share blk_lf_share hisp_lf_share  ///
		  blue_share blk_blue_shr hsp_blue_shr wh_blue_shr , format
		  
* Drop states with missing data or very few claims
		  
drop if state == "Alaska" | state == "Hawaii" | state == "Idaho" | state == "Iowa" | ///
        state == "Maine"  | state == "Montana" | state == "Nebraska" | state == "New Hampshire" | ///
		state == "North Dakota" | state == "Oregon" | state == "South Dakota" | state == "Utah" | ///
		state == "Vermont" | state == "Wyoming" | state == "West Virginia" |  state == "Rhode Island"

summarize race race_rate ///
          punemp1 punemp4 punemp7 punemp13 ///
          wht_lf_share blk_lf_share hisp_lf_share  ///
		  blue_share blk_blue_shr hsp_blue_shr wh_blue_shr , format

* Regression (1)
		  
eststo: regress race_rate blk_lf_share hisp_lf_share blue_share punemp4 punemp7 punemp13 confederate

* Regression (2)

eststo: regress race_rate blk_lf_share hisp_lf_share blue_share punemp13 
*** EDITED by Annie Qian
estout using "../../results/table2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
***
log close
