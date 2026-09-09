
use state state_n monthly u_realtime using crk_ui_macro_dataset.dta, clear

xtset state_n monthly

gen u_3moavg=(l.u_realtime+l2.u_realtime+l3.u_realtime)/3

gen qtr=qofd(dofm(monthly))

forvalues p=4/5{
gen temp`p'=u_3moavg>`p'
bysort state qtr: egen trig`p'=mean(temp`p')
drop temp*
}
keep state state_n qtr trig4 trig5

duplicates drop
rename state st_name

replace st_name=subinstr(st_name, " ", "",.)

cd "C:\Research\RD Measurement Error\Geo Examples\UI Benefits\Cleaned Data\" 

merge 1:m st_name qtr using RD-State-by-border-Treatment-Status.dta, nogen keep(match using)
keep if treat==. & ui_avail_qtr_avg==26

forvalues p=4/5{
bysort st_bound qtr: egen tempmax=max(trig`p')
bysort st_bound qtr: egen tempmin=min(trig`p')
gen tempdiff=tempmax-tempmin
gen treat_p`p'=.
replace treat_p`p'=1 if trig`p'==tempmax & tempdiff>0
replace treat_p`p'=0 if trig`p'==tempmin & tempdiff>0
drop temp*
}

keep st_fips st_bound qtr treat_p4 treat_p5

save placebo-trigger-treat.dta, replace
