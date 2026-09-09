//CovidVsFundingAERAOpemAnalysis.do
//Authors: Mark Weber, Bruce D. Baker
//mark.weber@rutgers.edu
//2-22-25
//This file generates the tables used in "Does School Funding Matter In a Pandemic? COVID-19 Instructional Models and School Funding Adequacy"


//Enter file path here
cd "."

use "FINAL_PANEL_AERAOpen.dta", clear


**********

//TABLE 01
//Descriptive Statistics

putexcel set "CovidVsFundingAdqAERAOpen_FINAL.xlsx", modify sheet("Table01")

putexcel A1=("")
putexcel A2=("")
putexcel A3=("Dependent Variables")
putexcel A4=("Pct. of school time in:")
putexcel A5=("Virtual")
putexcel A6=("Hybrid")
putexcel A7=("In-person")
putexcel A8=("Spending Model")
putexcel A9=("Adjusted Spending per pupil")
putexcel A10=("Enrollment")
putexcel A11=("Pct. Grades 9-12")
putexcel A12=("Pct. ELL")
putexcel A13=("Pct. SWD")
putexcel A14=("Pct. Poverty (age 5-17)")
putexcel A15=("COVID-19 Cases per 100K (county level)")
putexcel A16=("Adequacy Model")
putexcel A17=("NECM Adequacy Gap/Surplus, no race covariate")
putexcel A18=("NECM Adequacy Gap/Surplus, w/race covariate")

putexcel B1="FY2019"
putexcel D1="FY2020"
putexcel F1="FY2021"

putexcel B2="Mean"
putexcel C2="S.D."
putexcel D2="Mean"
putexcel E2="S.D."
putexcel F2="Mean"
putexcel G2="S.D."


local r = 5
foreach v of varlist share_hybrid share_inperson share_virtual normCS_CWIFT enroll pct9to12_ccdpsu pctell_ccdlea pctspeced_ccdlea saipe_perpov cases_per_100k fundgap_1_n fundgap_1_bd {
	
	summarize `v' if normCS_CWIFT <= 50000 & normCS_CWIFT >= 4000 & fundgap_1_n <= 50000 & fundgap_1_n >= -50000 & year == 2019
	local mean = r(mean)
	di `mean'
	putexcel B`r' = (`mean')
	local sd = r(sd)
	di `sd'
	putexcel C`r' = (`sd')
	local r = `r' + 1
	if `r' == 8 {
		local r = `r' + 1
	}
	if `r' == 16 {
		local r = `r' + 1
	}
}


local r = 5
foreach v of varlist share_hybrid share_inperson share_virtual normCS_CWIFT enroll pct9to12_ccdpsu pctell_ccdlea pctspeced_ccdlea saipe_perpov cases_per_100k fundgap_1_n fundgap_1_bd {
	
	summarize `v' if normCS_CWIFT <= 50000 & normCS_CWIFT >= 4000 & fundgap_1_n <= 50000 & fundgap_1_n >= -50000 & year == 2020
	local mean = r(mean)
	di `mean'
	putexcel D`r' = (`mean')
	local sd = r(sd)
	di `sd'
	putexcel E`r' = (`sd')
	local r = `r' + 1
	if `r' == 8 {
		local r = `r' + 1
	}
	if `r' == 16 {
		local r = `r' + 1
	}
}

local r = 5
foreach v of varlist share_hybrid share_inperson share_virtual normCS_CWIFT enroll pct9to12_ccdpsu pctell_ccdlea pctspeced_ccdlea saipe_perpov cases_per_100k fundgap_1_n fundgap_1_bd {
	
	summarize `v' if normCS_CWIFT <= 50000 & normCS_CWIFT >= 4000 & fundgap_1_n <= 50000 & fundgap_1_n >= -50000 & year == 2021
	local mean = r(mean)
	di `mean'
	putexcel F`r' = (`mean')
	local sd = r(sd)
	di `sd'
	putexcel G`r' = (`sd')
	local r = `r' + 1
	if `r' == 8 {
		local r = `r' + 1
	}
	if `r' == 16 {
		local r = `r' + 1
	}
}

foreach col in B C D E {
	forvalue row = 5/7 {
		putexcel `col'`row' = ("-")
	}
}



*********************

//Covid cases changed to per 1,000
replace cases_per_100k = cases_per_100k*.01
rename cases_per_100k cases_per_1000

*** Gap and spending in $1,000 increments (to aid in interpretation)

replace fundgap_1_n = fundgap_1_n/1000
replace fundgap_1_bd = fundgap_1_bd/1000
replace normCS_CWIFT = normCS_CWIFT/1000


*********************

//AUX TABLE 03 
//Correlations table

putexcel set "CovidVsFundingAdqAERAOpen_FINAL.xlsx", modify sheet("AppendixTable03Data")

pwcorr ln_enroll pct9to12_ccdpsu pctell_ccdlea pctspeced_ccdlea saipe_perpov cases_per_1000 fundgap_1_n fundgap_1_bd, star(0.05)

matrix list r(C)
putexcel A1=matrix(r(C)), names



*********************

//TABLE 02
//Spending and Adequacy Models' Estimates

//Set up estimate table

putexcel set "CovidVsFundingAdqAERAOpen_FINAL.xlsx", modify sheet("Table02")

putexcel A1 = ""
putexcel A4 = "Spending per pupil ($1,000s)"
putexcel A5 = "NECM Adequacy Gap/Surplus per pupil ($1,000s)"
putexcel A6 = "Enrollment (natural log)"
putexcel A7 = "Pct. Enrolled Grades 9-12"
putexcel A8 = "ELL Pct."
putexcel A9 = "SWD pct."
putexcel A10 = "SAIPE Poverty pct."
putexcel A11 = "Covid Cases per 1000 (county-level, interacted w/state FE)"
putexcel A12 = "Constant"
putexcel A13 = "N"
putexcel A14 = "R-sq."
putexcel A15 = "Note: SEs clustered at the county level."
putexcel A16 = ("*** p<0.01, ** p<0.05, * p<0.1")

putexcel B3 = ("Spending Model 1")
putexcel C3 = ("Spending Model 2")
putexcel D3 = ("NECM Adequacy Gap/Surplus Model")
putexcel E3 = ("NECM Adequacy Gap/Surplus Model, w/race covariate")

putexcel B1 = ("Dependent Variable: Pct. Of Time In Virtual Instruction")
putexcel B2 = ("FY 2019")


*** Current Spending. Model 1 (normalized by CWIFT)

reg share_virtual normCS_CWIFT i.StateEncode##c.cases_per_1000 ln_enroll pct9to12_ccdpsu pctell_ccdlea pctspeced_ccdlea saipe_perpov if normCS_CWIFT <= 50 & normCS_CWIFT >= 4 & fundgap_1_n <= 50  & fundgap_1_n >= -50 & year == 2019, cluster(fips_code)

local est : di %6.3f _b[normCS_CWIFT]
local se : di %6.3f _se[normCS_CWIFT]
test normCS_CWIFT
local p =r(p)
local stars = ""
	if `p' < 0.01 {
		local stars = "***"
		}
	else if `p' < 0.05 {
		local stars = "**"
		}
	else if `p' < 0.1 {
		local stars = "*"
	}	
local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
di "`output'"
putexcel B4=("`output'")


putexcel B5=("-")
local rsq : di %6.3f e(r2)
putexcel B14=("`rsq'")
putexcel B13=`e(N)'

local row = 6
foreach v in ln_enroll pct9to12_ccdpsu pctell_ccdlea pctspeced_ccdlea saipe_perpov cases_per_1000 _cons {
	local est : di %6.3f _b[`v']
	di "`est'"
	local se : di %6.3f _se[`v']
	di "`se'"
	test `v'
	local p =r(p)
	local stars = ""
		if `p' < 0.01 {
			local stars = "***"
			}
		else if `p' < 0.05 {
			local stars = "**"
		}
		else if `p' < 0.1 {
			local stars = "*"
		}
		display "`stars'"
		
	local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
	di "`output'"
	putexcel B`row'=("`output'")
	local row = `row' + 1
}


*** Current Spending. Model 2 (normalized by CWIFT)

reg share_virtual normCS_CWIFT i.StateEncode##c.cases_per_1000 ln_enroll pct9to12_ccdpsu pctell_ccdlea saipe_perpov if normCS_CWIFT <= 50 & normCS_CWIFT >= 4 & fundgap_1_n <= 50  & fundgap_1_n >= -50 & year == 2019, cluster(fips_code)

local est : di %6.3f _b[normCS_CWIFT]
local se : di %6.3f _se[normCS_CWIFT]
test normCS_CWIFT
local p =r(p)
local stars = ""
	if `p' < 0.01 {
		local stars = "***"
		}
	else if `p' < 0.05 {
		local stars = "**"
		}
	else if `p' < 0.1 {
		local stars = "*"
	}	
local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
di "`output'"
putexcel C4=("`output'")


putexcel C5=("-")
local rsq : di %6.3f e(r2)
putexcel C14=("`rsq'")
putexcel C13=`e(N)'

local row = 6
foreach v in ln_enroll pct9to12_ccdpsu pctell_ccdlea {
	local est : di %6.3f _b[`v']
	di "`est'"
	local se : di %6.3f _se[`v']
	di "`se'"
	test `v'
	local p =r(p)
	local stars = ""
		if `p' < 0.01 {
			local stars = "***"
			}
		else if `p' < 0.05 {
			local stars = "**"
		}
		else if `p' < 0.1 {
			local stars = "*"
		}
		display "`stars'"
		
	local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
	di "`output'"
	putexcel C`row'=("`output'")
	local row = `row' + 1
}

putexcel C9=("-")

local row = 10
foreach v in saipe_perpov cases_per_1000 _cons {
	local est : di %6.3f _b[`v']
	di "`est'"
	local se : di %6.3f _se[`v']
	di "`se'"
	test `v'
	local p =r(p)
	local stars = ""
		if `p' < 0.01 {
			local stars = "***"
			}
		else if `p' < 0.05 {
			local stars = "**"
		}
		else if `p' < 0.1 {
			local stars = "*"
		}
		display "`stars'"
		
	local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
	di "`output'"
	putexcel C`row'=("`output'")
	local row = `row' + 1
}


*** Adequacy Gap (via NECM model, no race covariate).

reg share_virtual fundgap_1_n i.StateEncode##c.cases_per_1000 if normCS_CWIFT <= 50 & normCS_CWIFT >= 4 & fundgap_1_n <= 50  & fundgap_1_n >= -50 & year == 2019, cluster(fips_code)

local est : di %6.3f _b[fundgap_1_n]
local se : di %6.3f _se[fundgap_1_n]
test fundgap_1_n
local p =r(p)
local stars = ""
	if `p' < 0.01 {
		local stars = "***"
		}
	else if `p' < 0.05 {
		local stars = "**"
		}
	else if `p' < 0.1 {
		local stars = "*"
	}	
local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
di "`output'"
putexcel D5=("`output'")

putexcel D4=("-")
local rsq : di %6.3f e(r2)
putexcel D14=("`rsq'")
putexcel D13=`e(N)'

local row = 11
foreach v in cases_per_1000 _cons {
	local est : di %6.3f _b[`v']
	di "`est'"
	local se : di %6.3f _se[`v']
	di "`se'"
	test `v'
	local p =r(p)
	local stars = ""
		if `p' < 0.01 {
			local stars = "***"
			}
		else if `p' < 0.05 {
			local stars = "**"
		}
		else if `p' < 0.1 {
			local stars = "*"
		}
		display "`stars'"
		
	local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
	di "`output'"
	putexcel D`row'=("`output'")
	local row = `row' + 1
}

forvalue row = 6/10 {
	putexcel D`row'=("-")
}



*** Adequacy Gap (via NECM model, WITH race covariate (black)).

eststo: reg share_virtual fundgap_1_bd i.StateEncode##c.cases_per_1000 if normCS_CWIFT <= 50 & normCS_CWIFT >= 4 & fundgap_1_n <= 50  & fundgap_1_n >= -50  & year == 2019, cluster(fips_code)

local est : di %6.3f _b[fundgap_1_bd]
local se : di %6.3f _se[fundgap_1_bd]
test fundgap_1_bd
local p =r(p)
local stars = ""
	if `p' < 0.01 {
		local stars = "***"
		}
	else if `p' < 0.05 {
		local stars = "**"
		}
	else if `p' < 0.1 {
		local stars = "*"
	}	
local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
di "`output'"
putexcel E5=("`output'")

putexcel E4=("-")
local rsq : di %6.3f e(r2)
putexcel E14=("`rsq'")
putexcel E13=`e(N)'

local row = 11
foreach v in cases_per_1000 _cons {
	local est : di %6.3f _b[`v']
	di "`est'"
	local se : di %6.3f _se[`v']
	di "`se'"
	test `v'
	local p =r(p)
	local stars = ""
		if `p' < 0.01 {
			local stars = "***"
			}
		else if `p' < 0.05 {
			local stars = "**"
		}
		else if `p' < 0.1 {
			local stars = "*"
		}
		display "`stars'"
		
	local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
	di "`output'"
	putexcel E`row'=("`output'")
	local row = `row' + 1
}

forvalue row = 6/10 {
	putexcel E`row'=("-")
}

*** EDITED by Donna
estout using "../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
save final.dta, replace
***

*****************************************************


//TABLE 03
///Spending and Adequacy Models' Estimates, Across Three Years and In a 3-Year Panel


//Set up estimate table

putexcel set "CovidVsFundingAdqAERAOpen_FINAL.xlsx", modify sheet("Table03")

putexcel A1 = ""
putexcel A2 = ""
putexcel A3 = ""
putexcel A4 = "Spending per pupil ($1,000s)"
putexcel A5 = "NECM Adequacy Gap/Surplus per pupil ($1,000s)"
putexcel A6 = "Enrollment (natural log)"
putexcel A7 = "Pct. Enrolled Grades 9-12"
putexcel A8 = "ELL Pct."
putexcel A9 = "SAIPE Poverty pct."
putexcel A10 = "Covid Cases per 1000 (county-level, interacted w/state FE)"
putexcel A11 = "Constant"
putexcel A12 = "Year"
putexcel A13 = "N"
putexcel A14 = "R-sq."
putexcel A15 = "Note: SEs clustered at the county level."

putexcel B1 = ("Dependent Variable: Pct. Of Time In Virtual Instruction")
putexcel B2 = ("FY 2019")
putexcel D2 = ("FY 2020")
putexcel F2 = ("FY 2021")
putexcel H2 = ("3-Year Panel")

putexcel B3 = ("Spending Model 2")
putexcel C3 = ("NECM Adequacy Gap/Surplus Model, w/race covariate")
putexcel D3 = ("Spending Model 2")
putexcel E3 = ("NECM Adequacy Gap/Surplus Model, w/race covariate")
putexcel F3 = ("Spending Model 2")
putexcel G3 = ("NECM Adequacy Gap/Surplus Model, w/race covariate")
putexcel H3 = ("Spending Model 2")
putexcel I3 = ("NECM Adequacy Gap/Surplus Model, w/race covariate")




*** Current Spending. Model 2 (normalized by CWIFT)

foreach y in 2019 2020 2021 {

	if `y' == 2019 {
		local col = "B"
	} 
	else if `y' == 2020 {
		local col = "D"
	}
	else if `y' == 2021 {
		local col = "F"
	}	
	
	reg share_virtual normCS_CWIFT i.StateEncode##c.cases_per_1000 ln_enroll pct9to12_ccdpsu pctell_ccdlea saipe_perpov if normCS_CWIFT <= 50 & normCS_CWIFT >= 4 & fundgap_1_n <= 50  & fundgap_1_n >= -50 & year == `y', cluster(fips_code)

	local est : di %6.3f _b[normCS_CWIFT]
	local se : di %6.3f _se[normCS_CWIFT]
	test normCS_CWIFT
	local p =r(p)
	local stars = ""
		if `p' < 0.01 {
			local stars = "***"
			}
		else if `p' < 0.05 {
			local stars = "**"
			}
		else if `p' < 0.1 {
			local stars = "*"
		}	
	local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
	di "`output'"
	putexcel `col'4=("`output'")


	putexcel `col'5=("-")
	local rsq : di %6.3f e(r2)
	putexcel `col'14=("`rsq'")
	putexcel `col'13=`e(N)'

	local row = 6
	foreach v in ln_enroll pct9to12_ccdpsu pctell_ccdlea saipe_perpov cases_per_1000 _cons {
		local est : di %6.3f _b[`v']
		di "`est'"
		local se : di %6.3f _se[`v']
		di "`se'"
		test `v'
		local p =r(p)
		local stars = ""
			if `p' < 0.01 {
				local stars = "***"
				}
			else if `p' < 0.05 {
				local stars = "**"
			}
			else if `p' < 0.1 {
				local stars = "*"
			}
			display "`stars'"
			
		local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
		di "`output'"
		putexcel `col'`row'=("`output'")
		local row = `row' + 1
	}
	
	putexcel `col'12 = ("-")
	
}


//Panel, with linear year


	reg share_virtual normCS_CWIFT i.StateEncode##c.cases_per_1000 ln_enroll pct9to12_ccdpsu pctell_ccdlea saipe_perpov year_encode if normCS_CWIFT <= 50 & normCS_CWIFT >= 4 & fundgap_1_n <= 50  & fundgap_1_n >= -50, cluster(fips_code)

	local col = "H"
	local est : di %6.3f _b[normCS_CWIFT]
	local se : di %6.3f _se[normCS_CWIFT]
	test normCS_CWIFT
	local p =r(p)
	local stars = ""
		if `p' < 0.01 {
			local stars = "***"
			}
		else if `p' < 0.05 {
			local stars = "**"
			}
		else if `p' < 0.1 {
			local stars = "*"
		}	
	local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
	di "`output'"
	putexcel `col'4=("`output'")


	putexcel `col'5=("-")
	local rsq : di %6.3f e(r2)
	putexcel `col'14=("`rsq'")
	putexcel `col'13=`e(N)'

	local row = 6
	foreach v in ln_enroll pct9to12_ccdpsu pctell_ccdlea saipe_perpov cases_per_1000 _cons year_encode {
		local est : di %6.3f _b[`v']
		di "`est'"
		local se : di %6.3f _se[`v']
		di "`se'"
		test `v'
		local p =r(p)
		local stars = ""
			if `p' < 0.01 {
				local stars = "***"
				}
			else if `p' < 0.05 {
				local stars = "**"
			}
			else if `p' < 0.1 {
				local stars = "*"
			}
			display "`stars'"
			
		local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
		di "`output'"
		putexcel `col'`row'=("`output'")
		local row = `row' + 1
	}
	

*** Adequacy Gap (via Baker model, WITH race covariate (black)).

foreach y in 2019 2020 2021 {

		if `y' == 2019 {
			local col = "C"
		} 
		else if `y' == 2020 {
			local col = "E"
		}
		else if `y' == 2021 {
			local col = "G"
		}	
		
	reg share_virtual fundgap_1_bd i.StateEncode##c.cases_per_1000 if normCS_CWIFT <= 50 & normCS_CWIFT >= 4 & fundgap_1_n <= 50  & fundgap_1_n >= -50  & year == `y', cluster(fips_code)


	local est : di %6.3f _b[fundgap_1_bd]
	local se : di %6.3f _se[fundgap_1_bd]
	test fundgap_1_bd
	local p =r(p)
	local stars = ""
		if `p' < 0.01 {
			local stars = "***"
			}
		else if `p' < 0.05 {
			local stars = "**"
			}
		else if `p' < 0.1 {
			local stars = "*"
		}	
	local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
	di "`output'"
	putexcel `col'5=("`output'")

	putexcel `col'4=("-")
	local rsq : di %6.3f e(r2)
	putexcel `col'14=("`rsq'")
	putexcel `col'13=`e(N)'

	local row = 10
	foreach v in cases_per_1000 _cons {
		local est : di %6.3f _b[`v']
		di "`est'"
		local se : di %6.3f _se[`v']
		di "`se'"
		test `v'
		local p =r(p)
		local stars = ""
			if `p' < 0.01 {
				local stars = "***"
				}
			else if `p' < 0.05 {
				local stars = "**"
			}
			else if `p' < 0.1 {
				local stars = "*"
			}
			display "`stars'"
			
		local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
		di "`output'"
		putexcel `col'`row'=("`output'")
		local row = `row' + 1
	}

	forvalue row = 6/9 {
		putexcel `col'`row'=("-")
	}

	putexcel `col'12=("-")
}


//Panel, with linear year

	reg share_virtual fundgap_1_bd i.StateEncode##c.cases_per_1000 year_encode if normCS_CWIFT <= 50 & normCS_CWIFT >= 4 & fundgap_1_n <= 50  & fundgap_1_n >= -50, cluster(fips_code)

	local col = "I"
	local est : di %6.3f _b[fundgap_1_bd]
	local se : di %6.3f _se[fundgap_1_bd]
	test fundgap_1_bd
	local p =r(p)
	local stars = ""
		if `p' < 0.01 {
			local stars = "***"
			}
		else if `p' < 0.05 {
			local stars = "**"
			}
		else if `p' < 0.1 {
			local stars = "*"
		}	
	local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
	di "`output'"
	putexcel `col'5=("`output'")

	putexcel `col'4=("-")
	local rsq : di %6.3f e(r2)
	putexcel `col'14=("`rsq'")
	putexcel `col'13=`e(N)'

	local row = 10
	foreach v in cases_per_1000 _cons year_encode {
		local est : di %6.3f _b[`v']
		di "`est'"
		local se : di %6.3f _se[`v']
		di "`se'"
		test `v'
		local p =r(p)
		local stars = ""
			if `p' < 0.01 {
				local stars = "***"
				}
			else if `p' < 0.05 {
				local stars = "**"
			}
			else if `p' < 0.1 {
				local stars = "*"
			}
			display "`stars'"
			
		local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
		di "`output'"
		putexcel `col'`row'=("`output'")
		local row = `row' + 1
	}

	forvalue row = 6/9 {
		putexcel `col'`row'=("-")
	}



*****************************************************


//TABLE 04
//Adequacy Model Estimates With Three Dependent Variables

putexcel set "CovidVsFundingAdqAERAOpen_FINAL.xlsx", modify sheet("Table04")

putexcel A1=("")
putexcel A2=("")
putexcel A3=("NECM Adequacy Gap/Surplus per pupil ($1,000s)")
putexcel A4=("Year")
putexcel A5=("Constant")
putexcel A6=("N")
putexcel A7=("R-sq")

putexcel B1=("FY2019")
putexcel E1=("3-Year Panel")
putexcel B2=("Pct. Virtual")
putexcel C2=("Pct. Hybrid")
putexcel D2=("Pct. In-Person")
putexcel E2=("Pct. Virtual")
putexcel F2=("Pct. Hybrid")
putexcel G2=("Pct. In-Person")


//FY2019


foreach dv in share_virtual share_hybrid share_inperson {
	
	if "`dv'" == "share_virtual" {
		local col = "B"
	}
	else if "`dv'" == "share_hybrid" {
		local col = "C"
	}
	else if "`dv'" == "share_inperson" {
		local col = "D"
	}


	reg `dv' fundgap_1_bd i.StateEncode##c.cases_per_1000 if normCS_CWIFT <= 50 & normCS_CWIFT >= 4 & fundgap_1_n <= 50  & fundgap_1_n >= -50 & year == 2019, cluster(fips_code)

	local est : di %6.3f _b[fundgap_1_bd]
	local se : di %6.3f _se[fundgap_1_bd]
	test fundgap_1_bd
	local p =r(p)
	local stars = ""
		if `p' < 0.01 {
			local stars = "***"
			}
		else if `p' < 0.05 {
			local stars = "**"
			}
		else if `p' < 0.1 {
			local stars = "*"
		}	
	local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
	di "`output'"
	putexcel `col'3=("`output'")

	local rsq : di %6.3f e(r2)
	putexcel `col'7=("`rsq'")
	putexcel `col'6=`e(N)'

	foreach v in _cons {
		local est : di %6.3f _b[`v']
		di "`est'"
		local se : di %6.3f _se[`v']
		di "`se'"
		test `v'
		local p =r(p)
		local stars = ""
			if `p' < 0.01 {
				local stars = "***"
				}
			else if `p' < 0.05 {
				local stars = "**"
			}
			else if `p' < 0.1 {
				local stars = "*"
			}
			display "`stars'"
			
		local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
		di "`output'"
		putexcel `col'5=("`output'")
	}
	putexcel `col'4=("-")
}


//Three Year Panel


foreach dv in share_virtual share_hybrid share_inperson {
	
	if "`dv'" == "share_virtual" {
		local col = "E"
	}
	else if "`dv'" == "share_hybrid" {
		local col = "F"
	}
	else if "`dv'" == "share_inperson" {
		local col = "G"
	}


	reg `dv' fundgap_1_bd i.StateEncode##c.cases_per_1000 year_encode if normCS_CWIFT <= 50 & normCS_CWIFT >= 4 & fundgap_1_n <= 50  & fundgap_1_n >= -50, cluster(fips_code)

	local est : di %6.3f _b[fundgap_1_bd]
	local se : di %6.3f _se[fundgap_1_bd]
	test fundgap_1_bd
	local p =r(p)
	local stars = ""
		if `p' < 0.01 {
			local stars = "***"
			}
		else if `p' < 0.05 {
			local stars = "**"
			}
		else if `p' < 0.1 {
			local stars = "*"
		}	
	local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
	di "`output'"
	putexcel `col'3=("`output'")

	local rsq : di %6.3f e(r2)
	putexcel `col'7=("`rsq'")
	putexcel `col'6=`e(N)'

	local row = 4
	foreach v in year_encode _cons {
		local est : di %6.3f _b[`v']
		di "`est'"
		local se : di %6.3f _se[`v']
		di "`se'"
		test `v'
		local p =r(p)
		local stars = ""
			if `p' < 0.01 {
				local stars = "***"
				}
			else if `p' < 0.05 {
				local stars = "**"
			}
			else if `p' < 0.1 {
				local stars = "*"
			}
			display "`stars'"
			
		local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
		di "`output'"
		putexcel `col'`row'=("`output'")
	}
}



*************************************************

//APPENDIX TABLE 02
//Pandemic Instruction Spending Models With a Linear Time Variable vs. a Year Fixed Effect.


//Set up estimate table

putexcel set "CovidVsFundingAdqAERAOpen_FINAL.xlsx", modify sheet("AppendixTable02")

putexcel A1 = ""
putexcel A2 = ""
putexcel A3 = "Spending per pupil ($1,000s)"
putexcel A4 = "Enrollment (natural log)"
putexcel A5 = "Pct. Enrolled Grades 9-12"
putexcel A6 = "ELL Pct."
putexcel A7 = "SAIPE Poverty pct."
putexcel A8 = "Covid Cases per 1000 (county-level, interacted w/state FE)"

putexcel A9 = "2020"
putexcel A10 = "2021"
putexcel A11 = "Year (linear)"


putexcel A12 = "Constant"
putexcel A13 = "N"
putexcel A14 = "R-sq."
putexcel A15 = "Note: SEs clustered at the county level."

putexcel B1 = ("Dependent Variable: Pct. Of Time In Virtual Instruction")
putexcel B2 = ("Spending Model 2, Linear Year")
putexcel C2 = ("Spending Model 2, Year FE")



//Spending Panel, with linear year 


	reg share_virtual normCS_CWIFT i.StateEncode##c.cases_per_1000 ln_enroll pct9to12_ccdpsu pctell_ccdlea saipe_perpov year_encode if normCS_CWIFT <= 50 & normCS_CWIFT >= 4 & fundgap_1_n <= 50  & fundgap_1_n >= -50, cluster(fips_code)

	local col = "B"
	local est : di %6.3f _b[normCS_CWIFT]
	local se : di %6.3f _se[normCS_CWIFT]
	test normCS_CWIFT
	local p =r(p)
	local stars = ""
		if `p' < 0.01 {
			local stars = "***"
			}
		else if `p' < 0.05 {
			local stars = "**"
			}
		else if `p' < 0.1 {
			local stars = "*"
		}	
	local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
	di "`output'"
	putexcel `col'3=("`output'")

	local rsq : di %6.3f e(r2)
	putexcel `col'14=("`rsq'")
	putexcel `col'13=`e(N)'

	local row = 4
	foreach v in ln_enroll pct9to12_ccdpsu pctell_ccdlea saipe_perpov cases_per_1000{
		local est : di %6.3f _b[`v']
		di "`est'"
		local se : di %6.3f _se[`v']
		di "`se'"
		test `v'
		local p =r(p)
		local stars = ""
			if `p' < 0.01 {
				local stars = "***"
				}
			else if `p' < 0.05 {
				local stars = "**"
			}
			else if `p' < 0.1 {
				local stars = "*"
			}
			display "`stars'"
			
		local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
		di "`output'"
		putexcel `col'`row'=("`output'")
		local row = `row' + 1
	}
	
		local row = 11
	foreach v in year_encode _cons {
		local est : di %6.3f _b[`v']
		di "`est'"
		local se : di %6.3f _se[`v']
		di "`se'"
		test `v'
		local p =r(p)
		local stars = ""
			if `p' < 0.01 {
				local stars = "***"
				}
			else if `p' < 0.05 {
				local stars = "**"
			}
			else if `p' < 0.1 {
				local stars = "*"
			}
			display "`stars'"
			
		local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
		di "`output'"
		putexcel `col'`row'=("`output'")
		local row = `row' + 1
	}
	
putexcel B9=("-")
putexcel B10=("-")



//Spending Panel, with year FE


	reg share_virtual normCS_CWIFT i.StateEncode##c.cases_per_1000 ln_enroll pct9to12_ccdpsu pctell_ccdlea saipe_perpov i.year_encode if normCS_CWIFT <= 50 & normCS_CWIFT >= 4 & fundgap_1_n <= 50  & fundgap_1_n >= -50, cluster(fips_code)

	local col = "C"
	local est : di %6.3f _b[normCS_CWIFT]
	local se : di %6.3f _se[normCS_CWIFT]
	test normCS_CWIFT
	local p =r(p)
	local stars = ""
		if `p' < 0.01 {
			local stars = "***"
			}
		else if `p' < 0.05 {
			local stars = "**"
			}
		else if `p' < 0.1 {
			local stars = "*"
		}	
	local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
	di "`output'"
	putexcel `col'3=("`output'")

	local rsq : di %6.3f e(r2)
	putexcel `col'14=("`rsq'")
	putexcel `col'13=`e(N)'

	local row = 4
	foreach v in ln_enroll pct9to12_ccdpsu pctell_ccdlea saipe_perpov cases_per_1000 {
		local est : di %6.3f _b[`v']
		di "`est'"
		local se : di %6.3f _se[`v']
		di "`se'"
		test `v'
		local p =r(p)
		local stars = ""
			if `p' < 0.01 {
				local stars = "***"
				}
			else if `p' < 0.05 {
				local stars = "**"
			}
			else if `p' < 0.1 {
				local stars = "*"
			}
			display "`stars'"
			
		local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
		di "`output'"
		putexcel `col'`row'=("`output'")
		local row = `row' + 1
	}
	
		local row = 9
	foreach v in 2.year_encode 3.year_encode {
		local est : di %6.3f _b[`v']
		di "`est'"
		local se : di %6.3f _se[`v']
		di "`se'"
		test `v'
		local p =r(p)
		local stars = ""
			if `p' < 0.01 {
				local stars = "***"
				}
			else if `p' < 0.05 {
				local stars = "**"
			}
			else if `p' < 0.1 {
				local stars = "*"
			}
			display "`stars'"
			
		local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
		di "`output'"
		putexcel `col'`row'=("`output'")
		local row = `row' + 1
	}
	
	
	local row = 12
	foreach v in _cons {
		local est : di %6.3f _b[`v']
		di "`est'"
		local se : di %6.3f _se[`v']
		di "`se'"
		test `v'
		local p =r(p)
		local stars = ""
			if `p' < 0.01 {
				local stars = "***"
				}
			else if `p' < 0.05 {
				local stars = "**"
			}
			else if `p' < 0.1 {
				local stars = "*"
			}
			display "`stars'"
			
		local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
		di "`output'"
		putexcel `col'`row'=("`output'")
		local row = `row' + 1
	}
	
putexcel C11=("-")


*****************************************



//APPENDIX TABLE 04
//Spending and Adequacy Models With and Without State Fixed Effects


//Set up estimate table

putexcel set "CovidVsFundingAdqAERAOpen_FINAL.xlsx", modify sheet("AppendixTable04")

putexcel A1 = ""
putexcel A2 = ""
putexcel A3 = "Spending per pupil ($1,000s)"
putexcel A5 = "Enrollment (natural log)"
putexcel A6 = "Pct. Enrolled Grades 9-12"
putexcel A7 = "ELL Pct."
putexcel A8 = "SAIPE Poverty pct."
putexcel A9 = "Covid Cases per 1000 (county-level, interacted w/state FE when included)"
putexcel A10 = "Year (linear)"


putexcel A11 = "Constant"
putexcel A12 = "N"
putexcel A13 = "R-sq."
putexcel A14 = "Note: SEs clustered at the county level."
putexcel A15 = "*** p<0.01, ** p<0.05, * p<0.1"

putexcel B1 = ("Dependent Variable: Pct. Of Time In Virtual Instruction")
putexcel B2 = ("Spending Model 1, With State FE")
putexcel C2 = ("Spending Model 1, No State FE")
putexcel D2 = ("NEMC Adequacy Gap/Surplus Model 2, With State FE")
putexcel E2 = ("NEMC Adequacy Gap/Surplus Model 2, No State FE")



//Spending, w/state FE

	reg share_virtual normCS_CWIFT i.StateEncode##c.cases_per_1000 ln_enroll pct9to12_ccdpsu pctell_ccdlea saipe_perpov year_encode if normCS_CWIFT <= 50 & normCS_CWIFT >= 4 & fundgap_1_n <= 50  & fundgap_1_n >= -50, cluster(fips_code)


local col = "B"
	local est : di %6.3f _b[normCS_CWIFT]
	local se : di %6.3f _se[normCS_CWIFT]
	test normCS_CWIFT
	local p =r(p)
	local stars = ""
		if `p' < 0.01 {
			local stars = "***"
			}
		else if `p' < 0.05 {
			local stars = "**"
			}
		else if `p' < 0.1 {
			local stars = "*"
		}	
	local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
	di "`output'"
	putexcel `col'3=("`output'")

	local rsq : di %6.3f e(r2)
	putexcel `col'13=("`rsq'")
	putexcel `col'12=`e(N)'
	
	putexcel `col'4=("-")

	local row = 5
	foreach v in ln_enroll pct9to12_ccdpsu pctell_ccdlea saipe_perpov cases_per_1000 {
		local est : di %6.3f _b[`v']
		di "`est'"
		local se : di %6.3f _se[`v']
		di "`se'"
		test `v'
		local p =r(p)
		local stars = ""
			if `p' < 0.01 {
				local stars = "***"
				}
			else if `p' < 0.05 {
				local stars = "**"
			}
			else if `p' < 0.1 {
				local stars = "*"
			}
			display "`stars'"
			
		local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
		di "`output'"
		putexcel `col'`row'=("`output'")
		local row = `row' + 1
	}
	
		local row = 9
	foreach v in year_encode _cons {
		local est : di %6.3f _b[`v']
		di "`est'"
		local se : di %6.3f _se[`v']
		di "`se'"
		test `v'
		local p =r(p)
		local stars = ""
			if `p' < 0.01 {
				local stars = "***"
				}
			else if `p' < 0.05 {
				local stars = "**"
			}
			else if `p' < 0.1 {
				local stars = "*"
			}
			display "`stars'"
			
		local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
		di "`output'"
		putexcel `col'`row'=("`output'")
		local row = `row' + 1
	}
	


//Spending, NO state FE

	reg share_virtual normCS_CWIFT c.cases_per_1000 ln_enroll pct9to12_ccdpsu pctell_ccdlea saipe_perpov year_encode if normCS_CWIFT <= 50 & normCS_CWIFT >= 4 & fundgap_1_n <= 50  & fundgap_1_n >= -50, cluster(fips_code)


local col = "C"
	local est : di %6.3f _b[normCS_CWIFT]
	local se : di %6.3f _se[normCS_CWIFT]
	test normCS_CWIFT
	local p =r(p)
	local stars = ""
		if `p' < 0.01 {
			local stars = "***"
			}
		else if `p' < 0.05 {
			local stars = "**"
			}
		else if `p' < 0.1 {
			local stars = "*"
		}	
	local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
	di "`output'"
	putexcel `col'3=("`output'")

	local rsq : di %6.3f e(r2)
	putexcel `col'13=("`rsq'")
	putexcel `col'12=`e(N)'
	
	putexcel `col'4=("-")

	local row = 5
	foreach v in ln_enroll pct9to12_ccdpsu pctell_ccdlea saipe_perpov cases_per_1000 {
		local est : di %6.3f _b[`v']
		di "`est'"
		local se : di %6.3f _se[`v']
		di "`se'"
		test `v'
		local p =r(p)
		local stars = ""
			if `p' < 0.01 {
				local stars = "***"
				}
			else if `p' < 0.05 {
				local stars = "**"
			}
			else if `p' < 0.1 {
				local stars = "*"
			}
			display "`stars'"
			
		local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
		di "`output'"
		putexcel `col'`row'=("`output'")
		local row = `row' + 1
	}
	
		local row = 9
	foreach v in year_encode _cons {
		local est : di %6.3f _b[`v']
		di "`est'"
		local se : di %6.3f _se[`v']
		di "`se'"
		test `v'
		local p =r(p)
		local stars = ""
			if `p' < 0.01 {
				local stars = "***"
				}
			else if `p' < 0.05 {
				local stars = "**"
			}
			else if `p' < 0.1 {
				local stars = "*"
			}
			display "`stars'"
			
		local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
		di "`output'"
		putexcel `col'`row'=("`output'")
		local row = `row' + 1
	}
	


//Adequacy, w/state FE
	
	reg share_virtual fundgap_1_bd i.StateEncode##c.cases_per_1000 year_encode if normCS_CWIFT <= 50 & normCS_CWIFT >= 4 & fundgap_1_n <= 50  & fundgap_1_n >= -50, cluster(fips_code)

putexcel D3 = ("-")

local col = "D"
	local est : di %6.3f _b[fundgap_1_bd]
	local se : di %6.3f _se[fundgap_1_bd]
	test fundgap_1_bd
	local p =r(p)
	local stars = ""
		if `p' < 0.01 {
			local stars = "***"
			}
		else if `p' < 0.05 {
			local stars = "**"
			}
		else if `p' < 0.1 {
			local stars = "*"
		}	
	local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
	di "`output'"
	putexcel `col'4=("`output'")

	local rsq : di %6.3f e(r2)
	putexcel `col'13=("`rsq'")
	putexcel `col'12=`e(N)'
	
	putexcel `col'5=("-")
	putexcel `col'6=("-")
	putexcel `col'7=("-")
	putexcel `col'8=("-")

	local row = 9
	foreach v in cases_per_1000 year_encode _cons {
		local est : di %6.3f _b[`v']
		di "`est'"
		local se : di %6.3f _se[`v']
		di "`se'"
		test `v'
		local p =r(p)
		local stars = ""
			if `p' < 0.01 {
				local stars = "***"
				}
			else if `p' < 0.05 {
				local stars = "**"
			}
			else if `p' < 0.1 {
				local stars = "*"
			}
			display "`stars'"
			
		local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
		di "`output'"
		putexcel `col'`row'=("`output'")
		local row = `row' + 1
	}
	


//Adequacy, NO state FE
	
	reg share_virtual fundgap_1_bd c.cases_per_1000 year_encode if normCS_CWIFT <= 50 & normCS_CWIFT >= 4 & fundgap_1_n <= 50  & fundgap_1_n >= -50, cluster(fips_code)

putexcel D3 = ("-")

local col = "E"
	local est : di %6.3f _b[fundgap_1_bd]
	local se : di %6.3f _se[fundgap_1_bd]
	test fundgap_1_bd
	local p =r(p)
	local stars = ""
		if `p' < 0.01 {
			local stars = "***"
			}
		else if `p' < 0.05 {
			local stars = "**"
			}
		else if `p' < 0.1 {
			local stars = "*"
		}	
	local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
	di "`output'"
	putexcel `col'4=("`output'")

	local rsq : di %6.3f e(r2)
	putexcel `col'13=("`rsq'")
	putexcel `col'12=`e(N)'
	
	putexcel `col'5=("-")
	putexcel `col'6=("-")
	putexcel `col'7=("-")
	putexcel `col'8=("-")

	local row = 9
	foreach v in cases_per_1000 year_encode _cons {
		local est : di %6.3f _b[`v']
		di "`est'"
		local se : di %6.3f _se[`v']
		di "`se'"
		test `v'
		local p =r(p)
		local stars = ""
			if `p' < 0.01 {
				local stars = "***"
				}
			else if `p' < 0.05 {
				local stars = "**"
			}
			else if `p' < 0.1 {
				local stars = "*"
			}
			display "`stars'"
			
		local output = "`est'" + "`stars'" +  " (" + "`se'" + ")"
		di "`output'"
		putexcel `col'`row'=("`output'")
		local row = `row' + 1
	}
	






