* Import competition and the gender employment gap in China
* Feicheng Wang, Krisztina Kis-Katos, Minghai Zhou
* Journal of Human Resources
* Replication codes for figures
* Stata version 17.0 SE—Standard Edition
* 16-05-2022
* Author: Feicheng Wang

* Set work directory
global basedir "/Users/F.Wang/Dropbox/Research/Gender gap and trade openness in China/JHR/Replication files/JHR Replication"
global datadir "$basedir/data"
global codedir "$basedir/dofiles"
global figdir "$basedir/figures"
global tabledir "$basedir/tables"
cd "$datadir"

**# Figure 1: Import tariff rates in China: 1992–2010
use "$datadir/tariff_cic90",clear
gen tmean=.
gen tq25=.
gen tq75=.
forvalues y=1992/2010 {
sum tariff_imp if year==`y',detail
replace tmean=r(mean) if year==`y'
replace tq25=r(p25) if year==`y'
replace tq75=r(p75) if year==`y'
}
collapse (mean) tmean tq25 tq75, by(year)
drop if year>2010
twoway (line tmean year, sort xtitle("") ytitle("Import tariff rates (%)", size(medsmall)) ///
       yscale(titlegap(2)) ylabel(,format(%9.0f)) lp(solid) lw(medium) lc(gs0) xlabel(1992(2)2010, labsize(medsmall)) ///
	   ylabel(0(10)60, labsize(medsmall)) legend(off) graphregion(color(white)) xsize(9) ysize(6) ///
	   xline(1995 2001, lp(dot) lw(medium) lc(gs0)) ///
	   text(60.5 1995 "WTO membership application", place(north) c(gs0) size(small)) ///
	   text(60.5 2001 "WTO entry", place(north) c(gs0) size(small))) ///
	   (line tq25 year, sort lp(dash) lc(gs8)) ///
	   (line tq75 year, sort lp(dash) lc(gs8)) ///
	   (scatter tmean year if year==1992, mc(gs0) msize(small)) ///
	   (scatter tq25 year if year==1992, mc(gs8) msize(small)) ///
	   (scatter tq75 year if year==1992, mc(gs8) msize(small)) ///
	   (scatter tmean year if year==2005, mc(gs0) msize(small)) ///
	   (scatter tq25 year if year==2005, mc(gs8) msize(small)) ///
	   (scatter tq75 year if year==2005, mc(gs8) msize(small))
graph display, xsize(10)
graph export "$figdir/fig1.eps", as(eps) replace

**# Figure A.1: Employment rate by gender in China: 1990-2015
import excel "$datadir/employment rate_pop census.xlsx", sheet("population census") firstrow clear
save "$datadir/temp",replace
 
import delimited "$datadir/employment rate_ILO.csv",clear
keep if ref_arealabel=="China"
encode sexlabel, gen(gender)
encode classif1label, gen(age)
keep if age==1
drop if gender==3
keep time obs_value gender
rename time year
rename obs_value emplsh
reshape wide emplsh, i(year) j(gender)
rename emplsh1 emplsh_f
rename emplsh2 emplsh_m
gen emplsh_mf=emplsh_m-emplsh_f
keep if year<=2015
merge 1:1 year using "$datadir/temp", nogen
erase "$datadir/temp.dta"
twoway (line emplsh_f year, sort c(l) yaxis(1) xtitle("") ytitle("Employment rate (%)", axis(1) size(small)) ///
       yscale(titlegap(2) axis(1)) ylabel(,format(%9.0f) axis(1)) ///
       lp(solid) lw(medium) lc(gs0) xlabel(1990(2)2015, labsize(medsmall)) ///
	   legend(off) graphregion(color(white)) xsize(10) ysize(6) text(61.3 2013 "ILO: Female", place(north) c(gs0) size(small))) ///
       (line emplsh_m year, sort c(l) yaxis(1)  xtitle("") yscale(titlegap(2)) ///
	   lp(dash) lw(medium) lc(gs0) text(74.3 2013 "ILO: Male", place(north) c(gs0) size(small))) ///
	   (line emplsh_mf year, sort c(l) yaxis(2)  xtitle("") ytitle("Male-female difference (%)", axis(2) size(small)) ///
       lp(longdash) lw(medium) lc(gs8) text(67 2006.5 "ILO: Male-female difference", place(east) c(gs0) size(small))) ///
	   (scatter emplsh_m_popc year, sort m(Oh) mc(gs0) yaxis(1) text(85.1 1990.3 "Census: Male", place(east) c(gs0) size(small))) ///
	   (scatter emplsh_f_popc year, sort m(h) mc(gs0) yaxis(1) text(73.1 1990.3 "Census: Female", place(east) c(gs0) size(small))) ///
	   (scatter emplsh_mf_popc year, sort m(X) mc(gs8) msize(medlarge) yaxis(2) text(67 1990.3 "Census: Male-female difference", place(east) c(gs0) size(small)))
graph export "$figdir/fig_a1.eps", as(eps) replace

**# Figure A.3: Import and export tariffs across years: 1990-2015
use "$datadir/tariff_avg",clear
twoway (line tariff_imp year, sort xtitle("") ytitle("Tariff rates (%)", size(small)) ///
       yscale(titlegap(2)) ylabel(,format(%9.0f)) lp(solid) lw(medium) lc(gs0) xlabel(1990(2)2015, labsize(medsmall)) ///
	   legend(off) graphregion(color(white)) xsize(10) ysize(5.5) text(38 1991.5 "Import tariff", place(north) c(gs0) size(small)) ///
	   xline(1995 2001 2010, lp(dash) lw(thin) lc(gs9))) ///
       (line tariff_exp year, sort xtitle("") lp(dash) lw(medium) lc(gs0) text(14.5 1991.5 "Export tariff", place(north) c(gs0) size(small)) ///
	   text(43 1995 "WTO membership application", place(north) c(gs0) size(small)) ///
	   text(43 2001 "WTO entry", place(north) c(gs0) size(small)) ///
	   text(43 2010 "Tariff cut commitments fulfilled", place(north) c(gs0) size(small)))
graph export "$figdir/fig_a3.eps", as(eps) replace

**# Figure A.4: Tariff declines (1992–2005) and initial female employment shares
use "$datadir/fesh90",clear
twoway (scatter dtariff fesh90, m(O) mc(gs0) msize(small) ytitle("Tariff changes 1992-2005 (%)") xtitle("Female worker shares 1990 (%)") ///
legend(off) xvarformat(%9.0f) yvarformat(%9.0f) ylabel(, nogrid) yscale(titlegap(2))) ///
(lfit dtariff fesh90,lc(gs0)),graphregion(color(white))
gr export "$figdir/fig_a4.eps", as(eps) replace

**# Figure A.5: Import tariff declines (1992-2005) and initial tariff rates in China
use "$datadir/tariff_cic90",clear
keep if year==1992 | year==2005
reshape wide tariff_imp, i(cic90) j(year)
gen dtariff_imp=tariff_imp2005-tariff_imp1992
twoway (scatter dtariff_imp tariff_imp1992, m(O) mc(gs0) msize(small) ytitle("Tariff changes 1992-2005 (%)") xtitle("Tariff rates 1992 (%)") ///
legend(off) xvarformat(%9.0f) yvarformat(%9.0f) ylabel(, nogrid) yscale(titlegap(2))) ///
(lfit dtariff_imp tariff_imp1992, lc(gs0)),graphregion(color(white))
gr export "$figdir/fig_a5a.eps",as(eps) replace

use "$datadir/regdata",clear
keep city dtariff tariff92
twoway (scatter dtariff tariff92, m(O) mc(gs0) msize(small) ytitle("Tariff changes 1992-2005 (%)") xtitle("Tariff rates 1992 (%)") ///
legend(off) xvarformat(%9.0f) yvarformat(%9.0f) ylabel(, nogrid) yscale(titlegap(2))) ///
(lfit dtariff tariff92, lc(gs0)),graphregion(color(white))
gr export "$figdir/fig_a5b.eps", as(eps) replace
