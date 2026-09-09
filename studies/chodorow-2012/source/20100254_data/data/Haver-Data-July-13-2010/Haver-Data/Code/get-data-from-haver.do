clear
set mem 300m
set more off

global OutputPath E:

*	First, get the key data for each state
*		Education and Health Services
*		Federal government
*		Total government
*		Local government
*		Total non farm
*		Educational services
*		State government
*		Health care and social assistance
foreach state in AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY {
	clear
	tempfile ces_`state'_data
	haver use `state'LNAGRA  `state'LS0A  `state'LT0A  `state'LEDUHA  `state'LGOVTA  `state'LFGOVA  `state'LSGOVA  `state'LLGOVA `state'LNAGR  `state'LS0  `state'LT0  `state'LEDUH  `state'LGOVT  `state'LFGOV  `state'LSGOV  `state'LLGOV using s:\haver\data\laborr.dat
	save `ces_`state'_data'
	}

*	Also get the QCEW data
*		Federal govt
*		Local govt
*		Private education
*		Private Health
*		Private education and health
*		State govt
*		Total govt
*		Private
foreach state in AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY {
	clear
	tempfile qcew_`state'_data
	haver use `state'TEZ0	`state'TEGZ0	`state'LEZ0	`state'SEZ0	`state'FEZ0	`state'PEZ25	`state'PES0	`state'PET0 using s:\haver\data\cewr.dat
	save `qcew_`state'_data'
	}


*	Note that we need some extra series for DC and Wyoming
clear
tempfile DC_Wyoming_temp
haver use DCLGOVTA DCLFGOVA DCLGOVT DCLFGOV WYLS0 WYLT0 using s:\haver\data\laborr.dat
save `DC_Wyoming_temp'
 

*	Then, merge these data together
clear
use `ces_AK_data', replace
foreach state in AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY {
	merge time using `ces_`state'_data', sort
	tab _merge
	drop _merge
	}

foreach state in AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY {
	merge time using `qcew_`state'_data', sort
	tab _merge
	drop _merge
	}

merge time using `DC_Wyoming_temp', sort
drop _merge

order time


compress



save "$OutputPath\final_cleaned_data", replace
