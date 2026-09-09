/*************************************************************************************************************
Forecasted_Employment
This code produces forecasted employment based on an AR(9) model, used in Table 5.
*************************************************************************************************************/
version 10.1
ssc install freduse 
clear
set more off
cd "$dir"

global start = "2008m12"
global end = "2010m12"

set more off

* Set the parameters of exercise
local jumpoff = "$start"
local predictthrough = "$end"
local startpred = "1990m1"
local endpred = "$start" //End at the beginning of the outcome variable
local lag = 9

qui {
* Loop over the different types
foreach type in totalgov totalemp health education edhealth {

	* input from the CES folder
	use data/CES/`type'june82011, replace
	
	* Make panel, need to reshape the data 
	reshape long _ , i(state_abrev) j(time)
	rename _ baseline
	gen year = substr(string(time),1,4)
	gen month = substr(string(time),5,.)
	destring year month, replace
	gen date = ym(year,month)

	* do not keep those without observations (for health and education)
	drop if baseline==. 
	
	* Prepare to save predictions by erasing actual data past the "jumpoff point"
	
	drop if date > tm(`jumpoff')  // Get rid of actual data at point when want to start predicting
	
	* Keep only if states have an observation to do regression
	sort state_abrev
	by state_abrev: egen counter = count(baseline)
	drop if counter < 2*`lag' + 2

	* Label states with numbers 
	egen state_id = group(state_abrev)
	local statecount = state_id[_N]
	xtset state_id date, monthly
	keep state_abrev state_id date baseline

	tsappend, last(`predictthrough') tsfmt(tm)
	replace baseline = . if date > tm(`jumpoff')
	
	* Loop over states to make predictions
	
	forvalues state = 1/`statecount' {
		preserve
		keep if state_id == `state'
		tsset date, monthly

		* Multiply by 1,000 to get in number of jobs
		replace baseline = 1000*baseline

		* Do regression in logs
		replace baseline = ln(baseline)
		
		* Regression
		qui reg baseline L(1/`lag').baseline date if tin(`startpred',`endpred')

		* Filling in the prediction
		while baseline[_N]==. {
			qui predict pbaseline
			qui replace baseline = pbaseline if baseline==. & date > tm(`jumpoff')
			qui drop pbaseline
		}

		* Make into levels again
		replace baseline = exp(baseline)

		* Reshape
		keep if date >= tm(`jumpoff')
		gen time = string(year(dofm(date)))+ "m" + string(month(dofm(date)))
		keep state_abrev baseline time
		rename baseline _
		qui reshape wide _, i(state_abrev) j(time) string

		tempfile `state'file
		save ``state'file', replace
		display "`state'"
		restore
	}

	* Append states together
	
	clear
	use `1file'
	forvalues state = 2/`statecount' {
		append using ``state'file'
	}

	sort state_abrev

	save data/statepredictions/baseline`type'12_08_time, replace
}
}

