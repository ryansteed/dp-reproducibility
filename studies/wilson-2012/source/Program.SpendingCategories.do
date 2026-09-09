* * * * Spending Categories * * * *

*  In this section I am creating five different categories of spending.
*  These are education health labor transportation and other.
*  American Progress breaks its spending up into different programs and I have already
*  categorized these programs in the American Progress DataImport script.
*  For the Wall Street journal I am assigning the categories thusly:
 
*  WSJ_education - ED
*  WSJ_health - HHS 
*             - DOL 
*  WSJ_transportation - DOT 
*  everything else - OTHER 

*  So at this step all that I really have to do is sum obligations/payments/announcements and Wall Street Journal amounts
*  for the "other" category.

* Sum them if they are not missing.
#delimit ;

* This used to be in a loop ;
local outvar = "obl";
gen `outvar'_other = 0;
foreach oblvar of varlist finaltotal`outvar'_dlrCNCS
  finaltotal`outvar'_dlrDHS
  finaltotal`outvar'_dlrDOC
  finaltotal`outvar'_dlrDOD
  finaltotal`outvar'_dlrDOE
  finaltotal`outvar'_dlrDOI
  finaltotal`outvar'_dlrDOJ
  finaltotal`outvar'_dlrEPA
  finaltotal`outvar'_dlrHUD
  finaltotal`outvar'_dlrNASA
  finaltotal`outvar'_dlrNEA
  finaltotal`outvar'_dlrNSF
  finaltotal`outvar'_dlrTREAS
  finaltotal`outvar'_dlrUSAID
  finaltotal`outvar'_dlrUSDA
  finaltotal`outvar'_dlrSSA
  finaltotal`outvar'_dlrVA {;
	replace `outvar'_other = `outvar'_other + `oblvar' if `oblvar' ~= .;
	};
gen `outvar'_hhs = finaltotal`outvar'_dlrHHS  ;
gen `outvar'_dol = finaltotal`outvar'_dlrDOL;
gen `outvar'_dot = finaltotal`outvar'_dlrDOT;
gen `outvar'_ed  = finaltotal`outvar'_dlrED;


local outvar = "pd";
gen `outvar'_other = 0;
foreach oblvar of varlist finaltotal`outvar'_dlrCNCS
  finaltotal`outvar'_dlrDHS
  finaltotal`outvar'_dlrDOC
  finaltotal`outvar'_dlrDOD
  finaltotal`outvar'_dlrDOE
  finaltotal`outvar'_dlrDOI
  finaltotal`outvar'_dlrDOJ
  finaltotal`outvar'_dlrEPA
  finaltotal`outvar'_dlrHUD
  finaltotal`outvar'_dlrNASA
  finaltotal`outvar'_dlrNEA
  finaltotal`outvar'_dlrNSF
  finaltotal`outvar'_dlrTREAS
  finaltotal`outvar'_dlrUSAID
  finaltotal`outvar'_dlrSSA
  finaltotal`outvar'_dlrUSDA {;
	replace `outvar'_other = `outvar'_other + `oblvar' if `oblvar' ~= .;
	};
gen `outvar'_hhs = finaltotal`outvar'_dlrHHS  ;
gen `outvar'_dol = finaltotal`outvar'_dlrDOL;
gen `outvar'_dot = finaltotal`outvar'_dlrDOT;
gen `outvar'_ed  = finaltotal`outvar'_dlrED;


gen ann_other = 0;
gen ann_dol = AnnouncedDOL;
gen ann_dot = AnnouncedDOT;
gen ann_ed  = AnnouncedED;
gen ann_hhs = AnnouncedHHS;
  
foreach annvar of varlist
  AnnouncedCNCS   
  AnnouncedDHS    
  AnnouncedDOC    
  AnnouncedDOD    
  AnnouncedDOE    
  AnnouncedDOI    
  AnnouncedDOJ    
  AnnouncedDOS    
  AnnouncedEPA    
  AnnouncedFCC    
  AnnouncedGSA    
  AnnouncedHUD    
  AnnouncedNASA   
  AnnouncedRRB    
  AnnouncedSBA    
  AnnouncedSI     
  AnnouncedSSA    
  AnnouncedTREAS  
  AnnouncedUSACE  
  AnnouncedUSAID  
  AnnouncedUSDA   
  AnnouncedVA   {;
	replace ann_other = ann_other + `annvar' if `annvar' ~= .;
	};

#delimit cr;

*  I also make a copy of all of these variables in their per-capita format as well.

sort state time

foreach variable of varlist *_other *_hhs *_ed *_dol *_dot {
	disp "`variable'"
   gen `variable'_percap_mill = `variable'/((StatePopulation*1000)*1000000)
}
