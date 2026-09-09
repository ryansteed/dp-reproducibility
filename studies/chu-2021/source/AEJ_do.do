* The data for this "Hometown Ties and the Quality of Government Monitoring: Evidence from Rotation of Chinese Auditors" may be accessed at:

* Project 
* https://www.openicpsr.org/openicpsr/project/

clear
set more off

if "`c(username)'" == "user" {
	cd "directory"
	use "directory\AEJ_main.dta", clear
}

* Install packages required to execute the program
// capture ssc install estout
capture ssc install listtex
// capture ssc install reghdfe
capture ssc install ftools

use "AEJ_main", clear 

gen samecity=home_city==birthcity_citys|home_city==birthcity_cityg
label var samecity "City Leader Hometown"
gen tenure2=tenure^2
gen lnpop=log(pop)

********************************************************************************
*	Prepare
********************************************************************************

gen icity=city

* average variables for mayor and party secretary
gen tenure_gs=(tenure_cityg + tenure_citys)/2
gen age_gs=(age_cityg+age_citys)/2
gen lnage_gs=log(age_gs)

* whether the auditor was born in the same province as the focal (city's) province.
gen provincetie=home_prov==province

* measures of whether city is hometown for provincial leaders
gen isgovernorhome=birthcity_provg==city
gen isprovpartysecretaryhome=birthcity_provs==city

* Ratio of audits to government budget
gen susp_to_exp=exp(violate3)/(govbal*exp(lngovrev))
gen exp_to_gdp=(govbal*exp(lngovrev))/(exp(lngdp)*pop)

* Years the National Audit Office audits local finances
gen nao=year==2011|year==2013
gen post2013=year>=2013

label var id "name id"
label var province "province id"
label var city "city id"
label var num3 "ln(number of projects audited)"
label var violate1 "ln(total questionable expenditures found during the audit/number of audited projects)"
label var violate3 "ln(total questionable expenditures found during the audit)"
label var local_city "whether the chief auditor of the province was born in the focal city"
label var male "gender of the chief auditor"
label var age "age of the chief auditor"
label var tenure "tenure of the chief auditor"
label var tenure2 "\(\rm Tenure^2 \)"
label var edufin "whether the chief auditor has finance bakground"
label var edulevel "education of the chief auditor: 4 for doctor, 3 for master, 2 for bachelor, 1 for collage or lower level"
label var fromaud "was the chief working in the auditing department before? "
label var fromfin "was the chief working in the Finance/taxation department before? "
label var fromsup "was the chief working in the discplining department before? "
label var fromcitygov "was the cheif working in the general office before (for example, city mayor et.al.) "
label var lngdppc "ln(GDP per capita)"
label var sec "the ratio of industrial output to total GDP"
label var lngovrev "ln(fiscal revenue of the city)"
label var govbalance "fiscal expenditure/fiscal income of the city"
label var finv "city FDI/GDP"
label var edu "average education level of the province"
label var lnpop "ln(population, unit: 10k)"
label var tenure_gs "average trnure for mayor and party secretary"
label var age_gs "average age for mayor and party secretary"
label var lnage_gs "ln(average age for mayor and party secretary)"
label var provincetie "whether the auditor was born in the same province as the focal (city's) province"
label var isgovernorhome "the focal city is the provincial governor's hometown"
label var isprovpartysecretaryhome "the focal city is provincial party secretary's hometown"
label var susp_to_exp "total questionable expenditures found during the audit / fiscal expenditure"
label var exp_to_gdp "fiscal expenditure / gdp"
label var post2013 "whether the year is greater than or equal to 2013"
label var nao "years the National Audit Office audits local finances (2011 or 2013)"

* Control variables defined that will be used throughout
global auditorvar "male age tenure tenure2 edulevel edufin fromaud fromfin fromsup fromcitygov" 
global cityvar "lngdppc sec lnpop lngovrev govbalance finv edu "
global allvar "$auditorvar $cityvar"

/*
********************************************************************************
* Figure 1: The Organization of Chinese Audits
********************************************************************************
file open f1 using "tables/f1.tex", write replace
file write f1 "\begin{figure}[p]\captionsetup{justification=justified,singlelinecheck=false,width=\textwidth,labelformat=empty}" _n
file write f1 "\begin{center}" _n
file write f1 "Figure 1: The Organization of Chinese Audits" _n
file write f1 "\includegraphics[width=0.6\textwidth,trim=0 0 45 0,clip]{tables/f1.png}" _n
file write f1 "\end{center}" _n
file write f1 "\end{figure}" _n
file close f1

********************************************************************************
* Figure 2a: The Distribution of log(SuspiciousExpenditures per Audit) across Years
********************************************************************************

preserve 
collapse (mean) violate1 (semean) se_y =violate1, by(year )
gen y_l = violate1 - se_y*1.96
gen y_u = violate1 + se_y*1.96
tw (rarea y_u y_l year , sort color(ltblue*.5)) (connected violate1 year , sort lcolor(blue)) , legend(off) ytitle("log(Suspicious Expenditures per Audit)") xtitle("Year")
graph export tables/f2a.png, replace width(`pngwidth') height(`pngheight')

local notes_f2a_1 = "This figure shows the distribution of $ log(SuspiciousExpenditures \, per \, Audit) $ across the years in our sample."
local notes_f2a_2 = "Each dot indicates the average of $ log(SuspiciousExpenditures \, per \, Audit) $."
local notes_f2a_3 = "The shaded area shows the 95 percent confidence interval."

file open f2a using "tables/f2a.tex", write replace
file write f2a "\begin{figure}[p]\captionsetup{justification=justified,singlelinecheck=false,width=\textwidth,labelformat=empty}" _n
file write f2a "\begin{center}" _n
file write f2a "Figure 2a: The Distribution of log(SuspiciousExpenditures per Audit) across Years" _n
file write f2a "\includegraphics[width=\textwidth]{tables/f2a.png}" _n
file write f2a "\end{center}" _n
file write f2a "\begin{figurenotes}" _n
file write f2a "`notes_f2a_1' `notes_f2a_2' `notes_f2a_3'" _n
file write f2a "\end{figurenotes}" _n
file write f2a "\end{figure}" _n
file close f2a
restore 

********************************************************************************
* Figure 2b: The Distribution of Auditor Background across Years
********************************************************************************

preserve 
collapse (mean) fromaud (semean) se_y1 =fromaud (mean) fromcity (semean) se_y2 =fromcity, by(year )
gen y1_l = fromaud - se_y1*1.96
gen y1_u = fromaud + se_y1*1.96

gen y2_l = fromcity - se_y2*1.96
gen y2_u = fromcity + se_y2*1.96

tw	(rarea y1_u y1_l year , sort color(ltblue*.5)) (rarea y2_u y2_l year , sort color(orange*.3)) ///
	(connected fromaud year , sort lcolor(blue)) (connected fromcity year , sort lcolor(orange)), ///
	legend(order(3 "Former Auditors" 4 "Former City Chief Officers")) ytitle("% Former Auditors") ytitle("% Former City Chief Officers") xtitle("Year") 
graph export tables/f2b.png, replace width(`pngwidth') height(`pngheight')

local notes_f2b_1 = "This figure shows the distribution of auditor background across years."
local notes_f2b_2 = "Each dot indicates the fraction of auditors from different backgrounds."
local notes_f2b_3 = "The shaded area shows the 95 percent confidence interval."

file open f2b using "tables/f2b.tex", write replace
file write f2b "\begin{figure}[p]\captionsetup{justification=justified,singlelinecheck=false,width=\textwidth,labelformat=empty}" _n
file write f2b "\begin{center}" _n
file write f2b "Figure 2b: The Distribution of Auditor Background across Years" _n
file write f2b "\includegraphics[width=\textwidth]{tables/f2b.png}" _n
file write f2b "\end{center}" _n
file write f2b "\begin{figurenotes}" _n
file write f2b "`notes_f2b_1' `notes_f2b_2' `notes_f2b_3'" _n
file write f2b "\end{figurenotes}" _n
file write f2b "\end{figure}" _n
file close f2b
restore

********************************************************************************
* Figure 2c: The Average of log(SuspiciousExpenditures per Audit) across Years 
* for Hometown versus non-Hometown Auditors
********************************************************************************

preserve 
collapse (mean) violate1 (semean) se_y =violate1, by(year local_city)
gen y_l = violate1 - se_y*1.96
gen y_u = violate1 + se_y*1.96
tw (rarea y_u y_l year if local_city==0, sort color(ltblue*.5)) (rarea y_u y_l year if local_city==1, sort color(orange*.3))  ///
	(connected violate1 year if local_city==0, sort lcolor(blue)) (connected violate1 year if local_city==1, sort lcolor(orange))  , ///
	legend(order(4 "Hometown Auditor" 3 "Non-Hometown Auditor")) ytitle("log(Suspicious Expenditures per Audit)") xtitle("Year") 
graph export tables/f2c.png, replace width(`pngwidth') height(`pngheight')

local notes_f2c_1 = "This figure shows the distribution of $ log(SuspiciousExpenditures \, per \, Audit) $ across years, splitting the sample based on whether the chief auditor was born in the prefecture."
local notes_f2c_2 = "Each dot indicates the average of the $ log(SuspiciousExpenditures \, per \, Audit) $ uncovered by auditors from different backgrounds."
local notes_f2c_3 = "The shaded area shows the 95 percent confidence interval."

file open f2c using "tables/f2c.tex", write replace
file write f2c "\begin{figure}[p]\captionsetup{justification=justified,singlelinecheck=false,width=\textwidth,labelformat=empty}" _n
file write f2c "\begin{center}" _n
file write f2c "Figure 2c: The Average of log(SuspiciousExpenditures per Audit) across Years for Hometown versus non-Hometown Auditors" _n
file write f2c "\includegraphics[width=\textwidth]{tables/f2c.png}" _n
file write f2c "\end{center}" _n
file write f2c "\begin{figurenotes}" _n
file write f2c "`notes_f2c_1' `notes_f2c_2' `notes_f2c_3'" _n
file write f2c "\end{figurenotes}" _n
file write f2c "\end{figure}" _n
file close f2c
restore 

********************************************************************************
* Figure A1 - this is the alternative to 1c, which includes covariates.
********************************************************************************

preserve 
local outcome "violate1"
reg `outcome' $allvar, cluster(icity)
predict violate1_r,r

collapse (mean) violate1_r (semean) se_y =violate1_r, by(year local_city)
gen y_l = violate1_r - se_y*1.96
gen y_u = violate1_r + se_y*1.96
tw (rarea y_u y_l year if local_city==0, sort color(ltblue*.5)) (rarea y_u y_l year if local_city==1, sort color(orange*.3))  ///
	(connected violate1_r year if local_city==0, sort lcolor(blue)) (connected violate1_r year if local_city==1, sort lcolor(orange))  , ///
	legend(order(4 "Hometown Auditor" 3 "Non-Hometown Auditor")) ytitle("log(Suspicious Expenditures per Audit)") xtitle("Year") 
graph export tables/fa1.png, replace width(`pngwidth') height(`pngheight')

local notes_fa1_1 = "This figure shows the (residual) distribution of $ log(SuspiciousExpenditures per Audit) $ across years, splitting the sample based on whether the chief auditor was born in the prefecture. In generating the graph, we control for the auditor and city controls included in Table 3."
local notes_fa1_2 = "Each dot indicates the average of the $ log(SuspiciousExpenditures per Audit) $ uncovered by auditors from different backgrounds."
local notes_fa1_3 = "The shaded area shows the 95 percent confidence interval."

file open fa1 using "tables/fa1.tex", write replace
file write fa1 "\begin{figure}[p]\captionsetup{justification=justified,singlelinecheck=false,width=1\textwidth,labelformat=empty}" _n
file write fa1 "\begin{center}" _n
file write fa1 "Figure A1: The Average of log(SuspiciousExpenditures per Audit) across Years for Hometown versus non-Hometown Auditors, Controlling for Auditor and City Attributes" _n
file write fa1 "\includegraphics[width=\textwidth]{tables/fa1.png}" _n
file write fa1 "\end{center}" _n
file write fa1 "\begin{figurenotes}" _n
file write fa1 "`notes_fa1_1' `notes_fa1_2' `notes_fa1_3'" _n
file write fa1 "\end{figurenotes}" _n
file write fa1 "\end{figure}" _n
file close fa1
restore 

*/



********************************************************************************
* Table 1a: Summary Statistics, City-Year Aggregates
********************************************************************************
* summary statistics tables need to go here
* table 1a: city-year level
* table 1b comes later after table 7

label var violate3 "log(SuspiciousExpenditures)"
label var violate1 "log(SuspiciousExpenditures per Audit)"
label var num3 "log(Projects Audited)"
label var local_city "Hometown"
label var male "Gender" 
label var age "Age" 
label var tenure "Tenure"
label var tenure2 "\(\rm Tenure^2 \)"
label var edulevel "Education"
label var edufin "EduFinance"
label var fromaud "PastAuditor"
label var fromfin "PastFinance"
label var fromsup "PastDiscipline"
label var fromcitygov "PastCityLeader"
label var lngdppc "Log(GDP pc)"
label var lnpop "Log(Population)"
label var sec "IndustrialRatio"
label var lngovrev "og(GovRev)"
label var govbalance "GovBalance"
label var finv "FDI/GDP"
label var edu "AvgEdu"
label var susp_to_exp "Suspicious Exp/Gov Exp"
label var exp_to_gdp "Gov Exp/GDP"
label var tenure_cityg "Mayor Tenure"
label var tenure_citys "Party Sec Tenure"

preserve
estpost sum violate3 violate1 susp_to_exp num3 local_city exp_to_gdp $allvar ,detail

matrix t1a_mean = e(mean)'		
matrix t1a_sd = e(sd)' 		 
matrix t1a_obs = e(count)'

foreach mat in t1a_mean t1a_sd t1a_obs {
	svmat `mat'
}

gen t1avarname = ""
local position_a = 0
foreach var of varlist violate3 violate1 susp_to_exp num3 local_city $allvar {
	local position_a = `position_a' + 1
	replace t1avarname = "`:variable label `var''" in `position_a'
}

format t1a_mean t1a_sd %9.3f
format t1a_obs %9.0f

local notes_t1a_1 = "$ log(SuspiciousExpenditures) $ is the logarithm of total questionable expenditures found during the audit."
local notes_t1a_2 = "$ log(SuspiciousExpenditures per Audit) $ is the logarithm of total questionable expenditures per audited project."
local notes_t1a_3 = "$ log(Projects Audited) $ is the logarithm of number of audited projects."
local notes_t1a_4 = "$ Hometown $ is an indicator variable denoting that the provincial chief auditor was born in city $ c $."
local notes_t1a_5 = "$ Gender $ is an indicator variable denoting that the chief auditor is male."
local notes_t1a_6 = "$ Age $ is the age of the chief auditor."
local notes_t1a_7 = "$ Tenure $ is the tenure of the chief auditor."
local notes_t1a_8 = "$ Education $ is the education of the chief auditor: 4 for doctor, 3 for master, 2 for bachelor, 1 for college or lower level."
local notes_t1a_9 = "$ EduFinance $ is an indicator variable denoting whether the chief auditor has a business finance background."
local notes_t1a_10 = "$ PastAuditor $ is an indicator variable denoting whether the chief auditor previously worked in the auditing department."
local notes_t1a_11 = "$ PastFinance $ is an indicator variable denoting if the chief auditor previously worked in the finance/taxation department."
local notes_t1a_12 = "$ PastDiscipline $ is an indicator variable denoting if the chief auditor worked previously in the disciplining department."
local notes_t1a_13 = "$ PastCityLeader $ is an indicator variable denoting if the chief auditor worked previously as a city official with rank vice-mayor or higher."

local notes_t1a_14 = "$ Log(GDP pc) $ is the logarithm of city GDP per capita."
local notes_t1a_15 = "$ IndustrialRatio $ is the ratio of industrial output to total GDP."
local notes_t1a_16 = "$ Log(GovRev) $ is the logarithm of fiscal revenue of the city."
local notes_t1a_17 = "$ GovBalance $ the ratio of municipal government expenditures to revenues."
local notes_t1a_18 = "$ FDI/GDP $ is foreign direct investment scaled by GDP."
local notes_t1a_19 = "$ AvgEdu $ is the average number of years of education, at the province-level."

local notes_t1a " `notes_t1a_1' "
forvalues i=2(1)19 {
local notes_t1a `notes_t1a' `notes_t1a_`i'' 
}

listtex t1avarname t1a_* if _n < `position_a' + 1 using tables/t1a.tex, replace rstyle(tabular)  ///
		head(	"\begin{table}[p]\centering\footnotesize{"  ///
 				"\captionsetup{width=\textwidth,labelformat=empty}" /// 				
				"\caption{Table 1a: Summary Statistics, City-Year Aggregates}"  ///
				"\begin{threeparttable}" ///
				"\begin{tabular}{l  c c c }"  ///
				"\hline\hline"  ///
				"Variable Name & Mean & StdDev & Observations  \\"  ///
				"\hline")  ///
		foot(   "\hline\hline"  ///
				"\end{tabular}"  ///
				"\captionsetup{justification=justified,labelformat=empty}"  ///
				"\begin{tablenotes}\item Notes: `notes_t1a*' \end{tablenotes}"  ///
				"\end{threeparttable}}\end{table}") 
restore

********************************************************************************
* Table 2: Comparison of City Attributes, by Hometown Status
********************************************************************************

preserve
local varlist_dif "lngdppc sec lnpop lngovrev govbalance exp_to_gdp finv edu samecity"

estpost sum `varlist_dif' if local_city==0
matrix t2_c0_mean = e(mean)'
matrix t2_c0_sd = e(sd)' 
estpost sum `varlist_dif' if local_city==1
matrix t2_c1_mean = e(mean)'
matrix t2_c1_sd = e(sd)' 

foreach mat in t2_c1_mean t2_c1_sd t2_c0_mean t2_c0_sd {
	svmat `mat'
}

//create columns for: names, differences, and t-statistics
gen t2varname = ""
local position_a = 0
foreach var of varlist `varlist_dif' {
	local position_a = `position_a' + 1
	replace t2varname = "`:variable label `var''" in `position_a'
}

gen t2varname_dif = ""
gen t2_c3_mean = .
gen t2_c3_tstat = .

local position = 0
foreach var of varlist `varlist_dif' {
	local position = `position' + 1	
	replace t2varname_dif = "`:variable label `var''" in `position'
	regress `var' local_city, cluster(icity)
	matrix coeff = e(b)
	matrix variance = e(V)
	replace t2_c3_mean = coeff[1,1] in `position'
	replace t2_c3_tstat = coeff[1,1]/sqrt(variance[1,1]) in `position'
}

format t2_c* %9.3f

local note_dif_1 = "$ Hometown $ is an indicator variable denoting if the provincial chief auditor was born a given city."
local note_dif_2 = "See the notes to Table 1 for detailed definitions of the variables."
local note_dif_3 = "T-statistics are calculated based on a regression of each outcome on $ Hometown $, clustering at the city level."
listtex t2varname_dif t2_c* if _n < `position' + 1 using tables/t2.tex, replace rstyle(tabular)  ///
		head(	"\begin{table}[p]\centering\footnotesize{"  ///
 				"\captionsetup{width=\textwidth,labelformat=empty}" ///
				"\caption{Table 2: Comparison of City Attributes, by Hometown Status}"  ///
				"\begin{threeparttable}" ///
				"\begin{tabular}{l  c c c c c c}"  ///
				"\hline\hline"  ///
				"\; & \multicolumn{2}{c}{Hometown = 1} & \multicolumn{2}{c}{Hometown = 0} & \multicolumn{2}{c}{Difference}  \\"  ///
				"\hline" ///
				"Varible Name & Mean & StdDev & Mean & StdDev & Difference & t-statistic  \\"  ///
				"\hline")  ///
		foot(   "\hline\hline"  ///
				"\end{tabular}"  ///
				"\captionsetup{justification=justified,labelformat=empty}"  ///
				"\begin{tablenotes}\item Notes: `note_dif_1' `note_dif_2' `note_dif_3' \end{tablenotes}"  ///
				"\end{threeparttable}}\end{table}") 
restore

********************************************************************************
* Table 3: The Relationship Between Auditor Hometown and Government Audit Outcomes
********************************************************************************

egen sdev_localcity=sd(local_city),by(icity)

preserve

local outcome "violate3"
local varlist "local_city "
local table = "3"

* column 1
 reghdfe `outcome' local_city , absorb(year)  cluster(icity)
* eststo t`table'_col1
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col1
* column 2
 reghdfe `outcome' local_city , absorb(year icity)  cluster(icity)
* eststo t`table'_col2
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col2
* column 3
 reghdfe `outcome' local_city $auditorvar, absorb(year icity)  cluster(icity)
* eststo t`table'_col3
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col3
* column 4
eststo m1: reghdfe `outcome' local_city $allvar, absorb(year icity)  cluster(icity)
* eststo t`table'_col4
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col4
* column 5
reghdfe `outcome' local_city $cityvar, absorb(year icity id)  cluster(icity)
* eststo t`table'_col5
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col5
* column 6
 reghdfe `outcome' local_city $allvar if sdev_localcity>0, absorb(year icity) cluster(icity)
* eststo t`table'_col6
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col6
*** EDIT by Donna
estout m1 using "../results/table3.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace


* within-city std deviation in the outcome
egen violate3_sdev=sd(violate3),by(icity)
bys icity: replace violate3_sdev=. if _n~=1
sum violate3_sdev
* column 7
local outcome violate1
label var violate1 " $ log(SuspiciousExpenditures \; per \;Audit) $ "
 reghdfe `outcome' local_city $allvar, absorb(year icity)  cluster(icity)
* eststo t`table'_col7
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col7
* column 8
local outcome num3
label var num3 " $ log(Projects \; Audited) $ "
 reghdfe `outcome' local_city $allvar, absorb(year icity)  cluster(icity)
* eststo t`table'_col8
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col8

local significance = "  \\  Significance: * significant at 10\%; ** significant at 5\%; *** significant at 1\%."
local cluster = "Standard errors clustered by city in parentheses."
local auditctr = "Auditor Controls include $ Gender $, $ Age $, $ Tenure $, $ Tenure^2 $, $ Education $, $ EduFinance $, $ PastAuditor $, $ PastFinance $, $ PastDiscipline $, and $ PastCityLeader $."
local cityctr = "City controls include $ Log(GDP pc) $, $ IndustrialRatio $, $ Log(Population) $, $ Log(GovRev) $, $ GovBalance $, $ FDI/GDP $, and $ AvgEdu $."
local firmctr = "Firm controls include $ log(Assets) $, $ Leverage $, $ ROA $, $ MBRatio $, $ TopOwnership $, $ log(BoardSize) $, $ Dual $, $ Indep\_Ratio $, $ Mgtshare $, and $ Big4Audit $."
local post2013fe = "Column (6) includes all city and auditor controls interacted with the dummy variable $ Post2013 $."
local sample = "The sample covers the period from 2006 to 2016."
local depvar = "The dependent variable in columns (1)-(6) is $ log(SuspiciousExpenditures) $, which denotes the logarithm of total questionable expenditures found during the audit."
local depvar_1 = "The dependent variable in columns (7) is $ log(SuspiciousExpenditures \; per \;Audit) $, which denotes the logarithm of total questionable expenditures per audited project."
local depvar_2 = "The dependent variable in columns (8) is $ log(Projects \; Audited) $, which denotes the logarithm of number of projects audited."
local sample_1 = "The sample in column (6) is limited to cities that have variation in $ Hometown $ during the sample period."
local indepvar = "$ Hometown $ is an indicator variable denoting that the provincial chief auditor was born in city $ c $."
local ctr = "The coefficients and standard errors of the control variables are suppressed to conserve space."
local def = "See the notes to Table 1 for detailed definitions of the control variables."

* output to latex
* esttab t`table'_col*  ///
using tables/t`table'.tex, replace  ///
	star(* 0.10 ** 0.05 *** 0.01) /*plain*/ nogaps   ///
	nodepvars b(%9.3f) legend noabbrev style(tex) constant   ///
	title("Table 3: The Relationship Between Auditor Hometown and Government Audit Outcomes")   ///
	label stats(N r2 depavg, fmt(%9.0g %9.3g %9.3g) labels("Observations" "R-Squared" "Mean of Dep. Var.")) se  ///
	order(`varlist' /*_cons*/)     ///
	keep( `varlist' /*_cons*/)     ///
	nomtitles  ///
	posthead(	"Dependent Variable & \multicolumn{6}{c}{log(SuspiciousExpenditures)} & log(SuspExp/Audit) & log(Projects Audited) \\"  ///
				"\hline")  ///
	prefoot(	"\hline" ///
				"Year FEs         & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\"  ///
				"City FEs         &     & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\"  ///
				"Auditor Controls &     &     & Yes & Yes &     & Yes & Yes & Yes \\"  ///
				"Auditor FE    	  &     &     &     &	  &	Yes	&     &  	&  	  \\"  ///
				"City Controls    &     &     &     & Yes & Yes & Yes & Yes & Yes \\"  ///
				"\hline" ///
				"Sample & Full & Full & Full & Full & Full & \tabincell{c}{Within-City \\ Variation} & Full & Full \\ " ///
				"\hline")  ///
	nonotes 	///
	postfoot(	"\hline\hline" ///
				"\end{tabular}}"  ///
				"\captionsetup{justification=justified,labelformat=empty}"  ///
				"\begin{tablenotes}"  ///
				"\item Notes: `cluster' `sample' `depvar' `depvar_1' `depvar_2' `sample_1' `indepvar' `auditctr' `cityctr' `ctr' `def' `significance'" ///
				"\end{tablenotes}"  ///
				"\end{table}")  ///
	substitute(	\begin{table}[htbp]\centering \begin{table}[p]\centering\captionsetup{width=\textwidth,labelformat=empty}\begin{threeparttable}\footnotesize{ \end{table} \end{threeparttable}\end{table})
restore
	
********************************************************************************
* Table 4: Differences in Hometown Auditor Effect across Time Periods
********************************************************************************

preserve

foreach var in $allvar {
	gen post2013_`var'=post2013*`var'
}

gen local_city_post2013=local_city*post2013
label var local_city_post2013 "Hometown*Post2013"

foreach var in $allvar {
	gen nao_`var'=nao*`var'
}

gen local_city_nao=local_city*nao
label var local_city_nao "Hometown*NAO="

local outcome "violate3"
local depvar_label = "`:variable label `outcome''"
local varlist "local_city local_city_post2013 local_city_nao"
local table = "4"

* column 1
reghdfe `outcome' local_city local_city_post2013 $allvar , absorb(year icity)  cluster(icity)
* eststo t`table'_col1
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col1

* column 2
eststo m2: reghdfe `outcome' local_city local_city_post2013 $allvar post2013*, absorb(year icity)  cluster(icity)
* eststo t`table'_col2
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col2
*** EDIT by Donna
estout m2 using "../results/table4.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

* column 3
reghdfe `outcome' local_city local_city_nao $allvar , absorb(year icity)  cluster(icity)
* eststo t`table'_col3
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col3

* column 4
reghdfe `outcome' local_city local_city_nao $allvar nao*, absorb(year icity)  cluster(icity)
* eststo t`table'_col4
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col4

local significance = "  \\  Significance: * significant at 10\%; ** significant at 5\%; *** significant at 1\%."
local cluster = "Standard errors clustered by city in parentheses."
local auditctr = "Auditor Controls include $ Gender $, $ Age $, $ Tenure $, $ Tenure^2 $, $ Education $, $ EduFinance $, $ PastAuditor $, $ PastFinance $, $ PastDiscipline $, and $ PastCityLeader $."
local cityctr = "City controls include $ Log(GDP pc) $, $ IndustrialRatio $, $ Log(Population) $, $ Log(GovRev) $, $ GovBalance $, $ FDI/GDP $, and $ AvgEdu $."
local post2013fe = "Column (2) includes all city and auditor controls interacted with the dummy variable $ Post2013 $."
local naofe = "Column (3) includes all city and auditor controls interacted with the dummy variable $ NAO $."
local sample = "The sample covers the period from 2006 to 2016."
local depvar = "The dependent variable in all columns is $ log(SuspiciousExpenditures) $, which denotes the logarithm of total questionable expenditures found during the audit."
local sample_1 = "The sample in column (6) is limited to cities that have variation in $ Hometown $ during the sample period."
local indepvar1 = "$ Hometown $ is an indicator variable denoting that the provincial chief auditor was born in city $ c $."
local indepvar2 = "$ Post2013 $ denotes years 2013 and later, and $ NAO $ is an indicator variable denoting the years 2011 and 2013 when the National Audit Office audited local government debt."
local ctr = "The coefficients and standard errors of the control variables are suppressed to conserve space."
local def = "See the notes to Table 1 for detailed definitions of the control variables."

* output to latex
* esttab t`table'_col*  ///
	using tables/t`table'.tex, replace  ///
	star(* 0.10 ** 0.05 *** 0.01) /*plain*/ nogaps   ///
	nodepvars b(%9.3f) legend noabbrev style(tex) constant   ///
	title("Table 4: Differences in hometown auditor effect across time periods")   ///
	label stats(N r2 depavg, fmt(%9.0g %9.3g %9.3g) labels("Observations" "R-Squared" "Mean of Dep. Var.")) se  ///
	order(`varlist' /*_cons*/) 	   ///
	keep( `varlist' /*_cons*/)     ///
	nomtitles  ///
	posthead(	"Dependent Variable & \multicolumn{@M}{c}{ `depvar_label' }  \\"  ///
				"\hline")  ///
	prefoot(	"\hline" ///
				"Year FEs               & Yes & Yes & Yes & Yes \\"  ///
				"City FEs               & Yes & Yes & Yes & Yes \\"  ///
				"Auditor Controls       & Yes & Yes & Yes & Yes \\"  ///
				"City Controls          & Yes & Yes & Yes & Yes \\"  ///
				"City*Post2013 Controls &     & Yes &     &     \\"  ///
				"City*NAO Controls      &     &     &     & Yes \\"  ///
				"\hline")  ///
	nonotes 	///
	postfoot(	"\hline\hline" ///
				"\end{tabular}}"  ///
				"\captionsetup{justification=justified,labelformat=empty}"  ///
				"\begin{tablenotes}"  ///
				"\item Notes: `cluster' `sample' `depvar' `indepvar1' `indepvar2' `auditctr' `cityctr' `ctr' `def' `significance'" ///
				"\end{tablenotes}"  ///
				"\end{table}")  ///
	substitute(	\begin{table}[htbp]\centering \begin{table}[p]\centering\captionsetup{width=\textwidth,labelformat=empty}\begin{threeparttable}\footnotesize{ \end{table} \end{threeparttable}\end{table})
restore

******************************************************************
* Table 5: The Role of Auditor Tenure
******************************************************************

preserve
gen year1=tenure==1
gen year12=tenure<3 if tenure~=.
gen local_city_year1=year1*local_city
gen local_city_year12=year12*local_city

foreach var in tenure tenure2 {
	gen local_city_`var'=`var'*local_city
}

label var year1 "FirstYear"	
label var local_city_year1 "FirstYear*Hometown"	
label var local_city_tenure "Tenure*Hometown"	
label var local_city_tenure2 "\(\rm Tenure^2*Hometown\)"	
	
local outcome "violate3"
local depvar_label = "`:variable label `outcome''"
local varlist "local_city year1 local_city_year1 tenure local_city_tenure tenure2 local_city_tenure2"
local table = "5"
local depvar = "The dependent variable in all columns is $ log(SuspiciousExpenditures) $, which denotes the logarithm of total questionable expenditures found during the audit."

* column 1
eststo m1: reghdfe `outcome' $allvar local_city year1 local_city_year1, absorb(year icity )  cluster(icity)
* eststo t`table'_col1
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col1
* column 2
eststo m2: reghdfe `outcome' $allvar local_city local_city_tenure , absorb(year icity )  cluster(icity)
* eststo t`table'_col2
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col2
* column 3
eststo m3: reghdfe `outcome' $allvar local_city local_city_tenure local_city_tenure2, absorb(year icity )  cluster(icity)
* eststo t`table'_col3
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col3
*** EDIT by Donna
estout m1 m2 m3 using "../results/table5.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

* output to latex
* esttab t`table'_col*  ///
	using tables/t`table'.tex, replace  ///
	star(* 0.10 ** 0.05 *** 0.01) /*plain*/ nogaps   ///
	nodepvars b(%9.3f) legend noabbrev style(tex) constant   ///
	title("Table 5: The Role of Auditor Tenure")   ///
	label stats(N r2 depavg, fmt(%9.0g %9.3g %9.3g) labels("Observations" "R-Squared" "Mean of Dep. Var.")) se  ///
	order(`varlist' /*_cons*/)    ///
	keep( `varlist' /*_cons*/)     ///
	nomtitles  ///
	posthead(	"Dependent Variable & \multicolumn{@M}{c}{ `depvar_label' }  \\"  ///
				"\hline")  ///
	prefoot(	"\hline" ///
				"Year FEs         & Yes & Yes & Yes \\"  ///
				"City FEs         & Yes & Yes & Yes \\"  ///
				"Auditor Controls & Yes & Yes & Yes \\"  ///
				"City Controls    & Yes & Yes & Yes \\"  ///
				"\hline")  ///
	nonotes 	///
	postfoot(	"\hline\hline" ///
				"\end{tabular}}"  ///
				"\captionsetup{justification=justified,labelformat=empty}"  ///
				"\begin{tablenotes}"  ///
				"\item Notes: `cluster' `sample' `depvar' `indepvar' `auditctr' `cityctr' `ctr' `def' `significance'" ///
				"\end{tablenotes}"  ///
				"\end{table}")  ///
	substitute(	\begin{table}[htbp]\centering \begin{table}[p]\centering\captionsetup{width=\textwidth,labelformat=empty}\begin{threeparttable}\footnotesize{ \end{table} \end{threeparttable}\end{table})
restore

********************************************************************************
* Table 6: City Turnover, Administrative Oversight, and Audit Outcomes
********************************************************************************

preserve

gen local_city_turnover=local_city*turnover
**turnovers: city party secretary's turnover
gen local_city_turnovers=local_city*turnovers
**turnoverg: city mayor(governor)'s turnover 
gen local_city_turnoverg=local_city*turnoverg

**seems that the positive interaction effect of city official turnover and local_city comes from turnover of city mayor (rather than city party secretary)
**we can further disaggregate turnover into promotion vs nonpromotion. seems that for promotion (more attention grabbing), we see less favoritism played by hometown auditors.
**but i don't know whether we want to report these results.

label var turnover "CityTurnover"
label var local_city_turnover "CityTurnover*Hometown"
gen post2013_turnover=post2013*turnover
label var post2013_turnover "CityTurnover*Post2013"

local varlist "local_city turnover local_city_turnover"
local table = "6"

* column 1
local outcome "violate3"
reghdfe `outcome' $allvar local_city turnover local_city_turnover , absorb(year icity)  cluster(icity)
* eststo t`table'_col1
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col1

* column 2
local outcome "violate1"
reghdfe `outcome' $allvar local_city turnover local_city_turnover , absorb(year icity)  cluster(icity)
* eststo t`table'_col2
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col2

* column 3
local outcome "num3"
reghdfe `outcome' $allvar local_city turnover local_city_turnover , absorb(year icity)  cluster(icity)
* eststo t`table'_col3
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col3

local depvar = "The dependent variable in columns (1) is $ log(SuspiciousExpenditures) $, which denotes the logarithm of total questionable expenditures found during the audit."
local depvar_1 = "The dependent variable in columns (2) is $ log(SuspiciousExpenditures \; per \;Audit) $, which denotes the logarithm of total questionable expenditures per audited project."
local depvar_2 = "The dependent variable in columns (3) is $ log(Projects \; Audited) $, which denotes the logarithm of number of projects audited."
local indvar_1 = "$ Turnover $ denotes years in which the prefecture mayor or party secretary departs, which triggers audit oversight by the province-level Organization Department."

* output to latex
* esttab t`table'_col*  ///
	using tables/t`table'.tex, replace  ///
	star(* 0.10 ** 0.05 *** 0.01) /*plain*/ nogaps   ///
	nodepvars b(%9.3f) legend noabbrev style(tex) constant   ///
	title("Table 6: City Turnover, Administrative Oversight, and Audit Outcomes")   ///
	label stats(N r2 depavg, fmt(%9.0g %9.3g %9.3g) labels("Observations" "R-Squared" "Mean of Dep. Var")) se  ///
	order(`varlist' /*_cons*/)    ///
	keep( `varlist' /*_cons*/)     ///
	nomtitles  ///
	posthead(	"Dependent Variable & log(SuspiciousExpenditures) & log(SuspExp/Project) & log(Projects Audited) \\"  ///
				"\hline")  ///
	prefoot(	"\hline" ///
				"Year FEs         & Yes & Yes & Yes \\"  ///
				"City FEs         & Yes & Yes & Yes \\"  ///
				"Auditor Controls & Yes & Yes & Yes \\"  ///
				"City Controls    & Yes & Yes & Yes \\"  ///
				"\hline")  ///
	nonotes 	///
	postfoot(	"\hline\hline" ///
				"\end{tabular}}"  ///
				"\captionsetup{justification=justified,labelformat=empty}"  ///
				"\begin{tablenotes}"  ///
				"\item Notes: `cluster' `sample' `depvar' `depvar_1' `depvar_2' `indepvar' `indvar_1' `auditctr' `cityctr' `ctr' `def' `significance'" ///
				"\end{tablenotes}"  ///
				"\end{table}")  ///
	substitute(	\begin{table}[htbp]\centering \begin{table}[p]\centering\captionsetup{width=\textwidth,labelformat=empty}\begin{threeparttable}\footnotesize{ \end{table} \end{threeparttable}\end{table})
restore

********************************************************************************
* Table 7: Robustness and Heterogeneity (Interactions)
********************************************************************************

preserve

label var samecity "SameHometown Leaders"

gen local_province=province==home_prov
label var local_province "Homeprovince"

gen local_city_g=city==birthcity_provg
gen local_city_s=city==birthcity_provs
gen local_city_top2=local_city_g|local_city_s

label var local_city_top2 "Prov Leader Hometown"


egen evertop2=max(local_city_top2),by(icity)

local table = "7"

* demean variables for interactions
foreach var in lngdppc lnpop {
	egen `var'_mean=mean(`var')
	replace `var'=`var'-`var'_mean
	g `var'_local_city=`var'*local_city
}

label var lngdppc_local_city "Hometown*log(GDP per capita)"
label var lnpop_local_city "Hometown*log(Population)"
label var nearby_city "NearbyCity"

local outcome "violate3"

reghdfe `outcome' local_city local_province $allvar , absorb(year icity)  cluster(icity)
* eststo t`table'_col1
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col1

reghdfe `outcome' local_city samecity $allvar , absorb(year icity)  cluster(icity)
* eststo t`table'_col2
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col2

reghdfe  `outcome' local_city $allvar if evertop2==0, absorb(year icity)  cluster(icity)
* eststo t`table'_col3
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col3

reghdfe  `outcome'  local_city local_city_top2 $allvar, absorb(year icity)  cluster(icity)
* eststo t`table'_col4
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col4

reghdfe  `outcome' local_city nearby_city $allvar, absorb(year icity)  cluster(icity)
* eststo t`table'_col5
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col5

reghdfe  `outcome' local_city   $allvar if capital==0, absorb(year icity)  cluster(icity)
* eststo t`table'_col6
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col6

reghdfe  `outcome' local_city lnpop_local_city $allvar, absorb(year icity)  cluster(icity)
* eststo t`table'_col7
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col7

reghdfe  `outcome' local_city  lngdppc_local_city $allvar, absorb(year icity)  cluster(icity)
* eststo t`table'_col8
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col8

local varlist "local_city local_province samecity local_city_top2 nearby_city lnpop_local_city lngdppc_local_city"

local significance = "  \\  Significance: * significant at 10\%; ** significant at 5\%; *** significant at 1\%."
local cluster = "Standard errors clustered by city in parentheses."
local auditctr = "All regressions include the following auditor controls: $ Gender $, $ Age $, $ Tenure $, $ Tenure^2 $, $ Education $, $ EduFinance $, $ PastAuditor $, $ PastFinance $, $ PastDiscipline $, and $ PastCityLeader $."
local cityctr = "All regressions include the following city controls: $ Log(GDP pc) $, $ IndustrialRatio $, $ Log(Population) $, $ Log(GovRev) $, $ GovBalance $, $ FDI/GDP $, and $ AvgEdu $."
local sample1 = "The sample covers the period from 2006 to 2016. Column (2) excludes cities that, at some point during this period, was the hometown of the provincial governor or party secretary for the province where $ c $ is located."
local sample2 = "Column (6) excludes provincial capital cities."
local depvar = "The dependent variable in all columns is $ log(SuspiciousExpenditures) $, which denotes the logarithm of total questionable expenditures found during the audit."
local var1 = "$ Hometown $ is an indicator variable denoting that the provincial chief auditor was born in city $ c $."
local var2 = "$ Homeprovince $ is an indicator variable denoting that the provincial chief auditor was born in province of city $ c $."
local var3 = "$ Same Hometown Leader $ is an indicator variable denoting that the provincial chief auditor had the same hometown as the city mayor or party secretary."
local var4 = "$ ProvLeaderHometown $ is an indicator variable denoting that the provincial governor or party secretary was born in city $ c $."
local ctr = "The coefficients and standard errors of the control variables are suppressed to conserve space."
local def = "See the notes to Table 1 for detailed definitions of the remaining control variables."

* output to latex
* esttab t`table'_col*  ///
	using tables/t`table'.tex, replace  ///
	star(* 0.10 ** 0.05 *** 0.01) /*plain*/ nogaps   ///
	nodepvars b(%9.3f) legend noabbrev style(tex) constant   ///
	title("Table 7: Robustness and heterogeneity")   ///
	label stats(N r2 depavg, fmt(%9.0g %9.3g %9.3g) labels("Observations" "R-Squared" "Mean of Dep. Var.")) se  ///
	order(`varlist' /*_cons*/)    ///
	keep( `varlist' /*_cons*/)     ///
	nomtitles  ///
	posthead(	"Dependent Variable & \multicolumn{8}{c}{log(SuspiciousExpenditures)} \\ "  ///
				"\hline")  ///
	prefoot(	"\hline" ///
				"Excluding Mayor/PS hometowns? &     &     & Yes &     &     &     &     &  \\"  ///
				"Excluding Prov capitals?	   &     &     &     &     &     & Yes &     &  \\"  ///
				"\hline") ///
	nonotes 	///
	postfoot(	"\hline\hline" ///
				"\end{tabular}}"  ///
				"\captionsetup{justification=justified,labelformat=empty}"  ///
				"\begin{tablenotes}"  ///
				"\item Notes: `cluster' `sample1' `sample2' `depvar' `var1' `var2' `var3' `var4' `auditctr' `cityctr' `ctr' `def' `significance'" ///
				"\end{tablenotes}"  ///
				"\end{table}")  ///
	substitute(	\begin{table}[htbp]\centering \begin{table}[p]\centering\captionsetup{width=\textwidth,labelformat=empty}\begin{threeparttable}\footnotesize{ \end{table} \end{threeparttable}\end{table})
restore

/*
********************************************************************************
* Table A1: The Relationship Between Auditor Hometown and Government Audit Outcomes, All Covariates Listed
********************************************************************************

preserve
local outcome "violate3"
local varlist "local_city $allvar"
local table = "a1"

* column 1
reghdfe `outcome' local_city , absorb(year)  cluster(icity)
* eststo t`table'_col1
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col1
* column 2
reghdfe `outcome' local_city , absorb(year icity)  cluster(icity)
* eststo t`table'_col2
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col2
* column 3
reghdfe `outcome' local_city $auditorvar, absorb(year icity)  cluster(icity)
* eststo t`table'_col3
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col3
* column 4
reghdfe `outcome' local_city $allvar, absorb(year icity)  cluster(icity)
* eststo t`table'_col4
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col4
* column 5
reghdfe `outcome' local_city $cityvar, absorb(year icity id)  cluster(icity)
* eststo t`table'_col5
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col5
* column 6
reghdfe `outcome' local_city $allvar if sdev_localcity>0, absorb(year icity)  cluster(icity)
* eststo t`table'_col6
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col6
* column 7
local outcome violate1
label var violate1 " $ log(SuspiciousExpenditures \; per \;Audit) $ "

reghdfe `outcome' local_city $allvar, absorb(year icity)  cluster(icity)
* eststo t`table'_col7
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col7
* column 8
local outcome num3
label var num3 " $ log(Projects \; Audited) $ "
reghdfe `outcome' local_city $allvar, absorb(year icity)  cluster(icity)
* eststo t`table'_col8
su `outcome' if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col8

local significance = "  \\  Significance: * significant at 10\%; ** significant at 5\%; *** significant at 1\%."
local cluster = "Standard errors clustered by city in parentheses."
local auditctr = "Auditor Controls include $ Gender $, $ Age $, $ Tenure $, $ Tenure^2 $, $ Education $, $ EduFinance $, $ PastAuditor $, $ PastFinance $, $ PastDiscipline $, and $ PastCityLeader $."
local post2013fe = "Column (6) includes all city and auditor controls interacted with the dummy variable $ Post2013 $."
local sample = "The sample covers the period from 2006 to 2016."
local depvar = "The dependent variable in columns (1)-(6) is $ log(SuspiciousExpenditures) $, which denotes the logarithm of total questionable expenditures found during the audit."
local depvar_1 = "The dependent variable in columns (7) is $ log(SuspiciousExpenditures \; per \;Audit) $, which denotes the logarithm of total questionable expenditures per audited project."
local depvar_2 = "The dependent variable in columns (8) is $ log(Projects \; Audited) $, which denotes the logarithm of number of projects audited."
local sample_1 = "The sample in column (5) is limited to cities that have variation in $ Hometown $ during the sample period."
local indepvar = "$ Hometown $ is an indicator variable denoting that the provincial chief auditor was born in city $ c $."
local ctr = "The coefficients and standard errors of the control variables are suppressed to conserve space."
local def = "See the notes to Table 1 for detailed definitions of the control variables."

* output to latex
* esttab t`table'_col*  ///
	using tables/t`table'.tex, replace  ///
	star(* 0.10 ** 0.05 *** 0.01) /*plain*/ nogaps   ///
	nodepvars b(%9.3f) legend noabbrev style(tex) constant   ///
	title("Table A1: The Relationship Between Auditor Hometown and Government Audit Outcomes, All Covariates Listed")   ///
	label stats(N r2 depavg, fmt(%9.0g %9.3g %9.3g) labels("Observations" "R-Squared" "Mean of Dep. Var.")) se  ///
	order(`varlist' /*_cons*/)    ///
	keep( `varlist' /*_cons*/)     ///
	nomtitles  ///
	posthead(	"Dependent Variable & \multicolumn{6}{c}{ log(SuspiciousExpenditures) } & log(SuspExp/Audit) & log(Projects Audited) \\"  ///
				"\hline")  ///
	prefoot(	"\hline" ///
				"Year FEs         & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\"  ///
				"City FEs         &     & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\"  ///
				"Auditor FE    	  &     &     &     &	  &	Yes	&     &  	&  	  \\"  ///
				"\hline" ///
				"Sample & Full & Full & Full & Full & Full & \tabincell{c}{Within-City \\ Variation} & Full & Full \\ " ///
				"\hline")  ///
	nonotes 	///
	postfoot(	"\hline\hline" ///
				"\end{tabular}}"  ///
				"\captionsetup{justification=justified,labelformat=empty}"  ///
				"\begin{tablenotes}"  ///
				"\item Notes: `cluster' `sample1' `sample2' `depvar' `var1' `var2' `var3' `var4' `auditctr' `cityctr' `ctr' `def' `significance'" ///
				"\end{tablenotes}"  ///
				"\end{table}")  ///
	substitute(	\begin{table}[htbp]\centering \begin{table}[p]\centering\captionsetup{width=\textwidth,labelformat=empty}\scalebox{.85}{\begin{threeparttable}\footnotesize{ \end{table} \end{threeparttable}}\end{table})
restore
*/

********************************************************************************
* Firm-Level Analysis
********************************************************************************

use "AEJ_firm.dta", clear

label var stkcd "stock code"
label var year "year"
label var province "province id"
label var city "city id"
label var soe "if the firm is state owned enterprise, take 1, otherwise take 0"
label var lsoe "if the firm is local state owned enterprise, take 1, otherwise take 0"
label var csoe "if the firm is central state owned enterprise, take 1, otherwise take 0"
label var rm "real earnings management(total value)"
label var da_mj "earnings management(with symbol) calculated by modified Jones model (Dechow et al. 1995 TAR)"
label var local_city "whether the chief auditor of the province was born in the focal city"

label var male "gender of the chief auditor"
label var age "age of the chief auditor"
label var tenure "tenure of the chief auditor"
label var tenure2 "\(\rm Tenure^2 \)"
label var edufin "whether the chief auditor has finance bakground"
label var edulevel "education of the chief auditor: 4 for doctor, 3 for master, 2 for bachelor, 1 for collage or lower level"
label var fromaud "was the chief working in the auditing department before? "
label var fromfin "was the chief working in the Finance/taxation department before? "
label var fromsup "was the chief working in the discplining department before? "
label var fromcitygov "was the cheif working in the general office before (for example, city mayor et.al.) "

label var lnta "ln(total asset)"
label var lev "total liabilities divided by total assets"
label var roa "ROA" 
label var mb "market-to-book ratio"
label var largest "shareholding ratio of the largest shareholder"
label var board "natural logarithm of board members"               
label var dual "if the chairman and ceo are the same person, take 1, otherwise 0"                      
label var indep "number of Independent Directors divided by number of board members"                  
label var manshare "management shareholding ratio"         

label var lngdppc "ln(GDP per capita)"
label var sec "the ratio of industrial output to total GDP"
label var lngovrev "ln(fiscal revenue of the city)"
label var govbalance "fiscal expenditure/fiscal income of the city"
label var finv "city FDI/GDP"
label var edu "average education level of the province"       
            
global auditorvar "male age tenure tenure2 edulevel edufin fromaud fromfin fromsup fromcitygov"
global firmvar "lnta lev roa mb largest board dual indep manshare big4"
global cityvar "lngdppc sec lngovrev govbalance finv edu "
global allvar "$auditorvar $firmvar $cityvar"

egen firmid=group(stkcd)
egen icity=group(province city)

label var rm "RAM"
label var da_mj "AM"
label var local_city "Hometown"
label var lnta "log(Assets)"
label var lev "Leverage"
label var roa "ROA"
label var mb "MBRatio"
label var largest "TopOwnership"
label var board "log(BoardSize)"
label var dual "Dual"
label var indep "Ind\_Dir\_Ratio"
label var manshare "Mgtshare"
label var big4 "Big4Audit"

********************************************************************************
* Table 1b: Summary Statistics, Firm-Year Aggregates for Locally-Owned SOEs 
********************************************************************************

preserve

* since our main analysis is focused on lsoe, we drop csoe
keep if lsoe==1

drop if rm==.
estpost sum rm da_mj $firmvar ,detail

matrix t1b_mean = e(mean)'		
matrix t1b_sd = e(sd)' 		 
matrix t1b_obs = e(count)'

foreach mat in t1b_mean t1b_sd t1b_obs {
	svmat `mat'
}

gen t1bvarname = ""
local position_b = 0
foreach var of varlist rm da_mj $firmvar {
	local position_b = `position_b' + 1
	replace t1bvarname = "`:variable label `var''" in `position_b'
}

format t1b_mean t1b_sd %9.3f
format t1b_obs %9.0f

local notes_t1b_1 = "$ RAM $ is real activity manipulation."
local notes_t1b_2 = "$ AM $ is accrual manipulation."
local notes_t1b_3 = "$ Leverage $ is total liabilities divided by total assets."
local notes_t1b_4 = "$ log(Assets) $ is the logarithm of total assets."
local notes_t1b_5 = "$ ROA $ is return on assets."
local notes_t1b_6 = "$ MBRatio $ is the ratio of market capitalization to book value of total equity."
local notes_t1b_7 = "$ TopOwnership $ is the ownership share of the largest shareholder."
local notes_t1b_8 = "$ log(BoardSize) $ is the log of the number of board members."
local notes_t1b_9 = "$ Dual $ is an indicator variable denoting that the chairperson is also the CEO."
local notes_t1b_10 = "$ Indep\_Ratio $ is the ratio of independent directors to total number of directors."
local notes_t1b_11 = "$ Mgtshare $ denotes the fraction of shares held by management at the level of vice-CEO and higher."
local notes_t1b_12 = "$ Big4Audit $ is an indicator variable denoting whether the firm's auditor is one of the Big 4 global audit firms."

local notes_t1b  " `notes_t1b_1' "
forvalues i=2(1)12 {
local notes_t1b `notes_t1b' `notes_t1b_`i'' 
}

listtex t1bvarname t1b_* if _n < `position_b' + 1 using tables/t1b.tex, replace rstyle(tabular)  ///
		head(	"\begin{table}[p]\centering\footnotesize{"  ///
				"\begin{threeparttable}" ///
				"\captionsetup{width=\textwidth,labelformat=empty}"	///
 				"\caption{Table 1b: Summary Statistics, \\ Firm-Year Aggregates for Locally-Owned SOEs}"  ///
				"\begin{tabular}{lccc}"  ///
				"\hline\hline"  ///
				"Variable Name & Mean & StdDev & Observations \\"  ///
				"\hline")  ///
		foot(   "\hline\hline"  ///
				"\end{tabular}"  ///
				"\captionsetup{justification=justified,labelformat=empty}"  ///
                "\begin{tablenotes}\item Notes: `notes_t1b*' \end{tablenotes}"  ///
				"\end{threeparttable}}\end{table}") 
restore

********************************************************************************
* Table 8: Firm Level Regressions on Locally-Owned SOE Real Activity Manipulation
********************************************************************************

local significance = "  \\  Significance: * significant at 10\%; ** significant at 5\%; *** significant at 1\%."
local cluster = "Standard errors clustered by city in parentheses."
local auditctr = "Auditor Controls include $ Gender $, $ Age $, $ Tenure $, $ Tenure^2 $, $ Education $, $ EduFinance $, $ PastAuditor $, $ PastFinance $, $ PastDiscipline $, and $ PastCityLeader $."
local cityctr = "City controls include $ Log(GDP pc) $, $ IndustrialRatio $, $ Log(Population) $, $ Log(GovRev) $, $ GovBalance $, $ FDI/GDP $, and $ AvgEdu $."
local firmctr = "Firm controls include $ log(Assets) $, $ Leverage $, $ ROA $, $ MBRatio $, $ TopOwnership $, $ log(BoardSize) $, $ Dual $, $ Indep\_Ratio $, $ Mgtshare $, and $ Big4Audit $."
local sample = "The sample covers the period from 2006 to 2018."
local depvar = "The dependent variable in all columns is real activity manipulation ($ RAM $)."
local indepvar = "$ Hometown $ is an indicator variable denoting that the provincial chief auditor was born in city $ c $."
local def = "See the notes to Table 1 for detailed definitions of the control variables, and the text for further description of real activity manipulation."

local varlist "local_city"
local table = "8"

local sample_1 = "The sample includes all locally-controlled state-owned enterprises"

preserve
keep if lsoe==1
 
* column 1
 reghdfe rm local_city , absorb(year firmid) cluster(icity)
* eststo t`table'_col1
su rm if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col1
* column 2
 reghdfe rm local_city $auditorvar , absorb(year firmid) cluster(icity)
* eststo t`table'_col2
su rm if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col2
* column 3
 reghdfe rm local_city $auditorvar $firmvar , absorb(year firmid) cluster(icity)
* eststo t`table'_col3
su rm if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col3
* column 4
*** EDIT by Donna
eststo m4: reghdfe rm local_city $auditorvar $firmvar $cityvar , absorb(year firmid) cluster(icity)
estout m4 using "../results/table8.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
* eststo t`table'_col4
su rm if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col4
restore

* output to latex
* esttab t`table'_col*  ///
	using tables/t`table'.tex, replace  ///
	star(* 0.10 ** 0.05 *** 0.01) /*plain*/ nogaps   ///
	nodepvars b(%9.3f) legend noabbrev style(tex) constant   ///
	title("Table 8: Firm Level Regressions on Locally-Owned SOE Real Activity Manipulation")   ///
	label stats(N r2 depavg, fmt(%9.0g %9.3g %9.3g) labels("Observations" "R-Squared" "Mean of Dep. Var.")) se  ///
	order(`varlist' /*_cons*/)    ///
	keep( `varlist' /*_cons*/)     ///
	nomtitles  ///
	posthead(	"Dependent Variable & \multicolumn{4}{c}{ Real Activity Manipulation }\\"  ///
				"\hline")  ///
	prefoot(	"\hline" ///
				"Year FEs         & Yes & Yes & Yes & Yes \\"  ///
				"Firm FEs         & Yes & Yes & Yes & Yes \\"  ///
				"Auditor Controls &     & Yes & Yes & Yes \\"  ///
				"Firm Controls    &     &     & Yes & Yes \\"  ///
				"City Controls    &     &     &     & Yes \\"  ///
				"\hline")  ///
	nonotes 	///
	postfoot(	"\hline\hline" ///
				"\end{tabular}}"  ///
				"\captionsetup{justification=justified,labelformat=empty}"  ///
				"\begin{tablenotes}"  ///
				"\item Notes: `cluster' `sample' `sample_1' `depvar' `indepvar' `auditctr' `firmctr' `cityctr' `ctr' `def' `significance'" ///
				"\end{tablenotes}"  ///
				"\end{table}")  ///
	substitute(	\begin{table}[htbp]\centering \begin{table}[p]\centering\captionsetup{width=\textwidth,labelformat=empty}\begin{threeparttable}\footnotesize{ \end{table} \end{threeparttable}\end{table})
	
********************************************************************************
* Table A2: Firm Level Regressions on Locally-Owned SOE Accrual Manipulation
********************************************************************************

local significance = "  \\  Significance: * significant at 10\%; ** significant at 5\%; *** significant at 1\%."
local cluster = "Standard errors clustered by city in parentheses."
local auditctr = "Auditor Controls include $ Gender $, $ Age $, $ Tenure $, $ Tenure^2 $, $ Education $, $ EduFinance $, $ PastAuditor $, $ PastFinance $, $ PastDiscipline $, and $ PastCityLeader $."
local cityctr = "City controls include $ Log(GDP pc) $, $ IndustrialRatio $, $ Log(Population) $, $ Log(GovRev) $, $ GovBalance $, $ FDI/GDP $, and $ AvgEdu $."
local firmctr = "Firm controls include $ log(Assets) $, $ Leverage $, $ ROA $, $ MBRatio $, $ TopOwnership $, $ log(BoardSize) $, $ Dual $, $ Indep\_Ratio $, $ Mgtshare $, and $ Big4Audit $."
local sample = "The sample covers the period from 2006 to 2018."
local depvar = "The dependent variable in all columns is accrual manipulation ($ AM $)."
local indepvar = "$ Hometown $ is an indicator variable denoting that the provincial chief auditor was born in city $ c $."
local def = "See the notes to Table 1 for detailed definitions of the control variables, and the text for further description of real activity manipulation."

local varlist "local_city"
local table = "a2"

local sample_1 = "The sample includes all locally-controlled state-owned enterprises"

preserve
keep if lsoe==1
 
* column 1
reghdfe da_mj local_city , absorb(year firmid) cluster(icity)
* eststo t`table'_col1
su da_mj if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col1
* column 2
reghdfe da_mj local_city $auditorvar , absorb(year firmid) cluster(icity)
* eststo t`table'_col2
su da_mj if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col2
* column 3
reghdfe da_mj local_city $auditorvar $firmvar , absorb(year firmid) cluster(icity)
* eststo t`table'_col3
su da_mj if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col3
* column 4
reghdfe da_mj local_city $auditorvar $firmvar $cityvar , absorb(year firmid) cluster(icity)
* eststo t`table'_col4
su da_mj if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col4
restore

* output to latex
* esttab t`table'_col*  ///
	using `outputdir'tables/t`table'.tex, replace  ///
	star(* 0.10 ** 0.05 *** 0.01) /*plain*/ nogaps   ///
	nodepvars b(%9.3f) legend noabbrev style(tex) constant   ///
	title("Table A2: Firm Level Regressions on Locally-Owned SOE Accrual Manipulation")   ///
	label stats(N r2 depavg, fmt(%9.0g %9.3g %9.3g) labels("Observations" "R-Squared" "Mean of Dep. Var.")) se  ///
	order(`varlist' /*_cons*/)     ///
	keep( `varlist' /*_cons*/)     ///
	nomtitles  ///
	posthead(	"Dependent Variable & \multicolumn{4}{c}{ Accrual Manipulation }\\"  ///
				"\hline")  ///
	prefoot(	"\hline" ///
				"Year FEs         & Yes & Yes & Yes & Yes \\"  ///
				"Firm FEs         & Yes & Yes & Yes & Yes \\"  ///
				"Auditor Controls &     & Yes & Yes & Yes \\"  ///
				"Firm Controls    &     &     & Yes & Yes \\"  ///
				"City Controls    &     &     &     & Yes \\"  ///
				"\hline")  ///
	nonotes 	///
	postfoot(	"\hline\hline" ///
				"\end{tabular}}"  ///
				"\captionsetup{justification=justified,labelformat=empty}"  ///
				"\begin{tablenotes}"  ///
				"\item Notes: `cluster' `sample' `sample_1' `depvar' `indepvar' `auditctr' `firmctr' `cityctr' `ctr' `def' `significance'" ///
				"\end{tablenotes}"  ///
				"\end{table}")  ///
	substitute(	\begin{table}[htbp]\centering \begin{table}[p]\centering\captionsetup{width=\textwidth,labelformat=empty}\begin{threeparttable}\footnotesize{ \end{table} \end{threeparttable}\end{table})
	
/*
********************************************************************************
* Table A3: Firm Level Regressions on Centrally-owned SOE Real Activity Manipulation
********************************************************************************

local significance = "  \\  Significance: * significant at 10\%; ** significant at 5\%; *** significant at 1\%."
local cluster = "Standard errors clustered by city in parentheses."
local auditctr = "Auditor Controls include $ Gender $, $ Age $, $ Tenure $, $ Tenure^2 $, $ Education $, $ EduFinance $, $ PastAuditor $, $ PastFinance $, $ PastDiscipline $, and $ PastCityLeader $."
local cityctr = "City controls include $ Log(GDP pc) $, $ IndustrialRatio $, $ Log(Population) $, $ Log(GovRev) $, $ GovBalance $, $ FDI/GDP $, and $ AvgEdu $."
local firmctr = "Firm controls include $ log(Assets) $, $ Leverage $, $ ROA $, $ MBRatio $, $ TopOwnership $, $ log(BoardSize) $, $ Dual $, $ Indep\_Ratio $, $ Mgtshare $, and $ Big4Audit $."
local sample = "The sample covers the period from 2006 to 2018."
local depvar = "The dependent variable in all columns is real activity manipulation ($ RAM $)."
local indepvar = "$ Hometown $ is an indicator variable denoting that the provincial chief auditor was born in city $ c $."
local def = "See the notes to Table 1 for detailed definitions of the control variables, and the text for further description of real activity manipulation."

local varlist "local_city"
local table = "a3"

local sample_1 = "The sample includes all centrally-controlled state-owned enterprises"

preserve
keep if csoe==1
 
* column 1
reghdfe rm local_city , absorb(year firmid) cluster(icity)
* eststo t`table'_col1
su rm if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col1
* column 2
reghdfe rm local_city $auditorvar , absorb(year firmid) cluster(icity)
* eststo t`table'_col2
su rm if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col2
* column 3
reghdfe rm local_city $auditorvar $firmvar , absorb(year firmid) cluster(icity)
* eststo t`table'_col3
su rm if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col3
* column 4
reghdfe rm local_city $auditorvar $firmvar $cityvar , absorb(year firmid) cluster(icity)
* eststo t`table'_col4
su rm if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col4
restore

* output to latex
* esttab t`table'_col*  ///
	using `outputdir'tables/t`table'.tex, replace  ///
	star(* 0.10 ** 0.05 *** 0.01) /*plain*/ nogaps   ///
	nodepvars b(%9.3f) legend noabbrev style(tex) constant   ///
	title("Table A3: Firm Level Regressions on Centrally-owned SOE Real Activity Manipulation")   ///
	label stats(N r2 depavg, fmt(%9.0g %9.3g %9.3g) labels("Observations" "R-Squared" "Mean of Dep. Var")) se  ///
	order(`varlist' /*_cons*/)     ///
	keep( `varlist' /*_cons*/)     ///
	nomtitles  ///
	posthead(	"Dependent Variable & \multicolumn{4}{c}{ Real Activity Manipulation }\\"  ///
				"\hline")  ///
	prefoot(	"\hline" ///
				"Year FEs         & Yes & Yes & Yes & Yes \\"  ///
				"Firm FEs         & Yes & Yes & Yes & Yes \\"  ///
				"Auditor Controls &     & Yes & Yes & Yes \\"  ///
				"Firm Controls    &     &     & Yes & Yes \\"  ///
				"City Controls    &     &     &     & Yes \\"  ///
				"\hline")  ///
	nonotes 	///
	postfoot(	"\hline\hline" ///
				"\end{tabular}}"  ///
				"\captionsetup{justification=justified,labelformat=empty}"  ///
				"\begin{tablenotes}"  ///
				"\item Notes: `cluster' `sample' `sample_1' `depvar' `indepvar' `auditctr' `firmctr' `cityctr' `ctr' `def' `significance'" ///
				"\end{tablenotes}"  ///
				"\end{table}")  ///
	substitute(	\begin{table}[htbp]\centering \begin{table}[p]\centering\captionsetup{width=\textwidth,labelformat=empty}\begin{threeparttable}\footnotesize{ \end{table} \end{threeparttable}\end{table})
	
********************************************************************************
* Table A4: Firm Level Regressions on non-SOE Real Activity Manipulation
********************************************************************************

use AEJ_firm.dta, clear
keep if soe==0

label var rm "RAM"
label var da_mj "AM"
label var local_city "Hometown"
label var lnta "log(Assets)"
label var lev "Leverage"
label var roa "ROA"
label var mb "MBRatio"
label var largest "TopOwnership"
label var board "log(BoardSize)"
label var dual "Dual"
label var indep "Indep\_Ratio"
label var manshare "Mgtshare"
label var big4 "Big4Audit"


global auditorvar "male age tenure tenure2 edulevel edufin fromaud fromfin fromsup fromcitygov"
global firmvar "lnta lev roa mb largest board dual indep manshare big4"
global cityvar "lngdppc sec lngovrev govbalance finv edu "
global allvar "$auditorvar $firmvar $cityvar"

egen firmid=group(stkcd)

egen icity=group(province city)


local significance = "  \\  Significance: * significant at 10\%; ** significant at 5\%; *** significant at 1\%."
local cluster = "Standard errors clustered by city in parentheses."
local auditctr = "Auditor Controls include $ Gender $, $ Age $, $ Tenure $, $ Tenure^2 $, $ Education $, $ EduFinance $, $ PastAuditor $, $ PastFinance $, $ PastDiscipline $, and $ PastCityLeader $."
local cityctr = "City controls include $ Log(GDP pc) $, $ IndustrialRatio $, $ Log(Population) $, $ Log(GovRev) $, $ GovBalance $, $ FDI/GDP $, and $ AvgEdu $."
local firmctr = "Firm controls include $ log(Assets) $, $ Leverage $, $ ROA $, $ MBRatio $, $ TopOwnership $, $ log(BoardSize) $, $ Dual $, $ Indep\_Ratio $, $ Mgtshare $, and $ Big4Audit $."
local sample = "The sample covers the period from 2006 to 2018."
local depvar = "The dependent variable in all columns is real activity manipulation ($ RAM $)."
local indepvar = "$ Hometown $ is an indicator variable denoting that the provincial chief auditor was born in city $ c $."
local def = "See the notes to Table 1 for detailed definitions of the control variables, and the text for further description of real activity manipulation."

local varlist "local_city"
local table = "a4"

local sample_1 = "The sample includes all non-state-owned (fully private) enterprises"

* column 1
reghdfe rm local_city , absorb(year firmid) cluster(icity)
* eststo t`table'_col1
su rm if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col1
* column 2
reghdfe rm local_city $auditorvar , absorb(year firmid) cluster(icity)
* eststo t`table'_col2
su rm if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col2
* column 3
reghdfe rm local_city $auditorvar $firmvar , absorb(year firmid) cluster(icity)
* eststo t`table'_col3
su rm if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col3
* column 4
reghdfe rm local_city $auditorvar $firmvar $cityvar , absorb(year firmid) cluster(icity)
* eststo t`table'_col4
su rm if e(sample)
scalar ym=r(mean)
* estadd scalar depavg=ym:t`table'_col4

* output to latex
* esttab t`table'_col*  ///
	using `outputdir'tables/t`table'.tex, replace  ///
	star(* 0.10 ** 0.05 *** 0.01) /*plain*/ nogaps   ///
	nodepvars b(%9.3f) legend noabbrev style(tex) constant   ///
	title("Table A4: Firm Level Regressions on non-SOE Real Activity Manipulation")   ///
	label stats(N r2 depavg, fmt(%9.0g %9.3g %9.3g) labels("Observations" "R-Squared" "Mean of Dep. Var")) se  ///
	order(`varlist' /*_cons*/)     ///
	keep( `varlist' /*_cons*/)     ///
	nomtitles  ///
	posthead(	"Dependent Variable & \multicolumn{4}{c}{ Real Activity Manipulation }\\"  ///
				"\hline")  ///
	prefoot(	"\hline" ///
				"Year FEs         & Yes & Yes & Yes & Yes \\"  ///
				"Firm FEs         & Yes & Yes & Yes & Yes \\"  ///
				"Auditor Controls &     & Yes & Yes & Yes \\"  ///
				"Firm Controls    &     &     & Yes & Yes \\"  ///
				"City Controls    &     &     &     & Yes \\"  ///
				"\hline")  ///
	nonotes 	///
	postfoot(	"\hline\hline" ///
				"\end{tabular}}"  ///
				"\captionsetup{justification=justified,labelformat=empty}"  ///
				"\begin{tablenotes}"  ///
				"\item Notes: `cluster' `sample' `sample_1' `depvar' `indepvar' `auditctr' `firmctr' `cityctr' `ctr' `def' `significance'" ///
				"\end{tablenotes}"  ///
				"\end{table}")  ///
	substitute(	\begin{table}[htbp]\centering \begin{table}[p]\centering\captionsetup{width=\textwidth,labelformat=empty}\begin{threeparttable}\footnotesize{ \end{table} \end{threeparttable}\end{table})
*/