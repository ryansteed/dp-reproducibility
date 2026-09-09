

clear
set more off
set matsize 10000



if (`1' == 1) {
** 1% critical values
global c1 = 13.58
global c2 = 15.03
global c3 = 15.62
}

if (`1' == 5) {
** 5% critical values
global type = 5
global c1 = 9.63
global c2 = 11.14
global c3 = 12.16
}

if (`1' == 10) {
** 10% critical values
global c1 = 8.02
global c2 = 9.56
global c3 = 10.45
}




clear
insheet using mas_houseprice_growth_final.txt
keep metarea fhfacode
sort fhfacode metarea
by fhfacode: gen myn = _n

forvalues i = 1/4 {

 preserve
keep if myn == `i'
drop myn
sort metarea
save /tmp/metarea_to_fhfacode`i'.dta, replace
 restore

}




clear
insheet using fhfa.csv

rename v1 city
rename v2 fhfacode
rename v3 year
rename v4 q
rename v5 hpi_str

gen hpi = real(hpi_str)

assert(hpi_str == "-") if missing(hpi)
drop if missing(hpi)

do cpi.do

keep if year >= 1995 & year <= 2005

bys year: summ hpi
replace hpi = hpi / cpi

collapse (mean) hpi cpi, by(fhfacode year q) 

drop if missing(fhfacode)
sort fhfacode
save ./fhfa.dta, replace






forvalues i = 2/4 {

clear
use /tmp/metarea_to_fhfacode`i'.dta, replace
sort fhfacode
merge fhfacode using ./fhfa.dta
tab metarea _merge, missing
keep if _merge == 3
rename _merge _merge`i'
save /tmp/temp`i'.dta, replace

}

clear
use /tmp/metarea_to_fhfacode1.dta, replace
sort fhfacode
merge fhfacode using ./fhfa.dta
tab metarea _merge, missing
keep if _merge == 3

append using /tmp/temp2.dta
append using /tmp/temp3.dta
append using /tmp/temp4.dta

tab _merge _merge2, missing

isid metarea year q





gen hpi_orig = hpi
replace hpi = log(hpi)

gen year_orig = year
replace year = year*4 + (q-1)

summ year
replace year = year - r(min) + 1
tab year, missing
egen mnum = group(metarea)




summ hpi
summ hpi_orig
local mean = r(mean)
summ hpi
replace hpi = hpi + `mean' - r(mean)
summ hpi






xtset metarea year
matrix results = J(284, 23, .)


**
** 1-44 (year)
** 1-284 (metarea)
**
summ year, det
summ mnum, det

forvalues m = 1/284 {

 qui summ metarea if mnum == `m'
 local metarea = r(mean)

 qui summ fhfacode if mnum == `m'
 local fhfacode = r(mean)
 
 matrix results[`m',1] = `metarea'
 matrix results[`m',2] = `fhfacode'
 
 local r2 = -1
 local topt = 0
 local diff = 0

 local r2_p25 = -1

capture drop resid
capture drop sse*
reg hpi year if mnum == `m'
predict resid, resid
gen sse_input = (resid)^2
egen sse = sum(sse_input * (mnum == `m'))
summ sse, meanonly
local sse0 = r(mean)
summ resid if mnum == `m'
local sigma2_0 = r(Var)


 ** Q4:1995 - Q1:2005
 ** Andrews "trimming region" (5%-15% of total sample)
 forvalues t = 4/41 {

  capture drop post1
  gen post1 = (year - `t') * (year >= `t')
  reg hpi year post1 if mnum == `m', robust

 if (e(r2) > `r2') {
  local r2 = e(r2)
  local t1 = `t'
  local orig1 = _b[year]
  local diff1 = _b[post1]
 }

 if (e(r2) > `r2_p25') {
  local r2_p25 = e(r2)
  local t1_p25 = `t'
  local orig1_p25 = _b[year]
  local diff1_p25 = _b[post1]
 }


 ** END first loop through t 4/41
 }
 di "metarea `metarea' (4,41) [t1]; `t1', `diff1', `p1'"

capture drop post1
capture drop resid
capture drop sse*  
gen post1 = (year - `t1') * (year >= `t1')
qui reg hpi year post1 if mnum == `m' 
predict resid, resid
gen sse_input = (resid)^2
egen sse = sum(sse_input * (mnum == `m'))
summ sse, meanonly
local sse1 = r(mean)
summ resid if mnum == `m'
local sigma2_1 = r(Var)
local val = (`sse0' - `sse1')/`sigma2_0'
 matrix results[`m',3] = `t1'
 matrix results[`m',4] = `diff1'
 matrix results[`m',5] = `orig1'
 matrix results[`m',6] = `sse1'
 matrix results[`m',7] = `val'
 matrix results[`m',8] = (`val' > $c1)







**
** Check if first break is before 25
**
if (results[`m', 8] == 0 | results[`m',3] < 25) {

 local t2a = .
 local max1 = 41
 local min1 = 25

 local sse2a = 1e10

 local r2 = -1
 forvalues t = `min1'/`max1' {
   capture drop post2
   gen post2 = (year - `t') * (year >= `t')
   qui reg hpi year post1 post2 if mnum == `m' 

   if (e(r2) > `r2') {
   local r2 = e(r2)
   local t2a = `t'
   local orig2a = _b[year]
   local diff2a1 = _b[post1]
   local diff2a2 = _b[post2]

   }
  }

 
  di "metarea `metarea' (4,`max1') [t2a]; `t2a', `diff2a', `p2a'"

capture drop post2
capture drop resid
capture drop sse*  
gen post2 = (year - `t2a') * (year >= `t2a')
qui reg hpi year post1 post2 if mnum == `m'
predict resid, resid
gen sse_input = (resid)^2
egen sse = sum(sse_input * (mnum == `m'))
summ sse, meanonly
local sse2a = r(mean)
summ resid if mnum == `m'
local sigma2_2a = r(Var)

local min_sse2 = `sse2a'
local t2 = `t2a'
local diff2_1 = `diff2a1'
local diff2_2 = `diff2a2'
local orig2 = `orig2a'
local sse2 = `sse2a'
local sigma2_2 = `sigma2_2a'

local val = (`sse1' - `min_sse2')/`sigma2_1'

  matrix results[`m',9] = `t2'
  matrix results[`m',10] = `diff2_1'
  matrix results[`m',11] = `diff2_2'
  matrix results[`m',12] = `orig2'
  matrix results[`m',13] = `sse2'
  matrix results[`m',14] = `val'
  matrix results[`m',15] = (`val' > $c2)

}


  matrix results[`m',16] = `t1_p25'
  matrix results[`m',17] = `diff1_p25'
  matrix results[`m',18] = `orig1_p25'


**
** End FOR through all MSAs
**
}


matrix list results

drop _all
svmat results

rename results1 metarea
rename results2 fhfacode

rename results3 t1
rename results4 diff1
rename results5 orig1
rename results6 sse1
rename results7 val1
rename results8 val1d

rename results9 t2
rename results10 diff2_1
rename results11 diff2_2
rename results12 orig2
rename results13 sse2
rename results14 val2
rename results15 val2d

rename results16 t1_p25
rename results17 diff1_p25
rename results18 orig1_p25

sort metarea
save ./new_iv7_log_p`1'_RAW.dta, replace

exit


