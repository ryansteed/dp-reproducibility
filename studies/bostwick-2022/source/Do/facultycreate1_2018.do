clear

cd "$PATH/Academic Calendar"

quietly do ./do/faculty1990.do
quietly do ./do/faculty1991.do
quietly do ./do/faculty1992.do
quietly do ./do/faculty1993.do
quietly do ./do/faculty1994.do
quietly do ./do/faculty1995.do
quietly do ./do/faculty1996.do
quietly do ./do/faculty1997.do
quietly do ./do/faculty1998.do
quietly do ./do/faculty1999.do
*quietly do ./do/faculty2000.do
quietly do ./do/faculty2001.do
quietly do ./do/faculty2002.do
quietly do ./do/faculty2003.do
quietly do ./do/faculty2004.do
quietly do ./do/faculty2005.do
quietly do ./do/faculty2006.do
quietly do ./do/faculty2007.do
quietly do ./do/faculty2008.do
quietly do ./do/faculty2009.do
quietly do ./do/faculty2010.do
quietly do ./do/faculty2011.do
quietly do ./do/faculty2012.do
quietly do ./do/faculty2013.do
quietly do ./do/faculty2014.do
quietly do ./do/faculty2015.do
quietly do ./do/faculty2016.do


/*Year 2000 faculty data is missing. A new "blank" dataset is created and
then interpolated after it is appended to the rest of the years. The 
interpolation is just the linear value between 1999 and 2001.*/

clear
use ./data/faculty1999.dta
keep unitid
gen year=2000
gen faculty=.
save ./data/faculty2000.dta, replace


use ./data/faculty2016.dta
append using ./data/faculty2015.dta, force
append using ./data/faculty2014.dta, force
append using ./data/faculty2013.dta, force
append using ./data/faculty2012.dta, force
append using ./data/faculty2011.dta, force
append using ./data/faculty2010.dta, force
append using ./data/faculty2009.dta, force
append using ./data/faculty2008.dta, force
append using ./data/faculty2007.dta, force
append using ./data/faculty2006.dta, force
append using ./data/faculty2005.dta, force
append using ./data/faculty2004.dta, force
append using ./data/faculty2003.dta, force
append using ./data/faculty2002.dta, force
append using ./data/faculty2001.dta, force
append using ./data/faculty2000.dta, force
append using ./data/faculty1999.dta, force
append using ./data/faculty1998.dta, force
append using ./data/faculty1997.dta, force
append using ./data/faculty1996.dta, force
append using ./data/faculty1995.dta, force
append using ./data/faculty1994.dta, force
append using ./data/faculty1993.dta, force
append using ./data/faculty1992.dta, force
append using ./data/faculty1991.dta, force
append using ./data/faculty1990.dta, force

sort unitid year
bys unitid: ipolate faculty year if year>=1999 & year<=2001, gen(new)
replace faculty=new if year>1999 & year<2001
drop new

sort unitid year
save ./data/facultymaster1_2018.dta, replace

