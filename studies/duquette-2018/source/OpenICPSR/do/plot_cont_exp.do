/**************************************
* Figure: How does giving predict NPO 
* spending by state contemporaneously?
* from 1917 to 2013
**************************************/

/*
	// Change fontface if Consolas is not installed using this code
replace statesans=`"{fontface "Consolas":AL}"' if stfips==1
replace statesans=`"{fontface "Consolas":AK}"' if stfips==2
replace statesans=`"{fontface "Consolas":AZ}"' if stfips==4
replace statesans=`"{fontface "Consolas":AR}"' if stfips==5
replace statesans=`"{fontface "Consolas":CA}"' if stfips==6
replace statesans=`"{fontface "Consolas":CO}"' if stfips==8
replace statesans=`"{fontface "Consolas":CT}"' if stfips==9
replace statesans=`"{fontface "Consolas":DE}"' if stfips==10
replace statesans=`"{fontface "Consolas":DC}"' if stfips==11
replace statesans=`"{fontface "Consolas":FL}"' if stfips==12
replace statesans=`"{fontface "Consolas":GA}"' if stfips==13
replace statesans=`"{fontface "Consolas":HI}"' if stfips==15
replace statesans=`"{fontface "Consolas":ID}"' if stfips==16
replace statesans=`"{fontface "Consolas":IL}"' if stfips==17
replace statesans=`"{fontface "Consolas":IN}"' if stfips==18
replace statesans=`"{fontface "Consolas":IA}"' if stfips==19
replace statesans=`"{fontface "Consolas":KS}"' if stfips==20
replace statesans=`"{fontface "Consolas":KY}"' if stfips==21
replace statesans=`"{fontface "Consolas":LA}"' if stfips==22
replace statesans=`"{fontface "Consolas":ME}"' if stfips==23
replace statesans=`"{fontface "Consolas":MD}"' if stfips==24
replace statesans=`"{fontface "Consolas":MA}"' if stfips==25
replace statesans=`"{fontface "Consolas":MI}"' if stfips==26
replace statesans=`"{fontface "Consolas":MN}"' if stfips==27
replace statesans=`"{fontface "Consolas":MS}"' if stfips==28
replace statesans=`"{fontface "Consolas":MO}"' if stfips==29
replace statesans=`"{fontface "Consolas":MT}"' if stfips==30
replace statesans=`"{fontface "Consolas":NE}"' if stfips==31
replace statesans=`"{fontface "Consolas":NV}"' if stfips==32
replace statesans=`"{fontface "Consolas":NH}"' if stfips==33
replace statesans=`"{fontface "Consolas":NJ}"' if stfips==34
replace statesans=`"{fontface "Consolas":NM}"' if stfips==35
replace statesans=`"{fontface "Consolas":NY}"' if stfips==36
replace statesans=`"{fontface "Consolas":NC}"' if stfips==37
replace statesans=`"{fontface "Consolas":ND}"' if stfips==38
replace statesans=`"{fontface "Consolas":OH}"' if stfips==39
replace statesans=`"{fontface "Consolas":OK}"' if stfips==40
replace statesans=`"{fontface "Consolas":OR}"' if stfips==41
replace statesans=`"{fontface "Consolas":PA}"' if stfips==42
replace statesans=`"{fontface "Consolas":RI}"' if stfips==44
replace statesans=`"{fontface "Consolas":SC}"' if stfips==45
replace statesans=`"{fontface "Consolas":SD}"' if stfips==46
replace statesans=`"{fontface "Consolas":TN}"' if stfips==47
replace statesans=`"{fontface "Consolas":TX}"' if stfips==48
replace statesans=`"{fontface "Consolas":UT}"' if stfips==49
replace statesans=`"{fontface "Consolas":VT}"' if stfips==50
replace statesans=`"{fontface "Consolas":VA}"' if stfips==51
replace statesans=`"{fontface "Consolas":WA}"' if stfips==53
replace statesans=`"{fontface "Consolas":WV}"' if stfips==54
replace statesans=`"{fontface "Consolas":WI}"' if stfips==55
replace statesans=`"{fontface "Consolas":WY}"' if stfips==56
*/

use "$data/state_cont_exp", clear

	// Drop Hawaii, Alaska, and DC
drop if stfips==2 | stfips==11 | stfips==15


local sizeopts "ysize(4) xsize(6)"
	
	// ------------------------------
	// MAKE PLOTS
	
	// PLOT 1: Contributions versus spending, 2013
twoway (scatter ln_exp_totexp_pop Lx_lncont , msymbol(i) mlabel(statesans) mlabpos(0) mlabcolor(black))	///
	(lfit ln_exp_totexp_pop Lx_lncont , lpattern(dash) lcolor(black))										///
	,																													/// 
	legend(off)																											/// 
	ytitle("LN Nonprofit Expenditures / Population, 2013") xtitle("LN Contributions / Pop, 1917") title("`year'")  scheme(s1mono)

graph display, `sizeopts'
graph export "$charts/fig4B.pdf",  as(pdf) fontface("$mainfont") replace



	// PLOT 2: 1917 giving against 2013 contributions
twoway (scatter ln_exp_totexp_pop ln_c_styear , msymbol(i) mlabel(statesans) mlabpos(0) mlabcolor(black))	///
	(lfit ln_exp_totexp_pop ln_c_styear , lpattern(dash) lcolor(black))									///
	,																													/// 
	legend(off)																											/// 
	ytitle("LN Nonprofit Expenditures / Population, 2013") xtitle("LN Contributions / Pop, 2013") title("`year'") scheme(s1mono)
	
graph display, `sizeopts'
graph export "$charts/fig4A.pdf",  as(pdf) fontface("$mainfont") replace
