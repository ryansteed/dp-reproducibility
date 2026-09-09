/*******************************************************************************
	OWNER: STEPHANIE KESTELMAN
	DATE: AUG 4, 2017


	THIS PROGRAM ADJUSTS FOR INFLATION AT THE STATE LEVEL, and TAKES IN THE 
		FOLLOWING INPUTS:
		
		* YEAR WE WANT $S IN 
		* MONTH THE DATA IS IN. IF ANNUAL, WRITE ANNUAL
		* WHICH STATES TO INCLUDE. PROGRAM CAN BE MODIFIED IF NOT AT STATE LEVEL. 
		YEAR RANGE: 1920-2017. TO EXPAND RANGE, DOWNLOAD DESIRED RANGE OF YEARS FROM 
		https://data.bls.gov/pdq/SurveyOutputServlet 

	Edit path below when using another file
*******************************************************************************/


capture program drop adjust_inflation
program define adjust_inflation

syntax varlist , year(real) [month_3letter_or_annual(string) includestates(string)]

	qui{
	preserve /*Preserves data being adjusted*/
		
	* ADJUST FILE PATH AS NEEDED
	import excel using $rawdir/CPI_1920_2018_20190305.xlsx, ///
		cellrange(A12:P110) firstrow clear
	
	if "`month_3letter_or_annual'"==""{
		local month_3letter_or_annual = "annual"
	}
	
	local month = proper("`month_3letter_or_annual'")
	
	rename (Year `month') (year `month_3letter_or_annual')
	
	keep year `month_3letter_or_annual'
	
	*Get CPI for year we want to convert all other dollars into. E.g. if want to 
	*convert to 2014 dollars, select 2014. Calculate inflation rate + 1
	ds year, not
	foreach var in `r(varlist)'{
		g `var'base = `var' if year==`year'
		egen `var'_`year' = max(`var'base)
		g  `var'_inflation =`var'_`year'/`var'
	}
	drop *base *_`year'
	
	tempfile inflation
	save `inflation'
	restore /*Restores data being adjusted*/
	
	merge m:1 year using `inflation', keep(3) nogen

	*ADJUST FOR INFLATION IF IN THE LIST OF STATES TO INCLUDE. Some states conduct 
	*their data gathering in different months, so the inflation rate is slightly different. 
	*If all the same, can comment out the portion "if regexm("`includestates'", stateabbr)"
	if "`includestates'"!=""{
		foreach var in `varlist'{
			replace `var' = `month_3letter_or_annual'_inflation* `var' if regexm("`includestates'", stateabbr)
		}
	}
	
	else if "`includestates'"==""{
		foreach var in `varlist'{
			capture replace `var' = `month_3letter_or_annual'_inflation* `var'
			if _rc==0{
			di as error "Adjusted `var' to `year' dollars"
			}
		}
	}
	drop `month_3letter_or_annual' `month_3letter_or_annual'_inflation
	
	
	}
end
