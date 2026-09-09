************************************************************
*Run Event Study Analysis and create corresponding Figure 

*Combine all post periods after 5 years
*Arguments passed from calling do-file:
	*`1' is outcome variable
	*`2' is number of partially-treated cohorts +1
*Oct 1, 2020
************************************************************



*Notes: 
	*tdummy1 corresponds to (t==-13) = 13 years prior to switch to semesters
	*tdummy14 corresponds to (t==0) = year of switch 
	*tdummy19 corresponds to (t==5) = 5 years post-switch to semesters 
	
*The last untreated cohort (excluding the omitted group)
	*and the first partially-treated cohort depend on the passed argument #2	
local last_pretreat=13-`2'
local first_partial=`last_pretreat'+2

*Event Study regression
reghdfe `1' tenbefore tdummy5-tdummy`last_pretreat' tdummy`first_partial'-tdummy18 fiveormore $controls $time_trends , absorb(campus_num first_term) vce(cluster cluster_id1 cluster_id2 cluster_id3 cluster_id4 cluster_id5)



***Make figure***
*Save coefficients and confidence intervals into a 14x3 matrix
local cv=1.98
matrix D = J(14,3,.)
*Untreated cohorts
local rowmax=`last_pretreat'-4
forval row=1/`rowmax' {
	*Save estimates for tdummy5 into row 1; tdummy6 into row 2; etc.
	local ind=`row'+4
	matrix D[`row',1]=_b[tdummy`ind'], _b[tdummy`ind']-(`cv'*_se[tdummy`ind']), _b[tdummy`ind']+(`cv'*_se[tdummy`ind'])
}
*Omitted cohort
local omit=`rowmax'+1
matrix D[`omit',1]=0,0,0
*Partially-treated and fully-treated cohorts
local rowmin=`omit'+1
local ind=`first_partial'
forval row=`rowmin'/14 {
	matrix D[`row',1]=_b[tdummy`ind'], _b[tdummy`ind']-(`cv'*_se[tdummy`ind']), _b[tdummy`ind']+(`cv'*_se[tdummy`ind'])
	local ind=`ind'+1
}

matrix rownames  D = -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4
local partial_line=`last_pretreat'-2
coefplot matrix(D[,1]), vertical yline(0, lcolor(black) lwidth(medthin))  xline(10, lcolor(blue) lwidth(thin)) ci((D[,2] D[,3])) lcolor(black) msymbol(Oh) mcolor(black) mlwidth(medium) connect(direct) graphregion(color(white)) ciopts(lpattern(shortdash) ylab(,nogrid) recast(rline) lcolor(red)) xtitle("Years Relative to Policy") ytitle("Coefficient") xline(`partial_line', lcolor(blue) lwidth(thin)) 
*yscale(range(-.2(.1).2)) ylabel(-.2(.1).2)
graph export "Log Files/All_Campuses/`1'_EventStudy.png", replace


