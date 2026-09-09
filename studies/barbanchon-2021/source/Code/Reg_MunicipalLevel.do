
global root= ".."
*global root = "C:/XXX"
global directory "$root/Input"
cd "$directory"
cap global TABLES="$root/Output/"


/*
This do-file uses as inputs (databases located in folder Source):

1. database_LRcoalitions
- main database at the candidate-election level (restricted to candidates of main Left and Right parties over parliamentary elections 1981 to 2017)

2. Legislatives-Municipalities.dta
- candidates' scores at the municipality level

3. intermunicipality
- Information on intermunicipality-level codes for each municipalities

4. wagegaps_muni
- The dataset contains various measures of the gaps in earnings and wages between men and women, calculated using the DADS data for 1996, 2001, 2006, 2011 and 2015, at the municipal level.
We suppressed from the dataset:
- municipalities with fewer than 5 female workers, 
- municipalities with fewer than 5 male workers.

5. census_munic_pop_age_emp_8214.dta
- Data on municipality' characteristics (from INSEE)

*/
************************************************************************************************


*Information on intermunicipality-level codes for each municipalities
use "../Source/intermunicipality", clear
joinby comr using "../Source/wagegaps_muni"

*Compute earnings gaps aggregated at inter-municipality level
gen numt=age_ind_occ_egap*N_pop
bysort can year: egen num=sum(numt)
bysort can year: egen denum=sum(N_pop)
gen age_ind_occ_egapcan=num/denum

drop numt num
gen numt=e_gap*N_pop
bysort can year: egen num=sum(numt)
gen e_gapcan=num/denum

drop numt num
gen numt=age_ind_egap*N_pop
bysort can year: egen num=sum(numt)
gen age_ind_egapcan=num/denum

drop numt num
gen numt=age_egap*N_pop
bysort can year: egen num=sum(numt)
gen age_egapcan=num/denum


keep age_egapcan age_ind_egapcan age_ind_occ_egapcan e_gapcan comr year
save wagegaps_munican, replace

*Start from our sample of candidates of main L and R coalitions

use ../Source/database_LRcoalitions, replace
* merge with municipality level scores at legislatives
rename scoreL1 scoreCircoL1
rename scoreL2 scoreCircoL2
rename exprimesL1 expCircoL1
rename exprimesL2 expCircoL2
rename voixL1 voixCircoL1
rename voixL2 voixCircoL2

keep voixC* nbcandidat* nb* candidatid parti_stab electionl election ///
circouniqueid dpt incumbent entry gouv age_ PCS_3f alumni F coalition ///
elu scoreCircoL1 scoreCircoL2 expCirco* codeinseeREN1 codeinseeREN2 codeinseeREN3 yeard*

* merge with their scores at municipality level
joinby candidatid electionl using "../Source/Legislatives-Municipalities.dta"


* merge with census data at municipality level (retrieve employment rates and so on)
gen year_census=.
replace year_census=2014 if electionl==2017
replace year_census=2009 if electionl==2012
replace year_census=2006 if electionl==2007
replace year_census=1999 if electionl==2002
replace year_census=1990 if electionl==1997
replace year_census=1990 if electionl==1993
replace year_census=1990 if electionl==1988

cap drop code_insee
gen code_insee=codeinsee
joinby code_insee year_census using "../Source/census_munic_pop_age_emp_8214.dta"


gen sh_emp_F=pop_emp_women_/pop_working_age_women_
label var sh_emp_F "Employment rate of women (within municipality)" 
gen sh_emp_M=pop_emp_men_/pop_working_age_men_
label var sh_emp_M "Employment rate of men (within municipality)" 
gen emp_gap=sh_emp_M-sh_emp_F
label var emp_gap "Gender employment gap"

gen dptd=dpt
destring dptd, replace
gen comr=dptd*1000+codecommune
tostring comr, replace
replace comr="0"+comr if length(comr)==4
tostring comr, replace

* merge with municipality level gender wage gaps
destring comr, replace
gen year=electionl
replace year=year-1
replace year=2015 if electionl==2017
replace year=1996 if electionl==1997|electionl==1993|electionl==1988
merge m:1 comr year using ../Source/wagegaps_muni
drop if _m==2
drop _m
joinby comr year using wagegaps_munican, unm(b)
drop if _m==2
drop _m


gen malesgap=(males)*(age_ind_occ_egap)

egen district_electionl_g=group(circouniqueid electionl)
label var district_electionl_g "District X Election FE"
egen com_electionl=group(comr electionl)
label var com_electionl "Municipality X Election FE"
egen coal_election=group(parti_stab electionl)
label var coal_election "Party X Election FE"
egen ce=group(candidatid electionl)
label var ce "Candidate X Election FE"

global WEIGHT="pop_tot_"
drop if missing(pop_tot_)
gen log_pop_tot_=log(pop_tot_)
label var log_pop_tot_ "Total population (log)"
gen gender_ratio=pop_tot_men_/pop_tot_
label var gender_ratio "Male rate (municipal level)"
gen Erate=pop_emp_/pop_working_age_	
label var Erate "Employment rate (municipality level)"
gen Urate=pop_unemployed_/(pop_unemployed_+pop_emp_)
label var Urate "Unemployment rate (municipal level, until 2002)"
gen sh_working_age=pop_working_age_/pop_tot_
label var sh_working_age "Share of population btw 15-64 years old"
	
label var scoreL1 "Electoral Score (Round 1 - legislative)"
label var scoreL2 "Electoral Score (Round 2 - legislative)"
label var PCS_3f "High skill occ."


* Gender score gap - Municipalities
gen bias=.
label var bias "labor market bias"
cap gen inter=.
label var inter "Female $\times$ labor market bias"
gen inter2=.
label var inter2 "Right Party $\times$  LM bias"
gen  inter3=.
label var inter3 "Elite educ. $\times$  LM bias"
gen inter4=.
label var inter4 "High educ. $\times$  LM bias"
gen inter4b=.
label var inter4b "Miss. occ. $\times$  LM bias"
gen interR=.
label var interR "Right Party Women x LM bias"
gen interL=.
label var interL "Left Party Women x LM bias"


	global X="inter"
global size="2000"

	gen interincumbent=.
	gen intergouv=.
	gen interentry=.
	gen intermissage=.
	gen interage=.

	gen inter3R=.
	gen inter4R=.
	gen inter4bR=.
	
	gen interincumbentR=.
	gen intergouvR=.
	gen interentryR=.
	gen intermissageR=.
	gen interageR=.
	

		gen missingage=(age_==0)
		
	
gen localmandate=1 if codeinseeREN1==codeinsee&electionl>=yeard1
replace localmandate=1 if codeinseeREN2==codeinsee&electionl>=yeard2
replace localmandate=1 if codeinseeREN3==codeinsee&electionl>=yeard3
replace localmandate=0 if missing(localmandate)&electionl>=2002
gen localmandate_=localmandate
replace localmandate_=2 if electionl<2002

*For municipalities below 2000 inhabitants, compute at the inter-municipality level
replace age_ind_occ_egap=age_ind_occ_egapcan if pop_tot_<=2000
replace e_gap=e_gapcan if pop_tot_<=2000
replace age_ind_egap=age_ind_egapcan if pop_tot_<=2000
replace age_egap=age_egapcan if pop_tot_<=2000

*Table 3
foreach var of varlist age_ind_occ_egap {
replace bias=`var'
replace inter=F*`var'
replace interR=(parti_stab=="R")*F*`var'
replace interL=(parti_stab=="L")*F*`var'
replace inter2=(parti_stab=="R")*`var'
replace inter3=alumni*`var'
label var inter3 "Elite educ. x LM bias"
replace inter4=PCS_3f*`var'
label var inter4 "High educ. x LM bias"
replace inter4=0 if missing(PCS_3f)
replace inter4b=missing(PCS_3f)*`var'
label var inter4b "Miss. occ. x LM bias"

replace interincumbent=incumbent*`var'
replace intergouv=gouv*`var'
replace interentry=entry*`var'
replace intermissage=(age_==0)*`var'
replace interage=age_*`var'
	}
eststo clear
eststo: xi: reghdfe scoreL1 inter F  [w=pop_tot_], ///
	a(com_electionl) cl(candidatid com_electionl)  tolerance(1e-2)
eststo: xi: reghdfe scoreL1 inter  [w=pop_tot_], ///
	a(ce com_electionl) cl(candidatid com_electionl)  tolerance(1e-2)	
eststo: xi: reghdfe scoreL1 inter inter3 inter4 inter4b intermissage interage [w=pop_tot_], ///
	a(ce com_electionl) cl(candidatid com_electionl)  tolerance(1e-2)
eststo: xi: reghdfe scoreL1 inter inter3 inter4 inter4b intermissage interage interincumbent intergouv interentry [w=pop_tot_], ///
	a(ce com_electionl) cl(candidatid com_electionl)  tolerance(1e-2)
	eststo: xi: reghdfe scoreL1 inter inter3 inter4 inter4b intermissage interage interincumbent intergouv interentry inter2 [w=pop_tot_], ///
	a(ce com_electionl) cl(candidatid com_electionl)  tolerance(1e-2)
	eststo: xi: reghdfe scoreL1 interR interL inter3 inter4 intermissage interage interincumbent intergouv interentry inter4b inter2 [w=pop_tot_], ///
	a(ce com_electionl) cl(candidatid com_electionl)  tolerance(1e-2)
	esttab using ${TABLES}table3.tex, se r2 nolines nogaps nomtitles noconst label b(%5.3f) se(%5.3f) append ///
	keep(F inter interR interL inter2 inter3 inter4) ///
	starlevels("*" 0.10 "**" 0.05 "***" 0.01)alignment(D{.}{.}{-1}) page(dcolumn) nonumber 
estout using "../../results/table3.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

	**Table A.4	
eststo clear
eststo: xi: reghdfe scoreL1 inter [w=pop_tot_] if pop_tot_>=0&electionl>=2002, a(ce com_electionl) cl(candidatid com_electionl)	 tolerance(1e-2)
eststo: xi: reghdfe scoreL1 inter localmandate [w=pop_tot_] if pop_tot_>=0&electionl>=2002, a(ce com_electionl) cl(candidatid com_electionl)  tolerance(1e-2)
eststo: xi: reghdfe scoreL1 inter if pop_tot_>=2000&electionl>=2002, a(ce com_electionl) cl(candidatid com_electionl)  tolerance(1e-2)
eststo: xi: reghdfe scoreL1 inter localmandate if pop_tot_>=2000&electionl>=2002, a(ce com_electionl) cl(candidatid com_electionl)  tolerance(1e-2)	
esttab using ${TABLES}tableA4.tex, se r2 nolines nogaps nomtitles noconst label b(%5.3f) se(%5.3f) append ///
	keep(inter localmandate) ///
	starlevels("*" 0.10 "**" 0.05 "***" 0.01)alignment(D{.}{.}{-1}) page(dcolumn) nonumber 
	*/

	

**Table A.5 
eststo clear
eststo: xi: reghdfe scoreL1 inter F if pop_tot_>=2000, ///
	a(com_electionl) cl(candidatid com_electionl)  tolerance(1e-2)
eststo: xi: reghdfe scoreL1 inter if pop_tot_>=2000, ///
	a(ce com_electionl) cl(candidatid com_electionl)  tolerance(1e-2)	
eststo: xi: reghdfe scoreL1 inter inter3 inter4 inter4b intermissage interage if pop_tot_>=2000, ///
	a(ce com_electionl) cl(candidatid com_electionl)  tolerance(1e-2)
eststo: xi: reghdfe scoreL1 inter inter3 inter4 inter4b intermissage interage interincumbent intergouv interentry if pop_tot_>=2000, ///
	a(ce com_electionl) cl(candidatid com_electionl)  tolerance(1e-2)
	eststo: xi: reghdfe scoreL1 inter inter3 inter4 inter4b intermissage interage interincumbent intergouv interentry inter2 if pop_tot_>=2000, ///
	a(ce com_electionl) cl(candidatid com_electionl)  tolerance(1e-2)
	eststo: xi: reghdfe scoreL1 interR interL inter3 inter4 intermissage interage interincumbent intergouv interentry inter4b inter2 if pop_tot_>=2000, ///
	a(ce com_electionl) cl(candidatid com_electionl)  tolerance(1e-2)
esttab using ${TABLES}tableA5.tex, se r2 nolines nogaps nomtitles noconst label b(%5.3f) se(%5.3f) append ///
	keep(F inter interR interL inter2 inter3 inter4) ///
	starlevels("*" 0.10 "**" 0.05 "***" 0.01)alignment(D{.}{.}{-1}) page(dcolumn) nonumber 

		
***Table A.6

eststo clear
foreach var of varlist e_gap age_egap age_ind_egap age_ind_occ_egap {
replace bias=`var'
replace inter=F*`var'
replace interR=(parti_stab=="R")*F*`var'
replace interL=(parti_stab=="L")*F*`var'
replace inter2=(parti_stab=="R")*`var'
replace inter3=alumni*`var'
label var inter3 "Elite educ. x LM bias"
replace inter4=PCS_3f*`var'
label var inter4 "High educ. x LM bias"
replace inter4=0 if missing(PCS_3f)
replace inter4b=missing(PCS_3f)*`var'
label var inter4b "Miss. occ. x LM bias"
replace inter3R=inter3*(parti_stab=="R")
replace inter4R=inter4*(parti_stab=="R")
replace inter4bR=inter4b*(parti_stab=="R")
replace interincumbentR=incumbent*`var'*(parti_stab=="R")
replace intergouvR=gouv*`var'*(parti_stab=="R")
replace interentryR=entry*`var'*(parti_stab=="R")
replace intermissageR=(age_==0)*`var'*(parti_stab=="R")
replace interageR=age_*`var'*(parti_stab=="R")	
replace interincumbent=incumbent*`var'
replace intergouv=gouv*`var'
replace interentry=entry*`var'
replace intermissage=(age_==0)*`var'
replace interage=age_*`var'
	
	eststo: xi: reghdfe scoreL1 inter inter3 inter4 inter4b intermissage interage interincumbent intergouv interentry inter2 [w=pop_tot_], ///
	a(ce com_electionl) cl(candidatid com_electionl)  tolerance(1e-2)
}
esttab using ${TABLES}tableA6.tex, se r2 nolines nogaps nomtitles noconst label b(%5.3f) se(%5.3f) append ///
	keep(inter) ///
	prehead(\begin{table} \caption{\bf Gender and Electoral Scores }\begin{footnotesize} ///
	\begin{center} \begin{tabular}{l*{4}{c}}\hline\hline \addlinespace \\ &\multicolumn{4}{c}{Score - Round 1} \\&\multicolumn{4}{c}{Earnings Gaps Adjusted For}&\\  &Raw&+Age&+Age&+Age\\&&&+Industry&+Industry\\&&&&+Occupation\\\cmidrule(lr){2-5}) ///
	starlevels("*" 0.10 "**" 0.05 "***" 0.01)alignment(D{.}{.}{-1}) page(dcolumn) nonumber ///
	postfoot(\addlinespace \\ \hline \hline "\end{tabular} \end{center} \end{footnotesize} \end{table}") 

cap gen missingPCS_3f=missing(PCS_3f)
cap replace PCS_3f=0 if missing(PCS_3f)

gen R=parti_stab=="R"
foreach var in F R alumni PCS_3f missingPCS_3f gouv entry incumbent missingage age_ {
foreach com in age_ind_occ_egap Erate log_pop_tot_ gender_ratio sh_working_age sh_emp_M {
cap drop `var'x`com'
gen `var'x`com'=`var'*`com'
}
}


eststo clear
foreach com in gender_ratio log_pop_tot_ Erate sh_emp_M {
eststo: xi: reghdfe scoreL1 Fxage_ind_occ_egap Rxage_ind_occ_egap inter3 inter4 inter4b ///
	Fx`com' Rx`com' alumnix`com' PCS_3fx`com' missingagex`com' age_x`com' intermissage interage missingPCS_3fx`com' interincumbent intergouv interentry gouvx`com' entryx`com' incumbentx`com' ///
	[w=pop_tot_], ///
 a(ce com_electionl) cl(candidatid com_electionl)  tolerance(1e-2)
}
esttab using ${TABLES}tableA3.tex, se r2 nolines nogaps nomtitles noconst label b(%5.3f) se(%5.3f) append ///
	keep(Fxage_ind_occ_egap Fxlog_pop_tot_ Fxgender_ratio FxErate Fxsh_emp_M) ///
	starlevels("*" 0.10 "**" 0.05 "***" 0.01)alignment(D{.}{.}{-1}) page(dcolumn) nonumber 
