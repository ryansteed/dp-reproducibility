/*****

*****/

clear all
set more off

if "`c(username)'" == "rfisman" {
	cd "."
}

//add these options to the end of every png export command: , width(`pngwidth') height(`pngheight')
local pngwidth = 800
local pngheight = 600
//too small: width 800, height 600


/**************************************************/
/*  Set filepath and notes/titles variables here  */
/**************************************************/
//local png_folder = ""
local png_folder = "."

local significance = "* significant at 10\%; ** significant at 5\%; *** significant at 1\%"

use data_aej.dta, clear

* these are the industries that clear the threshold for sufficient observations over sample years
global industries "all agriculture coal fire imct railway severeaccidents transportation"

* reshape data to be industry X province X date
reshape long quota reported ,i(province date) j(industry) string
g highobs=0
***highobs means we have more observations for these industries. YX noted.

foreach ind in $industries {
	replace highobs=1 if industry=="`ind'"
}

* we drop all other industries
keep if highobs==1
g counter=(year-2004)*4+quarter
**counter=number of quarters since 2004

egen provinceindno=group(province industry)
sort provinceindno counter

tsset provinceindno counter

* this limits the sample to those province-year-industry observations where we have at least the 4th quarter of data (and also the quota/reported info)
g temp=(quota~=.) & quarter==4
egen quotanonmissing=max(temp),by(province year industry)
keep if quotanonmissing==1

* finally, get rid of 2004, as data are *very* sparse and also just the first year of implementation
keep if year>2004

***since, for some provinces, quotas were reported in absolute number and in others as %, we need to add the followingnoted.***************************************************
replace quota=quota*4/quarter if property_quota=="numbers for the corresponding period"
g qrate=reported/quota
replace qrate=quota/100 if property_quota=="percentage"
replace qrate=. if qrate<0


**d_qrate=change in qrate for each quarter, so it means incremental death/total quota in this specific period.
g d_qrate=qrate if quarter==1
replace d_qrate=d.qrate if quarter~=1 & quarter==l.quarter+1
	

g l_qrate=l.qrate if quarter~=1

***at the begining of the 4th quarter, how far are we from 1.
g gap=1-l_qrate if quarter==4

* Note that reported is the # of realized deaths (cumulative)	
g ln_reported=log(reported)
	

***quota_amt: means the annual quota for this province-industry-year pair.
g quota_amt=quota if property_quota~="percentage" 
replace quota_amt=reported*100/quota if property_quota=="percentage" 


g ln_quota_amt=log(quota_amt)

***adjusted grate. for example, if the qrate=0.75 in the 3rd quarter, then qrate_adjusted=0.74*4/3=1.
g qrate_adjusted=qrate*4/quarter

***right-censoring at 1.5 for adjusted qrate.
replace qrate_adjusted=1.5 if qrate_adjusted>1.5 & qrate~=.


* topcode qrate at 2
replace qrate=2 if qrate>2 & qrate~=.

* -ve values are missing obs
drop if reported<0 & reported~=.

* now merge in NSNP data
sort province
merge province using nopromotion

drop if _m==2
g post=year>effective_year

* merge in gdp info
drop _m
sort province 

merge province using provinceid

drop _m
sort provinceid year 

merge provinceid year using province_gdp

g lgdppc=log(gdppercapita)
drop if highobs==.


* Merge in gdp target and output data
drop _m
replace province="tibet" if province=="Tibet"

sort province year quarter


preserve

use gdptarget, clear
sort province year quarter
tempfile temp
save `temp', replace

restore


merge province year quarter using `temp'
*if "`c(username)'" == "erichardy" {
*	merge province year quarter using gdptarget_stata12.dta
*}
*else {
*	merge province year quarter using gdptarget
*}
replace realgdpgrowth=realgdpgrowth/100-100
replace gdpprogress_ratio=gdpprogress_ratio/100
drop if _m==2
drop _m

* calculate # of administative areas
g admin_areas=ncities
replace admin_areas=14 if province=="beijing"
replace admin_areas=18 if province=="chongqing" 
replace admin_areas=16 if province=="shanghai"
replace admin_areas=13 if province=="tianjin"


* THIS IS THE MAIN FILE, WHICH USES ONLY INDUSTRIES/YEARS WITH WELL-POPULATED DATA, FOR THE ANALYSIS
save deathquota_short,replace

/*
* GENERATE APPENDIX TABLE A2

tab year ind if qrate~=. & quarter==4

//Table A2
estpost tab ind year if qrate != . & quarter == 4
matrix a2 = e(b)

local a2_colnames : colnames a2
//di "`a2_colnames'"
//this is a list of unique provinces
local a2_colnames_u : list uniq a2_colnames
//di "`a2_colnames_u'"
local a2_eqn : coleq a2
//di "`a2_eqn'"
local a2_eqn_u : list uniq a2_eqn
//di "`a2_eqn_u'"

//create a variable with provinces for table
gen a2_category = ""
local position = 0
foreach a2_colname in `a2_colnames_u' {
	local position = `position' + 1

	//place "all" ahead of "agriculture"
	if "`a2_colname'" == "all" {
		replace a2_category = "`a2_colname'" in 1
	}
	if "`a2_colname'" == "agriculture" {
		replace a2_category = "`a2_colname'" in 2
	}
	
	if !inlist("`a2_colname'", "all", "agriculture") {
		replace a2_category = "`a2_colname'" in `position'	
	}
}

//create empty matrices for table columns
foreach eqn in `a2_eqn_u' {
	mat a2_`eqn' = J(`position', 1, .)
}


//for each unique column equation:
	//for each element of a2
		//insert element into a1_[] matrix if element's column equation equals the unique column equation

foreach unique_eqn in `a2_eqn_u' {
	local col_position = 0
	local mat_position = 0	
	foreach col_eqn in `a2_eqn' {
		local col_position = `col_position' + 1
		if "`unique_eqn'" == "`col_eqn'" {
			local mat_position = `mat_position' + 1
			matrix a2_`unique_eqn'[`mat_position', 1] = a2[1, `col_position']
		}
	}
}

//transfer all a1_* matrices into dataset columns:
foreach eqn in `a2_eqn_u' {
	svmat a2_`eqn'
}

//capitalize category names for the table
replace a2_category = "All" if a2_category == "all"
replace a2_category = "Agriculture" if a2_category == "agriculture"
replace a2_category = "Coal" if a2_category == "coal"
replace a2_category = "Fire" if a2_category == "fire"
replace a2_category = "IMCT" if a2_category == "imct"
replace a2_category = "Railway" if a2_category == "railway"
replace a2_category = "Severe Accidents" if a2_category == "severeaccidents"
replace a2_category = "Transportation" if a2_category == "transportation"
replace a2_category = "Total" if a2_category == "total"

listtex a2_* if a2_category != "" & a2_category != "Total" using ta2.tex, replace rstyle(tabular)  ///
		head(	"\begin{table}[htbp]\centering\captionsetup{width=0.8\textwidth}\footnotesize{"  ///
				"\caption{Table A2: Availability of death data by category and year}"  ///
				"\begin{tabular}{l  r r r r r r r r r}"  ///
				"\hline\hline"  ///
				"Category     & 2005 & 2006 & 2007 & 2008 & 2009 & 2010 & 2011 & 2012 & Total \\"  ///
				"\hline")  ///
		foot(	"\\")
//this adds a space before the "Total" row
listtex	a2_* if strpos(a2_category, "Total") > 0 , appendto(ta2.tex) rstyle(tabular)  ///		
		foot(	"\hline"  ///
				"\end{tabular}}"  ///
				"\caption{Notes: Each cell lists the number of provinces (out of a possible 31) with data available in a category-year cell.}"  ///
				"\end{table}")

drop a2_*
*/
**************************************************************
* DATA FOR Table 1
**************************************************************
preserve



keep if quarter==4
bys industry: sum reported qrate 


//create blank variables for the table
levelsof industry, local(ind)
gen t1_industry = ""
foreach var of varlist reported qrate {
	foreach suffix of newlist _mean _sd _min _max _obs {
		gen t1_`var'`suffix' = .
	}
}

local position = 0
foreach i in `ind' {
	local position = `position' + 1

	if "`i'" == "all" {
		replace t1_industry = "`i'" in 1
	}
	if "`i'" == "agriculture" {
		replace t1_industry = "`i'" in 2
	}
	
	if !inlist("`i'", "all", "agriculture") {
		replace t1_industry = "`i'" in `position'	
	}
}

foreach i in `ind' {
	foreach var of varlist reported qrate {
		sum `var' if industry == "`i'"
		replace t1_`var'_obs = r(N) if t1_industry == "`i'"
		replace t1_`var'_mean = round(r(mean), .01) if t1_industry == "`i'"
		replace t1_`var'_sd = round(r(sd), .01) if t1_industry == "`i'"
		replace t1_`var'_min = round(r(min), .01) if t1_industry == "`i'"
		replace t1_`var'_max = round(r(max), .01) if t1_industry == "`i'"
	}
}

replace t1_industry = "Agriculture" if t1_industry == "agriculture"
replace t1_industry = "All" if t1_industry == "all"
replace t1_industry = "Coal" if t1_industry == "coal"
replace t1_industry = "Fire" if t1_industry == "fire"
replace t1_industry = "IMCT" if t1_industry == "imct"
replace t1_industry = "Railway" if t1_industry == "railway"
replace t1_industry = "Severe Accidents" if t1_industry == "severeaccidents"
replace t1_industry = "Road" if t1_industry == "transportation"

format t1_qrate_mean t1_qrate_sd t1_qrate_min t1_qrate_max %9.2f

gen blank = .

//03/19/2015 Table 1 output
//03/23/2015: \begin{table}[htbp] changed to \begin{table}[htbp]; should center tables vertically on the page

local notes_1 = "The upper rows provide summary statistics on year-end accidental deaths in each listed category at the province-level."
local notes_2 = "The lower rows provide summary statistics on the year-end ratio of reported deaths to the government mandated death ceiling."
local notes_3 = "The IMCT category includes workplace deaths in industrials, non-coal mining, commercial, and trade; severe accidents are deaths in accidents that involve three or more fatalities."
local notes_4 = "Other death categories are self-explanatory (see text for details)."


listtex t1_industry blank t1_reported_* if t1_industry != ""  using t1.tex, replace rstyle(tabular)  ///
		head(	"\begin{table}[htbp]\centering\captionsetup{width=0.8\textwidth}\footnotesize{"  ///
				"\caption{Table 1: Deaths at the province-year level by category, 2005-2012}"  ///
				"\begin{tabular}{l r  r r r r r }"  ///
				"\hline\hline"  ///
				"         & & Mean & StdDev & Min & Max & Obs \\"  ///
				"\hline"  ///
				" & & \multicolumn{5}{c}{$ Deaths_{cpy} $ } \\") ///
				
//06/22/2016: put "second" set of 5 columns below, so the table does not exceed 9 columns
listtex t1_industry blank t1_qrate_* if t1_industry != "" using t1b_aej.tex, replace rstyle(tabular)  ///
		head(	"\\"  ///
				" & & \multicolumn{5}{c}{ $ Deaths_{cpy} / Ceiling_{cpy} $ } \\")  ///
		foot(	"\hline"  ///
				"\end{tabular}}"  ///
				"\caption{Notes: `notes_1' `notes_2' `notes_3' `notes_4'}"  ///
				"\end{table}")
				
drop t1_*	




restore

/****************************************************/

**************************************************************
* FIGURE 1, A1
**************************************************************
* now, the 'formal' version
* based on mccrary test
* thanks to Eric Hardy for coding this!!!
* in the file it's currently for 'all' but you get the same pattern for any other 'big' industry

/*****
deaths.do
Determine whether there is a discontinuity in the distribution of deaths
around the officially mandated maximum death number 
using the McCrary density test      

for DCdensity:
b() binsize
h() "second-step linear smoother" (bandwidth)

test estimates capital_theta_hat, with a "proposition standard error".  then do a t-test.  

to look at underreporting, assume:
given a yearly quota, people may be less likely to under-report in the first quarter
slightly more likely in the second quarter, and so on.  Then companies who in the third
quarter are closest to their cutoff points should be 

http://eml.berkeley.edu/~jmccrary/DCdensity/

*****/

clear all
set more off
use deathquota_short.dta, clear
local graphnames = ""

preserve

//  eric 09/25/2015: the subsequent line was commented out with a / *, causing figures 3 and 4 to not be produced
//  eric 02/13/2015: comment out for now, it slows things down

//  eric 09/26/2015: try to understand scatterplot from DCdensity

//from graph command: (scatter `cellvalname' `cellmpname', msymbol(circle_hollow) mcolor(gray))

  //   inputs: runvar - name of stata running variable ("R" in McCrary (2008))
  //             tousevar - name of variable indicating which obs to use
  //             c - point of potential discontinuity
  //             b - bin size entered by user (zero if default is to be used)
  //             h - bandwidth entered by user (zero if default is to be used)
  //             verbose - flag for extra messages printing to screen
  //             cellmpname - name of new variable that will hold the histogram cell midpoints
  //             cellvalname - name of new variable that will hold the histogram values
  //             evalname - name of new variable that will hold locations where the histogram smoothing was
  //                        evaluated
  //             cellsmname - name of new variable that will hold the smoothed histogram cell values
  //             cellsmsename - name of new variable that will hold standard errors for smoothed histogram cells
  //             atname - name of existing stata variable holding points at which to eval smoothed histogram


//integrate to 1 test:
/*
di (1*10 + 2.5*7 + 5*4 + 8*9 + 13*1     +    1*7) /.007786155

.007786155
*/



file open fa1 using "fa1.tex", write replace

file write fa1 "\begin{figure}[htbp]" _n
file write fa1 "\begin{center}" _n
file write fa1 "Figure A1: McCrary density tests for $ Deaths_{cpy} / Ceiling_{cpy} $ for province-year level accidental deaths, by category \\" _n
file write fa1 "\end{center}" _n
file write fa1 "\end{figure}" _n

label variable qrate "Deaths / Ceiling"
//list of industries: 
//

//Figure 1/2 Notes
local f1_notes_1 = "The figure provides a histogram of the ratio of overall reported accidental deaths to the government-mandated ceiling, for province-year observations during 2005-2012."
local f2_notes_1 = "The figure provides McCrary's density test for discontinuity in the distribution at 1, for the ratio of overall reported accidental deaths to the government-mandated ceiling." 
local f2_notes_2 = "The sample includes province-year observations during 2005-2012.."
local f2_notes_3 = "The bold line shows the local linear regression estimated on either side of 1, and the lighter lines show the 90 percent confidence interval."
local f2_notes_4 = "The t-statistic for the significance of the discontinuity at 1 is listed just below the graph."

//Figure A1 notes
local fa1_notes_1 = "Each panel shows a McCrary density test for discontinuity in the distribution of $ Deaths_{cpy} / Ceiling_{cpy} $ at 1 for a separate category of accidental deaths. "
local fa1_notes_2 = "In each case, the bold line shows the local linear regression estimated on either side of 1, and the lighter lines show the 90 percent confidence interval."
local fa1_notes_3 = "The t-statistic for the significance of the discontinuity at 1 is listed below each panel."
/*
local position = 0
foreach ind in $industries {
//local position = 
//tab industry
//twoway	(DCdensity qrate if quarter == 4 & industry == "`ind'" , breakpoint(1.0001) generate(xx yy rr fhat se_fhat) graphname(qrate_mcc_`ind'.png)),  ///
//		graphregion(fcolor(white) lcolor(white) color(white)) legend(region(lcolor(white)))
//DCdensity qrate if quarter == 4 & industry == "`ind'" & qrate > .60001, breakpoint(1.00001) generate(xx yy rr fhat se_fhat) graphname(qrate_mcc_`ind'.png)
//eric 09/26/2015: retrieve binsize to coordinate scatterplots
local binsize = r(binsize)

local theta = r(theta)
local se_theta = r(se)
local t_stat = round(`theta'/`se_theta', .001)
di "`t_stat'"

drop yy xx rr fhat se_fhat

// eric 09/25/2015: added "& qrate > .600001" to get around the following error:
//option start() may not be larger than minimum of qrate

//starting at the breakpoint of 1.00001, and using bins of width `binsize', find the first bin starting at less than .6.
local startbins = 1 - ceil((1.00001 - .60001) / `binsize')* `binsize'

twoway	(hist qrate if quarter == 4 & industry == "`ind'" & qrate > `startbins', start(`startbins') /*freq*/ width(`binsize')),  ///
		/*xline(1)*/  ///
		/*title("McCrary Density Test t-stat: `t_stat'")*/  ///
		graphregion(fcolor(white) lcolor(white) color(white)) legend(region(lcolor(white)))
graph export qrate_`ind'.png, replace width(`pngwidth') height(`pngheight')


//test histograms
twoway	(hist qrate if quarter == 4 & industry == "`ind'" , width(.007786155)),  ///
		graphregion(fcolor(white) lcolor(white) color(white)) legend(region(lcolor(white)))
graph export comparison.png, replace width(`pngwidth') height(`pngheight')





//write to Figure 1,2 file for "all" 
if "`ind'" == "all" {
	
	file open f1 using "f1.tex", write replace
	file write f1 "\begin{figure}[htbp]" _n
	file write f1 "\captionsetup{width=0.8\textwidth}" _n
	file write f1 "\begin{center}" _n
	file write f1 "Figure 1: Histogram for $ Deaths_{cpy} / Ceiling_{cpy} $ for overall province-year level accidental deaths \\" _n
	file write f1 "\includegraphics[scale=\fullscale]{`png_folder'qrate_all.png}\\" _n
	file write f1 "\end{center}" _n
	file write f1 "\caption{Notes: `f1_notes_1' }" _n
	file write f1 "\end{figure}" _n
	file close f1

	file open f2 using "f2.tex", write replace
	file write f2 "\begin{figure}[htbp]" _n
	file write f2 "\captionsetup{width=0.8\textwidth}" _n
	file write f2 "\begin{center}" _n
	file write f2 "Figure 2: McCrary density test for $ Deaths_{cpy} / Ceiling_{cpy} $ for overall province-year level accidental deaths \\" _n
	
	file write f2 "\includegraphics[scale=\fullscale]{`png_folder'qrate_mcc_all.png}\\" _n
	file write f2 "McCrary Density Test (t-stat: `t_stat')\\" _n
	file write f2 "\end{center}" _n
	file write f2 "\caption{Notes: `f2_notes_1' `f2_notes_2' `f2_notes_4' `f2_notes_4' }" _n
	file write f2 "\end{figure}" _n
	file close f2
}
if "`ind'" != "all" {
	if "`ind'" == "agriculture" {
		local title_ind = "Agriculture"
		local panel = "A"
	}
	if "`ind'" == "coal" {
		local title_ind = "Coal"
		local panel = "B"
	}
	if "`ind'" == "fire" {
		local title_ind = "Fire"
		local panel = "C"
	}
	if "`ind'" == "imct" {
		local title_ind = "IMCT"
		local panel = "D"
	}
	if "`ind'" == "railway" {
		local title_ind = "Railways"
		local panel = "E"
	}
	if "`ind'" == "severeaccidents" {
		local title_ind = "Severe Accidents"
		local panel = "F"
	}
	if "`ind'" == "transportation" {
		local title_ind = "Road"
		local panel = "G"
	}
	
	file write fa1 "\begin{figure}[htbp]" _n
	file write fa1 "\begin{center}" _n
	file write fa1 "\includegraphics[scale=\fscale]{`png_folder'qrate_mcc_`ind'.png}\\" _n
	file write fa1 "Category: `title_ind' \\" _n
	file write fa1 "McCrary Density Test t-stat: `t_stat' \\" _n
	file write fa1 "\end{center}" _n
	file write fa1 "\end{figure}" _n
	
}	
}  //foreach ind in $industries 

file write fa1 "\begin{figure}[htbp]" _n
file write fa1 "\captionsetup{width=0.8\textwidth}" _n
file write fa1 "\begin{center}" _n
file write fa1 "\caption{Notes: `fa1_notes_1' `fa1_notes_2' `fa1_notes_3' }" _n
file write fa1 "\end{center}" _n
file write fa1 "\end{figure}" _n
file close fa1
restore

*************************************************
* APPENDIX FIGURES A2
*************************************************

label variable qrate "Deaths / Ceiling"
foreach ind in $industries {
	foreach q in 3 {
		if "`ind'" == "agriculture" {
			local title_ind = "Agriculture"
		}
		if "`ind'" == "coal" {
			local title_ind = "Coal"
		}
		if "`ind'" == "fire" {
			local title_ind = "Fire"
		}
		if "`ind'" == "imct" {
			local title_ind = "IMCT"
		}
		if "`ind'" == "railway" {
			local title_ind = "Railways"
		}
		if "`ind'" == "severeaccidents" {
			local title_ind = "Severe Accidents"
		}
		if "`ind'" == "transportation" {
			local title_ind = "Road"
		}
		if "`ind'" == "all" {
			local title_ind = "All"
		}
	
		twoway	(histogram qrate if industry=="`ind'" & quarter==`q' & qrate>=0.34 & qrate<1 , start(0.34) width(0.01)),  ///
				title("Category: `title_ind'")  ///
				graphregion(fcolor(white) lcolor(white) color(white)) legend(region(lcolor(white)))
		graph export qrate_`ind'_q`q'.png,replace width(`pngwidth') height(`pngheight')
	}
}

file open fa2 using "fa2.tex", write replace
file write fa2 "\begin{figure}[htbp]" _n
file write fa2 "\begin{center}" _n
file write fa2 "Appendix Figure A2: Histograms of Death/Ceiling Ratios by Category \\" _n
file write fa2 "\end{center}" _n
file write fa2 "\end{figure}" _n

//put a latex line break (\\) after every second industry
local position = 0
foreach ind in $industries {
	
	file write fa2 "\begin{figure}[htbp]" _n
	file write fa2 "\begin{center}" _n
	file write fa2 "\includegraphics[scale=\fscale]{`png_folder'qrate_`ind'_q3.png}\\" _n
	file write fa2 "\end{center}" _n
	file write fa2 "\end{figure}" _n
	
}

file write fa2 "\begin{figure}[htbp]" _n
file write fa2 "\captionsetup{width=0.8\textwidth}" _n
file write fa2 "\begin{center}" _n
file write fa2 "\caption{Notes: Each figure shows a histogram of the ratio of overall reported accidental deaths to the end of the third quarter of the year to the government-mandated year-end ceiling, for province-year observations during 2005-2012.}" _n
file write fa2 "\end{center}" _n
file write fa2 "\end{figure}" _n
file close fa2



 
use deathquota_short,replace
keep if qrate~=.

* One final variable to be generated - is there any within-province variation in "no safety, no promotion"?
egen varpost=sd(post),by(province)
replace varpost=sign(varpost)
*/

*****************************************
* TABLE 2
*****************************************

egen provinceind=group(province industry)
g exceedquota=qrate>1 if qrate~=. & quarter==4

egen yi=group(industry year)

g gdpprogress_above=gdpprogress_ratio>=1 if gdpprogress_ratio~=.
label variable post " $ NSNP_{py} $ "
label variable gdpprogress_ratio " $ GDP_{py}/GDPTarget_{py} $ " 
label variable gdpprogress_above "$ I(GDP_{py} \geq GDPTarget_{py}) $ " 
local png_folder = "../"

*preserve

foreach var in exceedquota {
	eststo: xi: areg `var' post i.year i.industry if quarter==4 , absorb(province) cluster(province)
	eststo t2_`var'_1
	egen var_post = var(post), by(province)
	xi: areg `var' post i.year i.industry if quarter==4 & var_post > 0, absorb(province) cluster(province)
	eststo t2_`var'_2
	xi: areg `var' post gdpprogress_ratio i.year i.industry if quarter==4 & var_post>0, absorb(province) cluster(province)
	eststo t2_`var'_3
	xi: areg `var' post gdpprogress_ratio i.yi if quarter==4 & var_post>0 , absorb(provinceind) cluster(province)
	eststo t2_`var'_4
}
*** EDITED by Ryan
estout using "../../results/table.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
save final1.dta, replace
***
* JUST FOR INTEREST
foreach var in qrate {
	xi: areg `var' post i.year i.industry if quarter==4 , absorb(province) cluster(province)
	eststo t2_`var'_1
	egen var_post_1 = var(post), by(province)
	xi: areg `var' post i.year i.industry if quarter==4 & var_post_1>0, absorb(province) cluster(province)
	eststo t2_`var'_2
	xi: areg `var' post gdpprogress_ratio i.year i.industry if quarter==4 & var_post_1>0, absorb(province) cluster(province)
	eststo t2_`var'_3
	xi: areg `var' post gdpprogress_ratio i.yi if quarter==4 & var_post_1>0 , absorb(provinceind) cluster(province)
	eststo t2_`var'_4
}

//Table 2 Notes
local notes_1 = "Standard Errors clustered at the province level."
local notes_2 = "All analyses use province-year level data for the sample period 2005-2012."
local notes_3 = "The dependent variable in all columns an indicator variable denoting whether $ Deaths_{cpy}/Ceiling_{cpy} $ (strictly) exceeds one."
local notes_4 = "NSNP is an indicator variable denoting whether the province has passed \enquote{No safety, no promotion} legislation by year \emph{y}."
local notes_5 = "See text for additional details on variable construction and definitions."
local notes_6 = "The $ Var(NSNP) > 0 $ sample is the set of 15 provinces that passed NSNP legislation during the sample period 2005-2012 (and hence have within-province variation in NSNP)."

//03/20/2015: remove constants
//03/23/2015: replace \begin{table}[htbp] with \begin{table}[htbp]
esttab t2_exceedquota_*  ///
using t2.tex, replace  ///
star(* 0.10 ** 0.05 *** 0.01) /*plain*/ nogaps   ///
nodepvars b(%9.3f) legend noabbrev style(tex) constant   ///
title("Table 2: No safety, no promotion laws and accidental deaths")   ///
label stats(N r2_a, fmt(%9.0g %9.3f) labels("Observations" "Adjusted R-Squared")) se  ///
order(post gdpprogress_ratio /*_cons*/)    ///
keep(post gdpprogress_ratio /*_cons*/)     ///
nomtitles  ///
posthead("Dependent Variable & \multicolumn{4}{c}{ $ I(Deaths_{cpy} > Ceiling_{cpy}) $ }  \\"  ///
		"\hline")  ///
prefoot("\hline" ///
		"Category and Year FEs            & Yes & Yes & Yes & No  \\"  ///
		"Province FEs                     & Yes & Yes & Yes & No  \\"  ///
		"Cat. $ \times $ Year FEs     & No  & No  & No  & Yes \\"  ///
		"Cat. $ \times $ Province FEs & No  & No  & No  & Yes \\"  ///
		"\hline"  ///
		"Full Sample                      & Yes & No  & No  & No  \\"  ///
		" $ Var(NSNP)>0 $ Sample          & No  & Yes & Yes & Yes \\"  ///
		"\hline")  ///
nonotes ///
postfoot(	"\hline\hline" ///
			"\end{tabular}}"  ///
			"\caption{Notes: `notes_1' `notes_2' `notes_3' `notes_4' `notes_5' `notes_6' `significance'. }"  ///
			"\end{table}")  ///
substitute(	\begin{table}[htbp]\centering \begin{table}[htbp]\centering\captionsetup{width=0.8\textwidth}\footnotesize{ )

restore

*****************************************
* FIGURE 3
*****************************************
* show cdf for post=0 vs post=1
preserve
keep if quarter==4 
local cdfvar "qrate"

//03/19/2015
label variable qrate "Deaths/Ceiling"

g pre=1-post
cumul `cdfvar' if pre==1, gen(prevar) equal
label var prevar "NSNP=0"
cumul `cdfvar' if post==1, gen(postvar) equal
label var postvar "NSNP=1"
twoway 	(line prevar `cdfvar' if `cdfvar', sort connect(stairstep) lcolor(dknavy)) ///
		(line postvar `cdfvar' if `cdfvar', sort connect(stairstep) lcolor(dkgreen) lpattern(longdash)), ///
		legend(textfirst rows(2)) ///
		xlabel(0(0.1)1.5) ///
		ytitle("Cumulative Probability") legend(rows(1)) ///
		graphregion(fcolor(white) lcolor(white) color(white)) legend(region(lcolor(white)))
graph export "cdf-`cdfvar'-by-sample.png", replace width(`pngwidth') height(`pngheight')

local f3_notes_1 = "Each line shows a cumulative density function for the ratio of reported deaths to government-mandated ceiling, $ Deaths_{cpy} / Ceiling_{cpy} $ .  "
local f3_notes_2 = "The solid line employs data from province-year observations where \enquote{No safety, no promotion} legislation had been passed (NSNP=0), while the dashed line employs observations where such legislation was in place (NSNP=1)."

file open f3 using "f3.tex", write replace
file write f3 "\begin{figure}[htbp]" _n
file write f3 "\captionsetup{width=0.8\textwidth}" _n
file write f3 "\begin{center}" _n
file write f3 "Figure 3: Pre vs Post-NSNP Cumulative density function of $ Deaths_{cpy} / Ceiling_{cpy} $ \\" _n
file write f3 "\includegraphics[scale=\fullscale]{`png_folder'cdf-qrate-by-sample.png}" _n
file write f3 "\end{center}" _n
file write f3 "\caption{Notes: `f3_notes_1' `f3_notes_2' }" _n
file write f3 "\end{figure}" _n
file close f3

restore



//*/
*****************************************************
* We now turn to the question of quota-setting
* that is, does "performance" in t-1 affect how the quota is set the following year
* (probably we should add some output controls(?)
*****************************************************



use deathquota_short,replace
keep if quarter==4
egen yi=group(year industry)
egen py=group(province year)
tsset provinceind year

g ln_reported_lag=l.ln_reported


****************************************
* Figure 4
****************************************
//scatter ln_quota_amt ln_reported_lag

label variable ln_quota_amt "log(Ceiling)"
label variable ln_reported_lag "log(Deaths) lagged 1 year"

//to get smaller points: vsmall, tiny, vtiny
twoway	(scatter ln_quota_amt ln_reported_lag, msize(small)),  ///
		graphregion(fcolor(white) lcolor(white) color(white)) legend(region(lcolor(white)))
graph export f4.png, replace width(`pngwidth') height(`pngheight')

local f4_notes_1 = "The graph uses data from all category-year-province observations during 2005-2012."
local f4_notes_2 = "It shows the relationship between the natural logarithm of reported deaths in year $ y-1 $ and the natural logarithm of the death ceiling in year $ y $ ."


file open f4 using "f4.tex", write replace
file write f4 "\begin{figure}[htbp]" _n
file write f4 "\captionsetup{width=0.8\textwidth}" _n
file write f4 "\begin{center}" _n
file write f4 "Figure 4: Relationship between lagged reported deaths and current death ceiling\\" _n
file write f4 "\includegraphics[scale=\fullscale]{`png_folder'f4.png}" _n
file write f4 "\end{center}" _n
file write f4 "\caption{Notes: `f4_notes_1' `f4_notes_2' }" _n
file write f4 "\end{figure}" _n
file close f4



****************************************
* TABLE 3
****************************************
gen ln_quota_amt_1lag = l.ln_quota_amt
gen exceedquota_lag = (l.qrate)>1 if l.qrate~=.

gen ln_reported_exceedquota_x_lag = exceedquota_lag * ln_reported_lag

label variable ln_quota_amt " $ log(Ceiling_{cpy}) $ "
label variable ln_quota_amt_1lag " $ log(Ceiling_{cpy-1}) $ "
label variable ln_reported_lag " $ log(Deaths_{cpy-1}) $ "
label variable ln_reported_exceedquota_x_lag " $ I(Deaths_{cpy-1}>Ceiling_{cpy-1}) * log(Deaths_{cpy-1}) $ " 
label variable exceedquota_lag " $ I(Deaths_{cpy-1}>Ceiling_{cpy-1}) $ "

xi: areg ln_quota_amt ln_reported_lag                    i.yi i.py, absorb(provinceind) cluster(province)
eststo t3_1
xi: areg ln_quota_amt                 ln_quota_amt_1lag  i.yi i.py, absorb(provinceind) cluster(province)
eststo t3_2
xi: areg ln_quota_amt ln_reported_lag ln_quota_amt_1lag  i.yi i.py, absorb(provinceind) cluster(province)
eststo t3_3
xi: areg ln_quota_amt ln_reported_lag ln_quota_amt_1lag exceedquota_lag ln_reported_exceedquota_x_lag  ///
														 i.yi i.py, absorb(provinceind) cluster(province)
eststo t3_4
*** EDITED by Ryan
estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
save final2.dta, replace
***
//Table 3 Notes
local notes_0 = "Standard Errors clustered at the province level."
local notes_1 = "All analyses use province-year level data for the sample period 2005-2012."
local notes_2 = "The dependent variable, $ log(Ceiling_{cpy}) $ is the natural logarithm of province \emph{p}'s assigned death ceiling in category \emph{c} and year \emph{y}, while $ log(Ceiling_{cpy-1}) $ is the lagged value of this variable."
local notes_3 = " $ log(Deaths_{cpy-1} )$ is the lagged value of the natural logarithm of reported deaths."
local notes_4 = "$ I(Deaths_{cpy} > Ceiling_{cpi}) $ is an indicator variable denoting whether reported deaths exceed the mandated ceiling in year $ y-1 $ . "


esttab t3_1 t3_2 t3_3 t3_4 ///
using t3.tex, replace  ///
star(* 0.10 ** 0.05 *** 0.01) /*plain*/ nogaps   ///
nodepvars b(%9.3f) legend noabbrev style(tex) constant   ///
title("Table 3: Determinants of death ceilings")   ///
label stats(N r2_a, fmt(%9.0g %9.3f) labels("Observations" "Adjusted R-Squared")) se  ///
order(ln_reported_lag ln_quota_amt_1lag exceedquota_lag ln_reported_exceedquota_x_lag /*_cons*/)    ///
keep(ln_reported_lag ln_quota_amt_1lag exceedquota_lag ln_reported_exceedquota_x_lag  /*_cons*/)     ///
nomtitles  ///
posthead("Dependent Variable & \multicolumn{4}{c}{ $ log(Ceiling_{cpy}) $ }  \\"  ///		
		"\hline")  ///
prefoot("\hline" ///
		"Category $ \times $ Year FEs     & Yes & Yes & Yes & Yes \\"  ///
		"Province $ \times $ Year FEs     & Yes & Yes & Yes & Yes \\"  ///
		"Province $ \times $ Cat. FEs & Yes & Yes & Yes & Yes \\"  ///
		"\hline")  ///
nonotes ///
postfoot(	"\hline\hline" ///
			"\end{tabular}}"  ///
			"\caption{Notes: `notes_0' `notes_1' `notes_2' `notes_3' `notes_4' `significance'. }"  ///
			"\end{table}")  ///
substitute(	\begin{table}[htbp]\centering \begin{table}[htbp]\centering\captionsetup{width=0.8\textwidth}\footnotesize{ )



*****************************************
* Figure 5 
*****************************************

use provincedeath_imct_1993_2012_final.dta, clear
tsset provinceid year
g death_growth=industrialdeaths/l.industrialdeaths-1

* topcode death_growth at 1, -0.5
replace death_growth=1 if death_growth>1 & death_growth~=.
replace death_growth=-1 if death_growth<-1 & death_growth~=.

local graphnames = ""
g post=year>=2005
g pre=1-post

* show cdf for pre vs post2004
preserve
local cdfvar "death_growth"
cumul `cdfvar' if pre==1, gen(prevar) equal
label var prevar "pre-2004"
cumul `cdfvar' if post==1, gen(postvar) equal
label var postvar "post-2004"
twoway 	(line prevar `cdfvar' if `cdfvar', sort connect(stairstep) lcolor(dknavy)) ///
		(line postvar `cdfvar' if `cdfvar', sort connect(stairstep) lcolor(dkgreen) lpattern(longdash)), ///
		legend(textfirst rows(1))  ///
		xlabel(-0.5(0.1)1) xtitle("Percent Change in Deaths", margin(small)) ytitle("Cumulative Probability") ///
		graphregion(fcolor(white) lcolor(white) color(white)) legend(region(lcolor(white)))
graph export "cdf-`cdfvar'-by-sample.png",replace width(`pngwidth') height(`pngheight')

local f5_notes_1 = "The graph depicts cumulative density functions for the annual change in accidental deaths, at the province-level, for industrial, non-coal mining, construction, and trade (IMCT) for the years 1993-1997, 1999-2003, and 2005-2012."
local f5_notes_2 = "We split the sample by 2004, the year of implementation of death ceilings."
local f5_notes_3 = "See Section 2 for details on the variable definition and sources."

file open f5 using "f5.tex", write replace 
file write f5 "\begin{figure}[htbp]" _n
file write f5 "\captionsetup{width=0.8\textwidth}" _n
file write f5 "\begin{center}" _n
file write f5 "Figure 5: Pre vs. post-2004 cumulative distribution of Percent Change in Deaths for IMCT category \\" _n
file write f5 "\includegraphics[scale=\fullscale]{`png_folder'cdf-death_growth-by-sample.png}" _n
file write f5 "\end{center}" _n
file write f5 "\caption{Notes: `f5_notes_1' `f5_notes_2' `f5_notes_3' }" _n
file write f5 "\end{figure}" _n
file close f5

restore


/***********************************************************************/
/*  Table A1: Instatement of no safety, no promotion laws              */
/*  Code imported from bottom of accident_tables_091714.do             */
/***********************************************************************/

/*
// import Table A1 from Tables - rf1.xlsx
import excel using "Tables - rf1.xlsx", sheet("Table A1") clear firstrow
drop Deaths Firmyearobs

//drop notes
drop if _n == 32
rename *, lower
compress

//format dates
replace effectivedate = substr(effectivedate, 1, 2) + "-" + substr(effectivedate, 3, 3) + "-" + substr(effectivedate, 6, 4) if effectivedate != "No safety quota"
replace passagedate = substr(passagedate, 1, 2) + "-" + substr(passagedate, 3, 3) + "-" + substr(passagedate, 6, 4) if passagedate != "No safety quota"

//upper case months
replace effectivedate = substr(effectivedate, 1, 3) + strupper(substr(effectivedate, 4, 1)) + substr(effectivedate, 5, .) if  effectivedate != "No safety quota"
replace passagedate = substr(passagedate, 1, 3) + strupper(substr(passagedate, 4, 1)) + substr(passagedate, 5, .) if passagedate != "No safety quota"

local notes_1 = "In response to the 2004 death ceiling policy, provinces began adopting \enquote{no safety, no promotion} (NSNP) policies that made promotion of safety regulators and other local government officials contingent on meeting "
local notes_2 = "the safety production target set for their province by the provincial government."
local notes_3 = "The first two columns list the dates of NSNP legislation passage and implementation respectively."
local notes_4 = "Both population and income figures are obtained from CSMAR Regioual Economy Database."


//03/23/2015: replace \begin{table}[htbp] with \begin{table}[htbp]
listtex * using ta1.tex, replace rstyle(tabular) ///
		head(	"\begin{table}[htbp]\centering\captionsetup{width=0.8\textwidth}\footnotesize{"  ///
				"\caption{Table A1: Instatement of \enquote{no safety, no promotion} laws by province}"  ///
				"\begin{tabular}{l c c c c}"  ///
				"\hline\hline"  ///
				"Province & Effective Date & Passage Date & Population in 2005 & GDP per capita in 2005\\"  ///
				"         &                &              & (unit: 10,000)     & (unit: 1 RMB)         \\"  ///
				"\hline")  ///
		foot(	"\hline"  ///
				"\end{tabular}}"  ///
				"\caption{Notes: `notes_1' `notes_2' `notes_3' `notes_4'}"  ///
				"\end{table}")
*/