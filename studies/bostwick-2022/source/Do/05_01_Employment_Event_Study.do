************************************************************
*Run Event Study Analysis and create corresponding Figure 


*No institution-specific time trends in these regressions

*Combine all post periods after 5 years
*Arguments passed from calling do-file:
	*`1' is outcome variable
	*`2' is the year of enrollment at which outcome is measured
	
*Oct 15, 2020
************************************************************



*Notes: 
	*tdummy1 corresponds to (t==-13) = 13 years prior to switch to semesters
	*tdummy14 corresponds to (t==0) = year of switch 
	*tdummy19 corresponds to (t==5) = 5 years post-switch to semesters 
	
*The last untreated cohort (excluding the omitted group) corresponds to tdummy9 (t=-5)

*Event Study regression
reghdfe `1' tenbefore tdummy5-tdummy9 tdummy11-tdummy18 fiveormore $controls , absorb(campus_num first_term) vce(cluster cluster_id1 cluster_id2 cluster_id3 cluster_id4 cluster_id5)



***Make figure***
*Save coefficients and confidence intervals into a 14x3 matrix
local cv=1.98
matrix D = J(14,3,.)
*Untreated cohorts
forval row=1/5 {
	*Save estimates for tdummy5 into row 1; tdummy6 into row 2; etc.
	local ind=`row'+4
	matrix D[`row',1]=_b[tdummy`ind'], _b[tdummy`ind']-(`cv'*_se[tdummy`ind']), _b[tdummy`ind']+(`cv'*_se[tdummy`ind'])
}
*Omitted cohort
matrix D[6,1]=0,0,0
*Partially-treated and fully-treated cohorts
local ind=11
forval row=7/14 {
	matrix D[`row',1]=_b[tdummy`ind'], _b[tdummy`ind']-(`cv'*_se[tdummy`ind']), _b[tdummy`ind']+(`cv'*_se[tdummy`ind'])
	local ind=`ind'+1
}

*Horizontal axis labels depend on year of enrollment at which outcome is measured (passed argument `2')
if `2'==1 {
	matrix rownames  D = -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4
}
else if `2'==2 {
	matrix rownames  D = -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5
}
else if `2'==3 {
	matrix rownames  D = -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6
}
else if `2'==4 {
	matrix rownames  D = -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 7
}
local zero_line=11-`2'
coefplot matrix(D[,1]), vertical yline(0, lcolor(black) lwidth(medthin)) ci((D[,2] D[,3])) lcolor(black) msymbol(Oh) mcolor(black) mlwidth(medium) connect(direct) graphregion(color(white)) ciopts(lpattern(shortdash) ylab(,nogrid) recast(rline) lcolor(red)) xtitle("Years Relative to Policy") ytitle("Coefficient") xline(`zero_line', lcolor(blue) lwidth(thin)) 
*yscale(range(-.1(.05).1)) ylabel(-.1(.05).1)
graph export "Log Files/All_Campuses/`1'_EventStudy.png", replace


