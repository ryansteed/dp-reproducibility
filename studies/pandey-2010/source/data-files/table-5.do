
 use "table-5-teacher.dta"
**soil and climate as control**
reg  tattendance  op      dms01- dmts4 lon lat alt rain , cluster(district)
reg  tactivity   op   dms01- dmts4 lon lat alt rain  , cluster(district)

**soil, climate controls and population variables *
reg  tattendance  frsc frobc   totpop  op  density     dms01- dmts4 lon lat alt rain , cluster(district)
reg  tactivity  frsc frobc   totpop  op  density  dms01- dmts4 lon lat alt rain  , cluster(district)

**soil, climate controls, population variables and teacher, gp characteristics****
eststo teacherattend: reg  tattendance tcaste tcaste2 tgen  edu toenr dissch frsc frobc   totpop op density  lit index elec phone gpdistro dms01- dmts4 lon lat alt rain, cluster(district)
eststo activity: reg  tactivity tcaste tcaste2 tgen  edu toenr dissch frsc frobc  totpop op density  lit index  elec phone gpdistro dms01- dmts4 lon lat alt rain, cluster(district)

clear


use "table-5-stipend.dta"

**Stipend received by SC students**
**soil and climate as control**
reg scholar oudh  dms01- dmts4 lon lat alt rain if caste2==0 , cluster(district)
**soil, climate controls and population variables *
reg scholar oudh frsc frobc density totpop dms01- dmts4 lon lat alt rain if caste2==0 , cluster(district)
**soil, climate controls, population variables and gp characteristics****
eststo stipend: reg scholar oudh frsc frobc density totpop lit elec phone gpdistro  dms01- dmts4 lon lat alt rain if caste2==0 , cluster(district)

clear

use "table-5-infrastructure.dta"

**soil and climate as controls**
reg  index  op  dms01- dmts4 lon lat alt rain  , cluster(district)
**soil, climate controls and population variables *
reg  index  frsc frobc  totpop  op  density  dms01- dmts4 lon lat alt rain  , cluster(district)
**soil, climate controls, population variables and gp characteristics****
eststo infra: reg  index frsc frobc  totpop op density lit  elec phone gpdistro dms01- dmts4 lon lat alt rain, cluster(district)
clear

use "table-5-student-score-attendance.dta"
**standardized score and attendance**
**soil and climate controls**
reg meanscore    op  dms01- dmts4 lon lat alt rain, cluster(district)
reg studentattendance  op dms01- dmts4 lon lat alt rain, cluster(district)

**soil, climate controls and population variables *
reg meanscore    frsc frobc  totpop  op density  dms01- dmts4 lon lat alt rain, cluster(district)
reg studentattendance frsc frobc totpop op density  dms01- dmts4 lon lat alt rain, cluster(district)

**soil, climate controls, population variables and gp characteristics****
eststo meanscore: reg meanscore scaste scaste2 sgen me2 me3 fe2 fe3  tepupr frsc frobc  totpop  op density  elec phone gpdistro index  lit dms01- dmts4 lon lat alt rain, cluster(district)
eststo studentattend: reg studentattendance scaste scaste2 sgen me2 me3 fe2 fe3  tepupr frsc frobc  totpop  op density  elec phone gpdistro index  lit dms01- dmts4 lon lat alt rain, cluster(district)

*** EDITED by Donna
estout using "../../results/table5.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

clear






