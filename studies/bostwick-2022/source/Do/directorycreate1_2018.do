clear
cd "$PATH/Academic Calendar"


quietly do ./do/directory1987.do
quietly do ./do/directory1988.do
quietly do ./do/directory1989.do
quietly do ./do/directory1990.do
quietly do ./do/directory1991.do
quietly do ./do/directory1992.do
quietly do ./do/directory1993.do
quietly do ./do/directory1994.do
quietly do ./do/directory1995.do
quietly do ./do/directory1996.do
quietly do ./do/directory1997.do
quietly do ./do/directory1998.do
quietly do ./do/directory1999.do
quietly do ./do/directory2000.do
quietly do ./do/directory2001.do
quietly do ./do/directory2002.do
quietly do ./do/directory2003.do
quietly do ./do/directory2004.do
quietly do ./do/directory2005.do
quietly do ./do/directory2006.do
quietly do ./do/directory2007.do
quietly do ./do/directory2008.do
quietly do ./do/directory2009.do
quietly do ./do/directory2010.do
quietly do ./do/directory2011.do
quietly do ./do/directory2012.do
quietly do ./do/directory2013.do
quietly do ./do/directory2014.do
quietly do ./do/directory2015.do
quietly do ./do/directory2016.do

use ./data/directory1987.dta
append using ./data/directory1988.dta, force
append using ./data/directory1989.dta, force
append using ./data/directory1990.dta, force
append using ./data/directory1991.dta, force
append using ./data/directory1992.dta, force
append using ./data/directory1993.dta, force
append using ./data/directory1994.dta, force
append using ./data/directory1995.dta, force
append using ./data/directory1996.dta, force
append using ./data/directory1997.dta, force
append using ./data/directory1998.dta, force
append using ./data/directory1999.dta, force
append using ./data/directory2000.dta, force
append using ./data/directory2001.dta, force
append using ./data/directory2002.dta, force
append using ./data/directory2003.dta, force
append using ./data/directory2004.dta, force
append using ./data/directory2005.dta, force
append using ./data/directory2006.dta, force
append using ./data/directory2007.dta, force
append using ./data/directory2008.dta, force
append using ./data/directory2009.dta, force
append using ./data/directory2010.dta, force
append using ./data/directory2011.dta, force
append using ./data/directory2012.dta, force
append using ./data/directory2013.dta, force
append using ./data/directory2014.dta, force
append using ./data/directory2015.dta, force
append using ./data/directory2016.dta, force

gen observation=1
bys unitid: egen totalyears=sum(observation)
keep unitid year totalyears instnm city carnegie stabbr fips obereg fice sector iclevel control affil hloffer

drop if sector!=1 & sector!=2
bys unitid: egen carnegie1=max(carnegie)
drop if carnegie1<10 | carnegie1>32

xtset unitid year

save ./data/directorymaster1_2018.dta, replace
