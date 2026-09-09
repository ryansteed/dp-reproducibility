/*Using basic monthly CPS files from IPUMS-CPS, this file creates two datasets used for the credit constraints and labor market paperr. (1) It creates state_level_average_basic_cps.dta annual averages of demographic vraiables, e.g. age and indicator vraiables for gender, race (white, black, etc.), education (highschool, collegee etc.). Averaging the indicator variables creates variables that have an interpretation of share of states population  (2) It collapses the data by statefips year agegrp3cat female married race4cat educ4cat to create panel data by state, year and demographic group.
*/
cd "C:\Users\Anil Kumar\OneDrive\Dallas Fed\wulf04\cps_ipums"
adopath + ~/ado/plus

use ipums_cps_extract_AEJ_credit_constraints.dta, clear

numlabel, add
sum year
tab race
tab hispan
gen nothisp=hispan==0
tab nothisp
gen white=race==100 & nothisp if !mi(race)
gen black=race==200 & nothisp if !mi(race)
gen hisp=1-nothisp 
replace hisp=. if hispan==901|hispan==902

**create race categories
gen race4cat=1 if white==1
replace race4cat=2 if black==1
replace race4cat=3 if hisp==1
replace race4cat=4 if race4cat==.

label define race4cat 1 "White" 2 "Black" 3 "Hispanic" 4 "Others" 
label values race4cat race4cat


gen head=relate==101 if relate<.
gen spouse=relate==201 if relate<.

**gen ownhome=ownershp==10 if !mi(ownershp)
replace labforce=. if labforce==0
replace empstat=. if empstat==0
gen nilf=labforce==1 if !mi(labforce)
tab nilf
sum nilf
gen inlf=1-nilf
tab inlf
sum inlf
gen birthyear=year-age

gen empl=(empstat==10|empstat==12|empstat==13) & !mi(empstat)
tab empl inlf
gen unem=(empstat==20|empstat== 21|empstat==22) & !mi(empstat)
tab unem inlf

**very short term
gen durlt5w=durunemp<5 if !mi(durunemp)
**short term
gen durle14w=durunemp<=14 if !mi(durunemp)
**medium term
gen durge5le14w=(durunemp>=5 & durunemp<=14) if !mi(durunemp)
gen durge15w=durunemp>=15 if !mi(durunemp)
**medium term
gen durge15le26w=(durunemp>=15 & durunemp<=26) if !mi(durunemp)
**broad medium term
gen durge5le26w=(durunemp>=5 & durunemp<=26) if !mi(durunemp)
**long term six months to one year
gen durge27le52w=(durunemp>=27 & durunemp<=52 ) if !mi(durunemp)
**very long-term more than 1 year
gen durge53w=durunemp>=53 if !mi(durunemp)
**more than 6 months unemployed
gen durge27w=durunemp>=27 if !mi(durunemp)

gen male=sex==1
gen female=sex==2

replace higrade=. if higrade>=999
gen hi_hsdrop=higrade<150 if !missing(higrade)
gen hi_hsgrad=higrade==150 if !missing(higrade)
gen hi_somecol=(higrade>150 & higrade<190) if !missing(higrade)
gen hi_college=higrade==190 if !missing(higrade)
gen hi_postcollege=higrade>190 if !missing(higrade)
gen hi_anycollege=higrade>150 if !missing(higrade)

replace educ=. if educ>=999
gen hsdrop=educ<73 if educ<.
gen hsgrad=educ==73 if educ<.

gen somecol=(educ==81|educ==91|educ==92) if educ<. & year>=1992
replace somecol=(educ>73 & educ<110) if educ<. & year<1992

gen college=educ==111 if educ<. & year>=1992
replace college=educ==110 if educ<. & year<1992

gen postcollege=educ>111 if educ<. & year>=1992
replace postcollege=educ>110 if educ<. & year<1992

gen collegeplus=educ>=111 if educ<. & year>=1992
replace collegeplus=educ>=110 if educ<. & year<1992

gen anycollege=educ>73 if educ<.
gen nocollege=1-anycollege


**includes married spouse present or absent
gen married=marst==1|marst==2 if !mi(marst)

gen agegrp5cat=.
replace agegrp5cat=1 if age>=16 & age<=19
replace agegrp5cat=2 if age>=20 & age<=34
replace agegrp5cat=3 if age>=35 & age<=54
replace agegrp5cat=4 if age>=55 & age<=64
replace agegrp5cat=5 if age>=65 & age~=.
gen age65plus=age>=65 & age~=.


**broader categories
gen agegrp3cat=1 if age<=24
replace agegrp3cat=2 if age>=25 & age<=54
replace agegrp3cat=3 if age>=55

label define agegrp3cat 1 "Young" 2 "25-54" 3 "55+"
label values agegrp3cat agegrp3cat
tab agegrp3cat, gen(agegrp3cat)

gen prime=age>=22 & age<=60 if age<.
label define prime 0 "Non-Prime Age" 1 "Prime-Age"
label values prime prime

gen educ5cat=1 if hsdrop==1
replace educ5cat=2 if hsgrad==1
replace educ5cat=3 if somecol==1
replace educ5cat=4 if college==1
replace educ5cat=5 if postcollege==1

label define educ5cat 1 "HS Dropout" 2 "HS" 3 "Some College" 4 "College" 5 "Post-College"
label values educ5cat educ5cat

gen educ4cat=educ5cat
replace educ4cat=4 if educ5cat==5

label define educ4cat 1 "HS Dropout" 2 "HS" 3 "Some College" 4 "College+" 
label values educ4cat educ4cat

rename statefip statefips
format statefips %8.0g
recast long year
format year %12.0g

replace uhrsworkt=. if uhrsworkt==997|uhrsworkt==999
sum uhrsworkt if relate==101

replace uhrsworkorg=. if uhrsworkorg==998
gen hoursperweek=uhrsworkorg

replace earnweek=. if earnweek==9999.99
gen wageperhour=earnweek/hoursperweek

**note that some wtsupp weights are negative
cap replace wtsupp=0 if wtsupp<0

**some more variables
gen child=yngch<=18
**define household with child
bys year month serial (pernum): egen nchild=total(child)
gen hhchild=nchild>0 & nchild<.

gen nochild=1-child
gen nohhchild=1-hhchild

bys year month serial (pernum): egen fsize=count(serial)

**examine more variables
replace wkstat=. if wkstat==99
gen fulltime=wkstat==10 if wkstat<. & empl==1 & year<=1993
replace fulltime=wkstat==11 if wkstat<. & empl==1 & year>=1994
gen parttime=1-fulltime 

qui do cpi99.do

foreach x of varlist earnweek wageperhour {
**for 2016 dollars see https://cps.ipums.org/cps/cpi99.shtml
cap drop r`x'
gen r`x'=`x'*cpi99*1.440
}

gen texas=statefips==48
gen post=year>=1998
gen texas_post=texas*post

egen t=group(year)
egen groupstatefips=group(statefips)

preserve
collapse inlf nilf empl unem fulltime parttime age prime age65plus white black hisp married female child hhchild fsize hsdrop hsgrad somecol college postcollege collegeplus anycollege nocollege [w=wtfinl], by(statefips year) 
save state_level_average_basic_cps.dta, replace
restore

cap program drop collapse_key_vars
program collapse_key_vars 

preserve
gen numinlf=inlf
gen numempl=empl
local formeans inlf empl child
local forsum numinlf numempl
gen weight_all=1
gcollapse (mean) `formeans' (sum) `forsum' weight_all [iw=wtfinl], by($byvars) missing fast
sort $byvars 
save temp.dta, replace
restore


**#unemployed and u1, u2, u3, unemployment rate

preserve
gen numunem=unem
local formeans unem 
local forsum numunem
gen weight_lf=1
gcollapse (mean) `formeans' (sum) `forsum' weight_lf [iw=wtfinl] if nilf==0, by($byvars) missing fast
sort $byvars 
merge 1:1 $byvars using temp.dta
tab _merge 
drop _merge 
sort $byvars 
save temp.dta, replace
restore


preserve
local formeans dur* 
gen weight_unem=1
gcollapse (mean) `formeans' (sum) weight_unem [iw=wtfinl] if unem==1, by($byvars) missing fast
sort $byvars 
merge 1:1 $byvars using temp.dta 
tab _merge 
drop _merge 
sort $byvars 
save temp.dta, replace
restore

preserve
**remove lt35* only due to memory problems
local formeans fulltime parttime uhrsworkt hoursperweek  wageperhour
gen weight_empl=1
gcollapse (mean) `formeans' (sum) weight_empl [iw=wtfinl] if empl==1, by($byvars) missing fast
sort $byvars 
merge 1:1 $byvars using temp.dta 
tab _merge 
drop _merge 
sort $byvars 
save temp.dta, replace
**now simply update the main output file
**append using state_level_labor_force_vars_basic_cps.dta
foreach x of varlist $byvars {
drop if `x'==.
}
sort $byvars 
save "state_level_labor_force_vars_basic_cps_IPUMS_by_${byvars}.dta", replace
restore
end

global byvars statefips year agegrp3cat female married race4cat educ4cat 
collapse_key_vars