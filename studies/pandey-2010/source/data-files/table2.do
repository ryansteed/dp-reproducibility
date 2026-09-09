
use "teachercharacterisitcs-table2.dta"

**Differences in observed charcateristics of teachers**

sum tcaste3 tcaste2 tcaste edu dissch tgen if op==1
sum tcaste3 tcaste2 tcaste edu dissch tgen if op==0

reg  tcaste3  op   , cluster(district)
reg  tcaste2  op   , cluster(district)
reg  tcaste op   , cluster(district)
reg  edu op   , cluster(district)
reg  dissch op  , cluster(district)
reg  tgen op  , cluster(district)

clear

use "villagecharacterisitcs-table2.dta", replace

sum elec phone gpdistroad gpsl density lit frsc frobc if op==1
sum elec phone gpdistroad gpsl density lit frsc frobc if op==0

*GP level differences**
reg elec   op   , cluster(district)
reg phone  op  , cluster(district)
reg gpdistroad  op  , cluster(district)
reg gpsl  op , cluster(district)
reg density   op , cluster(district)
reg lit op   , cluster(district)
reg frsc op    , cluster(district)
reg frobc op   , cluster(district)
clear


use "studentcharacterisitcs-table2.dta"
**Student characteristics**
sum  studenthighcaste studentobccaste studentsccaste  fatherprimaryedu motherprimaryedu studentgender if op==1
sum  studenthighcaste studentobccaste studentsccaste  fatherprimaryedu motherprimaryedu studentgender if op==0


reg studentobccaste op, cluster(district)
reg studentsccaste op, cluster(district)
reg studenthighcaste op, cluster(district)
reg fatherprimaryedu op, cluster(district)
reg motherprimaryedu op, cluster(district)
reg studentgender op, cluster(district)

clear
