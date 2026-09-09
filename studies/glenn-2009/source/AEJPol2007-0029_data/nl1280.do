/***************************************************************************/
/*****                                                                 *****/
/*****                         NL1280                                  *****/
/*****                                                                 *****/
/***************************************************************************/

/* estimates the discrete choice model                                     */
/* of demand for the 128 MB pc 100 memory modules                          */
/* program runs under stata 8.0                                            */

cd c:/research/tax/aejfinal
capture clear
program drop _all

set more off


set matsize 800
set mem 800m
set maxvar 32000

capture log close
log using nl1280.log, replace

use nldata1280.dta

sort numdate h postal cnum
for num 1/24: gen byte bX=0
for num 1/24: replace bX=1 if cnum==2 & crank==X
for num 1/24: replace bX=1 if cnum[_n+1]==2 & crank[_n+1]==X & h==h[_n+1] & numdate==numdate[_n+1]



program define nlbase9
  version 7.0
  if "`1'"=="?" {
    global S_1 "HOME BOOST Taxwt PROX WKEND MINP PRICE PAGE2 SHIPTIME ST_FL ST_IL ST_OH ST_OR ST_PA ST_VA ST_WI ST_TX ST_AL ST_GA ST_AK ST_AZ ST_AR ST_CO ST_CT ST_DE ST_DC ST_HI ST_ID ST_IN ST_IA ST_KS ST_KY ST_LA ST_ME ST_MD ST_MA ST_MI ST_MN ST_MS ST_MO ST_MT ST_NE ST_NV ST_NH ST_NJ ST_NM ST_NY ST_NC ST_ND ST_OK ST_RI ST_SC ST_SD ST_TN ST_UT ST_VT ST_WA ST_WV ST_WY T1 T4 T7 T11"

    global HOME=0.477
    global Taxwt=0.050
    global PROX=-0.054
    global WKEND=-0.42
    global MINP=-0.0327
    global PRICE=-.566
    global PAGE2=-1.14
    global SHIPTIME=-0.035
    global BOOST=-.169

    global ST_FL=2.87
    global ST_IL=2.49
    global ST_OH=2.23
    global ST_OR=1.70
    global ST_PA=2.38
    global ST_VA=2.02
    global ST_WI=1.77
    global ST_TX=2.86
    global ST_AL=1.24
    global ST_GA=2.00
    global ST_AK=-0.09
    global ST_AZ=1.84
    global ST_AR=1.05
    global ST_CO=1.78
    global ST_CT=0.85
    global ST_DE=-0.17
    global ST_DC=-0.48
    global ST_HI=-0.085
    global ST_ID=0.77
    global ST_IN=1.81
    global ST_IA=1.43
    global ST_KS=1.21
    global ST_KY=1.24
    global ST_LA=1.63
    global ST_ME=0.66
    global ST_MD=1.52
    global ST_MA=1.91
    global ST_MI=2.14
    global ST_MN=1.77
    global ST_MS=0.47
    global ST_MO=1.89
    global ST_MT=-0.25
    global ST_NE=-0.20
    global ST_NV=1.00
    global ST_NH=0.34
    global ST_NJ=1.79
    global ST_NM=1.00
    global ST_NY=2.63
    global ST_NC=1.74
    global ST_ND=0.05
    global ST_OK=1.39
    global ST_RI=0.69
    global ST_SC=1.24
    global ST_SD=-0.13
    global ST_TN=1.78
    global ST_UT=0.74
    global ST_VT=-1.19
    global ST_WA=2.38
    global ST_WV=0.10
    global ST_WY=-0.56


    global T1=0.0185
    global T4=-0.040
    global T7=0.018
    global T11=-0.00236
    exit
  }
  tempvar m s

  
  quietly gen double `m'=exp($ST_FL) if postal=="FL"
  quietly replace `m'=exp($ST_IL) if postal=="IL"
  quietly replace `m'=exp($ST_OH) if postal=="OH"
  quietly replace `m'=exp($ST_OR) if postal=="OR"
  quietly replace `m'=exp($ST_PA) if postal=="PA"
  quietly replace `m'=exp($ST_VA) if postal=="VA"
  quietly replace `m'=exp($ST_WI) if postal=="WI"
  quietly replace `m'=exp($ST_TX) if postal=="TX"
  quietly replace `m'=exp($ST_AL) if postal=="AL"
  quietly replace `m'=exp($ST_GA) if postal=="GA"

  quietly replace `m'=exp($ST_AK) if postal=="AK"
  quietly replace `m'=exp($ST_AZ) if postal=="AZ"
  quietly replace `m'=exp($ST_AR) if postal=="AR"
  quietly replace `m'=exp($ST_CO) if postal=="CO"
  quietly replace `m'=exp($ST_CT) if postal=="CT"
  quietly replace `m'=exp($ST_DE) if postal=="DE"
  quietly replace `m'=exp($ST_DC) if postal=="DC"
  quietly replace `m'=exp($ST_HI) if postal=="HI"
  quietly replace `m'=exp($ST_ID) if postal=="ID"
  quietly replace `m'=exp($ST_IN) if postal=="IN"
  quietly replace `m'=exp($ST_IA) if postal=="IA"
  quietly replace `m'=exp($ST_KS) if postal=="KS"
  quietly replace `m'=exp($ST_KY) if postal=="KY"
  quietly replace `m'=exp($ST_LA) if postal=="LA"
  quietly replace `m'=exp($ST_ME) if postal=="ME"
  quietly replace `m'=exp($ST_MD) if postal=="MD"
  quietly replace `m'=exp($ST_MA) if postal=="MA"
  quietly replace `m'=exp($ST_MI) if postal=="MI"
  quietly replace `m'=exp($ST_MN) if postal=="MN"
  quietly replace `m'=exp($ST_MS) if postal=="MS"
  quietly replace `m'=exp($ST_MO) if postal=="MO"
  quietly replace `m'=exp($ST_MT) if postal=="MT"
  quietly replace `m'=exp($ST_NE) if postal=="NE"
  quietly replace `m'=exp($ST_NV) if postal=="NV"
  quietly replace `m'=exp($ST_NH) if postal=="NH"
  quietly replace `m'=exp($ST_NJ) if postal=="NJ"
  quietly replace `m'=exp($ST_NM) if postal=="NM"
  quietly replace `m'=exp($ST_NY) if postal=="NY"
  quietly replace `m'=exp($ST_NC) if postal=="NC"
  quietly replace `m'=exp($ST_ND) if postal=="ND"
  quietly replace `m'=exp($ST_OK) if postal=="OK"
  quietly replace `m'=exp($ST_RI) if postal=="RI"
  quietly replace `m'=exp($ST_SC) if postal=="SC"
  quietly replace `m'=exp($ST_SD) if postal=="SD"
  quietly replace `m'=exp($ST_TN) if postal=="TN"
  quietly replace `m'=exp($ST_UT) if postal=="UT"
  quietly replace `m'=exp($ST_VT) if postal=="VT"
  quietly replace `m'=exp($ST_WA) if postal=="WA"
  quietly replace `m'=exp($ST_WV) if postal=="WV"
  quietly replace `m'=exp($ST_WY) if postal=="WY"

  quietly replace `m'=`m'*hshare
  quietly replace `m'=`m'*exp($T1*t1+$T4*t4+$T7*t7+$T11*t11)
  quietly replace `m'=`m'*exp($MINP*price1)
  quietly replace `m'=`m'*exp($WKEND*weekend)
  

  quietly gen double `s'=exp($HOME*home1+$PRICE*(price1*(1+$Taxwt*tax*home1))+$SHIPTIME*ship1+$PROX*prox1+$BOOST*b1)
  quietly replace `s'=`s'+exp($HOME*home2+$PRICE*(price2*(1+$Taxwt*tax*home2))+$SHIPTIME*ship2+$PROX*prox2+$BOOST*b2) 
  quietly replace `s'=`s'+exp($HOME*home3+$PRICE*(price3*(1+$Taxwt*tax*home3))+$SHIPTIME*ship3+$PROX*prox3+$BOOST*b3) 
  quietly replace `s'=`s'+exp($HOME*home4+$PRICE*(price4*(1+$Taxwt*tax*home4))+$SHIPTIME*ship4+$PROX*prox4+$BOOST*b4) 
  quietly replace `s'=`s'+exp($HOME*home5+$PRICE*(price5*(1+$Taxwt*tax*home5))+$SHIPTIME*ship5+$PROX*prox5+$BOOST*b5)
  quietly replace `s'=`s'+exp($HOME*home6+$PRICE*(price6*(1+$Taxwt*tax*home6))+$SHIPTIME*ship6+$PROX*prox6+$BOOST*b6) 
  quietly replace `s'=`s'+exp($HOME*home7+$PRICE*(price7*(1+$Taxwt*tax*home7))+$SHIPTIME*ship7+$PROX*prox7+$BOOST*b7)
  quietly replace `s'=`s'+exp($HOME*home8+$PRICE*(price8*(1+$Taxwt*tax*home8))+$SHIPTIME*ship8+$PROX*prox8+$BOOST*b8) 
  quietly replace `s'=`s'+exp($HOME*home9+$PRICE*(price9*(1+$Taxwt*tax*home9))+$SHIPTIME*ship9+$PROX*prox9+$BOOST*b9) 
  quietly replace `s'=`s'+exp($HOME*home10+$PRICE*(price10*(1+$Taxwt*tax*home10))+$SHIPTIME*ship10+$PROX*prox10+$BOOST*b10) 
  quietly replace `s'=`s'+exp($HOME*home11+$PRICE*(price11*(1+$Taxwt*tax*home11))+$SHIPTIME*ship11+$PROX*prox11+$BOOST*b11) 
  quietly replace `s'=`s'+exp($HOME*home12+$PRICE*(price12*(1+$Taxwt*tax*home12))+$SHIPTIME*ship12+$PROX*prox12+$BOOST*b12) 
quietly replace `s'=`s'+exp($HOME*home13+$PAGE2+$PRICE*(price13*(1+$Taxwt*tax*home13))+$SHIPTIME*ship13+$PROX*prox13+$BOOST*b13) 
  quietly replace `s'=`s'+exp($HOME*home14+$PAGE2+$PRICE*(price14*(1+$Taxwt*tax*home14))+$SHIPTIME*ship14+$PROX*prox14+$BOOST*b14) 
  quietly replace `s'=`s'+exp($HOME*home15+$PAGE2+$PRICE*(price15*(1+$Taxwt*tax*home15))+$SHIPTIME*ship15+$PROX*prox15+$BOOST*b15) 
  quietly replace `s'=`s'+exp($HOME*home16+$PAGE2+$PRICE*(price16*(1+$Taxwt*tax*home16))+$SHIPTIME*ship16+$PROX*prox16+$BOOST*b16) 
  quietly replace `s'=`s'+exp($HOME*home17+$PAGE2+$PRICE*(price17*(1+$Taxwt*tax*home17))+$SHIPTIME*ship17+$PROX*prox17+$BOOST*b17) 
  quietly replace `s'=`s'+exp($HOME*home18+$PAGE2+$PRICE*(price18*(1+$Taxwt*tax*home18))+$SHIPTIME*ship18+$PROX*prox18+$BOOST*b18) 
  quietly replace `s'=`s'+exp($HOME*home19+$PAGE2+$PRICE*(price19*(1+$Taxwt*tax*home19))+$SHIPTIME*ship19+$PROX*prox19+$BOOST*b19) 
  quietly replace `s'=`s'+exp($HOME*home20+$PAGE2+$PRICE*(price20*(1+$Taxwt*tax*home20))+$SHIPTIME*ship20+$PROX*prox20+$BOOST*b20) 
  quietly replace `s'=`s'+exp($HOME*home21+$PAGE2+$PRICE*(price21*(1+$Taxwt*tax*home21))+$SHIPTIME*ship21+$PROX*prox21+$BOOST*b21) 
  quietly replace `s'=`s'+exp($HOME*home22+$PAGE2+$PRICE*(price22*(1+$Taxwt*tax*home22))+$SHIPTIME*ship22+$PROX*prox22+$BOOST*b22) 
  quietly replace `s'=`s'+exp($HOME*home23+$PAGE2+$PRICE*(price23*(1+$Taxwt*tax*home23))+$SHIPTIME*ship23+$PROX*prox23+$BOOST*b23) 
  quietly replace `s'=`s'+exp($HOME*home24+$PAGE2+$PRICE*(price24*(1+$Taxwt*tax*home24))+$SHIPTIME*ship24+$PROX*prox24+$BOOST*b24) 


  quietly replace `m'=`m'*exp($PRICE*(cprice*(1+$Taxwt*tax*chome))+$SHIPTIME*cship)
  quietly replace `m'=`m'*exp($HOME*chome) 
  quietly replace `m'=`m'*exp($PROX*cprox) 
  quietly replace `m'=`m'*exp($BOOST) if cnum==2
  quietly replace `m'=`m'*exp($PAGE2) if crank > 12
  quietly replace `m'=`m'/`s'
  replace `1'=`m'
end

nl base9 norder if postal~="CA"

/*
predict qpred

gen double npred=exp(_b[ST_FL]) if postal=="FL"
replace npred=exp(_b[ST_IL]) if postal=="IL"
replace npred=exp(_b[ST_OH]) if postal=="OH"
replace npred=exp(_b[ST_OR]) if postal=="OR"
replace npred=exp(_b[ST_PA]) if postal=="PA"
replace npred=exp(_b[ST_VA]) if postal=="VA"
replace npred=exp(_b[ST_WI]) if postal=="WI"
replace npred=exp(_b[ST_TX]) if postal=="TX"
replace npred=exp(_b[ST_AL]) if postal=="AL"
replace npred=exp(_b[ST_GA]) if postal=="GA"
replace npred=exp(_b[ST_AK]) if postal=="AK"
replace npred=exp(_b[ST_AZ]) if postal=="AZ"
replace npred=exp(_b[ST_AR]) if postal=="AR"
replace npred=exp(_b[ST_CO]) if postal=="CO"
replace npred=exp(_b[ST_CT]) if postal=="CT"
replace npred=exp(_b[ST_DE]) if postal=="DE"
replace npred=exp(_b[ST_DC]) if postal=="DC"
replace npred=exp(_b[ST_HI]) if postal=="HI"
replace npred=exp(_b[ST_ID]) if postal=="ID"
replace npred=exp(_b[ST_IN]) if postal=="IN"
replace npred=exp(_b[ST_IA]) if postal=="IA"
replace npred=exp(_b[ST_KS]) if postal=="KS"
replace npred=exp(_b[ST_KY]) if postal=="KY"
replace npred=exp(_b[ST_LA]) if postal=="LA"
replace npred=exp(_b[ST_ME]) if postal=="ME"
replace npred=exp(_b[ST_MD]) if postal=="MD"
replace npred=exp(_b[ST_MA]) if postal=="MA"
replace npred=exp(_b[ST_MI]) if postal=="MI"
replace npred=exp(_b[ST_MN]) if postal=="MN"
replace npred=exp(_b[ST_MS]) if postal=="MS"
replace npred=exp(_b[ST_MO]) if postal=="MO"
replace npred=exp(_b[ST_MT]) if postal=="MT"
replace npred=exp(_b[ST_NE]) if postal=="NE"
replace npred=exp(_b[ST_NV]) if postal=="NV"
replace npred=exp(_b[ST_NH]) if postal=="NH"
replace npred=exp(_b[ST_NJ]) if postal=="NJ"
replace npred=exp(_b[ST_NM]) if postal=="NM"
replace npred=exp(_b[ST_NY]) if postal=="NY"
replace npred=exp(_b[ST_NC]) if postal=="NC"
replace npred=exp(_b[ST_ND]) if postal=="ND"
replace npred=exp(_b[ST_OK]) if postal=="OK"
replace npred=exp(_b[ST_RI]) if postal=="RI"
replace npred=exp(_b[ST_SC]) if postal=="SC"
replace npred=exp(_b[ST_SD]) if postal=="SD"
replace npred=exp(_b[ST_TN]) if postal=="TN"
replace npred=exp(_b[ST_UT]) if postal=="UT"
replace npred=exp(_b[ST_VT]) if postal=="VT"
replace npred=exp(_b[ST_WA]) if postal=="WA"
replace npred=exp(_b[ST_WV]) if postal=="WV"
replace npred=exp(_b[ST_WY]) if postal=="WY"

replace npred=npred*hshare
replace npred=npred*exp(_b[T1]*t1+_b[T4]*t4+_b[T7]*t7+_b[T11]*t11)
replace npred=npred*exp(_b[MINP]*price1)
replace npred=npred*exp(_b[WKEND]*weekend)

gen share1=qpred/npred
gen share2=norder/npred

sum share1 share2 if postal~="CA" 
sum share1 share2 if postal~="CA" & cnum==1
sum share1 share2 if postal~="CA" & cnum==2

sort localh
tab localh, sum(hshare)

for num 1/24: gen dtaxX=homeX*priceX*tax
egen mhome=rmean(home1-home24)
egen mprox=rmean(prox1-prox24)
egen mdtax=rmean(dtax1-dtax24)
sum norder cprice price1 crank mhome chome mprox cprox mdtax if postal~="CA" 

*/

log close



