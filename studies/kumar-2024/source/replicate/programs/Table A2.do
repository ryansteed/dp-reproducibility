/***IMPORTANT NOTE: MUST DOWNLOAD THE FOLLOWING TWO FILES USING THE DONWLOAD LINKS BELOW AND PLACE THEM IN "replicate\data" BEFORE EXECUTING THIS FILE TO REPLICATE APPENDIX TABLE A2 
(1) https://www.openicpsr.org/openicpsr/project/195021/version/V1/view?path=/openicpsr/195021/fcr:versions/V1/psid_variables_from_cnef.dta&type=file
(2) https://www.openicpsr.org/openicpsr/project/195021/version/V1/view?path=/openicpsr/195021/fcr:versions/V1/psid_ownhome.dta&type=file
*/
use "data\psid_variables_from_cnef.dta", clear
gen statepsid=l11101 
sort statepsid year
count
count if statepsid>0 & statepsid<.

sort statepsid year
merge m:1 statepsid year using "data\state_year_panel_dataset.dta", keepusing(statefips stateusps inter_bra)
keep if _merge==1|_merge==3
drop _merge

rename x11101LL x11101ll
sort x11101ll year
**merge other useful variable created using psiduse
merge 1:1 x11101ll year using "data\psid_ownhome.dta"
keep if _merge==1|_merge==3
drop _merge
gen psid_ownhome=1 if downhome==1
replace psid_ownhome=0 if downhome==5

gen age=d11101
gen prime=age>=25 & age<=54
gen married=d11104
gen nchild=d11107
gen child=nchild>0
gen female=d11102L==2
gene educ=d11109
gen hsdrop=educ<12
gen hsgrad=educ==12
gen somecol=educ>12 & educ<16
gen collegeplus=educ>=16
gen anycollege=somecol==1|collegeplus==1
gen race=d11112LL
gen white=race==1
gen black=race==2
gen weight=w11101
gen hhweight=w11102
gen longweight=w11103
gen id=x11101ll
gen inlf=e11102
gen hours=e11101

**create ownhome variable
gen cnef_ownhome=i11105>0 if i11105<.
**ownhome variable using cnef is somewhat approximate as it is based on imputed rental value for households with positive equity
**alternatively define ownhome using own home variables downloaded directly from psid
gen ownhome=psid_ownhome
tab ownhome

tab stateusps
gen texas=stateusps=="TX"

**********************************************************
**********************************************************
**********************************************************
**********************************************************
**sample selection
count
keep if year>=1992 & year<=2007
**keep if prime
drop if inlf==.
drop if ownhome==.
count
egen meanownhome=mean(ownhome), by(id)
egen meantexas=mean(texas), by(id)
**********************************************************
**********************************************************
**********************************************************
**********************************************************
cap drop post1997
gen post1997=year>=1998
cap drop post2003
gen post2003=year>=2004

gen texas_post1997=texas*post1997
gen texas_post2003=texas*post2003

gen post1997to2003=year>=1998 & year<=2003
gen texas_post1997to2003=texas*post1997to2003

gen texas_ownhome=texas*ownhome
gen ownhome_post1997=post1997*ownhome
gen ownhome_post2003=post2003*ownhome
gen ownhome_post1997to2003=ownhome*post1997to2003

gen texas_ownhome_post1997=texas*post1997*ownhome
gen texas_ownhome_post1997to2003=texas*post1997to2003*ownhome
gen texas_ownhome_post2003=texas*post2003*ownhome

reg inlf texas post1997 texas_post1997 if ownhome
reg inlf texas post1997 texas_post1997 if !ownhome

reg inlf texas post1997 ownhome texas_ownhome ownhome_post1997 texas_post1997 texas_ownhome_post1997, robust cluster(statefips)

reg inlf texas post1997 ownhome texas_ownhome ownhome_post1997 texas_post1997 texas_ownhome_post1997to2003 texas_ownhome_post2003, robust cluster(statefips)

label var texas_post1997 "Texas X Post 1997"
label var texas_post2003 "Texas X Post 2003"
label var texas_post1997to2003 "Texas X 1997-2003"

replace inlf=inlf*100

label var ownhome_post1997 "Homeowner X Post 1997"
label var ownhome_post2003 "Homeowner X Post 2003"

label var texas_ownhome "Texas X Homeowner"
label var texas_ownhome_post1997 "Texas X Homeowner X Post 1997"
label var texas_ownhome_post1997to2003 "Texas X Homeowner X 1997-2003"
label var texas_ownhome_post2003 "Texas X Homeowner X Post 2003"

**pre dummy excluding 1997
gen pre=year<1997
gen texas_pre=texas*pre
egen t=group(year)
gen t2=t^2
gen t3=t^3
gen t4=t^4
egen groupstatefips=group(statefips)
egen groupstateusps=group(stateusps)

cap label drop texas
label define texas 0 "Rest of US" 1 "Texas"
label val texas texas

char year[omit] 1997

xi i.year

global expl2 age married child hsgrad collegeplus

global clustvar statefips

**MODEL WITH 1997-2003 Dummy and Post-2003 Dummy
estimates clear
eststo: qui areg inlf $expl2 inter_bra texas _Iyear* texas_post1997to2003 texas_post2003, ab(id) cluster($clustvar)

preserve

keep if ownhome
eststo: qui areg inlf $expl2 inter_bra texas _Iyear* texas_post1997to2003 texas_post2003, ab(id) cluster($clustvar)

restore

preserve

keep if !ownhome
eststo: qui areg inlf $expl2 inter_bra texas _Iyear* texas_post1997to2003 texas_post2003, ab(id) cluster($clustvar)

restore

esttab using "$resultsdir\Table A2.rtf", replace title("Table A2: Difference in Differences Estimates of Home Equity Access on LFPR") keep(texas_post1997to2003 texas_post2003) order(texas_post1997to2003 texas_post2003) mtitles("Full Sample" "Homeowners" "Renters") nocons b(%7.3f) se(%7.3f) nonotes starlevels(* 0.10 ** 0.05) label  sfmt(%12.3f) scalars("r2_a AdjR-Sq") indicate("Year Fixed Effects=_Iyear*" "Demographic Controls=${expl2}" "Bank Branching Control=inter_bra")

estimates clear
preserve

keep if texas
eststo: areg inlf $expl2 inter_bra post1997to2003 post2003, ab(id)

restore

preserve

keep if texas & ownhome
eststo: areg inlf $expl2 inter_bra post1997to2003 post2003, ab(id)

restore

preserve

keep if texas & !ownhome
eststo: areg inlf $expl2 inter_bra post1997to2003 post2003, ab(id)

restore

esttab using "$resultsdir\Table A2.rtf", append title("Panel B: Texas Sample") keep(post1997to2003 post2003) order(post1997to2003 post2003) mtitles("Full Sample" "Homeowners" "Renters") nocons b(%7.3f) se(%7.3f) nonotes starlevels(* 0.10 ** 0.05) label  sfmt(%12.3f) scalars("r2_a AdjR-Sq") indicate("Demographic Controls=${expl2}" "Bank Branching Control=inter_bra") 