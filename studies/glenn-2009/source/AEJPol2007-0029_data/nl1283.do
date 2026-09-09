/***************************************************************************/
/*****                                                                 *****/
/*****                         NL1283                                  *****/
/*****                                                                 *****/
/***************************************************************************/

/* performs discrete choice demand estimation                                 */
/* for 128 MB PC 133 memory modules                                           */
/* program runs under stata version 8.0                                       */


cd c:/research/tax/aejfinal
capture clear
program drop _all

set more off

set matsize 800
set mem 800m
set maxvar 32000

capture log close
log using nl1283.log, replace

use nldata1283.dta

sort numdate h postal cnum
for num 1/24: gen byte bX=0
for num 1/24: replace bX=1 if cnum==2 & crank==X
for num 1/24: replace bX=1 if cnum[_n+1]==2 & crank[_n+1]==X & h==h[_n+1] & numdate==numdate[_n+1]


program define nlbase9
  version 7.0
  if "`1'"=="?" {
    global S_1 "HOME BOOST Taxwt PROX WKEND MINP PRICE PAGE2 SHIPTIME ST_FL ST_IL ST_OH ST_OR ST_PA ST_VA ST_WI ST_TX ST_AL ST_GA ST_AK ST_AZ ST_AR ST_CO ST_CT ST_DE ST_DC ST_HI ST_ID ST_IN ST_IA ST_KS ST_KY ST_LA ST_ME ST_MD ST_MA ST_MI ST_MN ST_MS ST_MO ST_MT ST_NE ST_NV ST_NH ST_NJ ST_NM ST_NY ST_NC ST_ND ST_OK ST_RI ST_SC ST_SD ST_TN ST_UT ST_VT ST_WA ST_WV ST_WY T1 T4 T7 T11"

    global HOME=0.4414758
    global Taxwt=0.0694581
    global PROX=0
    global WKEND=-0.4339595
    global MINP=-0.0316861
    global PRICE=-.5466305
    global PAGE2=-1.036888
    global SHIPTIME=0.00
    global BOOST=-.1807

    global ST_FL=1.519594
    global ST_IL=1.117243
    global ST_OH=0.8452633
    global ST_OR=0.3650221
    global ST_PA=1.035233
    global ST_VA=0.6633362
    global ST_WI=0.4115461
    global ST_TX=1.532373
    global ST_AL=-0.1157187
    global ST_GA=0.5932382

    global ST_AK=0.0
    global ST_AZ=0.0
    global ST_AR=0.0
    global ST_CO=0.0
    global ST_CT=0.0
    global ST_DE=0.0
    global ST_DC=0.0
    global ST_HI=0.0
    global ST_ID=0.0
    global ST_IN=0.0
    global ST_IA=0.0
    global ST_KS=0.0
    global ST_KY=0.0
    global ST_LA=0.0
    global ST_ME=0.0
    global ST_MD=0.0
    global ST_MA=0.0
    global ST_MI=0.0
    global ST_MN=0.0
    global ST_MS=0.0
    global ST_MO=0.0
    global ST_MT=0.0
    global ST_NE=0.0
    global ST_NV=0.0
    global ST_NH=0.0
    global ST_NJ=0.0
    global ST_NM=0.0
    global ST_NY=0.0
    global ST_NC=0.0
    global ST_ND=0.0
    global ST_OK=0.0
    global ST_RI=0.0
    global ST_SC=0.0
    global ST_SD=0.0
    global ST_TN=0.0
    global ST_UT=0.0
    global ST_VT=0.0
    global ST_WA=0.0
    global ST_WV=0.0
    global ST_WY=0.0


    global T1=0.0163087
    global T4=-0.0367654
    global T7=0.0184545
    global T11=-0.0070031
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


log close



