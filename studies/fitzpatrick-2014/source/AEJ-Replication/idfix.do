clear
set mem 2g
use rcdata2

egen flag=tag(scname dsname year)
drop if flag==0
drop flag
keep rcds scname dsname year
replace year=year+1900 if year>0
replace year=2000 if year==0
reshape wide rcds, i(scname dsname) j(year)
save scid_rcdata, replace

use rcdata2, clear
replace year=year+1900 if year>0
replace year=2000 if year==0

egen firstyr=min(year), by(rcds)
egen lastyr=max(year), by(rcds)

dmerge scname dsname using scid_rcdata
drop if _merge==1
drop _merge

* Last Year 1991 *

gen rcds2=""
gen rcds3=""
gen rcds4=""
forvalues x=1992(1)2000{
replace rcds2=rcds`x' if rcds2=="" & lastyr==1991
replace rcds3=rcds`x' if rcds2~="" & rcds3=="" & rcds`x'~=rcds2 & rcds`x'~=rcds &  lastyr==1991
replace rcds4=rcds`x' if rcds2~="" & rcds3~="" & rcds4==""  & rcds`x'~=rcds3 & rcds`x'~=rcds2 & rcds`x'~=rcds &  lastyr==1991
}

* Last Year 1992 *

forvalues x=1993(1)2000{
replace rcds2=rcds`x' if rcds2=="" & lastyr==1992
replace rcds3=rcds`x' if rcds2~="" & rcds3=="" & rcds`x'~=rcds2 & rcds`x'~=rcds &  lastyr==1992
replace rcds4=rcds`x' if rcds2~="" & rcds3~="" & rcds4==""  & rcds`x'~=rcds3 & rcds`x'~=rcds2 & rcds`x'~=rcds &  lastyr==1992
}

* Last Year 1993 *

forvalues x=1994(1)2000{
replace rcds2=rcds`x' if rcds2=="" & lastyr==1993
replace rcds3=rcds`x' if rcds2~="" & rcds3=="" & rcds`x'~=rcds2 & rcds`x'~=rcds &  lastyr==1993
replace rcds4=rcds`x' if rcds2~="" & rcds3~="" & rcds4==""  & rcds`x'~=rcds3 & rcds`x'~=rcds2 & rcds`x'~=rcds &  lastyr==1993
}

* Last Year 1994 *

forvalues x=1995(1)2000{
replace rcds2=rcds`x' if rcds2=="" & lastyr==1994
replace rcds3=rcds`x' if rcds2~="" & rcds3=="" & rcds`x'~=rcds2 & rcds`x'~=rcds &  lastyr==1994
replace rcds4=rcds`x' if rcds2~="" & rcds3~="" & rcds4==""  & rcds`x'~=rcds3 & rcds`x'~=rcds2 & rcds`x'~=rcds &  lastyr==1994
}

* Last Year 1995 *

forvalues x=1996(1)2000{
replace rcds2=rcds`x' if rcds2=="" & lastyr==1995
replace rcds3=rcds`x' if rcds2~="" & rcds3=="" & rcds`x'~=rcds2 & rcds`x'~=rcds &  lastyr==1995
replace rcds4=rcds`x' if rcds2~="" & rcds3~="" & rcds4==""  & rcds`x'~=rcds3 & rcds`x'~=rcds2 & rcds`x'~=rcds &  lastyr==1995
}

* Last Year 1996 *

forvalues x=1997(1)2000{
replace rcds2=rcds`x' if rcds2=="" & lastyr==1996
replace rcds3=rcds`x' if rcds2~="" & rcds3=="" & rcds`x'~=rcds2 & rcds`x'~=rcds &  lastyr==1996
replace rcds4=rcds`x' if rcds2~="" & rcds3~="" & rcds4==""  & rcds`x'~=rcds3 & rcds`x'~=rcds2 & rcds`x'~=rcds &  lastyr==1996
}

* Last Year 1997 *

forvalues x=1998(1)2000{
replace rcds2=rcds`x' if rcds2=="" & lastyr==1997
replace rcds3=rcds`x' if rcds2~="" & rcds3=="" & rcds`x'~=rcds2 & rcds`x'~=rcds &  lastyr==1997
replace rcds4=rcds`x' if rcds2~="" & rcds3~="" & rcds4==""  & rcds`x'~=rcds3 & rcds`x'~=rcds2 & rcds`x'~=rcds &  lastyr==1997
}

* Last Year 1998 *

forvalues x=1999(1)2000{
replace rcds2=rcds`x' if rcds2=="" & lastyr==1998
replace rcds3=rcds`x' if rcds2~="" & rcds3=="" & rcds`x'~=rcds2 & rcds`x'~=rcds &  lastyr==1998
replace rcds4=rcds`x' if rcds2~="" & rcds3~="" & rcds4==""  & rcds`x'~=rcds3 & rcds`x'~=rcds2 & rcds`x'~=rcds &  lastyr==1998
}

* Last Year 1999 *

replace rcds2=rcds2000 if rcds2=="" & lastyr==1999
replace rcds3=rcds2000 if rcds2~="" & rcds3=="" & rcds2000~=rcds2 & rcds2000~=rcds &  lastyr==1999
replace rcds4=rcds2000 if rcds2~="" & rcds3~="" & rcds4==""  & rcds2000~=rcds3 & rcds2000~=rcds2 & rcds2000~=rcds &  lastyr==1999
drop rcds4

gen rcds_fix=rcds
replace rcds_fix=rcds2 if rcds2~=""
replace rcds_fix=rcds3 if rcds3~=""
drop rcds1990-rcds2000
gen district=substr(rcds_fix,1,9)
save rcdata2_idfix, replace

keep rcds rcds2 rcds3 year
save idfix, replace








