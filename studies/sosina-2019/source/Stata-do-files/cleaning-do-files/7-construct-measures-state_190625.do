	
capture log close
macro drop _all
setdate
setdirectory

log using "Logs/7-construct-measures-state_${date}", replace text
********************************************************************************
*contruct-measures-state_$date: contruct the state level analytical file
*Written by Ericka Weathers (esw71@psu.edu)
*Edited by Victoria Sosina (vsosina@stanford.edu)
di "Date: $date"
********************************************************************************
/*Construct state level measures*/
********************************************************************************

version 13
set linesize 82
set more off, perm

********************************************************************************
*OPEN FILE
********************************************************************************

*set version of per pupil variables
global n 1 		

gen ppdenom = "${n}"
replace ppdenom = "ccd imp" if ppdenom == "1"
replace ppdenom = "rut member" if ppdenom == "2"

/*notes: 
- change prefix from "cwi" to "" use per pupil vars w/out cwi adjustments
- change n from "1" to "2" to use per pupil vars where denominator is from 
imp ccd (1) or rutgers member (2) */

********************************************************************************
*SES SEGREGATION
********************************************************************************

*Avg proportion poor in the avg blk, hsp, and wht students districts
foreach g in wht blk hsp asn ind tot {
	preserve
		*save labels
		foreach v of var *{
			local l`v' : variable label `v'
		}
		collapse ///
			segpov`g' 		= 	desc_perpov ///				//using pov
			segfl`g' 		= 	imp_perflunch ///			//using FL
			blkin`g' 		= 	imp_perblack ///			//bl enroll 
			hspin`g' 		= 	imp_perhisp ///				//hi enroll
			whasin`g'		= 	imp_perwhas ///				//wh/asian enroll
			whtin`g'		=	imp_perwhite ///			//wh enroll
			specin`g' 		= 	rut_perspeced ///			//speced enroll
			ellin`g' 		= 	rut_perell ///				//ell enroll 
			nschin`g' 		= 	imp_nsch ///				//nsch 	
			pschin`g' 		= 	p_sch	///					//sch per 1000
			exp_totexp`g' 	= 	cwippexp_totexp${n} /// 	//tot exp
			exp_instr`g'	= 	cwippexp_instr${n} ///  	//instruction
			exp_admin`g' 	= 	cwippexp_admin${n} /// 		//admin
			exp_social`g'	= 	cwippexp_social${n} ///  	//social serv.
			exp_infra`g'	= 	cwippexp_infra${n} ///	  	//infrastructure
			exp_other`g' 	= 	cwippexp_other${n} /// 		//other
			pexp_totexp`g' 	= 	propexp_totexp${n} /// 		//prop tot exp
			pexp_instr`g'	= 	propexp_instr${n} ///  		//prop instruction
			pexp_admin`g' 	= 	propexp_admin${n} /// 		//prop admin
			pexp_social`g'	= 	propexp_social${n} ///  	//prop social serv.
			pexp_infra`g'	= 	propexp_infra${n} ///	  	//prop infrastructure
			pexp_other`g' 	= 	propexp_other${n} /// 		//prop other			
			rev_totalrev`g' = 	cwipprev_totalrev${n} ///	//total rev
			rev_tfedrev`g' 	= 	cwipprev_tfedrev${n} ///	//fed rev 
			rev_tstrev`g' 	= 	cwipprev_tstrev${n} ///		//state rev
			rev_tlocrev`g' 	= 	cwipprev_tlocrev${n} ///	//loc rev 
			city`g'			=	urbanicity_1 ///			//city dis
			suburb`g'		=	urbanicity_2 ///			//suburban dis
			othgeo`g'		=	urbanicity_3 ///			//other geo dis
			stR`g'			= 	stud_teach	 ///			//stdt-tch ratio
			stRnout`g'		= 	stud_teach_nout	 ///		//no outlier vers.			
			[fw = n`g'], by(imp_fips year)
		
		*apply labels
		foreach v of var * {
			label variable `v' "`l`v''"
		}

		tempfile `g'avg
		save ``g'avg'
	restore
}


*Collapse counts to the state level
*save labels
foreach v of var *{
	local l`v' : variable label `v'
}

collapse 	(sum)   nwht nblk nhsp nasn nind ntot ///
			(sum) 	imp_totind imp_totasian imp_tothisp imp_totblack ///
					imp_totflunch imp_totwhite rut_pov517 ///
					imp_member rut_pop517 ///
			(mean)  imp_perind imp_perasian imp_perhisp imp_perblack ///
					imp_perflunch imp_perwhas imp_perwhite desc_perpov ///
			(first) ppdenom cwi ///
			, by(imp_fips year)

*apply labels
foreach v of var * {
	label variable `v' "`l`v''"
}
			
*Merge state level counts to group-specific files
foreach g in wht blk hsp asn ind tot {
	merge 1:1 imp_fips year using ``g'avg'
	drop _merge
}
su

*create state level proportions
gen prop_ind 	= imp_totind 	/	imp_member
gen prop_asian 	= imp_totasian	/	imp_member
gen prop_hisp 	= imp_tothisp	/	imp_member
gen prop_black 	= imp_totblack	/	imp_member
gen prop_flunch = imp_totflunch	/	imp_member
gen prop_whas 	= (imp_totwhite + imp_totasian)	/	imp_member
gen prop_white 	= imp_totwhite	/	imp_member
gen prop_pov 	= rut_pov517	/	rut_pop517

label variable prop_ind		"state proportion native american"
label variable prop_asian	"state proportion asian"
label variable prop_hisp	"state proportion hispanic"
label variable prop_black	"state proportion black"
label variable prop_flunch	"state proportion fl"
label variable prop_whas	"state proportion white/asian"
label variable prop_white	"state proportion white"
label variable prop_pov		"state proportion poor (saipe)"


	*---------------------
	*check that everything works
	foreach g in wht blk hsp asn ind {
		gen p`g' = n`g'/ntot 				//prop of students of a given race 
		
		*wgted disparities for each race
		gen wsegfl`g' 			= p`g' * segfl`g' 			//fl
		gen wsegpov`g' 			= p`g' * segpov`g'			//pov
		gen wblkin`g' 			= p`g' * blkin`g'			//bl enroll
		gen whspin`g' 			= p`g' * hspin`g'			//hi enroll
		gen wwhasin`g' 			= p`g' * whasin`g'			//wh/asian enroll
		gen wwhtin`g' 			= p`g' * whtin`g'			//wh enroll
		gen wspecin`g' 			= p`g' * specin`g'			//spec enroll
		gen wellin`g' 			= p`g' * ellin`g'			//ell enroll
		gen wnschin`g' 			= p`g' * nschin`g'			//nsch enroll			
		gen wpschin`g' 			= p`g' * pschin`g'			//sch per 1000 enroll			
		gen wexp_totexp`g' 		= p`g' * exp_totexp`g' 		//tot exp
		gen wexp_instr`g'	 	= p`g' * exp_instr`g'  		//instruction
		gen wexp_admin`g' 	 	= p`g' * exp_admin`g'  		//admin
		gen wexp_social`g'	 	= p`g' * exp_social`g'   	//social serv.
		gen wexp_infra`g'	 	= p`g' * exp_infra`g' 	  	//infrastructure
		gen wexp_other`g' 	 	= p`g' * exp_other`g' 		//other		
		gen wpexp_totexp`g' 	= p`g' * pexp_totexp`g' 	//prop tot exp
		gen wpexp_instr`g'	 	= p`g' * pexp_instr`g'  	//prop instruction
		gen wpexp_admin`g' 	 	= p`g' * pexp_admin`g'  	//prop admin
		gen wpexp_social`g'	 	= p`g' * pexp_social`g'   	//prop social serv.
		gen wpexp_infra`g'	 	= p`g' * pexp_infra`g' 	  	//prop infrastructure
		gen wpexp_other`g' 	 	= p`g' * pexp_other`g' 		//prop other
		gen wrev_totalrev`g' 	= p`g' * rev_totalrev`g' 	//total rev seg			
		gen wrev_tfedrev`g' 	= p`g' * rev_tfedrev`g' 	//fed rev seg			
		gen wrev_tstrev`g' 		= p`g' * rev_tstrev`g' 		//state rev seg			
		gen wrev_tlocrev`g'		= p`g' * rev_tlocrev`g' 	//loc rev seg	
		gen wcity`g'			= p`g' * city`g'			//city dis
		gen wsuburb`g'			= p`g' * suburb`g'			//suburb dis
		gen wothgeo`g'			= p`g' * othgeo`g'			//other geo dis
		gen wstR`g'				= p`g' * stR`g'				//stdt-tch ratio
		gen wstRnout`g'			= p`g' * stRnout`g'			//no outlier vers.		
	}
	
	*sum weighted disparities for all racial subgroups and compare to total
	foreach v in segfl segpov blkin hspin whasin whtin specin ellin nschin pschin ///
				 exp_totexp exp_instr exp_admin exp_social ///
				 exp_infra exp_other ///
				 pexp_totexp pexp_instr pexp_admin pexp_social ///
				 pexp_infra pexp_other ///
				 rev_totalrev rev_tfedrev rev_tstrev rev_tlocrev ///
				 city suburb othgeo stR stRnout{
				 
		egen w`v' = rsum(w`v'???)
		su w`v' `v'tot
		drop w`v'
	}
	//avg for everyone (*tot) is same as wgt avg of the group-specific (w*)
	//only differences are for observations where the sample size changes

	*drop intermediate variables
	foreach v in segfl segpov blkin hspin whasin whtin specin ellin nschin pschin ///
				 exp_totexp exp_instr exp_admin exp_social ///
				 exp_infra exp_other ///
				 pexp_totexp pexp_instr pexp_admin pexp_social ///
				 pexp_infra pexp_other ///				 
				 rev_totalrev rev_tfedrev rev_tstrev rev_tlocrev ///
				 city suburb othgeo stR stRnout{
		
		drop w`v'???

	}
	drop p??? 
	*---------------------

*Generate SES segregation variables
gen bwdiffl= segflblk - segflwht
gen hwdiffl= segflhsp - segflwht
gen bwdifpov= segpovblk - segpovwht
gen hwdifpov= segpovhsp - segpovwht

*Generate racial segregation variables
gen bwdifblk = blkinblk - blkinwht
gen hwdifhsp = hspinhsp - hspinwht
gen bwdifhsp = hspinblk - hspinwht
gen hwdifblk = blkinhsp - blkinwht

gen bwdifwhas = whasinblk - whasinwht
gen hwdifwhas = whasinhsp - whasinwht

gen bwdifwht = whtinblk	- whtinwht
gen hwdifwht = whtinhsp	- whtinwht
	
*Generate controls (racial disparities)
gen bwdifspec = specinblk - specinwht
gen hwdifspec = specinhsp - specinwht
gen bwdifnsch = nschinblk - nschinwht
gen hwdifnsch = nschinhsp - nschinwht

gen bwdifpsch = pschinblk - pschinwht
gen hwdifpsch = pschinhsp - pschinwht

gen bwdifell = ellinblk - ellinwht
gen hwdifell = ellinhsp - ellinwht

gen bwdifcity =	cityblk - citywht 
gen bwdifsuburb = suburbblk - suburbwht
gen bwdifothgeo = othgeoblk - othgeowht

gen hwdifcity =	cityhsp - citywht 
gen hwdifsuburb = suburbhsp - suburbwht
gen hwdifothgeo = othgeohsp - othgeowht

*Generate finance ratios
foreach g in wht blk hsp asn ind {
	*revenue
	gen `g'revtotR = rev_totalrev`g'	/	rev_totalrevtot	//total
	gen `g'revfedR = rev_tfedrev`g'		/	rev_tfedrevtot	//fed
	gen `g'revstateR = rev_tstrev`g'	/	rev_tstrevtot	//state
	gen `g'revlocR = rev_tlocrev`g'		/	rev_tlocrevtot	//local
	
	*expenditures
	gen `g'exptotR = exp_totexp`g'		/	exp_totexptot	//total
	gen `g'expinstrR = exp_instr`g'		/	exp_instrtot	//instructional	
	gen `g'expadminR = exp_admin`g'		/	exp_admintot	//admin
	gen `g'expsocialR = exp_social`g'	/	exp_socialtot	//social serv.
	gen `g'expinfraR = exp_infra`g'		/	exp_infratot	//infrastructure
	gen `g'expotherR = exp_other`g'		/	exp_othertot	//other
	
	*proportion expenditures
	gen `g'pexptotR = pexp_totexp`g'	/	pexp_totexptot	//total
	gen `g'pexpinstrR = pexp_instr`g'	/	pexp_instrtot	//instructional	
	gen `g'pexpadminR = pexp_admin`g'	/	pexp_admintot	//admin
	gen `g'pexpsocialR = pexp_social`g'	/	pexp_socialtot	//social serv.
	gen `g'pexpinfraR = pexp_infra`g'	/	pexp_infratot	//infrastructure
	gen `g'pexpotherR = pexp_other`g'	/	pexp_othertot	//other

}

*black-white and hispanic-white finance disparities
foreach f in 	revtotR revfedR revstateR revlocR ///
				exptotR expinstrR expadminR expsocialR expinfraR ///
				expotherR ///
				pexptotR pexpinstrR pexpadminR pexpsocialR pexpinfraR ///
				pexpotherR{
	*ratios
	gen bw`f' = blk`f'/wht`f'
	gen hw`f' = hsp`f'/wht`f'
}	

*black-white and hispanic-white disparities in dollar differences
foreach f in rev_totalrev rev_tfedrev rev_tstrev rev_tlocrev ///
			 exp_totexp exp_instr exp_admin exp_social exp_infra ///
			 exp_other{
	*dollar differences
	gen bwdd`f' = (`f'blk - `f'wht) * 1000
	gen hwdd`f' = (`f'hsp - `f'wht) * 1000

}

*Generate finance differences for the proportion variables
foreach f in totexp instr admin social infra other {
	gen bw`f' = pexp_`f'blk - pexp_`f'wht
	gen hw`f' = pexp_`f'hsp - pexp_`f'wht
	
}

*black-white and hispanic-white disparities in dollar differences - standardized
*find total expenditures in median year
preserve
	gen midexp_totexp = exp_totexptot if year == 2006
	gen midrev_totalrev = rev_totalrevtot if year == 2006
	collapse midexp_totexp midrev_totalrev, by(imp_fips)
	tempfile t
	save `t', replace
restore
merge m:1 imp_fips using `t', nogenerate

foreach f in rev_totalrev rev_tfedrev rev_tstrev rev_tlocrev {
	*dollar differences
	gen bwdd`f'_std = (((`f'blk - `f'wht) * 1000)/(midrev_totalrev*1000))*10000
	gen hwdd`f'_std = (((`f'hsp - `f'wht) * 1000)/(midrev_totalrev*1000))*10000

}	 

foreach f in exp_totexp exp_instr exp_admin exp_social exp_infra ///
			 exp_other{
	*dollar differences
	gen bwdd`f'_std = (((`f'blk - `f'wht) * 1000)/(midexp_totexp*1000))*10000
	gen hwdd`f'_std = (((`f'hsp - `f'wht) * 1000)/(midexp_totexp*1000))*10000

}	

	/*Take each state's funding in the middle year and divide all the 
	spending numbers for that state in all years by that number, then multiply 
	every number by 10k; coefficients would be like how much does enroll disp 
	affect spending disp, where spending disp is measured in dollars per 
	$10,000 of average spending by the state */

*student-teacher ratio disparities
gen bwdifstR = stRblk - stRwht
gen hwdifstR = stRhsp - stRwht

gen bwdifstRnout = stRnoutblk - stRnoutwht
gen hwdifstRnout = stRnouthsp - stRnoutwht
********************************************************************************
*OTHER VARIABLES FOR HETEROGENEITY CHECKS
********************************************************************************
*indicator for pre/post recession
gen recession = (year >= 2009)

label variable recession "Post recession (2009 or later)"

*trend in racial and SES segregation
levelsof imp_fips, local(state)

gen bwdifblk_trend = . 
gen hwdifhsp_trend = . 

gen bwdifpov_trend = . 
gen hwdifpov_trend = . 

foreach s of local state{
	qui reg bwdifblk year if imp_fips == `s'
	replace bwdifblk_trend = (`=_b[year]' > 0) if imp_fips == `s'
	
	qui reg hwdifhsp year if imp_fips == `s'
	replace hwdifhsp_trend = (`=_b[year]' > 0) if imp_fips == `s'

	qui reg bwdifpov year if imp_fips == `s'
	replace bwdifpov_trend = (`=_b[year]' > 0) if imp_fips == `s'
	
	qui reg hwdifpov year if imp_fips == `s'
	replace hwdifpov_trend = (`=_b[year]' > 0) if imp_fips == `s'
	
}

local text "increasing between 1999 and 2013"
label variable bwdifblk_trend "Black-White diff in Black enrollment `text'"
label variable hwdifhsp_trend "Latinx-White diff in Latinx enrollment `text'"
label variable bwdifpov_trend "Black-White diff in SAIPE poverty `text'"
label variable hwdifpov_trend "Latinx-White diff in SAIPE poverty `text'"

*change in segregation from prior year
preserve
	keep year imp_fips bwdifblk hwdifhsp bwdifpov hwdifpov
	reshape wide bwdifblk hwdifhsp bwdifpov hwdifpov, i(imp_fips) j(year)

	forvalues t = 2000/2013{
		local tminus1 = `t' - 1
		gen bwdifblk_d`t' = bwdifblk`t' - bwdifblk`tminus1'
		gen hwdifhsp_d`t' = hwdifhsp`t' - hwdifhsp`tminus1'
		
		gen bwdifpov_d`t' = bwdifpov`t' - bwdifpov`tminus1'
		gen hwdifpov_d`t' = hwdifpov`t' - hwdifpov`tminus1'	
	}
	
	keep imp_fips *_d????
	reshape long bwdifblk_d hwdifhsp_d bwdifpov_d hwdifpov_d, ///
		i(imp_fips) j(year)
		
	rename bwdifblk_d delta_bwdifblk
	rename hwdifhsp_d delta_hwdifhsp
	rename bwdifpov_d delta_bwdifpov
	rename hwdifpov_d delta_hwdifpov
	
	tempfile t
	save `t', replace
restore

merge 1:1 imp_fips year using `t', nogenerate

gen bwdifblk_inc = (delta_bwdifblk >= 0)
gen hwdifblk_inc = (delta_hwdifhsp >= 0)
gen bwdifpov_inc = (delta_bwdifpov >= 0)
gen hwdifpov_inc = (delta_hwdifpov >= 0)

local text "increased between current and prior year"
label variable bwdifblk_inc "Black-White diff in Black enrollment `text'" 
label variable hwdifblk_inc "Latinx-White diff in Latinx enrollment `text'"
label variable bwdifpov_inc "Black-White diff in poverty `text'" 
label variable hwdifpov_inc "Latinx-White diff in poverty `text'"

*starting point of inequality 
gen expfavorsblk = (bwddexp_totexp_std >= 0) & !missing(bwddexp_totexp_std)
gen expfavorshsp = (hwddexp_totexp_std >= 0) & !missing(hwddexp_totexp_std)

local text "student's district > = White"
label variable expfavorsblk "Total expenditures in typical Black `text'"
label variable expfavorshsp "Total expenditures in typical Latinx `text'"


********************************************************************************
*RENAME AND LABEL
********************************************************************************
*rename rev variables 
rename rev_totalrevwht	rev_totalwht
rename rev_tstrevblk	rev_stateblk
rename rev_totalrevasn	rev_totalasn
rename rev_tstrevind	rev_stateind
rename rev_tfedrevwht	rev_fedwht
rename rev_tlocrevblk	rev_locblk
rename rev_tfedrevasn	rev_fedasn
rename rev_tlocrevind	rev_locind
rename rev_tstrevwht	rev_statewht
rename rev_totalrevhsp	rev_totalhsp
rename rev_tstrevasn	rev_stateasn
rename rev_totalrevtot	rev_totaltot
rename rev_tlocrevwht	rev_locwht
rename rev_tfedrevhsp	rev_fedhsp
rename rev_tlocrevasn	rev_locasn
rename rev_tfedrevtot	rev_fedtot
rename rev_totalrevblk	rev_totalblk
rename rev_tstrevhsp	rev_statehsp
rename rev_totalrevind	rev_totalind
rename rev_tstrevtot	rev_statetot
rename rev_tfedrevblk	rev_fedblk
rename rev_tlocrevhsp	rev_lochsp
rename rev_tfedrevind	rev_fedind
rename rev_tlocrevtot	rev_loctot

*SES segregation - saipe
label variable segpovwht "avg proportion poor in typical students' districts: white (saipe)"
label variable segpovblk "avg proportion poor in typical students' districts: black (saipe)"
label variable segpovhsp "avg proportion poor in typical students' districts: hispanic (saipe)"
label variable segpovasn "avg proportion poor in typical students' districts: asian (saipe)"
label variable segpovind "avg proportion poor in typical students' districts: nat am (saipe)"
label variable segpovtot "avg proportion poor in typical students' districts: tot (saipe)"

*SES segregation - flunch
label variable segflwht "avg proportion poor in typical students' districts: white (flunch)"
label variable segflblk "avg proportion poor in typical students' districts: black (flunch)"
label variable segflhsp "avg proportion poor in typical students' districts: hispanic (flunch)"
label variable segflasn "avg proportion poor in typical students' districts: asian (flunch)"
label variable segflind "avg proportion poor in typical students' districts: nat am (flunch)"
label variable segfltot "avg proportion poor in typical students' districts: tot (flunch)"

*racial enrollment seg - blk
label variable blkinwht "avg proportion black in typical students' districts: white" 
label variable blkinblk "avg proportion black in typical students' districts: black" 
label variable blkinhsp "avg proportion black in typical students' districts: hispanic" 
label variable blkinasn "avg proportion black in typical students' districts: asian" 
label variable blkinind "avg proportion black in typical students' districts: nat am" 
label variable blkintot "avg proportion black in typical students' districts: tot"

*racial enrollment seg - hsp
label variable hspinwht "avg proportion hispanic in typical students' districts: white"
label variable hspinblk "avg proportion hispanic in typical students' districts: black"
label variable hspinhsp "avg proportion hispanic in typical students' districts: hispanic"
label variable hspinasn "avg proportion hispanic in typical students' districts: asian"
label variable hspinind "avg proportion hispanic in typical students' districts: nat am"
label variable hspintot "avg proportion hispanic in typical students' districts: tot"

*racial enrollment seg - whas
label variable whasinwht "avg proportion white/asian in typical students' districts: white"
label variable whasinblk "avg proportion white/asian in typical students' districts: black"
label variable whasinhsp "avg proportion white/asian in typical students' districts: hispanic"
label variable whasinasn "avg proportion white/asian in typical students' districts: asian"
label variable whasinind "avg proportion white/asian in typical students' districts: nat am"
label variable whasintot "avg proportion white/asian in typical students' districts: tot"

*racial enrollment seg - wh
label variable whtinwht "avg proportion white in typical students' districts: white"
label variable whtinblk "avg proportion white in typical students' districts: black"
label variable whtinhsp "avg proportion white in typical students' districts: hispanic"
label variable whtinasn "avg proportion white in typical students' districts: asian"
label variable whtinind "avg proportion white in typical students' districts: nat am"
label variable whtintot "avg proportion white in typical students' districts: tot"

*special education enrollment seg 
label variable specinwht "avg proportion special ed in typical students' districts: white"
label variable specinblk "avg proportion special ed in typical students' districts: black"
label variable specinhsp "avg proportion special ed in typical students' districts: hispanic"
label variable specinasn "avg proportion special ed in typical students' districts: asian"
label variable specinind "avg proportion special ed in typical students' districts: nat am"
label variable specintot "avg proportion special ed in typical students' districts: tot"

*ell enrollment seg
label variable ellinwht "avg proportion ELL in typical students' districts: white"
label variable ellinblk "avg proportion ELL in typical students' districts: black"
label variable ellinhsp "avg proportion ELL in typical students' districts: hispanic"
label variable ellinasn "avg proportion ELL in typical students' districts: asian"
label variable ellinind "avg proportion ELL in typical students' districts: nat am"
label variable ellintot "avg proportion ELL in typical students' districts: tot"

*nsch seg
label variable nschinwht "avg number of schools in typical students' districts: white" 
label variable nschinblk "avg number of schools in typical students' districts: black" 
label variable nschinhsp "avg number of schools in typical students' districts: hispanic" 
label variable nschinasn "avg number of schools in typical students' districts: asian" 
label variable nschinind "avg number of schools in typical students' districts: nat am" 
label variable nschintot "avg number of schools in typical students' districts: tot"

*psch seg
label variable pschinwht "avg prop of school per 1000 in typical students' districts: white" 
label variable pschinblk "avg prop of school per 1000 in typical students' districts: black" 
label variable pschinhsp "avg prop of school per 1000 in typical students' districts: hispanic" 
label variable pschinasn "avg prop of school per 1000 in typical students' districts: asian" 
label variable pschinind "avg prop of school per 1000 in typical students' districts: nat am" 
label variable pschintot "avg prop of school per 1000 in typical students' districts: tot"


*urbanicity seg: city district
label variable citywht "avg proportion city district in typical students' districts: white"
label variable cityblk "avg proportion city district in typical students' districts: black"
label variable cityhsp "avg proportion city district in typical students' districts: hispanic"
label variable cityasn "avg proportion city district in typical students' districts: asian"
label variable cityind "avg proportion city district in typical students' districts: nat am"
label variable citytot "avg proportion city district in typical students' districts: tot"

*urbanicity seg: suburban district
label variable suburbwht "avg proportion suburban district in typical students' districts: white"
label variable suburbblk "avg proportion suburban district in typical students' districts: black"
label variable suburbhsp "avg proportion suburban district in typical students' districts: hispanic"
label variable suburbasn "avg proportion suburban district in typical students' districts: asian"
label variable suburbind "avg proportion suburban district in typical students' districts: nat am"
label variable suburbtot "avg proportion suburban district in typical students' districts: tot"


*urbanicity seg: oth geo district
label variable othgeowht "avg proportion oth geo district in typical students' districts: white"
label variable othgeoblk "avg proportion oth geo district in typical students' districts: black"
label variable othgeohsp "avg proportion oth geo district in typical students' districts: hispanic"
label variable othgeoasn "avg proportion oth geo district in typical students' districts: asian"
label variable othgeoind "avg proportion oth geo district in typical students' districts: nat am"
label variable othgeotot "avg proportion oth geo district in typical students' districts: tot"


*label expenditures - avg expenditures in typical students' districts by race
foreach V in exp_totexp exp_instr exp_admin exp_social exp_infra exp_other{
	*expenditure options
	if strpos("`V'","totexp")>0{
		local expenditure "total exp"
	}
	if strpos("`V'","instr")>0{
		local expenditure "instructional exp"
	}
	if strpos("`V'","admin")>0{
		local expenditure "admin exp"
	}
	if strpos("`V'","social")>0{
		local expenditure "soc serv exp"
	}

	if strpos("`V'","infra")>0{
		local expenditure "infrastructure exp"
	}
	else if strpos("`V'","other")>0{
		local expenditure "other exp"
	}

	foreach v of var `V'*{
		*race options
		if substr("`v'",length("`v'")-2,.)=="wht"{
			local race "white"
		}

		if substr("`v'",length("`v'")-2,.)=="blk"{
			local race "black"
		}

		if substr("`v'",length("`v'")-2,.)=="hsp"{
			local race "hispanic"
		}
		
		if substr("`v'",length("`v'")-2,.)=="asn"{
			local race "asian"
		}

		if substr("`v'",length("`v'")-2,.)=="ind"{
			local race "nat am"
		}

		if substr("`v'",length("`v'")-2,.)=="tot"{
			local race "tot"
		}
		
		*label variable
		label variable `v' "avg `expenditure' in typical students' districts: `race'"
	}
}

*label expenditures - avg expenditures in typical students' districts by race
foreach V in pexp_totexp pexp_instr pexp_admin pexp_social pexp_infra pexp_other{
	*expenditure options
	if strpos("`V'","totexp")>0{
		local expenditure "total exp"
	}
	if strpos("`V'","instr")>0{
		local expenditure "instructional exp"
	}
	if strpos("`V'","admin")>0{
		local expenditure "admin exp"
	}
	if strpos("`V'","social")>0{
		local expenditure "soc serv exp"
	}

	if strpos("`V'","infra")>0{
		local expenditure "infrastructure exp"
	}
	else if strpos("`V'","other")>0{
		local expenditure "other exp"
	}

	foreach v of var `V'*{
		*race options
		if substr("`v'",length("`v'")-2,.)=="wht"{
			local race "white"
		}

		if substr("`v'",length("`v'")-2,.)=="blk"{
			local race "black"
		}

		if substr("`v'",length("`v'")-2,.)=="hsp"{
			local race "hispanic"
		}
		
		if substr("`v'",length("`v'")-2,.)=="asn"{
			local race "asian"
		}

		if substr("`v'",length("`v'")-2,.)=="ind"{
			local race "nat am"
		}

		if substr("`v'",length("`v'")-2,.)=="tot"{
			local race "tot"
		}
		
		*label variable
		label variable `v' "prop `expenditure' in typical students' districts: `race'"
	}
}

*label revenues - avg revenues in typical students' districts by race
foreach V in rev_total rev_fed rev_state rev_loc {
	*revenue options
	if strpos("`V'","total")>0{
		local revenue "total rev"
	}
	if strpos("`V'","fed")>0{
		local revenue "fed rev"
	}
	if strpos("`V'","state")>0{
		local revenue "state rev"
	}
	else if strpos("`V'","loc")>0{
		local revenue "local rev"
	}

	foreach v of var `V'*{
		*race options
		if substr("`v'",length("`v'")-2,.)=="wht"{
			local race "white"
		}

		if substr("`v'",length("`v'")-2,.)=="blk"{
			local race "black"
		}

		if substr("`v'",length("`v'")-2,.)=="hsp"{
			local race "hispanic"
		}
		
		if substr("`v'",length("`v'")-2,.)=="asn"{
			local race "asian"
		}

		if substr("`v'",length("`v'")-2,.)=="ind"{
			local race "nat am"
		}

		if substr("`v'",length("`v'")-2,.)=="tot"{
			local race "tot"
		}
		
		*label variable
		label variable `v' "avg `revenue' in typical students' districts: `race'"
	}
}

*label poverty, enrollment, special education, ell, and n sch disparity measures
foreach v of var bwdif* hwdif*{
	*race options
	if strpos("`v'","bw")>0{
		local race "black-white"
	}
	if strpos("`v'","hw")>0{
		local race "hispanic-white"
	}
	
	*disparity options
	if strpos("`v'","fl")>0{
		local disparity "flunch"
	}
	if strpos("`v'","pov")>0{
		local disparity "poverty"
	}
	if strpos("`v'","blk")>0{
		local disparity "black enroll"
	}
	if strpos("`v'","hsp")>0{
		local disparity "hispanic enroll"
	}
	if strpos("`v'","wht")>0{
		local disparity "white enroll"
	}	
	if strpos("`v'","whas")>0{
		local disparity "white/asian enroll"
	}	
	if strpos("`v'","spec")>0{
		local disparity "spec ed enroll"
	}
	if strpos("`v'","ell")>0{
		local disparity "ell enroll"
	}
	if strpos("`v'","nsch")>0{
		local disparity "n sch enroll"
	}		
	if strpos("`v'","psch")>0{
		local disparity "p sch enroll"
	}		
	if strpos("`v'","city")>0{
		local disparity "city district"
	}		
	if strpos("`v'","suburb")>0{
		local disparity "suburban district"
	}		
	if strpos("`v'","othgeo")>0{
		local disparity "oth geo district"
	}
	
	*label variable
		label variable `v' "`race' `disparity' disparity"
	}


*label revenue ratios - 
*ratio of subgroup specific avg revenues to avg revenues for all students
foreach v of var ???rev*{
	*revenue options
	if strpos("`v'","tot")>0{
		local revenue "total rev"
	}
	if strpos("`v'","fed")>0{
		local revenue "fed rev"
	}
	if strpos("`v'","state")>0{
		local revenue "state rev"
	}
	else if strpos("`v'","loc")>0{
		local revenue "local rev"
	}
	*race options
	if substr("`v'",length("`v'")-2,.)=="wht"{
		local race "white"
	}

	if substr("`v'",length("`v'")-2,.)=="blk"{
		local race "black"
	}

	if substr("`v'",length("`v'")-2,.)=="hsp"{
		local race "hispanic"
	}
	
	if substr("`v'",length("`v'")-2,.)=="asn"{
		local race "asian"
	}

	if substr("`v'",length("`v'")-2,.)=="ind"{
		local race "nat am"
	}

	*label variable
	label variable `v' "ratio of `race' to total avg `revenue'"
}


*label expenditure ratios - 
*ratio of subgroup specific avg expenditures to avg expenditures for all students
foreach v of var ???exp*{
	*expenditure options
	if strpos("`v'","totexp")>0{
		local expenditure "total exp"
	}
	if strpos("`v'","instr")>0{
		local expenditure "instructional exp"
	}
	if strpos("`v'","admin")>0{
		local expenditure "admin exp"
	}
	if strpos("`v'","social")>0{
		local expenditure "soc serv exp"
	}

	if strpos("`v'","infra")>0{
		local expenditure "infrastructure exp"
	}
	else if strpos("`v'","other")>0{
		local expenditure "other exp"
	}
	
	*race options
	if substr("`v'",1,3)=="wht"{
		local race "white"
	}

	if substr("`v'",1,3)=="blk"{
		local race "black"
	}

	if substr("`v'",1,3)=="hsp"{
		local race "hispanic"
	}
	
	if substr("`v'",1,3)=="asn"{
		local race "asian"
	}

	if substr("`v'",1,3)=="ind"{
		local race "nat am"
	}

	*label variable
	label variable `v' "ratio of `race' to total avg `expenditure'"
}

*label expenditure proportion ratios - 
*ratio of subgroup specific avg expenditures to avg expenditures for all students
foreach v of var ???pexp*{
	*expenditure options
	if strpos("`v'","totexp")>0{
		local expenditure "total exp"
	}
	if strpos("`v'","instr")>0{
		local expenditure "instructional exp"
	}
	if strpos("`v'","admin")>0{
		local expenditure "admin exp"
	}
	if strpos("`v'","social")>0{
		local expenditure "soc serv exp"
	}

	if strpos("`v'","infra")>0{
		local expenditure "infrastructure exp"
	}
	else if strpos("`v'","other")>0{
		local expenditure "other exp"
	}
	
	*race options
	if substr("`v'",1,3)=="wht"{
		local race "white"
	}

	if substr("`v'",1,3)=="blk"{
		local race "black"
	}

	if substr("`v'",1,3)=="hsp"{
		local race "hispanic"
	}
	
	if substr("`v'",1,3)=="asn"{
		local race "asian"
	}

	if substr("`v'",1,3)=="ind"{
		local race "nat am"
	}

	*label variable
	label variable `v' "ratio of `race' to total prop `expenditure'"
}

*label black/white and hispanic/white expenditure and revenue ratios - 
*ratio of black finances ratio to white finance ratio
foreach v of var bw*R hw*R{
	*race options
	if strpos("`v'","bw")>0{
		local race "black-white"
	}
	if strpos("`v'","hw")>0{
		local race "hispanic-white"
	}
	
	*expenditure options
	if strpos("`v'","exptot")>0{
		local disparity "total exp"
	}
	if strpos("`v'","instr")>0{
		local disparity "instructional exp"
	}
	if strpos("`v'","admin")>0{
		local disparity "admin exp"
	}
	if strpos("`v'","social")>0{
		local disparity "soc serv exp"
	}

	if strpos("`v'","infra")>0{
		local disparity "infrastructure exp"
	}
	else if strpos("`v'","other")>0{
		local disparity "other exp"
	}
	
	*revenue options
	if strpos("`v'","revtot")>0{
		local disparity "total rev"
	}
	if strpos("`v'","fed")>0{
		local disparity "fed rev"
	}
	if strpos("`v'","state")>0{
		local disparity "state rev"
	}
	else if strpos("`v'","loc")>0{
		local disparity "local rev"
	}
	
	
	*label variable
	label variable `v' "`race' `disparity' ratio"
	}
	
*label black/white and hispanic/white expenditure and revenue ratios - 
*ratio of black finances ratio to white finance ratio
foreach v of var bwdd* hwdd*{
	*race options
	if strpos("`v'","bw")>0{
		local race "black-white"
	}
	if strpos("`v'","hw")>0{
		local race "hispanic-white"
	}
	
	*expenditure options
	if strpos("`v'","totexp")>0{
		local disparity "total exp"
	}
	if strpos("`v'","instr")>0{
		local disparity "instructional exp"
	}
	if strpos("`v'","admin")>0{
		local disparity "admin exp"
	}
	if strpos("`v'","social")>0{
		local disparity "soc serv exp"
	}

	if strpos("`v'","infra")>0{
		local disparity "infrastructure exp"
	}
	else if strpos("`v'","other")>0{
		local disparity "other exp"
	}
	
	*revenue options
	if strpos("`v'","totalrev")>0{
		local disparity "total rev"
	}
	if strpos("`v'","fed")>0{
		local disparity "fed rev"
	}
	if strpos("`v'","tst")>0{
		local disparity "state rev"
	}
	else if strpos("`v'","loc")>0{
		local disparity "local rev"
	}
	
	
	*label variable
	label variable `v' "`race' `disparity' dollar difference"
	}
	
*label black/white and hispanic/white expenditure and revenue ratios - 
*ratio of black finances ratio to white finance ratio
foreach v of var bwdd*std hwdd*std{
	*race options
	if strpos("`v'","bw")>0{
		local race "black-white"
	}
	if strpos("`v'","hw")>0{
		local race "hispanic-white"
	}
	
	*expenditure options
	if strpos("`v'","totexp")>0{
		local disparity "total exp"
	}
	if strpos("`v'","instr")>0{
		local disparity "instructional exp"
	}
	if strpos("`v'","admin")>0{
		local disparity "admin exp"
	}
	if strpos("`v'","social")>0{
		local disparity "soc serv exp"
	}

	if strpos("`v'","infra")>0{
		local disparity "infrastructure exp"
	}
	else if strpos("`v'","other")>0{
		local disparity "other exp"
	}
	
	*revenue options
	if strpos("`v'","totalrev")>0{
		local disparity "total rev"
	}
	if strpos("`v'","fed")>0{
		local disparity "fed rev"
	}
	if strpos("`v'","tst")>0{
		local disparity "state rev"
	}
	else if strpos("`v'","loc")>0{
		local disparity "local rev"
	}
	
	
	*label variable
	label variable `v' "`race' `disparity' dollar difference (standardized)"
	}
		
	
*label black/white and hispanic/white expenditure and revenue ratios - 
*ratio of black finances ratio to white finance ratio
foreach v of var bwpexp*R hwpexp*R{
	*race options
	if strpos("`v'","bw")>0{
		local race "black-white"
	}
	if strpos("`v'","hw")>0{
		local race "hispanic-white"
	}
	
	*expenditure options
	if strpos("`v'","exptot")>0{
		local disparity "total exp"
	}
	if strpos("`v'","instr")>0{
		local disparity "instructional exp"
	}
	if strpos("`v'","admin")>0{
		local disparity "admin exp"
	}
	if strpos("`v'","social")>0{
		local disparity "soc serv exp"
	}

	if strpos("`v'","infra")>0{
		local disparity "infrastructure exp"
	}
	else if strpos("`v'","other")>0{
		local disparity "other exp"
	}
	
	*label variable
	label variable `v' "`race' proportion `disparity' ratio"
	}
	
	label variable bwtotexp "black-white difference in prop: total exp"
	label variable bwinstr  "black-white difference in prop: instr exp"
	label variable bwadmin 	"black-white difference in prop: admin exp"
	label variable bwsocial "black-white difference in prop: social serv exp"
	label variable bwinfra  "black-white difference in prop: infra exp"
	label variable bwother 	"black-white difference in prop: other exp"
	
	label variable hwtotexp "hispanic-white difference in prop: total exp"
	label variable hwinstr 	"hispanic-white difference in prop: instr exp"
	label variable hwadmin 	"hispanic-white difference in prop: admin exp"
	label variable hwsocial "hispanic-white difference in prop: social serv exp"
	label variable hwinfra 	"hispanic-white difference in prop: infra exp"
	label variable hwother 	"hispanic-white difference in prop: other exp"
	
	label variable bwdifstR "black-white student-teacher ratio disparity"
	label variable hwdifstR "hispanic-white student-teacher ratio disparity"
	
	label variable bwdifstRnout "black-white student-teacher ratio disparity(no outliers)"
	label variable hwdifstRnout "hispanic-white student-teacher ratio disparity (no outliers)"	
	
********************************************************************************
*INDICATOR FOR REDUCED SAMPLE
********************************************************************************
gen red_samp =  !missing(bwdifspec) & !missing(bwdifell) & ///
				!missing(bwdifcity) & !missing(bwdifsuburb)
	
********************************************************************************
*END MATTER
********************************************************************************
capture log close
