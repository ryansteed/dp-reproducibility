###########################################################
##### Electoral Competition, Voter Bias and Women in Politics
###########################################################
##### By Thomas Le Barbanchon and Julien Sauvagnat
###########################################################

global root= ".."
*global root = "C:/XXX"
global directory "$root/Input"
cd "$directory"

/*
This do-file uses as inputs (databases located in folder Source):
1. GGS 
- Gender Generation Survey (GGS) Wave of 2005 
- obtained by Sauvagnat in May 2018
- https://www.ggp-i.org/data/

2. database_LRcoalitions
- main database at the candidate-election level (restricted to candidates of main Left and Right parties over parliamentary elections 1981 to 2017)

3. database_allcandidates
- database at the candidate-election level (with all candidates running for election between 1981 to 2017, with only a few candidates' characteristics available)

4. wagegaps_circo
- The dataset contains various measures of the gaps in earnings and wages between men and women, calculated using the DADS data for 1996, 2001, 2006, 2011 and 2015, at the district level.

5. REN-clean
- "Repertoire des elus" (register of local politicians)

*/
******************************************************************************************************************************************************




*Compute beliefs at department of residence level
use ../Source/GGS.dta, clear
gen betterpoli=a1113_c==1|a1113_c==2
replace betterpoli=. if a1113_c==3
gen jobs=a1114_a==1|a1114_a==2
replace jobs=. if a1114_a==3
*** EDITED by Ryan Steed
collapse(mean) better* job* (sum) sum_betterpoli=betterpoli sum_jobs=jobs (count) n_betterpoli=betterpoli n_jobs=jobs, by(dpt_r)
***
rename dpt_r dpt
save GGS_aggregated, replace


*Upload initial database of candidates of the two main Left and Right parties
use ../Source/database_LRcoalitions, replace


* Recover scores of the two main parties in the presidential elections
merge m:1 dpt circo election using ../Source/presidentialscore
drop if _m==2
drop _m

* "UMP" denotes main Right Party, "PS" main Left Party
gen scoreP1=score1UMP if coalition=="UMP"
replace scoreP1=score1PS if coalition=="PS"
gen scoreP2=score2UMP if coalition=="UMP"
replace scoreP2=score2PS if coalition=="PS"

label var scoreL1 "Electoral Score (Round 1 - legislative)"
label var scoreL2 "Electoral Score (Round 2 - legislative)"
label var scoreP1 "Presidential Elect. Party Score" 	


* District-Election and Coalition-Election FEs
egen district_electionl_g=group(dpt circo electionl)
egen coalition_electionl=group(coalition electionl)
sort dpt circo coalition electionl

* Compute contestability measures based on presidential and parliamentary elections' scores
forvalues i=1(1)3{
gen contest`i'P=scoreP2>=0.5-`i'/100&scoreP2<=0.5+`i'/100 if missing(scoreP2)==0
label var contest`i'P "Party score within 2x`i' bandwidth around 0.5 in round 2 of previous presidential election"
gen contest`i'L=scoreL2>=0.5-`i'/100&scoreL2<=0.5+`i'/100 if missing(scoreL2)==0
label var contest`i'L "Party score within 2x`i' bandwidth around 0.5 in round 2 of current legislative election"
}

* Merge with wage_gaps data 
gen year_dads=electionl
replace year_dads=year_dads-1
replace year_dads=2015 if electionl==2017
replace year_dads=1996 if electionl==1997|electionl==1993|electionl==1988
joinby circouniqueid year_dads using "../Source/wagegaps_circo.dta"

*  Merge with beliefs
joinby dpt using "GGS_aggregated", unm(b)
drop if _merge==2
drop _merge

foreach var in 1 2 {
gen scoreL`var'_R_=scoreL`var' if parti_stab=="R"
gen scoreL`var'_L_=scoreL`var' if parti_stab=="L"
}

foreach var in 1 2 {
bysort electionl circouniqueid: egen scoreL`var'_R=mean(scoreL`var'_R_)
by electionl circouniqueid: egen scoreL`var'_L=mean(scoreL`var'_L_)
label var scoreL`var'_R "Right party Score (round `i') of current legislative election"
label var scoreL`var'_L "Left party Score (round `i') of current legislative election"
}

gen diffscoreL1_RL=abs(scoreL1_R-scoreL1_L)
label var diffscoreL1_RL "Absolute diff in round 1 scores of current legislative elec (between R and L)"
gen diffscoreL2_RL=abs(scoreL2_R-scoreL2_L)
label var diffscoreL2_RL "Absolute diff in round 2 scores of current legislative elec (between R and L)"

gen contest1P_=contest1P 
gen contest2P_=contest2P 
gen contest3P_=contest3P 

label var contest3P_ "Contestable district using relevant presidential election score"
gen diffscore1_RL=score1UMP-score1PS
label var diffscore1_RL "Score difference btw Rigth and Left party"

gen contest3P1=inrange(diffscore1_RL,-0.03,0.03)
gen contest1P1=inrange(diffscore1_RL,-0.01,0.01)
gen contest2P1=inrange(diffscore1_RL,-0.02,0.02)

replace contest1P_=contest1P1 if electionl==2002
replace contest1P_=contest1P1 if electionl==2017
replace contest3P_=contest3P1 if electionl==2002
replace contest3P_=contest3P1 if electionl==2017
replace contest2P_=contest2P1 if electionl==2002
replace contest2P_=contest2P1 if electionl==2017
save database, replace


***Create Share Independent

*save database_allcandidates, replace
use ../Source/database_allcandidates, clear
gen coalition="PS" if nuance=="DVG"
replace coalition="UMP" if nuance=="DVD"
drop if missing(coalition)
gen n=1
collapse(mean) FshareIndependentCoalition=F (sum) nbIndependent=n nbFIndependentCoalition=F, by(coalition dpt circo electionl)
save Findependent, replace

***Computing Gender gap in high-skill occupation for local politicians
* Take register of local politicians
use ../Source/REN-clean, clear
*Restrict to right-wing candidates
keep if political_orientation_cand=="right"
* Code municipality
gen codeinseeREN=codedudpartementmaire*1000+codeinseedelacommune
gen yeard=substr(datededbutdumandat,7,4)
*Female dummy
gen F=codesexe=="F"
*Date of birth
gen dof=substr(datedenaissance,7,4)
destring dof, replace
*Dummy for high-skill occupations (based on occupation-codes)
gen PCS=1 if codeprofession==5|codeprofession==6|codeprofession==13|codeprofession==18|codeprofession==19|codeprofession==24|codeprofession==25|codeprofession==26|codeprofession==27|codeprofession==28|codeprofession==29|codeprofession==30|codeprofession==32|codeprofession==34|codeprofession==35|codeprofession==36|codeprofession==37|codeprofession==38|codeprofession==39|codeprofession==41|codeprofession==45|codeprofession==46|codeprofession==47|codeprofession==50|codeprofession==51|codeprofession==54
replace PCS=0 if missing(PCS)
keep nidentificationdunlu yeard codeinseeREN PCS F dof
destring yeard, replace
collapse(min) yeard (mean) F PCS dof, by(nidentificationdunlu codeinsee)
rename codeinseeREN codeinsee
save temp, replace

use database, clear
drop if missing(candidatid)
drop if missing(electionl)
keep electionl dpt circo 
duplicates drop
keep if electionl>=2002
joinby dpt circo electionl using ../Source/circo-municipalities-link.dta
keep electionl dpt circo codeinsee
duplicates drop
joinby codeinsee using temp
gen age=electionl-dof
keep if age>=18&age<=90
keep if electionl>=yeard
gen n=1
collapse(mean) PCS, by(electionl dpt circo F)
reshape wide PCS, i(electionl dpt circo) j(F)
keep if electionl>=2001
gen diffPCSr1=PCS0-PCS1
keep diffPCSr1 electionl dpt circo 
save localpoolr, replace

use ../Source/REN-clean, clear
*Restrict to left-wing candidates
keep if political_orientation_cand=="left"
* Code municipality
gen codeinseeREN=codedudpartementmaire*1000+codeinseedelacommune
gen yeard=substr(datededbutdumandat,7,4)
*Female dummy
gen F=codesexe=="F"
*Date of birth
gen dof=substr(datedenaissance,7,4)
destring dof, replace
*Dummy for high-skill occupations (based on occupation-codes)
gen PCS=1 if codeprofession==5|codeprofession==6|codeprofession==13|codeprofession==18|codeprofession==19|codeprofession==24|codeprofession==25|codeprofession==26|codeprofession==27|codeprofession==28|codeprofession==29|codeprofession==30|codeprofession==32|codeprofession==34|codeprofession==35|codeprofession==36|codeprofession==37|codeprofession==38|codeprofession==39|codeprofession==41|codeprofession==45|codeprofession==46|codeprofession==47|codeprofession==50|codeprofession==51|codeprofession==54
replace PCS=0 if missing(PCS)
keep nidentificationdunlu yeard codeinseeREN PCS F dof
destring yeard, replace
collapse(min) yeard (mean) F PCS dof, by(nidentificationdunlu codeinsee)
rename codeinseeREN codeinsee
save temp, replace

use database, clear
drop if missing(candidatid)
drop if missing(electionl)
keep electionl dpt circo 
duplicates drop
keep if electionl>=2002
joinby dpt circo electionl using ../Source/circo-municipalities-link.dta
keep electionl dpt circo codeinsee
duplicates drop
joinby codeinsee using temp
gen age=electionl-dof
keep if age>=18&age<=90
keep if electionl>=yeard
gen n=1
collapse(mean) PCS, by(electionl dpt circo F)
reshape wide PCS, i(electionl dpt circo) j(F)
keep if electionl>=2001
gen diffPCSr0=PCS0-PCS1
keep diffPCSr0 electionl dpt circo 
save localpooll, replace

joinby electionl dpt circo using localpoolr
keep diffPCSr1 diffPCSr0 circo dpt electionl
reshape long diffPCSr, i(circo dpt electionl) j(v)
gen coalition="UMP" if v==1
replace coalition="PS" if v==0
drop v
save localpoolbyp, replace
