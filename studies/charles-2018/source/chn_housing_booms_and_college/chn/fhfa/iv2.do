
clear
set more off
set matsize 10000




**
* Structural break code
**



clear
insheet using msa_houseprice_growth_final.txt
keep metarea fhfacode
sort fhfacode metarea
by fhfacode: gen myn = _n

forvalues i = 1/4 {

 preserve
keep if myn == `i'
drop myn
sort metarea
save ./tmp/metarea_to_fhfacode`i'.dta, replace
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

gen cpi = .

/*
ftp://ftp.bls.gov/pub/special.requests/cpi/cpiai.txt
 ** ANNUAL AVERAGE
 */
replace cpi = 130.7 if year == 1990
replace cpi = 136.2 if year == 1991
replace cpi = 140.3 if year == 1992
replace cpi = 144.5 if year == 1993
replace cpi = 148.2 if year == 1994
replace cpi = 152.4 if year == 1995
replace cpi = 156.9 if year == 1996
replace cpi = 160.5 if year == 1997
replace cpi = 163.0 if year == 1998
replace cpi = 166.6 if year == 1999
replace cpi = 172.2 if year == 2000
replace cpi = 177.1 if year == 2001
replace cpi = 179.9 if year == 2002
replace cpi = 184.0 if year == 2003
replace cpi = 188.9 if year == 2004
replace cpi = 195.3 if year == 2005
replace cpi = 201.6 if year == 2006
replace cpi = 207.342 if year == 2007
replace cpi = 215.303 if year == 2008
replace cpi = 214.537 if year == 2009
replace cpi = 218.056 if year == 2010
replace cpi = 224.939 if year == 2011

keep if year >= 2000 & year <= 2005

bys year: summ hpi

replace hpi = hpi / cpi

collapse (mean) hpi cpi, by(fhfacode year q) 


drop if missing(fhfacode)
sort fhfacode
save ./tmp/fhfa.dta, replace


forvalues i = 2/4 {

clear
use ./tmp/metarea_to_fhfacode`i'.dta, replace
sort fhfacode
merge fhfacode using ./tmp/fhfa.dta
tab metarea _merge, missing
keep if _merge == 3
rename _merge _merge`i'
save ./tmp/temp`i'.dta, replace

}

clear
use ./tmp/metarea_to_fhfacode1.dta, replace
sort fhfacode
merge fhfacode using ./tmp/fhfa.dta
tab metarea _merge, missing
keep if _merge == 3

append using ./tmp/temp2.dta
append using ./tmp/temp3.dta
append using ./tmp/temp4.dta

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



*0-27 (year)
*1-284 (metarea)

summ hpi_orig
local mean = r(mean)
summ hpi
replace hpi = hpi + `mean' - r(mean)

xtset metarea year

matrix results = J(284, 6, .)

forvalues m = 1/284 {
 qui summ metarea if mnum == `m'
 local metarea = r(mean)
 matrix results[`m',1] = `metarea'
 local r2 = -1
 local topt = 0
 local diff = 0

 ** Q1:2001 - Q1:2005
 ** Andrews "trimming region"
 forvalues t = 5/21 {

  capture drop post

  gen post = (year - `t') * (year >= `t')
  qui reg hpi year post if mnum == `m'

  if (e(r2) > `r2') {
   local r2 = e(r2)

   local topt = `t'

   local orig = _b[year]
   local cons = _b[_cons]
   local diff = _b[post]
   qui test post
   local p = r(p)
  }
 }
 di "metarea: `metarea'; `topt', `diff'" 
 matrix results[`m',2] = `topt'
 matrix results[`m',3] = `diff'
 matrix results[`m',4] = `orig'
 matrix results[`m',5] = `cons'
 matrix results[`m',6] = `p'
}

matrix list results

drop _all
svmat results

rename results1 metarea
rename results2 t_log
rename results3 iv2_log
rename results4 beta_year
rename results5 cons
rename results6 pval

corr iv2_log pval
reg iv2_log pval

sort metarea
save ./new_iv2_log.dta, replace

exit


