
*  State GSP per Capita
*  This program makes the State GSP per Capita variables.
*  And, I will need the percent change in state GSP per capita from 2006 to 2007 and from 2007 to 2008, since that is one
*  of the control variables. So, I make this variable before  I drop the observations from the
*  time periods that I don't need. I'm taking the max() function just to get any of the values in that year.
*  This works because State GDP and State Population are yearly variables.


sort state time
assert StateGDP == StateGDP[_n-1] if year(dofm(time)) == year(dofm(time[_n-1])) & state == state[_n-1]
assert StatePopulation == StatePopulation[_n-1] if year(dofm(time)) == year(dofm(time[_n-1])) & state == state[_n-1]
by state: egen g06_tot = max(StateGDP) if year(dofm(time)) == 2006
by state: egen g07_tot = max(StateGDP) if year(dofm(time)) == 2007
by state: egen g06 = max(StateGDP/StatePopulation) if year(dofm(time)) == 2006
by state: egen g07 = max(StateGDP/StatePopulation) if year(dofm(time)) == 2007
by state: egen g08 = max(StateGDP/StatePopulation) if year(dofm(time)) == 2008
by state: egen gsp06 = min(g06)
by state: egen gsp07 = min(g07)
by state: egen gsp08 = min(g08)
by state:egen gsp06_tot = min(g06_tot)
by state:egen gsp07_tot = min(g07_tot)


generate delta_gsp_percapita_0607 = ln(gsp07) - ln(gsp06)
generate delta_gsp_percapita_0708 = ln(gsp08) - ln(gsp07)
generate delta_gsp_0607 = ln(gsp06_tot) - ln(gsp07_tot)
drop g06 g07 g08 gsp06_tot gsp07_tot g06_tot g07_tot


label variable delta_gsp_percapita_0607 "Percentage Change in GDP per capita from 2006 to 2007."
label variable delta_gsp_percapita_0708 "Percentage Change in GDP per capita from 2007 to 2008."
