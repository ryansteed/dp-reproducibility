clear all
set max_memory 30g
set matsize 11000
set more off

*** EDIT by Donna
do 0_macro_libraries.do
*** Load the data --------------------------------------------------------------
use $processed/data_for_analysis.dta, clear
*** EDITED by Ryan
xtset id_upp date
***
*** -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** DESCRIPTIVE STATISTICS ---------------------------------------------------------------------------------------------------------------------------------------------------------------
*** -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*** TABLE A.1 ***---------------------------------------------------------------
preserve
bysort upp: keep if _n==1
keep upp time_bope time_upp effpolice nbredefavela population gang
order upp time_bope time_upp effpolice population nbredefavela gang
export excel using "$results/tableA1.xls", firstrow(variables) replace
restore


*** TABLE A.2 ***---------------------------------------------------------------
eststo clear
estpost cor perc_proprio perc_alphabete perc_jeune perc_potable perc_elec perc_egout revenu_tete, matrix listwise
esttab,  unstack not noobs nostar compress
esttab using $results/tableA2.rtf , unstack not noobs nostar  replace


*** TABLE 1 ***-----------------------------------------------------------------
eststo clear
estpost sum desc_pre_murder desc_pre_violencenokill desc_pre_totalrobbery  desc_pre_totaltheft desc_pre_policeaction  desc_pre_policekill  desc_pre_threat  desc_pre_rape desc_pre_extortion desc_pre_totevent  desc_pre_accident, listwise
esttab using $results/table1_col12.rtf, cells("mean(fmt(a1)) sd") nonumber replace
estpost sum desc_post_murder desc_post_violencenokill desc_post_totalrobbery  desc_post_totaltheft desc_post_policeaction  desc_post_policekill  desc_post_threat  desc_post_rape desc_post_extortion desc_post_totevent  desc_post_accident, listwise
esttab using $results/table1_col34.rtf, cells("mean(fmt(a1)) sd") nonumber replace


*** TABLE 2 *** ----------------------------------------------------------------
preserve
import delimited $data_socio,  varnames(1) clear 
rename(rev_par_tete personne_par_domicile proportion_proprietaire_logement proportion_electricite proportion_eau_potable proportion_analphabete_15_plus) ///
		(income sizehouse homeowner electric water illiterate)
rename (domicile nbre_15_plus) (nbhouse nb_15_more)
* statistics favelas vs no favelas
bysort favela: asgen WM_income = income, w(population)
foreach v in sizehouse homeowner electric water {
 	bysort favela: asgen WM_`v' = `v' , w(nbhouse)
}
bysort favela: asgen WM_illiterate = illiterate, w(nb_15_more)
* statistics favelas (UPP yes or no) vs no favelas (UPP yes or no)
bysort favela upp: asgen WM_upp_income = income, w(population)
foreach v in sizehouse homeowner electric water {
 	bysort favela upp: asgen WM_upp_`v' = `v' , w(nbhouse)
}
bysort favela upp: asgen WM_upp_illiterate = illiterate, w(nb_15_more)
bysort favela upp: keep if _n==1
keep favela upp WM_*
* Store results
mkmat WM_income WM_sizehouse WM_homeowner WM_electric WM_water WM_illiterate, matrix(fav)
mkmat WM_upp_income WM_upp_sizehouse WM_upp_homeowner WM_upp_electric WM_upp_water WM_upp_illiterate, matrix(fav_upp)
mat result=J(6,6,.) //Defining empty matrix
mat rownames result = "Income" "Size of household" "Homeowner" "Electricity" "Water" "Illiterate"
mat colnames result = "Favela" "NoFavela" "FavelaUPP" "FavelaNoUPP" "NoFavelaUPP" "NoFavelaNoUPP"
forv n=1/6 {
	mat result[`n',1]=fav[3,`n']
	mat result[`n',2]=fav[1,`n']
	mat result[`n',3]=fav_upp[4,`n']
	mat result[`n',4]=fav_upp[3,`n']
	mat result[`n',5]=fav_upp[2,`n']
	mat result[`n',6]=fav_upp[1,`n']
}
mat list result
mata: result_rounded=round(st_matrix("result"),.01) // round all values to two decimals in Mata
mata: st_matrix("result2",result_rounded)
mat rownames result2 = "Income" "Size of household" "Homeowner" "Electricity" "Water" "Illiterate"
mat colnames result2 = "Favela" "NoFavela" "FavelaUPP" "FavelaNoUPP" "NoFavelaUPP" "NoFavelaNoUPP"
mat list result2
putexcel set $results/table2, replace
putexcel B1=("Favela") C1=("NoFavela") D1=("FavelaUPP") E1=("FavelaNoUPP") F1=("NoFavelaUPP") G1=("NoFavelaNoUPP")
putexcel A2=("Income") A3=("Size of household") A4=("Homeowner") A5=("Electricity") A6=("Water") A7=("Illiterate")
putexcel B2 = matrix(result2)
restore


*** TABLE 6 ***-----------------------------------------------------------------
bysort gang_bis: eststo: quietly estpost summarize desc_pre_murder desc_pre_violencenokill desc_pre_totalrobbery  desc_pre_totaltheft desc_pre_policeaction  desc_pre_policekill  desc_pre_threat  desc_pre_rape desc_pre_extortion desc_pre_totevent  desc_pre_accident, listwise
esttab using $results/table6.rtf, cells("mean(fmt(a1)) sd") label nodepvar replace


*** FIGURE 1 and FIGURE A.1 ***-------------------------------------------------
preserve
	* Aggregate crime data inside UPPs at the level of Rio de Janeiro x Month
	collapse (first) time (sum)  murder violencenokill policeaction drugarrest armarrest policekill rape totalrobbery totaltheft threat extortion accident, by(date)
	tempfile x y
	save `x', replace
	* Add crime data (outside UPPs) at the DP level and population (outside UPPs) at the DP level
	* Warning: variable "armarrest", "occurrenceswithflagrante" and "compliancewarrantofarrest" does not exist in the DP data
	import delimited $spillover/CrimeDP_without_UPP.csv, clear
	gen policeaction_noupp= drugarrest + carrecovery
	gen drugarrest_noupp = drugarrest
	gen policekill_noupp=resistancetodeathofpolic
	gen murder_noupp =  homicideintentional + bodyinjurydeathfollowed + robberydeathfollowed
	gen violencenokill_noupp = bodyinjuryintentional + attemptedmurder
	gen accident_noupp=homicidenointentional + bodyinjurynointentional 
	ren (rape totalrobbery totaltheft threat extortion) (rape_noupp robbery_noupp theft_noupp threat_noupp extortion_noupp)
	gen annee=.
	forv j=1/10 {
		replace annee = 2006 + `j' if inrange(date,`=`j'*12-11',`=`j'*12')
	}
	keep dp date annee policeaction_noupp drugarrest_noupp policekill_noupp murder_noupp violencenokill_noupp rape_noupp robbery_noupp theft_noupp threat_noupp extortion_noupp accident_noupp
	* Aggregate crime data outside UPPs at the level of Rio de Janeiro x Month
	collapse (first) annee (sum) policeaction_noupp drugarrest_noupp policekill_noupp murder_noupp violencenokill_noupp rape_noupp robbery_noupp theft_noupp threat_noupp extortion_noupp accident_noupp, by(date)
	merge 1:1 date using `x', nogen
	* Aggregate crime data a the level Rio de Janeiro x Year
	collapse (sum) policeaction_noupp drugarrest_noupp policekill_noupp murder_noupp violencenokill_noupp rape_noupp robbery_noupp theft_noupp threat_noupp extortion_noupp accident_noupp murder violencenokill policeaction drugarrest armarrest policekill rape totalrobbery totaltheft threat extortion accident , by(annee)
	drop if annee==2016
	* Add time-varying population for UPPs and for the rest of the City of Rio de Janeiro
	save `y', replace
	import excel $source/ISP/PopulacaoProjecaoUpp.xlsx, sheet("populacao") firstrow allstring clear
	destring Ano Estado Capital UPP, replace
	gen pop_rio_noupp = Capital - UPP
	rename Ano annee
	rename UPP pop_upp
	keep annee pop_rio_noupp pop_upp
	keep if inrange(annee,2007,2015)
	merge 1:m annee using `y'
	* Build the variables of interest
	foreach var in policeaction_noupp drugarrest_noupp policekill_noupp murder_noupp violencenokill_noupp rape_noupp robbery_noupp theft_noupp threat_noupp extortion_noupp accident_noupp {
		gen p_`var' = `var' * 100000 / pop_rio_noupp
	}
	foreach var in murder violencenokill policeaction drugarrest armarrest policekill rape totalrobbery totaltheft threat extortion accident {
		gen p_`var' = `var' * 100000 / pop_upp
	}
	rename annee year
	label var year "Year"
	* FIGURE 1(a)
	scatter p_murder p_murder_noupp year, ms(O D) connect(l l l) lpattern("l" "_") legend(label(1 "Murder UPP") label(2 "Murder Non-UPP")) graphregion(color(white)) ytitle("Number of events per 100,000 in Rio")
	graph export $results/figure1a_Murder_UPP_noUPP.pdf, as(pdf) replace
	* FIGURE 1(b)
	scatter p_violencenokill p_violencenokill_noupp year, ms(O D) connect(l l) lpattern("l" "_") legend(label(1 "Assault UPP") label(2 "Assault Non-UPP")) graphregion(color(white)) ytitle("Number of events per 100,000 in Rio")
	graph export $results/figure1b_Assault_UPP_noUPP.pdf, as(pdf) replace
	* FiGURE A.1(a)
	scatter p_policeaction p_policeaction_noupp year, ms(O D) connect(l l) lpattern("l" "_") legend(label(1 "Police Action UPP") label(2 "Police Action Non-UPP")) graphregion(color(white)) ytitle("Number of events per 100,000 in Rio")
	graph export $results/figureA1a_Policeaction_UPP_noUPP.pdf, as(pdf) replace
	* FiGURE A.1(b)
	scatter p_policekill p_policekill_noupp year, ms(O D) connect(l l) lpattern("l" "_") legend(label(1 "Police Killings UPP") label(2 "Police Killings Non-UPP")) graphregion(color(white)) ytitle("Number of events per 100,000 in Rio")
	graph export $results/figureA1b_Policekill_UPP_noUPP.pdf, as(pdf) replace
restore


*** FIGURE B.2 and FIGURE B.3 *** ----------------------------------------------
* No obvious correlation between  the timing of the policy and pre-treatment characteristics of UPPs
preserve
collapse (first) time_upp gang pop1 perc_proprio perc_alphabete perc_jeune perc_effpolice perc_elec perc_egout perc_potable perc_ordure perc_infsmic perc_tenxsmic revenu_tete densite_pop  altitude_diff pre_p1_murder pre_p1_violencenokill pre_p1_totaltheft pre_p1_totalrobbery,  by(upp)
sort time_upp upp
* FIGURE B.2(a)
scatter pop1 time_upp, sort ms(O) connect(l) graphregion(color(white)) ytitle(Population) xtitle(Date of UPP) legend( order(1 "Population"))
graph export $results/figureB2a_population_timing.pdf, replace
* FIGURE B.2(b)
scatter densite_pop time_upp, sort ms(O) connect(l) graphregion(color(white)) ytitle(Population density) xtitle(Date of UPP) legend( order(1 "Population density"))
graph export $results/figureB2b_density_pop_timing.pdf, replace
* FIGURE B.2(c)
scatter revenu_tete time_upp, sort ms(O) connect(l) graphregion(color(white)) ytitle(Income) xtitle(Date of UPP) legend( order(1 "Average income"))
graph export $results/figureB2c_revenu_timing.pdf, replace
* FIGURE B.2(d)
scatter altitude_diff time_upp, sort ms(O) connect(l) graphregion(color(white)) ytitle(Elevation range) xtitle(Date of UPP) legend( order(1 "Elevation Range"))
graph export $results/figureB2d_altitude_timing.pdf, replace
* FIGURE B.3(a)
scatter perc_elec perc_egout time_upp, sort ms(O D) connect(l l) graphregion(color(white)) ytitle(Percentage) xtitle(Date of UPP) legend( order(1 "Perc. with electricity" 2 "Perc. with sewer"))
graph export $results/figureB3a_elec_sewer_timing.pdf, replace
* FIGURE B.3(b)
scatter perc_proprio perc_jeune perc_alphabete time_upp, sort ms(O D T) connect(l l l) graphregion(color(white)) ytitle(Percentage) xtitle(Date of UPP) legend( order(1 "Perc. of homeowner" 2 "Perc. of young inhabitants" 3 "Perc. of literacy"))
graph export $results/figureB3b_homeowner_young_literacy_timing.pdf, replace
* FIGURE B.3(c)
scatter perc_infsmic perc_tenxsmic perc_effpolice time_upp, sort ms(O D T) connect(l l l) graphregion(color(white)) ytitle(Percentage) xtitle(Date of UPP) legend( order(1 "Perc. earning < min. wage" 2 "Perc. earning > 10x min. wage" 3 "Density of police officers"))
graph export $results/figureB3c_infsmic_10xsmic_effpolice_timing.pdf, replace
* FIGURE B.3(d)
scatter pre_p1_murder pre_p1_violencenokill time_upp, sort ms(O D) connect(l l) graphregion(color(white)) ytitle(Crime rate before the pacification) xtitle(Date of UPP) legend( order(1 "Murder rate" 2 "Assault rate"))
graph export $results/figureB3d_murder_violence_timing.pdf, replace
restore 


*** FIGURE P.1 *** -------------------------------------------------------------
* Graphical evidence on firearm confiscation
preserve
bysort year: egen tot_armarrest = total(armarrest)
bysort year: egen tot_drugarrest = total(drugarrest)
bysort year: egen tot_policeaction = total(policeaction)
bysort year: egen tot_carrecovery = total(carrecovery)
label var tot_armarrest "Firearm confiscation"
collapse (first) tot_armarrest tot_drugarrest tot_policeaction tot_carrecovery, by(year)
replace tot_armarrest=. if year==2016
replace tot_drugarrest=. if year==2016
replace tot_policeaction=. if year==2016
replace tot_carrecovery=. if year==2016
sort year
scatter tot_armarrest tot_drugarrest tot_policeaction tot_carrecovery year, ms(O D T S) connect(l l l l) lpattern("l" "_" "-" ".") legend(label(1 "Firearm confiscation") label(2 "Drug confiscation") label(3 "Police Actions") label(4 "Car Recovery")) graphregion(color(white)) xtitle(Year)
graph export $results/figureP1a_police_actions.pdf, as(pdf) replace
scatter tot_armarrest year, ms(O) connect(l) lpattern("l")  graphregion(color(white)) ytitle("Firearm confiscation in UPPs") xtitle(Year)
graph export $results/figureP1b_firearm_confiscation.pdf, as(pdf) replace
restore


*** -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** ANALYTICAL RESULTS ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*** TABLE 3 *** ----------------------------------------------------------------
* With UPP linear trend
forv l=2/2 {
	forv p=1/1 {
		* Without our fix for the endogeneous reporting bias
		eststo clear
		foreach v of varlist murder violencenokill totalrobbery totaltheft extortion policeaction policekill threat rape totevent {
		eststo: quietly xtreg ln`l'_p`p'_`v' intervention pacified upp_timetrend* i.date , fe vce(cluster upp) 
		}
		esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified intervention) replace 
		esttab using $results/table3_panelA.rtf, nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified intervention) replace
		* With our fix for the endogeneous reporting bias
		eststo clear
		foreach v of varlist murder violencenokill totalrobbery totaltheft extortion policeaction policekill threat rape totevent {
		eststo: quietly xtreg ln`l'_p`p'_`v'_a intervention pacified upp_timetrend* i.date , fe vce(cluster upp) 
		}
		esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified intervention) replace
		esttab using $results/table3_panelB.rtf , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified intervention) replace
	}
}
*** EDITED by Donna
forv l=2/2 {
	forv p=1/1 {
		* Without our fix for the endogeneous reporting bias
		eststo clear
		foreach v of varlist murder violencenokill totalrobbery totaltheft extortion policeaction policekill threat rape totevent {
			eststo: quietly xtreg ln`l'_p`p'_`v' intervention pacified upp_timetrend* i.date , fe vce(cluster upp) 
		}
		esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified intervention) replace 
		esttab using $results/table3_panelA.rtf, nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified intervention) replace
		estout using "../../results/table1_`l'_`p'.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
	}
}
save final.dta, replace


*** EDITED by Donna =============================================================================================================
/*
*** TABLE F.1 *** --------------------------------------------------------------
* Without UPP linear trend
forv l=2/2 {
	forv p=1/1 {
		* Without our fix for the endogeneous reporting bias
		eststo clear
		foreach v of varlist murder violencenokill totalrobbery totaltheft extortion policeaction policekill threat rape totevent {
		eststo: quietly xtreg ln`l'_p`p'_`v' intervention pacified i.date , fe vce(cluster upp) 
		}
		esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified intervention) replace 
		esttab using $results/tableF1_panelA.rtf, nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified intervention) replace
		* With our fix for the endogeneous reporting bias
		eststo clear
		foreach v of varlist murder violencenokill totalrobbery totaltheft extortion policeaction policekill threat rape totevent {
		eststo: quietly xtreg ln`l'_p`p'_`v'_a intervention pacified i.date , fe vce(cluster upp) 
		}
		esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified intervention) replace
		esttab using $results/tableF1_panelB.rtf , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified intervention) replace
	}
}


*** FIGURE 3 *** ---------------------------------------------------------------
* Bounded variation assumptions (BVA): increase of the reporting with respect to that of accidents
cap drop variation_RR*
foreach v of varlist violencenokill totalrobbery totaltheft extortion threat rape totevent {
	cap drop ln2_p1_`v'_a_*
	gen beta_bva_`v'=.
}
gen var_RR=.
local i=0
foreach b in -0.167 -0.125 -0.083 -0.042 0.000 0.042 0.083 0.125 0.167 0.208 0.250 0.292 0.333 0.375 0.417 0.458 0.500 0.542 0.583 0.625 0.667 {
	gen variation_RR`i'= 1 + pacified * `b' 
	foreach v of varlist violencenokill totalrobbery totaltheft extortion threat rape totevent {
		gen ln2_p1_`v'_a_`i' = ln2_p1_`v' - log((accident+0.5) / pop10 * variation_RR`i') 
	}
	eststo clear
	foreach v of varlist violencenokill totalrobbery totaltheft extortion threat rape totevent {
		eststo: quietly xtreg ln2_p1_`v'_a_`i' intervention pacified upp_timetrend* i.date , fe vce(cluster upp) 
		qui: replace beta_bva_`v' =  _b[pacified] if _n==`=`i'+1'
	}
	esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified intervention) replace
	esttab using BVA_`i'.rtf , nolabel star(* 0.10 ** 0.05 *** 0.01) se notes keep(pacified ) replace
	qui: replace var_RR = `i'/4 if _n==`=`i'+1'
	local i = `i' + 1
}
* FIGURE 3 *
scatter beta_bva* var_RR, yline(0, lcolor(black)) sort ms(O D T S + X Oh) connect(l l l l l l l) graphregion(color(white)) ytitle(Treatment Effect) xtitle(ratio Delta) legend( order(1 "Assault" 2 "Robbery" 3 "Theft" 4 "Extortion" 5 "Threat" 6 "Rape" 7 "Total Event"))
graph export $results/figure3.pdf, as(pdf) replace
* Export BVA results to plot a nice graph using Python (for instance)
export excel var_RR beta_bva* using $results/figure3_BVA_results_for_python.xls, firstrow(variables) replace


*** TABLE 4 *** ----------------------------------------------------------------
forv l=2/2 {
	forv p=1/1 {
		eststo clear
		foreach v of varlist accident {
		eststo: quietly xtreg ln`l'_p`p'_`v' intervention pacified upp_timetrend* i.date , fe vce(cluster upp) 
		eststo: quietly xtreg ln`l'_p`p'_`v' intervention pacified inter_zonesud pacif_zonesud upp_timetrend* i.date , fe vce(cluster upp) 
		eststo: quietly xtreg ln`l'_p`p'_`v'_death intervention pacified upp_timetrend* i.date , fe vce(cluster upp) 
		eststo: quietly xtreg ln`l'_p`p'_`v'_death intervention pacified inter_zonesud pacif_zonesud upp_timetrend* i.date , fe vce(cluster upp) 
		eststo: quietly xtreg ln`l'_p`p'_`v'_nodeath intervention pacified upp_timetrend* i.date , fe vce(cluster upp) 
		eststo: quietly xtreg ln`l'_p`p'_`v'_nodeath intervention pacified inter_zonesud pacif_zonesud upp_timetrend* i.date , fe vce(cluster upp) 		
		}
		esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacif* inter*) replace 
	}
}
esttab using $results/table4.rtf , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacif* inter*) replace


*** TABLE 5 ***-----------------------------------------------------------------
* Diff-in-Diff effect of the pacification of Cidade de Deus (CDD) on other yet to be pacified favelas controlled by the same gang (gang CV) with respect
* to yet to be pacified favelas controlled by ADA (+ contested favelas) before and after the pacification of CDD
forv l=2/2 {
	forv p=1/1 {
	eststo clear
	foreach v of varlist murder violencenokill totalrobbery totaltheft extortion policeaction policekill threat rape totevent {
	eststo: quietly xtreg ln`l'_p`p'_`v' CVnopacifxCDD_pacif upp_timetrend* i.date if year_bope>=2010 & year<2010, fe vce(cluster upp) 
	}
}
}
esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(CV*) replace
esttab using $results/table5.rtf, nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(CV*) replace	


*** TABLE 7 ***-----------------------------------------------------------------
* Subsample of UPPs which are not contested (CV is the reference group)
forv l=2/2 {
	forv p=1/1 {
		eststo clear
		foreach v in murder violencenokill_a totalrobbery_a totaltheft_a extortion_a policeaction policekill threat_a rape_a totevent_a {
		eststo: quietly xtreg ln`l'_p`p'_`v' intervention inter_gang_ada  pacified pacif_gang_ada upp_timetrend* i.date if gang_contest~=1 , fe vce(cluster upp) 
		}
	}
}
esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacif* ) replace
esttab using $results/table7.rtf, nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacif* ) replace


*** -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** APPENDIX RESULTS ---------------------------------------------------------------------------------------------------------------------------------------------------------------
*** -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


*** TABLE C.1 *** --------------------------------------------------------------
*** Alternative fix for the endogeneous reporting bias using fatal and non-fatal accidents
forv l=1/3 {
	forv p=1/1 {
		foreach v in murder violencenokill totalrobbery totaltheft extortion policeaction policekill threat rape totevent {
		gen ln`l'_p`p'_`v'_a_bis = ln`l'_p`p'_`v' - (ln`l'_p`p'_accident_nodeath - ln`l'_p`p'_accident_death)
		}
	}
}
forv l=2/2 {
	forv p=1/1 {
		eststo clear
		foreach v in murder violencenokill totalrobbery totaltheft extortion policeaction policekill threat rape totevent {
		eststo: quietly xtreg ln`l'_p`p'_`v'_a_bis intervention pacified upp_timetrend* i.date , fe vce(cluster upp) 
		}
	}
}
esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(intervention pacified ) replace
esttab using $results/tableC1.rtf , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified ) replace


*** TABLE E.1 ***---------------------------------------------------------------
* Testing the sensibility of results to different shift parameter in the log function (l=1,2,3)
forv l=1/3 {
	forv p=1/1 {
		eststo clear
		foreach v in murder violencenokill totalrobbery totaltheft extortion policeaction policekill threat rape totevent {
		eststo: quietly xtreg ln`l'_p`p'_`v' intervention pacified upp_timetrend* i.date , fe vce(cluster upp) 
		}
		esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep( pacified ) replace compress
		esttab using $results/tableE1_panel`l'.rtf, nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified ) replace
	}
}


*** TABLE E.2 ***---------------------------------------------------------------
* log-transformation with a constant giving the closest result, in terms of 
* semi-elasticity, of what we get without log in terms of semi-elasticity
gen eps1=1
gen eps2=0.5
gen eps3=0.25
gen eps4=0.1
gen eps5=0.05
gen eps6=0.01
gen eps7=0.005
gen eps8=0.001
forv i=1/8{
	gen ln`i'_p1_violencenokill_test = log((violencenokill+eps`i') / pop10)
}
mean p1_violencenokill
eststo clear
eststo: quietly xtreg p1_violencenokill pacified intervention upp_timetrend* i.date , fe vce(cluster upp)
margins, eydx(pacified) atmeans
forv i=1/8{
	eststo: quietly xtreg ln`i'_p1_violencenokill_test pacified intervention upp_timetrend* i.date , fe vce(cluster upp)
}
esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified) replace
esttab using $results/tableE2.rtf , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified) replace


*** TABLE G.1 ***---------------------------------------------------------------
* Heterogeneity 
forv l=2/2 {  
	eststo clear
	foreach v in murder violencenokill_a rape_a totalrobbery_a totaltheft_a {
		eststo: quietly xtreg ln`l'_p1_`v' intervention pacified pacif_p_proprio pacif_p_alphabete pacif_revenu_tete pacif_p_jeune pacif_altitude_diff pacif_effpolice pacif_densite_pop i.date upp_timetrend*, fe vce(cluster upp)
	}
}
esttab, nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacif*) replace 
esttab using $results/tableG1.rtf, nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacif*) replace 



*** Table I.1 ***---------------------------------------------------------------
* Testing the effect of BOPE entry in complexo do Alemao: effect on not yet 
* pacified favelas of CV with respect to no yet pacified favelas of ADA
capture drop group_test_alemao
gen group_test_alemao = inlist(upp,"DoUppVidigal", "DoUppRocinha", "DoUppJacarezinho", "DoUppManguinhos", "DoUppAraraMandela", ///
									"DoUppBarreiraVascoTuiuti", "DoUppCaju", "DoUppCerroCora", "DoUppCamaristaMeier") 
replace group_test_alemao = 1 if inlist(upp, "DoUppLins", "DoUppVilaKennedy")
eststo clear
	foreach v of varlist murder violencenokill totalrobbery totaltheft extortion policeaction policekill rape threat totevent  {
eststo: quietly xtreg ln2_p1_`v' CVnopacifxALEAMO_pacif upp_timetrend* i.date if group_test_alemao & year<2012 , fe vce(cluster upp)
}
esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(CVnopacifxALEAMO_pacif) replace
esttab using $results/tableI1.rtf, nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(CVnopacifxALEAMO_pacif) replace


*** Table I.2 ***---------------------------------------------------------------
* Removing "headquarters" (panel A)
capture drop HQCVADA
gen HQCVADA=gang_cvhq
replace HQCVADA=1 if upp=="DoUppRocinha"
forv l=2/2 {
	forv p=1/1 {
		eststo clear
		foreach v in murder violencenokill_a totalrobbery_a totaltheft_a extortion_a policeaction policekill threat_a rape_a totevent_a {
		eststo: quietly xtreg ln`l'_p`p'_`v' intervention pacified upp_timetrend* i.date if HQCVADA==0 , fe vce(cluster upp) 
		}
		esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified) replace
		esttab using $results/tableI2_panelA.rtf , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified ) replace
	}
}
* Removing contested favelas (panel B)
forv l=2/2 {
	forv p=1/1 {
		eststo clear
		foreach v in murder violencenokill_a totalrobbery_a totaltheft_a extortion_a policeaction policekill threat_a rape_a totevent_a {
		eststo: quietly xtreg ln`l'_p`p'_`v' intervention pacified upp_timetrend* i.date if gang!="contested", fe vce(cluster upp) 
		}
		esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified ) replace
		esttab using $results/tableI2_panelB.rtf , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified ) replace
	}
}


*** Table J.1 ***---------------------------------------------------------------
* Alternative treatment = intervention + pacified
capture drop traitement
gen traitement = intervention + pacified
forv l=2/2 {
	forv p=1/1 {
		eststo clear
		foreach v in murder violencenokill_a totalrobbery_a totaltheft_a extortion_a policeaction policekill threat_a rape_a  totevent_a {
		eststo: quietly xtreg ln`l'_p`p'_`v' traitement upp_timetrend* i.date , fe vce(cluster upp) 
		}
		esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(traitement) replace
		esttab using $results/tableJ1.rtf , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(traitement) replace
	}
}


*** Table K.1 ***---------------------------------------------------------------
* with package boottest : manually collect the p-value after each estimation
mat resultK1=J(2,10,.) //Defining empty matrix
local k = 0
forv l=2/2 {
	forv p=1/1 {
		eststo clear
		foreach v in murder violencenokill_a totalrobbery_a totaltheft_a extortion_a policeaction policekill threat_a rape_a  totevent_a {
		eststo: quietly xtreg ln`l'_p`p'_`v' intervention pacified upp_timetrend* i.date, fe vce(cluster id_upp)
		scalar beta = _b[pacified]
		boottest pacified, cluster(id_upp) bootcluster(id_upp) seed(123) reps(1000)
		scalar pval = r(p) 
		local k = `k'+1
		mat resultK1[1,`k']=beta
		mat resultK1[2,`k']=pval
		}
		esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified intervention) replace
	}
}
mat rownames resultK1 = "Pacified" "P-value"
mat colnames resultK1 = "Murder" "Assault" "Robbery" "Theft" "Extortion" "Police Action" "Police Killing" "Threat" "Rape" "Total Events"
mat list resultK1
putexcel set $results/tableK1, replace
putexcel B1=("Murder") C1=("Assault") D1=("Robbery") E1=("Theft") F1=("Extortion") G1=("Police Action") H1=("Police Killing") I1=("Threat") J1=("Rape") K1=("Total Events")
putexcel A2=("Pacified") A3=("P-value") 
putexcel B2 = matrix(resultK1)
* Other method: wild BootStrap with package cgmwildbootstrap (to install the package : ssc install clustse)
*tab upp, gen (UPP)
*tab date, gen (DATE)
*forv l=2/2 {
*	forv p=1/1 {
*		eststo clear
*		foreach v in murder violencenokill_a totalrobbery_a totaltheft_a extortion_a policeaction policekill threat_a rape_a  totevent_a {
*		eststo: quietly cgmwildboot ln`l'_p`p'_`v' intervention pacified upp_timetrend* UPP2-UPP38 DATE2-DATE114, cluster(id_upp) bootcluster(id_upp) seed(123) reps(1000)
*		}
*		esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified ) replace
*	}
*}


*** Table K.2 ***---------------------------------------------------------------
* Randomization Inference:
* Dates of BOPE entry are between "month values" 19 and 87, and thoses of UPPs between 25 and 90.
* Since the duration of BOPE intervention is between 0 and 639 days, we are going to generate random
* favela pacification dates between 19 (july 2008) and 90 (may 2014). We do not randomize the duration
* of the BOPE intervention: we generate a new BOPE entry date that is equal to the new randomized 
* pacified date minus the duration of the BOPE intervention. The underlying assumption is that the duration
* of intervention is specific to the favela (its characteristics) and do not depend on the timing of pacification
* Generate (discrete) duration of intervention in months
gen duree_mois_inter=round(duree_intervention/30,1)
* Modeling the duration of intervention
preserve
	keep if date==1
	sort date_bope date_upp
	gen rank=1
	gen population2=population^2
	forv j=2/37 {
		replace rank=rank+1 if _n>=`j' & date_bope[`j']>date_bope[`=`j'-1']
	}
	eststo clear
	eststo: reg duree_mois_inter rank, robust
	eststo: reg duree_mois_inter revenu_tete nbredefavela population population2, robust
	eststo: reg duree_mois_inter revenu_tete nbredefavela population population2 rank, robust
	esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2) se notes replace
	esttab using $results/tableK2.rtf , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2) se notes replace
restore
* ==> the duration of intervention does no seem to depend on the timing of pacification, 
* which supports our assumption 


*** Table K.3 ***---------------------------------------------------------------
* Program "randon_inf" to do randomization inference 
cap prog drop random_inf
prog def random_inf
args reps
* Initialisation with "true" (estimated) values of coefficients
	foreach v in murder violencenokill_a totalrobbery_a totaltheft_a extortion_a policeaction policekill threat_a rape_a  totevent_a {
	cap drop beta1_`v' beta2_`v'
	gen beta1_`v'=.
	gen beta2_`v'=.
	qui: xtreg ln2_p1_`v' pacified intervention i.date, fe
	qui: replace beta1_`v' =  _b[pacified] if _n==1
	qui: xtreg ln2_p1_`v' pacified intervention i.date upp_timetrend*, fe
	qui: replace beta2_`v' =  _b[pacified] if _n==1
}	
* randomization inference
forv i=1/`reps' {
	bysort id_upp: gen rand=round(runiform(19,90),1) if _n==1
	bysort id_upp: egen date_treat=max(rand)
	gen r_treat=date>=date_treat
	gen date_pre_treat=date_treat-duree_mois_inter
	replace date_pre_treat=1 if date_pre_treat<1
	gen r_pre_treat=(date>=date_pre_treat & date<date_treat)
	foreach v in murder violencenokill_a totalrobbery_a totaltheft_a extortion_a policeaction policekill threat_a rape_a  totevent_a {
		qui: xtreg ln2_p1_`v' r_treat r_pre_treat i.date, fe
		qui: replace beta1_`v' =  _b[r_treat] if _n==`=`i'+1'
		qui: xtreg ln2_p1_`v' r_treat r_pre_treat i.date upp_timetrend*, fe
		qui: replace beta2_`v' =  _b[r_treat] if _n==`=`i'+1'
	}
	drop rand date_treat r_treat date_pre_treat r_pre_treat
}
* Statistics to summarize the results of the randomization inference
	foreach v in murder violencenokill_a totalrobbery_a totaltheft_a extortion_a policeaction policekill threat_a rape_a  totevent_a {
	forv j=1/2 {	
	* Empirical p-values 
		gen test=abs(beta`j'_`v')>=abs(beta`j'_`v'[1]) if  beta`j'_`v'!=.
		egen pval=total(test)
		replace beta`j'_`v'=pval/(`reps'+1) if _n==2
		drop test pval
	* Quantiles of the statistics under H0
	_pctile beta`j'_`v' if _n>1 , p(.5, 2.5, 5, 95, 97.5, 99.5)
		replace beta`j'_`v'=r(r1) if _n==3
		replace beta`j'_`v'=r(r2) if _n==4
		replace beta`j'_`v'=r(r3) if _n==5
		replace beta`j'_`v'=r(r4) if _n==6
		replace beta`j'_`v'=r(r5) if _n==7
		replace beta`j'_`v'=r(r6) if _n==8
	replace beta`j'_`v'=. if _n>=9
	}
}
gen var_name1 ="" 
replace var_name1="Est. coef." if _n==1
replace var_name1="p-value"    if _n==2
replace var_name1="IC inf 99p" if _n==3
replace var_name1="IC inf 95p" if _n==4
replace var_name1="IC inf 90p" if _n==5
replace var_name1="IC sup 90p" if _n==6
replace var_name1="IC sup 95p" if _n==7
replace var_name1="IC sup 99p" if _n==8
order var_name1 beta1_* beta2_*
export excel var_name1 beta1_* beta2_* using $results/tableK3_full.xls, firstrow(variables) replace
replace var_name1="Pacified"   if _n==1
export excel var_name1 beta2_* using $results/tableK3_final.xls if _n<=2, firstrow(variables) replace
drop beta1_* beta2_* var_name1
end
* Execute program random_inf with 1000 replications
set seed 1234
random_inf 100



*** TABLE L.1***----------------------------------------------------------------
* No obvious data tampering
capture drop month jan fev mar avr mai jun jul aug sep oct nov dec
gen month = month(time)
gen jan = month==1 
gen fev = month==2
gen mar = month==3 
gen avr = month==4
gen mai = month==5 
gen jun = month==6
gen jul = month==7 
gen aug = month==8
gen sep = month==9 
gen oct = month==10
gen nov = month==11
gen dec = month==12
foreach v in jan fev mar avr mai jun jul aug sep oct nov dec {
	gen pacif_`v'=pacified * `v'
}
forv l=2/2 {
	forv p=1/1 {
		eststo clear
		foreach v in murder violencenokill_a totalrobbery_a totaltheft_a policeaction policekill threat_a rape_a {
		eststo: quietly xtreg ln`l'_p`p'_`v' intervention pacif_jan-pacif_dec upp_timetrend* i.date , fe vce(cluster upp) 
		}
		esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacif*) replace
		esttab using $results/tableL1.rtf , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacif* ) replace
	}
}


*** TABLE M.1***----------------------------------------------------------------
* OLS regressions with crime indicators in level
forv p=1/1 {
	foreach v in murder violencenokill totalrobbery totaltheft extortion policeaction policekill threat rape totevent {
	gen p`p'_`v'_a = p`p'_`v' - p`p'_accident
	}
}
forv p=1/1 {
	* Without endogenenous reporting correction (panel A)
	eststo clear
	foreach v in murder violencenokill totalrobbery totaltheft extortion policeaction policekill threat rape totevent {
	eststo: quietly xtreg p`p'_`v' intervention pacified upp_timetrend* i.date , fe vce(cluster upp) 
	}
	esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified ) replace
	esttab using $results/tableM1_panelA.rtf, nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified ) replace
	* With endogenenous reporting correction (panel B)	
	eststo clear
	foreach v in murder violencenokill totalrobbery totaltheft extortion policeaction policekill threat rape totevent {
	eststo: quietly xtreg p`p'_`v'_a intervention pacified upp_timetrend* i.date , fe vce(cluster upp) 
	}
	esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified ) replace
	esttab using $results/tableM1_panelB.rtf, nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified ) replace
}


*** TABLE M.2***----------------------------------------------------------------
* Poisson regressions with crime indicators in level
capture drop accident_e
gen accident_e=accident+0.5
* Panel A: without reporting correction
eststo clear
	foreach v in murder violencenokill totalrobbery totaltheft extortion policeaction policekill threat rape totevent {
	eststo: quietly poisson `v' intervention pacified i.date i.id_upp upp_timetrend*, irr vce(cluster id_upp) iterate(50) exposure(pop1)
	}
esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified) eform replace compress
esttab using $results/tableM2_panelA.rtf, nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N ) se notes keep(pacified) eform replace
* Panel B: with reporting correction
eststo clear
	foreach v in murder violencenokill totalrobbery totaltheft extortion policeaction policekill threat rape totevent {
	eststo: quietly poisson `v' intervention pacified i.date i.id_upp upp_timetrend*, irr vce(cluster id_upp) iterate(50) exposure(accident_e)
	}
esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified) eform replace compress
esttab using $results/tableM2_panelB.rtf, nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N ) se notes keep(pacified) eform replace


*** TABLE M.3***----------------------------------------------------------------
* Negative Binomial regressions with crime indicators in level
* Panel A: without reporting correction
eststo clear
	foreach v in murder violencenokill totalrobbery totaltheft extortion policeaction policekill threat rape totevent {
	eststo: quietly nbreg `v' intervention pacified i.id_upp i.date upp_timetrend*, irr vce(cluster id_upp) iterate(50) exposure(pop1) 
	}
esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified ) eform replace
esttab using $results/tableM3_panelA.rtf, nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N ) se notes keep(pacified) eform replace
* Panel B: with reporting correction
eststo clear
	foreach v in murder violencenokill totalrobbery totaltheft extortion policeaction policekill threat rape totevent {
	eststo: quietly nbreg `v' intervention pacified i.id_upp i.date upp_timetrend*, irr vce(cluster id_upp) iterate(50) exposure(accident_e)
	}
esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified) eform replace compress
esttab using $results/tableM3_panelB.rtf, nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N ) se notes keep(pacified) eform replace


*** TABLE M.4***----------------------------------------------------------------
* First difference and fixed effect estimators
sort id_upp date
eststo clear
foreach v in murder violencenokill_a rape_a totalrobbery_a totaltheft_a policeaction policekill threat_a extortion_a totevent_a accident fraud_a {
  eststo: xi: quietly reg D.(ln2_p1_`v' pacified intervention i.date)  , nocons vce(cluster upp) 
}
esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(D.pacif*) replace compress
esttab using $results/tableM4.rtf , nolabel star(* 0.10 ** 0.05 *** 0.01) se notes keep(D.pacif* ) replace


*** TABLE N.1 ***----------------------------------------------------------------
* Removing first pacified favelas (BATAN and CIDADE DE DEUS)
forv l=2/2 {
	forv p=1/1 {
		eststo clear
		foreach v in murder violencenokill_a rape_a totalrobbery_a totaltheft_a policeaction policekill threat_a extortion_a totevent_a fraud_a {
		eststo: quietly xtreg ln`l'_p`p'_`v' intervention pacified upp_timetrend* i.date if upp!="DoUppBatan" & upp!="DoUppCdd", fe vce(cluster upp) 
		}
		esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified) replace
		esttab using $results/tableN1.rtf , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacified) replace
	}
}


*** TABLE O.1 ***---------------------------------------------------------------
*** Seperate regressions for CV and ADA
forv l=2/2 {
	forv p=1/1 {
		* Panel A: regressions on ADA's favelas only
		eststo clear
		foreach v in murder violencenokill_a totalrobbery_a totaltheft_a extortion_a policeaction policekill threat_a rape_a totevent_a {
		eststo: quietly xtreg ln`l'_p`p'_`v' intervention pacified upp_timetrend* i.date if gang_ada==1, fe vce(cluster upp) 
		}
		esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacif* inter*) replace
		esttab using $results/tableO1_panelA.rtf, nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacif* inter*) replace
		* Panel B: regressions on CV's favelas only
		eststo clear
		foreach v in murder violencenokill_a totalrobbery_a totaltheft_a extortion_a policeaction policekill threat_a rape_a totevent_a {
		eststo: quietly xtreg ln`l'_p`p'_`v' intervention pacified upp_timetrend* i.date if gang_cv==1, fe vce(cluster upp) 
		}
		esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacif* inter*) replace
		esttab using $results/tableO1_panelB.rtf, nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(pacif* inter*) replace
	}
}

*/

