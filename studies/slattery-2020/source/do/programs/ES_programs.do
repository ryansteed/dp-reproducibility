/***********************/
/*** 1-line ES graph ***/
/***********************/

capture program drop ES_graph

program define ES_graph

set more off

syntax, ci(real) [ xti(string) yti(string) lab1(string) outname(string) rawti(string) yl(string)  ]

preserve

if "`yl'"!=""{
	local ylab = "ylab(`yl')"
}
else{
	local ylab=""
}

gen fig_upper=b+`ci'*se
gen fig_lower=b-`ci'*se
capture gen fig_t = t-101
rename b fig_b

twoway (scatter fig_b fig_t if  fig_t<6 & fig_t>-6, c(l) xline(-0.0, lc(gs11) lp(shortdash)) yline(0, lc(gs11) lp(shortdash))) ///
(rcap fig_upper fig_lower fig_t  if fig_t<6 & fig_t>-6 , lpattern(solid) lcolor(dknavy) c(l) m(i) ), ///
plotregion(fcolor(white) lcolor(white)) ///
graphregion(fcolor(white) lcolor(white)) ///
xtitle("`xti'") ///
ytitle("`yti'") ///
xlab(-5(1)5) `ylab' ///
legend(label(1 "`lab1'") label(2 "95% CI") region(lcolor(white)))
	
graph export "$graphdir/`outname'.pdf", replace

restore

end


/***********************/
/*** 2-line ES graph ***/
/***********************/

capture program drop ES_graph2

program define ES_graph2

set more off
	
syntax, ci(real) [ xti(string) yti(string) outname(string) lab1(string) lab2(string) rawti(string) yl(string) row(string) ]

preserve

if "`yl'"!=""{
	local ylab = "ylab(`yl')"
}
else{
	local ylab=""
}
if "`row'" !=""{
	local rr = "row(`row')"
}
else{
	local rr=""
}


gen fig_upper1=b1+`ci'*se1
gen fig_lower1=b1-`ci'*se1
gen fig_upper2=b2+`ci'*se2
gen fig_lower2=b2-`ci'*se2
capture gen fig_t = t-101
rename b1 fig_b1
rename b2 fig_b2

	
*Figure in gph format with title (only if specified with rawti option)
twoway (scatter fig_b1 fig_t1 if  fig_t1<6 & fig_t1>-6, c(l) lc(dknavy) mcolor(dknavy) msymbol(o) xline(-0.0, lc(gs11) lp(shortdash)) yline(0, lc(gs11) lp(shortdash))) ///
(rcap fig_upper1 fig_lower1 fig_t1  if fig_t1<6 & fig_t1>-6 , lpattern(solid) lcolor(dknavy) c(l) m(i) ) ///
(scatter fig_b2 fig_t2 if  fig_t2<6 & fig_t2>-6, c(l) lpattern(dash) lc(maroon) mcolor(maroon)  msymbol(d) ) ///
(rcap fig_upper2 fig_lower2 fig_t2  if fig_t2<6 & fig_t2>-6 , lpattern(dash) lcolor(maroon) c(l) m(i) ), ///
plotregion(fcolor(white) lcolor(white)) ///
graphregion(fcolor(white) lcolor(white)) ///
xtitle("`xti'") ///
ytitle("`yti'") ///
xlab(-5(1)5) `ylab' ///
legend(label(1 "`lab1'") label(3 "`lab2'") label(2 "95% CI") label(4 "95% CI") region(lcolor(white)) `rr')
	
graph export "$graphdir/`outname'.pdf", replace

restore

end



/***********************/
/*** 3-line ES graph ***/
/***********************/

capture program drop ES_graph3

program define ES_graph3

set more off
	
syntax, ci(real) [ xti(string) yti(string) outname(string) lab1(string) lab2(string) lab3(string) rawti(string) yl(string) row(string) ]

preserve

if "`yl'"!=""{
	local ylab = "ylab(`yl')"
}
else{
	local ylab=""
}

if "`row'" !=""{
	local rr = "row(`row')"
}
else{
	local rr=""
}

gen fig_upper1=b1+`ci'*se1
gen fig_lower1=b1-`ci'*se1
gen fig_upper2=b2+`ci'*se2
gen fig_lower2=b2-`ci'*se2
gen fig_upper3=b3+`ci'*se3
gen fig_lower3=b3-`ci'*se3


capture gen fig_t = t-101
rename b1 fig_b1
rename b2 fig_b2
rename b3 fig_b3

	
*Figure in gph format with title (only if specified with rawti option)
twoway (scatter fig_b1 fig_t1 if  fig_t1<6 & fig_t1>-6, c(l) lc(dknavy) mcolor(dknavy) msymbol(o) xline(-0.0, lc(gs11) lp(shortdash)) yline(0, lc(gs11) lp(shortdash))) ///
(rcap fig_upper1 fig_lower1 fig_t1  if fig_t1<6 & fig_t1>-6 , lpattern(solid) lcolor(dknavy) c(l) m(i) ) ///
(scatter fig_b2 fig_t2 if  fig_t2<6 & fig_t2>-6, c(l) lpattern(dash) lc(maroon) mcolor(maroon)  msymbol(d) ) ///
(rcap fig_upper2 fig_lower2 fig_t2  if fig_t2<6 & fig_t2>-6 , lpattern(dash) lcolor(maroon) c(l) m(i) ) ///
(scatter fig_b3 fig_t3 if  fig_t3<6 & fig_t3>-6, c(l) lpattern(dash_dot) lc(forest_green*.7) mcolor(forest_green*.7)  msymbol(th) ) ///
(rcap fig_upper3 fig_lower3 fig_t3  if fig_t3<6 & fig_t3>-6 , lpattern(dash_dot) lcolor(forest_green*.7) c(l) m(i) ) ///
, ///
plotregion(fcolor(white) lcolor(white)) ///
graphregion(fcolor(white) lcolor(white)) ///
xtitle("`xti'") ///
ytitle("`yti'") ///
xlab(-5(1)5) `ylab' ///
legend(order(1 3 5) label(1 "`lab1'") label(3 "`lab2'") label(5 "`lab3'") region(lcolor(white)) `rr')
	
graph export "$graphdir/`outname'.pdf", replace

restore

end


/***********************/
/*** 4-line ES graph ***/
/***********************/

capture program drop ES_graph4

program define ES_graph4

set more off
	
syntax, ci(real) [ xti(string) yti(string) outname(string) lab1(string) lab2(string) lab3(string) lab4(string) rawti(string) yl(string) row(string) ]

preserve

if "`yl'"!=""{
	local ylab = "ylab(`yl')"
}
else{
	local ylab=""
}

if "`row'" !=""{
	local rr = "row(`row')"
}
else{
	local rr=""
}

gen fig_upper1=b1+`ci'*se1
gen fig_lower1=b1-`ci'*se1
gen fig_upper2=b2+`ci'*se2
gen fig_lower2=b2-`ci'*se2
gen fig_upper3=b3+`ci'*se3
gen fig_lower3=b3-`ci'*se3
gen fig_upper4=b4+`ci'*se4
gen fig_lower4=b4-`ci'*se4

capture gen fig_t = t-101
rename b1 fig_b1
rename b2 fig_b2
rename b3 fig_b3
rename b4 fig_b4

	
*Figure in gph format with title (only if specified with rawti option)
twoway (scatter fig_b1 fig_t1 if  fig_t1<6 & fig_t1>-6, c(l) lc(dknavy) mcolor(dknavy) msymbol(o) xline(-0.0, lc(gs11) lp(shortdash)) yline(0, lc(gs11) lp(shortdash))) ///
(rcap fig_upper1 fig_lower1 fig_t1  if fig_t1<6 & fig_t1>-6 , lpattern(solid) lcolor(dknavy) c(l) m(i) ) ///
(scatter fig_b2 fig_t2 if  fig_t2<6 & fig_t2>-6, c(l) lpattern(dash) lc(maroon) mcolor(maroon)  msymbol(d) ) ///
(rcap fig_upper2 fig_lower2 fig_t2  if fig_t2<6 & fig_t2>-6 , lpattern(dash) lcolor(maroon) c(l) m(i) ) ///
(scatter fig_b3 fig_t3 if  fig_t3<6 & fig_t3>-6, c(l) lpattern(dash_dot) lc(forest_green*.7) mcolor(forest_green*.7)  msymbol(th) ) ///
(rcap fig_upper3 fig_lower3 fig_t3  if fig_t3<6 & fig_t3>-6 , lpattern(dash_dot) lcolor(forest_green*.7) c(l) m(i) ) ///
(scatter fig_b4 fig_t4 if  fig_t4<6 & fig_t4>-6, c(l) lpattern(dash) lc(dkorange*.5) mcolor(dkorange*.5)  msymbol(x) ) ///
(rcap fig_upper4 fig_lower4 fig_t4  if fig_t4<6 & fig_t4>-6 , lpattern(dash) lcolor(dkorange) c(l) m(i) ) ///
, ///
plotregion(fcolor(white) lcolor(white)) ///
graphregion(fcolor(white) lcolor(white)) ///
xtitle("`xti'") ///
ytitle("`yti'") ///
xlab(-5(1)5) `ylab' ///
legend(order(1 3 5 7) label(1 "`lab1'") label(3 "`lab2'") label(5 "`lab3'") label(7 "`lab4'") region(lcolor(white)) `rr')
	
graph export "$graphdir/`outname'.pdf", replace

restore

end



/****************************************************************************************/
/*** Average impact of an event on different outcomes (in time = t): ***/
/****************************************************************************************/
capture program drop Event_outcome
program define Event_outcome
syntax [if] [in], yvar(varname) event(varname)  [ controls(string) outname(string) fe(string) ]

set more off

preserve

*Keep if specified
if "`if'" != "" {
	keep `if'
}

*if no FE specified, assume fips
if "`fe'" == "" {
	local fe = "fips"
}


*Setup event
g e = year if `event' == 1
qui sum year
local years = `r(max)' - `r(min)' + 1

*Fill up:
local i = 0
while `i' < `years' {
	qui replace e = e[_n+1] if `fe' == `fe'[_n+1] & abs(year - e[_n+1]) < abs(year - e)
	local ++i
}
*Fill down: 
local i = 0
while `i' < `years' {
	qui replace e = e[_n-1] if `fe' == `fe'[_n-1] & abs(year - e[_n-1]) < abs(year - e)
	local ++i
}

*DEFINE EVENT
*binned
gen Dn5=year<=e-6.5 
gen Dn4=year==e-4
gen Dn3=year==e-3
gen Dn2=year==e-2
gen D0=year==e
gen D1=year==e+1
gen D2=year==e+2
gen D3=year==e+3
gen D4=year==e+4
gen D5=year==e+5
*binned
gen D6=year>=e+6

*MAIN REG
reghdfe `yvar' Dn5-D6 , abs(year `fe') cluster(`fe')

*Raw regression output
regsave  
drop if substr(var,1,1) != "D"
drop N r2
export delimited $dumpdir/`outname'.csv, replace

restore

end
