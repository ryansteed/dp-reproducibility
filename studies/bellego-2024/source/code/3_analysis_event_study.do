clear all
set max_memory 30g
set matsize 11000
set more off

*** EDIT by Donna
do 0_macro_libraries.do
* Load the functions to estimate the event studies
do $programs/0_prog_eventStudy.do

tempfile x
* Import characteristics of UPPs (pacification date, socio-demo, ...)
import delimited $data_upp_main, clear
drop pacified bope 
replace date_upp="" if upp=="DoUppMare"
order upp city complexo date_bope date_upp effpolice gang 
foreach var in population_favela domicile_moins_smic responsable_domicile_ logement_proprietaire logement_locataire logement_occupe logement_autre electricite eau_potable egout ordure analphabete_15ans_plu analphabete_10_14ans 15_29ans {
	rename proportion_`var' perc_`var'
}
rename (perc_responsable_domicile_ v24) (perc_chefmenage_moins_smic perc_chefmenage_10fois_smic)
rename (revenu_domicile perc_domicile_moins_smic personne_par_domicile) (revenu_menage perc_menage_moins_smic nbpersonne_par_menage)
rename (mean_altitude std_altitude max_altitude min_altitude) (altitude_mean altitude_std altitude_max altitude_min)
rename zonasud zone_sud

* Transform pacification date into date variable
foreach v in bope upp {
	gen day_`v'=substr(date_`v',1,2)
	gen month_`v'=substr(date_`v',4,2)
	gen year_`v'=substr(date_`v',7,2)
	replace year_`v'="20" + year_`v'
	destring day_`v' month_`v' year_`v', replace
	gen time_`v'=mdy(month_`v', day_`v', year_`v')
	format time_`v' %td
	drop day_`v' month_`v' year_`v' date_`v'
}	

* Discrete BOPE entry and pacification dates
foreach v in bope upp {
	gen month_`v' = month(time_`v')
	gen date_`v' = month_`v' + (year(time_`v') - 2007) * 12
	replace date_`v' = date_`v' + 1 if day(time_`v') >= 15
	drop month_`v'
}

* Add crime data
tempfile x z
save `x', replace
import delimited $data_upp_crime, clear
foreach v of varlist homicideintentional- eventsregistration {
	replace `v'="" if `v'=="nan"
	destring `v', replace
}
save `z', replace
use `x', clear
merge 1:m upp using `z'
drop _merge
* Specific case of UppDoMare which has never been pacified: we do not observe crime in this group of favelas; so we drop it
drop if upp=="DoUppMare"
* Specific cas of Mangueirinha which is outside the city of Rio de Janeiro (was pacified and we observe crime)
* But we do not observe well socio-demo characteristics , so we drop it
drop if upp=="DoUppMangueirinha"

* Date variable of the end of each month
gen day=15
gen time=mdy(month, day, year)
format time %td
drop day month
gen dd = day(time)
gen mm = month(time)
gen yyyy = year(time)
gen mm1=mm+1 if mm<12
replace mm1=1 if mm==12
replace yyyy=yyyy+1 if mm==12
gen time1 = mdy(mm1,1,yyyy)-1
format time1 %td
gen nday_of_month=day(time1)
drop time dd mm yyyy mm1
rename time1 time

* Quarterly time variable
gen quarter=qofd(time)


*** Variables about gang
gen gang_ada=gang=="ADA"
gen gang_cv=gang=="CV" | gang=="CV HQ"
gen gang_cvhq=gang=="CV HQ"
gen gang_cvnohq=gang=="CV"
gen gang_contest=gang=="contested"
gen gang_milice=gang=="MILITIA"
gen gang_nocv=1-gang_cv


*** Treatment variables: pacified & intervention 
gen duree_intervention=time_upp-time_bope
gen diff_pacified = time-time_upp
gen diff_bope = time-time_bope
gen pacified=(diff_pacified>0)
gen intervention=(diff_bope>0 & diff_pacified< nday_of_month)
replace pacified=diff_pacified/nday_of_month if diff_pacified < nday_of_month & pacified==1
replace intervention=diff_bope/nday_of_month if diff_bope < nday_of_month & intervention==1
replace intervention=1-pacified if intervention==1 & pacified>0 & pacified<1
drop diff_pacified diff_bope


*** Aggregate variables at the quarterly level
collapse (sum) pacified intervention homicideintentional - eventsregistration (first) population revenu_tete densite perc_population_favela perc_menage_moins_smic - perc_15_29ans effpolice duree_intervention time_upp time_bope date_upp date_bope (last) time  , by(upp quarter)
replace pacified=pacified/3
replace intervention=intervention/3

*** Set the panel
egen id_upp = group(upp)
xtset id_upp quarter

* Linear timetrend specific to each UPP
forv j=1/38 {
gen upp_`j'=(id_upp==`j')
gen upp_timetrend`j' = upp_`j'*(quarter-187)
drop upp_`j'
}

* Population
gen pop10 = population


*** Crime variables  ------------------------------------------------------------------------------------------------------------------------------------------------------------------
rename robberywithdrivingtotakeoutinatm atmdriverobbery
rename extortionwithkidnapping extortionwithkidnap
rename extortionwithmomentarykidnapping extortwithmomentarykidnap
rename resistancetodeathofpoliceopponen resistancetodeathofpolic

*** Partition of crime indicators:
* Violence from Police
gen policekill=resistancetodeathofpolic
* Violence on Police:
gen policedeath= deathofmilitarypolice + deathofcivilpolice 
* Intended Violence on individuals
gen intendedviolence = homicideintentional + bodyinjurydeathfollowed + attemptedmurder + bodyinjuryintentional 
* Robbery
gen robbery=robberydeathfollowed + storerobbery + homerobbery + carrobbery + boatrobbery + passerbyrobbery + collectiverobbery + bankrobbery + mobilephonerobbery + atmdriverobbery + atmrobbery
* Extortion
gen totalextortion= extortion + extortionwithkidnap + extortwithmomentarykidnap 
gen kidnap = extortionwithkidnap + extortwithmomentarykidnap 
rename extortwithmomentarykidnap extortwithtempkidnap
* Accident
gen accident=homicidenointentional + bodyinjurynointentional
gen accident_death=homicidenointentional
gen accident_nodeath=bodyinjurynointentional
* Found 
gen deadfound=deadbodyfound+bonesfound
* Police action
gen policeaction= drugarrest + armarrest + compliancewarrantofarrest + carrecovery + occurrenceswithflagrante
* Total events
gen totevent = eventsregistration
* Tous les événements liés aux voitures
gen totalcar = cartheft + carrobbery
* Murder 
gen murder =  homicideintentional + bodyinjurydeathfollowed + robberydeathfollowed
* Murder bis
gen murder_bis =  homicideintentional + attemptedmurder
* Murder (including police)
gen murderpol = murder + deathofmilitarypolice + deathofcivilpolice
* Violence without killing
gen violencenokill = bodyinjuryintentional + attemptedmurder
* Brazilian indicators
gen lethality = homicideintentional + bodyinjurydeathfollowed + robberydeathfollowed + resistancetodeathofpolic
gen streetrobbery= passerbyrobbery + mobilephonerobbery + collectiverobbery


*** Generate number of crimes divided by the population
foreach v of varlist homicideintentional-eventsregistration policekill-streetrobbery {
gen p1_`v' = `v' / pop10
}

*** Generate log of crime percentage
gen epsilon1=1
gen epsilon2=0.5
gen epsilon3=0.25
foreach v of varlist homicideintentional-eventsregistration policekill-streetrobbery {
gen ln1_p1_`v' = log((`v'+epsilon1) / pop10)
gen ln2_p1_`v' = log((`v'+epsilon2) / pop10)
gen ln3_p1_`v' = log((`v'+epsilon3) / pop10)
}


* Dependent variable with a rise in the reporting rate of 20%
gen RR20 = 1 + pacified * 0.20 
foreach v of varlist homicideintentional-eventsregistration policekill-streetrobbery {
	gen ln_p_`v'_r = log((`v' + epsilon2)) - log(RR20)
}


*** Variables for the event studies
*gen _quarter_upp=quarter if pacified>=0.5
gen _quarter_upp=quarter if pacified==1
*gen _quarter_bope=quarter if intervention>=0.5
gen _quarter_bope=quarter if intervention>0
egen quarter_upp=min(_quarter_upp), by (upp)
egen quarter_bope=min(_quarter_bope), by (upp)
drop _quarter_upp _quarter_bope
* deal with case where the duration of intervention is small (smaller than 1 quarter)
gen _intervention=intervention*10000000
bysort upp: egen max_intervention=max(_intervention)
replace quarter_bope=quarter if _intervention==max_intervention & quarter_bope==.
drop _intervention max_intervention
bysort upp: egen max_quarter_bope=max(quarter_bope)
drop quarter_bope
rename max_quarter_bope quarter_bope

* Variable "time to treatment"  for the event study: the treatment starts with BOPE entry
gen time_pacif = quarter - quarter_bope
* Bin up event time indicators beyond some range 
recode time_pacif (.=-1) (-1000/-12=-12) (12/1000=12)
char time_pacif[omit] -1 
*xi i.time_pacif, pref(_T)

* Treatment variable for the heterogenous event study of d'Haultefoeuille et de Chaisemartin
gen traitement=pacified+intervention
replace traitement=1 if traitement>=0.5
replace traitement=0 if traitement<0.5


************************************************************************************************************************************************************************************
***** Event Studies ****************************************************************************************************************************************************************
************************************************************************************************************************************************************************************


*** FIGURE 4 -------------------------------------------------------------------
* Panel (a) : only coefficient k=-1 is set to zero
eventStudy_alt ln2_p1_murder 		, min(-12) max(12) event(time_pacif) pan(id_upp quarter) name(Murder, replace)
graph export $results/Figure4a_Murder.pdf, as(pdf) replace
eventStudy_alt ln2_p1_violencenokill, min(-12) max(12) event(time_pacif) pan(id_upp quarter) name(Assault, replace)
graph export $results/Figure4a_Assault.pdf, as(pdf) replace
eventStudy_alt ln2_p1_totalrobbery 	, min(-12) max(12) event(time_pacif) pan(id_upp quarter) name(Robbery, replace)
graph export $results/Figure4a_Robbery.pdf, as(pdf) replace
eventStudy_alt ln2_p1_totaltheft 	, min(-12) max(12) event(time_pacif) pan(id_upp quarter) name(Theft, replace)
graph export $results/Figure4a_Theft.pdf, as(pdf) replace
eventStudy_alt ln2_p1_extortion		, min(-12) max(12) event(time_pacif) pan(id_upp quarter) name(Extortion, replace)
graph export $results/Figure4a_Extortion.pdf, as(pdf) replace
eventStudy_alt ln2_p1_policeaction 	, min(-12) max(12) event(time_pacif) pan(id_upp quarter) name(PoliceAction, replace)
graph export $results/Figure4a_PoliceAction.pdf, as(pdf) replace
eventStudy_alt ln2_p1_policekill 	, min(-12) max(12) event(time_pacif) pan(id_upp quarter) name(PoliceKill, replace)
graph export $results/Figure4a_PoliceKill.pdf, as(pdf) replace
eventStudy_alt ln2_p1_threat 		, min(-12) max(12) event(time_pacif) pan(id_upp quarter) name(Threat, replace)
graph export $results/Figure4a_Threat.pdf, as(pdf) replace
eventStudy_alt ln2_p1_rape 			, min(-12) max(12) event(time_pacif) pan(id_upp quarter) name(Rape, replace)
graph export $results/Figure4a_Rape.pdf, as(pdf) replace
eventStudy_alt ln2_p1_totevent 		, min(-12) max(12) event(time_pacif) pan(id_upp quarter) name(TotEvent, replace)
graph export $results/Figure4a_TotalEvent.pdf, as(pdf) replace
* Panel (b) : coefficients k=-1 and k=-12 are both set to zero
eventStudy ln2_p1_murder, min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Violence, replace)
graph export $results/Figure4b_Murder.pdf, as(pdf) replace
eventStudy ln2_p1_violencenokill, min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Violence, replace)
graph export $results/Figure4b_Assault.pdf, as(pdf) replace
eventStudy ln2_p1_totalrobbery, min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Robbery, replace)
graph export $results/Figure4b_Robbery.pdf, as(pdf) replace
eventStudy ln2_p1_totaltheft, min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Theft, replace)
graph export $results/Figure4b_Theft.pdf, as(pdf) replace
eventStudy ln2_p1_totalextortion , min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Extortion, replace)
graph export $results/Figure4b_Extortion.pdf, as(pdf) replace
eventStudy ln2_p1_policeaction, min(-12) max(12) event(time_pacif) pan(id_upp  quarter)  name(PoliceAction, replace)
graph export $results/Figure4b_PoliceAction.pdf, as(pdf) replace
eventStudy ln2_p1_policekill, min(-12) max(12) event(time_pacif) pan(id_upp  quarter)  name(PoliceKill, replace)
graph export $results/Figure4b_PoliceKill.pdf, as(pdf) replace
eventStudy ln2_p1_threat , min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Threat, replace)
graph export $results/Figure4b_Threat.pdf, as(pdf) replace
eventStudy ln2_p1_rape , min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Rape, replace)
graph export $results/Figure4b_Rape.pdf, as(pdf) replace
eventStudy ln2_p1_totevent, min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(TotEvent, replace)
graph export $results/Figure4b_TotalEvent.pdf, as(pdf) replace


*** FIGURE 6 -------------------------------------------------------------------
* Panel (a) : only coefficient k=-1 is set to zero
eventStudy_alt ln2_p1_accident 		, min(-12) max(12) event(time_pacif) pan(id_upp quarter) name(Accident, replace)
graph export $results/Figure6a_Accident.pdf, as(pdf) replace
* Panel (b) : coefficients k=-1 and k=-12 are both set to zero
eventStudy ln2_p1_accident, min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Accident, replace)
graph export $results/Figure6b_Accident.pdf, as(pdf) replace


*** FIGURE H1 ------------------------------------------------------------------
* Event studies for different crime indicators with a 20% increase in reporting 
* Panel (a) : only coefficient k=-1 is set to zero
eventStudy_alt ln_p_violencenokill_r, min(-12) max(12) event(time_pacif) pan(id_upp quarter) name(Assault, replace)
graph export $results/FigureH1a_Assault.pdf, as(pdf) replace
eventStudy_alt ln_p_totalrobbery_r  , min(-12) max(12) event(time_pacif) pan(id_upp quarter) name(Robbery, replace)
graph export $results/FigureH1a_Robbery.pdf, as(pdf) replace
eventStudy_alt ln_p_totaltheft_r	  , min(-12) max(12) event(time_pacif) pan(id_upp quarter) name(Theft, replace)
graph export $results/FigureH1a_Theft.pdf, as(pdf) replace
eventStudy_alt ln_p_threat_r 	  , min(-12) max(12) event(time_pacif) pan(id_upp quarter) name(Threat, replace)
graph export $results/FigureH1a_Threat.pdf, as(pdf) replace
* Panel (b) : coefficients k=-1 and k=-12 are both set to zero
eventStudy ln_p_violencenokill_r, min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Violence, replace)
graph export $results/FigureH1b_Assault.pdf, as(pdf) replace
eventStudy ln_p_totalrobbery_r, min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Robbery, replace)
graph export $results/FigureH1b_Robbery.pdf, as(pdf) replace
eventStudy ln_p_totaltheft_r, min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Theft, replace)
graph export $results/FigureH1b_Theft.pdf, as(pdf) replace
eventStudy ln_p_threat_r , min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Threat, replace)
graph export $results/FigureH1b_Threat.pdf, as(pdf) replace


*** FIGURE H2 ------------------------------------------------------------------
* Event studies for different crime indicators with a 20% increase in reporting 
* Panel (a) : only coefficient k=-1 is set to zero
eventStudy_alt ln_p_totalextortion_r, min(-12) max(12) event(time_pacif) pan(id_upp quarter) name(Extortion, replace)
graph export $results/FigureH2a_Extortion.pdf, as(pdf) replace
eventStudy_alt ln_p_rape_r		  , min(-12) max(12) event(time_pacif) pan(id_upp quarter) name(Rape, replace)
graph export $results/FigureH2a_Rape.pdf, as(pdf) replace
eventStudy_alt ln_p_totevent_r 	  , min(-12) max(12) event(time_pacif) pan(id_upp quarter) name(TotEvent, replace)
graph export $results/FigureH2a_TotalEvent.pdf, as(pdf) replace
* Panel (b) : coefficients k=-1 and k=-12 are both set to zero
eventStudy ln_p_totalextortion_r, min(-12) max(12) event(time_pacif) pan(id_upp quarter) name(Extortion, replace)
graph export $results/FigureH2b_Extortion.pdf, as(pdf) replace
eventStudy ln_p_rape_r , min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Rape, replace)
graph export $results/FigureH2b_Rape.pdf, as(pdf) replace
eventStudy ln_p_totevent_r, min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(TotEvent, replace)
graph export $results/FigureH2b_TotalEvent.pdf, as(pdf) replace


*** FIGURE H3 ------------------------------------------------------------------
* Event studies with heterogenous treatment effects àla de Chaisemartin and D’Haultfœuille
* Code that runs on an older version of the package "did_multipleGT" but that does not run anymore
/*
did_multipleGT ln2_p1_murder id_upp quarter traitement, placebo(12) dynamic(11) cluster(id_upp) breps(500)
graph export $results/FigureH3_Hetero_murder.pdf, as(pdf) replace
did_multipleGT ln2_p1_violencenokill id_upp quarter traitement, placebo(12) dynamic(11) cluster(id_upp) breps(500)
graph export $results/FigureH3_Hetero_assault.pdf, as(pdf) replace
did_multipleGT ln2_p1_totalrobbery id_upp quarter traitement, placebo(12) dynamic(11) cluster(id_upp) breps(500)
graph export $results/FigureH3_Hetero_robbery.pdf, as(pdf) replace
did_multipleGT ln2_p1_totaltheft id_upp quarter traitement, placebo(12) dynamic(11) cluster(id_upp) breps(500)
graph export $results/FigureH3_Hetero_theft.pdf, as(pdf) replace
did_multipleGT ln2_p1_totalextortion id_upp quarter traitement, placebo(12) dynamic(11) cluster(id_upp) breps(500)
graph export $results/FigureH3_Hetero_extortion.pdf, as(pdf) replace
did_multipleGT ln2_p1_policeaction id_upp quarter traitement, placebo(12) dynamic(11) cluster(id_upp) breps(500)
graph export $results/FigureH3_Hetero_policeaction.pdf, as(pdf) replace
did_multipleGT ln2_p1_policekill id_upp quarter traitement, placebo(12) dynamic(11) cluster(id_upp) breps(500)
graph export $results/FigureH3_Hetero_policekill.pdf, as(pdf) replace
did_multipleGT ln2_p1_threat id_upp quarter traitement, placebo(12) dynamic(11) cluster(id_upp) breps(500)
graph export $results/FigureH3_Hetero_threat.pdf, as(pdf) replace
did_multipleGT ln2_p1_rape id_upp quarter traitement, placebo(12) dynamic(11) cluster(id_upp) breps(500)
graph export $results/FigureH3_Hetero_rape.pdf, as(pdf) replace
did_multipleGT ln2_p1_totevent id_upp quarter traitement, placebo(12) dynamic(11) cluster(id_upp) breps(500)
graph export $results/FigureH3_Hetero_totevent.pdf, as(pdf) replace
*/
* To produce results very close to those presented in the paper with the actual version of the package,
* run the following code, and find a way to build the graph from the estimated results (using coefplot for instance)
/*
did_multiplegt ln2_p1_murder id_upp quarter traitement, robust_dynamic placebo(12) dynamic(11) cluster(id_upp) breps(500)
did_multiplegt ln2_p1_violencenokill id_upp quarter traitement, robust_dynamic placebo(12) dynamic(11) cluster(id_upp) breps(500)
did_multiplegt ln2_p1_totalrobbery id_upp quarter traitement, robust_dynamic placebo(12) dynamic(11) cluster(id_upp) breps(500)
did_multiplegt ln2_p1_totaltheft id_upp quarter traitement, robust_dynamic placebo(12) dynamic(11) cluster(id_upp) breps(500)
did_multiplegt ln2_p1_totalextortion id_upp quarter traitement, robust_dynamic placebo(12) dynamic(11) cluster(id_upp) breps(500)
did_multiplegt ln2_p1_policeaction id_upp quarter traitement, robust_dynamic placebo(12) dynamic(11) cluster(id_upp) breps(500)
did_multiplegt ln2_p1_policekill id_upp quarter traitement, robust_dynamic placebo(12) dynamic(11) cluster(id_upp) breps(500)
did_multiplegt ln2_p1_threat id_upp quarter traitement, robust_dynamic placebo(12) dynamic(11) cluster(id_upp) breps(500)
did_multiplegt ln2_p1_rape id_upp quarter traitement, robust_dynamic placebo(12) dynamic(11) cluster(id_upp) breps(500)
did_multiplegt ln2_p1_totevent id_upp quarter traitement, robust_dynamic placebo(12) dynamic(11) cluster(id_upp) breps(500)
*/

* Method Callaway Sant'Anna just to check that it is consistent
/*
csdid ln2_p1_violencenokill, ivar(id_upp) time(quarter) gvar(quarter_bope) method(reg) agg(event) notyet
estat event, window(-12 12)
csdid_plot, style(rcap)
csdid ln2_p1_violencenokill, ivar(id_upp) time(quarter) gvar(quarter_bope) method(ipw) agg(event) notyet
estat event, window(-12 12)
csdid_plot, style(rcap)
*/


*** FIGURE H4 ------------------------------------------------------------------
* Event studies with Negative Binomial regressions
* Coefficients k=-1 and k=-12 are both set to zero
PoissonEventStudy murder, min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Murder, replace)
graph export $results/FigureH4_NegBin_Murder.pdf, as(pdf) replace
PoissonEventStudy violencenokill, min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Assault, replace)
graph export $results/FigureH4_NegBin_ViolentAssault.pdf, as(pdf) replace
PoissonEventStudy totalrobbery, min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Robbery, replace)
graph export $results/FigureH4_NegBin_Robbery.pdf, as(pdf) replace
PoissonEventStudy totaltheft, min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Theft, replace)
graph export $results/FigureH4_NegBin_Theft.pdf, as(pdf) replace
PoissonEventStudy policeaction, min(-12) max(12) event(time_pacif) pan(id_upp  quarter)  name(PoliceAction, replace)
graph export $results/FigureH4_NegBin_PoliceAction.pdf, as(pdf) replace
PoissonEventStudy policekill, min(-12) max(12) event(time_pacif) pan(id_upp  quarter)  name(PoliceKill, replace)
graph export $results/FigureH4_NegBin_PoliceKill.pdf, as(pdf) replace
PoissonEventStudy rape , min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Rape, replace)
graph export $results/FigureH4_NegBin_Rape.pdf, as(pdf) replace
PoissonEventStudy extortion , min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Extortion, replace)
graph export $results/FigureH4_NegBin_Extortion.pdf, as(pdf) replace
PoissonEventStudy threat , min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Threat, replace)
graph export $results/FigureH4_NegBin_Threat.pdf, as(pdf) replace
PoissonEventStudy totevent, min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(TotEvent, replace)
graph export $results/FigureH4_NegBin_TotalEvent.pdf, as(pdf) replace
* Only coefficient k=-1 is set to zero
*PoissonEventStudy_alt murder, min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Murder, replace) 
*PoissonEventStudy_alt violencenokill, min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Assault, replace) 
*PoissonEventStudy_alt totalrobbery, min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Robbery, replace) 
*PoissonEventStudy_alt totaltheft, min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Theft, replace) 
*PoissonEventStudy_alt policeaction, min(-12) max(12) event(time_pacif) pan(id_upp  quarter)  name(PoliceAction, replace) 
*PoissonEventStudy_alt policekill, min(-12) max(12) event(time_pacif) pan(id_upp  quarter)  name(PoliceKill, replace) 
*PoissonEventStudy_alt rape , min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Rape, replace) 
*PoissonEventStudy_alt extortion , min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Extortion, replace) 
*PoissonEventStudy_alt threat , min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(Threat, replace) 
*PoissonEventStudy_alt totevent, min(-12) max(12) event(time_pacif) pan(id_upp  quarter) name(TotEvent, replace) 


*** FIGURE P2 ------------------------------------------------------------------
* Only coefficient k=-1 is set to zero
eventStudy_alt ln2_p1_armarrest 	, min(-12) max(12) event(time_pacif) pan(id_upp quarter) name(Weapons, replace)
graph export $results/FigureP2_weapons.pdf, as(pdf) replace
* Coefficients k=-12 and k=-1 are set to zero
*eventStudy ln2_p1_armarrest	, min(-12) max(12) event(time_pacif) pan(id_upp quarter) name(Weapons, replace) 



