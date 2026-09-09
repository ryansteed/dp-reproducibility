
capture log close
macro drop _all
setdate
setdirectory

log using "Logs/1-rutgers_${date}", replace text
********************************************************************************
*rutgers_$date: clean fiscal data
*Victoria Sosina (vsosina@stanford.edu)
di "Date: $date"
********************************************************************************
/*Subset variables of interest and rename. Creates indicators used for sample 
restriction later in the analysis. */
********************************************************************************

version 13
set linesize 82
set more off, perm

********************************************************************************
*OPEN FILE
********************************************************************************

use "Source\PUBLIC_LEApanel1.17.dta", clear

********************************************************************************
*INDICATORS FOR DISTRICT CHARACTERISTICS USED IN SAMPLE RESTRICTION
********************************************************************************
	
	*Indicator for vocational or special education system***********************
	gen drop_vocspec = 	schlev_f33full == "05"
		
		*vocational district strings
		local vocstrings "`"vocational"' `"voc sch"' `"voc sys"' `"voc-tech"'"
		local vocstrings "`vocstrings' `"voc/tech"' `"jvsd"' `"vocationa"'"
		local vocstrings "`vocstrings' `"boces"' `"vocatio"'" 
		
		*search all three given names for voc strings and update indicator
		foreach v of local vocstrings{
			replace drop_vocspec = 1 if strpos(lower(name_f33full), "`v'")
			replace drop_vocspec = 1 if strpos(lower(name_f33red), "`v'")
			replace drop_vocspec = 1 if strpos(lower(name_ccdlea), "`v'")
		}	
			
		*special education district strings
		local specstrings "`"deaf"' `"blind"' `"handicap"'"
		
		*search all three given names for speced strings and update indicator
		foreach v of local specstrings{
			replace drop_vocspec = 1 if strpos(lower(name_f33full), "`v'")
			replace drop_vocspec = 1 if strpos(lower(name_f33red), "`v'")
			replace drop_vocspec = 1 if strpos(lower(name_ccdlea), "`v'")
		}	
		
		
	*Indicator for non-operating school systems*********************************
	gen drop_noop = schlev_f33full == "06"
	
		*non-operational district strings
		local noopstrings "`"(non-op)"' `"(non op)"'"
	
		*search all three given names for non-op strings and update indicator
		foreach v of local noopstrings{
			replace drop_noop = 1 if strpos(lower(name_f33full), "`v'")
			replace drop_noop = 1 if strpos(lower(name_f33red), "`v'")
			replace drop_noop = 1 if strpos(lower(name_ccdlea), "`v'")
		}
								 
	*Indicator for ESAs*********************************************************
	/*federal, state, regional, or other ESAs*/
	gen drop_esa = schlev_f33full == "07"
	
		*update indicator using ccd type indicator
		replace drop_esa = 1 if type_ccdlea == 4 | ///		//regional 
								type_ccdlea == 5 | ///		//state
								type_ccdlea == 6 | ///		//federal
								type_ccdlea == 8 			//other esa
	
	*Indicator for charter districts********************************************
	gen drop_charter = agchrt_ccdlea == "1"
	
		*update indicator using ccd type indicator
		replace drop_charter = 1 if type_ccdlea == 7		//charter agency
		
		*charter district strings
		local chartstrings "`"charter"'"
	
		*search all three given names for charter strings and update indicator
		foreach v of local chartstrings{
			replace drop_charter = 1 if strpos(lower(name_f33full), "`v'")
			replace drop_charter = 1 if strpos(lower(name_f33red), "`v'")
			replace drop_charter = 1 if strpos(lower(name_ccdlea), "`v'")
		}

	*Indicator for juvenile justice districts***********************************
	gen drop_jj = 0 

		*juvenile justice district strings
		local jjstrings "`"juvenile"' `"correction"'"
	
		*search all three given names for jj strings and update indicator
		foreach v of local jjstrings{
			replace drop_jj = 1 if strpos(lower(name_f33full), "`v'")
			replace drop_jj = 1 if strpos(lower(name_f33red), "`v'")
			replace drop_jj = 1 if strpos(lower(name_ccdlea), "`v'")
		}
		/*a lot of the jj obs were likely identified with the state operated 
		agencies */

	*Indicator for not 50 states************************************************
	//Hawaii's also in here, because it only has one district
	gen drop_notstate = 0
	
		*non-state strings
		local notstatestrings "63 59 60 66 69 72 78 11 15"
		
		*search all three given names for non-state strings and update indicator
		foreach v of local notstatestrings{
			replace drop_notstate = 1 if strpos(leaid, "`v'")==1
			replace drop_notstate = 1 if strpos(leaid, "`v'")==1
			replace drop_notstate = 1 if strpos(leaid, "`v'")==1
		}

		//DOD - 63, BIE - 59, Samoa - 60, Guam - 66, Mariana Is. - 69, 
		//PR - 72, Virgin Is. - 78, DC - 11, Hawaii - 15 
		
		/*There's also a 61 fipst value in the data. All the observations with a
		61 fipst value are federally operated agencies. From the names, they 
		seem to be military bases. Since they will be excluded under the 
		federally operated agencies restriction, I'm not including them here. */
		
	*Indicator for ccd lea math 50 states***************************************
	
	*Additional charter indicator
	tab chrtleastat_ccdlea drop_charter
	/*all of the charter districts identified by this indicator are already
	identified by the drop_charter indicator.	*/
	
	*Ever drop indicator********************************************************
	preserve
		drop if year < 1995 
				
		foreach v of var drop_*{
			egen sd`v' = sd(`v'), by(leaid)
			gen ever`v' = sd`v'
			recode ever`v' (0 = 0) (nonmissing = 1)
			
			egen ct`v' = count(`v'), by(leaid)
			
			egen sum`v' = sum(`v'), by(leaid)
		}
	restore
		
	foreach v of var drop_vocspec drop_esa drop_jj drop_notstate{
		*does the district switch status on the indicator in given time frame?
		egen sd`v' = sd(`v'), by(leaid), if year >= 1995 & !missing(year)
		gen ever`v' = sd`v'
		recode ever`v' (0 = 0) (nonmissing = 1) 
			
		*update drop indicator
		replace `v' = 1 if ever`v' == 1
					
		*drop intermediate variables
		drop sd`v' ever`v'
	}
	
	*how many years is the district present in the data?
	egen year_n = count(year), by(leaid), if year >= 1995 & !missing(year)
	
	foreach v of var drop_*{	
		*how many years does district have value of 1 on the given indicator?
		egen sum`v' = sum(`v'), by(leaid), if year >= 1995 & !missing(year)
		
		*number of years present against years with a 1 on each indicator
		su sum`v' year_n if sum`v' > 0
		//should be equal for vocspec esa jj nostate
			
	}
	

********************************************************************************
*GENERATE AND RENAME VARIABLES
********************************************************************************
gen rut_gen_fips = substr(leaid,1,2)

*Indicator for non-unified system (i.e. just elem or just hs)
gen rut_nonuni = schlev_f33full == "01" | schlev_f33full == "02"

*Indicator for unified system (i.e. both elem or just hs)
gen rut_uni = schlev_f33full == "03"

*Variables for the construction of urbanicity
gen rut_ulocal = ulocal_ccdlea
replace rut_ulocal = "." if rut_ulocal == "M"
replace rut_ulocal = "." if rut_ulocal == "N"
destring rut_ulocal, replace

*Rename ID variables
rename name_ccdlea 	rut_name_ccdlea 
rename name_f33red 	rut_name_f33red 
rename name_f33full	rut_name_f33full

*Rename fiscal/enrollment variables
rename totalrev_f33full rev_totalrev
rename tfedrev_f33full 	rev_tfedrev
rename tstrev_f33full 	rev_tstrev
rename tlocrev_f33full	rev_tlocrev

rename totalexp_f33full exp_totexp
rename tcurinst_f33full exp_tcurinst
rename e08_f33full 		exp_genadmin		
rename e09_f33full		exp_schadmin
rename e17_f33full		exp_pupsup
rename v40_f33full		exp_opmain

rename pctblack_ccdlea	rut_perblack
rename pcthisp_ccdlea	rut_perhisp
rename pctwhite_ccdlea	rut_perwhite
rename pctspeced_ccdlea	rut_perspeced
rename pctell_ccdlea	rut_perell
rename saipe_perpov		rut_persaipe
rename saipe_pop517		rut_pop517
rename saipe_pov517		rut_pov517
rename v33_f33full		rut_member
rename ecwi_cwi			rut_cwi

rename enroll_f33red	rut_member_red
rename totalexp_f33red 	rut_totexp_red
rename tcurinst_f33red 	rut_tcurinst_red


rename tcurelsc_f33full			rut_tcurelsc
rename e13_f33full 				rut_e13
rename v91_f33full 				rut_v91
rename v92_f33full 				rut_v92
rename tcurssvc_f33full 		rut_tcurssvc
rename e07_f33full 				rut_e07
rename v45_f33full 				rut_v45
rename v90_f33full 				rut_v90
rename v85_f33full 				rut_v85
rename tcuroth_f33full 			rut_tcuroth
rename e11_f33full 				rut_e11
rename v60_f33full 				rut_v60
rename v65_f33full 				rut_v65
rename nonelsec_f33full 		rut_tnonelse
rename v70_f33full 				rut_v70
rename v75_f33full 				rut_v75
rename v80_f33full 				rut_v80
rename tcapout_f33full 			rut_tcapout
rename f12_f33full 				rut_f12
rename g15_f33full 				rut_g15
rename k09_f33full 				rut_k09
rename k10_f33full 				rut_k10
rename k11_f33full 				rut_k11
rename l12_f33full 				rut_l12
rename m12_f33full 				rut_m12
rename q11_f33full 				rut_q11
rename i86_f33full 				rut_i86
rename j98_f33full				rut_j98
rename j99_f33full				rut_j99
rename j13_f33full 				rut_j13
rename j12_f33full 				rut_j12
rename j14_f33full				rut_j14
rename j17_f33full 				rut_j17
rename j07_f33full 				rut_j07
rename j08_f33full 				rut_j08
rename j09_f33full 				rut_j09
rename j40_f33full 				rut_j40
rename j45_f33full 				rut_j45
rename j90_f33full 				rut_j90
rename j11_f33full 				rut_j11
rename j96_f33full 				rut_j96
rename j10_f33full				rut_j10
rename j97_f33full				rut_j97
rename j85_f33full				rut_j85

********************************************************************************
*LABEL VARIABLES
********************************************************************************
*generated variables
label variable drop_vocspec 	"Drop vocational/special education districts (Rutgers)"
label variable drop_noop 		"Drop non-operational districts (Rutgers)"
label variable drop_esa 		"Drop fed, state, regional, and other ESAs (Rutgers)"
label variable drop_charter 	"Drop charter districts (Rutgers)"
label variable drop_jj 			"Drop juvenile justice districts (Rutgers)"
label variable drop_notstate 	"Drop BIE, DOD, territories, DC, Hawaii districts (Rutgers)"

label variable sumdrop_vocspec 	"N yrs district is vocational/special education districts (Rutgers)"
label variable sumdrop_noop 	"N yrs district is non-operational districts (Rutgers)"
label variable sumdrop_esa 		"N yrs district is fed, state, regional, and other ESAs (Rutgers)"
label variable sumdrop_charter 	"N yrs district is charter districts (Rutgers)"
label variable sumdrop_jj 		"N yrs district is juvenile justice districts (Rutgers)"
label variable sumdrop_notstate "N yrs district is BIE, DOD, territories, DC, Hawaii districts (Rutgers)"

label variable rut_nonuni 		"Elementary or secondary schools only (Rutgers)"
label variable rut_uni			"Both elementary and secondary schools (Rutgers)" 

label variable year_n 			"number of years district is present in data"

*clarify labels
label variable rut_cwi 			"NCES CWI (extended) (district)" 

*shorten existing labels so that the don't get truncated
label variable rev_totalrev  "TOTAL ELEMENTARY-SECONDARY REVENUE"
label variable rev_tfedrev   "Total Revenue from Federal Sources"
label variable rev_tstrev    "Total Revenue from State Sources"
label variable rev_tlocrev   "Total Revenue from Local Sources"
label variable exp_totexp    "TOTAL ELEMENTARY-SECONDARY EXPENDITURE"
label variable exp_tcurinst  "TOTAL CURRENT SPENDING FOR INSTRUCTION"
label variable exp_pupsup    "Current op exp - Pupil support"
label variable exp_genadmin  "Current op exp - General admin"
label variable exp_schadmin  "Current op exp - School admin"
label variable exp_opmain    "Current op exp - Operation and maintenance of plant"


rename tottch_ccdlea 	rut_tottch_ccdlea 
rename ptr 				rut_pup_pertch 
rename tch_per100		rut_tch_per100
********************************************************************************
*KEEP VARIABLES OF INTEREST
********************************************************************************
keep leaid year* rut_* drop_* exp_* rev_* sumdrop*

********************************************************************************
*SAVE
********************************************************************************
save "Derived/1-rutgers_${date}", replace

********************************************************************************
*DOCUMENTATION NOTES
********************************************************************************
/*	
	schlev - 
	
	FY2013 F33 documentation, p. 17	("C:\Users\Victoria\Dropbox\Segregation\
	Documentation\F-33\Documentation_F33_2013.pdf")  
	
		01 = Elementary school system only—the lowest grade with students is 
		less than grade 9 and the highest grade with students is less than 
		grade 9;
		
		02 = Secondary school system only—the lowest grade with students is 
		greater than grade 6 and the highest grade with students is greater 
		than grade 8;
		
		03 = Elementary/Secondary school system—the lowest grade with students 
		is less than grade 7 and the highest grade with students is greater 
		than grade 8;
		
		05 = Vocational or special education system;
		
		06 = Nonoperating school system that exists for administrative purposes 
		only and does not operate its own schools. SCHLEV code “06” is also 
		assigned for LEAs that closed shortly before the start of the fiscal 
		year or are scheduled to open in a future fiscal year but still 
		reported revenue or expenditure information for the current fiscal 
		year; and
		
		07 = Education service agency (ESA).	

	bound - 
	
	FY2013 CCD LEA documentation, p. 12-13 ("C:\Users\Victoria\Dropbox\
	Segregation\Documentation\CCD LEA Universe\Documentation_LEA_Universe_2013.pdf")
	
	(BOUND) Operational Status Code. This field contains a classification of 
	changes in an education agency’s boundaries since the last report to NCES. 
	All agencies are coded to reflect their status as reported for the 2012-13 
	school year. The valid responses include the following:
		1 = No significant boundary change for this agency since the last 
			report. Currently in operation.
		2 = Education agency has closed with no effect on another agency’s 
			boundaries.
		3 = New agency formed with no effect on another agency’s boundaries.
		4 = Agency was in existence, but not reported in previous year’s CCD 
			Agency Universe Survey, and is now being added.
		5 = Agency has undergone a significant change in geographic boundaries 
			or instructional responsibility.
		6 = Agency is temporarily closed and may reopen within 3 years.
		7 = Agency is scheduled to be operational within 2 years.
		8 = Agency was closed on previous year’s file but has reopened.
	
	Agencies with an operational status code of “2” remain in the file for one 
	year for historical purposes. Code “6” and “7” response options for the 
	BOUND field were added to the agency file starting in 2002–03. Code “8” 
	response option for the BOUND field was added to the agency file starting 
	in 2005–06.
	
	agcrt - 
	
	FY2013 F33 documentation, p. 17	("C:\Users\Victoria\Dropbox\Segregation\
	Documentation\F-33\Documentation_F33_2013.pdf")  
	
	The AGCHRT code is used to identify districts with charter schools. The 
	source of the AGCHRT code is the SY 2012-13 LEA Universe Survey, 
	Provisional Version 1a. The codes are as follows:
		1 = All associated schools are charter schools;
		2 = All associated schools are charter and noncharter schools;
		3 = All associated schools are noncharter schools; and
		N = Not applicable or code could not be determined (assigned to 
		school systems in the F-33 file, such as ESAs, that do not operate 
		schools, as well as to districts that are not in the CCD LEA universe 
		files).	
		
	ANSI state codes - 
	
	FY2013 CCD LEA documentation, p. 20 ("C:\Users\Victoria\Dropbox\
	Segregation\Documentation\CCD LEA Universe\Documentation_LEA_Universe_2013.pdf")
				
					ANSI			ABBR
		DOD			63				DD, AA, AE, AP, or US state
		BIE			59				BI or US state
		Samoa		60				AS
		Guam		66				GU
		Mariana	Is.	69				MP
		PR			72				PR
		Virgin Is.	78				VI
	
	*/

********************************************************************************
*END MATTER
********************************************************************************
capture log close
