***AER TABLE 3
clear all
*X*X*X*
*left panel for "small sample"
use AER_smallsample,clear
tabstat broad narrow fraction_broad fraction_narrow , by(pop_cat) stat(mean count) format(%9.2f)
latabstat broad narrow fraction_broad fraction_narrow , by(pop_cat) f(%9.2fc) tf(tab_desc) stat(mean) replace


*X*X*X*
*right panel for "large sample"
use AER_largesample,clear
tabstat opp_college opp_yschool reele_inc, by(pop_cat) stat(mean count) format(%9.2f)latabstat opp_college opp_yschool reele_inc, by(pop_cat) f(%9.2fc) tf(tab_desc1) replace

