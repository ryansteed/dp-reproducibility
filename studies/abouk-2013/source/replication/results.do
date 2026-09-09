set more off
clear

* log using c:\aej\results, replace


use estdata

* Table 2
sum accidentsvso txmsban pop unemp permale2 rgastax if treated==0 & state~=2 & txmsban==0
sum accidentsvso txmsban pop unemp permale2 rgastax if treated==1 &  state~=2
sum accidentsvso txmsban pop unemp permale2 rgastax if treated==1 & txmsban==0 & state~=2
sum accidentsvso txmsban pop unemp permale2 rgastax if treated==1 & txmsban==1 & state~=2




*Table 3
*-------------------


gen strongban= second~=1 & agelimit~=1 & txmsban==1
gen weakban= strongban==0 & txmsban==1


*Model 1a
eststo: reg laccidentsvso2 txmsban lpop lunemp permale2 lrgastax  st1-st50 t1-t48 [aweight=pop],cluster(state)

eststo main: reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax st1-st50 t1-t48 [aweight=pop],cluster(state)

eststo:reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax  laccidentmv2 st1-st50 t1-t48 [aweight=pop],cluster(state)

eststo:reg laccidentsvso2 weakban strongban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 time time stt1-stt50 [aweight=pop],cluster(state)

eststo:reg laccidentsvso2 weakban strongban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48 time stt1-stt50 [aweight=pop],cluster(state)

*** EDITED by Donna
estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

/*
*Figures
*-------------------

gen lead11sb=cond(second~=1 & agelimit~=1,lead11,0)
gen lead10sb=cond(second~=1 & agelimit~=1,lead10,0)
gen lead9sb=cond(second~=1 & agelimit~=1,lead9,0)
gen lead8sb=cond(second~=1 & agelimit~=1,lead8,0)
gen lead7sb=cond(second~=1 & agelimit~=1,lead7,0)
gen lead6sb=cond(second~=1 & agelimit~=1,lead6,0)
gen lead5sb=cond(second~=1 & agelimit~=1,lead5,0)
gen lead4sb=cond(second~=1 & agelimit~=1,lead4,0)
gen lead3sb=cond(second~=1 & agelimit~=1,lead3,0)
gen lead2sb=cond(second~=1 & agelimit~=1,lead2,0)
gen lead1sb=cond(second~=1 & agelimit~=1,lead1,0)
gen lag1sb=cond(second~=1 & agelimit~=1,lag1,0)
gen lag2sb=cond(second~=1 & agelimit~=1,lag2,0)
gen lag3sb=cond(second~=1 & agelimit~=1,lag3,0)
gen lag4sb=cond(second~=1 & agelimit~=1,lag4,0)
gen lag5sb=cond(second~=1 & agelimit~=1,lag5,0)
gen lag5psb=cond(second~=1 & agelimit~=1,lag5p,0)
gen lag6sb=cond(second~=1 & agelimit~=1,lag6,0)
gen lag7sb=cond(second~=1 & agelimit~=1,lag7,0)
gen lag8sb=cond(second~=1 & agelimit~=1,lag8,0)
gen lag8psb=cond(second~=1 & agelimit~=1,lag8p,0)
gen lag9sb=cond(second~=1 & agelimit~=1,lag9,0)
gen lag10sb=cond(second~=1 & agelimit~=1,lag10,0)
gen lag11psb=cond(second~=1 & agelimit~=1,lag11p,0)






gen lead11wb=cond(agelimit~=0 | second~=0,lead11,0)
gen lead10wb=cond(agelimit~=0 | second~=0,lead10,0)
gen lead9wb=cond(agelimit~=0 | second~=0,lead9,0)
gen lead8wb=cond(agelimit~=0 | second~=0,lead8,0)
gen lead7wb=cond(agelimit~=0 | second~=0,lead7,0)
gen lead6wb=cond(agelimit~=0 | second~=0,lead6,0)
gen lead5wb=cond(agelimit~=0 | second~=0,lead5,0)
gen lead4wb=cond(agelimit~=0 | second~=0,lead4,0)
gen lead3wb=cond(agelimit~=0 | second~=0,lead3,0)
gen lead2wb=cond(agelimit~=0 | second~=0,lead2,0)
gen lead1wb=cond(agelimit~=0 | second~=0,lead1,0)
gen lag1wb=cond(agelimit~=0 | second~=0,lag1,0)
gen lag2wb=cond(agelimit~=0 | second~=0,lag2,0)
gen lag3wb=cond(agelimit~=0 | second~=0,lag3,0)
gen lag4wb=cond(agelimit~=0 | second~=0,lag4,0)
gen lag5wb=cond(agelimit~=0 | second~=0,lag5,0)
gen lag5pwb=cond(agelimit~=0 | second~=0,lag5p,0)
gen lag6wb=cond(agelimit~=0 | second~=0,lag6,0)
gen lag7wb=cond(agelimit~=0 | second~=0,lag7,0)
gen lag8wb=cond(agelimit~=0 | second~=0,lag8,0)
gen lag8pwb=cond(agelimit~=0 | second~=0,lag8p,0)
gen lag9wb=cond(agelimit~=0 | second~=0,lag9,0)
gen lag10wb=cond(agelimit~=0 | second~=0,lag10,0)
gen lag11pwb=cond(agelimit~=0 | second~=0,lag11p,0)






reg laccidentsvso2 lead5sb lead4sb lead3sb lead2sb lead1sb lag1sb lag2sb lag3sb lag4sb lag5psb  lead5wb lead4wb lead3wb lead2wb lead1wb lag1wb lag2wb lag3wb lag4wb lag5pwb   lpop lunemp permale2 lrgastax  laccidentmv2  st1-st50 t1-t48 stb1-stb51 [aweight=pop],cluster(state) 

reg laccidentsvso2 lead5sb lead4sb lead3sb lead2sb lead1sb lag1sb lag2sb lag3sb lag4sb lag5psb  lead5wb lead4wb lead3wb lead2wb lead1wb lag1wb lag2wb lag3wb lag4wb lag5pwb   lpop lunemp permale2 lrgastax  laccidentmv2  st1-st50 t1-t48 stb1-stb51 time stt1-stt50 [aweight=pop],cluster(state) 



* Handheld 


* No handheld ban

reg laccidentsvso2 lead5sb lead4sb lead3sb lead2sb lead1sb lag1sb lag2sb lag3sb lag4sb lag5psb  lead5wb lead4wb lead3wb lead2wb lead1wb lag1wb lag2wb lag3wb lag4wb lag5pwb   lpop lunemp permale2 lrgastax  laccidentmv2  st1-st50 t1-t48 stb1-stb51 [aweight=pop] if (HHBAN==0|treated==0),cluster(state)


reg laccidentsvso2 lead5sb lead4sb lead3sb lead2sb lead1sb lag1sb lag2sb lag3sb lag4sb lag5psb  lead5wb lead4wb lead3wb lead2wb lead1wb lag1wb lag2wb lag3wb lag4wb lag5pwb   lpop lunemp permale2 lrgastax  laccidentmv2  st1-st50 t1-t48 stb1-stb51 time stt1-stt50 [aweight=pop] if (HHBAN==0|treated==0),cluster(state)

* No handheld ban

reg laccidentsvso2 lead5sb lead4sb lead3sb lead2sb lead1sb lag1sb lag2sb lag3sb lag4sb lag5psb  lead5wb lead4wb lead3wb lead2wb lead1wb lag1wb lag2wb lag3wb lag4wb lag5pwb   lpop lunemp permale2 lrgastax  laccidentmv2  st1-st50 t1-t48 stb1-stb51 [aweight=pop] if (HHBAN==1|treated==0),cluster(state)


reg laccidentsvso2 lead5sb lead4sb lead3sb lead2sb lead1sb lag1sb lag2sb lag3sb lag4sb lag5psb  lead5wb lead4wb lead3wb lead2wb lead1wb lag1wb lag2wb lag3wb lag4wb lag5pwb   lpop lunemp permale2 lrgastax  laccidentmv2  st1-st50 t1-t48 stb1-stb51 time stt1-stt50 [aweight=pop] if (HHBAN==1|treated==0),cluster(state)



****longer lags

reg laccidentsvso2 lead8sb lead7sb lead6sb lead5sb lead4sb lead3sb lead2sb lead1sb lag1sb lag2sb lag3sb lag4sb lag5sb lag6sb lag7sb lag8psb lead8wb lead7wb lead6wb lead5wb lead4wb lead3wb lead2wb lead1wb lag1wb lag2wb lag3wb lag4wb lag5wb lag6wb lag7wb lag8pwb  lpop lunemp permale2 lrgastax  laccidentmv2  st1-st50 t1-t48 stb1-stb51 [aweight=pop],cluster(state) 

reg laccidentsvso2 lead8sb lead7sb lead6sb lead5sb lead4sb lead3sb lead2sb lead1sb lag1sb lag2sb lag3sb lag4sb lag5sb lag6sb lag7sb lag8psb lead8wb lead7wb lead6wb lead5wb lead4wb lead3wb lead2wb lead1wb lag1wb lag2wb lag3wb lag4wb lag5wb lag6wb lag7wb lag8pwb  lpop lunemp permale2 lrgastax  laccidentmv2  st1-st50 t1-t48 stb1-stb51 time stt1-stt50 [aweight=pop],cluster(state) 





reg laccidentsvso2 lead11sb lead10sb lead9sb lead8sb lead7sb lead6sb lead5sb lead4sb lead3sb lead2sb lead1sb lag1sb lag2sb lag3sb lag4sb lag5sb lag6sb lag7sb lag8sb lag9sb lag10sb lag11psb lead11wb lead10wb lead9wb lead8wb lead7wb lead6wb lead5wb lead4wb lead3wb lead2wb lead1wb lag1wb lag2wb lag3wb lag4wb lag5wb lag6wb lag7wb lag8wb lag9wb lag10wb lag11pwb  lpop lunemp permale2 lrgastax  laccidentmv2  st1-st50 t1-t48 stb1-stb51 [aweight=pop],cluster(state) 

reg laccidentsvso2 lead11sb lead10sb lead9sb lead8sb lead7sb lead6sb lead5sb lead4sb lead3sb lead2sb lead1sb lag1sb lag2sb lag3sb lag4sb lag5sb lag6sb lag7sb lag8sb lag9sb lag10sb lag11psb lead11wb lead10wb lead9wb lead8wb lead7wb lead6wb lead5wb lead4wb lead3wb lead2wb lead1wb lag1wb lag2wb lag3wb lag4wb lag5wb lag6wb lag7wb lag8wb lag9wb lag10wb lag11pwb lpop lunemp permale2 lrgastax  laccidentmv2  st1-st50 t1-t48 stb1-stb51 time stt1-stt50 [aweight=pop],cluster(state) 












************************************************************************************************************************************************************************************************************************************************
** Table 4 (without trends)

*1

reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48 [aweight=pop],cluster(state)

reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 time time stt1-stt50 [aweight=pop],cluster(state)

reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48  time time stt1-stt50 [aweight=pop],cluster(state)


*2

reg laccident2 strongban weakban lpop lunemp permale2  lrgastax st1-st50 t1-t48 [aweight=pop],cluster(state)

reg laccident2 strongban weakban lpop lunemp permale2  lrgastax st1-st50 time time stt1-stt50[aweight=pop],cluster(state)

reg laccident2 strongban weakban lpop lunemp permale2  lrgastax st1-st50 t1-t48 time time stt1-stt50[aweight=pop],cluster(state)




*3 

reg laccidentmv2 strongban weakban lpop lunemp permale2  lrgastax st1-st50 t1-t48 [aweight=pop],cluster(state)






reg laccidentmv2 strongban weakban lpop lunemp permale2  lrgastax st1-st50 time time stt1-stt50[aweight=pop],cluster(state)

reg laccidentmv2 strongban weakban lpop lunemp permale2  lrgastax st1-st50 t1-t48 time time stt1-stt50[aweight=pop],cluster(state)



*diff diff

save c:\aej\temp, replace
keep laccidentmv2 txmsban strongban weakban lpop lunemp permale2  lrgastax st1-st50 t1-t48 time time stt1-stt50 pop state second agelimit
gen svso = 0
gen laccident = laccidentmv2
save c:\aej\tempmv, replace

clear
use c:\aej\temp
keep laccidentsvso2 txmsban strongban weakban lpop lunemp permale2  lrgastax st1-st50 t1-t48 time time stt1-stt50 pop state second agelimit
gen svso = 1
gen laccident = laccidentsvso2

append using c:\aej\tempmv

gen svso_ban = svso*txmsban
gen svso_sban = svso*strongban
gen svso_wban = svso*weakban



reg laccident strongban weakban svso svso_sban svso_wban  lpop lunemp permale2  lrgastax st1-st50 t1-t48 [aweight=pop],cluster(state)


reg laccident strongban weakban svso svso_sban svso_wban  lpop lunemp permale2  lrgastax st1-st50 time time stt1-stt50 [aweight=pop],cluster(state)

reg laccident strongban weakban svso svso_sban svso_wban  lpop lunemp permale2  lrgastax st1-st50 t1-t48 time time stt1-stt50 [aweight=pop],cluster(state)

clear
use c:\aej\temp




***vehicle miles travelled falsification

reg lvmt strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48 [aweight=pop],cluster(state)

reg lvmt strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 time time stt1-stt50[aweight=pop],cluster(state)

reg lvmt strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48 time stt1-stt50[aweight=pop],cluster(state)




***accident per vehicle miles travelled falsification

reg lacc2vmt strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48 [aweight=pop],cluster(state)

reg lacc2vmt strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 time stt1-stt50[aweight=pop],cluster(state)

reg lacc2vmt strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48 time stt1-stt50[aweight=pop],cluster(state)







**hand held/none


reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48 [aweight=pop] if (HHBAN==0|treated==0),cluster(state)

reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 time stt1-stt50 [aweight=pop] if (HHBAN==0|treated==0),cluster(state)


reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48 time stt1-stt50 [aweight=pop] if (HHBAN==0|treated==0),cluster(state)





reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48 laccidentmv2 [aweight=pop] if (HHBAN==1|treated==0),cluster(state)
reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax st1-st50 laccidentmv2 time stt1-stt50 [aweight=pop] if (HHBAN==1|treated==0),cluster(state)


reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax st1-st50 t1-t48 laccidentmv2 time stt1-stt50 [aweight=pop] if (HHBAN==1|treated==0),cluster(state)






**negative binomial

nbreg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48,cluster(state)

nbreg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax st1-st50 laccidentmv2 time stt1-stt50,cluster(state)

nbreg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax st1-st50 t1-t48 laccidentmv2 time stt1-stt50,cluster(state)



*year, moth feffects


xi: reg laccidentsvso2 strongban weakban lpop lunemp permale2  laccidentmv2 lrgastax st1-st50 mon1-mon12 i.year [aweight=pop],cluster(state)

xi: reg laccidentsvso2 strongban weakban lpop lunemp permale2  laccidentmv2 lrgastax st1-st50 mon1-mon12 i.year time stt1-stt50 [aweight=pop],cluster(state)

xi: reg laccidentsvso2 strongban weakban lpop lunemp permale2  laccidentmv2 lrgastax st1-st50 mon1-mon12 i.year time stt1-stt50 [aweight=pop],cluster(state)




* 1999

xi: reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48 [aweight=pop] if year<=2009,cluster(state)


xi: reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax st1-st50 t1-t48 laccidentmv2 time stt1-stt50 [aweight=pop] if year<=2009,cluster(state)

xi: reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax st1-st50 laccidentmv2 time stt1-stt50 [aweight=pop] if year<=2009,cluster(state)








*************************************************************************************************************************************************************************************************************************************************************************************************************************************new 
*Table A1
*-------------------

tsset time state 

newey laccidentsvso2 lpop lunemp permale2  lrgastax st1-st50 t1-t48 stb1-stb51 [aweight=pop],lag(1) force

newey laccidentsvso2 lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48 stb1-stb51[aweight=pop], lag(1)force






*Table A2

***old
*CA
newey laccidentsvso2 txmsban lpop lunemp permale2  lrgastax st1-st50 t1-t48 [aweight=pop] if state==6|state==4|state==32|state==41, lag(0) force


newey laccident2 txmsban lpop lunemp permale2  lrgastax st1-st50 t1-t48 [aweight=pop] if state==6|state==4|state==32|state==41 , lag(0) force


*LA

newey laccidentsvso2 txmsban lpop lunemp permale2  lrgastax st1-st50 t1-t48 [aweight=pop] if state==22|state==5|state==28|state==48, lag(0) force

newey laccident2 txmsban lpop lunemp permale2  lrgastax st1-st50 t1-t48 [aweight=pop] if state==22|state==5|state==28|state==48, lag(0) force


*MN

newey laccidentsvso2 txmsban lpop lunemp permale2  lrgastax st1-st50 t1-t48 [aweight=pop] if state==27|state==19|state==55, lag(0) force


newey laccident2 txmsban lpop lunemp permale2  lrgastax st1-st50 t1-t48 [aweight=pop] if state==27|state==19|state==55, lag(0) force



*WA
newey laccidentsvso2 txmsban lpop lunemp permale2  lrgastax st1-st50 t1-t48 [aweight=pop] if state==53|state==16|state==41, lag(0) force


newey laccident2 txmsban lpop lunemp permale2  lrgastax st1-st50 t1-t48 [aweight=pop] if state==53|state==16|state==41, lag(0) force





****************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************
******* additional robustness


reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48 [aweight=pop],cluster(state)

reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 time stt1-stt50 [aweight=pop],cluster(state)

reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48  time stt1-stt50 [aweight=pop],cluster(state)


*no weight 


reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48,cluster(state)

reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 time stt1-stt50,cluster(state)

reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48  time stt1-stt50 ,cluster(state)





*OLS acc pop

egen accmin = min(accidentsvso), by(state)
egen popmin = min(pop), by(state)



reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48 if popmin>2000000,cluster(state)

reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 time stt1-stt50 if popmin>2000000 ,cluster(state)

reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48  time stt1-stt50 if popmin>2000000,cluster(state)


reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48 if accmin>0,cluster(state)

reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 time stt1-stt50 if accmin>0,cluster(state)

reg laccidentsvso2 strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48  time stt1-stt50 if accmin>0,cluster(state)





* poisson

poisson accidentsvso strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48 if popmin>2000000,cluster(state)

poisson accidentsvso strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 time stt1-stt50 if popmin>2000000 ,cluster(state)

poisson accidentsvso strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48  time stt1-stt50 if popmin>2000000,cluster(state)


poisson accidentsvso strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48 if accmin>0,cluster(state)

poisson accidentsvso strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 time stt1-stt50 if accmin>0 ,cluster(state)

poisson accidentsvso strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48  time stt1-stt50 if accmin>0 ,cluster(state)




*nbreg


nbreg accidentsvso strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48 if popmin>2000000,cluster(state)

nbreg accidentsvso strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 time stt1-stt50 if popmin>2000000 ,cluster(state)

nbreg accidentsvso strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48  time stt1-stt50 if popmin>2000000,cluster(state)


nbreg accidentsvso strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48 if accmin>0,cluster(state)

nbreg accidentsvso strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 time stt1-stt50 if accmin>0 ,cluster(state)

nbreg accidentsvso strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48  time stt1-stt50 if accmin>0 ,cluster(state)



**Illinois and New Mexico


reg laccidentsvso strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48 [aweight=pop] if state~=17,cluster(state)

reg laccidentsvso strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 time stt1-stt50 [aweight=pop] if state~=17,cluster(state)

reg laccidentsvso strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48  time stt1-stt50 [aweight=pop] if state~=17,cluster(state)


reg laccidentsvso strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48 [aweight=pop] if state~=35,cluster(state)

reg laccidentsvso strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 time stt1-stt50 [aweight=pop] if state~=35,cluster(state)

reg laccidentsvso strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48  time stt1-stt50 [aweight=pop] if state~=35,cluster(state)



**balanced

reg laccidentsvso strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48 [aweight=pop] if balanced==1,cluster(state)

reg laccidentsvso strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 time stt1-stt50 [aweight=pop] if balanced==1,cluster(state)

reg laccidentsvso strongban weakban lpop lunemp permale2  lrgastax laccidentmv2 st1-st50 t1-t48  time stt1-stt50 [aweight=pop] if balanced==1,cluster(state)











****************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************
******* robustness for lead lags


* 0


reg laccidentsvso2 lead5sb lead4sb lead3sb lead2sb lead1sb lag1sb lag2sb lag3sb lag4sb lag5psb  lead5wb lead4wb lead3wb lead2wb lead1wb lag1wb lag2wb lag3wb lag4wb lag5pwb   lpop lunemp permale2 lrgastax  laccidentmv2  st1-st50 t1-t48 stb1-stb51 time stt1-stt50 [aweight=pop],cluster(state) 


test lead5sb lead4sb lead3sb lead2sb lead1sb
test lead5wb lead4wb lead3wb lead2wb lead1wb




* 1

reg laccidentmv2 lead5sb lead4sb lead3sb lead2sb lead1sb lag1sb lag2sb lag3sb lag4sb lag5psb  lead5wb lead4wb lead3wb lead2wb lead1wb lag1wb lag2wb lag3wb lag4wb lag5pwb   lpop lunemp permale2 lrgastax  st1-st50 t1-t48 stb1-stb51 time stt1-stt50 [aweight=pop],cluster(state) 


test lead5sb lead4sb lead3sb lead2sb lead1sb
test lead5wb lead4wb lead3wb lead2wb lead1wb


* 2


reg lacc2vmt lead5sb lead4sb lead3sb lead2sb lead1sb lag1sb lag2sb lag3sb lag4sb lag5psb  lead5wb lead4wb lead3wb lead2wb lead1wb lag1wb lag2wb lag3wb lag4wb lag5pwb   lpop lunemp permale2 lrgastax  laccidentmv2  st1-st50 t1-t48 stb1-stb51 time stt1-stt50 [aweight=pop],cluster(state) 


test lead5sb lead4sb lead3sb lead2sb lead1sb
test lead5wb lead4wb lead3wb lead2wb lead1wb



* 3 
* Handheld 


reg laccidentsvso2 lead5sb lead4sb lead3sb lead2sb lead1sb lag1sb lag2sb lag3sb lag4sb lag5psb  lead5wb lead4wb lead3wb lead2wb lead1wb lag1wb lag2wb lag3wb lag4wb lag5pwb   lpop lunemp permale2 lrgastax  laccidentmv2  st1-st50 t1-t48 stb1-stb51 time stt1-stt50 [aweight=pop] if (HHBAN==1|treated==0),cluster(state)

test lead5sb lead4sb lead3sb lead2sb lead1sb
test lead5wb lead4wb lead3wb lead2wb lead1wb











* 4 
* No handheld ban

reg laccidentsvso2 lead5sb lead4sb lead3sb lead2sb lead1sb lag1sb lag2sb lag3sb lag4sb lag5psb  lead5wb lead4wb lead3wb lead2wb lead1wb lag1wb lag2wb lag3wb lag4wb lag5pwb   lpop lunemp permale2 lrgastax  laccidentmv2  st1-st50 t1-t48 stb1-stb51 time stt1-stt50 [aweight=pop] if (HHBAN==0|treated==0),cluster(state)

test lead5sb lead4sb lead3sb lead2sb lead1sb
test lead5wb lead4wb lead3wb lead2wb lead1wb






* 5
nbreg laccidentsvso2 lead5sb lead4sb lead3sb lead2sb lead1sb lag1sb lag2sb lag3sb lag4sb lag5psb  lead5wb lead4wb lead3wb lead2wb lead1wb lag1wb lag2wb lag3wb lag4wb lag5pwb   lpop lunemp permale2 lrgastax  laccidentmv2  st1-st50 t1-t48 stb1-stb51 time stt1-stt50,cluster(state) 


test lead5sb lead4sb lead3sb lead2sb lead1sb
test lead5wb lead4wb lead3wb lead2wb lead1wb



* 6
* removing state-specifics

reg laccidentsvso2 lead5sb lead4sb lead3sb lead2sb lead1sb lag1sb lag2sb lag3sb lag4sb lag5psb  lead5wb lead4wb lead3wb lead2wb lead1wb lag1wb lag2wb lag3wb lag4wb lag5pwb   lpop lunemp permale2 lrgastax  laccidentmv2  st1-st50 t1-t48 time stt1-stt50 [aweight=pop],cluster(state) 


test lead5sb lead4sb lead3sb lead2sb lead1sb
test lead5wb lead4wb lead3wb lead2wb lead1wb


* 7
* balanced

reg laccidentsvso2 lead5sb lead4sb lead3sb lead2sb lead1sb lag1sb lag2sb lag3sb lag4sb lag5psb  lead5wb lead4wb lead3wb lead2wb lead1wb lag1wb lag2wb lag3wb lag4wb lag5pwb   lpop lunemp permale2 lrgastax  laccidentmv2  st1-st50 t1-t48 stb1-stb51 time stt1-stt50 [aweight=pop] if balanced==1,cluster(state) 


test lead5sb lead4sb lead3sb lead2sb lead1sb
test lead5wb lead4wb lead3wb lead2wb lead1wb

*/