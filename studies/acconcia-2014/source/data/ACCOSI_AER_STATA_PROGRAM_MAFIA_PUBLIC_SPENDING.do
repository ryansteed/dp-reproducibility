use "ACCOSI_AER_DATA_MAFIA_PUBLIC_SPENDING.dta", clear
tsset Id Year
********************
*Mean Difference
********************
gen Split_CD_NoCD=2 if Year>=1989 & Year<=1999
replace Split_CD_NoCD=1 if CD>0
gen LSplit_CD_NoCD=l.Split_CD_NoCD
*
gen Province_CD= (Province=="AGRIGENTO" | Province=="AVELLINO" | Province=="BARI" | Province=="BENEVENTO" | Province=="CALTANISSETTA" | Province=="CASERTA" | Province=="CATANIA" | Province=="CATANZARO" | Province=="LECCE" | Province=="MATERA" | Province=="MESSINA" | Province=="NAPOLI" | Province=="PALERMO" | Province=="RAGUSA" | Province=="REGGIO_CALABRIA" | Province=="SALERNO" | Province=="TORINO" | Province=="TRAPANI")
*
ttest Gprop if Year>=1990 & Year<=1999, by(LSplit_CD_NoCD) unequal
ttest G if Year>=1990 & Year<=1999, by(LSplit_CD_NoCD) unequal
ttest Gprop if Year>=1990 & Year<=1999 & Province_CD==1, by(LSplit_CD_NoCD) unequal
ttest G if Year>=1990 & Year<=1999 & Province_CD==1, by(LSplit_CD_NoCD) unequal
ttest Gprop if Year>=1990 & Year<=1999 & LSplit_CD_NoCD==2, by(Province_CD) unequal
ttest G if Year>=1990 & Year<=1999 & LSplit_CD_NoCD==2, by(Province_CD) unequal
*
drop Split_CD_NoCD LSplit_CD_NoCD Province_CD
********************
*Randomness
********************
quietly {
gen FirstCD91=  (Province=="NAPOLI" | Province=="CASERTA" | Province=="LECCE" | Province=="CATANZARO" | Province=="REGGIO_CALABRIA" | Province=="PALERMO" | Province=="MESSINA" | Province=="CATANIA") & Year<=1990
gen FirstCD92= (Province=="TRAPANI" | Province=="CALTANISSETTA" | Province=="RAGUSA" | Province=="AGRIGENTO") & Year<=1991
gen FirstCD93= (Province=="BARI" | Province=="AVELLINO" | Province=="SALERNO") & Year<=1992
gen FirstCD94= (Province=="MATERA" | Province=="BENEVENTO") & Year<=1993
gen FirstCD95= (Province=="TORINO") & Year<=1994
*
gen Trend=Year-1985
gen TrendFirstCD91=FirstCD91*Trend
gen TrendFirstCD92=FirstCD92*Trend
gen TrendFirstCD93=FirstCD93*Trend
gen TrendFirstCD94=FirstCD94*Trend
gen TrendFirstCD95=FirstCD95*Trend
*
gen AllTrendFirstCD=TrendFirstCD91+TrendFirstCD92+TrendFirstCD93+TrendFirstCD94+TrendFirstCD95
gen AllFirstCD=FirstCD91+FirstCD92+FirstCD93+FirstCD94+FirstCD95
*
label var AllFirstCD "Before First CD Dummy"
label var AllTrendFirstCD "Before First CD Trend"
*
eststo: reg Y Trend AllFirstCD AllTrendFirstCD , cluster(Group)
}
*
esttab est1, keep(AllFirstCD AllTrendFirstCD) b(2) se label
drop First* Trend* All*
est clear
quietly {
********************
*Generate Regressors
********************
foreach j in G Y U1 U2 Mafiosi Extortion Corruption1 Corruption2 Murder {
g L1`j'=L1.`j'
g L2`j'=L2.`j'
}
*
gen L2CD=L2.CD
gen L3CD=L3.CD
gen L1CD_S2=L.CD_S2
*
foreach j in Resignation Election Budget Others G_ex {
g L1`j'=L.`j'
}
*
summarize L1G if Year>=1990 & Year<=1999, meanonly
local L1Gmean = r(mean)
summarize L1G_ex if Year>=1990 & Year<=1999, meanonly
local L1G_exmean = r(mean)
g L1Gint=(L1G-`L1Gmean')*(L1G_ex-`L1G_exmean')
*
foreach j in G Y CD U1 U2 Mafiosi Extortion Corruption1 Corruption2 Murder ///
L1G L1Y L1CD L1U1 L1U2 L1Mafiosi L1Extortion L1Corruption1 L1Corruption2 L1Murder ///
L2G L2Y L2CD L2U1 L2U2 L2Mafiosi L2Extortion L2Corruption1 L2Corruption2 L2Murder ///
Resignation Election Budget Others L1Resignation L1Election L1Budget L1Others ///
L2CD L3CD CD_S1 L1CD_S2 ///
G_ex L1G_ex L1Gint {
xi: regress `j' i.Year i.Id if Year>=1990 & Year<=1999
predict temporaneo, residuals
replace `j'=temporaneo
drop temporaneo
}
drop _IYear*
drop _IId*
*
lab var Province "Province"
lab var Region "Region"
lab var Year "Year"
lab var Group "Cluster"
*
lab var G "G(t)"
lab var L1G "G(t-1)"
lab var L2G "G(t-2)"
lab var L1Y "Y(t-1)"
lab var L2Y "Y(t-2)"
lab var CD_S1 "CD-S1"
lab var L1CD_S2 "CD-S2(t-1)"
*
label variable Resignation "Resignation(t)"
label variable L1Resignation "Resignation(t-1)"
label variable Election "Election(t)"
label variable L1Election "Election(t-1)"
label variable Budget "Budget-No confidence vote(t)"
label variable L1Budget "Budget-No confidence vote(t-1)"
label variable Others "Others(t)"
label variable L1Others "Others(t-1)"
}
********************
*Baseline
********************
quietly {
local Controls L1U1 L1U2 L2U1 L2U2 L2CD L3CD Mafiosi Extortion Corruption1 Corruption2 Murder L1Mafiosi L1Extortion L1Corruption1 L1Corruption2 L1Murder L2Mafiosi L2Extortion L2Corruption1 L2Corruption2 L2Murder
*
reg Y G L1G L2G `Controls' [w=Pop] if Year>=1990 & Year<=1999,  cluster(Group)
est store R1
reg Y G L1G L2G L1Y L2Y `Controls' [w=Pop] if Year>=1990 & Year<=1999,  cluster(Group)
est store R2
*
reg G CD_S1 L1CD_S2 L1G L2G `Controls' [w=Pop] if Year>=1990 & Year<=1999,  cluster(Group)
test CD_S1 L1CD_S2 
estadd scalar Ftest_Instruments=r(F)
est store R3
eststo: ivreg2 Y (G = CD_S1 L1CD_S2) L1G L2G `Controls' [w=Pop] if Year>=1990 & Year<=1999, first partial(`Controls') cluster(Group)
est store R4
*
reg G CD_S1 L1CD_S2 L1G L2G L1Y L2Y `Controls' [w=Pop] if Year>=1990 & Year<=1999,  cluster(Group)
test CD_S1 L1CD_S2 
estadd scalar Ftest_Instruments=r(F)
est store R5
eststo: ivreg2 Y (G = CD_S1 L1CD_S2) L1G L2G L1Y L2Y `Controls' [w=Pop] if Year>=1990 & Year<=1999, first partial(`Controls') cluster(Group)
est store R6
}

*** EDITED by Donna
estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
save "post_replication.dta", replace

* esttab R1 R2 R3 R4 R5 R6, keep(G `IV' L1Y L2Y L1G L2G) order(G L1G L2G L1Y L2Y CD_S1 L1CD_S2) b(2) label ///
* stat(Ftest_Instruments) nonotes brackets alignment(l) title(Public Spending Multplier) nodepvars nonumbers mtitle(OLS OLS First_Stage Second_Stage First_Stage Second_Stage) se 
est clear
********************
*Exclusion Restriction
********************
quietly {
*
ivreg2 Y (G = CD_S1 L1CD_S2) L1G L2G L1Y L2Y L2CD L3CD L1U1 L1U2 L2U1 L2U2 [w=Pop] ///
if Year>=1990 & Year<=1999, first partial(L2CD L3CD L1U1 L1U2 L2U1 L2U2) cluster(Group)
matrix A=e(first)
estadd scalar Ftest_Instruments=A[3,1]
est store RdropCrime
*
foreach j in Resignation Election Budget Others {
local Controls L1U1 L1U2 L2U1 L2U2 L2CD L3CD Mafiosi Extortion Corruption1 Corruption2 Murder L1Mafiosi L1Extortion L1Corruption1 L1Corruption2 L1Murder L2Mafiosi L2Extortion L2Corruption1 L2Corruption2 L2Murder
*
ivreg2 Y (G = CD_S1 L1CD_S2) L1G L2G L1Y L2Y `Controls' `j' L1`j' [w=Pop] ///
if Year>=1990 & Year<=1999, first partial(`Controls') cluster(Group)
matrix A=e(first)
estadd scalar Ftest_Instruments=A[3,1]
est store R`j'
}
}
esttab RdropCrime RResignation RElection RBudget ROthers , keep(G L1G L2G L1Y L2Y Resignation Election Budget Others L1Resignation L1Election L1Budget L1Others) order(G L1G L2G L1Y L2Y) b(2) label ///
stat(Ftest_Instruments) nonotes brackets alignment(l) title(Do city council dismissals affect output independently of variation in public spending?) ///
nodepvars nonumbers mtitle((1) (2) (3) (4) (5)) se
*
est clear
********************
*Dropping Province
********************
quietly {
foreach j in NAPOLI CASERTA PALERMO CATANIA SALERNO BARI REGGIO_CALABRIA {
local Controls L1U1 L1U2 L2U1 L2U2 L2CD L3CD Mafiosi Extortion Corruption1 Corruption2 Murder L1Mafiosi L1Extortion L1Corruption1 L1Corruption2 L1Murder L2Mafiosi L2Extortion L2Corruption1 L2Corruption2 L2Murder
*
preserve
drop if Province=="`j'"
ivreg2 Y (G = CD_S1 L1CD_S2) L1G L2G L1Y L2Y `Controls' [w=Pop] ///
if Year>=1990 & Year<=1999, first partial(`Controls') cluster(Group)
matrix A=e(first)
estadd scalar Ftest_Instruments=A[3,1]
est store R`j'
restore
}
}
*
esttab R* , keep(G L1G L2G L1Y L2Y) order(G L1G L2G L1Y L2Y) b(2) label ///
stat(Ftest_Instruments) nonotes brackets alignment(l) title(Dropping Provinces) nodepvars nonumbers mtitle(NA CE PA CT SA BA RC) se
est clear
********************
*Spillover 1
********************
quietly {
local Controls L1U1 L1U2 L2U1 L2U2 L2CD L3CD Mafiosi Extortion Corruption1 Corruption2 Murder L1Mafiosi L1Extortion L1Corruption1 L1Corruption2 L1Murder L2Mafiosi L2Extortion L2Corruption1 L2Corruption2 L2Murder
*
ivreg2 Y (G = CD_S1 L1CD_S2) L1G L2G L1Y L2Y G_ex L1G_ex `Controls' [w=Pop] if Year>=1990 & Year<=1999, first partial(`Controls') cluster(Group)
matrix A=e(first)
estadd scalar Ftest_Instruments=A[3,1]
est store R1
*
ivreg2 Y (G = CD_S1 L1CD_S2) L1G L2G L1Y L2Y L1Gint `Controls' [w=Pop] if Year>=1990 & Year<=1999, first partial(`Controls') cluster(Group)
matrix A=e(first)
estadd scalar Ftest_Instruments=A[3,1]
est store R2
}
*
esttab R* , keep(G L1G L2G L1Y L2Y G_ex L1G_ex L1Gint) order(G L1G L2G L1Y L2Y G_ex L1G_ex L1Gint) b(2) label ///
stat(Ftest_Instruments) nonotes brackets alignment(l) title(Spillovers) nodepvars nonumbers mtitle((1) (2) (3) (4)) se
est clear
********************
*Further Results
********************
*
quietly {
local Controls L1U1 L1U2 L2U1 L2U2 L2CD L3CD Mafiosi Extortion Corruption1 Corruption2 Murder L1Mafiosi L1Extortion L1Corruption1 L1Corruption2 L1Murder L2Mafiosi L2Extortion L2Corruption1 L2Corruption2 L2Murder
*
ivreg2 Y (G = CD_S1 L1CD_S2) L1G L2G L1Y L2Y `Controls' [w=Pop] ///
if Year>=1990 & Year<=1999 & (Region=="ABRUZZO" | Region=="MOLISE" | Region=="CAMPANIA" | Region=="PUGLIA" | Region=="BASILICATA" | Region=="CALABRIA" | Region=="SICILIA" | Region=="SARDEGNA"), first partial(`Controls') cluster(Group)
matrix A=e(first)
estadd scalar Ftest=A[3,1]
est store R1
************
preserve
use "ACCOSI_AER_DATA_MAFIA_PUBLIC_SPENDING.dta", clear
tsset Id Year
foreach j in G Y U1 U2 Mafiosi Extortion Corruption1 Corruption2 Murder {
g L1`j'=L1.`j'
g L2`j'=L2.`j'
}
gen L2CD=L2.CD
gen L3CD=L3.CD
gen L1CD_S2=L.CD_S2
*
foreach j in G Y CD U1 U2 Mafiosi Extortion Corruption1 Corruption2 Murder ///
L1G L1Y L1CD L1U1 L1U2 L1Mafiosi L1Extortion L1Corruption1 L1Corruption2 L1Murder ///
L2G L2Y L2CD L2U1 L2U2 L2Mafiosi L2Extortion L2Corruption1 L2Corruption2 L2Murder ///
L2CD L3CD CD_S1 L1CD_S2 {
xi: regress `j' i.Id if Year>=1990 & Year<=1999
predict temporaneo, residuals
replace `j'=temporaneo
drop temporaneo
}
drop _IId*
lab var G "G(t)"
lab var L1G "G(t-1)"
lab var L2G "G(t-2)"
lab var L1Y "Y(t-1)"
lab var L2Y "Y(t-2)"
*
quietly {
local Controls L1U1 L1U2 L2U1 L2U2 L2CD L3CD Mafiosi Extortion Corruption1 Corruption2 Murder L1Mafiosi L1Extortion L1Corruption1 L1Corruption2 L1Murder L2Mafiosi L2Extortion L2Corruption1 L2Corruption2 L2Murder
*
xi: ivreg2 Y (G = CD_S1 L1CD_S2) L1G L2G L1Y L2Y `Controls' [w=Pop] ///
if Year>=1990 & Year<=1999, first partial(`Controls') cluster(Group)
matrix A=e(first)
estadd scalar Ftest=A[3,1]
est store R2
}
************
use "ACCOSI_AER_DATA_MAFIA_PUBLIC_SPENDING.dta", clear
tsset Id Year
foreach j in G Y U1 U2 Mafiosi Extortion Corruption1 Corruption2 Murder {
g L1`j'=L1.`j'
g L2`j'=L2.`j'
}
gen L2CD=L2.CD
gen L3CD=L3.CD
gen L1CD_S2=L.CD_S2
*
foreach j in G Y CD U1 U2 Mafiosi Extortion Corruption1 Corruption2 Murder ///
L1G L1Y L1CD L1U1 L1U2 L1Mafiosi L1Extortion L1Corruption1 L1Corruption2 L1Murder ///
L2G L2Y L2CD L2U1 L2U2 L2Mafiosi L2Extortion L2Corruption1 L2Corruption2 L2Murder ///
L2CD L3CD CD_S1 L1CD_S2 {
xi: regress `j' i.Year if Year>=1990 & Year<=1999
predict temporaneo, residuals
replace `j'=temporaneo
drop temporaneo
}
drop _IYear*
lab var G "G(t)"
lab var L1G "G(t-1)"
lab var L2G "G(t-2)"
lab var L1Y "Y(t-1)"
lab var L2Y "Y(t-2)"
*
quietly {
local Controls L1U1 L1U2 L2U1 L2U2 L2CD L3CD Mafiosi Extortion Corruption1 Corruption2 Murder L1Mafiosi L1Extortion L1Corruption1 L1Corruption2 L1Murder L2Mafiosi L2Extortion L2Corruption1 L2Corruption2 L2Murder
*
xi: ivreg2 Y (G = CD_S1 L1CD_S2) L1G L2G L1Y L2Y `Controls' [w=Pop] ///
if Year>=1990 & Year<=1999, first partial(`Controls') cluster(Group)
matrix A=e(first)
estadd scalar Ftest=A[3,1]
est store R3
}
restore
}
esttab R1 R2 R3 , keep(G L1Y L2Y L1G L2G) order(G L1G L2G L1Y L2Y) b(2) label ///
stat(Ftest) nonotes brackets alignment(l) title(Further Results) ///
nodepvars nonumbers mtitle("South" "Drop at" "Drop ai") se
*
clear all
********************
*Spillover Aggregation
********************
use "ACCOSI_AER_AGGDATA_MAFIA_PUBLIC_SPENDING", clear
quietly {
tsset Id Year
foreach j in G Y U1 U2 Mafiosi Extortion Corruption1 Corruption2 Murder {
g L1`j'=L1.`j'
g L2`j'=L2.`j'
}
gen L2CD=L2.CD
gen L3CD=L3.CD
gen L1CD_S2=L.CD_S2
foreach j in G Y CD U1 U2 Mafiosi Extortion Corruption1 Corruption2 Murder ///
L1G L1Y L1CD L1U1 L1U2 L1Mafiosi L1Extortion L1Corruption1 L1Corruption2 L1Murder ///
L2G L2Y L2CD L2U1 L2U2 L2Mafiosi L2Extortion L2Corruption1 L2Corruption2 L2Murder ///
L2CD L3CD CD_S1 L1CD_S2 {
xi: regress `j' i.Year i.Id if Year>=1990 & Year<=1999
predict temporaneo, residuals
replace `j'=temporaneo
drop temporaneo
}
*
lab var G "G(t)"
lab var L1G "G(t-1)"
lab var L2G "G(t-2)"
lab var L1Y "Y(t-1)"
lab var L2Y "Y(t-2)"
*
local Controls L1U1 L1U2 L2U1 L2U2 L2CD L3CD Mafiosi Extortion Corruption1 Corruption2 Murder L1Mafiosi L1Extortion L1Corruption1 L1Corruption2 L1Murder L2Mafiosi L2Extortion L2Corruption1 L2Corruption2 L2Murder
ivreg2 Y (G = CD_S1 L1CD_S2) L1G L2G L1Y L2Y `Controls' [w=Pop] if Year>=1990 & Year<=1999, first partial(`Controls') cluster(Group)
matrix A=e(first)
estadd scalar Ftest_Instruments=A[3,1]
est store RAggregated
}
esttab RAggregated , keep(G L1G L2G L1Y L2Y) order(G L1G L2G L1Y L2Y) b(2) label ///
stat(Ftest_Instruments) nonotes brackets alignment(l) title(Spillovers) nodepvars nonumbers mtitle((1) (2) (3) (4)) se
clear all
