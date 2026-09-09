********************************************************************************
* Timing of Effect, Reduced Form - Main Results
*

preserve
tab year, gen(year_)
gen Potential_Up_2000 = year_1*dpotentialUpstream
gen Potential_Up_2001 = year_2*dpotentialUpstream
gen Potential_Up_2002 = year_3*dpotentialUpstream
gen Potential_Up_2003 = 0
gen Potential_Up_2004 = year_5*dpotentialUpstream
gen Potential_Up_2005 = year_6*dpotentialUpstream
gen Potential_Up_2006 = year_7*dpotentialUpstream
gen Potential_Up_2007 = year_8*dpotentialUpstream
gen Potential_Up_2008 = year_9*dpotentialUpstream
gen Potential_Up_2009 = year_10*dpotentialUpstream
gen Potential_Up_2010 = year_11*dpotentialUpstream



xi: xtreg IMR Potential_Up_20* $control, fe cluster(basin)
	
mat b =e(b)
mat b1 = b[1,1..11]'
mat b1=[. \ b1]
mat drop b
mat v=e(V)
mat sd1=[.]
forval k=1(1)11{
	mat sd1 = [sd1 \ sqrt(v[`k',`k'])] 
	}
mat drop v
svmat b1
svmat sd1
drop if b11==.
gen t=_n


serrbar b1 sd1 t, yline(0) scale(1.96)  xlabel(1 "Potential_Up_2000" 2 "Potential_Up_2001" 3 "Potential_Up_2002" 4 "Potential_Up_2003" 5 "Potential_Up_2004" 6 "Potential_Up_2005" 7 "Potential_Up_2006" 8 "Potential_Up_2007" 9 "Potential_Up_2008" 10 "Potential_Up_2009" 11 "Potential_Up_2010", labsize(small) angle(vertical)) ///
xline(5, lpattern(shortdash)lstyle(refline)) xtitle("") title("Potential Upstream Effects on IMR -- Reduced Form") yscale(range(-5 20)) ytick(-5(5)20) ylabel(-5(5)20, labsize(small) angle(horizontal)) ytitle("")  scheme(s1mono) 
graph save "$pathresults/Timing.gph", replace
restore
