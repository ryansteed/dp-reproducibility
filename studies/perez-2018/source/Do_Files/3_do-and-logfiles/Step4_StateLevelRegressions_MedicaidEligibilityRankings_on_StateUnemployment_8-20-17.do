clear

*** EDIT by Donna
global OUTPUT	".."
global 	DATA 	"../2_data"

	use $DATA/AllStates_JulyAnnualUnemploymentRate2001_2010.dta

ssc install xtile2
ssc install astile	
	
/*==============================================================================
	I	BRING IN SIMULATED MEDICAID ELIGIBILITY FOR EACH YEAR	
==============================================================================*/

	merge 1:1 st_fips year using "$DATA/sim_elig_adults2.dta"

		keep if _merge==3

/*==============================================================================
	II	SET UP DATA AS A STATE-LEVEL PANEL.
==============================================================================*/
		
			xtset st_fips year

/*==============================================================================
	III	HOUSEKEEPING
==============================================================================*/
	
	*Label Existing Variables.................................
	
		replace sim_mcd_elig = 100*sim_mcd_elig
			label var sim_mcd_elig "%Medicaid Eligible [*SIMULATED]"
			
		label var ann_unempl "%Unemployment [s,t]"			
			
	*Generate New Variables...................................
	
		*a) Medicaid Generosity Rank.
		
			bysort  year: egen rnk_generous = rank(sim_mcd_elig)
			label var rnk_generous "Rank in year: Generosity for Medicaid Eligibility"
		
		*b) Tertiles of Medicaid Generosity (3 Groups)
			
			astile mcdgenerous_3grp = sim_mcd_elig,  nq(3)  by(year)
				label var mcdgenerous_3grp "3 Groups of Generosity"
					label define mcdgenerous_3grp 	1 "Least Generous (lower 1/3)"		///
													2 "Avg. Generosity (middle 1/3)"	///
													3 "Most Generous (upper 1/3)"
					label values mcdgenerous_3grp mcdgenerous_3grp
			
			gen mcdgencat = .
				replace mcdgencat = 100*(mcdgenerous_3grp - 2)
					label var mcdgencat "Category of Medicaid Generosity"
					label define mcdgencat  -1 "Least Generous (lower 1/3)"		///
											0 "Avg. Generosity (middle 1/3)"	///
											1 "Most Generous (upper 1/3)"
					label values mcdgencat mcdgencat
		
		*c) Interim & Post Recession.
					 
			 gen pre_recess  = (year<2007)
				label var pre_recess "Pre-Recession"
				
			 gen int_recess  = (year>=2007 & year<=2009)
				label var int_recess "Recession"
				
			 gen post_recess = (year>=2010)
				label var post_recess "Post-Recession"
				
		*d) Unemployment & Medicaid Generosity for Graphs
				
				bysort mcdgenerous_3grp year: egen pooled_unempl = mean(ann_unempl)
				bysort mcdgenerous_3grp year: egen pooled_elig = mean(sim_mcd_elig)		
			
					label var pooled_unempl "Pooled %Unemployment [3 Groups of MCD Generosity]"
					label var pooled_elig   "Pooled %Medicaid Eligible [3 Groups of MCD Generosity]"
					
/*==============================================================================
	IV	SAVE FILE FOR MERGING W/ OTHER MICRO-FILES
==============================================================================*/

	preserve
	
		keep year st_fips rnk_generous mcdgenerous_3grp mcdgencat sim_mcd_elig
		
			save $DATA/MedicaidEligibilityGroupings_8-21-17 , replace
			
		restore
							
/*==============================================================================
	V	FIGURES
==============================================================================*/

	
	graph twoway 	scatter pooled_unempl year if 	mcdgenerous_3grp==1, sort connect(l) clpattern(solid) 		msymbol(D) 	 lw(medthick) 	||	///
					scatter pooled_unempl year if 	mcdgenerous_3grp==2, sort connect(l) clpattern(longdash) 	msymbol(Th)  lw(medthick) 	||	///
					scatter pooled_unempl year if 	mcdgenerous_3grp==3, sort connect(l) clpattern(dot) 		msymbol(S) 	 lw(thick) 	///
					title("Unemployment Rate by Level of Generosity for Medicaid Eligibility" "  " , size(medium) )  ///
					xlab(2002(1)2010) xline( 2006.5 2009.5)  ///
					legend( row(3) col(1) order(1 "Lower Third (Least Generous)" 2 "Middle" 3 "Upper Third (Most Generous)") ) ///
					ylab(0(2)12) ytitle("%Unemployment")  xtitle("Year")
					
		graph export  "$OUTPUT/Graph1_BPS_EffectsofRecessionon_UnemploymentRate&MedicaidGenerosityGroup_8-20-17.png" , as(png) replace 
		graph export  "$OUTPUT/Graph1_BPS_EffectsofRecessionon_UnemploymentRate&MedicaidGenerosityGroup_8-20-17.pdf" , as(pdf) replace 
		graph export  "$OUTPUT/Graph1_BPS_EffectsofRecessionon_UnemploymentRate&MedicaidGenerosityGroup_8-20-17.eps" , as(eps) replace 
		
		/*
			Great to know that Medicaid generosity in this broad category had no observable effect on 
			employment rates during this period. 
			
			This should actually add validity to the strategy. 
		*/	
					
	/*
	
	
	graph twoway 	scatter pooled_elig year if 	mcdgenerous_3grp==1, sort connect(l) clpattern(solid) 		msymbol(D) 	 lw(medthick) 	||	///
					scatter pooled_elig year if 	mcdgenerous_3grp==2, sort connect(l) clpattern(longdash) 	msymbol(Th)  lw(medthick) 	||	///
					scatter pooled_elig year if 	mcdgenerous_3grp==3, sort connect(l) clpattern(dot) 		msymbol(S) 	 lw(thick) 	///
					legend( row(1) col(3) order(1 "Least Generous" 2 "Middle" 3 "Most Generous") ) ///
					ylab(0(6)30) ytitle("%Medicaid Eligible")  xtitle("Year")
	
	*/
	
/*==============================================================================
	VI	REGRESSIONS
==============================================================================*/

quietly xtreg sim_mcd_elig ann_unempl, fe
	quietly estadd local year_fe "Yes"
	quietly estadd local state_fe "Yes"
	quietly eststo est_mod1
	quietly estadd ysumm

quietly xtreg sim_mcd_elig  c.ann_unempl##(int_recess post_recess) , fe
	quietly estadd local year_fe "Yes"
	quietly estadd local state_fe "Yes"
	quietly eststo est_mod2
	quietly estadd ysumm


 
esttab   est_*  ///
			using "$OUTPUT/RegressionTable1_BPS_EffectsofRecessiononMedicaidGenerosity_RegressionResults_8-20-17.rtf" , ///
			keep(ann_unempl 1.int_recess 1.post_recess 1.int_recess#c.ann_unempl 1.post_recess#c.ann_unempl ) ///
			starlevels(* 0.1 ** 0.05 *** 0.01) label ///
			b(%20.4f) se(%20.4f) eqlabels(none) alignment(c)  ///
			stats(ymean ysd N year_fe state_fe, fmt(%3.2f %3.2f 0 0 ))  ///
			title("Table 1. Effects of 2007-2009 Financial Crisis on Medicaid Generosity with Respect to Eligibility.") ///
			addnotes("Note: Percent eligible for Medicaid for years 2002-2010 was developed using a simulated eligibility measure based on each state's rules governing Medicaid eligibility limits." ) ///
		replace 

estout est_* using "../../../results/table3.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace			 	


		
clear
