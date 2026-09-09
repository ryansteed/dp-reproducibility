global DropboxFolder "."
global DataFolder "."

cd "$DataFolder"
use "$DataFolder/AEJApplied_CrossCountryData.dta", clear

gen avglogdist90_adj = 1-pcia_90
gen avglogdist90_unadj = 1-pci_90
gen largest_avglogdist90_adj = 1-largestgcisc2_90
gen other_avglogdist90_adj = 1-othergcisc2_90

* Generating Autocracy dummy and interaction
cap drop autocracy 
cap drop tercile*
pctile tercile=polity if iso~="ZAF" & iso~="MUS" & iso~="MMR" & iso~="KAZ" & dup<2, nq(3)
egen tercile1_polity = min(tercile)
gen autocracy=1 if polity<=tercile1_polity
replace autocracy=0 if polity>tercile1_polity & polity!=.
drop tercile*


*** EDIT BY Donna
/*
***********************************************
* Figure 2: Basic Scatterplot (WGI Governance *
***********************************************
scatter kkm_pcfirst_9612 avglogdist90_adj if iso~="ZAF" & iso~="MUS" & iso~="MMR" & iso~="KAZ" & dup<2, mlabel(iso) || lfit kkm_pcfirst avglogdist90_adj if iso~="ZAF" & iso~="MUS" & iso~="MMR" & iso~="KAZ" & dup<2, legend(label(1 "WGI First PC")) xtitle("Avg Log Distance") title("Full Sample") ylabel(-5 0 5)


**************************
* Figure 3: Split Sample *
**************************
scatter kkm_pcfirst avglogdist90_adj if autocracy==1 & iso~="MMR" & iso~="KAZ" & dup<2, mlabel(iso) || lfit kkm_pcfirst avglogdist90_adj if autocracy==1 & iso~="MMR" & iso~="KAZ" & dup<2, legend(label(1 "WGI First PC")) xsc(r(.5 .9)) xtitle("Avg Log Distance") title("A. Autocracies (Polity bottom tercile)") ylabel(-5 0 5)
scatter kkm_pcfirst avglogdist90_adj if polity>9 & polity~=. & iso~="ZAF" & iso~="MUS" & iso~="MMR" & iso~="KAZ" & dup<2, mlabel(iso) || lfit kkm_pcfirst avglogdist90_adj if polity>9 & polity~=. & iso~="ZAF" & iso~="MUS" & iso~="MMR" & iso~="KAZ" & dup<2, legend(label(1 "WGI First PC")) xsc(r(.5 .9)) xtitle("Avg Log Distance") title("B. Established Democracies (Polity>9)") ylabel(-5 0 5)
*/

*******************************************
* Table 8: Basic Results (WGI Governance) *
*******************************************
* Generating standardized variables
egen zavglogdist90_adj=std(avglogdist90_adj)
egen zkkm_PolStab_9612=std(kkm_PolStab_9612)
gen lavgdays= log(avgdays)
egen zlavgdaysletter=std(lavgdays)
egen zkkm_pcfirst_9612=std(kkm_pcfirst_9612)

cap drop zavglogdist90_adjXautocracy
gen zavglogdist90_adjXautocracy=zavglogdist90_adj*autocracy

save workfile, replace

* Full sample
use workfile, clear
keep if iso~="ZAF" & iso~="MUS"  & polity~=. & elf_eth~=. & maj~=. & pres~=.  & iso~="MMR" & iso~="KAZ" & dup<2
reg zkkm_pcfirst_9612 zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS  reg_* leg_* if iso~="ZAF" & iso~="MUS"  & polity~=. & elf_eth~=. & maj~=. & pres~=.  & iso~="MMR" & iso~="KAZ" & dup<2
*psacalc zavglogdist90_adj set, delta(1)
local bound = r(output)
*psacalc zavglogdist90_adj delta, beta(0)
reg zkkm_pcfirst_9612 zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS  reg_* leg_* if iso~="ZAF" & iso~="MUS"  & polity~=. & elf_eth~=. & maj~=. & pres~=.  & iso~="MMR" & iso~="KAZ" & dup<2, robust
*outreg2 zavglogdist90_adj using "$DropboxFolder/TablesAEJApp_8.xml", adds(Oster's bound:, `bound') bracket nocons title("Isolated Capital Cities and Misgovernance") bdec(4) tex replace 
use workfile, clear
keep if iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2 & polity~=.
reg zkkm_pcfirst_9612 zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2 & polity~=.
*psacalc zavglogdist90_adj set, delta(1)
local bound = r(output)
*psacalc zavglogdist90_adj delta, beta(0)
eststo:reg zkkm_pcfirst_9612 zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2 & polity~=., robust
*outreg2 zavglogdist90_adj using "$DropboxFolder/TablesAEJApp_8.xml", adds(Oster's bound:, `bound') bracket nocons title("Isolated Capital Cities and Misgovernance") bdec(4) excel append
*** EDITED by Donna
estout using "../results/table2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

* Split sample
* Autocracies
use workfile, clear
keep if autocracy==1 & elf_eth~=. & maj~=. & pres~=.  & iso~="MMR" & iso~="KAZ" & dup<2
reg zkkm_pcfirst_9612 zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS reg_* leg_* if autocracy==1 & elf_eth~=. & maj~=. & pres~=.  & iso~="MMR" & iso~="KAZ" & dup<2
*psacalc zavglogdist90_adj set, delta(1)
local bound = r(output)
reg zkkm_pcfirst_9612 zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS reg_* leg_* if autocracy==1 & elf_eth~=. & maj~=. & pres~=.  & iso~="MMR" & iso~="KAZ" & dup<2, robust 
*outreg2 zavglogdist90_adj using "$DropboxFolder/TablesAEJApp_8.xml", adds(Oster's bound:, `bound') bracket nocons title("Isolated Capital Cities and Misgovernance: Autocracies vs Democracies") bdec(4) excel append
use workfile, clear
keep if autocracy==1 & iso~="MMR" & iso~="KAZ" & dup<2
reg zkkm_pcfirst_9612 zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if autocracy==1 & iso~="MMR" & iso~="KAZ" & dup<2
*psacalc zavglogdist90_adj set, delta(1)
local bound = r(output)
reg zkkm_pcfirst_9612 zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if autocracy==1 & iso~="MMR" & iso~="KAZ" & dup<2, robust 
*outreg2 zavglogdist90_adj using "$DropboxFolder/TablesAEJApp_8.xml", adds(Oster's bound:, `bound') bracket nocons title("Isolated Capital Cities and Misgovernance: Autocracies vs Democracies") bdec(4) excel append
* Established democracies
use workfile, clear
reg zkkm_pcfirst_9612 zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS reg_* leg_* if polity>9 & polity~=. & iso~="ZAF" & iso~="MUS" & elf_eth~=. & maj~=. & pres~=.  & iso~="MMR" & iso~="KAZ" & dup<2, robust 
*outreg2 zavglogdist90_adj using "$DropboxFolder/TablesAEJApp_8.xml", adds(Oster's bound:, `bound') bracket nocons title("Isolated Capital Cities and Misgovernance: Autocracies vs Democracies") bdec(4) excel append
reg zkkm_pcfirst_9612 zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if polity>9 & polity~=. & iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2, robust 
*outreg2 zavglogdist90_adj using "$DropboxFolder/TablesAEJApp_8.xml", adds(Oster's bound:, `bound') bracket nocons title("Isolated Capital Cities and Misgovernance: Autocracies vs Democracies") bdec(4) excel append

* Testing for difference of coefficients
use workfile, clear
reg zkkm_pcfirst_9612 zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if autocracy==1 & iso~="MMR" & iso~="KAZ" & dup<2
estimates store autoc
reg zkkm_pcfirst_9612 zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if polity>9 & polity~=. & iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2 
estimates store democ
suest autoc democ, vce(robust)
test [autoc_mean=democ_mean]: zavglogdist90_adj
estimates drop autoc
estimates drop democ

*** EDIT BY Donna
/*
* Interaction
use workfile, clear
keep if polity~=. & iso~="ZAF" & iso~="MUS" & elf_eth~=. & maj~=. & pres~=.  & iso~="MMR" & iso~="KAZ" & dup<2
reg zkkm_pcfirst_9612 zavglogdist90_adj zavglogdist90_adjXautocracy autocracy lgdppc lpop SP_URB_TOTL_IN_ZS reg_* leg_* if polity~=. & iso~="ZAF" & iso~="MUS" & elf_eth~=. & maj~=. & pres~=.  & iso~="MMR" & iso~="KAZ" & dup<2
psacalc zavglogdist90_adjXautocracy set, delta(1)
local bound = r(output)
reg zkkm_pcfirst_9612 zavglogdist90_adj zavglogdist90_adjXautocracy autocracy lgdppc lpop SP_URB_TOTL_IN_ZS reg_* leg_* if polity~=. & iso~="ZAF" & iso~="MUS" & elf_eth~=. & maj~=. & pres~=.  & iso~="MMR" & iso~="KAZ" & dup<2, robust 
*outreg2 zavglogdist90_adj* using "$DropboxFolder/TablesAEJApp_8.xml", adds(Oster's bound:, `bound') bracket nocons title("Isolated Capital Cities and Misgovernance") bdec(4) excel append
use workfile, clear
keep if polity~=. & iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2
reg zkkm_pcfirst_9612 zavglogdist90_adj zavglogdist90_adjXautocracy autocracy lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if polity~=. & iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2
psacalc zavglogdist90_adjXautocracy set, delta(1)
local bound = r(output)
reg zkkm_pcfirst_9612 zavglogdist90_adj zavglogdist90_adjXautocracy autocracy lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if polity~=. & iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2, robust 
*outreg2 zavglogdist90_adj* using "$DropboxFolder/TablesAEJApp_8.xml", adds(Oster's bound:, `bound') bracket nocons title("Isolated Capital Cities and Misgovernance") bdec(4) excel append
*/

*****
* Include semi-parametric plot for WGI PCI here (Figure 4)
*****

*** EDIT BY Donna

/*

***********************
* Table 9: Robustness *
***********************
* Generating relevant variables
use workfile, clear
egen zavglogdist90_unadj=std(avglogdist90_unadj)
gen zavglogdist90_unadjXautocracy=zavglogdist90_unadj*autocracy
egen zlgapdistance90=std(lgapdistance90)
gen zlgapXautocracy=zlgapdistance90*autocracy
egen zcap_prim90=std(cap_prim90)
pctile median=polity if iso~="ZAF" & iso~="MUS" & iso~="MMR" & iso~="KAZ" & dup<2
egen median_polity = min(median)
drop median
gen autocracy2=1 if polity<=median_polity
replace autocracy2=0 if polity>median_polity & polity!=.
drop median*
gen zcap_prim90Xautocracy2=zcap_prim90*autocracy2
egen zPR_rescaled=std(PR_rescaled)
egen zother_avglogdist90_adj=std(other_avglogdist90_adj)
gen zother_avglogdist90_adjXaut=zother_avglogdist90_adj*autocracy
save workfile, replace

* Unadjusted measure
use workfile, clear
keep if autocracy==1 & iso~="MMR" & iso~="KAZ" & dup<2
reg zkkm_pcfirst_9612 zavglogdist90_unadj lgdppc lpop SP_URB_TOTL_IN_ZS llandarea maj pres  elf_eth  reg_* leg_* if autocracy==1 & iso~="MMR" & iso~="KAZ" & dup<2
psacalc zavglogdist90_unadj set, delta(1)
local bound = r(output)
reg zkkm_pcfirst_9612 zavglogdist90_unadj lgdppc lpop SP_URB_TOTL_IN_ZS llandarea maj pres  elf_eth  reg_* leg_* if autocracy==1 & iso~="MMR" & iso~="KAZ" & dup<2, robust 
*outreg2 zavglogdist90_unadj using "$DropboxFolder/TablesAEJApp_9.xml", adds(Oster's bound:, `bound') bracket nocons title("Isolated Capital Cities and Misgovernance: Robustness") bdec(4) excel replace
use workfile, clear
reg zkkm_pcfirst_9612 zavglogdist90_unadj lgdppc lpop SP_URB_TOTL_IN_ZS llandarea maj pres  elf_eth  reg_* leg_* if polity>9 & polity~=. & iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2, robust 
*outreg2 zavglogdist90_unadj using "$DropboxFolder/TablesAEJApp_9.xml", bracket nocons title("Isolated Capital Cities and Misgovernance: Robustness") bdec(4) excel append

*Distance between capital and concentration-maximizing location
use workfile, clear
keep if autocracy==1 & iso~="MMR" & iso~="KAZ" & dup<2
reg zkkm_pcfirst_9612 zlgapdistance90 lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if autocracy==1 & iso~="MMR" & iso~="KAZ" & dup<2
psacalc zlgapdistance90 set, delta(1)
local bound = r(output)
reg zkkm_pcfirst_9612 zlgapdistance90 lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if autocracy==1 & iso~="MMR" & iso~="KAZ" & dup<2, robust 
*outreg2 zlgapdistance90 using "$DropboxFolder/TablesAEJApp_9.xml", adds(Oster's bound:, `bound') bracket nocons title("Isolated Capital Cities and Misgovernance: Robustness") bdec(4) excel append
use workfile, clear
reg zkkm_pcfirst_9612 zlgapdistance90 lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if polity>9 & polity~=. & iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2, robust 
*outreg2 zlgapdistance90 using "$DropboxFolder/TablesAEJApp_9.xml", bracket nocons title("Isolated Capital Cities and Misgovernance: Robustness") bdec(4) excel append

*Capital Primacy (Threshold at median to get decent autocracy sample size)
use workfile, clear
keep if autocracy2==1 & iso~="MMR" & iso~="KAZ" & dup<2
reg zkkm_pcfirst_9612 zcap_prim90 lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if autocracy2==1 & iso~="MMR" & iso~="KAZ" & dup<2
psacalc zcap_prim90 set, delta(1)
local bound = r(output)
reg zkkm_pcfirst_9612 zcap_prim90 lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if autocracy2==1 & iso~="MMR" & iso~="KAZ" & dup<2, robust 
*outreg2 zcap_prim90 using "$DropboxFolder/TablesAEJApp_9.xml", adds(Oster's bound:, `bound') bracket nocons title("Isolated Capital Cities and Misgovernance: Robustness") bdec(4) excel append
use workfile, clear
reg zkkm_pcfirst_9612 zcap_prim90 lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if polity>9 & polity~=. & iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2, robust 
*outreg2 zcap_prim90 using "$DropboxFolder/TablesAEJApp_9.xml", bracket nocons title("Isolated Capital Cities and Misgovernance: Robustness") bdec(4) excel append

*Freedom House
use workfile, clear
keep if autocracy==1 & iso~="MMR" & iso~="KAZ" & dup<2
reg zPR zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if autocracy==1 & iso~="MMR" & iso~="KAZ" & dup<2
psacalc zavglogdist90_adj set, delta(1)
local bound = r(output)
reg zPR zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if autocracy==1 & iso~="MMR" & iso~="KAZ" & dup<2, robust 
*outreg2 zavglogdist90_adj using "$DropboxFolder/TablesAEJApp_9.xml", adds(Oster's bound:, `bound') bracket nocons title("Isolated Capital Cities and Misgovernance: Robustness") bdec(4) excel append
use workfile, clear
reg zPR zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if polity>9 & polity~=. & iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2, robust 
*outreg2 zavglogdist90_adj using "$DropboxFolder/TablesAEJApp_9.xml", bracket nocons title("Isolated Capital Cities and Misgovernance: Robustness") bdec(4) excel append

*Largest City
use workfile, clear
keep if polity~=. & iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2
reg zkkm_pcfirst_9612 zavglogdist90_adj* zother_avglogdist90_adj* autocracy lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if polity~=. & iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2
psacalc zavglogdist90_adjX set, delta(1)
local bound = r(output)
reg zkkm_pcfirst_9612 zavglogdist90_adj* zother_avglogdist90_adj* autocracy lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if polity~=. & iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2, robust 
*outreg2 zavglogdist90_adj* zother_avglogdist90_adj* using "$DropboxFolder/TablesAEJApp_9.xml", adds(Oster's bound:, `bound') bracket nocons title("Isolated Capital Cities and Misgovernance: Robustness") bdec(4) excel append


*****
* Include semi-parametric plots for PolStab and Log Avg Days here (Figure 5)
*****



************************************************************************************************
* Table 11: Polity - Constraints on Executive & Political Competition vs Executive Recruitment *
************************************************************************************************
** Autocracies **

use workfile, clear

egen zpolity=std(polity)
egen zxconst19752010=std(xconst19752010)
egen zparcomp19752010=std(parcomp19752010)
egen zxrcomp19752010=std(xrcomp19752010)
egen zxropen19752010=std(xropen19752010)

save workfile, replace

*Use median because there is very little variation in Polity components in the bottom tercile
* Polity
use workfile, clear
keep if autocracy2==1 & iso~="MMR" & iso~="KAZ" & dup<2
reg zpolity zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if autocracy2==1 & iso~="MMR" & iso~="KAZ" & dup<2
psacalc zavglogdist90_adj set, delta(1)
local bound = r(output)
reg zpolity zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if autocracy2==1 & iso~="MMR" & iso~="KAZ" & dup<2, robust 
*outreg2 zavglogdist90_adj using "$DropboxFolder/TablesAEJApp_11.xml", adds(Oster's bound:, `bound') bracket nocons title("Isolated Capital Cities and Misgovernance: Autocracies vs Democracies (Freedom House)") bdec(4) excel replace

* Constraints on Executive
use workfile, clear
keep if autocracy2==1 & iso~="MMR" & iso~="KAZ" & dup<2
reg zxconst19752010 zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if autocracy2==1 & iso~="MMR" & iso~="KAZ" & dup<2
psacalc zavglogdist90_adj set, delta(1)
local bound = r(output)
reg zxconst19752010 zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if autocracy2==1 & iso~="MMR" & iso~="KAZ" & dup<2, robust 
*outreg2 zavglogdist90_adj using "$DropboxFolder/TablesAEJApp_11.xml", adds(Oster's bound:, `bound') bracket nocons title("Isolated Capital Cities and Misgovernance: Autocracies vs Democracies (Freedom House)") bdec(4) excel append

* Political Competition
use workfile, clear
keep if autocracy2==1 & iso~="MMR" & iso~="KAZ" & dup<2
reg zparcomp19752010 zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if autocracy2==1 & iso~="MMR" & iso~="KAZ" & dup<2
psacalc zavglogdist90_adj set, delta(1)
local bound = r(output)
reg zparcomp19752010 zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if autocracy2==1 & iso~="MMR" & iso~="KAZ" & dup<2, robust 
*outreg2 zavglogdist90_adj using "$DropboxFolder/TablesAEJApp_11.xml", adds(Oster's bound:, `bound') bracket nocons title("Isolated Capital Cities and Misgovernance: Autocracies vs Democracies (Freedom House)") bdec(4) excel append

* Executive Recruitment (placebo)
use workfile, clear
keep if autocracy2==1 & iso~="MMR" & iso~="KAZ" & dup<2
reg zxrcomp19752010 zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if autocracy2==1 & iso~="MMR" & iso~="KAZ" & dup<2
psacalc zavglogdist90_adj set, delta(1)
local bound = r(output)
reg zxrcomp19752010 zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if autocracy2==1 & iso~="MMR" & iso~="KAZ" & dup<2, robust 
*outreg2 zavglogdist90_adj using "$DropboxFolder/TablesAEJApp_11.xml", adds(Oster's bound:, `bound') bracket nocons title("Isolated Capital Cities and Misgovernance: Autocracies vs Democracies (Freedom House)") bdec(4) excel append
use workfile, clear
keep if autocracy2==1 & iso~="MMR" & iso~="KAZ" & dup<2
reg zxropen19752010 zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if autocracy2==1 & iso~="MMR" & iso~="KAZ" & dup<2
psacalc zavglogdist90_adj set, delta(1)
local bound = r(output)
reg zxropen19752010 zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  reg_* leg_* if autocracy2==1 & iso~="MMR" & iso~="KAZ" & dup<2, robust 
*outreg2 zavglogdist90_adj using "$DropboxFolder/TablesAEJApp_11.xml", adds(Oster's bound:, `bound') bracket nocons title("Isolated Capital Cities and Misgovernance: Autocracies vs Democracies (Freedom House)") bdec(4) excel append



***********************************************
* Table 12: Capital Premium + Military Budget *
***********************************************
use workfile, clear
egen zgdppc_capratio=std(gdppc_capratio)
egen zlmilexpgovexp=std(lmilexpgovexp)

* Polity averaged between 1975-2000: use it because we need to set the threshold at the median to get a decent sample, and the median of Polity in the Capital Ratio subsample is way too high (7.5) to actually characterize autocracies
*scatter zgdppc_capratio zavglogdist90_adj if polity2_19752000<=5 & iso~="ZAF" & iso~="MUS" & iso~="MMR" & iso~="KAZ" & dup<2, mlabel(iso) || lfit zgdppc_capratio zavglogdist90_adj if polity2_19752000<=5 & iso~="ZAF" & iso~="MUS" & iso~="MMR" & iso~="KAZ" & dup<2
*scatter zgdppc_capratio zavglogdist90_adj if polity2_19752000>5 & polity2_19752000~=. & iso~="ZAF" & iso~="MUS" & iso~="MMR" & iso~="KAZ" & dup<2, mlabel(iso) || lfit zgdppc_capratio zavglogdist90_adj if polity2_19752000>5 & polity2_19752000~=. & iso~="ZAF" & iso~="MUS" & iso~="MMR" & iso~="KAZ" & dup<2

* Generating Autocracy dummy and interaction
pctile median=polity2_19752000 if iso~="ZAF" & iso~="MUS" & iso~="MMR" & iso~="KAZ" & dup<2 & gdppc_capratio~=.
egen median_polity2 = min(median)
gen autocracy3=1 if polity2<=median_polity2
replace autocracy3=0 if polity2>median_polity2 & polity2_19752000!=.
drop median*
gen zavglogdist90_adjXautocracy3= zavglogdist90_adj*autocracy3
save workfile, replace

* Capital Premium
use workfile, clear
* Autocracy
keep if autocracy3==1 & iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2
reg zgdppc_capratio zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth if autocracy3==1 & iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2
psacalc zavglogdist90_adj set, delta(1)
local bound = r(output)
reg zgdppc_capratio zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth if autocracy3==1 & iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2, robust
*outreg2 zavglogdist90_adj  using "$DropboxFolder/TablesAEJApp_12.xml", adds(Oster's bound:, `bound') bracket nocons title("Isolated Capital Cities and Capital Premium") bdec(4) excel replace
* Democracy
use workfile, clear
reg zgdppc_capratio zavglogdist90_adj lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth if autocracy3==0 & iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2, robust
*outreg2 zavglogdist90_adj zavglogdist90_adjXautocracy3 using "$DropboxFolder/TablesAEJApp_12.xml", bracket nocons title("Isolated Capital Cities and Capital Premium") bdec(4) excel append
* Interaction
use workfile, clear
keep if iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2
reg zgdppc_capratio zavglogdist90_adj zavglogdist90_adjXautocracy3 autocracy3  lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth if iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2
psacalc zavglogdist90_adjXautocracy3 set, delta(1)
local bound = r(output)
reg zgdppc_capratio zavglogdist90_adj zavglogdist90_adjXautocracy3 autocracy3  lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth if iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2, robust
*outreg2 zavglogdist90_adj zavglogdist90_adjXautocracy3 using "$DropboxFolder/TablesAEJApp_12.xml", adds(Oster's bound:, `bound') bracket nocons title("Isolated Capital Cities and Capital Premium") bdec(4) excel append

* Military Spending
* Autocracy
use workfile, clear
keep if autocracy3==1 & iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2
reg zlmilexpgovexp zavglogdist90_adj war19752007 lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  if autocracy3==1 & iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2
psacalc zavglogdist90_adj set, delta(1)
local bound = r(output)
reg zlmilexpgovexp zavglogdist90_adj war19752007 lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  if autocracy3==1 & iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2, robust
*outreg2 zavglogdist90_adj war19752007 using "$DropboxFolder/TablesAEJApp_12.xml", adds(Oster's bound:, `bound') bracket nocons title("Isolated Capital Cities and Capital Premium") bdec(4) excel append
* Democracy
use workfile, clear
reg zlmilexpgovexp zavglogdist90_adj war19752007 lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth  if autocracy3==0 & iso~="ZAF" & iso~="MUS"& iso~="MMR" & iso~="KAZ" & dup<2, robust
*outreg2 zavglogdist90_adj war19752007 using "$DropboxFolder/TablesAEJApp_12.xml", bracket nocons title("Isolated Capital Cities and Capital Premium") bdec(4) excel append
* Interaction
use workfile, clear
keep if iso~="ZAF" & iso~="MUS" & iso~="MMR" & iso~="KAZ" & dup<2
reg zlmilexpgovexp zavglogdist90_adj zavglogdist90_adjXautocracy3 autocracy3 war19752007 lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth if iso~="ZAF" & iso~="MUS" & iso~="MMR" & iso~="KAZ" & dup<2
psacalc zavglogdist90_adjXautocracy3 set, delta(1)
local bound = r(output)
reg zlmilexpgovexp zavglogdist90_adj zavglogdist90_adjXautocracy3 autocracy3 war19752007 lgdppc lpop SP_URB_TOTL_IN_ZS maj pres  elf_eth if iso~="ZAF" & iso~="MUS" & iso~="MMR" & iso~="KAZ" & dup<2, robust
*outreg2 zavglogdist90_adj zavglogdist90_adjXautocracy3 war19752007 using "$DropboxFolder/TablesAEJApp_12.xml", adds(Oster's bound:, `bound') bracket nocons title("Isolated Capital Cities and Capital Premium") bdec(4) excel append
*/