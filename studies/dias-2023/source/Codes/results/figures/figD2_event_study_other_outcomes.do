********************************************************************************
* Timing of Effect, Reduced Form - Other Outcomes
*

scalar first_reg=1

scalar flag=0

foreach y in r_baby_death_infectious r_baby_death_respiratory r_baby_death_perinatal r_baby_death_congenital r_baby_death_external r_baby_death_endoc_nut r_baby_death_genito r_baby_death_illdef FMR IMR_masc IMR_fem s_birth_lowbirthw s_gesta_preterm s_gesta_below22 s_gesta_22_27 s_gesta_28_36 s_gesta_37_41 s_gesta_above42 s_lowapgar1 s_lowapgar5 sex_ratio birth_rate birth_motheredclow_mean birth_motheredcmid_mean birth_motheredchigh_mean birth_motherage_mean{

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



xi: xtreg `y' Potential_Up_20* $control, fe cluster(basin)

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

if `y'==sex_ratio{
	scalar flag=1
	}
if `y'==IMR_masc{
	scalar flag=2
	}
if `y'==s_birth_lowbirthw{
	scalar flag=3
	}
if `y'==birth_rate{
	scalar flag=4
	}
if `y'==birth_motherage_mean{
	scalar flag=5
	}

if flag==0{
	serrbar b1 sd1 t, yline(0) scale(1.96)  xlabel(1 "2000" 2 "2001" 3 "2002" 4 "2003" 5 "2004" 6 "2005" 7 "2006" 8 "2007" 9 "2008" 10 "2009" 11 "2010", labsize(small) angle(horizontal)) ///
	xline(5, lpattern(shortdash)lstyle(refline)) xtitle("") title("Potential Upstream Effects on `: variable label `y''" "Reduced Form") yscale(range(-5 10)) ytick(-5(5)10) ylabel(-5(5)10, labsize(small) angle(horizontal)) ytitle("")  scheme(s1mono) 
	graph save "$pathresults/graphs_other_outcomes/Timing_`y'.gph", replace
	graph export "$pathresults/graphs_other_outcomes/Timing_`y'.png", replace
	}
if flag==1{
	serrbar b1 sd1 t, yline(0) scale(1.96)  xlabel(1 "2000" 2 "2001" 3 "2002" 4 "2003" 5 "2004" 6 "2005" 7 "2006" 8 "2007" 9 "2008" 10 "2009" 11 "2010", labsize(small) angle(horizontal)) ///
	xline(5, lpattern(shortdash)lstyle(refline)) xtitle("") title("Potential Upstream Effects on `: variable label `y''" "Reduced Form") yscale(range(-.2 .2)) ytick(-.2(.1).2) ylabel(-.2(.1).2, labsize(small) angle(horizontal)) ytitle("")  scheme(s1mono) 
	graph save "$pathresults/graphs_other_outcomes/Timing_`y'.gph", replace
	graph export "$pathresults/graphs_other_outcomes/Timing_`y'.png", replace
	}
if flag==2{
	serrbar b1 sd1 t, yline(0) scale(1.96)  xlabel(1 "2000" 2 "2001" 3 "2002" 4 "2003" 5 "2004" 6 "2005" 7 "2006" 8 "2007" 9 "2008" 10 "2009" 11 "2010", labsize(small) angle(horizontal)) ///
	xline(5, lpattern(shortdash)lstyle(refline)) xtitle("") title("Potential Upstream Effects on `: variable label `y''" "Reduced Form") yscale(range(-10 20)) ytick(-10(5)20) ylabel(-10(5)20, labsize(small) angle(horizontal)) ytitle("")  scheme(s1mono) 
	graph save "$pathresults/graphs_other_outcomes/Timing_`y'.gph", replace
	graph export "$pathresults/graphs_other_outcomes/Timing_`y'.png", replace
	}
if flag==3{
	serrbar b1 sd1 t, yline(0) scale(1.96)  xlabel(1 "2000" 2 "2001" 3 "2002" 4 "2003" 5 "2004" 6 "2005" 7 "2006" 8 "2007" 9 "2008" 10 "2009" 11 "2010", labsize(small) angle(horizontal)) ///
	xline(5, lpattern(shortdash)lstyle(refline)) xtitle("") title("Potential Upstream Effects on `: variable label `y''" "Reduced Form") yscale(range(-.1 .1)) ytick(-.1(.05).1) ylabel(-.1(.05).1, labsize(small) angle(horizontal)) ytitle("")  scheme(s1mono) 
	graph save "$pathresults/graphs_other_outcomes/Timing_`y'.gph", replace
	graph export "$pathresults/graphs_other_outcomes/Timing_`y'.png", replace
	}
if flag==4{
	serrbar b1 sd1 t, yline(0) scale(1.96)  xlabel(1 "2000" 2 "2001" 3 "2002" 4 "2003" 5 "2004" 6 "2005" 7 "2006" 8 "2007" 9 "2008" 10 "2009" 11 "2010", labsize(small) angle(horizontal)) ///
	xline(5, lpattern(shortdash)lstyle(refline)) xtitle("") title("Potential Upstream Effects on `: variable label `y''" "Reduced Form") yscale(range(-.02 .02)) ytick(-.02(.01).02) ylabel(-.02(.01).02, labsize(small) angle(horizontal)) ytitle("")  scheme(s1mono) 
	graph save "$pathresults/graphs_other_outcomes/Timing_`y'.gph", replace
	graph export "$pathresults/graphs_other_outcomes/Timing_`y'.png", replace
	
	scalar flag=3
	}
if flag==5{
	serrbar b1 sd1 t, yline(0) scale(1.96)  xlabel(1 "2000" 2 "2001" 3 "2002" 4 "2003" 5 "2004" 6 "2005" 7 "2006" 8 "2007" 9 "2008" 10 "2009" 11 "2010", labsize(small) angle(horizontal)) ///
	xline(5, lpattern(shortdash)lstyle(refline)) xtitle("") title("Potential Upstream Effects on `: variable label `y''" "Reduced Form") ytitle("")  scheme(s1mono) 
	graph save "$pathresults/graphs_other_outcomes/Timing_`y'.gph", replace
	graph export "$pathresults/graphs_other_outcomes/Timing_`y'.png", replace
	}


restore
}
