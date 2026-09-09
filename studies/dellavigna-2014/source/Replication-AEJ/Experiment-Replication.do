clear
set more off
local path=""
use "`path'/Experiment Replication Data.dta"
cd "`path'/Replication/"

*******Data preparation


tab group, gen (gr)


global main_file="experiment.xls"
global Katz_file="experiment_Katz.xls"
global interactions_file="experiment_interactions.xls"

replace serbs=0 if serbs==.
drop if serbs==1
rename gender gend
encode gend, gen (gender)

tab familypartinwar, gen(fp)
tab kia, gen(k)

gen familywar=0 if familypartinwar==1|familypartinwar==2
replace familywar=1 if familypartinwar==1
quietly sum familywar

gen familywarmissing=0
replace familywarmissing=1 if familypartinwar==3|familypartinwar==4

gen killedwar=0 if kia==1|kia==2
replace killedwar=1 if kia==1
gen killedwarmissing=0
replace killedwarmissing=1 if kia==3|kia==4

rename v46 feelingserb
rename bosniand feelingbosnian
rename hungarian feelinghungarian



foreach var in work school friend husband {
	rename `var' `var'bosnian0
}
	
forval i=0/2 {
	local j=30+`i'*4
	local ethnic="serb0"
	if `i'==1 {
		local ethnic="hungarian0" 
	}
	if `i'==2 {
		local ethnic="rusini0" 
	}
	rename v`j' work`ethnic'
	local j=`j'+1
	rename v`j' school`ethnic'
	local j=`j'+1
	rename v`j' friend`ethnic'
	local j=`j'+1
	rename v`j' husband`ethnic'
}

foreach ethnic in serb0 bosnian0 hungarian0 rusini0 {
	pca work`ethnic' school`ethnic' friend`ethnic' husband`ethnic'
	predict with`ethnic'0
}

gen vukovar=0 if village!=""
replace vukovar=1 if village=="Vukovar"|village=="Vuvkoar"

gen osijek=0 if village!=""
replace osijek=1 if village=="Osijek"
gen familywar_gr2=familywar*gr2
gen familywar_gr3=familywar*gr3

replace gender=2-gender

global short="gr2 gr3 vukovar osijek"
global long="gr2 gr3 vukovar osijek gender familywar killedwar"

foreach ethnic in serb bosnian hungarian rusini {
	foreach dovar in work school friend husband {
		rename `dovar'`ethnic'0 `dovar'`ethnic'
		replace `dovar'`ethnic'=0 if `dovar'`ethnic'==2

	}
}	



gen hdzetal=(hdz+hdssb)/2
gen group_id=1 if group=="c"
replace group_id=3 if group=="t1"
replace group_id=2 if group=="t2"



gen nationalist=(hdz+hdssb+hsp)/3

*parties
replace hdz=1 if hdz<min(hsp,sdp)
replace hdz=2 if (hdz>hsp&hdz<sdp)|(hdz<hsp&hdz>sdp)
replace hdz=3 if hdz>max(hsp,sdp)

replace hsp=1 if hdz<min(hdz,sdp)
replace hsp=2 if (hsp>hdz&hsp<sdp)|(hsp<hdz&hsp>sdp)
replace hsp=3 if hsp>max(hdz,sdp)

replace sdp=1 if sdp<min(hsp,hdz)
replace sdp=2 if (sdp>hsp&sdp<hdz)|(sdp<hsp&sdp>hdz)
replace sdp=3 if sdp>max(hsp,hdz)

foreach var in hdz hsp sdp nationalist {
	rename `var' rank`var'
}
gen new_id=_n



*Katz style measure
foreach ethnic in serb bosnian hungarian {
foreach x of varlist feeling`ethnic' work`ethnic' school`ethnic' husband`ethnic' friend`ethnic' {
	qui sum `x' if group_id==1 & serbs==0
	local mean_control=r(mean)
	local sd_control=r(sd)
	gen standard_Katz_`x'=(`x'-`mean_control')/`sd_control'
	}

}


foreach ethnic in bosnian hungarian serb {	
egen outcome_index_`ethnic'=	rowmean(standard_Katz_*`ethnic')
}



gen byte treatment1=(group_id==2)
gen byte treatment2=(group_id==3)



local opt="replace"
foreach ethnic in bosnian hungarian serb {	
reg outcome_index_`ethnic' treatment1 treatment2 if serbs==0, r
test treatment1=treatment2
gen outcome_index_se_gr1_`ethnic'=_se[_cons]
gen outcome_index_se_gr2_`ethnic'=_se[treatment1]
gen outcome_index_se_gr3_`ethnic'=_se[treatment2]

outreg2 using "$Katz_file", bracket `opt' label dec(3) addstat("Equality of coef. F", r(F), "Equality of coef. p", r(p))
local opt="append"
}

drop *ersintrimot 

preserve
reshape long feeling work friend husband school  outcome_index_ outcome_index_se_gr1_ outcome_index_se_gr2_ outcome_index_se_gr3_, i(id) j(ethnic) string

gen order=1 if ethnic=="serb"
replace order=2 if ethnic=="bosnian"
replace order=3 if ethnic=="hungarian"
replace order=4 if ethnic=="rusini"

drop if regexm(ethnic,"0")
drop if serb==1

replace ethnic="Serb" if ethnic=="serb"
replace ethnic="Bosnian" if ethnic=="bosnian"
replace ethnic="Hungarian" if ethnic=="hungarian"
replace ethnic="Rusini" if ethnic=="rusini"

replace work=1-work
replace  school= 1-school
replace husband = 1-husband
replace friend = 1-friend


gen aux=order*4+group_id-3

foreach var in feeling work school husband friend outcome_index_ {
*	replace `var'=1-`var'
	egen `var'_mean=mean(`var'), by(aux)
	egen `var'_sd=sd(`var'), by(aux)
	egen `var'_n=count(`var'), by(aux)
}


gen hi=.
gen low=.



*******Drawing graphs

*STANDARD ERRORS FROM REGRESSION, BUT USE NORMAL APPROXIMATION


* Figure 3
local var="outcome_index_"
forvalues x=1/3 {
replace hi=`var'_mean+1.96*outcome_index_se_gr`x'_ if group_id==`x'
replace low=`var'_mean-1.96*outcome_index_se_gr`x'_ if group_id==`x'
}
twoway (bar `var'_mean aux if group_id==1, color(midblue*2)) (bar `var'_mean aux if group_id==2,color(red*2)) (bar `var'_mean aux if group_id==3,color(green*1.5)) (rcap hi low aux, color(gs4)) if aux<=12, ysc(r(0 0.5)) legend( order (1 "Control" 2 "B92 radio treatment" 3 "RTS radio treatment")) xlabel( 3 "Serbs" 7 "Bosnians" 11 "Hungarians", noticks) xtitle(" ") ytitle("Standardized measure of attitudes toward different groups", size (small)) 



*NOTE: STANDARD ERRORS ARE APPROXIMATE AND ARE NOT REGRESSION BASED

*OA Figure 5a
local var="work"
replace hi=`var'_mean+invttail(`var'_n-1,0.025)*(`var'_sd/ sqrt(`var'_n))
replace low=`var'_mean-invttail(`var'_n-1,0.025)*(`var'_sd/ sqrt(`var'_n))
twoway (bar `var'_mean aux if group_id==1, color(midblue*2)) (bar `var'_mean aux if group_id==2,color(red*2)) (bar `var'_mean aux if group_id==3,color(green*1.5)) (rcap hi low aux, color(gs4)) if aux<=17, ysc(r(0 0.6)) legend( order (1 "Control" 2 "B92 radio treatment" 3 "RTS radio treatment")) xlabel( 3 "Serb" 7 "Bosnian" 11 "Hungarian" 15 "Rusini", noticks) xtitle(" ") ytitle("Would you agree to work with... (0-yes, 1 - no)", size (small))

*OA Figure 5b
local var="school"
replace hi=`var'_mean+invttail(`var'_n-1,0.025)*(`var'_sd/ sqrt(`var'_n))
replace low=`var'_mean-invttail(`var'_n-1,0.025)*(`var'_sd/ sqrt(`var'_n))
twoway (bar `var'_mean aux if group_id==1, color(midblue*2)) (bar `var'_mean aux if group_id==2,color(red*2)) (bar `var'_mean aux if group_id==3,color(green*1.5)) (rcap hi low aux, color(gs4)) if aux<=17, ysc(r(0 0.5)) legend( order (1 "Control" 2 "B92 radio treatment" 3 "RTS radio treatment")) xlabel( 3 "Serb" 7 "Bosnian" 11 "Hungarian" 15 "Rusini", noticks) xtitle(" ") ytitle("Would you agree that your child go to school with... (0-yes, 1 - no)", size(small))

*OA Figure 5c
local var="friend"
replace hi=`var'_mean+invttail(`var'_n-1,0.025)*(`var'_sd/ sqrt(`var'_n))
replace low=`var'_mean-invttail(`var'_n-1,0.025)*(`var'_sd/ sqrt(`var'_n))
twoway (bar `var'_mean aux if group_id==1, color(midblue*2)) (bar `var'_mean aux if group_id==2,color(red*2)) (bar `var'_mean aux if group_id==3,color(green*1.5)) (rcap hi low aux, color(gs4)) if aux<=17, ysc(r(0 0.5)) legend( order (1 "Control" 2 "B92 radio treatment" 3 "RTS radio treatment")) xlabel( 3 "Serb" 7 "Bosnian" 11 "Hungarian" 15 "Rusini", noticks) xtitle(" ") ytitle("Would you agree that your child's best friend is... (0-yes, 1 - no)", size(small))

*OA Figure 5d
local var="husband"
replace hi=`var'_mean+invttail(`var'_n-1,0.025)*(`var'_sd/ sqrt(`var'_n))
replace low=`var'_mean-invttail(`var'_n-1,0.025)*(`var'_sd/ sqrt(`var'_n))
twoway (bar `var'_mean aux if group_id==1, color(midblue*2)) (bar `var'_mean aux if group_id==2,color(red*2)) (bar `var'_mean aux if group_id==3,color(green*1.5)) (rcap hi low aux, color(gs4)) if aux<=17, ysc(r(0 0.5)) legend( order (1 "Control" 2 "B92 radio treatment" 3 "RTS radio treatment")) xlabel( 3 "Serb" 7 "Bosnian" 11 "Hungarian" 15 "Rusini", noticks) xtitle(" ") ytitle("Would you agree that your child marry... (0-yes, 1 - no)", size(small))




*OA Figure 5e
replace hi=feeling_mean+invttail(feeling_n-1,0.025)*(feeling_sd/ sqrt(feeling_n))
replace low=feeling_mean-invttail(feeling_n-1,0.025)*(feeling_sd/ sqrt(feeling_n))
twoway (bar feeling_mean aux if group_id==1, color(midblue*2)) (bar feeling_mean aux if group_id==2,color(red*2)) (bar feeling_mean aux if group_id==3,color(green*1.5)) (rcap hi low aux, color(gs4)) if aux<=12, ysc(r(0 0.5)) legend( order (1 "Control" 2 "B92 radio treatment" 3 "RTS radio treatment")) xlabel( 3 "Serbs" 7 "Bosnians" 11 "Hungarians", noticks) xtitle(" ") ytitle("Attitudes toward different groups (''feeling thermometer'')", size (small)) 

restore


*OA Figure 5f
reshape long rank, i(new_id) j(party) string
replace party="Moderate nationalists" if party=="hdz"
replace party="Extreme nationalists" if party=="hsp"
replace party="Social-Democrats" if party=="sdp"
drop if party=="nationalist"|party=="hdzetal"


gen order=2 if party=="Moderate nationalists"
replace order=1 if party=="Extreme nationalists"
replace order=3 if party=="Social-Democrats"
drop if serb==1

gen aux=order*4+group_id-3
replace rank=4-rank
local var="rank"
egen `var'_mean=mean(`var'), by(aux)
egen `var'_sd=sd(`var'), by(aux)
egen `var'_n=count(`var'), by(aux)

local var="rank"
gen hi=`var'_mean+invttail(`var'_n-1,0.025)*(`var'_sd/ sqrt(`var'_n))
gen low=`var'_mean-invttail(`var'_n-1,0.025)*(`var'_sd/ sqrt(`var'_n))

twoway (bar `var'_mean aux if group_id==1, color(midblue*2)) (bar `var'_mean aux if group_id==2,color(red*2)) (bar `var'_mean aux if group_id==3,color(green*1.5)) (rcap hi low aux, color(gs4)), ysc(r(0 0.5)) legend( order (1 "Control" 2 "B92 radio treatment" 3 "RTS radio treatment")) xlabel( 3 "Extreme Nationalists" 7 "Moderate Nationalists" 11 "Social Democrats" , noticks) xtitle(" ") ytitle("Average rank of parties in a group", size(small))


