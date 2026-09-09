clear

cd "$PATH/Academic Calendar"

quietly do ./do/tuition1990.do
quietly do ./do/tuition1991.do
quietly do ./do/tuition1992.do
quietly do ./do/tuition1993.do
quietly do ./do/tuition1994.do
quietly do ./do/tuition1995.do
quietly do ./do/tuition1996.do
quietly do ./do/tuition1997.do
quietly do ./do/tuition1998.do
quietly do ./do/tuition1999.do
quietly do ./do/tuition2000.do
quietly do ./do/tuition2001.do
quietly do ./do/tuition2002.do
quietly do ./do/tuition2003.do
quietly do ./do/tuition2004.do
quietly do ./do/tuition2005.do
quietly do ./do/tuition2006.do
quietly do ./do/tuition2007.do
quietly do ./do/tuition2008.do
quietly do ./do/tuition2009.do
quietly do ./do/tuition2010.do
quietly do ./do/tuition2011.do
quietly do ./do/tuition2012.do
quietly do ./do/tuition2013.do
quietly do ./do/tuition2014.do
quietly do ./do/tuition2015.do
quietly do ./do/tuition2016.do


use ./data/tuition2016.dta
append using ./data/tuition2015.dta, force
append using ./data/tuition2014.dta, force
append using ./data/tuition2013.dta, force
append using ./data/tuition2012.dta, force
append using ./data/tuition2011.dta, force
append using ./data/tuition2010.dta, force
append using ./data/tuition2009.dta, force
append using ./data/tuition2008.dta, force
append using ./data/tuition2007.dta, force
append using ./data/tuition2006.dta, force
append using ./data/tuition2005.dta, force
append using ./data/tuition2004.dta, force
append using ./data/tuition2003.dta, force
append using ./data/tuition2002.dta, force
append using ./data/tuition2001.dta, force
append using ./data/tuition2000.dta, force
append using ./data/tuition1999.dta, force
append using ./data/tuition1998.dta, force
append using ./data/tuition1997.dta, force
append using ./data/tuition1996.dta, force
append using ./data/tuition1995.dta, force
append using ./data/tuition1994.dta, force
append using ./data/tuition1993.dta, force
append using ./data/tuition1992.dta, force
append using ./data/tuition1991.dta, force
append using ./data/tuition1990.dta, force

order unitid year
sort unitid year

save ./data/tuitionmaster1_2018.dta, replace

