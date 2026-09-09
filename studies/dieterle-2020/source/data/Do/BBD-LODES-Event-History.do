/*Generate the following:
1. Summary Statistics for Table 4
2. Figure 3
3. Figure 4
*/
use BBD-lodes.dta if d2b<=5, clear

egen st_by_bound=group(st_bound st_fips)

*Table 4
sum work_neigh_frac work_neigh work_total if hiui==1 & year==2008
sum work_neigh_frac work_neigh work_total if loui==1 & year==2008



*Figure 3
foreach y of varlist work_neigh_frac work_neigh work_total{

reg `y' ibn.year#ibn.hiui if hilosamp==1, nocons cluster(st_by_bound)
test 2010.year#1.hiui-2010.year#0.hiui=2011.year#1.hiui-2011.year#0.hiui=2008.year#1.hiui-2008.year#0.hiui
capture: mat drop b se bdiff sediff

forvalues t=2004/2011{
forvalues h=0/1{
lincom `t'.year#`h'.hiui-2008.year#`h'.hiui
mat b=nullmat(b)\r(estimate)
mat se=nullmat(se)\r(se)
}
}

forvalues t=2004/2011{
lincom `t'.year#1.hiui-2008.year#1.hiui-(`t'.year#0.hiui-2008.year#0.hiui)
mat bdiff=nullmat(bdiff)\r(estimate)
mat sediff=nullmat(sediff)\r(se)
}


mata: b=st_matrix("b")
mata: se=st_matrix("se")
mata: bdiff=st_matrix("bdiff")
mata: sediff=st_matrix("sediff")


preserve
clear
getmata b se
gen year=2003+ceil(_n/2)
gen hi=_n/2==round(_n/2)

line b year if hi==0 || line b year if hi==1, name(`y', replace)

restore

preserve
clear
getmata bdiff sediff
gen year=2003+_n

serrbar bdiff sediff year, scale(1.96) addplot(line bdiff year || line bdiff year) name(`y'_diff, replace)

restore

}


*Figure 4
use BBD-lodes.dta if d2b<=50 & (year==2008 | year==2007 | year==2011 | year==2010) , clear

bysort h_geocode: egen mean0708=mean(work_neigh_frac) if year==2008 | year==2007 
bysort h_geocode: egen mean1011=mean(work_neigh_frac) if year==2010 | year==2011 

keep h_geocode mean0708 mean1011 d2b hiui loui
duplicates drop
drop if mean0708==. & mean1011==.
gen time=1 if mean0708<.
replace time=2 if mean1011<.

xtset h_geocode time

gen diff=mean1011-l.mean0708

gen d2b_rd=d2b*hiui-d2b*(loui)

twoway lpolyci diff d2b_rd if hiui==1 || lpolyci diff d2b_rd if loui==1










