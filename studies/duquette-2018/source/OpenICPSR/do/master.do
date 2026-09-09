// ------------------------------------------------------------------------- //
//																			 //
// Historical inequality, philanthropy, and 								 //
// income taxation of high-income US households								 //
// Nicolas J. Duquette | nduquett@usc.edu									 //
//																			 //
// This file is not only complex; it is incomplete.							 //
// Portions of this paper's work must run on the NBER's servers, because	 //
// (1) while the IRS public use files are public, the NBER's copies			 //
// have NBER-specific adjustments and are not for downloading or 			 //
// general use, and (2) I use the taxpuf9 version of TAXSIM, a				 //
// richer version of TAXSIM that takes hundreds of input variables,			 //
// and which is only run in the NBER's server environments.					 //
//																			 //
// ------------------------------------------------------------------------- //

version 14.2

clear all

	// Install esttab / estout if it's not installed yet.
capture net install estout

// ====================================
// 1. Set up the work environment

	* CHANGE THIS PATH TO THE LOCATION OF THIS FOLDER ON YOUR COMPUTER
local root "[[[YOUR FILE PATH HERE]]]"
												// Central storage for project

*** Edited by Annie
global data "./data"						// Source data
global do_files "./do"						// store do-files here		
global charts "./FT"						// figures		
global tables "./FT"						// tables
***								
// ===========================================
// Make plots for manuscript


do "$do_files/plot_gr_ineq.do"				// Compare giving/income time series to 
											// inequality time series (figure 1) 
 
do "$do_files/plot_gr_basic.do"				// Chart giving ratios for entire time series
											// (Figure 2: giving/income by income group)
												
do "$do_files/plot_gr_tax.do"				// Compare giving/income time series to 
											// to tax time series (figure 3)
											
				
do "$do_files/plot_cont_exp.do"				// This creates figures comparing historical
											// and current contributions to current
											// charity and foundation expenditures
											// by state (fig 4)
					
							
											
// ===========================================
// Regression tables for main text

do "$do_files/est_rhos.do"					// Calculate time series 
											// correlations for body text
											// of the paper

do "$do_files/reg_basic_time_series.do"		// Multivariate time series
											// regressions (table 1),
											// as well as time series 
											// appendix checks
											// (tables A2, A5, and A6)
	


do "$do_files/table2_synpanel.do"			// Regress synthetic panel of
											// high-income fractiles on 
											// inequality and syntehtic tax,
											// income variables (table 2)
											// and replication using PSZ
											// inequality (table A7) and
											
											
	// REGRESSION USING CROSS-SECTIONAL DATA HAS TO RUN ON NBER 
	// SERVERS DUE TO DATA RESTRICTIONS (TABLES 3, A8 and A9).
					
do "$do_files/reg_sy_total_ineq_tax.do"		// State-year regression (table 4)
	
																					
// ============================================
// Additional appendix regressions and plots

do "$do_files/org_ts_reg.do"				// Do regressions for giving to
											// charity AR time series (TABLE A1)
	

do "$do_files/chart_giving_history_shares"	// Plot top group shares of 
											// national giving and national
											// (figs A1, A2, A3)

do "$do_files/plot_giving_per_capita.do"	// Plot actual real-dollar giving 
											// per tax unit against income 
											// levels to show this isn't a 
											// denominator-only phenomenon
											// (figure A9) and
											// regress aboslute amoutns
											// in time series (table A4)

do "$do_files/tableA10.do"					// time series without all three
											// regressors (table A10)
		
	// FIGURE A4 IS CREATED IN AN EXCEL FILE INCLUDED IN THE ROOT DIRECTORY	
		
do "$do_files/bequest_incentive_plot.do"	// Compare individual and estate
											// tax rates (figure A5)

do "$do_files/estate_plot.do"				// Plot giving/assets in estates
											// Figure A6
											
do "$do_files/plot_canada.do"				// Does Canada coincide wtih USA?
											// (figure A7)


	// FIGURE A8 IS CREATED IN AN EXCEL FILE INCLUDED IN THE ROOT DIRECTORY											
