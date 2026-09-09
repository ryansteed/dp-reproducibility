###########################################################
##### Electoral Competition, Voter Bias and Women in Politics
###########################################################
##### By Thomas Le Barbanchon and Julien Sauvagnat
###########################################################

global root= ".."
*global root = "C:/XXX"
global directory "$root/Input"
cd "$directory"
cap global TABLES="$root/Output/"

/*
This do-file uses as inputs (databases located in folder Source):

1. database (and other intermediate datasets)
- constructed with CreateFinalSample.do 

2. stats_deputes (and link_names_upper)
- Monthly activity of MPs
- from https://www.nosdeputes.fr

3. GGS 
- Gender Generation Survey (GGS) Wave of 2005 
- obtained by Sauvagnat in May 2018
- https://www.ggp-i.org/data/

4. wagegaps_muni
- The dataset contains various measures of the gaps in earnings and wages between men and women, calculated using the DADS data for 1996, 2001, 2006, 2011 and 2015, at the municipal level.
We suppressed from the dataset:
- municipalities with fewer than 5 female workers, 
- municipalities with fewer than 5 male workers.



*/
************************************************************************************************

**Figure 1

use database, clear
collapse(mean) F, by(electionl)
set scheme s2color
sort electionl
twoway connected F electionl, mlabel() ///
	xlabel(1988 1993 1997 2002 2007 2012 2017) ///
	xtitle("Year") ytitle("") ylabel(0(0.1)0.5) ///
	xline(2000, lwidth(thick) lcolor(black)) 
	graph export ${TABLES}fig1.pdf, replace


use database, clear

gen contest=contest3P_
label var contest "Contestable District"

rename coalition_electionl coal_election

joinby dpt electionl circo coalition using localpoolbyp, unm(b)
drop _merge

joinby dpt electionl circo coalition using Findependent, unm(b)
drop _merge

drop if missing(electionl)


******
** Table 1
******
label var betterpoli  "Men better political leaders"
label var jobs "Men more right to a job"
label var age_ind_occ_egap "Gender earnings gap (residualized)"
label var contest3P_ "Contestable"

eststo clear
estpost summarize F age alumni PCS_3f entry incumbent gouv localmandate ///
scoreL1 elu scoreP1 contest ///
betterpoli jobs age_ind_occ_egap , detail
esttab using ${TABLES}table1.tex, cells("count mean(fmt(3)) sd(fmt(3)) p1(fmt(3)) p50(fmt(3)) p99(fmt(3))") ///
	nolines nogaps nomtitles noconst noobs nonumber label title("Summary statistics") replace prefoot("") postfoot("")

	
*Table A.1
global control_vars=" "

#delimit;
global list="age alumni PCS_3f entry incumbent gouv localmandate scoreL1 elu scoreP1 contest";
global listf="";
#delimit cr
                                                      
local i = 1
gen var=""
foreach var of newlist mean sd N meant sdt Nt p {
	gen `var'=.
}
local i=1
foreach var of varlist $list  {
	numlist "1/17"
	local myvar: word `i' of `r(numlist)'
	replace var="`var'" if _n==`myvar'
	qui sum `var' if F==0, det
	replace mean=r(mean) if _n==`myvar' 
	replace sd=r(sd) if _n==`myvar'
	replace N=r(N) if _n==`myvar'
	qui sum `var' if F==1, det
	replace meant=r(mean) if _n==`myvar' 
	replace sdt=r(sd) if _n==`myvar'
	replace Nt=r(N) if _n==`myvar'

	qui regress `var' F $control_vars , r
	test F=0
	replace p=r(p) if _n==`myvar'
	foreach var of varlist mean sd meant sdt p { 
		replace `var'=round(`var', 0.01)
	}
	local i=`i'+1
}

mkmat Nt meant sdt N mean sd p if _n<=17, mat(M) 
outtable using ${TABLES}tableA1, mat(M) replace center nobox ///
	format(%9.0f %9.3f %9.3f %9.0f %9.3f %9.3f %9.3f)	



*******
***Table 2
*******

winsor2 betterpoli jobs age_ind_occ_egap, replace

foreach var of varlist betterpoli jobs{
*** EDIT by Donna
* eststo clear
eststo: xi: reghdfe F `var', a(coal_election) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F `var', a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F `var' gouv entry incumbent i.localmandate_, a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
eststo D_`var': xi: reghdfe F `var' gouv entry incumbent i.localmandate_ scoreP1, a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
esttab using ${TABLES}table2.tex, se r2 nolines nogaps nomtitles noconst label b(%5.3f) se(%5.3f) keep(`var')  append ///
starlevels("*" 0.10 "**" 0.05 "***" 0.01)alignment(D{.}{.}{-1}) page(dcolumn) nonumber
}  

foreach var of varlist age_ind_occ_egap{
*** EDIT by Donna
* eststo clear
eststo: xi: reghdfe F `var', a(coal_election) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F `var', a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F `var' gouv entry incumbent i.localmandate_, ///
	a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F `var' gouv entry incumbent i.localmandate_ scoreP1, ///
	a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F `var' gouv entry incumbent i.localmandate_ scoreP1, ///
	a(coal_election age_ PCS_3f_ alumni circouniqueid) cl(candidatid district_electionl_g)
esttab using ${TABLES}table2.tex, se r2 nolines nogaps nomtitles noconst label b(%5.3f) se(%5.3f) append ///
	keep(`var') ///
	starlevels("*" 0.10 "**" 0.05 "***" 0.01)alignment(D{.}{.}{-1}) page(dcolumn) nonumber
}  

estout using "../../results/table2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

**Table 4

eststo clear
eststo: xi: reghdfe F contest3P_ if inrange(electionl,2002,2017), ///
	a(coal_election) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F contest3P_ scoreP1 if inrange(electionl,2002,2017), ///
	a(coal_election) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F contest3P_ scoreP1 if inrange(electionl,2002,2017), ///
	a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F contest3P_ scoreP1 gouv entry incumbent i.localmandate_ if inrange(electionl,2002,2017), ///
	a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F contest3P_ scoreP1 gouv entry incumbent age_ind_occ_egap i.localmandate_ if inrange(electionl,2002,2017), ///
	a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
eststo F: xi: reghdfe F contest3P_ scoreP1 gouv entry incumbent age_ind_occ_egap i.localmandate_ if inrange(electionl,2002,2017), ///
	a(coal_election age_ PCS_3f_ alumni circouniqueid) cl(candidatid district_electionl_g)
esttab using ${TABLES}table4.tex, se r2 nolines nogaps nomtitles noconst label b(%5.3f) se(%5.3f) replace ///
	keep(contest3P_) ///
	starlevels("*" 0.10 "**" 0.05 "***" 0.01)alignment(D{.}{.}{-1}) page(dcolumn) nonumber


winsor2 diffPCSr, replace
*** EDIT by Donna
* eststo clear
eststo: xi: reghdfe diffPCSr contest3P_ if inrange(electionl,2002,2017), ///
	a(coal_election) cl(candidatid district_electionl_g)
eststo: xi: reghdfe diffPCSr contest3P_ scoreP1 if inrange(electionl,2002,2017), ///
	a(coal_election) cl(candidatid district_electionl_g)
eststo: xi: reghdfe diffPCSr contest3P_ scoreP1 if inrange(electionl,2002,2017), ///
	a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
eststo: xi: reghdfe diffPCSr contest3P_ scoreP1 gouv entry incumbent i.localmandate_ if inrange(electionl,2002,2017), ///
	a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
eststo: xi: reghdfe diffPCSr contest3P_ scoreP1 gouv entry incumbent age_ind_occ_egap i.localmandate_ if inrange(electionl,2002,2017), ///
	a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
eststo: xi: reghdfe diffPCSr contest3P_ scoreP1 gouv entry incumbent age_ind_occ_egap i.localmandate_ if inrange(electionl,2002,2017), ///
	a(coal_election age_ PCS_3f_ alumni circouniqueid) cl(candidatid district_electionl_g)
esttab using ${TABLES}table4.tex, se r2 nolines nogaps nomtitles noconst label b(%5.3f) se(%5.3f) append ///
	keep(contest3P_) ///
	starlevels("*" 0.10 "**" 0.05 "***" 0.01)alignment(D{.}{.}{-1}) page(dcolumn) nonumber

estout using "../../results/table4.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace


**Table A.11
eststo clear
eststo: xi: reghdfe F contest3P_ if inrange(electionl,2002,2012), ///
	a(coal_election) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F contest3P_ scoreP1 if inrange(electionl,2002,2012), ///
	a(coal_election) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F contest3P_ scoreP1 if inrange(electionl,2002,2012), ///
	a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F contest3P_ scoreP1 gouv entry incumbent i.localmandate_ if inrange(electionl,2002,2012), ///
	a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F contest3P_ scoreP1 gouv entry incumbent age_ind_occ_egap i.localmandate_ if inrange(electionl,2002,2012), ///
	a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F contest3P_ scoreP1 gouv entry incumbent age_ind_occ_egap i.localmandate_ if inrange(electionl,2002,2012), ///
	a(coal_election age_ PCS_3f_ alumni circouniqueid) cl(candidatid district_electionl_g)
esttab using ${TABLES}tableA11.tex, se r2 nolines nogaps nomtitles noconst label b(%5.3f) se(%5.3f) replace ///
	keep(contest3P_) ///
	starlevels("*" 0.10 "**" 0.05 "***" 0.01)alignment(D{.}{.}{-1}) page(dcolumn) nonumber



* Table 5
gen contestL3=scoreL2>=0.47&scoreL2<=0.53
label var contestL3 "Ex-post tight race"

foreach num of numlist 1997 2002 {
eststo clear
eststo: xi: reghdfe F contestL3 if electionl==`num'&!missing(scoreL2), ///
	a(coal_election) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F contestL3 scoreL2 if electionl==`num'&!missing(scoreL2), ///
	a(coal_election) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F contestL3 scoreL2 if electionl==`num'&!missing(scoreL2), ///
	a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F contestL3 scoreL2 gouv entry incumbent i.localmandate_ if electionl==`num'&!missing(scoreL2), ///
	a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F contestL3 scoreL2 gouv entry incumbent age_ind_occ_egap i.localmandate_ if electionl==`num'&!missing(scoreL2), ///
	a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
esttab using ${TABLES}table5.tex, se r2 nolines nogaps nomtitles noconst label b(%5.3f) se(%5.3f) append ///
	keep(contestL3) ///
	starlevels("*" 0.10 "**" 0.05 "***" 0.01)alignment(D{.}{.}{-1}) page(dcolumn) nonumber
}

***Graph ex-post tight race

foreach num of numlist 1988 1993 1997 2002 2007 2012 2017 {
eststo: xi: reghdfe F contestL3 scoreL2 gouv entry incumbent age_ind_occ_egap i.localmandate_ if electionl==`num'&!missing(scoreL2), ///
	a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
estimates store E`num'
}

coefplot (E1988, aseq(1988) \ E1993, aseq(1993) \ E1997, aseq(1997)  \ E2002, aseq(2002) \ E2007, aseq(2007)  \ E2012, aseq(2012)  \ E2017, aseq(2017)), ///
keep(contestL3) xline(3.5, lcolor(black) lwidth(thin) lpattern(dash)) vertical swapnames title(Coefficient on ex-post tight race) 
graph export ${TABLES}dyn.pdf, replace

**Table A.8
replace nbFIndependentCoalition=0 if missing(nbFIndependentCoalition)

eststo clear
eststo: xi: reghdfe FshareIndependentCoalition contest3P_ if inrange(electionl,2002,2017), ///
	a(coal_election) cl(district_electionl_g)
eststo: xi: reghdfe FshareIndependentCoalition contest3P_ scoreP1 if inrange(electionl,2002,2017), ///
	a(coal_election) cl(district_electionl_g)
eststo: xi: reghdfe FshareIndependentCoalition contest3P_ scoreP1 if inrange(electionl,2002,2017), ///
	a(coal_election circouniqueid) cl(district_electionl_g)
	eststo: xi: reghdfe nbFIndependentCoalition contest3P_ if inrange(electionl,2002,2017), ///
	a(coal_election) cl(district_electionl_g)
eststo: xi: reghdfe nbFIndependentCoalition contest3P_ scoreP1 if inrange(electionl,2002,2017), ///
	a(coal_election) cl(district_electionl_g)
eststo: xi: reghdfe nbFIndependentCoalition contest3P_ scoreP1 if inrange(electionl,2002,2017), ///
	a(coal_election circouniqueid) cl(district_electionl_g)
	esttab using ${TABLES}tableA8.tex, se r2 nolines nogaps nomtitles noconst label b(%5.3f) se(%5.3f) append ///
	keep(contest3P_) ///
	starlevels("*" 0.10 "**" 0.05 "***" 0.01)alignment(D{.}{.}{-1}) page(dcolumn) nonumber



*Table A.7
replace contest3L=0 if missing(contest3L)
eststo clear
eststo: xi: reg contest3L contest3P_ if inrange(electionl,2002,2017)
eststo: xi: reghdfe contest3L contest3P_ if inrange(electionl,2002,2017), a(coal_election) cl(candidatid district_electionl_g)
eststo: xi: reghdfe contest3L contest3P_ if inrange(electionl,2002,2017), a(coal_election circouniqueid) cl(candidatid district_electionl_g)
eststo: xi: reg diffscoreL2_RL contest3P_ if inrange(electionl,2002,2017)
eststo: xi: reghdfe diffscoreL2_RL contest3P_ if inrange(electionl,2002,2017), a(coal_election) cl(candidatid district_electionl_g)
eststo: xi: reghdfe diffscoreL2_RL contest3P_ if inrange(electionl,2002,2017), a(coal_election circouniqueid) cl(candidatid district_electionl_g)
esttab using ${TABLES}tableA7.tex, se r2 nostar nolines nogaps nomtitles noconst label b(%5.3f) se(%5.3f) append  ///
	keep(contest3P_) ///
	starlevels("*" 0.10 "**" 0.05 "***" 0.01)alignment(D{.}{.}{-1}) page(dcolumn) nonumber



**Table A.9 and Table A.10
foreach v of varlist contest3P1 contest3P contest1P_ contest2P_ {
replace contest=`v'
eststo clear
eststo: xi: reghdfe F `v' if inrange(electionl,2002,2017), ///
	a(coal_election) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F `v' scoreP1 if inrange(electionl,2002,2017), ///
	a(coal_election) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F `v' scoreP1 if inrange(electionl,2002,2017), ///
	a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F `v' scoreP1 gouv entry incumbent i.localmandate_ if inrange(electionl,2002,2017), ///
	a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F `v' scoreP1 gouv entry incumbent age_ind_occ_egap i.localmandate_ if inrange(electionl,2002,2017), ///
	a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
eststo: xi: reghdfe F `v' scoreP1 gouv entry incumbent age_ind_occ_egap i.localmandate_ if inrange(electionl,2002,2017), ///
	a(coal_election age_ PCS_3f_ alumni circouniqueid) cl(candidatid district_electionl_g)
esttab using ${TABLES}tableA9A10.tex, se r2 nolines nogaps nomtitles noconst label b(%5.3f) se(%5.3f) append ///
	keep(`v') ///
	starlevels("*" 0.10 "**" 0.05 "***" 0.01)alignment(D{.}{.}{-1}) page(dcolumn) nonumber
}


****
*Table A.13	
*****

eststo clear
eststo: xi: reghdfe scoreL1 F, ///
	a(coal_election) cl(candidatid district_electionl_g)
eststo: xi: reghdfe scoreL1 F, ///
	a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
eststo: xi: reghdfe scoreL1 F gouv entry incumbent i.localmandate_, ///
	a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
eststo: xi: reghdfe scoreL1 F gouv entry incumbent i.localmandate_ scoreP1, ///
	a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
	eststo: xi: reghdfe scoreL1 F gouv entry incumbent i.localmandate_ scoreP1, ///
	a(coal_election age_ PCS_3f_ alumni circouniqueid) cl(candidatid district_electionl_g)
esttab using ${TABLES}tableA13.tex, nostar se r2 nolines nogaps nomtitles noconst label b(%5.3f) se(%5.3f) replace ///
	keep(F) ///
	starlevels("*" 0.10 "**" 0.05 "***" 0.01)alignment(D{.}{.}{-1}) page(dcolumn) nonumber

	
**Activites Parlementaires

use database, clear
keep if elu==1
keep if electionl>=2007

rename coalition_electionl coal_election

gen upper_link= prenom+" "+nom
keep dpt circo upper_link F circouniqueid scoreP1 gouv entry incumbent age_ind_occ_egap localmandate_ age_ PCS_3f_ alumni electionl candidatid coal_election
drop if real(dpt)==.
destring dpt, replace
count
save tempm, replace

use ../Source/stats_deputes, clear
rename num_deptmt dpt
rename num_circo circo
drop if real(dpt)==.
destring dpt, replace
rename nom nom_stat
*Il y a bien unique observation nom year month 
gen n=1
egen g=group(nom_stat election)
sort year month
egen g2=group(year month)

gen questions=questions_orales+questions_ecrites
gen propositions=propositions_signees+propositions_ecrites

foreach v of varlist semaines_presence rapports questions propositions questions_orales questions_ecrites propositions_signees propositions_ecrites hemicycle_interventions_courtes hemicycle_interventions commission_presences commission_interventions amendements_signes amendements_proposes amendements_adoptes {
replace `v'=0 if `v'==.
}

gen n2=1
rename election electionl
joinby nom_stat using ../Source/link_names_upper.dta
destring dpt, replace
joinby electionl dpt circo using tempm

keep if upper==upper_link

egen geym=group(electionl year month)

foreach v of varlist semaines_presence rapports questions propositions questions_orales questions_ecrites propositions_signees propositions_ecrites hemicycle_interventions_courtes hemicycle_interventions commission_presences commission_interventions amendements_signes amendements_adoptes {
bysort geym: egen q`v'=xtile(`v'), nq(5)
}

egen index3q=rowmean(qsemaines_presence qrapports qquestions_orales qquestions_ecrites qpropositions_signees qpropositions_ecrites qhemicycle_interventions_courtes qhemicycle_interventions qcommission_presences qcommission_interventions qamendements_signes qamendements_adoptes)

cap erase activity.tex
eststo clear


gen qhemicycle_interv_c=qhemicycle_interventions_courtes


foreach v of varlist index3q qsemaines_presence qrapports qquestions_orales qquestions_ecrites qpropositions_signees qpropositions_ecrites ///
	 qhemicycle_interv_c qhemicycle_interventions qcommission_presences qcommission_interventions qamendements_signes qamendements_adoptes {
xi: reghdfe `v' F scoreP1 if inrange(electionl,2002,2017), a(coal_election g2 dpt) cl(candidatid)
estimates store `v'
}

coefplot (index3q, aseq("{bf:Average Index}") \ qsemaines_presence, aseq(Presence in House) \ qrapports, aseq(Reports) \ qquestions_orales, aseq(Oral questions) \ qquestions_ecrites , aseq(Written questions) \ qpropositions_signees, aseq(Signed proposals)  \ qpropositions_ecrites, aseq(Written proposals)  \ qhemicycle_interv_c, aseq(Short oral intervention )  \ qhemicycle_interventions, aseq(Long oral intervention ) \ qcommission_presences, aseq(Presence in committee) \ qcommission_interventions, aseq(Interventions in committee) \ qamendements_signes, aseq(Signed amendments) \ qamendements_adoptes, aseq(Adopted amendments)), keep(F) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) swapnames title(Female-Male differences) 
graph export ${TABLES}gender_gap_parliamentary_activity.pdf, replace


*****Table A.2
use "../Source/wagegaps_muni.dta", clear
keep if year==2001
gen dpt=floor(comr/1000)
collapse (mean) e_gap w_gap age_egap age_ind_egap age_ind_occ_egap age_wgap age_ind_wgap age_ind_occ_wgap [w=N_pop], by(dpt)
save wage_temp.dta, replace


use "../Source/GGS.dta", clear
gen betterpoli=a1113_c==1|a1113_c==2
gen betterpoli2=betterpoli
replace betterpoli2=. if a1113_c==3
gen jobs=a1114_a==1|a1114_a==2
gen jobs2=jobs
replace jobs2=. if a1114_a==3
rename dpt_r dpt
drop if real(dpt)==.
destring dpt, replace

merge m:1 dpt using "wage_temp.dta"
keep if _m==3
drop _m
gen n=1
bysort dpt: egen nb=sum(n)
gen female=asex==2
eststo clear
eststo: xi: reg betterpoli jobs, cl(dpt)
eststo: xi: reg betterpoli jobs female, cl(dpt)
collapse (mean) betterpoli betterpoli2 jobs2 age_ind_occ_egap, by(dpt)
eststo: xi: reg betterpoli2 jobs2, cl(dpt)
eststo: xi: reg betterpoli2 age_ind_occ_egap, cl(dpt)
esttab using ${TABLES}tableA2.tex, se r2 nolines nogaps nomtitles noconst label b(%5.3f) se(%5.3f) replace ///
	starlevels("*" 0.10 "**" 0.05 "***" 0.01)alignment(D{.}{.}{-1}) page(dcolumn) nonumber

	
	