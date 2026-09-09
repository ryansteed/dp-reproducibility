clear all
set max_memory 30g
set matsize 11000
set more off

do 0_macro_libraries.do

tempfile x y

* Import characteristics of UPPs (pacification date, socio-demo, ...)
import delimited $data_upp_main, clear
drop bope pacified
replace date_upp="" if upp=="DoUppMare"
order upp city complexo date_bope date_upp effpolice gang 
foreach var in population_favela domicile_moins_smic responsable_domicile_ logement_proprietaire logement_locataire logement_occupe logement_autre electricite eau_potable egout ordure analphabete_15ans_plu analphabete_10_14ans 15_29ans 10_29ans 5_29ans 0_29ans {
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

*** Set the panel
egen id_upp = group(upp)
xtset id_upp date

*** Linear timetrend specific to each UPP
forv j=1/38 {
	gen upp_`j'=(id_upp==`j')
	gen upp_timetrend`j' = upp_`j'*date
	gen upp_quad_timetrend`j' = upp_`j'*date*date
	drop upp_`j'
}

*** Variables about gang
gen gang_bis=gang
replace gang_bis="CV" if gang_bis=="CV HQ"
replace gang_bis="contested" if gang_bis=="MILITIA"
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


*** Treatment variables for geographic spillovers 
* (1) Treatment variable specific to Cidade de Deus "DoUppCdd"(large favela controlled by CY pre-pacification)
gen _time_bope_cdd=time_bope if upp=="DoUppCdd"
egen time_bope_cdd=max(_time_bope_cdd)
gen diff_cdd_pacif=time-time_bope_cdd
gen cdd_pacif=(diff_cdd_pacif>0)
replace cdd_pacif=diff_cdd_pacif/nday_of_month if diff_cdd_pacif < nday_of_month & cdd_pacif==1
drop _time_bope_cdd time_bope_cdd diff_cdd_pacif
* (2) Treatment variable specific to Alemao "DoUppAleamo", HQ of CV, which was pacified at the same time than
* DoUppVilaCruzeiro, DoUppNovaBrasilia, DoUppAdeusBaiana, DoUppParqueProletario, DoUppAlemao, DoUppFazendinha
gen _time_bope_alemao=time_bope if upp=="DoUppAlemao"
egen time_bope_alemao=max(_time_bope_alemao)
gen diff_alemao_pacif=time-time_bope_alemao
gen alemao_pacif=(diff_alemao_pacif>0)
replace alemao_pacif=diff_alemao_pacif/nday_of_month if diff_alemao_pacif < nday_of_month & alemao_pacif==1
drop _time_bope_alemao time_bope_alemao diff_alemao_pacif
* Binary indicator
gen nopacif=1-pacified-intervention
* Cidade de Deus
gen CVnopacifxCDD_pacif=gang_cv * nopacif * cdd_pacif
* Alemao
gen CVnopacifxALEAMO_pacif=gang_cv * nopacif * alemao_pacif


*** Variables of HETEROGENEITY -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Population of the 2010 census
gen pop10 = population
* Police officer density per inhabitant
gen perc_effpolice=effpolice/pop10
* Population density
gen densite_pop=densite
* Variables socio-demo
gen perc_proprio=perc_logement_proprietaire
gen perc_analphabete=perc_analphabete_15ans_plu + perc_analphabete_10_14ans
gen perc_alphabete=100-perc_analphabete
gen perc_potable=perc_eau_potable
gen perc_elec=perc_electricite
gen perc_jeune=perc_15_29ans
gen perc_jeune2=perc_10_29ans
gen perc_jeune3=perc_5_29ans
gen perc_jeune4=perc_0_29ans

gen perc_infsmic=perc_chefmenage_moins_smic 
gen perc_tenxsmic=perc_chefmenage_10fois_smic
gen perc_popfavela=perc_population_favela

*** Interaction between treatment and gang
foreach v in gang_ada gang_cv gang_cvhq gang_cvnohq gang_contest {
	gen pacif_`v'=pacified*`v' 
	gen inter_`v'=intervention*`v'
}
foreach v in duree_intervention date_upp densite_pop revenu_tete effpolice {
	gen pacif_`v'=pacified*`v' 
	gen inter_`v'=intervention*`v'
}
 * Interaction between treatment and heterogeneity of favelas (percentage of the population)
foreach v in proprio alphabete potable elec egout ordure jeune jeune2 jeune3 jeune4 infsmic tenxsmic popfavela {
	gen pacif_p_`v' = pacified * perc_`v'
	gen inter_p_`v' = intervention * perc_`v'
}
* Variable ZONE SUD: "zone sud" correspond to the central favelas (to test the assumption about the proxy variable)
gen pacif_zonesud = pacified * zone_sud
gen inter_zonesud = intervention * zone_sud
* Altitude variables interactions
gen altitude_diff=altitude_max-altitude_min
foreach var of varlist altitude_mean altitude_std altitude_diff  {
	gen pacif_`var' = pacified * `var'
	gen inter_`var' = intervention * `var'
}



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
* All events related to cars
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


*** We compute the average value of crime percentage variables over the period 2007-2008 which is the period
* during which no UPP have been installed (first UPP installed the 19th of December 2008)
gen y20072008=inrange(year,2007,2008)
foreach var of varlist drugarrest armarrest policeaction policekill policedeath murder violencenokill rape totalrobbery totaltheft fraud threat extortion totevent accident accident_nodeath kidnap {
	gen b_`var'=p1_`var' if y20072008==1
	bysort upp : egen pre_p1_`var' = mean(b_`var')
	drop b_`var' 
}
drop y20072008
foreach v of varlist policeaction policekill policedeath murder violencenokill rape totalrobbery totaltheft fraud threat extortion totevent accident accident_nodeath kidnap {
	gen pacif_pre_`v'=pacified*pre_p1_`v'
}

*** Violence après la pacification (la derniere pacification dans l'échantillon a lieu le 23 may 2014)
gen y20152016=(year==2015|year==2016)
foreach var of varlist policeaction policekill policedeath murder violencenokill rape totalrobbery totaltheft fraud threat extortion totevent accident accident_nodeath kidnap {
	gen b_`var'=p1_`var' if y20152016==1
	bysort upp : egen post_p1_`var' = mean(b_`var')
	drop b_`var'
}
drop y20152016


*** Annual number of crimes per 100000 inhabitants before and after pacification
foreach v in murder violencenokill totalrobbery totaltheft policeaction policekill threat rape extortion totevent accident {
	gen desc_pre_`v'  = pre_p1_`v' * 12 * 100000
	gen desc_post_`v' = post_p1_`v' * 12 * 100000
}


*** Rename population variables
gen pop1=pop10

*** Generate log of crime percentage
gen epsilon1=1
gen epsilon2=0.5
gen epsilon3=0.25
foreach v of varlist homicideintentional-eventsregistration policekill-streetrobbery {
gen ln1_p1_`v' = log((`v'+epsilon1) / pop10)
gen ln2_p1_`v' = log((`v'+epsilon2) / pop10)
gen ln3_p1_`v' = log((`v'+epsilon3) / pop10)
}

*** ¨Years when BOPE enters the favelas and when the UPP is installed
gen year_pacif=year(time_upp)
gen year_bope=year(time_bope)


*** Dependent variables (to fix the endogeneous reporting bias using accident as a proxy variable)
forv l=1/3 {
	forv p=1/1 {
		foreach v of varlist policeaction policekill murder violencenokill rape totalrobbery totaltheft fraud threat totalextortion extortion totevent carrobbery cartheft totalcar extortionwithkidnap extortwithtempkidnap kidnap {
		gen ln`l'_p`p'_`v'_a = ln`l'_p`p'_`v' - ln`l'_p`p'_accident
		}
	}
}


*** Save the processed dataset
save $processed/data_for_analysis.dta, replace
