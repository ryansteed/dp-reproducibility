set logtype text
log using logs/apptable1.log, replace
use data/private, clear

* Appendix Table I:  construction of the instrument

gen samp=$samp
drop if ~samp
gsort - inst_sca
gen rankinst=_n

gsort -shr_mexca
gen rankmex=_n

list rankmex shr_mexca dname msaname rankinst inst_sca if rankmex<=10, clean noobs

gsort - inst_sca
list rankmex shr_mexca dname msaname rankinst inst_sca if rankinst<=10, clean noobs

log close
