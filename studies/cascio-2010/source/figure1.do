* Figure1.do
* Trends in mexican share in California and the US

clear
set scheme s1color

set more off
set logtype text
cap log close

use data/cen_mex, clear
sort year
sum

gr two (scatter under18 year, c(l) ms(Oh) color(orange)) ///
  (scatter caliunder18 year, c(l) ms(Oh) color(green) lp(dash) xtick(1960 1970 1976 1980 1990 2000) xlab(1960 1970 1976 1980 1990 2000) ytick(0 0.05 .1 .15 .2 .25 .3) ylab(0 .1 .2 .3)), ///
  text(.05 1985 "U.S.", color(orange)) text(.2 1985 "California", color(green)) xtitle(" ") fxsize(97) legend(off) plotregion(lcolor(none)) 
graph export output/figure1.eps, replace as(eps)
