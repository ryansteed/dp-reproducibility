/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 12/21/2020

DESCRIPTION:
This do-file imports information from district-level revenue limits
from 1996-97 through 2014-15. This dataset is reported at the district level
through the WI Department of Public Instruction.

DATA INPUTS: (1) revlim_mem.xls (2) cpiu.dta
DATA OUTPUTS: (1) revenue_limits.dta
*********************************/

*****************************************
******SECTION I: IMPORT REV LIM DATA
*****************************************
clear
set more off
cd "${path}Data\Raw\Revenue_Limits"

*Import dataset
import excel using revlim_mem.xls, sheet(Data)


*****************************************
******SECTION II: GEN DISTRICT-BY-YEAR PANEL
*****************************************
*Keep only variables of interest
keep A B N Q T W Z AC AF AI AL AO AR AU AX BA BD BG BJ BM BP ///
L O R U X AA AD AG AJ AM AP AS AV AY BB BE BH BK BN

*Rename variables
rename (A B N Q T W Z AC AF AI AL AO AR AU AX BA BD BG BJ BM BP) ///
(district_code district_name rev_lim_mem1996 rev_lim_mem1997 ///
rev_lim_mem1998 rev_lim_mem1999 rev_lim_mem2000 rev_lim_mem2001 ///
rev_lim_mem2002 rev_lim_mem2003 rev_lim_mem2004 rev_lim_mem2005 ///
rev_lim_mem2006 rev_lim_mem2007 rev_lim_mem2008 rev_lim_mem2009 ///
rev_lim_mem2010 rev_lim_mem2011 rev_lim_mem2012 rev_lim_mem2013 rev_lim_mem2014)

rename (L O R U X AA AD AG AJ AM AP AS AV AY BB BE BH BK BN) ///
(mem1996 mem1997 ///
mem1998 mem1999 mem2000 mem2001 ///
mem2002 mem2003 mem2004 mem2005 ///
mem2006 mem2007 mem2008 mem2009 ///
mem2010 mem2011 mem2012 mem2013 mem2014)


*Drop empty cells
drop if district_code==""
drop if district_code=="CODE"|district_code=="district_code"

*Destring 
local z district_code rev_lim_mem1996 rev_lim_mem1997 ///
rev_lim_mem1998 rev_lim_mem1999 rev_lim_mem2000 rev_lim_mem2001 ///
rev_lim_mem2002 rev_lim_mem2003 rev_lim_mem2004 rev_lim_mem2005 ///
rev_lim_mem2006 rev_lim_mem2007 rev_lim_mem2008 rev_lim_mem2009 ///
rev_lim_mem2010 rev_lim_mem2011 rev_lim_mem2012 rev_lim_mem2013 rev_lim_mem2014 ///
mem1996 mem1997 mem1998 mem1999 mem2000 mem2001 ///
mem2002 mem2003 mem2004 mem2005 mem2006 mem2007 mem2008 mem2009 ///
mem2010 mem2011 mem2012 mem2013 mem2014

foreach var in `z'{
destring `var', replace
}

*Reshape data
reshape long rev_lim_mem mem, i(district_code) j(year)
rename year school_year


*Convert to 2010 dollars using the Midwestern CPI-U
merge m:1 school_year using "${path}Data\Intermediate\cpiu"
edit if _merge==2 // I do not have these school years in my dataset
drop if _merge==2
drop _merge
sort district_code school_year

*Make a variable measuring CPI in 2010
gen cpi2010 =.
order cpi2010
replace cpi2010=208.046
gen newcpi = cpi/cpi2010
order newcpi

*Convert revenue limit per member measure
replace rev_lim_mem = (rev_lim/newcpi) //deflate

*Drop these additional variables
drop newcpi cpi2010 cpi 

*Deal with consolidations, name changes, and mergers

*There are a few consolidations a mergers to worry about. The full list can
*be found here: https://dpi.wi.gov/sms/reorganization/history-and-orders

*(1) River Ridge (merge between Bloomington and West Grant in 1995)
drop if district_code==4249 | district_code==539

*(2) Trevor - Wilmot (merge between Trevor Grade and Wilmot Grade in 2006)
*Also, Salem changed name to Trevor in 2000
replace district_code = 5780 if district_code== 5061 //replace Trevor's (Salem) district_code
replace district_code = 5780 if district_code== 5075 //replace Wilmot's district_code
edit if district_code== 5780
sort district_code school_year //at the end, I will collapse by year and district_code to fix this merger


*(3) There was a split between Shawano-Gresham into Shawano and Gresham in 2007-08
*Gresham appears in the data from 2007 on. I will take the Shawano-Gresham school district as one through the sample.
edit if district_code==2415|district_code==5264
replace district_code = 5264 if district_code== 2415


*(4) Glidden and Park Falls merged in 2009 to become Chequamegon
replace district_code = 1071 if district_code == 2205 //glidden
replace district_code = 1071 if district_code == 4242 //park falls
edit if district_code==1071

*(5) Chetek and Weyerhauser merged to become Chetek - Weyerhauser
replace district_code = 1080 if district_code == 1078 //chetek
replace district_code = 1080 if district_code == 6410 //weyerhauser
edit if district_code==1080


*(6) Herman, Neosho, Rubicon merged in 2016
replace district_code=2525 if district_code==4998 //Rubicon 
replace district_code=2525 if district_code==3913 //Neosho
replace district_code=2525 if district_code==2523 //Herman
edit if district_code==2525


*Before I collapse, generate "revenue limits"
gen rev_lim = rev_lim_mem*mem 

*Collapse data to account for these consolidations
collapse (sum) rev_lim mem, by(district_code school_year) 
gen rev_lim_mem = rev_lim/mem
keep district_code school_year rev_lim_mem

*****************************************
******SECTION III: SAVE THIS DATASET
*****************************************
save "${path}Data\Raw\Completed_Files\revenue_limits", replace
