clear
cd "$PATH/Academic Calendar"

forvalues i=1997/2016 {
quietly do ./do/publicrevenues`i'.do
cd "$PATH/Academic Calendar"
quietly do ./do/privaterevenues`i'.do
cd "$PATH/Academic Calendar"
}


forvalues i=1991/1996 {
quietly do ./do/costs`i'.do
cd "$PATH/Academic Calendar"
quietly do ./do/revenues`i'.do
cd "$PATH/Academic Calendar"
}



cd "$PATH/Academic Calendar/Data/"
use publicrevenues2016.dta
append using publicrevenues2015.dta
append using publicrevenues2014.dta
append using publicrevenues2013.dta
append using publicrevenues2012.dta
append using publicrevenues2011.dta
append using publicrevenues2010.dta
append using publicrevenues2009.dta
append using publicrevenues2008.dta
append using publicrevenues2007.dta
append using publicrevenues2006.dta
append using publicrevenues2005.dta
append using publicrevenues2004.dta
append using publicrevenues2003.dta
append using publicrevenues2002.dta
append using publicrevenues2001.dta
append using publicrevenues2000.dta
append using publicrevenues1999.dta
append using publicrevenues1998.dta
append using publicrevenues1997.dta
append using privaterevenues2016.dta
append using privaterevenues2015.dta
append using privaterevenues2014.dta
append using privaterevenues2013.dta
append using privaterevenues2012.dta
append using privaterevenues2011.dta
append using privaterevenues2010.dta
append using privaterevenues2009.dta
append using privaterevenues2008.dta
append using privaterevenues2007.dta
append using privaterevenues2006.dta
append using privaterevenues2005.dta
append using privaterevenues2004.dta
append using privaterevenues2003.dta
append using privaterevenues2002.dta
append using privaterevenues2001.dta
append using privaterevenues2000.dta
append using privaterevenues1999.dta
append using privaterevenues1998.dta
append using privaterevenues1997.dta

keep unitid costs revenue year
save revenues97_2016.dta, replace

clear
use revenues1996.dta
append using revenues1995.dta
append using revenues1994.dta
append using revenues1993.dta
append using revenues1992.dta
append using revenues1991.dta

sort unitid year

save revenues91_96.dta, replace

clear
use costs1996.dta
append using costs1995.dta
append using costs1994.dta
append using costs1993.dta
append using costs1992.dta
append using costs1991.dta

sort unitid year

save costs91_96.dta, replace
merge 1:1 unitid year using revenues91_96.dta

append using revenues97_2016.dta
drop _merge
*replace year=year-1
sort unitid year

save revenuesmaster1_2018.dta, replace

