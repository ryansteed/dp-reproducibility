*****************************************************************************************************************
* Author: V Perez																								*
* Created: 			June 19, 2013																				*
* Last Modified:    August 19, 2017																				*
* Purpose: Read in data from NASBO Expenditure Reports and Fiscal Reports, 2002-2010							*
* Final file for output: nasbo_shocks_finalfile																	*
*****************************************************************************************************************

clear all
set more off


/*Working Directories*/

*** EDIT by Donna
* global db "/Users/vieperez/Dropbox/Work"
* global basedir "${db}/BPS_MedicaidCoverage&Recessions/PapersProceedings"
global outputdir "../2_data"
global inputdir "${outputdir}/NASBO/ExpenditureReports"
global sourcedir "."
global logdir "."
global tabledir "../4_output"
global datadir "${outputdir}/NASBO"

*****************************************************************************************************************
* Part 1: 																										*
* This program converts the wide data from the odesk freelancer to a long format.                               *
* The funding source: federal (fed), general fund (gen), other state funding (st), bonds (bd), and total (tot). *
* The next piece indicated if the actual fiscal amount (af) or the estimated fiscal amount(ef).                 *
* If this was Medicaid expenditures only, an (_m_) was inserted.                                                *
* The first year indicates the year referenced by the table column.                                             *
* The second year indicates the year of the report.                                                             *
* For example, bd_af_m_85_87: Bond funds spent on Medicaid in 1985 as reported in the 1987 Expenditure report.  *
*****************************************************************************************************************

	/*MEDICAID*/
	local fundtype fed gen st tot 

	foreach g of local fundtype{
		insheet using "${inputdir}/ExpenditureReports`g'_af_m.csv", comma case names clear
				drop regname 
				drop if stname=="TOTAL"
				drop if stname=="Puerto Rico"
				drop if stname==""
			reshape long `g'_af_m, i(stname) j(yrrep) s
			split yrrep, p("_") gen(yr)
				drop yr1
					rename yr2 yr1
					rename yr3 yr2
			destring yr1 yr2, replace

			sort stname yr2 yr1
			destring `g'_af_m, replace

				drop if yr1==yr2 & yr1!=11 
				drop yrrep
				sort stname yr1
				keep stname `g'_af_m yr1
				drop if yr1>10
				duplicates report stname yr1
		save "${datadir}/`g'_af_m.dta", replace
	}

	foreach h of local fundtype {
		insheet using "${inputdir}/ExpenditureReports`h'_ef_m.csv", comma case names clear
				drop regname
				drop if stname=="TOTAL"
				drop if stname=="Puerto Rico"
				drop if stname==""
			reshape long `h'_ef_m, i(stname) j(yrrep) s
			split yrrep, p("_") gen(yr)
				/*For example 
				stname	gen_af_m	yr1	yr2
				MA		2			11	10
				So there should be half as many observations as in the actual fiscal expenditures files 
				(after the reshaping, or half the number of vars before the reshaping)*/
				drop yr1
					rename yr2 yr1
					rename yr3 yr2
			destring yr1 yr2, replace
				drop yrrep
				sort stname yr1 yr2
				keep stname `h'_ef_m yr1
		save "${datadir}/`h'_ef_m.dta", replace

		merge 1:1  stname yr1 using "${datadir}/`h'_af_m.dta", nogen
				drop if yr1>10 

		save "${datadir}/`h'_m_final.dta", replace
	}


	use  "${datadir}/fed_m_final.dta", clear

		merge 1:1 stname yr1 using  "${datadir}/gen_m_final.dta", nogen
		merge 1:1 stname yr1 using  "${datadir}/st_m_final.dta", nogen
		merge 1:1 stname yr1 using  "${datadir}/tot_m_final.dta", nogen

		replace yr1=yr1+2000
		ren yr1 year
		
			foreach h of local fundtype {		
				gen medshock_`h'=(`h'_ef_m-`h'_af_m)/`h'_ef_m
	*			gen medshock_`h'=(`h'_ef_m-`h'_af_m)/`h'_af_m
				}	
			
		keep year stname medshock*
		
	save "${datadir}/medicaid_spending.dta", replace

	/*Total Expenditures*/

	foreach g of local fundtype{
		insheet using "${inputdir}/TotExpend_`g'.csv", comma case names clear
				drop if stname=="TOTAL"
				drop if stname=="Puerto Rico"
				drop if stname==""
				drop `g'_ef*
			reshape long `g'_af, i(stname) j(yrrep) s
				split yrrep, p("_") gen(yr)
				drop yr1 yrrep
					rename yr2 yr1
					rename yr3 yr2
				destring yr1 yr2, replace
				drop if yr1==yr2 & yr1!=11 
				drop if yr1>10
				drop yr2
			replace yr1=2000+yr1
		save "${datadir}/af_te_`g'.dta", replace

		insheet using "${inputdir}/TotExpend_`g'.csv", comma case names clear
				drop if stname=="TOTAL"
				drop if stname=="Puerto Rico"
				drop if stname==""
				drop `g'_af*
			reshape long `g'_ef, i(stname) j(yrrep) s
				split yrrep, p("_") gen(yr)
				drop yr1 yrrep
					rename yr2 yr1
					rename yr3 yr2
				destring yr1 yr2, replace	
				drop if yr1==yr2 & yr1!=11 
				drop if yr1>10
			replace yr1=2000+yr1
				drop yr2
		save "${datadir}/ef_te_`g'.dta", replace
		
			merge 1:1 stname yr1 using "${datadir}/af_te_`g'.dta", nogen
					rename yr1 year
				drop if year<2000|year>2010
		
	*		gen shock_`g'=(`g'_ef-`g'_af)
			gen shock_`g'=(`g'_ef-`g'_af)/`g'_af
			
		keep stname year shock*	
		save "${datadir}/`g'.dta", replace

	}


	use  "${datadir}/fed.dta", clear

		merge 1:1 stname year using  "${datadir}/gen.dta", nogen
		merge 1:1 stname year using  "${datadir}/st.dta", nogen
		merge 1:1 stname year using  "${datadir}/tot.dta", nogen

		merge 1:1 year stname using "${datadir}/medicaid_spending.dta", nogen
			drop if stname=="DC"

	save "${datadir}/fiscalshock.dta", replace

	insheet using "${inputdir}/stname.csv", comma case names clear
			rename stfip st
		gen stfip=string(st,"%02.0f")
			drop st 
		merge 1:m stname using "${datadir}/fiscalshock.dta"
			drop if _merge<3
			drop _merge
			
	save "${datadir}/fiscalshock.dta", replace


************************************
* Part 2: 						   *
* Emergency Stabilization Fund 	   *
************************************

	insheet using "${datadir}/FallFiscalReports.csv", comma case names clear
			replace est_rd_fund=" " if est_rd_fund=="NA" | est_rd_fund=="N/A" |  est_rd_fund=="*" | est_rd_fund=="-" | act_rd_fund=="NA" | act_rd_fund=="N/A" | act_rd_fund=="*" | act_rd_fund=="-"
				drop if yr1<2000|yr1>2010
		destring est_rd_fund, gen(rd_ef) ignore("$" "," " ")
		destring act_rd_fund, gen(rd_af) ignore("$" "," " ")
				drop est_rd_fund act_rd_fund
				
		gen rdshock =(rd_ef-rd_af)/rd_ef
		gen rdshocklvl =(rd_ef-rd_af)
		*gen rdshock =(rd_ef-rd_af)
		ren yr1 year
		
		keep year stname rdshock*
	save "${datadir}/rd911.dta", replace
	
	merge 1:1 stname year using "${datadir}/fiscalshock.dta", nogen
	
	* Add Variable Names
	ren stfip  st_fips
	destring st_fips, replace
		label var stname 	"Full state name"
		label var year		"Year"
		label var rdshock	"Rainy Day Fund"
		label var stn		"State (2-letter)"
		label var st_fips		"State FIPS"
		label var shock_fed	"Federal funds"
		label var shock_gen "General fund"
		label var shock_st	"Other state funds"
		label var shock_tot	"Total funds"
		label var medshock_fed "Federal funds in Medicaid"
		label var medshock_gen "General fund in Medicaid" 
		label var medshock_st "Other state funds in Medicaid"
		label var medshock_tot "Total funds in Medicaid"
	
	save "${datadir}/nasbo_shocks_finalfile.dta", replace
