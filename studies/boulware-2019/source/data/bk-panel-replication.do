* This program does the state-level panel regressions used in Boulware/Kuttner
* "Labor Market Conditions and Discrimination: Is There a Link?"
* Created on 1/10/2019

* Data sources:
*    Discrimination charges are from the EEOC Enforcement and Litigation statistics
*       https://www.eeoc.gov/eeoc/statistics/enforcement/
*    Labor force and unemployment rates are from the BLS Local Area Unemployment Statistics
*       https://www.bls.gov/lau/ex14tables.htm

clear
use "bk-panel-section-data"
*** EDITED BY Ryan Steed
xtset state2
***
log using panel-replication.log, replace
set linesize 132

gen race_rate = race/(lf7+ lf13)  

format %3.2f punemp1 punemp4 punemp7 punemp13 race_rate
format %5.1f race

summarize race race_rate ///
          punemp1 punemp4 punemp7 punemp13, format

* Drop states with missing data or very few claims
		  
drop if state == "Alaska" | state == "Hawaii" | state == "Idaho" | state == "Iowa" | ///
        state == "Maine"  | state == "Montana" | state == "Nebraska" | state == "New Hampshire" | ///
		state == "North Dakota" | state == "Oregon" | state == "South Dakota" | state == "Utah" | ///
		state == "Vermont" | state == "Wyoming" | state == "West Virginia" |  state == "Rhode Island"

summarize race race_rate ///
          punemp1 punemp4 punemp7 punemp13, format


* Regression (1)
		  
eststo: xtreg race_rate punemp1, fe					

* Regression (2)

eststo: xtreg race_rate punemp4 punemp7 punemp13,fe
*** EDITED by Annie Qian	
estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
*** EDITED by Annie Qian	
log close

