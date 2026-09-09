*Generate estimates for Table 3 column (1)
use  BBD-bpfe.dta, clear


areg D_ln_unemp_qd D_ln_ui i.qtr [aweight=wgt] if bbd_samp1==1, absorb(pair_id) cluster(pair_id)
nlcom exp(ln(.05)+(_b[D_ln_ui])*((1-(.891)^16)/(1-(.891)))*(ln(82.5)-ln(26)))
nlcom exp(ln(.05)+(_b[D_ln_ui])*((1)/(1-(.891)))*(ln(99)-ln(26)))

