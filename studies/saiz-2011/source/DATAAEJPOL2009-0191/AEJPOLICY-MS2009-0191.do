version 9
clear
capture set more off
capture log close
/* memory allocation will depend on constraints*/
set mem 9000m
set matsize 11000

use "DATAAEJPOLICY_MS_2009_191.dta", clear

log using "AEJ SAIZ-WACHTER.log", replace

/* THIS PROGRAM PERFORMS THE REGRESSIONS IN SAIZ-WACHTER : IMMIGRATION AND THE NEIGHBORHOOD */

/* ====================================================================================================================================== */
/* ======= KEEP ONLY IMMIGRANT METRO AREAS- DROP 1970 (NO PRICE CHANGES AVAILABLE ) and 1980 (SMALL SAMPLE, LACK OF PREVIOUS TRENDS ===== */
/* ====================================================================================================================================== */
drop if year==1970 | year==1980
keep if  immicapmsa~=.

/* CITIES WHERE IMMIGRATION MATTERS: MORE THAN 5% DURING THE DECADE */
keep if immicapmsa>0.05 & immicapmsa~=. 

/* ===================================== GENERATE MSA-YEAR DUMMIES ==================================================== */
tab msayear, gen(m)

/* ==================================================================================================================== */
/* ======================================== AVERAGE HOUSING VALUES: BASELINE REGRESION================================= */
/* ==================================================================================================================== */

/* TABLE 1: COLUMN 1 */
xi: areg   dloval dforeigncap if  l1shanhwhite~=. [aw=l1own], cluster(tract) absorb(msayear)
/* TABLE 1: COLUMN 2 ++++++ BASELINE REGRESSION ===== */
xi: areg   dloval dforeigncap  cha* Ql1* l1sharebach l1loinc l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden [aw=l1own], cluster(tract) absorb(msayear)
/* TABLE 1: COLUMN 2; Add Previous Income Trends */
xi: areg   dloval dforeigncap cha* Ql1* l1sharebach l1loinc l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden  shawa shacim l1loval l1dloval l1dloinc  [aw=l1own], cluster(tract) absorb(msayear)
/* ##################################################################################################################### */
/* ++++++++++++++++++++++++++++++++++++++++++++ INSTRUMENTAL VARIABLES +++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ##################################################################################################################### */

/* TABLE 1: COLUMN 4 */
xi: ivreg   dloval (dforeigncap=pull)  cha* Ql1* l1sharebach   l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid l1shaown l1vacrat l1loden  m1-m122 [aw=l1own], cluster(tract) 

/* TABLE 1: COLUMN 5 */
xi: ivreg2   dloval (dforeigncap=pull pulli pullmsa) cha* Ql1* l1sharebach   l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid l1shaown l1vacrat l1loden  l1foreigncap  m1-m122 [aw=l1own], cluster(tract) first

/* TABLE 1: COLUMN 6 */
*** EDITED BY Ryan
eststo: xi: ivreg2   dloval (dforeigncap=pulli pullmsa)  cha* Ql1* l1sharebach   l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid l1shaown l1vacrat l1loden l1foreigncap pull m1-m122 [aw=l1own], cluster(tract) first
estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
eststo clear
***

/* ================================== HAUSMAN TEST (reported in text)==================================== */
xi: ivreg2   dloval (dforeigncap=pulli pullmsa)  cha* Ql1* l1sharebach   l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid l1shaown l1vacrat l1loden l1foreigncap pull m1-m122 [aw=l1own], 
est store IVMOD
/* ==================================================================================== */
xi: reg   dloval dforeigncap cha* Ql1* l1sharebach   l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid l1shaown l1vacrat l1loden l1foreigncap pull m1-m121 [aw=l1own],  
hausman IVMOD

/* ====================================================================================================================== */
/* =================================== INTERACTIONS WITH INITIAL VARIABLES OF INTEREST ================================== */
/* ====================================================================================================================== */

/* QUARTILES OF T-10 LAGGED HOUSING VALUES */
egen lapricut1=pctile(l1loval), by(msayear) p(25)
egen lapricut2=pctile(l1loval), by(msayear) p(50)
egen lapricut3=pctile(l1loval), by(msayear) p(75)
gen lapriqu=0 if l1loval~=.
replace lapriqu=1 if l1loval>lapricut1 & l1loval~=.
replace lapriqu=2 if l1loval>lapricut2 & l1loval~=.
replace lapriqu=3 if l1loval>lapricut3 & l1loval~=.
drop lapricut*

gen imvalqu=dforeigncap*lapriqu
label var lapriqu "Lagged Price Quartiles"
label var imvalqu "Change in Foreign Population/Population * House Value Quartile at T-10

/* TABLE 2: COLUMN 1 */
xi: areg   dloval dforeigncap imnhwhite cha* Ql1* l1sharebach l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden  [aw=l1own], cluster(tract) absorb(msayear)

/* TABLE 2: COLUMN 2 */
xi: areg   dloval dforeigncap imvalqu l1loval cha* Ql1* l1sharebach l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden  [aw=l1own], cluster(tract) absorb(msayear)

/* TABLE 2: COLUMN 3 */
xi: areg   dloval dforeigncap imnhwhite imvalqu l1loval cha* Ql1* l1sharebach l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden  [aw=l1own], cluster(tract) absorb(msayear)

/* ==================================================================================================================================== */
/* =============================================== IS THERE NATIVE FLIGHT ============================================================== */
/* ==================================================================================================================================== */

/* TABLE 3: COLUMN 1 */
xi: areg  natgro immicap  cha* Ql1* l1sharebach l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden [aw=l1pop], cluster(tract) absorb(msayear)

/* TABLE 3: COLUMN 2 */
xi: areg  natgro immicap  cha* Ql1* l1sharebach l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden if dlopo<1 [aw=l1pop], cluster(tract) absorb(msayear)

/* TABLE 3: COLUMN 3 */
xi: qreg  natgro immicap  cha* Ql1* l1sharebach l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden m1-m122  [aw=l1pop],  

/* TABLE 3: COLUMN 4 */
xi: ivreg   natgro (immicap=pulli pullmsa) pull cha* Ql1* l1sharebach   l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid l1shaown l1vacrat l1loden  l1foreigncap m1-m122 [aw=l1pop], cluster(tract) 

/* TABLE 3: COLUMN 5 */
xi: areg  nhwhitegro immicap  cha* Ql1* l1sharebach l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden [aw=l1pop], cluster(tract) absorb(msayear)

/* TABLE 3: COLUMN 6 */
xi: areg  nhwhitegro immicap  cha* Ql1* l1sharebach l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden if dlopo<1 [aw=l1pop], cluster(tract) absorb(msayear)

/* TABLE 3: COLUMN 7 */
xi: qreg  nhwhitegro immicap  cha* Ql1* l1sharebach l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden m1-m122  [aw=l1pop],  

/* TABLE 3: COLUMN 8 */
*** EDITED BY Ryan
eststo: xi: ivreg   nhwhitegro  (immicap=pulli pullmsa) pull cha* Ql1* l1sharebach   l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid l1shaown l1vacrat l1loden  l1foreigncap m1-m122 [aw=l1pop], cluster(tract) 
estout using "../../results/table3.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
eststo clear
***

*** EDITED BY Ryan
exit
***

/* ================================================================================================*/
/* ============================== BY ORIGIN COUNTRY 2000's ========================================*/
/* ================================================================================================*/

/* CHANGES IN THE SHARE BY ORIGIN-COUNTRY WERE ESTIMATED USING 1990 AND 2000 CENSUS TRACTS AND PUBLISHED GEOGRAPHIC CROSS-WALKS FROM MABLE GEOCORR, WE USE POPULATION
WEIGHTS TO DO THE ALLOCATION (NOTE THAT THIS GENERATES MEASUREMENT ERROR WITH RESPECT TO ETHNIC GROUPS THAT DO NOT LOCATE SIMILARLY 
TO THE OTHER POPULATIONS IN THE TRACT */
/* VARIABLES WITH SUFFIX _PROC ARE ESTIMATES FROM THIS GEOGRAPHIC IMPUTATION PROCEDURE; THUS, FOR INSTANCE, DSHACUBA_PROC IS THE ESTIMATED INTERCENSUS (1990-2000) 
CHANGE IN THE SHARE OF CUBANS IN A 2000-DEFINED CENSUS TRACT */
/* WE THEN MULTIPLY BY THE SHARE OF RECENT IMMIGRANT ARRIVALS WHO DROPPED OUT OF SCHOOL BY ETHNIC GROUP AND STATE IN ORDER TO GENERATE THE IMMIGRANT-DRIVEN "SHOCK" 
TO EDUCATION; SIMILARLY FOR RACIAL/LINGUISTIC GROUPS */

#delimit;
gen dropshock=dshacuba_proc*dropoutcuba+dshadominican_proc*dropoutdominican+dshaeuropeans_proc*dropouteurope+dshachin_proc*dropoutchina+dshaphilippines_proc*dropoutphilippines 
+dshacanada_proc*dropoutcanada+dshamexico_proc*dropoutmexico+dshascasia_proc*dropoutscasia+dshaeastasia_proc*dropouteastasia 
+dshamideast_proc*dropoutmideast+dshaafrica_proc*dropoutafrica+dshacaribbean_proc*dropoutcaribbean 
+dshacentralam_proc*dropoutcentralam +dshasoutham_proc*dropoutsouthamer+dshaoceania_proc*dropoutoceania+dshaother_proc*dropoutother; 

#delimit;
gen nhwhiteshock=dshacuba_proc*nhwhitecuba+dshadominican_proc*nhwhitedominican+dshaeuropeans_proc*nhwhiteeurope+dshachin_proc*nhwhitechina+dshaphilippines_proc*nhwhitephilippines 
+dshacanada_proc*nhwhitecanada+dshamexico_proc*nhwhitemexico+dshascasia_proc*nhwhitescasia+dshaeastasia_proc*nhwhiteeastasia 
+dshamideast_proc*nhwhitemideast+dshaafrica_proc*nhwhiteafrica+dshacaribbean_proc*nhwhitecaribbean 
+dshacentralam_proc*nhwhitecentralam +dshasoutham_proc*nhwhitesouthamer+dshaoceania_proc*nhwhiteoceania+dshaother_proc*nhwhiteother; 

#delimit;
gen nhblackshock=dshacuba_proc*nhblackcuba+dshadominican_proc*nhblackdominican+dshaeuropeans_proc*nhblackeurope+dshachin_proc*nhblackchina+dshaphilippines_proc*nhblackphilippines 
+dshacanada_proc*nhblackcanada+dshamexico_proc*nhblackmexico+dshascasia_proc*nhblackscasia+dshaeastasia_proc*nhblackeastasia 
+dshamideast_proc*nhblackmideast+dshaafrica_proc*nhblackafrica+dshacaribbean_proc*nhblackcaribbean 
+dshacentralam_proc*nhblackcentralam +dshasoutham_proc*nhblacksouthamer+dshaoceania_proc*nhblackoceania+dshaother_proc*nhblackother; 

#delimit;
gen nhasianshock=dshacuba_proc*nhasiancuba+dshadominican_proc*nhasiandominican+dshaeuropeans_proc*nhasianeurope+dshachin_proc*nhasianchina+dshaphilippines_proc*nhasianphilippines 
+dshacanada_proc*nhasiancanada+dshamexico_proc*nhasianmexico+dshascasia_proc*nhasianscasia+dshaeastasia_proc*nhasianeastasia 
+dshamideast_proc*nhasianmideast+dshaafrica_proc*nhasianafrica+dshacaribbean_proc*nhasiancaribbean 
+dshacentralam_proc*nhasiancentralam +dshasoutham_proc*nhasiansouthamer+dshaoceania_proc*nhasianoceania+dshaother_proc*nhasianother; 

#delimit;
gen hispanicshock=dshacuba_proc*hispaniccuba+dshadominican_proc*hispanicdominican+dshaeuropeans_proc*hispaniceurope+dshachin_proc*hispanicchina+dshaphilippines_proc*hispanicphilippines 
+dshacanada_proc*hispaniccanada+dshamexico_proc*hispanicmexico+dshascasia_proc*hispanicscasia+dshaeastasia_proc*hispaniceastasia 
+dshamideast_proc*hispanicmideast+dshaafrica_proc*hispanicafrica+dshacaribbean_proc*hispaniccaribbean 
+dshacentralam_proc*hispaniccentralam +dshasoutham_proc*hispanicsouthamer+dshaoceania_proc*hispanicoceania+dshaother_proc*hispanicother; 

/* THE 1990-2000 TRACT CROSSWALK DOES NOT PERFECTLY ASSIGN EVERYONE TO THE RIGHT TRACT (E.G. MOST CUBANS MAY LIVE ON ONE SIDE OF A 2000-CENSUS DEFINED TRACT BOUNDARY
BUT WE ALLOCATE THEM - PROPORTIONALLY AS WITH THE REST OF POPULATION - ON BOTH SIDES */
/* generate an accuracy ratio for 1990 foreignborn data: both using our imputation and the "right" number */
gen ratforest=l1total_proc/l1foreign;

#delimit cr
/**********************************************************************/
/* REGRESSIONS IN TABLE 4 EXCLUDE TRACTS WERE THE FOREIGN-BOR ALLOCATION USING 1990-2000 CROSS WALK SEEMS TO BE OFF BY MORE THAN 10% W.R.T. 1990 FOREIGN-BORN COUNTS
RESULSTA ARE SIMILAR, HOWEVER, IN THE UNRESTRICTED SAMPLE!*/

/* TABLE 4: COLUMN 1 */
xi: areg   dloval  dshacuba_proc dshaeuropeans_proc dshadominican_proc dshachin_proc dshaphilippines_proc dshamexico_proc dshascasia_proc dshaeastasia_proc dshamideast_proc dshaafrica_proc dshacaribbean_proc dshacentralam_proc dshasoutham_proc cha* Ql1* l1sharebach   l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden if ratforest<1.1 & ratforest>0.9 [aw=l1own], cluster(tract) absorb(msayear)

/* INCLUDE SCHOOL DISTRICT CODE FIXED-EFFECTS */

/* TABLE 4: COLUMN 2 */
xi: areg   dloval  dforeigncap cha* Ql1* l1sharebach   l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden if ratforest<1.1 & ratforest>0.9 [aw=l1own], cluster(tract) absorb(sdcodeyear)

/* TABLE 4: COLUMN 3 */
xi: areg   dloval  dropshock   nhwhiteshock nhblackshock nhasianshock hispanicshock cha* Ql1* l1sharebach   l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden if ratforest<1.1 & ratforest>0.9 [aw=l1own], cluster(tract) absorb(sdcodeyear)

capture log close
