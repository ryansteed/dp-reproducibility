use table4.dta 
**village meetings**
reg  gsmeet  op dms01- dmts4 lon lat alt rain, cluster(district)
reg  gsmeet  op dms01- dmts4  lon lat alt rain frsc frobc totpop density, cluster(district)
eststo gsmeet: reg  gsmeet  op dms01- dmts4 lon lat alt rain frsc frobc totpop density elec phone gpdistro lit , cluster(district)

**village education committee meetings**
reg  ssmeet  op dms01- dmts4 lon lat alt rain, cluster(district)
reg  ssmeet  op dms01- dmts4 lon lat alt rain frsc frobc totpop density , cluster(district)
eststo ssmeet: reg  ssmeet  op dms01- dmts4 lon lat alt rain frsc frobc totpop density elec phone gpdistro lit , cluster(district)

**PTA meetings**
reg  ptameet   op dms01- dmts4 lon lat alt rain, cluster(district)
reg  ptameet op dms01- dmts4 lon lat alt rain frsc frobc totpop density  , cluster(district)
eststo ptameet: reg  ptameet op dms01- dmts4  lon lat alt rain frsc frobc totpop density elec phone gpdistro lit, cluster(district)

*** EDITED by Donna
estout using "../../results/table4_1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

clear


eststo clear
use "table4-health-committee.dta"
**if health committee met**
reg  healthcommittee  oudh dms01- dmts4   lon lat alt rain , cluster(district)
reg  healthcommittee  oudh dms01- dmts4   lon lat alt rain frsc frobc totpop density , cluster(district)
eststo: reg  healthcommittee  oudh dms01- dmts4   lon lat alt rain frsc frobc totpop density elec phone gpdistro lit, cluster(district)
*** EDITED by Donna
estout using "../../results/table4_2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
clear




