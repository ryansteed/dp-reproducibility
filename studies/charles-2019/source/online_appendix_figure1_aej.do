capture log close
log using online_appendix_figure1_aej, replace text

// Project: Voting Paper
// Task: create online appendix firgure 1
// Author and Date: Mel Stephens, 2012-11-14

version 12.1
clear all
macro drop _all
set matsize 2000
set more off

use data/voting_paper_anes_extract.dta, clear

net from http://www.stata.com/stb/stb56
net install dm79

//------------------------------------------------------------------------------
// cleaning up
//------------------------------------------------------------------------------

// Rename variables
rename VCF0118	empstatus
rename VCF0104	gender
rename VCF0101	age
rename VCF0006a	hhid
rename VCF0004	year
rename VCF0901a	state
rename VCF0050a	poli_info
rename VCF0727	newspaper
rename VCF0726	magazine
rename VCF0725	radio
rename VCF0724	tv
rename VCF0009a	weight
rename VCF0702  votestatus
rename VCF0301  polparty

// Replace 0 with missing value
foreach i of varlist state age gender newspaper magazine tv radio {	
	replace `i' = . if `i'==0
}

// Generate dependent and independent variables
gen informed = (poli_info==1 | poli_info==2) if inlist(poli_info, 1,2,3,4,5)
gen emp = (empstatus==1) if inlist(empstatus,1,2,3,4,5)
gen agesq = age^2
gen male = (gender==1) if gender!=.

gen valid_expo = (newspaper!=. & magazine!=. & tv!=. & radio!=.)
egen total_expo = rowtotal(newspaper magazine tv radio) if valid_expo==1
gen exposed = (total_expo >= 7) if valid_expo==1

gen voted = votestatus==2 if votestatus!=0
replace polparty = . if polparty<1|polparty>7

gen pres = 0
forvalues i = 1948(4)2008 {
	replace pres = 1 if year==`i'
}

/* drop if emp==. | age==. | male==. | state==. */

//------------------------------------------------------------------------------
// FIGURE 1A
//------------------------------------------------------------------------------

/* Graph of voted by level of political information */
/* ONLY in Presidential years 1968-2004 EXCEPT 2002 */
/* Only use presidential year observations for the analysis */
replace informed = . if pres==0

/* Call the file with the graph after setting the global variables */
global outcomevar "informed"
global graphsubtitle "A. By Respondent Political Information"
global graphlegendlabel1 "Political Info High"
global graphlegendlabel2 "Political Info Low"


/* Create a dummy variable for each of the party categories in polparty */
/* which runs from strong dem (1) to independent (4) to strong repub (7) */
/* In addition, differentiate between having information and not */
/* so really a total of 14 categories */
/* The seven overall intercepts are for being in the political category */
/* The seven differences are for those in each political category */
/* AND being well informed */

for num 1/7: /*
*/ gen lack_info_reg_X =  polparty==X if ${outcomevar}!=. \ /*
*/ gen has_info_reg_X =  polparty==X&${outcomevar}==1 if ${outcomevar}!=.
sum lack_* has_*

/* Now regress whether or not voted on 14 indicators */
/* DROP the intercept term!!! */

reg voted lack_info_reg_1 lack_info_reg_2 lack_info_reg_3 lack_info_reg_4 /*
*/        lack_info_reg_5 lack_info_reg_6 lack_info_reg_7 /*
*/        has_info_reg_1 has_info_reg_2 has_info_reg_3 has_info_reg_4 /*
*/        has_info_reg_5 has_info_reg_6 has_info_reg_7 /*
*/        [pw=weight], noconstant

/* Get matrices */
/* Point estimates */
matrix polbeta = e(b)

/* Diagonal of variance-covariance matrix (i.e., variances) */
matrix polvar = vecdiag(e(V))

/* Put together with column 1 being point est. and column 2 being variances */
matrix D = polbeta', polvar'

/* Now create seven rows of four variables rather than 14 rows of two vars */
/* Column 1 political category lack info group, column 2 is its variance */
/* Column 3 political category DIFFERENCE between the has info group and */
/*   the lack info group, column 4 is its variance */
matrix newD = D[1..7,1..2],D[8..14,1..2]

/* The SVMAT2 command will put the columns of this matrix as */
/* new variables. So here we have four new variables which */
/* will be attached to the first seven observations */
/* The variables will have name of matrix plus column number */
svmat2 newD

/* Create an x-axis for the graph */
/* Already in order 1 to 7 on first seven variables */
gen xvar = _n if _n<=7

/* Get the lack information variable */
gen lack_info_graph = newD1

/* Get the has information variable */
gen has_info_graph = newD1 + newD3

/* Get the difference between the two groups */
gen diff_info_graph = newD3

/* Get the confidence interval lines on the difference */
gen upper_diff_ci_graph = newD3 + 1.96*(sqrt(newD4))
gen lower_diff_ci_graph = newD3 - 1.96*(sqrt(newD4))

/* Create a label for the x-axis */
label define polidentlabel 1 "Strong Democrat" 4 "Independent" 7 "Strong Republican"
label values xvar polidentlabel

/* Now plot the graph */
scatter has_info_graph lack_info_graph diff_info_graph  /*
*/      upper_diff_ci_graph lower_diff_ci_graph xvar if xvar>=1&xvar<=7, /*
*/      c(l l l l l) lp(l _ l - -) lwidth(medium medium medium vthin vthin) /*
*/      msymbol(d s o i i) /*
*/      pstyle(p1 p2 p3 p4 p4) /*
        Using pstyle here and repeating for last two (p4 p4) so that
        C.I. lines have same markers
*/      ytitle("Probability of Voting")  /*
*/      xtitle("Political Identity") xtick(1(1)7) /*
        For xlabel, normally use xlabel(1 4 7, valuelabel to use label 
        of x-axis variable. HOWEVER, want strong and democrat on separate
        lines so using minor axis as well.

        Hence, use xmlabel as well as xlabel.  Use labgap to put space
        between label and ticks.  Use labsize to make both labels same size.
        AND do not use valuelabel but assign names here
*/      xlabel(1 "Strong" 4 "Independent" 7 "Strong", labsize(medium)) /*
*/      xmlabel(1 "Democrat" 7 "Republican", labsize(medium) labgap(5)) /*
*/      title("${graphsubtitle}") /*
*/      legend(order(1 "${graphlegendlabel1}" 2 "${graphlegendlabel2}" 3 "Difference in Voting Prob." 4 "Difference C.I.")) /*
        Using order option for legend will ONLY show the listed values
*/      graphregion(ifcolor(white)) graphregion(fcolor(white)) /*
*/      graphregion(ilcolor(white)) graphregion(lcolor(white)) /*
*/      saving(onlineappfig1a, replace)

/* Export graph as Postscript file */
graph export onlineappfig1a.ps, replace


/* Clear matrices and variables created for this graph */
matrix drop _all
drop newD* lack_info_reg_* has_info_reg_* xvar /*
*/   lack_info_graph has_info_graph diff_info_graph /*
*/   upper_diff_ci_graph lower_diff_ci_graph
     
label drop polidentlabel


//------------------------------------------------------------------------------
// FIGURE 1B
//------------------------------------------------------------------------------
/* Graph of voted by level of index of media exposure */
/* Have Presidential years (Except 1988), non-presidential years 1982 only */
/* Only use presidential year observations for the analysis */
replace exposed=. if pres==0

/* Call the file with the graph after setting the global variables */
global outcomevar "exposed"
global graphsubtitle "B. By Respondent Media Exposure"
global graphlegendlabel1 "Media Exposure High"
global graphlegendlabel2 "Media Exposure Low"


/* Create a dummy variable for each of the party categories in polparty */
/* which runs from strong dem (1) to independent (4) to strong repub (7) */
/* In addition, differentiate between having information and not */
/* so really a total of 14 categories */
/* The seven overall intercepts are for being in the political category */
/* The seven differences are for those in each political category */
/* AND being well informed */

for num 1/7: /*
*/ gen lack_info_reg_X =  polparty==X if ${outcomevar}!=. \ /*
*/ gen has_info_reg_X =  polparty==X&${outcomevar}==1 if ${outcomevar}!=.
sum lack_* has_*

/* Now regress whether or not voted on 14 indicators */
/* DROP the intercept term!!! */

reg voted lack_info_reg_1 lack_info_reg_2 lack_info_reg_3 lack_info_reg_4 /*
*/        lack_info_reg_5 lack_info_reg_6 lack_info_reg_7 /*
*/        has_info_reg_1 has_info_reg_2 has_info_reg_3 has_info_reg_4 /*
*/        has_info_reg_5 has_info_reg_6 has_info_reg_7 /*
*/        [pw=weight], noconstant

/* Get matrices */
/* Point estimates */
matrix polbeta = e(b)

/* Diagonal of variance-covariance matrix (i.e., variances) */
matrix polvar = vecdiag(e(V))

/* Put together with column 1 being point est. and column 2 being variances */
matrix D = polbeta', polvar'

/* Now create seven rows of four variables rather than 14 rows of two vars */
/* Column 1 political category lack info group, column 2 is its variance */
/* Column 3 political category DIFFERENCE between the has info group and */
/*   the lack info group, column 4 is its variance */
matrix newD = D[1..7,1..2],D[8..14,1..2]

/* The SVMAT2 command will put the columns of this matrix as */
/* new variables. So here we have four new variables which */
/* will be attached to the first seven observations */
/* The variables will have name of matrix plus column number */
svmat2 newD

/* Create an x-axis for the graph */
/* Already in order 1 to 7 on first seven variables */
gen xvar = _n if _n<=7

/* Get the lack information variable */
gen lack_info_graph = newD1

/* Get the has information variable */
gen has_info_graph = newD1 + newD3

/* Get the difference between the two groups */
gen diff_info_graph = newD3

/* Get the confidence interval lines on the difference */
gen upper_diff_ci_graph = newD3 + 1.96*(sqrt(newD4))
gen lower_diff_ci_graph = newD3 - 1.96*(sqrt(newD4))

/* Create a label for the x-axis */
label define polidentlabel 1 "Strong Democrat" 4 "Independent" 7 "Strong Republican"
label values xvar polidentlabel

/* Now plot the graph */
scatter has_info_graph lack_info_graph diff_info_graph  /*
*/      upper_diff_ci_graph lower_diff_ci_graph xvar if xvar>=1&xvar<=7, /*
*/      c(l l l l l) lp(l _ l - -) lwidth(medium medium medium vthin vthin) /*
*/      msymbol(d s o i i) /*
*/      pstyle(p1 p2 p3 p4 p4) /*
        Using pstyle here and repeating for last two (p4 p4) so that
        C.I. lines have same markers
*/      ytitle("Probability of Voting")  /*
*/      xtitle("Political Identity") xtick(1(1)7) /*
        For xlabel, normally use xlabel(1 4 7, valuelabel to use label 
        of x-axis variable. HOWEVER, want strong and democrat on separate
        lines so using minor axis as well.

        Hence, use xmlabel as well as xlabel.  Use labgap to put space
        between label and ticks.  Use labsize to make both labels same size.
        AND do not use valuelabel but assign names here
*/      xlabel(1 "Strong" 4 "Independent" 7 "Strong", labsize(medium)) /*
*/      xmlabel(1 "Democrat" 7 "Republican", labsize(medium) labgap(5)) /*
*/      title("${graphsubtitle}") /*
*/      legend(order(1 "${graphlegendlabel1}" 2 "${graphlegendlabel2}" 3 "Difference in Voting Prob." 4 "Difference C.I.")) /*
        Using order option for legend will ONLY show the listed values
*/      graphregion(ifcolor(white)) graphregion(fcolor(white)) /*
*/      graphregion(ilcolor(white)) graphregion(lcolor(white)) /*
*/      saving(onlineappfig1b, replace)

/* Export graph as Postscript file */
graph export onlineappfig1b.ps, replace

log close
