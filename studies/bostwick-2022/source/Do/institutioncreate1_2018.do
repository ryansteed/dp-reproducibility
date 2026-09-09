clear

cd "$PATH/Academic Calendar"


quietly do ./do/institution1986.do
quietly do ./do/institution1987.do
quietly do ./do/institution1988.do
quietly do ./do/institution1989.do
quietly do ./do/institution1990.do
quietly do ./do/institution1991.do
quietly do ./do/institution1992.do
quietly do ./do/institution1993.do
quietly do ./do/institution1994.do
quietly do ./do/institution1995.do
quietly do ./do/institution1996.do
quietly do ./do/institution1997.do
quietly do ./do/institution1998.do
quietly do ./do/institution1999.do
quietly do ./do/institution2000.do
quietly do ./do/institution2001.do
quietly do ./do/institution2002.do
quietly do ./do/institution2003.do
quietly do ./do/institution2004.do
quietly do ./do/institution2005.do
quietly do ./do/institution2006.do
quietly do ./do/institution2007.do
quietly do ./do/institution2008.do
quietly do ./do/institution2009.do
quietly do ./do/institution2010.do
quietly do ./do/institution2011.do
quietly do ./do/institution2012.do
quietly do ./do/institution2013.do
quietly do ./do/institution2014.do
quietly do ./do/institution2015.do
quietly do ./do/institution2016.do

use ./data/institution1986.dta
append using ./data/institution1987.dta, force
append using ./data/institution1988.dta, force
append using ./data/institution1989.dta, force
append using ./data/institution1990.dta, force
append using ./data/institution1991.dta, force
append using ./data/institution1992.dta, force
append using ./data/institution1993.dta, force
append using ./data/institution1994.dta, force
append using ./data/institution1995.dta, force
append using ./data/institution1996.dta, force
append using ./data/institution1997.dta, force
append using ./data/institution1998.dta, force
append using ./data/institution1999.dta, force
append using ./data/institution2000.dta, force
append using ./data/institution2001.dta, force
append using ./data/institution2002.dta, force
append using ./data/institution2003.dta, force
append using ./data/institution2004.dta, force
append using ./data/institution2005.dta, force
append using ./data/institution2006.dta, force
append using ./data/institution2007.dta, force
append using ./data/institution2008.dta, force
append using ./data/institution2009.dta, force
append using ./data/institution2010.dta, force
append using ./data/institution2011.dta, force
append using ./data/institution2012.dta, force
append using ./data/institution2013.dta, force
append using ./data/institution2014.dta, force
append using ./data/institution2015.dta, force
append using ./data/institution2016.dta, force

drop if year==1986


gen semester=0
replace semester=1 if calsys==1
gen quarter=0
replace quarter=1 if calsys==2
gen trimester=0
replace trimester=1 if calsys==3
gen four1four=0
replace four1four=1 if calsys==4
gen othercalsys=0
replace othercalsys=1 if calsys<0|calsys>4
keep unitid year semester quarter trimester four1four othercalsys calsys
sort unitid year

save ./data/institutionmaster1_2018.dta, replace
