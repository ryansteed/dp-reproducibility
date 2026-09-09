/********************************************************************************
	Wilson_AEJEP_2012.do
	
	This file produces all of the results provided in 
	Fiscal Spending Jobs Multipliers: Evidence from the 2009 American Recovery 
	and Reinvestment Act
	
*********************************************************************************/
clear
clear matrix
version 11.1
quietly capture log close
set more off

capture mkdir results
capture mkdir logs
global data "data/Master.Final.dta"
global data_JanPre "data/Master.Final.JanPre.dta"
global data_DecPre "data/Master.Final.DecPre.dta"
global data_NovPre "data/Master.Final.NovPre.dta"
global data_Full "data/Master_Controls_and_Outcomes.dta"

/* *** EDITED by Ryan Steed
* Table 1
if 1==1 {
	quietly log using logs/table1.log, replace
	use $data_Full, clear

	* Fix the Social Security Amounts.
	qui: FixSSA ym(2009,2)

	*  Make the tax benefits variable.
	gen taxbenefits_dollarspercap = taxbenefits/(StatePopulation*1000)
	gen taxbenefits_cap = taxbenefits/(1000000*(StatePopulation*1000))
	label variable taxbenefits_cap "Tax Benefits (Mill. per cap)"
	label variable taxbenefits_dollarspercap "Tax Benefits (p.c.)"

	gen obligations   = 0
	gen obligations_lessdol = 0
	gen payments      = 0
	gen payments_lessdol = 0
	gen announcements = 0
	gen announcements_lessdol = 0
	gen Amounts_wallstreet      = 0
	
	qui: desc finaltotalobl_dlr*, varlist
	foreach variable in `r(varlist)' {
		replace obligations = obligations + `variable' if `variable' ~= .
		replace obligations_lessdol = obligations_lessdol + `variable' if `variable' ~= . & `variable' ~= finaltotalobl_dlrDOL
		}
	
	qui: desc finaltotalpd_dlr*, varlist
	foreach variable in `r(varlist)' {
		replace payments = payments + `variable' if `variable' ~= .
		replace payments_lessdol = payments_lessdol + `variable' if `variable' ~= . & `variable' ~= finaltotalpd_dlrDOL
	}
	
	qui: desc Announced*, varlist
	foreach variable in `r(varlist)'{
		replace announcements = announcements + `variable' if `variable' ~= .
		replace announcements_lessdol = announcements_lessdol + `variable' if `variable' ~= . & `variable' ~= AnnouncedDOL
	}
	generate obligations_percapita   = obligations   / (StatePopulation*1000)
	generate payments_percapita      = payments      / (StatePopulation*1000)
	generate announcements_percapita = announcements / (StatePopulation*1000)
	
	generate obl_percapita_lessdol = obligations_lessdol / (StatePopulation*1000)
	generate pd_percapita_lessdol  = payments_lessdol / (StatePopulation*1000)
	generate ann_percapita_lessdol = announcements_lessdol / (StatePopulation*1000)
	
	label variable obligations_percapita "Per-Capita Obligations"
	label variable announcements_percapita "Per-Capita Announcements"
	label variable payments_percapita "Per-Capita Payments to States"
	
	sort state time
	
	#delimit ;

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
	
	
	gen announced_other = 0;
	gen announced_dol = AnnouncedDOL;
	gen announced_dot = AnnouncedDOT;
	gen announced_ed  = AnnouncedED;
	gen announced_hhs = AnnouncedHHS;
	
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
		replace announced_other = announced_other + `annvar' if `annvar' ~= .;
	};

	#delimit cr;
	
	* Get the per-capita amounts ...
	
	foreach variable of varlist *_other *_hhs *_dol *_dot *_ed {
		gen `variable'_percap = `variable'/(StatePopulation*1000)
	}
	
	
	gen time_2 = dofm(time)
	drop time
	rename time_2 time
	format %td time
	format %20.0gc announcements* obligations* payments*
	local savefile = "tmp_displays"
	
	*For all of these displays I am excluding Washington, D.C.
	
	drop if state == 11
	keep if time == mdy(3, 1, 2011)
	collapse (sum) StatePopulation *_other *_hhs *_dol *_dot *_ed
	
	gen sum_announcements = announced_other + announced_hhs + announced_dot + announced_ed
	gen sum_obligations   = obl_other + obl_hhs + obl_dot + obl_ed
	gen sum_payments      = pd_other + pd_hhs + pd_dot + pd_ed
	
	foreach agency in ed other hhs dot {
		gen announced_`agency'_mill = announced_`agency'/1000000
		gen obl_`agency'_mill = obl_`agency'/1000000
		gen pd_`agency'_mill = pd_`agency'/1000000
	}
	
	tempfile _tmp1
	save `_tmp1' , replace
	
	foreach agency in ed other hhs dot {
		gen pct_1_`agency' = announced_`agency'/sum_announcements
		gen pct_2_`agency' = obl_`agency'/sum_obligations
		gen pct_3_`agency' = pd_`agency'/sum_payments
	}
	
	/* These reshape and collapse commands convert the dataset into the agency X stimulus measure
	That we are looking to output. */
	
	keep pct_*
	gen obs = 1
	reshape long pct_ , i(obs) j(percent) string
	
	gen type = substr(percent, 1, 1)
	gen agency = substr(percent, -3, .)
	
	reshape wide pct_ , j(type) i(percent) string
	collapse (sum) pct_1 pct_2 pct_3 , by(agency)
	rename pct_1 Percent_Announced
	rename pct_2 Percent_Obligated
	rename pct_3 Percent_Payments
	
	sort agency
	
	tempfile _tmp2
	save `_tmp2', replace
	
	use `_tmp1', replace
	
	keep *_mill
	
	foreach agency in ed other hhs dot{
		rename announced_`agency'_mill mill_1_`agency' 
		rename obl_`agency'_mill mill_2_`agency'
		rename pd_`agency'_mill mill_3_`agency'
		}
	
	gen obs = 1
	reshape long mill_ , i(obs) j(sum) string
	
	gen type = substr(sum, 1, 1)
	gen agency = substr(sum, -3, .)
	
	reshape wide mill_ , j(type) i(sum) string
	collapse (sum) mill_1 mill_2 mill_3 , by(agency)
	rename mill_1 Sum_Announced
	rename mill_2 Sum_Obligated
	rename mill_3 Sum_Payments
	sort agency
	merge agency using `_tmp2'
	drop _merge
	
	foreach variable of varlist Percent* {
		replace `variable' = `variable'*100
		}
	/* Now convert to matrix and then output to .tex*/
	
	
	/* This is some serious hacking-together to output this stuff correctly,
	but I need to put the percents in parentheses and I don't know any other way to do it.
	Basically I am making them all negative, and then telling estout to replace the negative sign with the open parentheses, and
	then telling estout to replace .* with .*) for all * between 0 and 9. This works because the sums are always positive and I have
	formatted them without decimals.
	*/
	
	set obs `= _N+1'
	gen sum_ann = sum(Sum_Announced)
	gen sum_obl = sum(Sum_Obligated)
	gen sum_pay = sum(Sum_Payments)
	
	/* Make these output as billions instead of millions */
	replace Sum_Announced = sum_ann if Sum_Announced == .
	replace Sum_Obligated = sum_obl if Sum_Obligated == .
	replace Sum_Payments = sum_pay if Sum_Payments == .
	
	replace Sum_Announced = Sum_Announced/1000
	replace Sum_Obligated = Sum_Obligated/1000
	replace Sum_Payments = Sum_Payments/1000
	
	gen sum_pcta = sum(Percent_Announced)
	gen sum_pcto = sum(Percent_Obligated)
	gen sum_pctp = sum(Percent_Payments)
	replace Percent_Announced = sum_pcta if Percent_Announced == .
	replace Percent_Obligated = sum_pcto if Percent_Obligated == .
	replace Percent_Payments  = sum_pctp if Percent_Payments == .
	
	
	replace Percent_Announced = -1*Percent_Announced
	replace Percent_Obligated = -1*Percent_Obligated
	replace Percent_Payments = -1*Percent_Payments
	mkmat Sum_Announced Percent_Announced Sum_Obligated Percent_Obligated Sum_Payments Percent_Payments , matrix(output)
	matrix rownames output =  "(ED)" "(DOT)" "(Other)" "(HHS)" "(sum)"
	matrix colnames output = "Announcements" ""  "Obligations" ""  "Payments" ""
	
	#delimit ;
	estout matrix(output, fmt(%9,1fc 1 %9,1fc 1 %9,1fc 1)) using results/Table1.tex, style(tex)  posthead("\hline \hline") replace collabels("Announcements" "" "Obligations" "" "Payments" "") msign("(")
	  substitute("output" ""
	  "-" "("
	  ".0" ".0)"
	  ".1" ".1)"
	  ".2" ".2)"
	  ".3" ".3)"
	  ".4" ".4)"
	  ".5" ".5)"
	  ".6" ".6)"
	  ".7" ".7)"
	  ".8" ".8)"
	  ".9" ".9)"
	  ","  "."
	  "(ED)" "Dept. of Education (ED)"
	  "(DOT)" "Dept. of Transportation (DOT)"
	  "(Other)" "Other"
	  "(HHS)" "Dept. of Health and Human Services (HHS)"
	  "(sum)" "Total (excluding Dept. of Labor)"
	  )
	  ;
	#delimit cr;
	log close
}
* Table 2
if 1==1{
	quietly log using logs/table2.log, replace
	use $data, clear
	
	*** The latest data used in this file is as-of:
	
	summ time
	local finaldate = ym(2010,2)

	*** The default pre time period is February, 2009.
	local pre = ym(2009, 2)
	local pre_text = string(`pre', "%tmMonYY")
	local window = `finaldate' - `pre'

	*** Which would give the following number of months in the window between pre and post:
	display "Window is: "
	display `window'
	
	* Regress stimulus on instruments to create fitted values for each stimulus measure *
	
	local instruments "HHS_instrument ED_instrument DOT_predict_instrument"
	regress ann_cap `instruments' if time==tm(2010m2) & state~=11
	predict ann_cap_predict if e(sample), xb
	bysort state: egen ann_cap_predicted = min(ann_cap_predict)
	
	* Create ranks for predicted stimulus reciepts as of 2/2010 for each state *
	
	keep if time==ym(2010,2) & state~=11
	rename state statecode
	decode statecode, generate(state)
	gen stateabbrev = substr(state,1,2)
	egen ann_rank = rank(ann_cap_predicted)
	gen stimulus_rank = 51-ann_rank
	gen pred_ann_round = round(ann_cap_predicted)
	gen ann_cap_round = round(ann_cap)
	gen HHS_round = round(HHS_instrument)
	gen DOT_round = round(DOT_predict_instrument)
	gen ED_temp = (round(ED_instrument*1000))/1000
	gen ED_round = round(ED_temp,.001)
	
	sort stimulus_rank
	
	mkmat pred_ann_round ann_cap_round HHS_round ED_round DOT_round, matrix(ARRA_Announcements) rownames(stateabbrev)
	matrix colnames ARRA_Announcements = Predicted_Announcements Actual_Announcements HHS_instrument ED_instrument DOT_instrument 
	matlist ARRA_Announcements 
	outtable using results/Table2, mat(ARRA_Announcements ) replace  format(%9.3g) caption("Selected Variables, as of February 2010" "States Ranked by Predicted ARRA Announcements") clabel(Tab:Predicted_ARRA_Announcements)
	log close
}
* Table 3
if 1==1 {
	quietly log using logs/table3.log, replace
	use $data, clear

	*** The latest data used in this file is as-of:	
	summ time
	local finaldate = ym(2010,2)

	*** The default pre time period is February, 2009.
	local pre = ym(2009, 2)
	local pre_text = string(`pre', "%tmMonYY")
	local window = `finaldate' - `pre'

	*** Which would give the following number of months in the window between pre and post:
	display "Window is: "
	display `window'
	
	* I am making three panels, one for dependent variables, one for explanatory variables, and one for instruments.
 	
 	matrix dep_Summ = (0, 0, 0, 0, 0)
 	matrix explanatory_Summ = (0, 0, 0, 0, 0)
 	matrix instrument_Summ = (0, 0, 0, 0, 0)
 	
	label variable RealAnnualPI_3yrMADifference "Change in PI 3-yr Moving Average (p.c.), 2005 to 2006"
	label variable change_localgov_emp_rate "Change in Employment (p.c.), S\&L Government"
	label variable cont_drchange_localgov_emp_rate "Dec07-Feb09 Employment (p.c.) trend, S\&L Government"
	label variable cont_lchange_localgov_emp_rate "Feb09 Employment (p.c.) Level, S\&L Government"
 	#delimit ;
 	local dep_sumvars
 	  change_emp_rate
 	  change_priv_emp_rate
 	  change_localgov_emp_rate
 	  change_cons_emp_rate
 	  change_manu_emp_rate
 	  change_eduh_emp_rate
 	  change_unemp_rate
 	  ;
 	
 	local explanatory_sumvars
 	  ann_cap
 	  obl_cap
 	  pay_cap
 	  cont_drchange_emp_rate
 	  cont_drchange_localgov_emp_rate
 	  cont_drchange_priv_emp_rate
 	  cont_drchange_cons_emp_rate
 	  cont_drchange_manu_emp_rate
 	  cont_drchange_eduh_emp_rate
 	  cont_drchange_unemp_rate
 	  cont_lchange_emp_rate
 	  cont_lchange_localgov_emp_rate  
 	  cont_lchange_priv_emp_rate
 	  cont_lchange_cons_emp_rate
 	  cont_lchange_manu_emp_rate
 	  cont_lchange_eduh_emp_rate
 	  cont_lchange_unemp_rate
 	  RealAnnualPI_3yrMADifference
 	  taxbenefits_dollarspercap
 	  house_price_runup
 	  ;
 	
 	local instrument_sumvars
 	  DOT_predict_instrument
 	  ED_instrument
 	  HHS_instrument
 	  ;
 	
 	#delimit cr;
 	
 	foreach var of varlist `dep_sumvars' {
 	summ `var' if time == `finaldate' &  state~=11
 	matrix dep_Summ = dep_Summ\(`r(mean)',`r(sd)' ,`r(min)', `r(max)', `r(N)' )	
 	}
 	
 	foreach var of varlist `explanatory_sumvars' {
 		summ `var' if time == `finaldate' &  state~=11
 		matrix explanatory_Summ = explanatory_Summ\(`r(mean)',`r(sd)' ,`r(min)', `r(max)', `r(N)' )	
 		}
 	
 	foreach var of varlist `instrument_sumvars' {
 		gen sum`var' = `var'
 		if "`var'" == "frac_house_committee" | "`var'" == "frac_sen_committee" { 
 			replace sum`var' = `var'
 		}
 		summ sum`var' if time == `finaldate' &  state~=11
 		drop sum`var'
 		matrix instrument_Summ = instrument_Summ\(`r(mean)',`r(sd)' ,`r(min)', `r(max)', `r(N)' )	
 	}
 		
 		
 	matrix dep_Summ = dep_Summ[2....,1....]
 	matrix explanatory_Summ = explanatory_Summ[2....,1....]
 	matrix instrument_Summ = instrument_Summ[2....,1....]
 	matrix colnames dep_Summ = Mean SD Min Max N
 	matrix colnames explanatory_Summ = Mean SD Min Max N
 	matrix colnames instrument_Summ = Mean SD Min Max N
 	
 	matrix rownames dep_Summ = `dep_sumvars'
 	matrix rownames explanatory_Summ = `explanatory_sumvars'
 	matrix rownames instrument_Summ = `instrument_sumvars'
 	
 	
 	#delimit ;
 	estout matrix(dep_Summ,fmt(4 4 4 4 0) ) 
	using results/Table3A.tex , style(tex) label substitute("dep_Summ" "") posthead("\hline \hline") replace;
 	estout matrix(explanatory_Summ,fmt(
 	  "%9.1fc %9.1fc %9.1fc 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 %9.1fc"
 	  "%9.1fc %9.1fc %9.1fc 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 %9.1fc"
 	  "%9.1fc %9.1fc %9.1fc 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 %9.1fc"
 	  "%9.1fc %9.1fc %9.1fc 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 %9.1fc"    
 	  0
 	  )
 	  ) using results/Table3B.tex , style(tex) label substitute("explanatory_Summ" "") posthead("\hline \hline") replace;
 	
 	estout matrix(instrument_Summ,fmt(
 	  "%9.1fc %9.3fc %9.1fc"
 	  "%9.3fc %9.3fc %9.1fc"
 	  "%9.3fc %9.3fc %9.1fc"
 	  0
 	  )
  	  ) using results/Table3C.tex , style(tex) label substitute("instrument_Summ" "" "Mill. " "") posthead("\hline \hline") replace;
 	#delimit cr;
	log close
 }
* Table 4
if 1==1 {
	quietly log using logs/table4.log, replace
	use $data, clear
	
	*** The latest data used in this file is as-of:
	
	summ time
	local finaldate = ym(2010,2)

	*** The default pre time period is February, 2009.
	local pre = ym(2009, 2)
	local pre_text = string(`pre', "%tmMonYY")
	local window = `finaldate' - `pre'

	*** Which would give the following number of months in the window between pre and post:
	display "Window is: "
	display `window'
	
	
	*** These are outputting options that I am using to output the tables.
	local eststaropts = "starlevels(\textbf .1)"
	local shortsub substitute("_star/"  )
	local estcell cells(_star & b(par({ }) label(\begin{math}\beta\end{math}) fmt(3) vacant("-")) _star & se( label(SE) par({( )}) fmt(3)))

	local controls RealAnnualPI_3yrMADifference taxbenefits_cap cont_drchange_emp_rate cont_lchange_emp_rate house_price_runup
	
	** I am going to use Thous per cap of stimulus for the first stage results ***	
		
	gen taxbenefits_cap_thousands = taxbenefits_cap*1000
	gen HHS_instrument_thousands = HHS_instrument/1000
	gen DOT_instrument_thousands = DOT_predict_instrument/1000
	
	
	foreach stimulus in obl ann pay {
		gen `stimulus'_lessDOL_thous_cap = `stimulus'_lessDOL_mill_cap*1000
		regress `stimulus'_lessDOL_thous_cap HHS_instrument_thousands DOT_instrument_thousands ED_instrument RealAnnualPI_3yrMADifference taxbenefits_cap_thousands cont_drchange_emp_rate cont_lchange_emp_rate house_price_runup if state~=11 & time == `finaldate'
		estimates store FirstStage_thous_`stimulus'
		drop `stimulus'_lessDOL_thous_cap
	}
	drop taxbenefits_cap_thousands HHS_instrument_thousands DOT_instrument_thousands
	
	foreach stimulus in obl ann pay {
	regress `stimulus'_lessDOL_mill_cap `instruments' `controls' if state~=11 & time == `finaldate'
	estimates store FirstStage_`stimulus'_controls
	}
	
	#delimit ;	

	estout FirstStage_thous_ann FirstStage_thous_obl FirstStage_thous_pay
		using results\Table4.tex,
			`eststaropts'
			`estcell'
			`shortsub'
			varlabels(
					HHS_instrument_thousands		"HHS instrument (thous. per cap)"
					ED_instrument					"ED instrument"
					DOT_instrument_thousands		"DOT instrument (thous. per cap)"
					RealAnnualPI_3yrMADifference   	"Change in PI Moving Average"
					taxbenefits_cap_thousands   	"Tax Benefits (thous. per cap)"
					cont_drchange_emp_rate      	"Dec07-Feb09 trend"
					cont_lchange_emp_rate			"Feb09 level"
					house_price_runup				"2003-2007 house price growth"
					_cons 							"Constant"	)
			stats(N r2, fmt(0 3) labels("N" "\begin{math}R^2\end{math}") )
			mlabels("Announcements (Thous. Per Cap)" "Obligations (Thous. Per Cap)" "Payments (Thous. Per Cap)")
			noabbrev
			style(tex)
			posthead("\hline \hline")
			prefoot("\hline \hline")
			replace
			;	
	#delimit cr;
	log close
} */
***
* Table 5
if 1==1 {

	quietly log using logs/table5.log, replace
	use $data, clear
	
	*** The latest data used in this file is as-of:
	
	summ time
	local finaldate = ym(2010,2)

	*** The default pre time period is February, 2009.
	local pre = ym(2009, 2)
	local pre_text = string(`pre', "%tmMonYY")
	local window = `finaldate' - `pre'

	*** EDITED BY RYAN STEED: need to recompute key vars for noise to take hold
	* did this in python
	/* drop *_lessDOL *_lessDOL_mill_cap *_Percap *3yrMADifference */
	/* gen PreStateEmployment_tmp = StateEmployment if time==ym(2009, 2)
	bysort state: egen PreStateEmployment = min(PreStateEmployment_tmp)
	gen change_emp_rate = (StateEmployment - PreStateEmployment)/popweight09 */
	qui: do "Program.3yrMAControls.do"
	qui: do "Program.ExcludingDOL.do"
	***

	*** Which would give the following number of months in the window between pre and post:
	display "Window is: "
	display `window'

	*** These are outputting options that I am using to output the tables.
	local eststaropts = "starlevels(\textbf .1)"
	local shortsub substitute("_star/"  )
	local estcell cells(_star & b(par({ }) label(\begin{math}\beta\end{math}) fmt(3) vacant("-")) _star & se( label(SE) par({( )}) fmt(3)))
	
	matrix Results_Partb = (0, 0, 0)

	foreach stimulus in obl_lessDOL_mill_cap ann_lessDOL_mill_cap pay_lessDOL_mill_cap {
			
			if "`stimulus'" == "obl_lessDOL_mill_cap" {
				local label = "Obl_"
			}
			if "`stimulus'" == "ann_lessDOL_mill_cap" {
				local label = "Ann_"
			}
			if "`stimulus'" == "pay_lessDOL_mill_cap" {
				local label = "Pay_"
			}
			
		* Do the OLS regression
		disp "Regressing change_emp_rate on `stimulus' and controls"
		reg change_emp_rate `stimulus' RealAnnualPI_3yrMADifference taxbenefits_cap cont*change_emp_rate house_price_runup if state~=11 & time == `finaldate' 
		estimates store reg_T_Emp_Rate_`label'_cer
		
		* Do the IV regression
		
		local instruments "HHS_instrument ED_instrument DOT_predict_instrument"	
		ivregress 2sls change_emp_rate (`stimulus' = `instruments') RealAnnualPI_3yrMADifference taxbenefits_cap cont*change_emp_rate house_price_runup if state ~= 11 & time == `finaldate' , first
		estimates store ivreg_T_Emp_Rate_`label'_cer		
		matrix Results_Partb = Results_Partb\(_b[`stimulus'], _se[`stimulus'], `e(N)')
		estat firststage
		estat overid
	}
	foreach stimulus in Ann Obl Pay {
		estimates restore ivreg_T_Emp_Rate_`stimulus'__cer
		estat firststage
		local F = r(mineig)
		estadd scalar F1 = `F'
		estat overid
		local J = r(p_sargan)
		estadd scalar J1 =`J'
	}	
	#delimit ;
		estout
		  reg_T_Emp_Rate_Ann__cer
		  ivreg_T_Emp_Rate_Ann__cer
		  reg_T_Emp_Rate_Obl__cer
		  ivreg_T_Emp_Rate_Obl__cer
		  reg_T_Emp_Rate_Pay__cer
		  ivreg_T_Emp_Rate_Pay__cer
		  using results\Table5.tex ,
		  order(ann* obl* pay*)
		  `eststaropts'
		  `estcell'
		  `shortsub'
		  label
		  varlabels(
		  obl_lessDOL_mill_cap 				"Obligations (Mill. Per Cap)"
		  ann_lessDOL_mill_cap 				"Announcements (Mill. Per Cap)"
		  pay_lessDOL_mill_cap 				"Payments (Mill. Per Cap)"
		  RealAnnualPI_3yrMADifference 		"Change in PI Moving Average"
		  taxbenefits_cap					"Tax Benefits (Mill. Per Cap)"
		  cont_drchange_emp_rate			"Dec07-Feb09 trend"
		  cont_lchange_emp_rate				"Feb09 level"  
		  house_price_runup					"2003-2007 house price growth"
		  _cons 							"Constant"	)
		  stats(N r2 F1 J1, fmt(0 3 3 3) labels("N" "\begin{math}R^2\end{math}" "Robust First-Stage F" "Overidentifying restrictions test (p-value)") )
		  mlabels("OLS" "IV" "OLS" "IV" "OLS" "IV")
		  noabbrev
		  style(tex)
		  posthead("\hline \hline")
		  prefoot("\hline \hline")
		  replace
		  ;
	#delimit cr;
	*** EDITED by Ryan Steed
	#delimit ;
	estout
		reg_T_Emp_Rate_Ann__cer
		ivreg_T_Emp_Rate_Ann__cer
		reg_T_Emp_Rate_Obl__cer
		ivreg_T_Emp_Rate_Obl__cer
		reg_T_Emp_Rate_Pay__cer
		ivreg_T_Emp_Rate_Pay__cer
		using ../results/Table5.csv ,
		cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace ;
	#delimit cr;
	***
	log close
}

*** Edited by RYAN STEED
exit
***

if 1==1 {
* Table 6
if 1==1{
	quietly log using logs/table6.log, replace
	use $data, clear
	
	local finaldate = ym(2010,2)	
	
	local instruments "HHS_instrument ED_instrument DOT_predict_instrument"		
	local controls RealAnnualPI_3yrMADifference taxbenefits_cap cont_drchange_emp_rate cont_lchange_emp_rate house_price_runup	
	local qcewcontrols RealAnnualPI_3yrMADifference taxbenefits_cap cont_drchange_qcew_nonfarm cont_lchange_qcew_nonfarm house_price_runup	
	local nooutliers state~=30 & state~=46 & state~=2 & state~=38 & state~=56	
		
	matrix TableSix = J(26,3,.)	
	local i = 0	
	foreach stimulus in ann_lessDOL_mill_cap obl_lessDOL_mill_cap pay_lessDOL_mill_cap {	
		local i = `i'+1	
		ivregress 2sls change_emp_rate (`stimulus' = `instruments') `controls' if state ~= 11 & time == `finaldate', first	
		matrix TableSix[1,`i'] = _b[`stimulus']	
		matrix TableSix[2,`i'] = _se[`stimulus']	
		ivregress 2sls change_emp_rate (`stimulus' = `instruments') if state ~= 11 & time == `finaldate', first	
		matrix TableSix[3,`i'] = _b[`stimulus']	
		matrix TableSix[4,`i'] = _se[`stimulus']	
		ivregress gmm change_emp_rate (`stimulus' = `instruments') `controls' StatePopulation if state ~= 11 & time == `finaldate', first	
		matrix TableSix[5,`i'] = _b[`stimulus']	
		matrix TableSix[6,`i'] = _se[`stimulus']	
		ivregress 2sls change_emp_rate (`stimulus' = `instruments') `controls' EdL if state ~= 11 & time == `finaldate', first	
		matrix TableSix[7,`i'] = _b[`stimulus']	
		matrix TableSix[8,`i'] = _se[`stimulus']
		ivregress gmm change_qcew_nonfarm (`stimulus' = `instruments' ) `qcewcontrols' if state ~= 11 & time == `finaldate' , first
		matrix TableSix[9,`i'] = _b[`stimulus']
		matrix TableSix[10,`i'] = _se[`stimulus']
		ivregress 2sls change_emp_rate (`stimulus' = `instruments') `controls' [aweight = weights] if state ~= 11 & time == `finaldate', first	
		matrix TableSix[11,`i'] = _b[`stimulus']	
		matrix TableSix[12,`i'] = _se[`stimulus']	
		ivregress 2sls change_emp_rate (`stimulus' = `instruments') `controls' if `nooutliers' & state ~= 11 & time == `finaldate', first
		matrix TableSix[13,`i'] = _b[`stimulus']
		matrix TableSix[14,`i'] = _se[`stimulus']
		ivregress 2sls change_emp_rate (`stimulus' = HHS_instrument DOT_predict_instrument) `controls' if state ~= 11 & time == `finaldate', first
		matrix TableSix[15,`i'] = _b[`stimulus']
		matrix TableSix[16,`i'] = _se[`stimulus']
		ivregress 2sls change_emp_rate (`stimulus' = ED_instrument DOT_predict_instrument) `controls' if state ~= 11 & time == `finaldate', first
		matrix TableSix[17,`i'] = _b[`stimulus']
		matrix TableSix[18,`i'] = _se[`stimulus']
		ivregress 2sls change_emp_rate (`stimulus' = HHS_instrument ED_instrument) `controls' if state ~= 11 & time == `finaldate', first
		matrix TableSix[19,`i'] = _b[`stimulus']
		matrix TableSix[20,`i'] = _se[`stimulus']
	}

	use $data_JanPre, clear
	local i = 0	
	foreach stimulus in ann_lessDOL_mill_cap obl_lessDOL_mill_cap pay_lessDOL_mill_cap {	
		local i = `i'+1	
		ivregress 2sls change_emp_rate (`stimulus' = `instruments') `controls' if state ~= 11 & time == `finaldate' , first
		matrix TableSix[21,`i'] = _b[`stimulus']
		matrix TableSix[22,`i'] = _se[`stimulus']
	}
	use $data_DecPre, clear
	local i = 0	
	foreach stimulus in ann_lessDOL_mill_cap obl_lessDOL_mill_cap pay_lessDOL_mill_cap {
		local i = `i'+1	
		ivregress 2sls change_emp_rate (`stimulus' = `instruments') `controls' if state ~= 11 & time == `finaldate' , first
		matrix TableSix[23,`i'] = _b[`stimulus']
		matrix TableSix[24,`i'] = _se[`stimulus']
	}
	use $data_NovPre, clear
	local i = 0	
	foreach stimulus in ann_lessDOL_mill_cap obl_lessDOL_mill_cap pay_lessDOL_mill_cap {
		local i = `i'+1	
		ivregress 2sls change_emp_rate (`stimulus' = `instruments') `controls' if state ~= 11 & time == `finaldate' , first
		matrix TableSix[25,`i'] = _b[`stimulus']
		matrix TableSix[26,`i'] = _se[`stimulus']
	}
	
	
	matrix colnames TableSix = "Announcements" "Obligations" "Payments"
	#delimit ;
	matrix rownames TableSix = 	"Baseline" "stderr "
								"No controls"  "stderr "
								"Control for population"  "stderr "
								"Control for industry composition"  "stderr "
								"BLS sampling weights" "stderr "
								"QCEW" "stderr "
								"Drop outliers (MT,SD,AK,ND,WY)" "stderr "
								"Drop ED instrument" "stderr "
								"Drop HHS instrument" "stderr "
								"Drop DOT instrument" "stderr "
								"Jan 09" "stderr "
								"Dec 08" "stderr "
								"Nov 08" "stderr "		;
	estout matrix(TableSix, fmt(3 3 3) ) 
		using results\Table6.tex, style(tex) posthead("\hline \hline") 
		substitute(	"stderr " "" 
					"Jan 09" "\hline Sensitivity to choice of pre-treatment period & & & \\ \hline Jan09" 
					"Drop ED instrument" "\hline Sensitivity to Instruments & & & \\ \hline Drop ED instrument"	
					"TableSix" " "	
					"Payments\\" "Payments\\ & \begin{math}\beta\end{math} /SE & \begin{math}\beta\end{math} /SE & \begin{math}\beta\end{math} /SE \\")
		replace;
	#delimit cr;	
	log close
}
* Table 7
if 1==1 {
	quietly log using logs/table7.log, replace
	use $data, clear

	* The latest data used in this file is as-of:
	summ time
	local finaldate = ym(2010,2)
	
	* The default pre time period is February, 2009.
	local pre = ym(2009, 2)
	local pre_text = string(`pre', "%tmMonYY")
	local window = `finaldate' - `pre'
		
	* Which would give the following number of months in the window between pre and post:
	display "Window is: "
	display `window'

	*** These are outputting options that I am using to output the tables.
	local eststaropts = "starlevels(\textbf .1)"
	local longsub substitute("            &_star/\begin{math}\beta\end{math}/_star/SE/F&_star/\begin{math}\beta\end{math}/_star/SE/F&_star/\begin{math}\beta\end{math}/_star/SE/F&_star/\begin{math}\beta\end{math}/_star/SE/F&_star/\begin{math}\beta\end{math}/_star/SE/F&_star/\begin{math}\beta\end{math}/_star/SE/F\\"  )
	local estcellF cells(_star & b(par({ }) label(\begin{math}\beta\end{math}) fmt(3) vacant("-")) _star & se( label(SE/F) par({( )}) fmt(3)))

	local index = 1
	* Do baseline regression (with Formulary Factor instruments)
	foreach depvar in change_emp_rate change_govt_emp_rate change_priv_emp_rate change_localgov_emp_rate change_cons_emp_rate change_manu_emp_rate change_eduh_emp_rate{
		if "`depvar'" == "change_manu_emp_rate" {
			local depvarlabel = "M_Emp_Rate_"
			}
		if "`depvar'" == "change_eduh_emp_rate" {
			local depvarlabel = "E_Emp_Rate_"
			}
		if "`depvar'" == "change_emp_rate" {
			local depvarlabel = "T_Emp_Rate_"
			}
		if "`depvar'" == "change_govt_emp_rate" {
			local depvarlabel = "G_Emp_Rate_"
			}
		if "`depvar'" == "change_priv_emp_rate" {
			local depvarlabel = "P_Emp_Rate_"
			}
		if "`depvar'" == "change_localgov_emp_rate" {
			local depvarlabel = "L_Emp_Rate_"
			}
		if "`depvar'" == "change_cons_emp_rate" {
			local depvarlabel = "C_Emp_Rate_"
			}
		foreach stimulus in obl_lessDOL_mill_cap ann_lessDOL_mill_cap pay_lessDOL_mill_cap {
			if "`stimulus'" == "obl_lessDOL_mill_cap" {
				local label = "Obl_"
				}
			if "`stimulus'" == "ann_lessDOL_mill_cap" {
				local label = "Ann_"
				}
			if "`stimulus'" == "pay_lessDOL_mill_cap" {
				local label = "Pay_"
				}		
			disp "Regressing `depvar' on `stimulus' ONLY"
			* Do the IV regression
			local instruments "HHS_instrument ED_instrument DOT_predict_instrument"
			ivregress 2sls `depvar' (`stimulus' = `instruments') RealAnnualPI_3yrMADifference taxbenefits_cap house_price_runup cont*`depvar' if state ~= 11 & time == `finaldate' , first
			estimates store ivreg_`depvarlabel'_`label'_xdol
			estat firststage
			local F = r(mineig)
			estat overid
			local Jp = r(p_sargan)
			estadd scalar F1 = `F'
			estadd scalar Jp = `Jp'
		}
	}
	
	* Make the table.
	#delimit ;
	estout ivreg_T_Emp_Rate__Ann__xdol ivreg_P_Emp_Rate__Ann__xdol ivreg_L_Emp_Rate__Ann__xdol ivreg_C_Emp_Rate__Ann__xdol ivreg_M_Emp_Rate__Ann__xdol ivreg_E_Emp_Rate__Ann__xdol
	using results/Table7.tex
	  , keep(ann*) 
	  mlabels("Total Nonfarm" "Private Nonfarm" "S\&L Govt" "Construction" "Manufacturing" "Educ. \& Health") varlabels(ann_lessDOL_mill_cap "\multirow{2}{1in}{Announcements (Mill. Per Cap)}") replace style(tex) unstack
	  posthead("\hline \hline")
	  `eststaropts'
	  `estcellF'
	  `shortsub'
	  stats(F1,  fmt(3) labels(" ") layout(\emph{@}))
		  ;
	
	estout ivreg_T_Emp_Rate__Obl__xdol ivreg_P_Emp_Rate__Obl__xdol ivreg_L_Emp_Rate__Obl__xdol ivreg_C_Emp_Rate__Obl__xdol ivreg_M_Emp_Rate__Obl__xdol ivreg_E_Emp_Rate__Obl__xdol
		  using results/Table7.tex
	  , mlabels(none) keep(obl*) 
	  varlabels(obl_lessDOL_mill_cap "\multirow{2}{1in}{Obligations (Mill. Per Cap)}") append style(tex) unstack
	  `eststaropts'
	  `estcellF'
	  `longsub'
	  posthead("\\")
	  stats(F1,  fmt(3) labels(" ") layout(\emph{@}))
	  ;	
	
	estout ivreg_T_Emp_Rate__Pay__xdol ivreg_P_Emp_Rate__Pay__xdol ivreg_L_Emp_Rate__Pay__xdol ivreg_C_Emp_Rate__Pay__xdol ivreg_M_Emp_Rate__Pay__xdol ivreg_E_Emp_Rate__Pay__xdol
		  using results/Table7.tex
	  , mlabels(none) keep(pay*) 
	  varlabels(pay_lessDOL_mill_cap "\multirow{2}{1in}{Payments (Mill. Per Cap)}") append style(tex) unstack
	  `eststaropts'
	  `estcellF'
	  `longsub'
	  posthead("\\")
	  stats(F1,  fmt(3) labels(" ") layout(\emph{@}))
		  ;
	#delimit cr;
	log close
}
* Figure 2
if 1==1 {
	quietly log using logs/figure2.log, replace
	use $data_Full, clear

	local enddate = ym(2011,3)

	gen obligations   = 0
	gen obligations_lessdol = 0
	gen payments      = 0
	gen payments_lessdol = 0
	gen announcements = 0
	gen announcements_lessdol = 0
	
	qui: desc finaltotalobl_dlr*, varlist
	foreach variable in `r(varlist)' {
		replace obligations = obligations + `variable' if `variable' ~= .
		replace obligations_lessdol = obligations_lessdol + `variable' if `variable' ~= . & `variable' ~= finaltotalobl_dlrDOL
		}
	
	qui: desc finaltotalpd_dlr*, varlist
	foreach variable in `r(varlist)' {
		replace payments = payments + `variable' if `variable' ~= .
		replace payments_lessdol = payments_lessdol + `variable' if `variable' ~= . & `variable' ~= finaltotalpd_dlrDOL
		}
	
	qui: desc Announced*, varlist
	foreach variable in `r(varlist)'{
		replace announcements = announcements + `variable' if `variable' ~= .
		replace announcements_lessdol = announcements_lessdol + `variable' if `variable' ~= . & `variable' ~= AnnouncedDOL
		}
	gen time_2 = dofm(time)
	drop time
	rename time_2 time
	format %td time
	format %20.0gc announcements* obligations* payments*
	
	*For all of these displays I am excluding Washington, D.C.
	
	drop if state == 11
	
	sort time
	collapse (sum) announcements_lessdol obligations_lessdol payments_lessdol , by(time)
	label variable announcements_lessdol "Announcements (Less DOL)"
	label variable obligations_lessdol "Obligations (Less DOL)"
	label variable payments_lessdol "Payments (Less DOL)"
	
	foreach var in announcements_lessdol obligations_lessdol payments_lessdol {
		replace `var' = `var'/1000000000
	}
	
	replace announcements_lessdol = . if time < mdy(8,1,2009)
	gen y = year(time)
	gen m = month(time)
	gen date = ym(y,m)
	format date %tm
	keep if date>tm(2009m3) & date <= `enddate'
	tsset date, monthly
	#delimit ;
		twoway 
		(tsline announcements_lessdol,  lpattern(solid) lwidth("0.4"))
		(tsline obligations_lessdol, lpattern(solid) lwidth("0.4"))
		(tsline payments_lessdol, lpattern(solid) lwidth("0.4")),
		legend(order(1 2 3))
		yscale(range(0 350))
		ylabel(0(50)350)
		ytitle("Billions ($)")
		graphregion(lcolor(white) fcolor(white) ilcolor(white) margin("r+3.25"));
	graph export results/Figure2.eps, replace;
	#delimit cr
	log close
}


* Figure 3
if 1==1 {
	quietly log using logs/figure3.log, replace
	use $data, clear

	*** The latest data used in this file is as-of:

	summ time
	local finaldate = ym(2010,2)
	
	*** The default pre time period is February, 2009.
	local pre = ym(2009, 2)
	local pre_text = string(`pre', "%tmMonYY")
	local window = `finaldate' - `pre'
	
	*** Which would give the following number of months in the window between pre and post:
	display "Window is: "
	display `window'

	* Regress stimulus on instruments to create fitted values for each stimulus measure *
	
	local instruments "HHS_instrument ED_instrument DOT_predict_instrument"
	
	foreach stimulus in obl_cap ann_cap pay_cap {
		regress `stimulus' `instruments' if time==tm(2010m2) & state~=11
		predict `stimulus'_predict if e(sample), xb
		bysort state: egen `stimulus'_predicted = min(`stimulus'_predict)
	}
	sort state time
	tempfile temp1
	save `temp1'
	keep if time==ym(2010,2) & state~=11
	
	foreach stimulus in obl_cap ann_cap pay_cap {
		egen `stimulus'_predicted_rank=rank(`stimulus'_predicted)
		gen topmax_`stimulus' = 1 if `stimulus'_predicted_rank==50
		gen topmin_`stimulus' = 1 if `stimulus'_predicted_rank==41
		gen bottommax_`stimulus' = 1 if `stimulus'_predicted_rank==10
		gen bottommin_`stimulus' = 1 if `stimulus'_predicted_rank==1
		gen quintile_`stimulus'=1 if inrange(`stimulus'_predicted_rank, 41, 50)
		replace quintile_`stimulus'=2 if inrange(`stimulus'_predicted_rank, 31, 40)
		replace quintile_`stimulus'=3 if inrange(`stimulus'_predicted_rank, 21, 30)
		replace quintile_`stimulus'=4 if inrange(`stimulus'_predicted_rank, 11, 20)
		replace quintile_`stimulus'=5 if inrange(`stimulus'_predicted_rank, 1, 10)
	}
	keep state *_predicted *_predicted_rank quintile* top* bottom*
	sort state
	tempfile predicted_stimulus_ranks
	save `predicted_stimulus_ranks'
	
	use `temp1', clear
	merge m:1 state using `predicted_stimulus_ranks'
	tab _merge
	keep if _merge==3 | _merge==1
	drop _merge
	
	sort state
	
	sort state time
	drop if state==11
	
	renpfix quintile_obl_cap quintile_obl
	renpfix quintile_ann_cap quintile_ann
	renpfix quintile_pay_cap quintile_pay
	
	keep if inrange(time, ym(2006,12),ym(2011,4)) & state~=11
	sort time
	
	keep state time StateEmployment quintile* top* bottom* popweight* RealAnnualPI_3yrMADifference taxbenefits_cap house_price_runup cont_lchange_emp_rate cont_drchange_emp_rate
	
	* Generate change in employment from Feb09 to current month(T)
	gen PreStateEmployment_tmp = StateEmployment if time==`pre'
	bysort state: egen PreStateEmployment = min(PreStateEmployment_tmp)
	gen change_emp_rate = (StateEmployment - PreStateEmployment)/popweight09
	
	gen emp_ratio = StateEmployment/popweight09
	
	* Generate state employment scaled by state's average 2008 level
	bysort state: egen temp1 = mean(StateEmployment) if inrange(time,tm(2008m1),tm(2008m12))
	bysort state: egen temp2 = min(temp1)
	gen employment_scaled=StateEmployment/temp2
	drop temp1-temp2
	
	foreach stimulus in obl pay ann	{
		sort time quintile_`stimulus'
		forvalues quintile=1/5 {
			by time quintile_`stimulus': egen employment_`stimulus'`quintile'=median(employment_scaled) if quintile_`stimulus'==`quintile'
		}
		gen employment_`stimulus'1_u = StateEmployment if topmax_`stimulus' == 1
		gen employment_`stimulus'1_l = StateEmployment if topmin_`stimulus' == 1
		gen employment_`stimulus'5_u = StateEmployment if bottommax_`stimulus' == 1
		gen employment_`stimulus'5_l = StateEmployment if bottommin_`stimulus' == 1
	}

	collapse (mean) employment* , by(time)

	drop if time<tm(2007m12)
	
	label var employment_ann1 "Top Quintile"
	label var employment_ann5 "Bottom Quintile"
	#delimit ;
	tsline employment_ann1 employment_ann5, l1title(Employment (scaled by 2008 average)) 
		title("Median Employment by Quintile of Predicted ARRA Announcements", size(medsmall) span) 
		legend(cols(1) symplacement(left) symxsize(12) forcesize rowgap(5)) tline(2009m2);
	# delimit cr;
	graph export results\Figure3.eps, replace
	log close
}
* Figure 4
if 1==1 {
	quietly log using logs/figure4.log, replace
	use $data, clear

	local instruments "HHS_instrument ED_instrument DOT_predict_instrument"
	foreach stimulus in obl_cap ann_cap pay_cap {
		regress `stimulus' `instruments' if time==tm(2010m2) & state~=11
		predict `stimulus'_predict if e(sample), xb
		bysort state: egen `stimulus'_predicted = min(`stimulus'_predict)
	}

	decode state, generate(statelabel)
	gen stateabbr = substr(statelabel,1,2)
	
	local markeropts msymbol(none) mlabel(stateabbr) mlabposition(0) mlabcolor(blue)
	
	#delimit ;
	graph twoway (lfit change_emp_rate ann_cap_predicted, lcolor(red)) (scatter change_emp_rate ann_cap_predicted, `markeropts') 
		if state ~= 11 & time == tm(2010m2),
		ytitle(Change in Employment-Pop Ratio) xtitle(Predicted Announcements Per Capita) legend(off);
	graph export results\Figure4.eps, replace;
	#delimit cr;
	log close
}	
* Figure 5
if 1==1 {
log using logs/figure5.log, replace
use $data_Full, clear
gen obligations   = 0
gen obligations_lessdol = 0
gen payments      = 0
gen payments_lessdol = 0
gen announcements = 0
gen announcements_lessdol = 0

qui: desc finaltotalobl_dlr*, varlist
foreach variable in `r(varlist)' {
	replace obligations = obligations + `variable' if `variable' ~= .
	replace obligations_lessdol = obligations_lessdol + `variable' if `variable' ~= . & `variable' ~= finaltotalobl_dlrDOL
	}

qui: desc finaltotalpd_dlr*, varlist
foreach variable in `r(varlist)' {
	replace payments = payments + `variable' if `variable' ~= .
	replace payments_lessdol = payments_lessdol + `variable' if `variable' ~= . & `variable' ~= finaltotalpd_dlrDOL
	}

qui: desc Announced*, varlist
foreach variable in `r(varlist)'{
	replace announcements = announcements + `variable' if `variable' ~= .
	replace announcements_lessdol = announcements_lessdol + `variable' if `variable' ~= . & `variable' ~= AnnouncedDOL
	}

generate obligations_percapita   = obligations   / (StatePopulation*1000)
generate payments_percapita      = payments      / (StatePopulation*1000)
generate announcements_percapita = announcements / (StatePopulation*1000)

generate obl_percapita_lessdol = obligations_lessdol / (StatePopulation*1000)
generate pd_percapita_lessdol  = payments_lessdol / (StatePopulation*1000)
generate ann_percapita_lessdol = announcements_lessdol / (StatePopulation*1000)

label variable obligations_percapita "Per-Capita Obligations"
label variable announcements_percapita "Per-Capita Announcements"
label variable payments_percapita "Per-Capita Payments to States"

sort state time
#delimit ;
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


gen announced_other = 0;
gen announced_dol = AnnouncedDOL;
gen announced_dot = AnnouncedDOT;
gen announced_ed  = AnnouncedED;
gen announced_hhs = AnnouncedHHS;
  
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
	replace announced_other = announced_other + `annvar' if `annvar' ~= .;
	};

#delimit cr;

* Get the per-capita amounts ...

foreach variable of varlist *_other *_hhs *_dol *_dot *_ed {
	gen `variable'_percap = `variable'/(StatePopulation*1000)
	}


gen time_2 = dofm(time)
drop time
rename time_2 time
format %td time
format %20.0gc announcements* obligations* payments*
local savefile = "tmp_displays"

sort time

collapse (sum) announcements_lessdol obligations_lessdol payments_lessdol , by(time)
label variable announcements_lessdol "Announcements (Less DOL)"
label variable obligations_lessdol "Obligations (Less DOL)"
label variable payments_lessdol "Payments (Less DOL)"

foreach var in announcements_lessdol obligations_lessdol payments_lessdol {
	replace `var' = `var'/1000000000
}

replace announcements_lessdol = . if time < mdy(8,1,2009)
rename announcements_lessdol Announced
rename obligations_lessdol Obligated
rename payments_lessdol	Paid
keep time Announced Obligated Paid
gen time_2 = mofd(time)
drop time
rename time_2 time
format time %tm
sort time
tempfile AmountsOverTime
save `AmountsOverTime'

local date1 = ym(2009,5)
use $data_Full, replace
summ time
*date2 is the ending final date.
local date2 = ym(2011,3)
clear
disp "Ending date is:"
disp %tm `date2'
local window = `date1' - `date2'


matrix Estimates = J(25,25,.)
matrix SE        = J(25,25,.)

matrix Estimates_endo = J(1,22,0)
matrix SE_endo        = J(1,22,0)

matrix Estimates_misc = J(1,22,0)
matrix SE_misc        = J(1,22,0)

matrix Estimates_exo = J(1,22,0)
matrix SE_exo        = J(1,22,0)

local i = 1
forvalues x = `date1'/`date2' {
	matrix EstVec = 0
	matrix SEVec  = 0 
	matrix EstEndo = 0
	matrix SEEndo  = 0
	matrix EstMisc = 0
	matrix SEMisc  = 0
	matrix EstExo  = 0
	matrix SEExo   = 0
	disp "`x'"
	use $data_Full, replace
	local finaldate = `x'
	
	local pre = ym(2009, 2)

	local window = `finaldate' - `pre'
	*Which would give the following number of months in the window between pre and post:
	display `window'

	
	* Fix the Social Security Amounts.
	qui: FixSSA `pre'

	*Dropping some unneccessary variables
	*To make things clearer in the final dataset I am dropping the marginal changes in obligations and outlays per month
	drop *month*
	
	*  Make State GSP per capita
	qui: do Program.StateGSPPerCapita.do
	
	
	* Make Expected Payroll Employment
	ExpectedPayrollEmployment `window' `finaldate'

	*Before I drop the observations that are neither pre or post, I should make a percent change in the outcome variable
	*for April, an alternative pre period.

	gen StateEmployment_apr = StateEmployment/StatePopulation if time == ym(2009, 4)
	by state: egen StateEmployment_apr_min = min(StateEmployment_apr)
	drop StateEmployment_apr

	gen pctchange_nonfarm_employment_apr = ln(StateEmployment) - ln(StateEmployment_apr_min)
	gen change_emp_rate_apr = StateEmployment/StatePopulation - StateEmployment_apr_min
	drop StateEmployment_apr_min

	*Also, as an additional control variable, I'm making a variable that is the change in the employment rate from pre-14 to pre, taking
	*pre to be february 2009.

	gen change_emp_rate_pre_14 = StateEmployment/StatePopulation - L14.StateEmployment/L14.StatePopulation if time == `pre'

	by state: egen change_emp_rate_pre_14_min = min(change_emp_rate_pre_14)
	drop change_emp_rate_pre_14
	rename change_emp_rate_pre_14 change_emp_rate_pre

	gen taxbenefits_cap = taxbenefits/(1000000*(StatePopulation*1000))
	label variable taxbenefits_cap "Tax Benefits (Mill. per cap)"
	
	* * * *Control Variables for trends * * * *
	*In this section, I am generating control variables that will incorporate movements and trends in employment
	*before the initial ARRA bill.
	*I am also making sure that these control variables match the dependent variable employment rate.
	*For example if the dependent variable is change in \emph{government} employment rate
	*then the control variable will deal with trends of \emph{government} employment.
	*The dependent variables that I have to match are
	*\verb=change_emp_rate change_govt_emp_rate=
	*\verb=change_priv_emp_rate change_localgov_emp_rate change_cons_emp_rate=.
	*So for each one I am going to name the ratio control variable \verb=cont_drat_(variable)=.
	*The variable as of February 2008 will be named \verb=cont_level_(variable)=.
	foreach emplevel of varlist StateEmployment StateTotGovEmployment StateLocalEmployment StatePrivEmp LCONSA StateUnemployment LMANUA LEDUHA{
		gen tmp_empratio = `emplevel'/StatePopulation
		gen _tmp_tc1 = tmp_empratio if time == ym(2007, 12)
		gen _tmp_tc2 = tmp_empratio if time == `pre'
		bysort state: egen nonmissing_tmp_tc1 = min(_tmp_tc1)
		bysort state: egen nonmissing_tmp_tc2 = min(_tmp_tc2)
		gen control_`emplevel' = (nonmissing_tmp_tc2 - nonmissing_tmp_tc1)
		drop _tmp_tc1 _tmp_tc2 nonmissing_tmp_tc1 nonmissing_tmp_tc2
		gen _tmp_tc1 = tmp_empratio if time == `pre'
		bysort state: egen c_level_`emplevel' = min(_tmp_tc1)
		drop _tmp_tc1 tmp_empratio	
		}
	rename control_StateEmployment cont_drchange_emp_rate
	rename control_StateTotGovEmployment cont_drchange_govt_emp_rate
	rename control_StateLocalEmployment cont_drchange_localgov_emp_rate
	rename control_StatePrivEmp cont_drchange_priv_emp_rate
	rename control_LCONSA cont_drchange_cons_emp_rate
	rename control_LMANUA cont_drchange_manu_emp_rate
	rename control_LEDUHA cont_drchange_eduh_emp_rate

	gen _tmp_unemployment_tc1 = StateUnemployment/100 if time == ym(2007,12)
	gen _tmp_unemployment_tc2 = StateUnemployment/100 if time == `pre'
	bysort state: egen nonmissing_tmp_tc1 = min(_tmp_unemployment_tc1)
	bysort state: egen nonmissing_tmp_tc2 = min(_tmp_unemployment_tc2)
	gen cont_drchange_unemp_rate = nonmissing_tmp_tc2 - nonmissing_tmp_tc1
	gen cont_lchange_unemp_rate = nonmissing_tmp_tc2
	drop _tmp_unemployment_tc1 _tmp_unemployment_tc2

	rename c_level_StateEmployment cont_lchange_emp_rate
	rename c_level_StateTotGovEmployment cont_lchange_govt_emp_rate
	rename c_level_StateLocalEmployment cont_lchange_localgov_emp_rate
	rename c_level_StatePrivEmp cont_lchange_priv_emp_rate
	rename c_level_LCONSA cont_lchange_cons_emp_rate
	rename c_level_LMANUA cont_lchange_manu_emp_rate
	rename c_level_LEDUHA cont_lchange_eduh_emp_rate	

	label variable cont_drchange_emp_rate "Change in the total employment-population ratio from Dec. 2007 to Feb. 2009"
	label variable cont_lchange_emp_rate  "Level of total employment-population ratio as of Feb. 2009"

	label variable cont_drchange_govt_emp_rate "Change in government  employment-population ratio from Dec. 2007 to Feb. 2009"
	label variable cont_lchange_govt_emp_rate  "Level of government employment-population ratio as of Feb. 2009"

	label variable cont_drchange_localgov_emp_rate "Change in local govt employment-population ratio from Dec. 2007 to Feb. 2009"
	label variable cont_lchange_localgov_emp_rate  "Level of local govt employment-population ratio as of Feb. 2009"

	label variable cont_drchange_priv_emp_rate "Change in private employment-population ratio from Dec. 2007 to Feb. 2009"
	label variable cont_lchange_priv_emp_rate  "Level of private employment-population ratio as of Feb. 2009"

	label variable cont_drchange_cons_emp_rate "Change in construction employment-population ratio from Dec. 2007 to Feb. 2009"
	label variable cont_lchange_cons_emp_rate "Level of construction employment-population as of Feb. 2009"
	
	label variable cont_drchange_manu_emp_rate "Change in manufacturing employment-population ratio from Dec. 2007 (SA)"
	label variable cont_lchange_manu_emp_rate "Level of manufacturing employment-population as of Feb. 2009 (SA)"
	
	label variable cont_drchange_eduh_emp_rate "Change in educational and health employment-population ratio from Dec. 2007 (SA)"
	label variable cont_lchange_eduh_emp_rate "Level of educational and health employment-population ratio as of Feb. 2009 (SA)"

	label variable cont_drchange_unemp_rate "Change in Unemployment from Dec. 2007 to Feb. 2009"
	label variable cont_lchange_unemp_rate "Level of Unemployment as of Feb. 2009"

	*** Generate growth in house prices from 2002m12 - 2007m12 as the "house price run-up" control variable
	gen tmp_HPI_1 = StateHPI if time == tm(2002m12)
	gen tmp_HPI_2 = StateHPI if time == tm(2007m12)
	bysort state: egen nonmissing_tmp_HPI_1 = min(tmp_HPI_1)
	bysort state: egen nonmissing_tmp_HPI_2 = min(tmp_HPI_2)
	gen house_price_runup = nonmissing_tmp_HPI_2/nonmissing_tmp_HPI_1 - 1 
	label variable house_price_runup "Growth rate in FHFA house price index from 2002m12 - 2007m12"
	drop tmp_HPI* nonmissing_tmp*



	* Formulary Factors instruments
	gen HHS_instrument = medicaid_fy2007/(StatePopulation*1000) if time == ym(2009,1)
	bysort state: egen HHS_instrument2 = min(HHS_instrument)
	drop HHS_instrument
	rename HHS_instrument2 HHS_instrument
	
	reg DOT_Obligations dot_taxpayments dot_vehiclemiles dot_lanemiles dot_obligationlimitation if state ~= 11 & time == `finaldate'
	predict DOT_predict, xb
	gen DOT_predict_instrument = DOT_predict/(StatePopulation*1000)
	
	bysort state: egen DOT_Instrument = min(DOT_Obligations/(StatePopulation*1000))
	
	foreach factor in dot_taxpayments dot_vehiclemiles dot_lanemiles dot_obligationlimitation {
	  gen `factor'_cap = `factor'/StatePopulation
	  }
	
	bysort time: egen sum_all_schoolage = total(school_age_pop)
	by time: egen sum_all_statepop = total(StatePopulation)
	gen frac_school_age = school_age_pop/sum_all_schoolage if time == ym(2008,1)
	gen school_age_pop1 = school_age_pop if time == ym(2008,1)
	gen frac_statepop = StatePopulation/sum_all_statepop if time == ym(2008,1)
	bysort state: egen hhs_frac_school = min(frac_school_age)
	bysort state: egen hhs_school_age = min(school_age_pop1)
	by state: egen hhs_frac_statepop = min(frac_statepop)
	*gen ED_instrument = (.61*(hhs_frac_school) + .39*(hhs_frac_statepop))/StatePopulation
	gen ED_instrument = hhs_school_age/StatePopulation


	*********************************************************
	* Make the three-year MA control variables (GSP and PI) *
	*********************************************************

	do Program.3yrMAControls.do
	
	*After this, I drop all of the observations that are not in the pre or post time period.
	drop if time ~= `pre' & time ~= `finaldate'
	
	* Sum the ARRA spending over agencies.
	qui: do Program.ARRASpending.do

	* Generate measures excluding DOL.
	qui: do Program.ExcludingDOL.do


	* Categorize spending into endogenous/exogenous groups based on agencies.
	qui: do Program.SpendingCategories.do

	*Fill in missing values for announcements variables for end-months prior to first month of data (8/2009)
	foreach ag in hhs dot ed dol {
	  replace ann_`ag'_percap_mill = ann_other_percap_mill*runiform() if time==`finaldate'
	  }

	gen EdLrate = EdL/StatePopulation
	sort state time
	
	* * * * Dependent Variables - With Construction * * * *
	*So we define our dependent variable here as:
	*\begin{displaymath}
	*\frac{\mbox{Emp}_{i,t} - \mbox{Emp}_{i,t-L}}{\mbox{Pop}}
	*\end{displaymath}

	*Because our variable of interest will be expressed as Millions of dollars of stimulus funds per million.
	*Hence
	*\begin{eqnarray*}
	*\frac{\mbox{Emp}_{i,t} - \mbox{Emp}_{i,t-L}}{\mbox{Pop}} &= \alpha \frac{\mbox{Mills}}{\mbox{Pop}} \\
	*\mbox{Emp}_{i,t} - \mbox{Emp}_{i,t-L} &= \alpha \mbox{Mills}	
	*\end{eqnarray*}
	*So we have alpha as being the impact of one million dollars of stimulus funding on a state's change in employment level.
	*Of course, we are defining a number of dependent variables here.
	*Perhaps I will clean this code up and remove defunct dependent variables.

	
	sort state time
	gen pre_announcements_percapita = announcements_percapita[_n-1] if state == state[_n-1]
	gen pctchange_nonfarm_employment = ln(StateEmployment) - ln(StateEmployment[_n-1]) if state == state[_n-1]
	gen change_emp_rate = StateEmployment/StatePopulation - StateEmployment[_n-1]/StatePopulation[_n-1]  if state == state[_n-1]

	*Change in construction employment.

	
	gen change_cons_emp_rate = LCONS/StatePopulation - LCONS[_n-1]/StatePopulation[_n-1] if state == state[_n-1]
	gen change_manu_emp_rate = LMANUA/StatePopulation - LMANUA[_n-1]/StatePopulation[_n-1] if state == state[_n-1]
	gen change_eduh_emp_rate = LEDUHA/StatePopulation - LEDUHA[_n-1]/StatePopulation[_n-1] if state == state[_n-1]
	

	*Change in  gov't employment , for both state and local and overall government.

	
	gen change_govt_emp_rate = StateTotGovEmployment/StatePopulation - StateTotGovEmployment[_n-1]/StatePopulation[_n-1] if state == state[_n-1]
	gen change_localgov_emp_rate = StateLocalEmployment/StatePopulation - StateLocalEmployment[_n-1]/StatePopulation[_n-1] if state == state[_n-1]
	

	*Change in private employment (total - government)

	*Note that some states have a separate series for private employment, however not all states do. I am constructing it as the difference between
	*total and government spending for all states. I can change this if neccessary.

	
	gen StatePrivEmp = StateEmployment - StateTotGovEmployment
	gen change_priv_emp_rate = StatePrivEmp/StatePopulation - StatePrivEmp[_n-1]/StatePopulation[_n-1] if state == state[_n-1]
	

	*Change in unemployment rate

	
	gen change_unemp_rate = (StateUnemployment - StateUnemployment[_n-1])/100
	

	gen ln_obligations_percapita = ln(obligations_percapita)
	gen ln_pre_announcements_percapita = ln(pre_announcements_percapita)

	/* this is just to see the percentage of state & local to total government */
	gen pctg_of_statelocal_to_total  = 100*(StateLocalEmployment / StateTotGovEmployment) if state == state[_n-1]

	*Employment Rate Specification

	*In this section I'm doing OLS and IV for each of the stimulus variables for the new dependent variables, for the employment rate specification.
	*(Winner from part B).
	*The parenthesis indicate the suffix that is appended to the estimates when the estimates are stored.
	*I am using these codes to output the cleaned-up results that we need.

	
	gen double obl_mill_cap = obligations_percapita/1000000
	gen double pay_mill_cap = payments_percapita/1000000
	gen double ann_mill_cap = announcements_percapita/1000000

	local j = 1
	*Change in the Employment Rate (cer)	
	* Some early months will have missing announcements.
	* I  just want to make these announcements equal to zero.
	replace ann_lessDOL_mill_cap = 0 if ann_lessDOL_mill_cap == .
	
	/* Generate Instruments */

		foreach stimulus in obl_lessDOL_mill_cap ann_lessDOL_mill_cap pay_lessDOL_mill_cap {
			if "`stimulus'" == "obl_lessDOL_mill_cap" {
				local label = "Obl"
				}
			if "`stimulus'" == "ann_lessDOL_mill_cap" {
				local label = "Ann"
				}
			if "`stimulus'" == "pay_lessDOL_mill_cap" {
				local label = "Pay"
				}				
			local instruments "HHS_instrument ED_instrument DOT_predict_instrument"
			ivregress 2sls change_emp_rate (`stimulus' = `instruments') RealAnnualPI_3yrMADifference taxbenefits_cap cont*change_emp_rate house_price_runup if state ~= 11 & time == `finaldate' , first
			matrix Estimates[`i',`j'] = _b[`stimulus']
			matrix SE[`i',`j'] = _se[`stimulus']
			local j = `j' + 1
					}
	estimates clear
	local i = `i'+1
}

svmat Estimates
rename Estimates1 Obligations
rename Estimates2 Announcements
rename Estimates3 Payments
keep Obligations Announcements Payments
gen time = tm(2009m4) + _n
format time %tm
sort time
tempfile coefficients
save `coefficients'

svmat SE
rename SE1 seObligations
rename SE2 seAnnouncements
rename SE3 sePayments
keep se*
gen time = tm(2009m4) + _n
format time %tm
sort time

merge 1:1 time using `coefficients'
tab _merge
drop _merge

foreach stimulus in Obligations Announcements Payments {
	generate `stimulus'U = `stimulus' + 1.65*se`stimulus'
	generate `stimulus'L = `stimulus' - 1.65*se`stimulus'
}

sort time
merge 1:1 time using `AmountsOverTime'
tab _merge
drop _merge
replace Obligated = . if Obligated == 0
replace Announced = . if Announced == 0
replace Paid = . if Paid == 0
replace Announcements = . if time<ym(2009,8)
replace AnnouncementsU = . if time<ym(2009,8)
replace AnnouncementsL = . if time<ym(2009,8)
label variable Obligated "Amount Obligations"
label variable Announced "Amount Announcements"
label variable Paid "Amount Payments"

foreach stimulus in Announcements Obligations Payments {
	label variable `stimulus'U "90% CI"
	label variable `stimulus'L "90% CI"
	label variable `stimulus' "Coefficient"	
}
#delimit ;	
graph twoway (tsline Announcements AnnouncementsU AnnouncementsL, yaxis(1) lpattern(solid dash dash) lcolor(black black black) )
	(tsline Announced, yaxis(2) lpattern(dot) lcolor(black) ) if inrange(time,ym(2009,5),ym(2011,3)),
	ytitle("Estimate", axis(1)) ytitle("Stimulus", axis(2)) yline(0, axis(1) lcolor(black) )
	title("Announcements") xtitle("") xlabel(
	592 "May"
	594 "July"
	596 "Sep"
	598 "Nov"
	600 "Jan"
	602 "Mar"
	604 "May"
	606 "July"
	608 "Sep"
	610 "Nov"
	612 "Jan"
	614 "Mar"	);
graph export results/Figure5a.eps, replace;
graph twoway (tsline Obligations ObligationsU ObligationsL, yaxis(1) lpattern(solid dash dash) lcolor(black black black) )
	(tsline Obligated, yaxis(2) lpattern(dot) lcolor(black) ) if inrange(time,ym(2009,5),ym(2011,3)),
	ytitle("Estimate", axis(1)) ytitle("Stimulus", axis(2)) yline(0, axis(1) lcolor(black) )
	title("Obligations") xtitle("") xlabel(
	592 "May"
	594 "July"
	596 "Sep"
	598 "Nov"
	600 "Jan"
	602 "Mar"
	604 "May"
	606 "July"
	608 "Sep"
	610 "Nov"
	612 "Jan"
	614 "Mar"	);
graph export results/Figure5b.eps, replace;
graph twoway (tsline Payments PaymentsU PaymentsL, yaxis(1) lpattern(solid dash dash) lcolor(black black black) )
	(tsline Paid, yaxis(2) lpattern(dot) lcolor(black) ) if inrange(time,ym(2009,5),ym(2011,3)),
	ytitle("Estimate", axis(1)) ytitle("Stimulus", axis(2)) yline(0, axis(1) lcolor(black) )
	title("Payments") xtitle("") xlabel(
	592 "May"
	594 "July"
	596 "Sep"
	598 "Nov"
	600 "Jan"
	602 "Mar"
	604 "May"
	606 "July"
	608 "Sep"
	610 "Nov"
	612 "Jan"
	614 "Mar"	);
graph export results/Figure5c.eps, replace;
#delimit cr;

log close
}
* Figure 6
if 1==1 {
	quietly log using logs/figure6.log, replace
	use $data_Full, clear
	summ time
	local maxdate = r(max) - ym(2009,1) - 2
	disp "`maxdate'"
	clear

	matrix WSJ_est = [0]
	matrix WSJ_se = [0]
	matrix Pre_time = [0]
	matrix Post_time = [0]
	matrix Window = [0]
	
	forvalues year=2006/2006 {
		forvalues lagforward=1/61 {
			local post_time = ym(`year',2) + `lagforward'
			local pre_time = ym(2009, 2)
			local pre_year = 2008
			disp "Pre/Post:" %tm `pre_time' " - " %tm `post_time'
			use $data_Full , replace

			*  Make State GSP per capita
			local startyear = `year' - 3
			local endyear   = `year' - 2
			
			GSPPerCapitaGeneralDate `startyear' `endyear'

			*  Make the tax benefits variable.
			gen taxbenefits_dollarspercap = taxbenefits/(StatePopulation*1000)
			gen taxbenefits_cap = taxbenefits/(1000000*(StatePopulation*1000))
			label variable taxbenefits_cap "Tax Benefits (Mill. per cap)"
			label variable taxbenefits_dollarspercap "Tax Benefits (p.c.)"

	*********************************************************
	* Make the three-year MA control variables (GSP and PI) *
	*********************************************************

			
			do Program.3yrMAControls.do
			
			* Sum the ARRA spending over agencies.
			qui: do Program.ARRASpending.do
			
			* Generate measures excluding DOL.
			do Program.ExcludingDOL.do
			
			foreach emplevel of varlist StateEmployment{
				gen tmp_empratio = `emplevel'/StatePopulation
				gen _tmp_tc1 = tmp_empratio if time == ym(`year'-2, 12)
				gen _tmp_tc2 = tmp_empratio if time == `pre_time'
				bysort state: egen nonmissing_tmp_tc1 = min(_tmp_tc1)
				bysort state: egen nonmissing_tmp_tc2 = min(_tmp_tc2)
				gen control_`emplevel' = (nonmissing_tmp_tc2 - nonmissing_tmp_tc1)
				drop _tmp_tc1 _tmp_tc2 nonmissing_tmp_tc1 nonmissing_tmp_tc2
				gen _tmp_tc1 = tmp_empratio if time == `pre_time'
				bysort state: egen c_level_`emplevel' = min(_tmp_tc1)
				drop _tmp_tc1 tmp_empratio	
			}
			rename control_StateEmployment cont_drchange_emp_rate
			rename c_level_StateEmployment cont_lchange_emp_rate
			
			* Keep 2009 Population
			qui: gen StatePopulation_all =  StatePopulation if time == ym(2009, 2)
			qui: bysort state: egen StatePopulation_all_nonmissing = min(StatePopulation_all)
			qui: replace StatePopulation = StatePopulation_all_nonmissing
			
			*** Generate growth in house prices from 2002m12 - 2007m12 as the "house price run-up" control variable
			gen tmp_HPI_1 = StateHPI if time == tm(2002m12)
			gen tmp_HPI_2 = StateHPI if time == tm(2007m12)
			bysort state: egen nonmissing_tmp_HPI_1 = min(tmp_HPI_1)
			bysort state: egen nonmissing_tmp_HPI_2 = min(tmp_HPI_2)
			gen house_price_runup = nonmissing_tmp_HPI_2/nonmissing_tmp_HPI_1 - 1 
			label variable house_price_runup "Growth rate in FHFA house price index from 2002m12 - 2007m12"
			drop tmp_HPI* nonmissing_tmp*
		
			* Formulary Factors instruments
			gen HHS_instrument = 0.062*(medicaid_fy2007/(StatePopulation*1000)) if time == ym(2009,1)
			bysort state: egen HHS_instrument2 = min(HHS_instrument)
			drop HHS_instrument
			rename HHS_instrument2 HHS_instrument_nonmiss

			reg DOT_Obligations dot_taxpayments dot_vehiclemiles dot_lanemiles dot_obligationlimitation if state ~= 11 & time == ym(2010,2)
			predict DOT_predict, xb
			gen DOT_predict_instrument = DOT_predict/(StatePopulation*1000)
			bysort state: egen DOT_predict_instrument_nonmiss = min(DOT_predict_instrument)
			bysort state: egen DOT_Instrument = min(DOT_Obligations/(StatePopulation*1000))
			foreach factor in dot_taxpayments dot_vehiclemiles dot_lanemiles dot_obligationlimitation {
				gen `factor'_cap = `factor'/(StatePopulation*1000)
			}

			bysort time: egen sum_all_schoolage = total(school_age_pop)
			by time: egen sum_all_statepop = total(StatePopulation)
			gen frac_school_age = school_age_pop/sum_all_schoolage if time == ym(2008,1)
			gen school_age_pop1 = school_age_pop if time == ym(2008,1)
			gen frac_statepop = StatePopulation/sum_all_statepop if time == ym(2008,1)
			bysort state: egen hhs_frac_school = min(frac_school_age)
			bysort state: egen hhs_school_age = min(school_age_pop1)
			by state: egen hhs_frac_statepop = min(frac_statepop)
			*gen ED_instrument = (.61*(hhs_frac_school) + .39*(hhs_frac_statepop))/StatePopulation
			gen ED_instrument = hhs_school_age/StatePopulation		
			bysort state: egen ED_instrument_nonmiss = min(ED_instrument)
		
			bysort state: gen avg_instrument = 0.00000621*HHS_instrument_nonmiss + 0.00014*ED_instrument_nonmiss + 0.00000220*DOT_predict_instrument_nonmiss
	
			
			qui: keep if time == `post_time' | time == `pre_time' 
			if `post_time' < `pre_time' {
				disp "Post Time less than Pre Time"
				gsort + state - time
				qui: gen change_emp_rate = StateEmployment/StatePopulation - StateEmployment[_n-1]/StatePopulation[_n-1]  if state == state[_n-1]
			}	
			else {
				disp "Pre Time less than Post Time"
				sort state time
				qui: gen change_emp_rate = StateEmployment/StatePopulation - StateEmployment[_n-1]/StatePopulation[_n-1]  if state == state[_n-1]
			}
			
			* do the regressions, and save the estimates in a matrix, as long as pre_time isn't equal to post_time.
			if `post_time' ~= `pre_time' {
				qui: reg change_emp_rate avg_instrument RealAnnualPI_3yrMADifference taxbenefits_cap cont*change_emp_rate house_price_runup     if state~=11 & time == `post_time'
				matrix coefficients = e(b)
				matrix varcovar = e(V)
				matrix WSJ_est = WSJ_est \ [el(coefficients, 1, 1)]
				matrix WSJ_se = WSJ_se \ [sqrt(el(varcovar, 1, 1))]
				
				* Make matrices containing the time periods that you did these regressions over.
				matrix Pre_time = Pre_time \ [`pre_year']
				matrix Post_time = Post_time \ [`post_time']
				matrix Window = Window \ [`lagforward']
			}
		}
	}
	
	* Make the matrix into variables.
	tempfile temp
	save `temp'
	matrix data = Pre_time, Window , WSJ_est , WSJ_se
	svmat data
	rename data1 date
	rename data2 window
	rename data3 WSJ
	rename data4 WSJ_se
	keep  date window WSJ WSJ_se
	drop in 1/1
	drop if date == .
	save `temp' , replace
	use `temp' , replace
	
	keep WSJ WSJ_se window date
	gen WSJ_upper = WSJ + 1.645*WSJ_se
	gen WSJ_lower = WSJ - 1.645*WSJ_se
	
	keep WSJ* window date
	
	reshape wide WSJ* , i(window) j(date)
	keep window WSJ*2008
	
	drop WSJ_se2008
	
	tsset window
	tsfill
	#delimit ;	
	graph twoway tsline WSJ2008 WSJ_lower2008 WSJ_upper2008 if window >= 25,
		cmissing(n n n)
		lcolor(navy navy*.5 navy*.5  midgreen midgreen*.5 midgreen*.5)
		lpattern(solid dash dash solid dash dash)
		title("Coefficient from Reduced Form Regression")
		subtitle("Change in Employment Regressed on Predicted ARRA Spending and controls", size(small))
		ytitle("Coefficient") xtitle("Month") xlabel(
		25 "Mar08"
		29 "Jul08"
		33 "Nov08"
		37 "Mar09"
		41 "Jul09"
		45 "Nov09"
		49 "Mar10"
		53 "Jul10"
		57 "Nov10"
		61 "Mar11"
		,labsize(small)
		)
		legend(off)
		;
	graph export results/Figure6.eps , replace;
	#delimit cr;
	log close	
}

*** Edited by RYAN STEED
}
***