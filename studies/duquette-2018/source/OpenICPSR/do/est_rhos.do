/****************
* for text of the paper, calculate correlation
* coefficients of plotted time series
****************/

use "$data/ts_chart", clear
pwcorr gr0010 incsh_t01, sig
pwcorr gr0010 _1mtr_t01, sig
pwcorr incsh_t01 _1mtr_t01, sig
pwcorr gr0010 incsh_t01 _1mtr_t01, sig

