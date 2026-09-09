
***AER TABLE 2
clear all
*X*X*X*
*left panel for "small sample"
use AER_smallsample,clear
tabstat fpm fpm_hat , by(pop_cat) stat(mean count) format(%9.2f)
latabstat fpm fpm_hat , by(pop_cat) f(%9.2fc) tf(tab_desc) stat(mean) replace

*X*X*X*
*right panel for "large sample"
use AER_largesample,clear
tabstat fpm fpm_hat , by(pop_cat) stat(mean count) format(%9.2f)
latabstat fpm fpm_hat , by(pop_cat) f(%9.2fc) tf(tab_desc) stat(mean) replace

