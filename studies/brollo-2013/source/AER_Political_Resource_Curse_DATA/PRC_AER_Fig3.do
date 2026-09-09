
***AER FIGURE 3
clear all
*X*X*X*
use AER_largesample,clear
preserve
gen group=-3500 if popnorm>=-3500&popnorm<-3250
forvalues i=1(1)30 {
replace group=-3500+(`i'*250) if popnorm>=-3500+(`i'*250) & popnorm<-3250+(`i'*250)
}
egen popnorm_mean2=mean(popnorm), by(group)
egen opp_college_mean2=mean(opp_college), by(group)

reg opp_college treatnorm popnorm popnorm_2 popnorm_3,robust cluster(id_city)
predict yhat_1
predict SE_1, stdp
gen low_1 = yhat_1 - 1.96*(SE_1)
gen high_1 = yhat_1 + 1.96*(SE_1)

twoway (scatter opp_college_mean2 popnorm_mean2 if popnorm<3392) /*
*/ (line yhat_1 low_1 high_1 popnorm if popnorm<0, pstyle(p p3 p3) sort)/* 
*/ (line yhat_1 low_1 high_1 popnorm if popnorm>0&popnorm<3392, pstyle(p p3 p3) sort) , /* 
*/ xtitle(Population) ytitle(College) legend(off) xline(0)
drop yhat_* low_* high_* SE_*
graph save oppgraph2.gph,replace
restore

preserve
gen group=-3500 if popnorm>=-3500&popnorm<-3250
forvalues i=1(1)30 {
replace group=-3500+(`i'*250) if popnorm>=-3500+(`i'*250) & popnorm<-3250+(`i'*250)
}
egen popnorm_mean2=mean(popnorm), by(group)
egen opp_yschool_mean2=mean(opp_yschool), by(group)

reg opp_yschool treatnorm popnorm popnorm_2 popnorm_3,robust cluster(id_city)
predict yhat_1
predict SE_1, stdp
gen low_1 = yhat_1 - 1.96*(SE_1)
gen high_1 = yhat_1 + 1.96*(SE_1)

twoway (scatter opp_yschool_mean2 popnorm_mean2 if popnorm<3392) /*
*/ (line yhat_1 low_1 high_1 popnorm if popnorm<0, pstyle(p p3 p3) sort)/* 
*/ (line yhat_1 low_1 high_1 popnorm if popnorm>0&popnorm<3392, pstyle(p p3 p3) sort) , /* 
*/ xtitle(Population) ytitle(Years of schooling) legend(off) xline(0)
drop yhat_* low_* high_* SE_*
graph save oppgraph3.gph,replace
restore

preserve
gen group=-3500 if popnorm>=-3500&popnorm<-3250
forvalues i=1(1)30 {
replace group=-3500+(`i'*250) if popnorm>=-3500+(`i'*250) & popnorm<-3250+(`i'*250)
}
egen popnorm_mean2=mean(popnorm), by(group)
egen reele_inc_mean2=mean(reele_inc), by(group)

reg reele_inc treatnorm popnorm popnorm_2 popnorm_3,robust cluster(id_city)
predict yhat_1
predict SE_1, stdp
gen low_1 = yhat_1 - 1.96*(SE_1)
gen high_1 = yhat_1 + 1.96*(SE_1)

twoway (scatter reele_inc_mean2 popnorm_mean2 if popnorm<3392) /*
*/ (line yhat_1 low_1 high_1 popnorm if popnorm<0, pstyle(p p3 p3) sort)/* 
*/ (line yhat_1 low_1 high_1 popnorm if popnorm>0&popnorm<3392, pstyle(p p3 p3) sort) , /* 
*/ xtitle(Population) ytitle(Incumbent reelection) legend(off) xline(0)
drop yhat_* low_* high_* SE_*
graph save oppgraph5.gph,replace
restore

graph combine oppgraph2.gph oppgraph3.gph oppgraph5.gph
graph save opponentsgraph,replace
graph export opponentsgraph.eps,replace

