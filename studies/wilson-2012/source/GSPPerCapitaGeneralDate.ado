
program define GSPPerCapitaGeneralDate
	*  State GSP per Capita
	*  This program makes the State GSP per Capita variables.
	*  And, I will need the percent change in state GSP per capita from 2006 to 2007 and from 2007 to 2008, since that is one
	*  of the control variables. So, I make this variable before  I drop the observations from the
	*  time periods that I don't need. I'm taking the max() function just to get any of the values in that year.
	*  This works because State GDP and State Population are yearly variables.

	*  This .ado program generalizes the previous Program.StateGSPPerCapita.do, in order
	*  to calculate the change in GSP over 
	local startyear = `1'
	local endyear   = `2'

	sort state time
	assert StateGDP == StateGDP[_n-1] if year(dofm(time)) == year(dofm(time[_n-1])) & state == state[_n-1]
	assert StatePopulation == StatePopulation[_n-1] if year(dofm(time)) == year(dofm(time[_n-1])) & state == state[_n-1]
	gen StatePop09 = StatePopulation if year(dofm(time)) == 2009
	by state: egen StatePop09_nomiss = min(StatePop09)
	by state: egen gsp_start = max(StateGDP/StatePop09_nomiss) if year(dofm(time)) == `startyear'
	by state: egen gsp_end = max(StateGDP/StatePop09_nomiss) if year(dofm(time)) == `endyear'
	by state: egen gsp_start_nomiss = min(gsp_start)
	by state: egen gsp_end_nomiss = min(gsp_end)


	generate delta_gsp_percapita = ln(gsp_end_nomiss) - ln(gsp_start_nomiss)
	drop gsp_start gsp_start_nomiss gsp_end gsp_end_nomiss StatePop09 StatePop09_nomiss


	label variable delta_gsp_percapita "Percentage Change in GDP per capita from `startyear' to `endyear'."
	
end Program.StateGSPPerCapita.GeneralDate
