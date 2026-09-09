***AER FIGURE 2
clear all
*X*X*X*
use AER_smallsample,clear

preserve

gen group=-3500 if popnorm>=-3500&popnorm<-3250
forvalues i=1(1)30 {
replace group=-3500+(`i'*250) if popnorm>=-3500+(`i'*250) & popnorm<-3250+(`i'*250)
}
egen popnorm_mean2=mean(popnorm), by(group)
egen broad_mean2=mean(broad), by(group)
egen narrow_mean2=mean(narrow), by(group)
egen fraction_broad_mean2=mean(fraction_broad), by(group)
egen fraction_narrow_mean2=mean(fraction_narrow), by(group)

reg broad treatnorm popnorm popnorm_2 popnorm_3,robust cluster(id_city)
predict yhat_1
predict SE_1, stdp
gen low_1 = yhat_1 - 1.96*(SE_1)
gen high_1 = yhat_1 + 1.96*(SE_1)

twoway (scatter broad_mean2 popnorm_mean2 if popnorm<3392) /*
*/ (line yhat_1 low_1 high_1 popnorm if popnorm<0, pstyle(p p3 p3) sort)/* 
*/ (line yhat_1 low_1 high_1 popnorm if popnorm>0&popnorm<3392, pstyle(p p3 p3) sort) , /* 
*/ xtitle(Population) ytitle(Broad corruption) legend(off) xline(0)
drop yhat_* low_* high_* SE_*
graph save corruptiongraph1.gph,replace

restore

preserve

gen group=-3500 if popnorm>=-3500&popnorm<-3250
forvalues i=1(1)30 {
replace group=-3500+(`i'*250) if popnorm>=-3500+(`i'*250) & popnorm<-3250+(`i'*250)
}
egen popnorm_mean2=mean(popnorm), by(group)
egen broad_mean2=mean(broad), by(group)
egen narrow_mean2=mean(narrow), by(group)
egen fraction_broad_mean2=mean(fraction_broad ), by(group)
egen fraction_narrow_mean2=mean(fraction_narrow), by(group)

reg narrow treatnorm popnorm popnorm_2 popnorm_3,robust cluster(id_city)
predict yhat_1
predict SE_1, stdp
gen low_1 = yhat_1 - 1.96*(SE_1)
gen high_1 = yhat_1 + 1.96*(SE_1)

twoway (scatter narrow_mean2 popnorm_mean2 if popnorm<3392) /*
*/ (line yhat_1 low_1 high_1 popnorm if popnorm<0, pstyle(p p3 p3) sort)/* 
*/ (line yhat_1 low_1 high_1 popnorm if popnorm>0&popnorm<3392, pstyle(p p3 p3) sort) , /* 
*/ xtitle(Population) ytitle(Narrow corruption) legend(off) xline(0)
drop yhat_* low_* high_* SE_*
graph save corruptiongraph2.gph,replace

restore

preserve

gen group=-3500 if popnorm>=-3500&popnorm<-3250
forvalues i=1(1)30 {
replace group=-3500+(`i'*250) if popnorm>=-3500+(`i'*250) & popnorm<-3250+(`i'*250)
}
egen popnorm_mean2=mean(popnorm), by(group)
egen broad_mean2=mean(broad), by(group)
egen narrow_mean2=mean(narrow), by(group)
egen fraction_broad_mean2=mean(fraction_broad ), by(group)
egen fraction_narrow_mean2=mean(fraction_narrow), by(group)

reg fraction_broad treatnorm popnorm popnorm_2 popnorm_3,robust cluster(id_city)
predict yhat_1
predict SE_1, stdp
gen low_1 = yhat_1 - 1.96*(SE_1)
gen high_1 = yhat_1 + 1.96*(SE_1)

twoway (scatter fraction_broad_mean2 popnorm_mean2 if popnorm<3392) /*
*/ (line yhat_1 low_1 high_1 popnorm if popnorm<0, pstyle(p p3 p3) sort)/* 
*/ (line yhat_1 low_1 high_1 popnorm if popnorm>0&popnorm<3392, pstyle(p p3 p3) sort) , /* 
*/ xtitle(Population) ytitle(Broad fraction of the amount) legend(off) xline(0)
drop yhat_* low_* high_* SE_*
graph save corruptiongraph3.gph,replace

restore

preserve

gen group=-3500 if popnorm>=-3500&popnorm<-3250
forvalues i=1(1)30 {
replace group=-3500+(`i'*250) if popnorm>=-3500+(`i'*250) & popnorm<-3250+(`i'*250)
}
egen popnorm_mean2=mean(popnorm), by(group)
egen broad_mean2=mean(broad), by(group)
egen narrow_mean2=mean(narrow), by(group)
egen fraction_broad_mean2=mean(fraction_broad ), by(group)
egen fraction_narrow_mean2=mean(fraction_narrow), by(group)

reg fraction_narrow treatnorm popnorm popnorm_2 popnorm_3,robust cluster(id_city)
predict yhat_1
predict SE_1, stdp
gen low_1 = yhat_1 - 1.96*(SE_1)
gen high_1 = yhat_1 + 1.96*(SE_1)

twoway (scatter fraction_narrow_mean2 popnorm_mean2 if popnorm<3392) /*
*/ (line yhat_1 low_1 high_1 popnorm if popnorm<0, pstyle(p p3 p3) sort)/* 
*/ (line yhat_1 low_1 high_1 popnorm if popnorm>0&popnorm<3392, pstyle(p p3 p3) sort) , /* 
*/ xtitle(Population) ytitle(Narrow fraction of the amount) legend(off) xline(0)
drop yhat_* low_* high_* SE_*
graph save corruptiongraph4.gph,replace

restore

graph combine corruptiongraph1.gph corruptiongraph2.gph corruptiongraph3.gph corruptiongraph4.gph
graph save corruptiongraph,replace
graph export corruptiongraph.eps,replace

