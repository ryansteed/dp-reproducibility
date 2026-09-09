clear
capture set more off
capture log close
/* memory allocation will depend on constraints*/
set mem 9000m
set matsize 11000

use "DATAAEJPOLICY_MS_2009_191.dta", 

log using "ONLINE APPENDIX AEJ SAIZ-WACHTER.log", replace


/* ++++++ BASELINE REGRESSION: ALL US MSA===== */
/* ONLINE SUPPLEMENTAL SECTION: APPENDIX TABLE 2, COLUMN 1 */
xi: areg   dloval dforeigncap  cha* Ql1* l1sharebach   l1loinc l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden [aw=l1own], cluster(tract) absorb(msayear)


/* CITIES WHERE IMMIGRATION MATTERS: MORE THAN 5% DURING THE DECADE */
keep if immicapmsa>0.05 & immicapmsa~=. 

/* ===================================== GENERATE MSA-YEAR DUMMIES ==================================================== */
tab msayear, gen(m)

/* =============================================================================================================================== */
/* ============ ALTERNATIVE APPENDIX REGRESSIONS: NON-IMMIGRANT AREAS,  MEDIAN HOUSING VALUES ========== */
/* =============================================================================================================================== */


/* Define low immigrant as lower 50% */
summ l1foreigncap if immicapmsa>0.05, d
egen cutoff=pctile(l1foreigncap), p(50) by(msayear)

label var cutoff "Lowest 50 percentile immigrant density"

/* ONLINE SUPPLEMENTAL SECTION: APPENDIX TABLE 2, COLUMN 2 */
/* Average Values MSA YEAR FIXED EFFECTS, ONLY FOR AREAS THAT DID NOT USE TO BE IMMIGRANT INTENSIVE (BELOW  50%) */
xi: areg   dloval dforeigncap  cha* Ql1* l1sharebach   l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden  if   l1foreigncap<cutoff [aw=l1own], cluster(tract) absorb(msayear)

/* ONLINE SUPPLEMENTAL SECTION: APPENDIX TABLE 2, COLUMN 3 */
/* controls for land use */
xi: areg   dloval dforeigncap  cha* Ql1* l1sharebach   l1loinc l1shanhwhite l1shaless25 l1shamore65 l1shafakid   l1shaown l1vacrat l1loden shawa shacim [aw=l1own], cluster(tract) absorb(msayear)

/* ONLINE SUPPLEMENTAL SECTION: APPENDIX TABLE 2, COLUMN 4 */
/* Median Values: Only for 1990s */
xi: areg   dlomval dforeigncap  cha* Ql1* l1sharebach   l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden  [aw=l1own], cluster(tract) absorb(msayear)

/* ONLINE SUPPLEMENTAL SECTION: APPENDIX TABLE 2, COLUMN 6 */
/* Include Past Immigrant Density */
xi: areg   dloval dforeigncap l1foreigncap cha* Ql1* l1sharebach   l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden  [aw=l1own], cluster(tract) absorb(msayear)

/*======================================================================================================================*/
/* ONLINE SUPPLEMENTAL SECTION: APPENDIX TABLE 2, COLUMN 5 */
/* ======================= REGRESSIONS BY DISTANCE-DENSITY TYPE ==================================== */

/* step 1 normalize distance to CBD by metro area and year*/
egen sddist=sd(lodistcbd), by(msayear)
egen meandist=mean(lodistcbd), by(msayear)
gen stadist=(lodistcbd-meandist)/sddist

/* step 2 normalize density by metro area and year*/
egen sdden=sd(l1loden), by(msayear)
egen meanden=mean(l1loden), by(msayear)
gen staden=(l1loden-sdden)/meanden

/* step 3: create quartile by normalizd density and distance from center */
xtile quadis=stadist, nq(4)
xtile quaden=staden, nq(4)
gen dendist=quaden*10+quadis

/* step 4: drop ancillary vars and label new usable data */
drop sddist meandist stadist sdden meanden staden
label var quadis "Distance to CBD Quartiles"
label var quaden "Density at T-10 quartiles"
label var dendist "Density-Distance to CBD Groups"

/* step 5: Regressions by Density-Distance Quartiles */

gen av_dendist=0
gen stdav_dendist=0
gen NTOT=0
forvalues k=11(1)44 {
capture xi: areg   dloval dforeigncap  cha* Ql1* l1sharebach   l1loinc l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden if dendist==`k' [aw=l1own], cluster(tract) absorb(msayear)
capture gen b`k'=_b[dforeigncap]
quietly replace b`k'=0 if dendist~=`k'
capture gen s`k'=_se[dforeigncap]
quietly replace s`k'=0 if dendist~=`k'
capture gen N`k'=e(N)
quietly replace N`k'=0 if dendist~=`k'
quietly replace av_dendist=av_dendist+ b`k'*N`k'
quietly replace stdav_dendist=stdav_dendist+s`k'
quietly replace NTOT=NTOT+N`k'
}
replace av_dendist=av_dendist/NTOT
replace stdav_dendist=(((stdav_dendist^2)/16))^(1/2)

/* step 6: show average treatmenmt effects across cells, and associated s.d. */
summ av_dendist stdav_dendist if av_dendist~=.
/*======================================================================================================================*/

/* INSTRUMENTAL VARIABLES First Stages */
/* ONLINE SUPPLEMENTAL SECTION: APPENDIX TABLE 3, COLUMN 1 */ 
areg   dforeigncap pull  cha* Ql1* l1sharebach   l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid l1shaown l1vacrat l1loden  [aw=l1own], absorb(msayear) cluster(tract) 
test pull

/* ONLINE SUPPLEMENTAL SECTION: APPENDIX TABLE 3, COLUMN 2 */ 
xi: areg dforeigncap pulli pullmsa cha* Ql1* l1sharebach   l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid l1shaown l1vacrat l1loden l1foreigncap pull  [aw=l1own],  absorb(msayear) cluster(tract)
test pulli pullmsa

/* ONLINE SUPPLEMENTAL SECTION: APPENDIX TABLE 4, COLUMN 1 */
/* Nonlinearities in proximity to immigrant tracts */
gen pull2=pull^2
gen pull3=pull^3
xi: ivreg2   dloval (dforeigncap= pulli pullmsa) pull pull2 pull3 cha* Ql1* l1sharebach   l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid l1shaown l1vacrat l1loden  l1foreigncap  m1-m122 [aw=l1own], cluster(tract) first

/* ONLINE SUPPLEMENTAL SECTION: APPENDIX TABLE 4, COLUMN 2 */
/* CONTROL FOR PROPOTIONAL CONCURENT CHANGES IN IMMIGRANT DENSITY IN NEIGHBORING TRACTS (CHANGE OF LOG PULL AT T+10*/
xi: ivreg   dloval (dforeigncap=pulli pullmsa) cha* Ql1* l1sharebach   l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid l1shaown l1vacrat l1loden  l1foreigncap pull dlopull_forward m1-m122 [aw=l1own], cluster(tract) 

/* ONLINE SUPPLEMENTAL SECTION: APPENDIX TABLE 4, COLUMN 3 */
/* Include lagged neighboring price changes*/
xi: ivreg2   dloval (dforeigncap=pulli pullmsa)  cha* Ql1* l1sharebach   l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid l1shaown l1vacrat l1loden l1foreigncap pull pullpevol m1-m122 [aw=l1own], cluster(tract) first

/* ONLINE SUPPLEMENTAL SECTION: APPENDIX TABLE 4, COLUMN 4 */
xi: ivreg2   dloval (dforeigncap=pullmsa pullimsa)  cha* Ql1* l1sharebach   l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid l1shaown l1vacrat l1loden l1foreigncap pull pulli m1-m122 [aw=l1own], cluster(tract) first

/* =============================================================================================================================*/
/*==============================================================================================================================*/
/*=========================== IMPACT ON RENTS: NEGATIVE AND MORE SO IN WHITE NEIGHBORHOODS ==========================================*/
/* =============================================================================================================================*/
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

/* Condition on no rent controls, free markets */
/* ONLINE SUPPLEMENTAL SECTION: APPENDIX TABLE 5, COLUMN 1 */
xi: areg   dlorent dforeigncap if rc==0  [aw=l1rent], cluster(tract) absorb(msayear)
/* ONLINE SUPPLEMENTAL SECTION: APPENDIX TABLE 5, COLUMN 2 */
xi: areg   dlorent dforeigncap cha* Ql1* l1sharebach l1loinc l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden if rc==0  [aw=l1rent], cluster(tract) absorb(msayear)
/* ONLINE SUPPLEMENTAL SECTION: APPENDIX TABLE 5, COLUMN 3 */
xi: areg   dlorent dforeigncap imnhwhite cha* Ql1* l1sharebach l1loinc  l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden if rc==0 [aw=l1rent], cluster(tract) absorb(msayear)
/* ONLINE SUPPLEMENTAL SECTION: APPENDIX TABLE 5, COLUMN 4 */
xi: areg   dlorent dforeigncap imvalqu cha* Ql1* l1sharebach l1loval l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden if rc==0 [aw=l1rent], cluster(tract) absorb(msayear)
/* ONLINE SUPPLEMENTAL SECTION: APPENDIX TABLE 5, COLUMN 5 */
xi: areg   dlorent dforeigncap imnhwhite imvalqu cha* Ql1* l1sharebach l1loval l1shanhwhite l1shaless25 l1shamore65 l1shafakid  l1shaown l1vacrat l1loden if rc==0 [aw=l1rent], cluster(tract) absorb(msayear)

capture log close

