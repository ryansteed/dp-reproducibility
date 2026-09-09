********************************************************************************
* Soy Hectares per Worker Graph - 1a
*
preserve

clear

use "$pathdataorig/fig_soyperworker_data.dta"

tw (connected soyperworker year, m(O) mcolor(black) lpattern(dash) lcolor(black)) ///
   (connected soyperworker year if inrange(year,2001,2009), m(O) mcolor(black) lpattern(solid) lcolor(black)) ///
   , scheme(s1mono) legend(off) title("Soybean Planted Area per Worker") ///
   xtitle("") xscale(range(1999 2011)) xtick(1999(1)2011) xlabel(1999(1)2011) ///
   ytitle("Hectares per worker") yscale(range(0 100)) ytick(0(20)100) ylabel(0(20)100, grid)

graph save "$pathresults/soy_area_per_worker.gph", replace

********************************************************************************
* Total Glyphosate Graph - 1b
*

* Linear interpolation for 2006-2008
clear

import excel using "$pathdataorig/area_temp_1996_2010.xlsx", allstring cellrange(B6:R5570)

drop if B==""

rename B codmun7
rename C name_mun

gen code_mun=substr(codmun7,1,6) 
destring code_mun, replace

local i=1996

foreach x in D E F G H I J K L M N O P Q R{

destring `x', force replace
replace `x'=0 if `x'==.
rename `x' area_temp`i'
local i=`i'+1

}

reshape long area_temp, i(code_mun name_mun) j(year)

collapse (sum) area_temp, by(year)

keep if inrange(year,2000,2010)

tempfile areatemp
save `areatemp'

clear
import excel using "$pathdataorig/soy_area_1996_2010.xlsx", allstring cellrange(B6:R5570)

drop if B==""

rename B codmun7
rename C name_mun

gen code_mun=substr(codmun7,1,6) 
destring code_mun, replace

local i=1996 // 1997 is actually 1996/1997

foreach x in D E F G H I J K L M N O P Q R{

destring `x', force replace
replace `x'=0 if `x'==.
rename `x' area_soy`i'
local i=`i'+1

}

reshape long area_soy, i(code_mun name_mun) j(year)

collapse (sum) area_soy, by(year)

keep if inrange(year,2000,2010)

merge 1:1 year using `areatemp'
drop _merge



********************************************************************************
gen glyphosate=.
replace glyphosate=39515 if year==2000
replace glyphosate=44467 if year==2001
replace glyphosate=43691 if year==2002
replace glyphosate=57614 if year==2003
replace glyphosate=77068 if year==2004
replace glyphosate=70954 if year==2005
replace glyphosate=82836 if year==2006
replace glyphosate=94719 if year==2007
replace glyphosate=106602 if year==2008
replace glyphosate=118485 if year==2009
replace glyphosate=127586 if year==2010


gen glyphosate_soy=glyphosate*area_soy/area_temp if year<=2003
quietly sum glyphosate_soy if year==2003
local glyphsoy2003=r(mean)
quietly sum glyphosate if year==2003
local glyph2003=r(mean)
replace glyphosate_soy = `glyphsoy2003' + (glyphosate-`glyph2003') if year>2003


tw (connected glyphosate year if !inrange(year,2006,2008), mcolor(black) lcolor(black) lpattern(solid)) ///
(connected glyphosate year if inrange(year,2006,2008), mcolor(black) m(Sh) lpattern(solid) lcolor(black)) ///
, scheme(s1mono) legend(off) ///
xscale(range(2000 2010)) xtick(2000(1)2010) xlabel(2000(1)2010) xtitle("") ///
yscale(range(0 150000)) ytick(0(25000)150000) ylabel(0(25000)150000, labsize(small) grid) ytitle("Metric tons of active ingredient" " ") ///
title("Glyphosate in Brazil per Year") 
graph save "$pathresults/glyphosate_br.gph", replace

restore
