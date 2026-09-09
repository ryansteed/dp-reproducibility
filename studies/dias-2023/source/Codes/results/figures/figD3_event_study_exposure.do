********************************************************************************
* Timing of Effect, Reduced Form - Main Results - High Exposure vs Low Exposure
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


xi: xtreg IMR_highexp Potential_Up_20* $control, fe cluster(basin)
	
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


xi: xtreg IMR_lowexp Potential_Up_20* $control, fe cluster(basin)
	
mat b =e(b)
mat b2 = b[1,1..11]'
mat b2=[. \ b2]
mat drop b
mat v=e(V)
mat sd2=[.]
forval k=1(1)11{
	mat sd2 = [sd2 \ sqrt(v[`k',`k'])] 
	}
mat drop v


mat sd1_high=b1+invnormal(0.975)*sd1
mat sd1_low=b1+invnormal(0.025)*sd1

mat sd2_high=b2+invnormal(0.975)*sd2
mat sd2_low=b2+invnormal(0.025)*sd2

svmat b1
svmat sd1
svmat b2
svmat sd2

svmat sd1_high 
svmat sd1_low 
svmat sd2_high 
svmat sd2_low

drop if b11==.
gen t=_n
gen t2=t+0.15

tw (rcap sd1_high sd1_low t, lw(thin)) (connected b1 t, m(circle) mlw(small) lw(small) lpattern(l)) (pcbarrow sd2_high t2 sd2_low t2, lw(thin)) (connected b2 t2, m(t) mlw(small) lw(small) lpattern(-)), yline(0)  xlabel(1 "Potential_Up_2000" 2 "Potential_Up_2001" 3 "Potential_Up_2002" 4 "Potential_Up_2003" 5 "Potential_Up_2004" 6 "Potential_Up_2005" 7 "Potential_Up_2006" 8 "Potential_Up_2007" 9 "Potential_Up_2008" 10 "Potential_Up_2009" 11 "Potential_Up_2010", labsize(small) angle(vertical)) ///
xline(5, lpattern(shortdash)lstyle(refline)) xtitle("") title("Potential Upstream Effects on IMR -- Reduced Form") yscale(range(-10 20)) ytick(-10(5)20) ylabel(-10(5)20, labsize(small) angle(horizontal)) ytitle("")  scheme(s1mono) ///
legend(order(2 "Higher exposure months (Mar-Jun)" 4 "Lower exposure months") size(small))
graph save "$pathresults/Timing_exposure.gph", replace
restore
