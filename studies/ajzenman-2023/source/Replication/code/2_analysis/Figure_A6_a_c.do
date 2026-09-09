*------------------------------------------------------------------------------*
* 								 Figure A6 (a and c)		 	 		  	   *
*------------------------------------------------------------------------------*
{
cd "$final"
use enusc_OLS, clear

ta year, gen(y_)

gen inter_2008 = y_1*lnrate_stock_imm
gen inter_2009 = y_2*lnrate_stock_imm
gen inter_2010 = y_3*lnrate_stock_imm
gen inter_2011 = y_4*lnrate_stock_imm
gen inter_2012 = y_5*lnrate_stock_imm
gen inter_2013 = y_6*lnrate_stock_imm
gen inter_2014= y_7*lnrate_stock_imm
gen inter_2015= y_8*lnrate_stock_imm
gen inter_2016= y_9*lnrate_stock_imm
gen inter_2017= y_10*lnrate_stock_imm

label variable vict_agreg "Victimization Index"
label variable pc_20 "Behavioral Reactions Index"

foreach var in vict_agreg pc_20{
	areg `var' lnrate_stock_imm inter_2009-inter_2017 i.year edad ismale i.year#c.bas_`var', absorb(cod_com) vce(cluster cod_com)

	matrix B = (2008,.,.,.,.,.\2009,.,.,.,.,.\2010,.,.,.,.,.\2011,.,.,.,.,.\2012,.,.,.,.,.\2013,.,.,.,.,.\2014,.,.,.,.,.\2015,.,.,.,.,.\2016,.,.,.,.,.\2017,.,.,.,.,.)


	lincom lnrate_stock_imm, level(95)
	matrix B[1,2] = r(estimate)*100
	matrix B[1,3] = r(estimate)*100 - 1.64*r(se)*100
	matrix B[1,4] = r(estimate)*100 + 1.64*r(se)*100	
	matrix B[1,5] = r(estimate)*100 - 1.96*r(se)*100
	matrix B[1,6] = r(estimate)*100 + 1.96*r(se)*100	


	lincom lnrate_stock_imm+inter_2009, level(95)
	matrix B[2,2] = r(estimate)*100
	matrix B[2,3] = r(estimate)*100 - 1.64*r(se)*100
	matrix B[2,4] = r(estimate)*100 + 1.64*r(se)*100	
	matrix B[2,5] = r(estimate)*100 - 1.96*r(se)*100
	matrix B[2,6] = r(estimate)*100 + 1.96*r(se)*100	

	lincom lnrate_stock_imm+inter_2010, level(95)
	matrix B[3,2] = r(estimate)*100
	matrix B[3,3] = r(estimate)*100 - 1.64*r(se)*100
	matrix B[3,4] = r(estimate)*100 + 1.64*r(se)*100	
	matrix B[3,5] = r(estimate)*100 - 1.96*r(se)*100
	matrix B[3,6] = r(estimate)*100 + 1.96*r(se)*100	

	lincom lnrate_stock_imm+inter_2011, level(95)
	matrix B[4,2] = r(estimate)*100
	matrix B[4,3] = r(estimate)*100 - 1.64*r(se)*100
	matrix B[4,4] = r(estimate)*100 + 1.64*r(se)*100	
	matrix B[4,5] = r(estimate)*100 - 1.96*r(se)*100
	matrix B[4,6] = r(estimate)*100 + 1.96*r(se)*100	

	lincom lnrate_stock_imm+inter_2012, level(95)
	matrix B[5,2] = r(estimate)*100
	matrix B[5,3] = r(estimate)*100 - 1.64*r(se)*100
	matrix B[5,4] = r(estimate)*100 + 1.64*r(se)*100	
	matrix B[5,5] = r(estimate)*100 - 1.96*r(se)*100
	matrix B[5,6] = r(estimate)*100 + 1.96*r(se)*100	

	lincom lnrate_stock_imm+inter_2013, level(95)
	matrix B[6,2] = r(estimate)*100
	matrix B[6,3] = r(estimate)*100 - 1.64*r(se)*100
	matrix B[6,4] = r(estimate)*100 + 1.64*r(se)*100	
	matrix B[6,5] = r(estimate)*100 - 1.96*r(se)*100
	matrix B[6,6] = r(estimate)*100 + 1.96*r(se)*100	

	lincom lnrate_stock_imm+inter_2014, level(95)
	matrix B[7,2] = r(estimate)*100
	matrix B[7,3] = r(estimate)*100 - 1.64*r(se)*100
	matrix B[7,4] = r(estimate)*100 + 1.64*r(se)*100	
	matrix B[7,5] = r(estimate)*100 - 1.96*r(se)*100
	matrix B[7,6] = r(estimate)*100 + 1.96*r(se)*100	

	lincom lnrate_stock_imm+inter_2015, level(95)
	matrix B[8,2] = r(estimate)*100
	matrix B[8,3] = r(estimate)*100 - 1.64*r(se)*100
	matrix B[8,4] = r(estimate)*100 + 1.64*r(se)*100	
	matrix B[8,5] = r(estimate)*100 - 1.96*r(se)*100
	matrix B[8,6] = r(estimate)*100 + 1.96*r(se)*100	

	lincom lnrate_stock_imm+inter_2016, level(95)
	matrix B[9,2] = r(estimate)*100
	matrix B[9,3] = r(estimate)*100 - 1.64*r(se)*100
	matrix B[9,4] = r(estimate)*100 + 1.64*r(se)*100	
	matrix B[9,5] = r(estimate)*100 - 1.96*r(se)*100
	matrix B[9,6] = r(estimate)*100 + 1.96*r(se)*100	

	lincom lnrate_stock_imm+inter_2017, level(95)
	matrix B[10,2] = r(estimate)*100
	matrix B[10,3] = r(estimate)*100 - 1.64*r(se)*100
	matrix B[10,4] = r(estimate)*100 + 1.64*r(se)*100	
	matrix B[10,5] = r(estimate)*100 - 1.96*r(se)*100
	matrix B[10,6] = r(estimate)*100 + 1.96*r(se)*100	


	mat list B
	svmat B

	cap drop time coef_es ci1 ci2 ci3 ci4
	rename B1 time
	rename B2 coef_es
	rename B3 ci1
	rename B4 ci2
	rename B5 ci3
	rename B6 ci4

	twoway rcap ci1 ci2 time if time !=. , legend(off)  yscale(r(-2 0 2)) ylabel(-1.5 0 1.5, labsize(large)) xlabel(2008(1)2017, labsize(large)) || rscatter ci3 ci4 time if time !=. , msymbol(circle_hollow) msize(tiny) pstyle(p4) legend(off)  || scatter coef_es time if time !=., , yline(0, lstyle(foreground)) xtitle("Year", size(vlarge)) ytitle(`: variable label `var'', size(vlarge))  graphregion(color(white)) ylab(,nogrid) legend(off) 
	graph export "${Graphs}/Figures_A6_`var'.pdf" , as(pdf) replace

}


}
