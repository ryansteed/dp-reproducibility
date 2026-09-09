*BLS-LAUS-unemployment-data.do

clear
use BLS-LAUS-Alabama.dta
gen state_nm="Alabama"
drop jan2014 feb2014 mar2014 apr2014 may2014 jun2014 jul2014 aug2014 sep2014 oct2014 nov2014 dec2014
capture noisily: drop annual*
foreach x in Arizona Arkansas California Colorado Connecticut DC Delaware Florida Georgia Idaho Illinois Indiana Iowa Kansas Kentucky Louisiana Maine Maryland Massachusetts Michigan Minnesota Mississippi Missouri Montana Nebraska Nevada NewHampshire NewJersey NewMexico NewYork NorthCarolina NorthDakota Ohio Oklahoma Oregon Pennsylvania RhodeIsland SouthCarolina SouthDakota Tennesse Texas Utah Vermont Virginia Washington WestVirginia Wisconsin Wyoming{
di "`x'"
append using BLS-LAUS-`x'.dta
drop jan2014 feb2014 mar2014 apr2014 may2014 jun2014 jul2014 aug2014 sep2014 oct2014 nov2014 dec2014
capture noisily: drop annual*
replace state_nm="`x'" if state_nm==""
}


gen temp=substr( seriesid, 19,.)
replace seriesid=substr(seriesid, 1, 18)

replace temp="unemp_r" if temp=="03"
replace temp="unemp" if temp=="04"
replace temp="emp" if temp=="05"
replace temp="labforce" if temp=="06"



reshape wide jan2004 feb2004 mar2004 apr2004 may2004 jun2004 jul2004 aug2004 sep2004 oct2004 nov2004 dec2004 jan2005 feb2005 mar2005 apr2005 may2005 jun2005 jul2005 aug2005 sep2005 oct2005 nov2005 dec2005 jan2006 feb2006 mar2006 apr2006 may2006 jun2006 jul2006 aug2006 sep2006 oct2006 nov2006 dec2006 jan2007 feb2007 mar2007 apr2007 may2007 jun2007 jul2007 aug2007 sep2007 oct2007 nov2007 dec2007 jan2008 feb2008 mar2008 apr2008 may2008 jun2008 jul2008 aug2008 sep2008 oct2008 nov2008 dec2008 jan2009 feb2009 mar2009 apr2009 may2009 jun2009 jul2009 aug2009 sep2009 oct2009 nov2009 dec2009 jan2010 feb2010 mar2010 apr2010 may2010 jun2010 jul2010 aug2010 sep2010 oct2010 nov2010 dec2010 jan2011 feb2011 mar2011 apr2011 may2011 jun2011 jul2011 aug2011 sep2011 oct2011 nov2011 dec2011 jan2012 feb2012 mar2012 apr2012 may2012 jun2012 jul2012 aug2012 sep2012 oct2012 nov2012 dec2012 jan2013 feb2013 mar2013 apr2013 may2013 jun2013 jul2013 aug2013 sep2013 oct2013 nov2013 dec2013, i(seriesid) j(temp) string


gen st_fips=substr(seriesid, 6,2)
destring st_fips, replace
gen fullarea_cd=substr(seriesid, 4,.)
gen county_cd=substr(seriesid, 8,3)
gen st_county_cd=substr(seriesid, 6,5)

reshape long @emp @unemp @unemp_r @labforce, i(seriesid) j(temp) string
gen month=substr(temp, 1,3)
gen year=substr(temp, 4,.)
drop temp
destring year, replace
merge m:1 fullarea_cd using BLS-LAUS-County-Names.dta
drop if _merge==2
drop _merge
save BLS-LAUS-All.dta, replace
