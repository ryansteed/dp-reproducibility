**********************************************************
**		Monica Martinez-Bravo							**
**		THE ROLE OF LOCAL OFFICIALS IN NEW DEMOCRACIES: **
**		EVIDENCE FROM INDONESIA	 						**
**		28th June 2013   								**
**********************************************************

clear
clear matrix
set mem 8g
set maxvar 32767 
set matsize 11000

//cd "/Users/your_path"

/* Defining Controls */
# delimit ;
global geography "urbDum_1996 
perc_ruralHH_1996 perc_ruralHH_1996_2 perc_ruralHH_1996_3 perc_ruralHH_1996_4 
ShareRurLand_1996  altitude_high_1996 lpopulation_1996* popdensity_1996 
dist_kecoffice_2000 dist_kab_kotacapital_2000";
global religion "mosqueph_1996 prayerhouseph_1996 churchesph_1996 viharaph_1996"  ;
global facilities "num_TVs_1996_pc   
num_hospitals_1996_pc num_maternhosp_1996_pc num_polyclinic_1996_pc num_puskesmas_1996_pc 
num_kindgarden_1996_pc num_primarysch_1996_pc  num_HS_1996_pc" ;
# delimit cr


#delimit ;
global conflict "conf_student_2003 conf_villagers_2003 conf_apparat_2003 conf_ethnic_2003 conf_other_2003";
global army_police "armyinvil KamlinDum PoliceDum";
global mining "perc_miningHH_1996 quarried_coralstone_1996 quarried_sand_1996 quarried_lime_1996 quarried_sulfur_1996 
quarried_kaolin_1996 quarried_kwarsa_1996";
global facilitieschange "hospchange_96_00 puskchange_96_00  maternhospchange_96_00 polyclinicchange_96_00 kindchange_96_00 primaryschchange_96_00";
global fundschange "changeCentrGov  changeProvGov changeKabGov";
global IDT "IDTinVillage_1996 perHH_receiIDT_1996"; 
global alignment_00_03 "changeCentrGov  changeProvGov changeKabGov hospchange_00_03perc puskchange_00_03perc 
maternhospchange_00_03perc polyclinicchange_00_03perc kindchange_00_03perc primaryschchange_00_03perc";
#delimit cr


******************************
/*   TABLE 1 		    */
/* DESCRIPTIVE STATISTICS   */
******************************
clear
use LocalOfficials_AER.dta, clear

foreach var of varlist GolkarFirst kelurDum $geography $religion $facilities{ 
drop if `var'==.
}

# delimit  ;
sum 
GolkarFirst
PDIFirst 
PKBFirst
PPPFirst
OtherFirst
kelurDum
urbDum_1996 
perc_ruralHH_1996 ShareRurLand_1996  altitude_high_1996 population_1996 popdensity_1996 
dist_kecoffice_2000 dist_kab_kotacapital_2000
mosqueph_1996 prayerhouseph_1996 churchesph_1996 viharaph_1996  
num_TVs_1996_pc   
num_hospitals_1996_pc num_maternhosp_1996_pc num_polyclinic_1996_pc num_puskesmas_1996_pc 
num_kindgarden_1996_pc num_primarysch_1996_pc  num_HS_1996_pc 
conflict_2003 armyinvil PoliceDum perc_miningHH_1996 puskchange_96_00 primaryschchange_96_00 
changeCentrGov changeProvGov changeKabGov
	/*if kelurDum==1*/
	/*if kelurDum==0*/
;
# delimit  cr

egen num_kabs=group(kab)
egen num_kecs=group(kec)
by kab, sort: egen vil_distr=count(kelurDum)
by kab: egen numkel_dist=total(kelurDum)
by kab: egen pop_dist=total(population_1996) 

sum num_kabs num_kecs 

duplicates drop kab, force 
sum vil_distr 
sum numkel_dist
sum pop_dist

/* ELELECTORAL RESULTS */
gen Elec_1999="Golkar" if  GolkarFirst_kab==1
replace Elec_1999="PDI" if  PDIFirst_kab==1
replace Elec_1999="PKB" if  PKBFirst_kab==1
replace Elec_1999="PPP" if  PPPFirst_kab==1
replace Elec_1999="PAN" if  PANFirst_kab==1
replace Elec_1999="PBB" if  PBBFirst_kab==1

gen Elec_1999_2nd="Golkar" if  GolkarSecond_kab==1
replace Elec_1999_2nd="PDI" if  PDISecond_kab==1
replace Elec_1999_2nd="PKB" if  PKBSecond_kab==1
replace Elec_1999_2nd="PPP" if  PPPSecond_kab==1
replace Elec_1999_2nd="PAN" if  PANSecond_kab==1
replace Elec_1999_2nd="PBB" if  PBBSecond_kab==1
replace Elec_1999_2nd="PDKB" if  secondpdkb_1999==1

tab Elec_1999
tab Elec_1999_2nd


******************************
/*   TABLE 2 		    	*/
/* BASELINE SPECIFICATION   */
******************************
clear
use LocalOfficials_AER.dta, clear
tab kab, gen(idkab_dum)

/* A. OLS */
/* Raw Difference */
reg GolkarFirst kelurDum, vce(cluster kab)
local adjR2=e(r2_a)
outreg2 kelurDum using "T2", /*
*/excel nocons bdec(4) addstat(Adjusted R2, `adjR2') ctitle(OLS, No contr No FE) addnote(OLS) append

/* Fixed Effects */
reg GolkarFirst kelurDum idkab_d*, vce(cluster kab)
local adjR2=e(r2_a)
outreg2 kelurDum using "T2", /*
*/excel nocons bdec(4) addstat(Adjusted R2, `adjR2')  ctitle(OLS, No contr FE) append

/* Geographic Characteristics */
reg GolkarFirst kelurDum $geography idkab_d*, vce(cluster kab)
local adjR2=e(r2_a)
outreg2 kelurDum using "T2", /*
*/	excel nocons bdec(4) addstat(Adjusted R2, `adjR2') ctitle(OLS, GEO) append

/* Religion */
reg GolkarFirst kelurDum  $geography $religion idkab_d*, vce(cluster kab)
local adjR2=e(r2_a)
outreg2 kelurDum using "T2", /*
*/	excel nocons bdec(4) addstat(Adjusted R2, `adjR2') ctitle(OLS, GEO+REL) append

/* Facilities pc*/
eststo: reg GolkarFirst kelurDum $geography $religion $facilities idkab_d*, vce(cluster kab)
local adjR2=e(r2_a)
outreg2 kelurDum using "T2", /*
*/	excel nocons bdec(4) addstat(Adjusted R2, `adjR2') ctitle(OLS, GEO+REL+FAC) append

*** EDITED by Ryan Steed
estout using "../../results/Table2Col5.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
if 0 {
***

/* B. PROBIT */
prob GolkarFirst kelurDum idkab_d*, vce(cluster kab)
local r2_pseudo=e(r2_p)
local loglikelihood=e(ll)
outreg2 kelurDum using "T2", excel nocons bdec(4) append /*
*/ ctitle(PROBIT, No contr FE) addstat(Log-likelihood, `loglikelihood', Pseudo R-sq, `r2_pseudo')
mfx, varlist(kelurDum)
outreg2 kelurDum using "T2", mfx excel nocons bdec(4)  ctitle(MFX) append


prob GolkarFirst kelurDum  $geography idkab_d*, vce(cluster kab)
local r2_pseudo=e(r2_p)
local loglikelihood=e(ll)
outreg2 kelurDum using "T2", excel nocons bdec(4) append /*
*/ ctitle(PROBIT, GEO) addstat(Log-likelihood, `loglikelihood', Pseudo R-sq, `r2_pseudo')
mfx, varlist(kelurDum)
outreg2 kelurDum using "T2", mfx excel nocons bdec(4)  ctitle(MFX) append

prob GolkarFirst kelurDum  $geography $religion idkab_d*, vce(cluster kab)
local r2_pseudo=e(r2_p)
local loglikelihood=e(ll)
outreg2 kelurDum using "T2", excel nocons bdec(4) append ctitle(PROBIT, GEO+REL) /*
*/ addstat(Log-likelihood, `loglikelihood', Pseudo R-sq, `r2_pseudo')
mfx, varlist(kelurDum)
outreg2 kelurDum using "T2", mfx excel nocons bdec(4)  ctitle(MFX) append

prob GolkarFirst kelurDum  $geography $religion $facilities idkab_d*, vce(cluster kab)
local r2_pseudo=e(r2_p)
local loglikelihood=e(ll)
outreg2 kelurDum using "T2", excel nocons bdec(4) append ctitle(PROBIT, GEO+REL+FAC) /*
*/ addstat(Log-likelihood, `loglikelihood', Pseudo R-sq, `r2_pseudo')
mfx, varlist(kelurDum)
outreg2 kelurDum  using "T2", mfx excel nocons bdec(4)  ctitle(MFX) append




** 	C. Prop Score Matching 	** 
use LocalOfficials_AER.dta, clear
tab kab, gen(idkab_dum)

** First Stage * GEOGRAPHY CONTROLS
egen g = group(prop) 
levelsof g, local(gr)
gen pscore=.
foreach j of local gr {
psmatch2 kelurDum $geography idkab_d* if g==`j', out(GolkarFirst) 
replace pscore= _pscore if g==`j'
drop _pscore
}

drop if pscore==.

gen maxmin=.
gen minmax=.
gen temp1=.
gen temp2=.
gen mindesa=. 
gen maxdesa=. 
gen minkelur=.
gen maxkelur=. 

levelsof g, local(gr)
foreach j of local gr {
sum pscore if g==`j' & kelurDum==1
replace minkelur=r(min) if g==`j'
replace maxkelur=r(max) if g==`j'
sum pscore if g==`j' & kelurDum==0
replace mindesa=r(min) if g==`j'
replace maxdesa=r(max) if g==`j'


* Highest Minimum
replace temp1=mindesa-minkelur if g==`j' 
sum temp1 if g==`j'
replace maxmin=mindesa if temp1>=0 & g==`j'
replace maxmin=minkelur if temp1<=0 & g==`j'

drop if kelurDum==0 & pscore<maxmin & g==`j' & pscore!=.
drop if kelurDum==1 & pscore<maxmin & g==`j' & pscore!=.

* Lowest Maximum
replace temp2=maxkelur-maxdesa if g==`j'
sum temp2 if g==`j'
replace minmax=maxdesa if temp2>=0 & g==`j'
replace minmax=maxkelur if temp2<=0 & g==`j'

drop if kelurDum==0 & pscore> minmax & g==`j' & pscore!=.
drop if kelurDum==1 & pscore> minmax & g==`j' & pscore!=.

}
drop temp1 temp2

*** Estimating Strata keeping only sample of common support *** 
by g, sort: egen temp1=pctile(pscore), p(20)
by g, sort: egen temp2=pctile(pscore), p(40)
by g, sort: egen temp3=pctile(pscore), p(60)
by g, sort: egen temp4=pctile(pscore), p(80)

gen pscore_dum=20 if pscore<temp1 & pscore!=.
replace pscore_dum=40 if (pscore>=temp1 & pscore<temp2 & pscore!=.) 
replace pscore_dum=60 if (pscore>=temp2 & pscore<temp3 & pscore!=.) 
replace pscore_dum=80 if (pscore>=temp3 & pscore<temp4 & pscore!=.) 
replace pscore_dum=100 if (pscore>=temp4 & pscore!=.) 
drop temp*


/* Col 3. Matching Estimator. Geo Controls */

#delimit ;
xi: reg GolkarFirst kelurDum i.prop i.pscore_dum i.prop*i.pscore_dum, vce(bootstrap);
#delimit ;
local adjR2=e(r2_a);
outreg2 kelurDum 
using "T2", excel nocons bdec(4) append addstat(Adjusted R2, `adjR2') ctitle(PSM, GEO);
#delimit cr




** GEO+REL + idkab in the first stage 
use LocalOfficials_AER.dta, clear
tab kab, gen(idkab_dum)

egen g = group(prop) 
levelsof g, local(gr)
gen pscore=.
foreach j of local gr {
psmatch2 kelurDum $geography $religion idkab_d* if g==`j', out(GolkarFirst) 
replace pscore= _pscore if g==`j'
drop _pscore
}

drop if pscore==.

gen maxmin=.
gen minmax=.
gen temp1=.
gen temp2=.
gen mindesa=. 
gen maxdesa=. 
gen minkelur=.
gen maxkelur=. 

levelsof g, local(gr)
foreach j of local gr {
sum pscore if g==`j' & kelurDum==1
replace minkelur=r(min) if g==`j'
replace maxkelur=r(max) if g==`j'
sum pscore if g==`j' & kelurDum==0
replace mindesa=r(min) if g==`j'
replace maxdesa=r(max) if g==`j'


* Highest Minimum
replace temp1=mindesa-minkelur if g==`j' 
sum temp1 if g==`j'
replace maxmin=mindesa if temp1>=0 & g==`j'
replace maxmin=minkelur if temp1<=0 & g==`j'

drop if kelurDum==0 & pscore<maxmin & g==`j' & pscore!=.
drop if kelurDum==1 & pscore<maxmin & g==`j' & pscore!=.

* Lowest Maximum
replace temp2=maxkelur-maxdesa if g==`j'
sum temp2 if g==`j'
replace minmax=maxdesa if temp2>=0 & g==`j'
replace minmax=maxkelur if temp2<=0 & g==`j'

drop if kelurDum==0 & pscore> minmax & g==`j' & pscore!=.
drop if kelurDum==1 & pscore> minmax & g==`j' & pscore!=.

}
drop temp1 temp2


*** Estimating Strata keeping only sample of common support *** 
by g, sort: egen temp1=pctile(pscore), p(20)
by g, sort: egen temp2=pctile(pscore), p(40)
by g, sort: egen temp3=pctile(pscore), p(60)
by g, sort: egen temp4=pctile(pscore), p(80)

gen pscore_dum=20 if pscore<temp1 & pscore!=.
replace pscore_dum=40 if (pscore>=temp1 & pscore<temp2 & pscore!=.) 
replace pscore_dum=60 if (pscore>=temp2 & pscore<temp3 & pscore!=.) 
replace pscore_dum=80 if (pscore>=temp3 & pscore<temp4 & pscore!=.) 
replace pscore_dum=100 if (pscore>=temp4 & pscore!=.) 
drop temp*


/* Table 2. Matching Estimator */
#delimit ;
xi: reg GolkarFirst kelurDum i.prop i.pscore_dum i.prop*i.pscore_dum, vce(bootstrap);
#delimit ;
local adjR2=e(r2_a);
outreg2 kelurDum 
using "T2", excel nocons bdec(4) append addstat(Adjusted R2, `adjR2') ctitle(PSM, GEO+REL);
#delimit cr

** GEO+REL +FAC+ idkab in the first stage 
use LocalOfficials_AER.dta, clear 
tab kab, gen(idkab_dum)

egen g = group(prop) 
levelsof g, local(gr)
gen pscore=.
foreach j of local gr {
psmatch2 kelurDum $geography $religion $facilities idkab_d* if g==`j', out(GolkarFirst) 
replace pscore= _pscore if g==`j'
drop _pscore
}

drop if pscore==.

gen maxmin=.
gen minmax=.
gen temp1=.
gen temp2=.
gen mindesa=. 
gen maxdesa=. 
gen minkelur=.
gen maxkelur=. 

levelsof g, local(gr)
foreach j of local gr {
sum pscore if g==`j' & kelurDum==1
replace minkelur=r(min) if g==`j'
replace maxkelur=r(max) if g==`j'
sum pscore if g==`j' & kelurDum==0
replace mindesa=r(min) if g==`j'
replace maxdesa=r(max) if g==`j'


* Highest Minimum
replace temp1=mindesa-minkelur if g==`j' 
sum temp1 if g==`j'
replace maxmin=mindesa if temp1>=0 & g==`j'
replace maxmin=minkelur if temp1<=0 & g==`j'

drop if kelurDum==0 & pscore<maxmin & g==`j' & pscore!=.
drop if kelurDum==1 & pscore<maxmin & g==`j' & pscore!=.

* Lowest Maximum
replace temp2=maxkelur-maxdesa if g==`j'
sum temp2 if g==`j'
replace minmax=maxdesa if temp2>=0 & g==`j'
replace minmax=maxkelur if temp2<=0 & g==`j'

drop if kelurDum==0 & pscore> minmax & g==`j' & pscore!=.
drop if kelurDum==1 & pscore> minmax & g==`j' & pscore!=.

}
drop temp1 temp2


*** Estimating Strata keeping only sample of common support *** 
by g, sort: egen temp1=pctile(pscore), p(20)
by g, sort: egen temp2=pctile(pscore), p(40)
by g, sort: egen temp3=pctile(pscore), p(60)
by g, sort: egen temp4=pctile(pscore), p(80)

gen pscore_dum=20 if pscore<temp1 & pscore!=.
replace pscore_dum=40 if (pscore>=temp1 & pscore<temp2 & pscore!=.) 
replace pscore_dum=60 if (pscore>=temp2 & pscore<temp3 & pscore!=.) 
replace pscore_dum=80 if (pscore>=temp3 & pscore<temp4 & pscore!=.) 
replace pscore_dum=100 if (pscore>=temp4 & pscore!=.) 
drop temp*


/* Col 5. Matching Estimator */
#delimit ;
xi: reg GolkarFirst kelurDum i.prop i.pscore_dum i.prop*i.pscore_dum, vce(bootstrap);
#delimit ;
local adjR2=e(r2_a);
outreg2 kelurDum 
using "T2", excel nocons bdec(4) append addstat(Adjusted R2, `adjR2') 
ctitle(PSM, GEO+REL+FAC);
#delimit cr




*** EDITED by Ryan Steed
}
eststo clear
***

***************************************
/*   TABLE 3. HETEROGENOUS EFFECTS   */
***************************************
use LocalOfficials_AER.dta, clear
tab kab, gen(idkab_dum)

/* A. LPM    */
foreach var of varlist GolkarFirst  PDIFirst { 
#delimit ;
reg `var' kelurDum  $geography $religion $facilities idkab_d*, vce(cluster kab);
local adjR2=e(r2_a);
outreg2 kelurDum 
using "T3_OLS", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', Whole Sample);

eststo: reg `var' kelurDum  $geography $religion $facilities 
idkab_d* if PDIFirst_kab==1 & maxpercVote>=SecondMaxpercVote+0.10,
vce(cluster kab);
local adjR2=e(r2_a);
outreg2 kelurDum  
using "T3_OLS", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', PDI Won Large);

reg `var' kelurDum  $geography $religion $facilities 
idkab_d* if PDIFirst_kab==1 & maxpercVote<SecondMaxpercVote+0.10, vce(cluster kab);
local adjR2=e(r2_a);
outreg2 kelurDum kelurDum 
using "T3_OLS", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', PDI Won);

reg `var' kelurDum  $geography $religion $facilities 
idkab_d* if GolkarFirst_kab==1 & maxpercVote<SecondMaxpercVote+0.10
, vce(cluster kab);
local adjR2=e(r2_a);
outreg2 kelurDum 
using "T3_OLS", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', Golkar Won);

reg `var' kelurDum  $geography $religion $facilities 
idkab_d* if GolkarFirst_kab==1 & maxpercVote>=SecondMaxpercVote+0.10, vce(cluster kab);
local adjR2=e(r2_a);
outreg2 kelurDum  
using "T3_OLS", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', Golkar Won Large);

reg `var' kelurDum  $geography $religion $facilities 
idkab_d* if GolkarFirst_kab==0 & PDIFirst_kab==0, vce(cluster kab);
local adjR2=e(r2_a);
outreg2 kelurDum 
using "T3_OLS", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', Neither Won);
#delimit cr
}

*** EDITED by Ryan Steed
estout using "../../results/Table3Col2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
exit
***


drop if GolkarFirst==.
duplicates drop kab, force
count 
count if PDIFirst_kab==1 & maxpercVote>=SecondMaxpercVote+0.10
count if PDIFirst_kab==1 & maxpercVote<SecondMaxpercVote+0.10
count if GolkarFirst_kab==1 & maxpercVote<SecondMaxpercVote+0.10
count if GolkarFirst_kab==1 & maxpercVote>=SecondMaxpercVote+0.10
count if GolkarFirst_kab==0 & PDIFirst_kab==0



/* B. PROBIT */
use LocalOfficials_AER.dta, clear
tab kab, gen(idkab_dum)

foreach var of varlist GolkarFirst PDIFirst { 
#delimit ; 
prob `var' kelurDum  $geography $religion $facilities
idkab_d*, vce(cluster kab);
local r2_pseudo=e(r2_p);
local loglikelihood=e(ll);
outreg2 kelurDum  /*$geography $religion $facilities*/
using "T3_PROBIT", excel nocons bdec(4) append ctitle(`var', Whole Sample)
addstat(Log-likelihood, `loglikelihood', Pseudo R-sq, `r2_pseudo');
mfx, varlist(kelurDum);
outreg2 kelurDum  using "T3_PROBIT", mfx excel nocons bdec(4)  ctitle(MFX) append;

prob `var' kelurDum  $geography $religion $facilities
idkab_d* if PDIFirst_kab==1 & maxpercVote>=SecondMaxpercVote+0.10, vce(cluster kab);
local r2_pseudo=e(r2_p);
local loglikelihood=e(ll);
outreg2 kelurDum  /*$geography $religion $facilities*/
using "T3_PROBIT", excel nocons bdec(4) append ctitle(`var', PDI Won Large)
addstat(Log-likelihood, `loglikelihood', Pseudo R-sq, `r2_pseudo');
mfx, varlist(kelurDum);
outreg2 kelurDum  using "T3_PROBIT", mfx excel nocons bdec(4)  ctitle(MFX) append;

prob `var' kelurDum  $geography $religion $facilities 
idkab_d* if PDIFirst_kab==1 & maxpercVote<SecondMaxpercVote+0.10, vce(cluster kab);
local r2_pseudo=e(r2_p);
local loglikelihood=e(ll);
outreg2 kelurDum  /*$geography $religion $facilities*/
using "T3_PROBIT", excel nocons bdec(4) append ctitle(`var', PDI Won)
addstat(Log-likelihood, `loglikelihood', Pseudo R-sq, `r2_pseudo');
mfx, varlist(kelurDum);
outreg2 kelurDum using "T3_PROBIT", mfx excel nocons bdec(4)  ctitle(MFX) append;

prob `var' kelurDum  $geography $religion $facilities 
idkab_d* if GolkarFirst_kab==1 & maxpercVote<SecondMaxpercVote+0.10
, vce(cluster kab);
local r2_pseudo=e(r2_p);
local loglikelihood=e(ll);
outreg2 kelurDum  /*$geography $religion $facilities*/
using "T3_PROBIT", excel nocons bdec(4) append ctitle(`var', Golkar Won)
addstat(Log-likelihood, `loglikelihood', Pseudo R-sq, `r2_pseudo');
mfx, varlist(kelurDum);
outreg2 kelurDum using "T3_PROBIT", mfx excel nocons bdec(4)  ctitle(MFX) append;

prob `var' kelurDum  $geography $religion $facilities 
idkab_d* if GolkarFirst_kab==1 & maxpercVote>=SecondMaxpercVote+0.10, vce(cluster kab);
local r2_pseudo=e(r2_p);
local loglikelihood=e(ll);
outreg2 kelurDum  /*$geography $religion $facilities*/
using "T3_PROBIT", excel nocons bdec(4) append ctitle(`var', Golkar Won Large)
addstat(Log-likelihood, `loglikelihood', Pseudo R-sq, `r2_pseudo');
mfx, varlist(kelurDum);
outreg2 kelurDum using "T3_PROBIT", mfx excel nocons bdec(4)  ctitle(MFX) append;

prob `var' kelurDum  $geography $religion $facilities 
idkab_d* if GolkarFirst_kab==0 & PDIFirst_kab==0, vce(cluster kab);
local r2_pseudo=e(r2_p);
local loglikelihood=e(ll);
outreg2 kelurDum  /*$geography $religion $facilities*/
using "T3_PROBIT", excel nocons bdec(4) append ctitle(`var', Neither Won)
addstat(Log-likelihood, `loglikelihood', Pseudo R-sq, `r2_pseudo');
mfx, varlist(kelurDum);
outreg2 kelurDum using "T3_PROBIT", mfx excel nocons bdec(4)  ctitle(MFX) append;
#delimit cr
}





** C. Propensity Score Matching 	** 

use LocalOfficials_AER.dta, clear
tab kab, gen(idkab_dum)

egen g = group(prop) 
levelsof g, local(gr)
gen pscore=.
foreach j of local gr {
psmatch2 kelurDum $geography $religion $facilities idkab_d* if g==`j', out(GolkarFirst) 
replace pscore= _pscore if g==`j'
drop _pscore
}

drop if pscore==.

gen maxmin=.
gen minmax=.
gen temp1=.
gen temp2=.
gen mindesa=. 
gen maxdesa=. 
gen minkelur=.
gen maxkelur=. 
gen dropdesa=.
gen dropkelur=.

levelsof g, local(gr)
foreach j of local gr {
sum pscore if g==`j' & kelurDum==1
replace minkelur=r(min) if g==`j'
replace maxkelur=r(max) if g==`j'
sum pscore if g==`j' & kelurDum==0
replace mindesa=r(min) if g==`j'
replace maxdesa=r(max) if g==`j'


* Highest Minimum
replace temp1=mindesa-minkelur if g==`j' 
sum temp1 if g==`j'
replace maxmin=mindesa if temp1>=0 & g==`j'
replace maxmin=minkelur if temp1<=0 & g==`j'

count if kelurDum==0 & pscore<maxmin & g==`j' & pscore!=.
replace dropdesa= r(N) if g==`j'
count if kelurDum==1 & pscore<maxmin & g==`j' & pscore!=.

drop if kelurDum==0 & pscore<maxmin & g==`j' & pscore!=.
drop if kelurDum==1 & pscore<maxmin & g==`j' & pscore!=.

* Lowest Maximum
replace temp2=maxkelur-maxdesa if g==`j'
sum temp2 if g==`j'
replace minmax=maxdesa if temp2>=0 & g==`j'
replace minmax=maxkelur if temp2<=0 & g==`j'

count if kelurDum==0 & pscore> minmax & g==`j' & pscore!=.
count if kelurDum==1 & pscore> minmax & g==`j' & pscore!=.
replace dropkelur = r(N) if g==`j'

drop if kelurDum==0 & pscore> minmax & g==`j' & pscore!=.
drop if kelurDum==1 & pscore> minmax & g==`j' & pscore!=.
}
drop temp1 temp2


*** Estimating Strata keeping only sample of common support *** 
by g, sort: egen temp1=pctile(pscore), p(20)
by g, sort: egen temp2=pctile(pscore), p(40)
by g, sort: egen temp3=pctile(pscore), p(60)
by g, sort: egen temp4=pctile(pscore), p(80)

gen pscore_dum=20 if pscore<temp1 & pscore!=.
replace pscore_dum=40 if (pscore>=temp1 & pscore<temp2 & pscore!=.) 
replace pscore_dum=60 if (pscore>=temp2 & pscore<temp3 & pscore!=.) 
replace pscore_dum=80 if (pscore>=temp3 & pscore<temp4 & pscore!=.) 
replace pscore_dum=100 if (pscore>=temp4 & pscore!=.) 
drop temp*


foreach var of varlist GolkarFirst  PDIFirst { 
#delimit; 
xi: reg `var' kelurDum i.prop i.pscore_dum i.pscore_dum*i.prop, vce(bootstrap);
local adjR2=e(r2_a);
outreg2 kelurDum 
using "T3_MATCHING", excel nocons bdec(4) append addstat(Adjusted R2, `adjR2') ctitle(NO IDKAB `var', Whole Sample);

xi: reg `var' kelurDum i.prop i.pscore_dum i.pscore_dum*i.prop if PDIFirst_kab==1 & maxpercVote>=SecondMaxpercVote+0.10, vce(bootstrap);
local adjR2=e(r2_a);
outreg2 kelurDum 
using "T3_MATCHING", excel nocons bdec(4) append addstat(Adjusted R2, `adjR2') ctitle(`var', PDI Won Large);

xi: reg `var' kelurDum i.prop i.pscore_dum i.pscore_dum*i.prop if PDIFirst_kab==1 & maxpercVote<SecondMaxpercVote+0.10, vce(bootstrap);
local adjR2=e(r2_a);
outreg2 kelurDum 
using "T3_MATCHING", excel nocons bdec(4) append addstat(Adjusted R2, `adjR2') ctitle(`var', PDI Won);

xi: reg `var' kelurDum i.prop i.pscore_dum i.pscore_dum*i.prop if GolkarFirst_kab==1 & maxpercVote<SecondMaxpercVote+0.10, vce(bootstrap);
local adjR2=e(r2_a);
outreg2 kelurDum 
using "T3_MATCHING", excel nocons bdec(4) append addstat(Adjusted R2, `adjR2') ctitle(`var', Golkar Won);

xi: reg `var' kelurDum i.prop i.pscore_dum i.pscore_dum*i.prop if GolkarFirst_kab==1 & maxpercVote>=SecondMaxpercVote+0.10, vce(bootstrap);
local adjR2=e(r2_a);
outreg2 kelurDum 
using "T3_MATCHING", excel nocons bdec(4) append addstat(Adjusted R2, `adjR2') ctitle(`var', Golkar Won Large);

xi: reg `var' kelurDum i.prop i.pscore_dum i.pscore_dum*i.prop if GolkarFirst_kab==0 & PDIFirst_kab==0, vce(bootstrap);
local adjR2=e(r2_a);
outreg2 kelurDum 
using "T3_MATCHING", excel nocons bdec(4) append addstat(Adjusted R2, `adjR2') ctitle(`var', Neither);
#delimit cr
}






*********************************************
/* TABLE 4. TURNOVER EFFECTS */
********************************************
clear
use LocalOfficials_AER.dta
tab kab, gen(idkab_dum)
keep if kelurDum==1

#delimit;
reg turnover GolkarFirst NewBupati_Golkar  $geography $religion $facilities idkab_d*, vce(cluster kab);
local adjR2=e(r2_a);
gen whole=e(sample);
outreg2 GolkarFirst NewBupati_Golkar 
using "Turnover", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(turnover, Whole Sample);

reg turnover GolkarFirst NewBupati_Golkar   $geography $religion $facilities 
idkab_d* if PDIFirst_kab==1 & maxpercVote>=SecondMaxpercVote+0.10,
vce(cluster kab);
local adjR2=e(r2_a);
gen PDIlarge=e(sample);
outreg2 GolkarFirst NewBupati_Golkar  
using "Turnover", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(turnover, PDI Won Large);

reg turnover GolkarFirst NewBupati_Golkar   $geography $religion $facilities 
idkab_d* if PDIFirst_kab==1 & maxpercVote<SecondMaxpercVote+0.10, vce(cluster kab);
local adjR2=e(r2_a);
gen PDIjust=e(sample);
outreg2 GolkarFirst NewBupati_Golkar   
using "Turnover", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(turnover, PDI Won);

reg turnover GolkarFirst NewBupati_Golkar   $geography $religion $facilities 
idkab_d* if GolkarFirst_kab==1 & maxpercVote<SecondMaxpercVote+0.10
, vce(cluster kab);
local adjR2=e(r2_a);
gen Golkjust=e(sample);
outreg2 GolkarFirst NewBupati_Golkar 
using "Turnover", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(turnover, Golkar Won);

reg turnover GolkarFirst NewBupati_Golkar   $geography $religion $facilities 
idkab_d* if GolkarFirst_kab==1 & maxpercVote>=SecondMaxpercVote+0.10, vce(cluster kab);
local adjR2=e(r2_a);
gen Golklarge=e(sample);
outreg2 GolkarFirst NewBupati_Golkar  
using "Turnover", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(turnover, Golkar Won Large);
#delimit cr







****************************************
/* TABLE 5. Robustness Checks */
****************************************
clear
use LocalOfficials_AER.dta
tab kab, gen(idkab_dum)

#delimit ;
global conflict "conf_student_2003 conf_villagers_2003 conf_apparat_2003 conf_ethnic_2003 conf_other_2003";
global army_police "armyinvil KamlinDum PoliceDum";
global mining "perc_miningHH_1996 quarried_coralstone_1996 quarried_sand_1996 quarried_lime_1996 quarried_sulfur_1996 
quarried_kaolin_1996 quarried_kwarsa_1996";
global facilitieschange "hospchange_96_00 puskchange_96_00  maternhospchange_96_00 polyclinicchange_96_00 kindchange_96_00 primaryschchange_96_00";
global fundschange "changeCentrGov  changeProvGov changeKabGov";
global IDT "IDTinVillage_1996 perHH_receiIDT_1996"; 
#delimit cr

sum $conflict $army_police $mining $facilitieschange $fundschange $IDT 

gen dumPDILarge=(PDIFirst_kab==1 & maxpercVote>=SecondMaxpercVote+0.10)
gen dumPDIJust=(PDIFirst_kab==1 & maxpercVote<SecondMaxpercVote+0.10)
gen dumGolkJust=(GolkarFirst_kab==1 & maxpercVote<SecondMaxpercVote+0.10)
gen dumGolkLarge=(GolkarFirst_kab==1 & maxpercVote>=SecondMaxpercVote+0.10)
gen dumOther=(GolkarFirst_kab==0 & PDIFirst_kab==0)

gen dumPDILarge_kelur=dumPDILarge*kelurDum
gen dumPDIJust_kelur= dumPDIJust*kelurDum
gen dumGolkJust_kelur= dumGolkJust*kelurDum
gen dumGolkLarge_kelur= dumGolkLarge*kelurDum
gen dumOther_kelur= dumOther*kelurDum

gen dis_kab= dist_kab_kotacapital_2000

# delimit ;
foreach var of varlist urbDum_1996 
perc_ruralHH_1996 perc_ruralHH_1996_2 perc_ruralHH_1996_3 perc_ruralHH_1996_4 
ShareRurLand_1996  altitude_high_1996 lpopulation_1996* popdensity_1996 
dist_kecoffice_2000 dis_kab mosqueph_1996 prayerhouseph_1996 churchesph_1996 viharaph_1996
num_TVs_1996_pc   
num_hospitals_1996_pc num_maternhosp_1996_pc num_polyclinic_1996_pc num_puskesmas_1996_pc 
num_kindgarden_1996_pc num_primarysch_1996_pc  num_HS_1996_pc
{;
capture gen PDILarge0_`var'=dumPDILarge*`var';
capture gen PDIJust0_`var'= dumPDIJust*`var';
capture gen GolkJst0_`var'= dumGolkJust*`var';
capture gen GolkLrg0_`var'= dumGolkLarge*`var';
capture gen Other0_`var'= dumOther*`var';
};
# delimit cr

# delimit ;
foreach var of varlist 
conf_student_2003 conf_villagers_2003 conf_apparat_2003 conf_ethnic_2003 conf_other_2003
{;
capture gen PDILargeC_`var'=dumPDILarge*`var';
capture gen PDIJustC_`var'= dumPDIJust*`var';
capture gen GolkJstC_`var'= dumGolkJust*`var';
capture gen GolkLrgC_`var'= dumGolkLarge*`var';
capture gen OtherC_`var'= dumOther*`var';
};
# delimit cr

# delimit ;
foreach var of varlist 
armyinvil KamlinDum PoliceDum {;
capture gen PDILargeA_`var'=dumPDILarge*`var';
capture gen PDIJustA_`var'= dumPDIJust*`var';
capture gen GolkJstA_`var'= dumGolkJust*`var';
capture gen GolkLrgA_`var'= dumGolkLarge*`var';
capture gen OtherA_`var'= dumOther*`var';
};
# delimit cr

# delimit ;
foreach var of varlist 
perc_miningHH_1996 quarried_coralstone_1996 quarried_sand_1996 quarried_lime_1996 quarried_sulfur_1996 
quarried_kaolin_1996 quarried_kwarsa_1996 {;
capture gen PDILargeM_`var'=dumPDILarge*`var';
capture gen PDIJustM_`var'= dumPDIJust*`var';
capture gen GolkJstM_`var'= dumGolkJust*`var';
capture gen GolkLrgM_`var'= dumGolkLarge*`var';
capture gen OtherM_`var'= dumOther*`var';
};
# delimit cr

# delimit ;
foreach var of varlist 
IDTinVillage_1996 perHH_receiIDT_1996
{;
capture gen PDILargeI_`var'=dumPDILarge*`var';
capture gen PDIJustI_`var'= dumPDIJust*`var';
capture gen GolkJstI_`var'= dumGolkJust*`var';
capture gen GolkLrgI_`var'= dumGolkLarge*`var';
capture gen OtherI_`var'= dumOther*`var';
};
# delimit cr

# delimit ;
foreach var of varlist 
hospchange_96_00 puskchange_96_00  maternhospchange_96_00 polyclinicchange_96_00 kindchange_96_00 primaryschchange_96_00
{;
capture gen PDILargeZ_`var'=dumPDILarge*`var';
capture gen PDIJustZ_`var'= dumPDIJust*`var';
capture gen GolkJstZ_`var'= dumGolkJust*`var';
capture gen GolkLrgZ_`var'= dumGolkLarge*`var';
capture gen OtherZ_`var'= dumOther*`var';
};
# delimit cr

# delimit ;
foreach var of varlist 
changeCentrGov  changeProvGov changeKabGov
{;
capture gen PDILargeF_`var'=dumPDILarge*`var';
capture gen PDIJustF_`var'= dumPDIJust*`var';
capture gen GolkJstF_`var'= dumGolkJust*`var';
capture gen GolkLrgF_`var'= dumGolkLarge*`var';
capture gen OtherF_`var'= dumOther*`var';
};
# delimit cr

/* Column 1 */
#delimit ;
foreach var of varlist GolkarFirst  PDIFirst {; 
reg `var'  $geography $religion $facilities 
	dumPDILarge_kelur dumPDIJust_kelur dumGolkJust_kelur dumGolkLarge_kelur dumOther_kelur PDILarge0_* PDIJust0_* GolkLrg0_* GolkJst0_* Other0_*
	idkab_d*, vce(cluster kab);
local adjR2=e(r2_a);
outreg2 /*$geography $religion $facilities */
	dumPDILarge_kelur dumPDIJust_kelur dumGolkJust_kelur dumGolkLarge_kelur dumOther_kelur
using "T5_ROBUSTNESS_DUM", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', Baseline);

/* Column 2 */
reg `var'  $geography $religion $facilities $conflict
	dumPDILarge_kelur dumPDIJust_kelur dumGolkJust_kelur dumGolkLarge_kelur dumOther_kelur 
	PDILarge0_* PDIJust0_* GolkLrg0_* GolkJst0_* Other0_*
	PDILargeC_* PDIJustC_* GolkLrgC_* GolkJstC_* OtherC_*
	idkab_d*, vce(cluster kab);
local adjR2=e(r2_a);
outreg2  /*$geography $religion $facilities $conflict*/
	dumPDILarge_kelur dumPDIJust_kelur dumGolkJust_kelur dumGolkLarge_kelur dumOther_kelur
using "T5_ROBUSTNESS_DUM", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', Conflict);

/* Column 3 */
reg `var'  $geography $religion $facilities $army_police
	dumPDILarge_kelur dumPDIJust_kelur dumGolkJust_kelur dumGolkLarge_kelur dumOther_kelur 
	PDILarge0_* PDIJust0_* GolkLrg0_* GolkJst0_* Other0_*
	PDILargeA_* PDIJustA_* GolkLrgA_* GolkJstA_* OtherA_*
	idkab_d*, vce(cluster kab);
local adjR2=e(r2_a);
outreg2  /*$geography $religion $facilities $army_police*/
	dumPDILarge_kelur dumPDIJust_kelur dumGolkJust_kelur dumGolkLarge_kelur dumOther_kelur
using "T5_ROBUSTNESS_DUM", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', Army);

/* Column 4 */
reg `var'  $geography $religion $facilities $mining 
	dumPDILarge_kelur dumPDIJust_kelur dumGolkJust_kelur dumGolkLarge_kelur dumOther_kelur 
	PDILarge0_* PDIJust0_* GolkLrg0_* GolkJst0_* Other0_*
	PDILargeM_* PDIJustM_* GolkLrgM_* GolkJstM_* OtherM_*
	idkab_d*, vce(cluster kab);
local adjR2=e(r2_a);
outreg2  /*$geography $religion $facilities $mining */
	dumPDILarge_kelur dumPDIJust_kelur dumGolkJust_kelur dumGolkLarge_kelur dumOther_kelur
using "T5_ROBUSTNESS_DUM", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', Mining);

/* Column 5 */
reg `var'  $geography $religion $facilities $IDT $facilitieschange
	dumPDILarge_kelur dumPDIJust_kelur dumGolkJust_kelur dumGolkLarge_kelur dumOther_kelur 
	PDILarge0_* PDIJust0_* GolkLrg0_* GolkJst0_* Other0_*
	PDILargeI_* PDIJustI_* GolkLrgI_* GolkJstI_* OtherI_*
	PDILargeZ_* PDIJustZ_* GolkLrgZ_* GolkJstZ_* OtherZ_*	
	idkab_d*, vce(cluster kab);
local adjR2=e(r2_a);
outreg2  /*$geography $religion $facilities $IDT*/
	dumPDILarge_kelur dumPDIJust_kelur dumGolkJust_kelur dumGolkLarge_kelur dumOther_kelur
using "Results/2013_06_28_ResultsFinal/T5_ROBUSTNESS_DUM", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', IDT-FacilChg);

/* Column 6 */
reg `var'  $geography $religion $facilities $conflict $army_police $mining  $IDT $facilitieschange 
	dumPDILarge_kelur dumPDIJust_kelur dumGolkJust_kelur dumGolkLarge_kelur dumOther_kelur 
	PDILarge0_* PDIJust0_* GolkLrg0_* GolkJst0_* Other0_*
	PDILargeC_* PDIJustC_* GolkLrgC_* GolkJstC_* OtherC_*	
	PDILargeA_* PDIJustA_* GolkLrgA_* GolkJstA_* OtherA_*	
	PDILargeM_* PDIJustM_* GolkLrgM_* GolkJstM_* OtherM_*	
	PDILargeI_* PDIJustI_* GolkLrgI_* GolkJstI_* OtherI_*
	PDILargeZ_* PDIJustZ_* GolkLrgZ_* GolkJstZ_* OtherZ_*
	idkab_d*, vce(cluster kab);
local adjR2=e(r2_a);
outreg2  /*$geography $religion $facilities $conflict $army_police $mining  $IDT $facilitieschange */
	dumPDILarge_kelur dumPDIJust_kelur dumGolkJust_kelur dumGolkLarge_kelur dumOther_kelur
using "T5_ROBUSTNESS_DUM", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', All);

};
#delimit cr

/* Not shown due to lack of space. 
reg `var'  $geography $religion $facilities $fundschange
	dumPDILarge_kelur dumPDIJust_kelur dumGolkJust_kelur dumGolkLarge_kelur dumOther_kelur 
	PDILarge0_* PDIJust0_* GolkLrg0_* GolkJst0_* Other0_*
	PDILargeF_* PDIJustF_* GolkLrgF_* GolkJstF_* OtherF_*
	idkab_d*, vce(cluster kab);
local adjR2=e(r2_a);
outreg2  /*$geography $religion $facilities $fundschange*/
	dumPDILarge_kelur dumPDIJust_kelur dumGolkJust_kelur dumGolkLarge_kelur dumOther_kelur
using "T5_ROBUSTNESS_DUM", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', Funds Change);
};
#delimit cr
*/

* Column 8
tab kec, gen(idkec_dum)

#delimit ;
foreach var of varlist GolkarFirst  PDIFirst {; 
reg `var'  $geography $religion $facilities 
	dumPDILarge_kelur dumPDIJust_kelur dumGolkJust_kelur dumGolkLarge_kelur dumOther_kelur PDIJust0_* GolkLrg0_* GolkJst0_* Other0_*
	idkec_d*, vce(cluster kec);
local adjR2=e(r2_a);
outreg2 /* $geography $religion $facilities */
	dumPDILarge_kelur dumPDIJust_kelur dumGolkJust_kelur dumGolkLarge_kelur dumOther_kelur
using "T5_ROBUSTNESS_DUM", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', KEC FE);
};
#delimit cr



/* Column 7. SUSENAS Sample Village Employment Composition */
use LocalOfficials_AER.dta, clear
keep if mergeSusenas==3
tab kab, gen(idkab_dum)

gen dumPDILarge=(PDIFirst_kab==1 & maxpercVote>=SecondMaxpercVote+0.10)
gen dumPDIJust=(PDIFirst_kab==1 & maxpercVote<SecondMaxpercVote+0.10)
gen dumGolkJust=(GolkarFirst_kab==1 & maxpercVote<SecondMaxpercVote+0.10)
gen dumGolkLarge=(GolkarFirst_kab==1 & maxpercVote>=SecondMaxpercVote+0.10)
gen dumOther=(GolkarFirst_kab==0 & PDIFirst_kab==0)
gen dumPDILarge_kelur=dumPDILarge*kelurDum
gen dumPDIJust_kelur= dumPDIJust*kelurDum
gen dumGolkJust_kelur= dumGolkJust*kelurDum
gen dumGolkLarge_kelur= dumGolkLarge*kelurDum
gen dumOther_kelur= dumOther*kelurDum

gen dis_kab= dist_kab_kotacapital_2000
# delimit ;
foreach var of varlist urbDum_1996 
perc_ruralHH_1996 perc_ruralHH_1996_2 perc_ruralHH_1996_3 perc_ruralHH_1996_4 
ShareRurLand_1996  altitude_high_1996 lpopulation_1996* popdensity_1996 
dist_kecoffice_2000 dis_kab mosqueph_1996 prayerhouseph_1996 churchesph_1996 viharaph_1996
num_TVs_1996_pc   
num_hospitals_1996_pc num_maternhosp_1996_pc num_polyclinic_1996_pc num_puskesmas_1996_pc 
num_kindgarden_1996_pc num_primarysch_1996_pc  num_HS_1996_pc
mean_govempl  mean_privempl
{;
capture gen PDILarge0_`var'=dumPDILarge*`var';
capture gen PDIJust0_`var'= dumPDIJust*`var';
capture gen GolkJst0_`var'= dumGolkJust*`var';
capture gen GolkLrg0_`var'= dumGolkLarge*`var';
capture gen Other0_`var'= dumOther*`var';
};
# delimit cr

#delimit ;
foreach var of varlist GolkarFirst  PDIFirst {;
reg `var' $geography $religion $facilities mean_govempl  mean_privempl
	dumPDILarge_kelur dumPDIJust_kelur dumGolkJust_kelur dumGolkLarge_kelur dumOther_kelur PDIJust0_* GolkLrg0_* GolkJst0_* Other0_*
	idkab_d*, vce(cluster kab);
local adjR2=e(r2_a);
outreg2 /*$geography $religion $facilities mean_govempl  mean_privempl*/
	dumPDILarge_kelur dumPDIJust_kelur dumGolkJust_kelur dumGolkLarge_kelur dumOther_kelur
using "T5_ROBUSTNESS_DUM", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', SUSENAS);
};
#delimit cr





*********************************************
/* TABLE 6. ALIGNMENT ROBUSTNESS CHECK */
********************************************

clear
use LocalOfficials_AER.dta
tab kab, gen(idkab_dum)

#delimit ;
global alignment_00_03 "changeCentrGov  changeProvGov changeKabGov hospchange_00_03perc puskchange_00_03perc 
maternhospchange_00_03perc primaryschchange_00_03perc";

foreach var of varlist $alignment_00_03{ ;
reg `var' aligned $geography $religion $facilities idkab_d*, vce(cluster kab);
local adjR2=e(r2_a);
outreg2 aligned using "T6_ROBUST_ALIGN", excel addstat(Adjusted R2, `adjR2') 
nocons bdec(4) append ctitle(`var');

reg `var' aligned kelurDum align_kelur $geography $religion $facilities idkab_d*, vce(cluster kab);
local adjR2=e(r2_a);
outreg2 aligned kelurDum align_kelur using "T6_ROBUST_ALIGN", excel 
addstat(Adjusted R2, `adjR2') nocons bdec(4) append ctitle(`var');
#delimit cr
}



** FIGURE 1
/* Figure 1 is computed out of the point estimates obtained in Appendix Table 12: The values of the solid line are obtained
 by adding the point estimates of the coefficient on "Golkar wins" and the coefficient on "Golkar wins * New Mayor" obtained in Panel A. 
 The values of the dashed line are obtained similarly when using the coefficients of Panel B. 
 The following code reproduces Appendix Table 12*/
 


** AT12. TURNOVER ROBUSTNESS CHECKS - DIFFERENT MARGINS OF VICTORY 
clear
use LocalOfficials_AER.dta
tab kab, gen(idkab_dum)

keep if kelurDum==1


* PANEL A 
foreach var of varlist turnover{ 
#delimit;
reg `var' GolkarFirst NewBupati_Golkar  $geography $religion $facilities idkab_d*, vce(cluster kab);
local adjR2=e(r2_a);
outreg2 GolkarFirst NewBupati_Golkar 
using "AT12_Turnover_ROB", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', diff%VICT Whole Sample);

reg `var' GolkarFirst NewBupati_Golkar   $geography $religion $facilities 
idkab_d* if PDIFirst_kab==1 & maxpercVote>=SecondMaxpercVote+0.2,
vce(cluster kab);
local adjR2=e(r2_a);
outreg2 GolkarFirst NewBupati_Golkar  
using "AT12_Turnover_ROB", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', +20% PDI Won);

reg `var' GolkarFirst NewBupati_Golkar   $geography $religion $facilities 
idkab_d* if PDIFirst_kab==1 & maxpercVote>=SecondMaxpercVote+0.1 & maxpercVote<SecondMaxpercVote+0.2,
vce(cluster kab);
local adjR2=e(r2_a);
outreg2 GolkarFirst NewBupati_Golkar  
using "AT12_Turnover_ROB", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', 10%-20% PDI Won);

reg `var' GolkarFirst NewBupati_Golkar   $geography $religion $facilities 
idkab_d* if PDIFirst_kab==1 & maxpercVote>=SecondMaxpercVote+0.05 & maxpercVote<SecondMaxpercVote+0.1,
vce(cluster kab);
local adjR2=e(r2_a);
outreg2 GolkarFirst NewBupati_Golkar  
using "AT12_Turnover_ROB", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', 5%-10% PDI Won);

reg `var' GolkarFirst NewBupati_Golkar   $geography $religion $facilities 
idkab_d* if PDIFirst_kab==1 & maxpercVote<SecondMaxpercVote+0.05,
vce(cluster kab);
local adjR2=e(r2_a);
outreg2 GolkarFirst NewBupati_Golkar  
using "AT12_Turnover_ROB", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', <5% PDI Won);

reg `var' GolkarFirst NewBupati_Golkar   $geography $religion $facilities 
idkab_d* if GolkarFirst_kab ==1 & maxpercVote<SecondMaxpercVote+0.05,
vce(cluster kab);
local adjR2=e(r2_a);
outreg2 GolkarFirst NewBupati_Golkar  
using "AT12_Turnover_ROB", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var',<5& Golk Won);


reg `var' GolkarFirst NewBupati_Golkar   $geography $religion $facilities 
idkab_d* if GolkarFirst_kab ==1 & maxpercVote>=SecondMaxpercVote+0.05 & maxpercVote<SecondMaxpercVote+0.1,
vce(cluster kab);
local adjR2=e(r2_a);
outreg2 GolkarFirst NewBupati_Golkar  
using "AT12_Turnover_ROB", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', 5%-10% Golk Won);

reg `var' GolkarFirst NewBupati_Golkar   $geography $religion $facilities 
idkab_d* if GolkarFirst_kab ==1 & maxpercVote>=SecondMaxpercVote+0.1 & maxpercVote<SecondMaxpercVote+0.2,
vce(cluster kab);
local adjR2=e(r2_a);
outreg2 GolkarFirst NewBupati_Golkar  
using "AT12_Turnover_ROB", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', 10%-20% Golk Won);

reg `var' GolkarFirst NewBupati_Golkar   $geography $religion $facilities 
idkab_d* if GolkarFirst_kab ==1 & maxpercVote>=SecondMaxpercVote+0.2,
vce(cluster kab);
local adjR2=e(r2_a);
outreg2 GolkarFirst NewBupati_Golkar  
using "AT12_Turnover_ROB", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(`var', +20% Golk Won);
};
#delimit cr

* PANEL B. Different margins of victory PLACEBO TEST 
capture drop whole PDIlarge PDIjust Golkjust Golklarge neither

#delimit;
reg turnover_vh1996 GolkarFirst NewBupati_Golkar  $geography $religion $facilities idkab_d*, vce(cluster kab);
local adjR2=e(r2_a);
outreg2 GolkarFirst NewBupati_Golkar 
using "AT12_Turnover_ROB", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(turnover_vh1996, diff%VICT Whole Sample);

reg turnover_vh1996 GolkarFirst NewBupati_Golkar   $geography $religion $facilities 
idkab_d* if PDIFirst_kab==1 & maxpercVote>=SecondMaxpercVote+0.2,
vce(cluster kab);
local adjR2=e(r2_a);
outreg2 GolkarFirst NewBupati_Golkar  
using "AT12_Turnover_ROB", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(turnover_vh1996, +20% PDI Won);

reg turnover_vh1996 GolkarFirst NewBupati_Golkar   $geography $religion $facilities 
idkab_d* if PDIFirst_kab==1 & maxpercVote>=SecondMaxpercVote+0.1 & maxpercVote<SecondMaxpercVote+0.2,
vce(cluster kab);
local adjR2=e(r2_a);
outreg2 GolkarFirst NewBupati_Golkar  
using "AT12_Turnover_ROB", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(turnover_vh1996, 10%-20% PDI Won);

reg turnover_vh1996 GolkarFirst NewBupati_Golkar   $geography $religion $facilities 
idkab_d* if PDIFirst_kab==1 & maxpercVote>=SecondMaxpercVote+0.05 & maxpercVote<SecondMaxpercVote+0.1,
vce(cluster kab);
local adjR2=e(r2_a);
outreg2 GolkarFirst NewBupati_Golkar  
using "AT12_Turnover_ROB", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(turnover_vh1996, 5%-10% PDI Won);

reg turnover_vh1996 GolkarFirst NewBupati_Golkar   $geography $religion $facilities 
idkab_d* if PDIFirst_kab==1 & maxpercVote<SecondMaxpercVote+0.05,
vce(cluster kab);
local adjR2=e(r2_a);
outreg2 GolkarFirst NewBupati_Golkar  
using "AT12_Turnover_ROB", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(turnover_vh1996, <5% PDI Won);

reg turnover_vh1996 GolkarFirst NewBupati_Golkar   $geography $religion $facilities 
idkab_d* if GolkarFirst_kab ==1 & maxpercVote<SecondMaxpercVote+0.05,
vce(cluster kab);
local adjR2=e(r2_a);
outreg2 GolkarFirst NewBupati_Golkar  
using "AT12_Turnover_ROB", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(turnover_vh1996,<5& Golk Won);


reg turnover_vh1996 GolkarFirst NewBupati_Golkar   $geography $religion $facilities 
idkab_d* if GolkarFirst_kab ==1 & maxpercVote>=SecondMaxpercVote+0.05 & maxpercVote<SecondMaxpercVote+0.1,
vce(cluster kab);
local adjR2=e(r2_a);
outreg2 GolkarFirst NewBupati_Golkar  
using "AT12_Turnover_ROB", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(turnover_vh1996, 5%-10% Golk Won);

reg turnover_vh1996 GolkarFirst NewBupati_Golkar   $geography $religion $facilities 
idkab_d* if GolkarFirst_kab ==1 & maxpercVote>=SecondMaxpercVote+0.1 & maxpercVote<SecondMaxpercVote+0.2,
vce(cluster kab);
local adjR2=e(r2_a);
outreg2 GolkarFirst NewBupati_Golkar  
using "AT12_Turnover_ROB", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(turnover_vh1996, 10%-20% Golk Won);

reg turnover_vh1996 GolkarFirst NewBupati_Golkar   $geography $religion $facilities 
idkab_d* if GolkarFirst_kab ==1 & maxpercVote>=SecondMaxpercVote+0.2,
vce(cluster kab);
local adjR2=e(r2_a);
outreg2 GolkarFirst NewBupati_Golkar  
using "AT12_Turnover_ROB", addstat(Adjusted R2, `adjR2') excel nocons bdec(4) append ctitle(turnover_vh1996, +20% Golk Won);

#delimit cr





** FIGURE 2
clear
use LocalOfficials_AER.dta
drop if mergeElect_all!=3

/* Measure of how rural the district is */
sort kab
by kab: egen num_HH_KAB = total(num_HH_1996)
by kab: egen num_HH_rural_KAB = total(num_HH_rural_1996)
gen ShareRurHH_KAB=num_HH_rural_KAB/num_HH_KAB

/* Propensity Score Matching */
pscore kelurDum  $geography $religion $facilities,  pscore(pscore_fac)

by kab, sort: egen temp_av_pscore_fac=mean(pscore_fac) if kelurDum==1
by kab: egen av_pscore_fac=max(temp_av_pscore_fac)
drop temp*

duplicates drop kab, force

reg gol_1971_perc ShareRurHH_KAB
predict GolkResid71, resid

reg av_pscore_fac GolkResid71
predict yhat

#delimit ;
scatter av_pscore_fac GolkResid71
	|| line yhat GolkResid71, lpattern(solid) sort lwidth(medthick)
, legend(off) xtitle("Support for Golkar in 1971", size(medlarge)) 
ytitle("Average Propensity Score of Kelurahan", size(medlarge));
#delimit cr

graph export "EndogeneityCheck_Golk1971.eps", replace





	
	
	
	
	
	
	
	
	
	
	
		
