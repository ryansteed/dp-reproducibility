
log using region_level_analysis, replace
clear
use region_data 
//////////////////////////////////////
//// run regressoins//////////////////
//////////////////////////////////////
eststo: areg Nins logPop  , a(state) rob cl(state)
est store a1 

eststo: areg Nins logPop landArea Urban Urbsq MedianIncome  Inc_25k_100k  GAF  relold smallfirm hosps, a(state) rob cl(state)
est store a2

eststo: areg Price logPop, a(state) rob cl(state)
est store b1

eststo: areg Price logPop landArea Urban Urbsq ded MedianIncome  Inc_25k_100k  GAF  relold smallfirm hosps, a(state) rob cl(state)
est store b2
///////////////////////////////////////////
/////////// display regression output ////////////
///////////////////////////////////////////

*** EDIT by Donna
* est tab a* ,   se stats(N r2_a) label title("///// N insurers  /////")
* est tab b* ,   se stats(N r2_a) label title("///// Price  /////")
///////////////////////////////////////////////

estout using "../../results/region.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

log close
