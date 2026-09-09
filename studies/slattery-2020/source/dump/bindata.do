insheet using ..//dump/bindata.csv

twoway (scatter corprate credits_percap, mcolor(navy) lcolor(maroon)) (function 0*x^2+.0525724412722829*x+5.373178553770598, range(0 77.4681453704834) lcolor(maroon)), graphregion(fcolor(white))  xtitle(credits_percap) ytitle(corprate) legend(off order())
