clear all
set max_memory 30g
set matsize 11000
set more off

tempfile a

*** EDIT by Donna
do 0_macro_libraries.do

* Import data about individuals who died in hospital following an attack
import delimited $hospital/agression.csv, clear
rename genre_tous allkilling
drop genre_inconnu age_tous race_tous 
foreach v in homme femme ///
			moins_de_1an _4ans _9ans _14ans _19ans _29ans _39ans _49ans _59ans _69ans _79ans ans_plus age_inconnu ///
			blanc noir asiatique metisse indigene race_inconnu {
	rename `v' `v'_all 
}
gen noblanc_all = allkilling - blanc_all - asiatique_all
gen black_all = noir_all + metisse_all
save `a', replace
* Add data about individuals who died in hospital following a gun attack
import delimited $hospital/agression_arme_feu.csv, clear
rename genre_tous gun 
drop genre_inconnu age_tous race_tous 
foreach v in homme femme ///
			moins_de_1an _4ans _9ans _14ans _19ans _29ans _39ans _49ans _59ans _69ans _79ans ans_plus age_inconnu ///
			blanc noir asiatique metisse indigene race_inconnu {
	rename `v' `v'_gun
}
gen noblanc_gun = gun - blanc_gun - asiatique_gun
gen black_gun = noir_gun + metisse_gun
merge 1:1 hopital date using `a', keep(match) nogen
save `a', replace
* Add data about individuals who died in hospital following a knife attack
import delimited $hospital/agression_couteau.csv, clear
rename genre_tous knife 
drop genre_inconnu  age_tous race_tous 
foreach v in homme femme ///
			moins_de_1an _4ans _9ans _14ans _19ans _29ans _39ans _49ans _59ans _69ans _79ans ans_plus age_inconnu ///
			blanc noir asiatique metisse indigene race_inconnu {
	rename `v' `v'_knife
}
gen noblanc_knife = knife - blanc_knife - asiatique_knife
gen black_knife = noir_knife + metisse_knife
merge 1:1 hopital date using `a', keep(match) nogen
* Killing with other means that a gun 
gen other = allkilling - gun
gen homme_other = homme_all - homme_gun
gen femme_other = femme_all - femme_gun
gen blanc_other = blanc_all - blanc_gun
gen black_other = black_all - black_gun
save `a', replace

* Detect large and small hospitals
bysort hopital : egen tot_killing = total(allkilling)
tab tot_killing
unique hopital if tot_killing>45
unique hopital if tot_killing<45
gen champ_etude = tot_killing>45
bysort champ_etude: egen totdeath = total(allkilling)
tab totdeath

* Set the panel
egen id_etab = group(hopital)
xtset id_etab date

* Linear timetrend specific to each hospital
qui unique(id_etab)
forv j=1/`r(unique)' {
	gen etab_`j'=(id_etab==`j')
	gen etab_timetrend`j' = etab_`j'*date
	gen etab_quad_timetrend`j' = etab_`j'*date*date
	drop etab_`j'
}

save `a', replace

* Import data about the total population living at a given range distance from each hospitalistance between each hospital and the population living around it
tempfile x 
*** EDIT by Donna
import delimited $hospital/Traitement_Denominateur_Hospital.csv,  clear
save `x', replace
* Import data about the monthly pacified population living at a given range distance from each hospital
*** EDIT by Donna
import delimited $hospital/Traitement_Numerateur_Hospital.csv,  clear
merge m:1 hopital using `x', nogen
* Rename variables
forv j = 100(100)9000 {
	rename numerateur_`=`j'-100'`j' pop_pacif_`=`j'-100'_`j' 
	rename denominateur_`=`j'-100'`j' pop_total_`=`j'-100'_`j'
}
drop num* denom*
save `x', replace

use `a', clear
merge 1:1 hopital date using `x'


*** Program that generate the percentage of treated population over a given range distance
cap prog drop gentreat_perc_poptotal
program gentreat_perc_poptotal 
	args i j
	local list_num
	local list_denum
	forv z = `i'(100)`=`j'-100' {
		local list_num `list_num' pop_pacif_`z'_`=`z'+100'
		local list_denum `list_denum' pop_total_`z'_`=`z'+100'
	}
	*display "`list_num'"
	tempvar num denum
	cap drop p_pacif_tot_`i'_`j'
	qui egen `num'   =rowtotal(`list_num') 
	qui egen `denum' =rowtotal(`list_denum')  
	gen p_pacif_tot_`i'_`j'=(`num')/`denum'
end

* Generate treatment variables used in the regression
foreach var in gentreat_perc_poptotal  {
	`var' 0 3000
	`var' 3000 6000
	`var' 6000 9000
}



tab tot_killing
unique hopital if tot_killing>45 & !mi(tot_killing)
unique hopital if tot_killing<45
tab totdeath

*** TABLE 9 ***-----------------------------------------------------------------
foreach var in p_pacif_tot  { 
	** Panel A: All murder  
	eststo clear
	foreach v of varlist allkilling homme_all femme_all blanc_all black_all {
		eststo: quietly poisson `v' `var'_0_3000 `var'_3000_6000 `var'_6000_9000 i.date etab_timetrend* i.id_etab if tot_killing>45 & !mi(tot_killing), vce(cluster id_etab) iter(100) 
	}
	esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N ) se notes keep(p_* ) replace
	esttab using $results/table9_panelA.rtf, nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N ) se notes keep(p_* ) replace
	** Panel B: Murder with gun
	eststo clear
	foreach v of varlist gun homme_gun femme_gun blanc_gun black_gun {
		eststo: quietly poisson `v' `var'_0_3000 `var'_3000_6000 `var'_6000_9000 i.date etab_timetrend* i.id_etab if tot_killing>45 & !mi(tot_killing), vce(cluster id_etab) iter(100) 
	}
	esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N ) se notes keep(p_* ) replace
	esttab using $results/table9_panelB.rtf, nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N ) se notes keep(p_* ) replace
	** Panel C: Murder with other methods (no Gun)
	eststo clear
	foreach v of varlist other homme_other femme_other blanc_other black_other {
		eststo: quietly poisson `v' `var'_0_3000 `var'_3000_6000 `var'_6000_9000 i.date etab_timetrend* i.id_etab if tot_killing>45 & !mi(tot_killing), vce(cluster id_etab) iter(100) 
	}
	esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N ) se notes keep(p_* ) replace
	esttab using $results/table9_panelC.rtf, nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N ) se notes keep(p_* ) replace
	** Panel D: Murder with knife
	*eststo clear
	*foreach v of varlist knife homme_knife femme_knife blanc_knife black_knife {
	*	eststo: quietly poisson `v' `var'_0_3000 `var'_3000_6000 `var'_6000_9000 i.date etab_timetrend* i.id_etab if tot_killing>45, vce(cluster id_etab) iter(100) 
	*}
	*esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N ) se notes keep(p_* ) replace
	*esttab using table9_panelD.rtf, nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N ) se notes keep(p_* ) replace
}

