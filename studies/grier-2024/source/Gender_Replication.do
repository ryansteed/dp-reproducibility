*The Causal Effect of Economic Freedom on Female Employment & Education
*Robin Grier, Contemporary Economic Policy


set more off

** NOTE THAT ANY USER OF THESE MATERIALS NEEDS TO ADD THEIR RELEVANT GLOBAL FILE PATH / DIRECTORY TO ALLOW THE PROGRAMS TO WORK AS INTENDED**

use "Replication_Data.dta", replace


/* Drop empty observations*/

drop if year == . 

#delimit ;


#delimit cr


egen id = group(country)


xtset id year

/*Generate Leads and Lags for Covariates*/

gen pcy=rgdpe/pop
gen pcyminus5=l5.pcy
gen hcminus5=l5.hc
gen csh_x5=l5.csh_x
gen csh_g5=l5.csh_g
gen inf5=l5.Inflation
gen EFW5=l5.EFW
gen lvdemoc=l5.vdemoc


/*Generate Leads and Lags for Outcome Variables*/

gen dfprimary=f5.Primary_Complete-Primary_Complete
gen dflfpart=f5.Labor_Force_Part-Labor_Force_Part
gen dflfper=f5.Labor_Force_Percent-Labor_Force_Percent
gen dflfpart_all=f5.Labor_Force_Part_all-Labor_Force_Part_all


*Generate Jump Variables

gen EFWchange= EFW-EFW5
gen nextchange=f10.EFW-EFW
gen prevchange= l5.EFWchange


gen jump75=0
replace jump75=1 if EFWchange > = .75 & nextchange > = -.15 & nextchange != .
replace jump75=0 if prevchange > = .75 & prevchange != .
replace jump75 = . if missing(EFWchange)


gen jump=0
replace jump=1 if EFWchange > = 1 & nextchange > =  -.20 & nextchange != .
replace jump=0 if prevchange > = 1 & prevchange != .
replace jump = . if missing(EFWchange)

gen jump125=0
replace jump125=1 if EFWchange > = 1.25 & nextchange > = -.25 & nextchange != .
replace jump125=0 if prevchange > = 1.25 & prevchange != .
replace jump125 = . if missing(EFWchange)


order id country year
sort country year

set seed 88


*TABLE 3 SUMMARY STATISTICS*
summarize EFW Labor_Force_Part Labor_Force_Percent Primary_Complete vdemoc ///
hc csh_x pcy csh_g Inflation


*TABLE 4 DETERMINANTS OF THE INITIATION OF REFORM

logit jump pcyminus5 EFW5 lvdemoc hcminus5 csh_g5  csh_x5 inf5 
predict prop
margins, eyex(pcyminus5 EFW5 lvdemoc hcminus5 csh_g5  csh_x5 inf5 )


*TABLE 5 THE EFFECTS OF REFORM ON GENDER EQUALITY OUTCOMES (JUMP OF 1.0)

*COLUMNS 2 & 3 OF TABLE 5 (% OF THE LABOR FORCE THAT IS FEMALE)

set seed 88

psmatch2 jump hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, /// 
out(dflfper) common ate logit  n(1)

eststo: bootstrap r(att), r(250) : psmatch2 jump hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, /// 
out(dflfper) common ate logit  n(1)
estout using "../results/table_lf.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
eststo clear

* COMMENTED OUT by Ryan *
/* pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dflfper) common ate logit  n(2)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dflfper) common ate logit  n(3)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dflfper) common ate logit  n(4)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc ///
, out(dflfper) kernel k(normal) common ate

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


teffects nnmatch (dflfper hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(1) 

teffects nnmatch (dflfper hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(2) 

teffects nnmatch (dflfper hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(3) 

teffects nnmatch (dflfper hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(4)  */



*COLUMNS 4 & 5 OF TABLE 5 (ECONOMICALLY ACTIVE FEMALES)

/* set seed 88

psmatch2 jump hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, /// 
out(dflfpart) common ate logit  n(1)

bootstrap r(att), r(250) : psmatch2 jump hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, /// 
out(dflfpart) common ate logit  n(1)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc  /// 
, out(dflfpart) common ate logit  n(2)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dflfpart) common ate logit  n(3)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dflfpart) common ate logit  n(4)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc ///
, out(dflfpart) kernel k(normal) common ate

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


teffects nnmatch (dflfpart hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(1) 

teffects nnmatch (dflfpart hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(2) 

teffects nnmatch (dflfpart hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(3) 

teffects nnmatch (dflfpart hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(4)  */



*COLUMNS 6 & 7 OF TABLE 5 (FEMALE PRIMARY SCHOOLING)

set seed 88

psmatch2 jump hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dfprimary) common ate logit  n(1)

psmatch2 jump hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc  /// 
, out(dfprimary) common ate logit  n(1)

eststo: bootstrap r(att), r(250) : psmatch2 jump hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dfprimary) common ate logit  n(1)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both

eststo: bootstrap r(att), r(250) : psmatch2 jump hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dfprimary) common ate logit  n(2)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both

eststo: bootstrap r(att), r(250) : psmatch2 jump hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dfprimary) common ate logit  n(3)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both

eststo: bootstrap r(att), r(250) : psmatch2 jump hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dfprimary) common ate logit  n(4)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both

eststo schooling: bootstrap r(att), r(250) : psmatch2 jump hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc ///
, out(dfprimary) kernel k(normal) common ate

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both

estout using "../results/table_schooling.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
eststo clear

save final.dta, replace
exit

teffects nnmatch (dfprimary hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(1) 

teffects nnmatch (dfprimary hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(2) 

teffects nnmatch (dfprimary hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(3) 

teffects nnmatch (dfprimary hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(4) 

/*
*TABLE 6 -- SEE RESULTS FROM TABLE 5 (SPECIFICALLY: Results are from the PSM nearest ///
2 neighbors equation presented in Table 5 for the first outcome variable (Percentage of ///
Labor Force that is female).


*TABLE 7 THE EFFECTS OF REFORM ON GENDER EQUALITY OUTCOMES (JUMP OF .75)

*COLUMNS 2 & 3 OF TABLE 7 (% OF THE LABOR FORCE THAT IS FEMALE)

set seed 88

psmatch2 jump75 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, /// 
out(dflfper) common ate logit  n(1)

bootstrap r(att), r(250) : psmatch2 jump75 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, /// 
out(dflfper) common ate logit  n(1)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump75 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dflfper) common ate logit  n(2)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump75 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dflfper) common ate logit  n(3)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump75 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dflfper) common ate logit  n(4)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump75 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc ///
, out(dflfper) kernel k(normal) common ate

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


teffects nnmatch (dflfper hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump75), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(1) 

teffects nnmatch (dflfper hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump75), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(2) 

teffects nnmatch (dflfper hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump75), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(3) 

teffects nnmatch (dflfper hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump75), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(4) 


*COLUMNS 4 & 5 OF TABLE 7 (ECONOMICALLY ACTIVE FEMALES)

set seed 88

psmatch2 jump75 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, /// 
out(dflfpart) common ate logit  n(1)

bootstrap r(att), r(250) : psmatch2 jump75 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, /// 
out(dflfpart) common ate logit  n(1)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump75 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc  /// 
, out(dflfpart) common ate logit  n(2)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump75 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dflfpart) common ate logit  n(3)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump75 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dflfpart) common ate logit  n(4)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump75 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc ///
, out(dflfpart) kernel k(normal) common ate

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


teffects nnmatch (dflfpart hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump75), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(1) 

teffects nnmatch (dflfpart hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump75), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(2) 

teffects nnmatch (dflfpart hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump75), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(3) 

teffects nnmatch (dflfpart hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump75), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(4) 



*COLUMNS 6 & 7 OF TABLE 7 (FEMALE PRIMARY SCHOOLING)

set seed 88

psmatch2 jump75 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dfprimary) common ate logit  n(1)

psmatch2 jump75 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc  /// 
, out(dfprimary) common ate logit  n(1)

bootstrap r(att), r(250) : psmatch2 jump75 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dfprimary) common ate logit  n(1)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump75 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dfprimary) common ate logit  n(2)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump75 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dfprimary) common ate logit  n(3)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump75 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dfprimary) common ate logit  n(4)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump75 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc ///
, out(dfprimary) kernel k(normal) common ate

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


teffects nnmatch (dfprimary hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump75), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(1) 

teffects nnmatch (dfprimary hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump75), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(2) 

teffects nnmatch (dfprimary hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump75), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(3) 

teffects nnmatch (dfprimary hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump75), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(4) 



*TABLE 8 THE EFFECTS OF REFORM ON GENDER EQUALITY OUTCOMES (JUMP OF 1.25)

*COLUMNS 2 & 3 OF TABLE 8 (% OF THE LABOR FORCE THAT IS FEMALE)

set seed 88

psmatch2 jump125 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, /// 
out(dflfper) common ate logit  n(1)

bootstrap r(att), r(250) : psmatch2 jump125 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, /// 
out(dflfper) common ate logit  n(1)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump125 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dflfper) common ate logit  n(2)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump125 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dflfper) common ate logit  n(3)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump125 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dflfper) common ate logit  n(4)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump125 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc ///
, out(dflfper) kernel k(normal) common ate

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


teffects nnmatch (dflfper hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump125), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(1) 

teffects nnmatch (dflfper hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump125), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(2) 

teffects nnmatch (dflfper hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump125), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(3) 

teffects nnmatch (dflfper hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump125), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(4) 


*COLUMNS 4 & 5 OF TABLE 8 (ECONOMICALLY ACTIVE FEMALES)

set seed 88

psmatch2 jump125 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, /// 
out(dflfpart) common ate logit  n(1)

bootstrap r(att), r(250) : psmatch2 jump125 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, /// 
out(dflfpart) common ate logit  n(1)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump125 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc  /// 
, out(dflfpart) common ate logit  n(2)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump125 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dflfpart) common ate logit  n(3)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump125 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dflfpart) common ate logit  n(4)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump125 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc ///
, out(dflfpart) kernel k(normal) common ate

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


teffects nnmatch (dflfpart hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump125), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(1) 

teffects nnmatch (dflfpart hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump125), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(2) 

teffects nnmatch (dflfpart hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump125), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(3) 

teffects nnmatch (dflfpart hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump125), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(4) 




*COLUMNS 6 & 7 OF TABLE 8 (FEMALE PRIMARY SCHOOLING)

set seed 88

psmatch2 jump125 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dfprimary) common ate logit  n(1)

psmatch2 jump125 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc  /// 
, out(dfprimary) common ate logit  n(1)

bootstrap r(att), r(250) : psmatch2 jump125 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dfprimary) common ate logit  n(1)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both



bootstrap r(att), r(250) : psmatch2 jump125 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dfprimary) common ate logit  n(2)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both



bootstrap r(att), r(250) : psmatch2 jump125 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dfprimary) common ate logit  n(3)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both



bootstrap r(att), r(250) : psmatch2 jump125 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc /// 
, out(dfprimary) common ate logit  n(4)

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both


bootstrap r(att), r(250) : psmatch2 jump125 hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc ///
, out(dfprimary) kernel k(normal) common ate

pstest hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc, both



teffects nnmatch (dfprimary hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump125), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(1) 

teffects nnmatch (dfprimary hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump125), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(2) 

teffects nnmatch (dfprimary hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump125), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(3) 

teffects nnmatch (dfprimary hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) (jump125), ///
biasadj(hcminus5 csh_x5 pcyminus5 csh_g5 inf5 EFW5 lvdemoc) atet nn(4) 


*/